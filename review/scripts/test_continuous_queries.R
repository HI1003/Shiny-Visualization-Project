# Run from the repository root. Uses generic distributions only.
.libPaths(c(normalizePath('.R-library'), .libPaths()))
if (.Platform$OS.type == 'windows') Sys.setlocale('LC_CTYPE', '.UTF-8')
suppressPackageStartupMessages({library(shiny); library(shinyjs); library(plotly); library(dplyr); library(latex2exp)})
for (file in c('pmf_helpers.R', 'past_exam_bank.R', 'learning_content.R', 'learning_practice.R', 'module_probability.R'))
  source(file.path('Project_PPeek1ng/modules', file), encoding = 'UTF-8')
checks <- list()
record <- function(name, passed) {
  checks[[length(checks) + 1L]] <<- list(name = name, passed = isTRUE(passed))
  if (!isTRUE(passed)) cat('FAIL', name, '\n')
}
near <- function(x, y) length(x) == length(y) && all(abs(x - y) < 1e-12)
testServer(prob_Server, args = list(course_path = function() 'legacy'), {
  session$setInputs(dist = 'bern', p_bern = .4, dist_cont = 'norm', a_unif = 0, b_unif = 1,
    rate_exp = 1, shape_gam = 2, rate_gam = 1, mean_norm = 0, sd_norm = 1,
    alpha_beta = 2, beta_beta = 2, df_chi = 2, df_t = 1, df1_f = 2, df2_f = 2)
  cases <- list(
    list(key='norm', step=.1, x=-1.1, pdf=.21785217703255053, cdf=.13566606094638267),
    list(key='unif', step=.01, x=.31, pdf=1, cdf=.31),
    list(key='exp', step=.1, x=1.3, pdf=exp(-1.3), cdf=1-exp(-1.3)),
    list(key='gamma', step=.1, x=1.3, pdf=1.3*exp(-1.3), cdf=1-exp(-1.3)*(1+1.3)),
    list(key='beta', step=.01, x=.31, pdf=6*.31*.69, cdf=3*.31^2-2*.31^3),
    list(key='chisq', step=.2, x=1, pdf=.5*exp(-.5), cdf=1-exp(-.5)),
    list(key='t', step=10, x=10, pdf=1/(pi*101), cdf=.5+atan(10)/pi),
    list(key='f', step=10, x=30, pdf=1/31^2, cdf=30/31)
  )
  for (case in cases) {
    session$setInputs(dist_cont = case$key)
    query <- continuous_query()
    position <- which.min(abs(query$x - case$x))
    record(paste0(case$key, '_adaptive_step'), near(query$reading$step, case$step))
    record(paste0(case$key, '_exact_query_position'), near(query$x[position], case$x))
    record(paste0(case$key, '_independent_density'), near(query$pdf[position], case$pdf))
    record(paste0(case$key, '_independent_cdf'), near(query$cdf[position], case$cdf))
    record(paste0(case$key, '_label_matches_actual_x'), near(as.numeric(query$labels), query$x))
    record(paste0(case$key, '_bounded_query_count'), length(query$x) >= 40 && length(query$x) <= 150)
    bounds <- default_range_cont()
    record(paste0(case$key, '_queries_within_shown_distribution'), all(query$x >= bounds[1] & query$x <= bounds[2]))
    pdf <- jsonlite::fromJSON(output$pdf_plot_cont, simplifyVector = FALSE)$x$data
    cdf <- jsonlite::fromJSON(output$cdf_plot_cont, simplifyVector = FALSE)$x$data
    record(paste0(case$key, '_renderers_share_query_x'), near(unlist(pdf[[1]]$x), unlist(cdf[[1]]$x)))
    record(paste0(case$key, '_smooth_curve_retained'), length(pdf[[2]]$x) >= 600 && length(cdf[[2]]$x) >= 600)
    curve_position <- which.min(abs(unlist(pdf[[2]]$x) - case$x))
    record(paste0(case$key, '_curve_passes_through_query'), near(pdf[[2]]$x[[curve_position]], case$x) &&
      near(pdf[[2]]$y[[curve_position]], case$pdf) && near(cdf[[2]]$y[[curve_position]], case$cdf))
  }
  session$setInputs(dist_cont='unif', a_unif=0, b_unif=100)
  record('wide_uniform_integer_queries', near(continuous_query()$reading$step, 1))
  session$setInputs(b_unif=.0001)
  query <- continuous_query()
  record('narrow_uniform_step', near(query$reading$step, .000001))
  record('narrow_uniform_label_precision', '0.000031' %in% query$labels)
  session$setInputs(dist_cont='exp', rate_exp=10)
  record('fast_exponential_step', near(continuous_query()$reading$step, .01))
  session$setInputs(dist_cont='norm', sd_norm=.01)
  query <- continuous_query(); position <- which.min(abs(query$x + .011))
  record('narrow_normal_step', near(query$reading$step, .001))
  record('narrow_normal_density', near(query$pdf[position], .21785217703255053/.01))
  record('narrow_normal_cdf', near(query$cdf[position], .13566606094638267))
  before <- query$reading$signature
  session$setInputs(mean_norm=.001)
  record('parameter_change_updates_revision', !identical(before, continuous_query()$reading$signature))
  for (key in c('gamma', 'beta', 'chisq', 'f')) {
    session$setInputs(dist_cont=key, shape_gam=.5, alpha_beta=.5, beta_beta=.5, df_chi=1, df1_f=1, df2_f=1)
    query <- continuous_query(); position <- which(query$x == 0)
    record(paste0(key, '_singular_density_is_not_zero'), length(position)==1 && is.infinite(query$pdf[position]))
    record(paste0(key, '_singular_cdf_is_zero'), length(position)==1 && query$cdf[position]==0)
    pdf <- jsonlite::fromJSON(output$pdf_plot_cont, simplifyVector=FALSE)$x$data[[1]]
    record(paste0(key, '_singular_density_omitted'), !0 %in% unlist(pdf$x))
    record(paste0(key, '_singular_query_indices_align'), near(unlist(query$reading$x), query$x) &&
      is.na(query$reading$density[[position]]) && query$reading$cumulative[[position]] == 0)
  }
})
args <- commandArgs(trailingOnly=TRUE)
report <- list(passed=sum(vapply(checks, `[[`, logical(1), 'passed')), total=length(checks), checks=checks)
jsonlite::write_json(report, if(length(args))args[1]else'.local/continuous_query_tests.json', auto_unbox=TRUE, pretty=TRUE)
cat(report$passed, '/', report$total, 'continuous query checks passed.\n')
if(report$passed != report$total) quit(status=1)
