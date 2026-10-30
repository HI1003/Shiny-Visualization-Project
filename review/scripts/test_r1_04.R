# Rscript --vanilla review/scripts/test_r1_04.R [report.json] [module.R] [bank.json]
.libPaths(c(normalizePath('.R-library'),.libPaths()))
if(.Platform$OS.type=='windows') Sys.setlocale('LC_CTYPE','.UTF-8')
suppressPackageStartupMessages({library(shiny);library(shinyjs);library(plotly);library(dplyr);library(latex2exp)})
args<-commandArgs(trailingOnly=TRUE)
destination<-if(length(args)) args[1] else 'review/evidence/r1_04_ui.json'
module_file<-if(length(args)>1) args[2] else 'Project_PPeek1ng/modules/module_joint.R'
bank_file<-if(length(args)>2) args[3] else '.local/r1_04_bank.json'
pmf_global<-reactiveValues(df_edit=NULL,df_final=NULL,counter=0,has_final=FALSE)
source('Project_PPeek1ng/modules/pmf_helpers.R',encoding='UTF-8')
source(module_file,encoding='UTF-8')
results<-new.env(); results$cases<-list()
record<-function(id,name,passed) {
  results$cases[[length(results$cases)+1L]]<-list(question=id,name=name,passed=isTRUE(passed))
}
expected<-c('1/8','1/20','7/18','7/24','1/2','5/12','1/24','0','1/18','1/9')
testServer(joint_Server,{
  results$bank<-lapply(question_bank,function(q) lapply(q,function(value) if(inherits(value,'html')) as.character(value) else value))
  session$setInputs(back_q=1L)
  record(1,'first_page_boundary',current_index()==1L)
  check_count<-0L
  submit<-function(answer) {
    check_count<<-check_count+1L
    session$setInputs(ans=answer,check=check_count)
    session$flushReact()
  }
  for(i in seq_len(10)) {
    q<-prob()
    record(i,'current_table_and_prompt',q$id==i &&
      grepl(as.character(q$table_ui),output$table_out$html,fixed=TRUE) &&
      grepl(as.character(q$question),output$qtext$html,fixed=TRUE))
    submit('-1')
    record(i,'first_wrong_hint',result()$status=='no' && tries()==1 &&
      grepl('alert-warning',output$feedback$html,fixed=TRUE) &&
      grepl(as.character(q$hint1),output$feedback$html,fixed=TRUE))
    submit('-1')
    record(i,'second_wrong_hint',result()$status=='no' && tries()==2 &&
      grepl(as.character(q$hint2),output$feedback$html,fixed=TRUE))
    submit('-1')
    record(i,'third_wrong_solution',result()$status=='no' &&
      grepl('alert-info',output$feedback$html,fixed=TRUE) &&
      grepl(as.character(q$solution),output$feedback$html,fixed=TRUE))
    submit(expected[i])
    record(i,'correct_exact_answer',result()$status=='ok' &&
      grepl('alert-success',output$feedback$html,fixed=TRUE) &&
      grepl(as.character(q$solution),output$feedback$html,fixed=TRUE))
    number<-parse_user_prob(expected[i])
    submit(sprintf('%.5f',number))
    record(i,'correct_five_decimal_answer',result()$status=='ok')
    submit(sprintf('%.5f',number+.01))
    record(i,'wrong_numeric_answer',result()$status=='no')
    submit('abc')
    record(i,'text_rejected',result()$status=='no')
    submit('')
    record(i,'blank_rejected',result()$status=='no')
    if(i==8) {
      submit('-0.000001')
      record(i,'negative_near_zero_rejected',result()$status=='no')
    }
    if(i<10) {
      session$setInputs(next_q=i); session$flushReact()
      record(i,'next_page_resets_feedback',current_index()==i+1L && is.null(result()) && tries()==0L)
    } else record(i,'last_page_boundary',!grepl('next_q',output$nav_buttons$html,fixed=TRUE))
  }
})
stopifnot(length(results$cases)==102L)
jsonlite::write_json(results$bank,bank_file,auto_unbox=TRUE,pretty=TRUE,digits=16,na='null')
report<-list(issue='R1-04',date='2026-10-30',source_md5=unname(tools::md5sum(module_file)),
  total=length(results$cases),passed=sum(vapply(results$cases,function(x)x$passed,logical(1))),cases=results$cases)
jsonlite::write_json(report,destination,auto_unbox=TRUE,pretty=TRUE,digits=16)
cat(report$passed,'/',report$total,'question UI cases passed.\n')
if(report$passed!=report$total) quit(status=1)
