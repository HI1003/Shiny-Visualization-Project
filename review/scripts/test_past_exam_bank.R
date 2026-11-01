# No exam wording, tables or expected answers are embedded in this distributable test.
.libPaths(c(normalizePath('.R-library'),.libPaths()))
if(.Platform$OS.type=='windows')Sys.setlocale('LC_CTYPE','.UTF-8')
suppressPackageStartupMessages({library(shiny);library(shinyjs);library(plotly);library(dplyr);library(latex2exp)})
for(f in c('pmf_helpers.R','past_exam_bank.R','learning_content.R','learning_practice.R','module_joint.R','module_conditional.R','module_expectation.R','module_probability.R'))
  source(file.path('Project_PPeek1ng/modules',f),encoding='UTF-8')
cases<-list()
record<-function(group,name,passed){cases[[length(cases)+1L]]<<-list(group=group,name=name,passed=isTRUE(passed));if(!isTRUE(passed))cat('FAIL:',group,name,'\n')}
html<-function(x)if(is.null(x))''else x$html
record('loader','local_bank_verified',local_exam_bank$status=='verified')
stopifnot(local_exam_bank$status=='verified')
all_questions<-unlist(lapply(c('overview','joint','conditional','expectation'),exam_questions),recursive=FALSE)
record('catalog','four_verified_exam_extracts_only',length(all_questions)==4&&all(vapply(all_questions,function(q)isTRUE(q$is_exam),logical(1))))
record('catalog','unique_references',!anyDuplicated(vapply(all_questions,`[[`,character(1),'key')))
record('catalog','no_unverified_or_original_fallback',length(learning_questions(list(),'overview'))==1&&all(vapply(all_questions,function(q)!isTRUE(q$legacy),logical(1))))
for(q in all_questions) {
  record(q$key,'source_reference',q$source$course=='STATS125'&&q$source$year%in%c(2024,2025,2026)&&nzchar(q$source_question)&&length(q$source_pages)>0)
  record(q$key,'adaptation_disclosed',is.logical(q$adapted)&&nzchar(q$adaptation_note))
}
record('loader','missing_bank_is_empty',read_local_exam_bank('.local/exam-selection/missing-bank.json')$status=='missing')
invalid<-local_exam_bank;invalid$sources[[1]]$question_md5<-'invalid-fingerprint'
jsonlite::write_json(invalid,'.local/exam-selection/invalid-bank.json',auto_unbox=TRUE)
record('loader','changed_pdf_is_rejected',read_local_exam_bank('.local/exam-selection/invalid-bank.json')$status=='invalid')
writeLines('{invalid','.local/exam-selection/malformed-bank.json')
record('loader','malformed_bank_is_rejected',read_local_exam_bank('.local/exam-selection/malformed-bank.json')$status=='invalid')
run_module<-function(module,server_fn) {
  scope<-reactiveVal('core')
  testServer(server_fn,args=list(course_path=function()scope()),{
    if(module=='overview')session$setInputs(dist='bern',p_bern=.4,dist_type='discrete',lambda=5)
    session$flushReact();counter<-0L
    record(module,'one_exam_default',practice$total()==1&&isTRUE(practice$prob()$is_exam))
    q<-practice$prob();fields<-learning_answer_fields(q)
    record(module,'year_question_and_adaptation_rendered',grepl(q$source_question,html(output$question_meta),fixed=TRUE)&&grepl(as.character(q$source$year),html(output$question_meta),fixed=TRUE)&&grepl(q$adaptation_note,html(output$question_meta),fixed=TRUE))
    submit<-function(wrong=FALSE){
      values<-lapply(fields,function(field)if(field$kind=='numeric')sprintf('%.12g',field$expected)else field$expected)
      names(values)<-vapply(fields,`[[`,character(1),'input_id')
      if(wrong)values[[length(values)]]<-''
      counter<<-counter+1L;values$check<-counter;do.call(session$setInputs,values)
      identical(practice$result()$status,'ok')
    }
    record(module,'all_entries_accept_reference',submit())
    record(module,'progress_counts_once',practice$completed()==1&&submit()&&practice$completed()==1)
    record(module,'missing_entry_rejected',!submit(TRUE))
    practice$tries(0)
    for(level in 1:3){submit(TRUE);record(module,paste0('feedback_',level),grepl(as.character(q[[c('hint1','hint2','solution')[level]]]),html(output$feedback),fixed=TRUE))}
    scope('preview');session$flushReact();record(module,'no_preview_fallback',practice$total()==0&&is.null(practice$prob()))
    scope('further');session$flushReact();record(module,'no_further_fallback',practice$total()==0&&is.null(practice$prob()))
    scope('core');session$flushReact();record(module,'return_retains_optional_progress',practice$completed()==1&&is.null(practice$result()))
    session$setInputs(back_q=1,next_q=1)
    record(module,'single_question_boundaries',practice$prob()$key==q$key)
    if(module!='overview'){
      session$setInputs(explore_example=1)
      record(module,'load_exact_exam_table',max(abs(pmf_final()$p_value-learning_pmf_example(q$pmf_example)$p_value))<1e-12)
      record(module,'exam_caption',grepl(learning_pmf_notes[[q$pmf_example]],html(output$pmf_example_note),fixed=TRUE))
    }else{
      for(key in q$plot_examples){
        graph<-local_exam_bank$graphs[[key]];apply_example(key)
        do.call(session$setInputs,c(graph$inputs,list(dist_type=graph$type,dist=graph$dist)))
        session$flushReact()
        record(module,paste0(key,'_selected_value'),identical(as.numeric(selected_k()),as.numeric(graph$x)))
        record(module,paste0(key,'_caption'),grepl(graph$note,html(output$example_note),fixed=TRUE))
        row<-dist_df()[dist_df()$k==graph$x,]
        record(module,paste0(key,'_pmf_and_cdf'),nrow(row)==1&&abs(row$pmf-dpois(graph$x,graph$inputs$lambda))<1e-12&&abs(row$cdf-ppois(graph$x,graph$inputs$lambda))<1e-12)
      }
    }
  })
}
run_module('joint',joint_Server);run_module('conditional',conditional_Server);run_module('expectation',expectation_Server);run_module('overview',prob_Server)
# Actual application scopes and global progress cannot enable the hidden old library.
previous<-getwd();setwd('Project_PPeek1ng');app<-new.env(parent=globalenv());sys.source('main.R',app);setwd(previous)
testServer(app$server,{
  record('application','four_optional_exam_extracts',grepl('0 / 4',html(output$learning_progress),fixed=TRUE))
  session$setInputs(learning_path='legacy');record('application','legacy_request_cannot_expose_old_questions',course_path()=='core'&&all(vapply(practice_modules,function(x)isTRUE(x$prob()$is_exam),logical(1))))
  session$setInputs(learning_path='preview');record('application','no_original_preview',grepl('0 / 0',html(output$learning_progress),fixed=TRUE))
})
saved_bank<-local_exam_bank;local_exam_bank<-read_local_exam_bank('.local/exam-selection/missing-bank.json')
testServer(joint_Server,{
  record('privacy','missing_bank_does_not_load_old_questions',practice$total()==0&&is.null(practice$prob()))
  record('privacy','empty_bank_explains_availability',grepl('No verified past-exam extract',html(output$practice_status),fixed=TRUE))
})
local_exam_bank<-saved_bank
args<-commandArgs(trailingOnly=TRUE)
report<-list(date=format(Sys.time(),'%Y-%m-%d',tz='Pacific/Auckland'),total=length(cases),passed=sum(vapply(cases,`[[`,logical(1),'passed')),
  cases=cases,question_references=lapply(all_questions,function(q)list(reference=q$key,year=q$source$year,semester=q$source$semester,question=q$source_question,adapted=q$adapted)),
  source_md5=as.list(tools::md5sum(list.files('Project_PPeek1ng',pattern='[.][Rr]$',recursive=TRUE,full.names=TRUE))))
jsonlite::write_json(report,if(length(args))args[1]else'review/evidence/exam_bank_tests.json',auto_unbox=TRUE,pretty=TRUE)
cat(report$passed,'/',report$total,'past-exam bank checks passed.\n');if(report$passed!=report$total)quit(status=1)
