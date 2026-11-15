# No exam wording, tables or expected answers are embedded in this distributable test.
.libPaths(c(normalizePath('.R-library'),.libPaths()))
if(.Platform$OS.type=='windows')Sys.setlocale('LC_CTYPE','.UTF-8')
suppressPackageStartupMessages({library(shiny);library(shinyjs);library(plotly);library(dplyr);library(latex2exp)})
for(f in c('pmf_helpers.R','past_exam_bank.R','learning_content.R','learning_practice.R','module_joint.R','module_conditional.R','module_expectation.R','module_probability.R'))
  source(file.path('Project_PPeek1ng/modules',f),encoding='UTF-8')
cases<-list()
dir.create('.local/exam-selection',recursive=TRUE,showWarnings=FALSE)
record<-function(group,name,passed){cases[[length(cases)+1L]]<<-list(group=group,name=name,passed=isTRUE(passed));if(!isTRUE(passed))cat('FAIL:',group,name,'\n')}
html<-function(x)if(is.null(x))''else x$html
preview_models<-unname(learning_continuous_choices('preview'))
further_models<-unname(learning_continuous_choices('further'))
record('paths','preview_has_three_introductory_models',setequal(preview_models,c('unif','exp','norm')))
record('paths','further_has_five_additional_models',setequal(further_models,c('gamma','beta','chisq','t','f')))
record('paths','continuous_paths_do_not_overlap',length(intersect(preview_models,further_models))==0&&
  setequal(c(preview_models,further_models),unname(learning_continuous_choices('legacy'))))
record('paths','legacy_keeps_all_eight_continuous_models',length(learning_continuous_choices('legacy'))==8)
examples<-learning_graph_examples()
record('paths','examples_belong_to_their_path_models',all(vapply(examples,function(example){
  paths<-intersect(example$paths,c('core','preview','further'))
  all(vapply(paths,function(path)if(example$type=='discrete')path=='core' else
    example$dist %in% learning_continuous_choices(path),logical(1)))
},logical(1))))
record('loader','local_bank_verified',local_exam_bank$status=='verified')
stopifnot(local_exam_bank$status=='verified')
record('loader','bundled_bank_discovered_from_repository_root',
  identical(normalizePath(exam_bank_path()),normalizePath('exam-materials/bank.json')))
previous_dir<-getwd();setwd('Project_PPeek1ng')
record('loader','bundled_bank_discovered_from_application_directory',
  identical(normalizePath(exam_bank_path()),normalizePath('../exam-materials/bank.json')))
setwd(previous_dir)
portable_dir<-tempfile('relocated materials ',tmpdir='.local/exam-selection')
dir.create(portable_dir,recursive=TRUE)
raw_bank<-jsonlite::read_json('exam-materials/bank.json',simplifyVector=FALSE)
for(source_id in names(raw_bank$sources))for(kind in c('question','solution')){
  field<-paste0(kind,'_path')
  target<-file.path(portable_dir,raw_bank$sources[[source_id]][[field]])
  dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
  stopifnot(file.copy(local_exam_bank$sources[[source_id]][[field]],target))
}
portable_bank<-file.path(portable_dir,'bank.json')
stopifnot(file.copy('exam-materials/bank.json',portable_bank))
relocated<-read_local_exam_bank(portable_bank)
record('loader','relative_pdf_paths_load_after_relocation',relocated$status=='verified'&&length(relocated$questions)==4)
first_relative<-raw_bank$sources[[1]]$question_path
record('loader','resolved_pdf_uses_relocated_directory',
  identical(relocated$sources[[1]]$question_path,normalizePath(file.path(portable_dir,first_relative),winslash='/')))
override_before<-Sys.getenv('STATS125_EXAM_BANK',unset=NA_character_)
Sys.setenv(STATS125_EXAM_BANK=normalizePath(portable_bank,winslash='/'))
record('loader','explicit_bank_override_retained',identical(exam_bank_path(),Sys.getenv('STATS125_EXAM_BANK')))
if(is.na(override_before))Sys.unsetenv('STATS125_EXAM_BANK')else Sys.setenv(STATS125_EXAM_BANK=override_before)
unlink(file.path(portable_dir,first_relative))
record('loader','missing_relative_pdf_is_rejected',read_local_exam_bank(portable_bank)$status=='invalid')
all_questions<-unlist(lapply(c('overview','joint','conditional','expectation'),exam_questions),recursive=FALSE)
for (module in c('joint','conditional','expectation')) {
  choices <- learning_pmf_example_choices(module)
  keys <- unlist(lapply(exam_questions(module), `[[`, 'pmf_example'), use.names=FALSE)
  record('catalog',paste0(module,'_table_examples_are_grouped_and_scoped'),
    identical(unname(choices$Demonstrations),c('cards','counts20','zero_x'))&&setequal(unname(choices[['Past exam']]),keys))
}
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
      session$setInputs(dist='binom',n=5,p=.2)
      overview_ui<-as.character(prob_UI('overview_check'))
      record(module,'distribution_presets_and_note_removed',!grepl('plot_example|example_controls|example_note',overview_ui))
      session$setInputs(plot_example='corn10')
      record(module,'obsolete_preset_input_does_not_overwrite_parameters',input$n==5&&input$p==.2)
      record(module,'exam_load_button_retained',grepl('explore_example',html(output$example_action),fixed=TRUE))
      for(key in q$plot_examples){
        graph<-local_exam_bank$graphs[[key]];apply_example(key)
        do.call(session$setInputs,c(graph$inputs,list(dist_type=graph$type,dist=graph$dist)))
        session$flushReact()
        record(module,paste0(key,'_example_x_on_plot'),graph$x %in% dist_df()$k)
        row<-dist_df()[dist_df()$k==graph$x,]
        record(module,paste0(key,'_pmf_and_cdf'),nrow(row)==1&&abs(row$pmf-dpois(graph$x,graph$inputs$lambda))<1e-12&&abs(row$cdf-ppois(graph$x,graph$inputs$lambda))<1e-12)
      }
    }
  })
}
run_module('joint',joint_Server);run_module('conditional',conditional_Server);run_module('expectation',expectation_Server);run_module('overview',prob_Server)
# Actual application scopes cannot enable the hidden old library.
previous<-getwd();setwd('Project_PPeek1ng');app<-new.env(parent=globalenv());sys.source('main.R',app);setwd(previous)
testServer(app$server,{
  record('application','four_optional_exam_extracts',sum(vapply(practice_modules,function(x)x$total(),numeric(1)))==4)
  session$setInputs(`prob1-learning_path`='legacy');record('application','legacy_request_cannot_expose_old_questions',course_path()=='core'&&all(vapply(practice_modules,function(x)isTRUE(x$prob()$is_exam),logical(1))))
  session$setInputs(`prob1-learning_path`='preview')
  record('application','overview_preview_does_not_hide_other_modules_practice',
    practice_modules$overview$total()==0&&all(vapply(practice_modules[c('joint','conditional','expectation')],function(x)x$total()==1,logical(1))))
})
saved_bank<-local_exam_bank;local_exam_bank<-read_local_exam_bank('.local/exam-selection/missing-bank.json')
testServer(joint_Server,{
  record('privacy','missing_bank_does_not_load_old_questions',practice$total()==0&&is.null(practice$prob()))
  record('privacy','empty_bank_hides_practice',output$practice_available=='false'&&html(output$practice_status)=='')
})
local_exam_bank<-saved_bank
args<-commandArgs(trailingOnly=TRUE)
report<-list(date=format(Sys.time(),'%Y-%m-%d',tz='Pacific/Auckland'),total=length(cases),passed=sum(vapply(cases,`[[`,logical(1),'passed')),
  cases=cases,question_references=lapply(all_questions,function(q)list(reference=q$key,year=q$source$year,semester=q$source$semester,question=q$source_question,adapted=q$adapted)),
  source_md5=as.list(tools::md5sum(list.files('Project_PPeek1ng',pattern='[.][Rr]$',recursive=TRUE,full.names=TRUE))))
jsonlite::write_json(report,if(length(args))args[1]else'review/evidence/exam_bank_tests.json',auto_unbox=TRUE,pretty=TRUE)
cat(report$passed,'/',report$total,'past-exam bank checks passed.\n');if(report$passed!=report$total)quit(status=1)
