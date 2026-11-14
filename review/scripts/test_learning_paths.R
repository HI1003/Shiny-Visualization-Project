# Run from repository root. New paths use the real default; legacy suites retain their original 32-case library.
.libPaths(c(normalizePath('.R-library'),.libPaths()))
if(.Platform$OS.type=='windows') Sys.setlocale('LC_CTYPE','.UTF-8')
suppressPackageStartupMessages({library(shiny);library(shinyjs);library(plotly);library(dplyr);library(latex2exp)})
for(f in c('pmf_helpers.R','learning_content.R','learning_practice.R','module_joint.R','module_conditional.R','module_expectation.R','module_probability.R'))
  source(file.path('Project_PPeek1ng/modules',f),encoding='UTF-8')
cases<-list()
record<-function(group,name,passed) {
  cases[[length(cases)+1L]]<<-list(group=group,name=name,passed=isTRUE(passed))
  if(!isTRUE(passed)) cat('FAIL:',group,name,'\n')
}
html<-function(x) if(is.null(x)) '' else x$html
# Independent expected values, including fractions, rather than reading expected fields from the implementation.
answers<-list(
  J11=c(cell1='3/10',cell2='1/5',cell3='1/10',cell4='2/5'),J12=c(px='1/2',py='3/5'),
  J13=c(independent='no',joint='2/5',product='3/10'),
  C14=c(joint='2/5',ygivenx='4/5',xgiveny='2/3'),C15=c(defined='undefined',positive='3/4'),
  C16=c(model='Hypergeometric',n='5',M='8',N='20',mean='2'),
  C17=c(model='Negative Binomial',k='2',p='1/4',mean='6'),
  E10=c(mean0='2/5',mean1='4/5',mean='3/5',total='3/5',product='2/5'),
  E11=c(second='11',squared_mean='9',variance='2'),
  O01=c(cdf0='3/5',less1='3/5',atleast1='2/5',greater1='0'))
find_getter<-function(tree,name) {
  if(is.call(tree) && identical(tree[[1]],as.name('<-')) && identical(tree[[2]],as.name(name))) return(tree[[3]])
  if(is.call(tree)||is.expression(tree)) for(i in seq_along(tree)) {
    found<-tryCatch(find_getter(tree[[i]],name),error=function(e) NULL);if(!is.null(found))return(found)
  }
  NULL
}
get_bank<-function(module,text=NULL) {
  name<-switch(module,joint='get_joint_question_bank',conditional='get_condition_question_bank',expectation='get_expectation_question_bank')
  tree<-if(is.null(text))parse(paste0('Project_PPeek1ng/modules/module_',module,'.R'))else parse(text=text)
  fn<-find_getter(tree,name);stopifnot(!is.null(fn));eval(fn)()
}
banks<-list(joint=learning_questions(get_bank('joint'),'joint'),
  conditional=learning_questions(get_bank('conditional'),'conditional'),
  expectation=learning_questions(get_bank('expectation'),'expectation'),overview=learning_questions(list(),'overview'))
all_questions<-do.call(c,unname(banks));keys<-vapply(all_questions,`[[`,character(1),'key')
tracks<-vapply(all_questions,`[[`,character(1),'track')
record('catalog','42_unique_references',length(keys)==42 && !anyDuplicated(keys))
record('catalog','30_core_8_preview_4_further',identical(as.integer(table(factor(tracks,levels=c('core','preview','further')))),c(30L,8L,4L)))
record('catalog','original_32_retained',sum(vapply(all_questions,function(q)isTRUE(q$legacy),logical(1)))==32)
record('catalog','continuous_selection_is_scoped',length(learning_continuous_choices('core'))==0 &&
  setequal(unname(learning_continuous_choices('preview')),c('unif','exp','norm')) && length(learning_continuous_choices('further'))==8)
# Read the prior local commit as immutable source, and compare every original answer field.
baseline<-new.env(parent=globalenv())
for(module in c('joint','conditional','expectation')) {
  path<-paste0('Project_PPeek1ng/modules/module_',module,'.R')
  old<-system2('git',c('show',paste0('7852cc1:',path)),stdout=TRUE)
  fields<-c('id','ans_val','ans_frac','ans_text','ans_pair','tolerance')
  extract<-function(bank) lapply(bank,function(q) q[intersect(fields,names(q))])
  record('compatibility',paste0(module,'_answers_unchanged'),identical(extract(get_bank(module)),extract(get_bank(module,old))))
}
run_practice<-function(module,server_fn) {
  path_state<-reactiveVal('core')
  testServer(server_fn,args=list(course_path=function() path_state()),{
    session$flushReact();counter<-0L
    expected_total<-c(joint=13,conditional=10,expectation=6)[[module]]
    record(module,'default_is_core',practice$total()==expected_total && all(vapply(practice$questions[practice$active_indices()],function(q)q$track=='core',logical(1))))
    record(module,'first_reference',prob()$key==c(joint='J11',conditional='C14',expectation='E01')[[module]])
    submit<-function(q,values) {
      counter<<-counter+1L
      inputs<-as.list(values);names(inputs)<-paste0('answer_',q$key,'_',names(values));inputs$check<-counter
      do.call(session$setInputs,inputs);identical(result()$status,'ok')
    }
    fresh<-which(vapply(practice$questions,function(q)!isTRUE(q$legacy),logical(1)))
    for(i in fresh) {
      current_index(i);session$flushReact();q<-prob();values<-answers[[q$key]]
      record(module,paste(q$key,'correct_fraction_fields'),submit(q,values))
      record(module,paste(q$key,'count_once'),practice$completed()<=length(fresh))
      record(module,paste(q$key,'repeat_no_extra_credit'),submit(q,values) && sum(practice$solved()==q$key)==1)
      wrong<-values;wrong[length(wrong)]<-''
      record(module,paste(q$key,'missing_field_rejected'),!submit(q,wrong))
      wrong[length(wrong)]<-'999'
      record(module,paste(q$key,'one_wrong_field_rejected'),!submit(q,wrong) && grepl('Check:',html(output$feedback),fixed=TRUE))
      tries(0)
      for(level in 1:3) {
        submit(q,wrong)
        record(module,paste(q$key,'feedback',level),grepl(as.character(q[[c('hint1','hint2','solution')[level]]]),html(output$feedback),fixed=TRUE))
      }
    }
    record(module,'all_new_questions_counted',practice$completed()==length(fresh))
    first<-practice$active_indices()[1];current_index(first);session$flushReact()
    current_index(NA_integer_);session$flushReact()
    record(module,'transient_path_change_has_no_navigation_error',is.null(output$nav_buttons))
    current_index(first);session$flushReact()
    session$setInputs(back_q=1);record(module,'first_boundary',current_index()==first)
    last<-tail(practice$active_indices(),1);current_index(last);session$flushReact()
    session$setInputs(next_q=1);record(module,'last_boundary',current_index()==last)
    completed_core<-practice$completed()
    path_state('preview');session$flushReact()
    record(module,'preview_count_and_no_core_credit',practice$total()==c(joint=0,conditional=5,expectation=3)[[module]] && practice$completed()==0 && is.null(result()))
    if(module!='joint') {
      counter<-counter+1L
      session$setInputs(ans=if(module=='conditional') 'Exponential' else '2',check=counter)
      record(module,'preview_answer_counts_separately',practice$completed()==1)
    } else record(module,'empty_preview_has_no_submit',is.null(prob()) && is.null(output$submit_control))
    path_state('further');session$flushReact()
    record(module,'further_separate',practice$total()==(if(module=='joint') 0 else 2) && practice$completed()==0)
    path_state('core');session$flushReact()
    record(module,'core_progress_retained',practice$completed()==completed_core && current_index()==first && is.null(result()))
    # Loading a worked table is explicit; changing a question does not replace a student's table.
    before<-pmf_final();current_index(tail(fresh,1));session$flushReact()
    record(module,'navigation_preserves_table',identical(pmf_final(),before))
    for(key in c('counts20','zero_x','cards')) {
      session$setInputs(pmf_example=key,load_pmf_example=match(key,c('counts20','zero_x','cards')))
      record(module,paste('load_table',key),max(abs(pmf_final()$p_value-learning_pmf_example(key)$p_value))<1e-12 && grepl(learning_pmf_notes[[key]],html(output$pmf_example_note),fixed=TRUE))
    }
  })
}
run_practice('joint',joint_Server);run_practice('conditional',conditional_Server);run_practice('expectation',expectation_Server)
# Every numeric field rejects invalid values; controlled names do not match unrelated prose.
for(value in c('','NaN','Inf','1/0','-0.1','not a number'))
  record('grading',paste('reject',value),!learning_field_correct(value,learning_field('x','x',.4)))
record('grading','reject_negated_model',!learning_field_correct('not Hypergeometric',learning_field('m','m','Hypergeometric','distribution')))
path_state<-reactiveVal('core')
testServer(prob_Server,args=list(course_path=function()path_state()),{
  session$setInputs(dist='bern',p_bern=.4,dist_type='discrete',dist_cont='unif',a_unif=0,b_unif=140,
    lambda=12,mean_norm=65,sd_norm=3,rate_exp=.5,shape_gam=2,rate_gam=1)
  session$flushReact()
  record('overview','core_question',practice$total()==1 && practice$prob()$key=='O01')
  inputs<-as.list(answers$O01);names(inputs)<-paste0('answer_O01_',names(inputs));inputs$check<-1
  do.call(session$setInputs,inputs)
  record('overview','CDF_endpoints_correct',practice$completed()==1)
  record('overview','continuous_not_in_core',inherits(tryCatch(continuous_key(),error=identity),'shiny.silent.error'))
  for(key in c('eggs_cloudy','eggs_sunny')) {
    ex<-examples[[key]]
    session$setInputs(dist='pois',lambda=ex$inputs$lambda)
    apply_example(key);session$flushReact()
    record('overview',paste(key,'example_point_on_plot'),ex$x %in% dist_df()$k)
    record('overview',paste(key,'CDF'),abs(dist_df()$cdf[dist_df()$k==ex$x]-ppois(ex$x,ex$inputs$lambda))<1e-12)
  }
  session$setInputs(lambda=13)
  record('overview','custom_parameter_updates_distribution',abs(dist_df()$pmf[1]-dpois(0,13))<1e-12)
  path_state('preview');session$flushReact()
  record('overview','preview_no_core_score',practice$total()==0 && practice$completed()==0)
  for(key in c('normal65','uniform140','rain')) {
    ex<-examples[[key]];values<-ex$inputs;values$dist_cont<-ex$dist
    do.call(session$setInputs,values);apply_example(key);session$flushReact()
    expected<-switch(key,normal65=pnorm(70,65,3),uniform140=5/14,rain=1-exp(-1))
    record('overview',paste(key,'CDF'),abs(pdf_cdf_at_cont(ex$x)$cdf-expected)<1e-12)
  }
  session$setInputs(dist_cont='gamma');record('overview','preview_blocks_other_models',continuous_key()!='gamma')
  path_state('further');session$flushReact();record('overview','further_all_models',continuous_key()=='gamma')
  path_state('core');session$flushReact();record('overview','CDF_progress_retained',practice$completed()==1)
})
# Inspect actual input ranges, not just the preset dictionary.
cat('Checking actual ranges\n')
ui_nodes<-xml2::read_html(as.character(prob_UI('probe')))
for(pair in list(c('lambda',24),c('mean_norm',65),c('b_unif',140))) {
  node<-xml2::xml_find_first(ui_nodes,paste0('//*[@id="probe-',pair[1],'"]'))
  record('ranges',pair[1],as.numeric(xml2::xml_attr(node,'data-max'))>=as.numeric(pair[2]))
}
# Actual app default and global counters, including a malicious/obsolete legacy input.
cat('Checking actual application\n')
previous<-getwd();setwd('Project_PPeek1ng');app<-new.env(parent=globalenv());sys.source('main.R',app);setwd(previous)
testServer(app$server,{
  record('application','default_30_core',course_path()=='core' && grepl('0 / 30',html(output$learning_progress),fixed=TRUE))
  session$setInputs('joint1-answer_J11_cell1'='.3','joint1-answer_J11_cell2'='.2','joint1-answer_J11_cell3'='.1','joint1-answer_J11_cell4'='.4','joint1-check'=1)
  record('application','real_module_updates_global_progress',grepl('1 / 30',html(output$learning_progress),fixed=TRUE))
  session$setInputs(learning_path='preview');record('application','preview_eight',grepl('0 / 8',html(output$learning_progress),fixed=TRUE))
  session$setInputs(learning_path='further');record('application','further_four',grepl('0 / 4',html(output$learning_progress),fixed=TRUE))
  session$setInputs(learning_path='legacy');record('application','legacy_not_selectable',course_path()=='core' && grepl('1 / 30',html(output$learning_progress),fixed=TRUE))
  practice_modules$conditional$current_index(4);session$flushReact();session$setInputs('cond1-explore_example'=1)
  record('application','question_to_plot_request',plot_request()$key=='eggs_cloudy' && course_path()=='core')
})
testServer(app$server,{record('application','new_session_no_progress',grepl('0 / 30',html(output$learning_progress),fixed=TRUE))})
args<-commandArgs(trailingOnly=TRUE)
report<-list(date=format(Sys.time(),'%Y-%m-%d',tz='Pacific/Auckland'),total=length(cases),passed=sum(vapply(cases,`[[`,logical(1),'passed')),
  original_answer_baseline='7852cc1',
  catalog=lapply(all_questions,function(q)list(reference=q$key,track=q$track,original=isTRUE(q$legacy),stage=q$stage,
    table_example=q$pmf_example,plot_examples=q$plot_examples)),
  graph_examples=learning_graph_examples(),cases=cases,
  source_md5=as.list(tools::md5sum(list.files('Project_PPeek1ng',pattern='[.][Rr]$',recursive=TRUE,full.names=TRUE))))
jsonlite::write_json(report,if(length(args))args[1] else 'review/evidence/content_learning_paths.json',auto_unbox=TRUE,pretty=TRUE,digits=16)
cat(report$passed,'/',report$total,'learning-path cases passed.\n')
if(report$passed!=report$total)quit(status=1)
