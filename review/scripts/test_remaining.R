# Run from repo root: Rscript --vanilla review/scripts/test_remaining.R [report.json]
.libPaths(c(normalizePath('.R-library'),.libPaths()))
if(.Platform$OS.type=='windows') Sys.setlocale('LC_CTYPE','.UTF-8')
suppressPackageStartupMessages({library(shiny);library(shinyjs);library(plotly);library(dplyr);library(latex2exp)})
for(f in c('pmf_helpers.R','module_joint.R','module_conditional.R','module_expectation.R','module_probability.R','module_game_discrete.r'))
  source(file.path('Project_PPeek1ng/modules',f),encoding='UTF-8')
results <- new.env(); results$cases <- list()
record <- function(group,name,passed,detail=NULL) {
  if(length(results$cases)==0 || tail(results$cases,1)[[1]]$group!=group) cat('Checking',group,'\n')
  results$cases[[length(results$cases)+1L]] <- list(group=group,name=name,passed=isTRUE(passed),detail=detail)
}
html <- function(x) if(is.null(x)) '' else x$html
testServer(conditional_Server, {
  check_count <- 0L
  submit <- function(value) {
    check_count <<- check_count+1L
    session$setInputs(ans=value,check=check_count)
    identical(result()$status,'ok')
  }
  exact <- c(`2`=1-.8^5,`4`=sum(exp(-12)*12^(0:10)/factorial(0:10)),
    `6`=.8^2,`8`=1-exp(-1),`10`=integrate(function(z) exp(-z*z/2)/sqrt(2*pi),5/3,Inf,rel.tol=1e-13,abs.tol=1e-13)$value,
    `12`=9/14)
  labels <- c(`1`='Binomial',`3`='Poisson',`5`='Geometric',`7`='Exponential',
              `9`='Normal',`11`='Uniform',`13`='Gamma')
  for(i in seq_len(13)) {
    current_index(i); session$flushReact()
    if(as.character(i) %in% names(exact)) {
      value <- exact[[as.character(i)]]
      record('conditional',paste0('q',i,'_stored_exact'),abs(prob()$ans_val-value)<1e-12)
      record('conditional',paste0('q',i,'_exact'),submit(sprintf('%.16g',value)))
      record('conditional',paste0('q',i,'_rounded4'),submit(sprintf('%.4f',value)))
      record('conditional',paste0('q',i,'_wrong'),!submit(sprintf('%.6f',value+.02)))
      if(i %in% c(4,10)) record('conditional',paste0('q',i,'_old_rejected'),!submit(if(i==4) '.263' else '.0475'))
    } else {
      name <- labels[[as.character(i)]]
      for(value in c(name,toupper(name),paste(name,'distribution')))
        record('names',paste(i,value),submit(value))
      for(value in c('',paste('not',name),paste(name,'or something else'),if(i==1) 'Negative Binomial' else 'Binomial')) {
        if(value==name) next
        record('names',paste(i,'reject',value),!submit(value))
      }
      record('names',paste(i,'name_only_instruction'),grepl('parameters are not required',html(output$answer_input),fixed=TRUE))
    }
    tries(0)
    for(level in 1:3) {
      submit('wrong')
      wanted <- as.character(prob()[[c('hint1','hint2','solution')[level]]])
      record('conditional',paste0('q',i,'_feedback',level),grepl(wanted,html(output$feedback),fixed=TRUE))
    }
  }
  record('names','controlled_aliases',distribution_answer_matches(' gaussian distribution ','Normal') &&
    distribution_answer_matches('binom','Binomial') && !distribution_answer_matches('non-binomial','Binomial'))
  text <- paste(unlist(question_bank[[5]][c('question','hint1','hint2','solution')]),collapse=' ')
  record('geometric','q5_shift_and_support',grepl('Z=Y-1',text,fixed=TRUE) && grepl('Z=0,1,2',text,fixed=TRUE) &&
    !grepl('Y\\mid S=s \\sim Geometric',text,fixed=TRUE))
  text <- paste(unlist(question_bank[[6]][c('hint1','hint2','solution')]),collapse=' ')
  record('geometric','q6_attempts_event_preserved',grepl('Z=Y-1',text,fixed=TRUE) && grepl('0.64',text,fixed=TRUE))
})
testServer(expectation_Server, {
  check_count <- 0L
  submit <- function(value) {
    check_count <<- check_count+1L
    session$setInputs(ans=value,check=check_count)
    identical(result()$status,'ok')
  }
  expected <- c(2,24,2,10000/3,9,.5,2,24,65)
  for(i in seq_len(9)) {
    current_index(i); session$flushReact()
    record('expectation',paste0('q',i,'_stored_exact'),abs(prob()$ans_val-expected[i])<1e-12)
    if(i==8) next
    record('expectation',paste0('q',i,'_exact'),submit(sprintf('%.16g',expected[i])))
    record('expectation',paste0('q',i,'_wrong'),!submit(as.character(expected[i]+.1)))
    tries(0)
    for(level in 1:3) {
      submit('wrong')
      wanted <- as.character(prob()[[c('hint1','hint2','solution')[level]]])
      record('expectation',paste0('q',i,'_feedback',level),grepl(wanted,html(output$feedback),fixed=TRUE))
    }
  }
  current_index(4); session$flushReact()
  for(v in c('10000/3','3333.33','3333.3333333333')) record('precision',v,submit(v))
  for(v in c('3333.34','3333.32','NaN','1/0','')) record('precision',paste('reject',v),!submit(v))
  current_index(8); session$flushReact()
  record('two_answers','labels',all(vapply(c('Sunny:','Cloudy:'),function(x)grepl(x,html(output$answer_input),fixed=TRUE),logical(1))))
  pairs <- list(correct=c('24','12'),fractions=c('48/2','24/2'),swapped=c('12','24'),missing=c('24',''),wrong_sunny=c('25','12'),wrong_cloudy=c('24','13'),blank=c('',''))
  for(name in names(pairs)) {
    v <- pairs[[name]]; check_count <- check_count+1L
    session$setInputs(ans_sunny=v[1],ans_cloudy=v[2],check=check_count)
    record('two_answers',name,identical(result()$status=='ok',name %in% c('correct','fractions')))
  }
  session$setInputs(ans_sunny='24',ans_cloudy='13',check=check_count+1L)
  record('two_answers','targeted_cloudy_feedback',grepl('Check the Cloudy answer',html(output$feedback),fixed=TRUE))
  df <- data.frame(x=c(0,0,1,1),y=c(0,1,0,1),p_value=c(0,0,.3,.7),p_input=c('0','0','.3','.7'),id=1:4)
  pmf_final(df); session$setInputs(cond_type='yx')
  record('zero_marginal','expectation_Y_given_X',grepl('undefined: P(X = 0)',html(output$expectation_detail),fixed=TRUE))
  df$p_value <- c(0,.4,0,.6); pmf_final(df); session$setInputs(cond_type='xy')
  record('zero_marginal','expectation_X_given_Y',grepl('undefined: P(Y = 0)',html(output$expectation_detail),fixed=TRUE))
  df$p_value <- c(1e-8,1e-8,.3,.7-2e-8)
  df$p_input <- as.character(df$p_value); pmf_final(df); session$setInputs(cond_type='yx')
  record('small_marginal','positive_probability_not_zero_fraction',simp_frac(2e-8)!='0/1' && parse_user_prob(simp_frac(2e-8))==2e-8)
  record('small_marginal','sub_tolerance_positive_stays_positive',parse_user_prob(simp_frac(1e-14))>0)
  record('small_marginal','positive_divisor_not_zero',grepl('0.00000002',html(output$expectation_detail),fixed=TRUE) &&
    grepl('0.00000001',html(output$expectation_detail),fixed=TRUE) && !grepl('undefined',html(output$expectation_detail),fixed=TRUE))
})
testServer(prob_Server, {
  session$setInputs(dist='bern',p_bern=.5,n=5,p=.5,r_nb=2,p_nb=.5,pg=.5,lambda=5,
    n_hy=4,M_hy=3,N_hy=10,N_du=5,dist_cont='unif',a_unif=-5,b_unif=5,
    rate_exp=1,shape_gam=2,rate_gam=1,mean_norm=0,sd_norm=1,alpha_beta=2,beta_beta=2,
    df_chi=5,df_t=5,df1_f=5,df2_f=5)
  for(d in c('bern','binom','nbinom','geom','pois','hyper','dunifd')) {
    session$setInputs(dist=d); df <- dist_df()
    record('distributions',paste(d,'valid'),all(is.finite(as.matrix(df))) && all(df$pmf>=0) &&
      all(diff(df$cdf)>=0) && all(df$cdf>=0 & df$cdf<=1) && sum(df$pmf)>.998)
    k <- df$k[1]; session$setInputs(click_pmf=list(x=k+.05))
    record('distributions',paste(d,'click'),identical(selected_k(),k) && grepl('P(X =',output$sel_text,fixed=TRUE))
  }
  for(d in c('geom','nbinom')) for(p in c(.01,.5,.99,1)) {
    session$setInputs(dist=d,pg=p,p_nb=p,r_nb=20); df <- dist_df()
    expected_mean <- (if(d=='geom') 1 else 20)*(1-p)/p
    record('endpoints',paste(d,p),abs(df$pmf[1]-p^(if(d=='geom') 1 else 20))<1e-12 &&
      all(abs(df$mean-expected_mean)<1e-12) && all(is.finite(df$cdf)) && sum(df$pmf)>.998)
  }
  for(p in c(0,1)) for(d in c('bern','binom')) {
    session$setInputs(dist=d,p_bern=p,p=p)
    record('endpoints',paste(d,p),sum(dist_df()$pmf)==1 && max(dist_df()$pmf)==1)
  }
  session$setInputs(dist='dunifd',N_du=1)
  record('endpoints','DU_singleton',dist_df()$pmf==1 && dist_df()$cdf==1)
  for(d in c('unif','exp','gamma','norm','beta','chisq','t','f')) {
    session$setInputs(dist_cont=d); df <- dist_df_cont()
    record('distributions',paste(d,'continuous_valid'),all(is.finite(df$pdf)) && all(df$pdf>=0) &&
      all(is.finite(df$cdf)) && all(diff(df$cdf)>=-1e-12) && all(df$cdf>=0 & df$cdf<=1))
    session$setInputs(click_pdf_cont=list(x=mean(range(df$x))))
    record('distributions',paste(d,'density_click'),grepl('fX(',output$sel_text_cont,fixed=TRUE))
    # Evaluate actual renderers to detect singular/degenerate plotting errors.
    record('plots',d,!inherits(try(output$pdf_plot_cont,silent=TRUE),'try-error') &&
      !inherits(try(output$cdf_plot_cont,silent=TRUE),'try-error'))
  }
  session$setInputs(dist_cont='unif',a_unif=0,b_unif=0)
  invalid <- tryCatch(dist_df_cont(),error=identity)
  record('endpoints','uniform_equal_rejected',inherits(invalid,'validation') && grepl('a < b',conditionMessage(invalid),fixed=TRUE))
  session$setInputs(b_unif=1)
  record('endpoints','uniform_recovers',all(dist_df_cont()$pdf==1) && pdf_cdf_at_cont(.5)$cdf==.5)
  for(d in c('gamma','beta','chisq','f')) {
    session$setInputs(dist_cont=d,shape_gam=.01,rate_gam=.01,alpha_beta=.01,beta_beta=.01,df_chi=1,df1_f=1,df2_f=1)
    df <- dist_df_cont()
    record('singular_density',d,any(is.infinite(df$pdf)) && all(is.finite(df$cdf)) &&
      !inherits(try(output$pdf_plot_cont,silent=TRUE),'try-error') && !inherits(try(output$cdf_plot_cont,silent=TRUE),'try-error'))
  }
})
testServer(game_discrete_Server, {
  session$setInputs(startBtn=1)
  for(i in seq_len(7)) {
    record('game',paste(i,'chapter'),step()==i && grepl(paste0('Chapter ',i,'/7'),html(output$mainUI),fixed=TRUE))
    correct <- stories[[i]]$correct
    wrong <- setdiff(c('Bernoulli','Binomial','Geometric','Negative Binomial','Hypergeometric','Discrete Uniform','Poisson'),correct)
    for(level in 1:3) {
      do.call(session$setInputs,setNames(list(wrong[1],level),c(paste0('dist',i),paste0('submit',i))))
      feedback <- html(output[[paste0('feedback',i)]])
      record('game',paste(i,'wrong',level),grepl(if(level<3) paste('Hint',paste0(level,':')) else 'The correct one is',feedback,fixed=TRUE))
    }
    do.call(session$setInputs,setNames(list(correct,4),c(paste0('dist',i),paste0('submit',i))))
    record('game',paste(i,'correct'),grepl('Correct! This is',html(output[[paste0('feedback',i)]]),fixed=TRUE))
    do.call(session$setInputs,setNames(list(1),paste0('next',i)))
  }
  record('game','ending_and_scores',step()==8 && sum(score_table()$Score)==0 && sum(score_table()$Errors)==42)
  # Each chapter had 3 errors, scores are bounded below by zero.
  for(cycle in 1:3) {
    session$setInputs(restartBtn=cycle)
    record('game',paste('restart',cycle),step()==0 && all(score_table()$Errors==0) && tail(score_table()$Score,1)==21)
    session$setInputs(startBtn=cycle+1)
    record('game',paste('start',cycle),step()==1)
  }
  record('game_content','DU_assumption',grepl('modeling assumption',stories[[2]]$analysis,fixed=TRUE) &&
    grepl('with replacement',stories[[2]]$analysis,fixed=TRUE))
  record('game_content','fixed_HYP_sample',grepl('Hypergeometric(4, 1, 7)',stories[[5]]$analysis,fixed=TRUE))
})
# Exercise the real application server twice, with both sessions alive together.
original_dir <- getwd(); setwd('Project_PPeek1ng')
app_env <- new.env(parent=globalenv())
sys.source('main.R',envir=app_env)
setwd(original_dir)
session_a <- MockShinySession$new(); session_b <- MockShinySession$new()
state_a <- withReactiveDomain(session_a,app_env$server(session_a$input,session_a$output,session_a))
state_b <- withReactiveDomain(session_b,app_env$server(session_b$input,session_b$output,session_b))
session_a$flushReact(); session_b$flushReact()
session_a$setInputs('joint1-p_1'='1','joint1-p_2'='2','joint1-p_3'='3','joint1-p_4'='4','joint1-generate'=1)
a <- isolate(state_a$df_final)
record('sessions','A_committed',max(abs(a$p_value-c(.1,.2,.3,.4)))<1e-12)
record('sessions','B_starts_independently',!isTRUE(isolate(state_b$has_final)))
session_b$setInputs('joint1-p_1'='4','joint1-p_2'='3','joint1-p_3'='2','joint1-p_4'='1','joint1-generate'=1)
record('sessions','B_own_commit',max(abs(isolate(state_b$df_final$p_value)-c(.4,.3,.2,.1)))<1e-12)
session_a$flushReact()
record('sessions','B_does_not_overwrite_A',identical(isolate(state_a$df_final),a))
session_a$close(); session_b$close()
args <- commandArgs(trailingOnly=TRUE)
report <- list(date=format(Sys.time(),'%Y-%m-%d',tz='Pacific/Auckland'),total=length(results$cases),
  passed=sum(vapply(results$cases,function(x)x$passed,logical(1))),cases=results$cases,
  source_md5=as.list(tools::md5sum(list.files('Project_PPeek1ng',pattern='[.][Rr]$',recursive=TRUE,full.names=TRUE))))
jsonlite::write_json(report,if(length(args)) args[1] else 'review/evidence/final_remaining.json',auto_unbox=TRUE,pretty=TRUE,digits=16)
cat(report$passed,'/',report$total,'remaining-issue cases passed.\n')
failed <- Filter(function(x)!x$passed,results$cases)
if(length(failed)) {print(failed);quit(status=1)}
