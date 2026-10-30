# Run from repository root: Rscript --vanilla review/scripts/round1_audit.R
# Read-only audit of current source. This records known failures; it does not fix them.
.libPaths(c(normalizePath('.R-library'), .libPaths()))
Sys.setlocale('LC_CTYPE', '.UTF-8')
dir.create('.local/course-review', recursive = TRUE, showWarnings = FALSE)
find_assignment <- function(node, target) {
  found <- NULL
  walk <- function(x) {
    if (!(is.call(x) || is.expression(x) || is.pairlist(x))) return(invisible(NULL))
    if (is.call(x) && identical(x[[1]], as.name('<-')) &&
        is.symbol(x[[2]]) && as.character(x[[2]]) == target) found <<- x
    for (part in as.list(x)) try(walk(part), silent = TRUE)
  }
  walk(node)
  if (is.null(found)) stop('Assignment not found: ', target)
  found
}
banks <- list()
envs <- list()
for (module in c('joint', 'conditional', 'expectation')) {
  file <- paste0('Project_PPeek1ng/modules/module_', module, '.R')
  ast <- parse(file, encoding = 'UTF-8')
  env <- new.env(parent = globalenv())
  env$HTML <- identity
  getter <- switch(module, joint = 'get_joint_question_bank',
                   conditional = 'get_condition_question_bank',
                   expectation = 'get_expectation_question_bank')
  eval(find_assignment(ast, getter), env)
  eval(find_assignment(ast, 'is_correct'), env)
  banks[[module]] <- env[[getter]]()
  envs[[module]] <- env
}
jsonlite::write_json(banks, '.local/course-review/banks.json', auto_unbox = TRUE,
                     pretty = TRUE, digits = 16, na = 'null')
checks <- list(
  conditional_poisson = list(issue = 'R1-01', question = 4,
    expected = ppois(10, 12), stored = banks$conditional[[4]]$ans_val,
    correct_answer_accepted = envs$conditional$is_correct(
      as.character(ppois(10, 12)), banks$conditional[[4]]$ans_val, NA)),
  expectation_second_moment = list(issue = 'R1-02', question = 4,
    expected = 10000/3, stored = banks$expectation[[4]]$ans_val,
    exact_fraction_accepted = envs$expectation$is_correct('10000/3',
      banks$expectation[[4]]$ans_val, banks$expectation[[4]]$ans_frac),
    stored_decimal_accepted = envs$expectation$is_correct('3333.33',
      banks$expectation[[4]]$ans_val, banks$expectation[[4]]$ans_frac)),
  conditional_distribution_name = list(issue = 'R1-03', question = 1,
    stored = banks$conditional[[1]]$ans_text,
    wrong_negative_binomial_accepted = grepl(banks$conditional[[1]]$ans_text,
      'Negative Binomial', ignore.case = TRUE),
    negation_accepted = grepl(banks$conditional[[1]]$ans_text,
      'not Binomial', ignore.case = TRUE)),
  numeric_positive_control = list(one_eighth_accepted =
    envs$joint$is_correct('1/8', 1/8, NA), wrong_answer_rejected =
    !envs$joint$is_correct('1/7', 1/8, NA))
)
checks$conditional_default_table <- list(issue = 'R1-05',
  input_probabilities = c(188,16)/221,
  expected = c(188,16)/204,
  actual_scalar_ifelse = rep(ifelse(sum(c(188,16)/221)>0,
    (c(188,16)/221)/sum(c(188,16)/221), 0), 2))
checks$conditional_numeric_bank <- lapply(c(2,4,6,8,10,12), function(i) {
  expected <- switch(as.character(i), '2'=1-.8^5, '4'=ppois(10,12),
    '6'=.8^2, '8'=pexp(2,.5), '10'=pnorm(70,65,3,lower.tail=FALSE), '12'=90/140)
  list(question=i, expected=expected, stored=banks$conditional[[i]]$ans_val,
       accepted=envs$conditional$is_correct(as.character(expected),
         banks$conditional[[i]]$ans_val,banks$conditional[[i]]$ans_frac))
})
checks$expectation_numeric_bank <- lapply(seq_len(9), function(i) {
  expected <- c(10*.2,6*4,1/.5,10000/3,9,2/2^2,10*.2,24,50+5*3)[i]
  list(question=i, expected=expected, stored=banks$expectation[[i]]$ans_val,
       accepted=envs$expectation$is_correct(as.character(expected),
         banks$expectation[[i]]$ans_val,banks$expectation[[i]]$ans_frac),
       caveat=if(i==8) 'Prompt asks two values; only Sunny=24 is checked; Cloudy=12 also required.' else '')
})
prob_ast <- parse('Project_PPeek1ng/modules/module_probability.R', encoding='UTF-8')
prob_env <- new.env(parent=globalenv())
prob_env$validate <- shiny::validate
prob_env$need <- shiny::need
range_body <- find_assignment(prob_ast, 'default_range')[[3]][[2]]
dist_body <- find_assignment(prob_ast, 'dist_df')[[3]][[2]]
prob_env$default_range <- function() eval(range_body, prob_env)
checks$probability_endpoints <- lapply(c('geom','nbinom','bern','binom'), function(dist) {
  prob_env$input <- list(dist=dist, pg=1, p_nb=1, r_nb=2, p_bern=1, n=5, p=1)
  actual <- eval(dist_body, prob_env)
  list(distribution=dist, input_p=1, mass_at_zero=actual$pmf[actual$k==0],
       displayed_mean=actual$mean[1],
       endpoint_correct=if(dist %in% c('geom','nbinom')) actual$pmf[1]==1 else sum(actual$pmf)==1)
})
checks$invalid_mass_normalization <- list(issue='R1-06', input=c(-1,1,1,1),
  generated=c(-1,1,1,1)/sum(c(-1,1,1,1)),
  zero_total_result=as.character(c(0,0)/sum(c(0,0))))
stopifnot(length(banks$joint) == 10, length(banks$conditional) == 13,
          length(banks$expectation) == 9,
          checks$numeric_positive_control$one_eighth_accepted,
          checks$numeric_positive_control$wrong_answer_rejected)
dir.create('review/evidence', recursive = TRUE, showWarnings = FALSE)
source_files <- c('Project_PPeek1ng/main.R', list.files('Project_PPeek1ng/modules', full.names=TRUE))
jsonlite::write_json(list(baseline = trimws(system2('git', c('rev-parse','HEAD'), stdout=TRUE)),
  source_md5 = as.list(tools::md5sum(source_files)),
  counts = as.list(lengths(banks)), checks = checks), 'review/evidence/round1_numeric.json',
  auto_unbox = TRUE, pretty = TRUE, digits = 16, na = 'null')
print(checks)
