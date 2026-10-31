# Run from repository root. Optional arguments: result.json module-directory
.libPaths(c(normalizePath('.R-library'), .libPaths()))
if (.Platform$OS.type == 'windows') Sys.setlocale('LC_CTYPE', '.UTF-8')
suppressPackageStartupMessages({library(shiny); library(shinyjs); library(plotly); library(dplyr); library(latex2exp)})
args <- commandArgs(trailingOnly=TRUE)
destination <- if(length(args)) args[1] else 'review/evidence/r1_06_regression.json'
module_dir <- if(length(args)>1) args[2] else 'Project_PPeek1ng/modules'
if(file.exists(file.path(module_dir,'pmf_helpers.R'))) source(file.path(module_dir,'pmf_helpers.R'),encoding='UTF-8')
source('Project_PPeek1ng/modules/learning_content.R',encoding='UTF-8')
source('Project_PPeek1ng/modules/learning_practice.R',encoding='UTF-8')
results <- new.env(parent=emptyenv()); results$cases <- list()
record <- function(module, name, passed, detail=list()) {
  results$cases[[length(results$cases)+1L]] <- c(list(module=module, name=name, passed=isTRUE(passed)), detail)
}
read_ui <- function(value) tryCatch(if(is.null(value)) '' else value$html, error=function(e) '')
table_values <- function(html) {
  cells <- xml2::xml_find_all(xml2::read_html(html), '(//table)[1]/tbody/tr/td')
  values <- xml2::xml_text(cells)
  values <- gsub('\\\\[()]', '', values)
  values <- gsub('\\\\frac\\{([^}]+)\\}\\{([^}]+)\\}', '\\1/\\2', values)
  vapply(values, parse_user_prob, numeric(1))
}
invalid <- list(negative=c('-1','1','1','1'), tiny_negative=c('-.000001','1','1','1'),
  text=c('abc','1','1','1'), zero_denominator=c('1/0','1','1','1'),
  zero_over_zero=c('0/0','1','1','1'),
  blank=c('','1','1','1'), infinity=c('Inf','1','1','1'), nan=c('NaN','1','1','1'),
  overflow=c(paste(rep('9',400),collapse=''),'1','1','1'),
  malformed_fraction=c('1/2/','1','1','1'), all_zero=rep('0',4))
valid <- list(weights=list(p=c('1','2','3','4'), expected=c(.1,.2,.3,.4)),
  fractions=list(p=c('1/7','2/7','1/7','3/7'), expected=c(1,2,1,3)/7),
  small=list(p=c('0.000001','0.000002','0.000003','0.000004'),expected=c(.1,.2,.3,.4)),
  large=list(p=rep('1e308',4),expected=rep(.25,4)),
  duplicates=list(p=c('1','2','3','4'),x=c(0,0,1,1),y=c(0,0,0,1),expected=c(.3,.3,.4)),
  explicit_zero=list(p=c('0','1','0','3'),expected=c(0,.25,0,.75)))

for (module in c('joint','conditional','expectation')) {
  pmf_global <- reactiveValues(df_edit=NULL,df_final=NULL,counter=0,has_final=FALSE)
  source(file.path(module_dir,paste0('module_',module,'.R')),encoding='UTF-8')
  server <- get(paste0(if(module=='conditional') 'conditional' else module,'_Server'))
  testServer(server, args=list(shared=pmf_global), {
    click_count <- c(generate=0L,normalize=0L,uniform=0L,add_row=0L)
    click <- function(action) {
      click_count[action] <<- click_count[action]+1L
      do.call(session$setInputs,setNames(list(click_count[[action]]),action))
      session$flushReact()
    }
    draft <- function(probabilities, x=c(0,0,1,1), y=c(0,1,0,1)) {
      df <- data.frame(x=x,y=y,p_input=probabilities,p_value=rep(0,length(x)),
        id=row_counter()+seq_along(x),stringsAsFactors=FALSE)
      pmf_edit(df); row_counter(if(nrow(df)) max(df$id) else row_counter())
      pmf_global$df_edit <- df; pmf_global$counter <- row_counter()
      session$flushReact()
      values <- if(length(probabilities)) setNames(as.list(probabilities),paste0('p_',df$id)) else list()
      if(length(values)) do.call(session$setInputs,values)
      session$flushReact()
    }
    draft(c('1','2','3','4')); click('generate')
    last_valid <- pmf_final(); last_html <- read_ui(output$joint_table_html)
    for (name in names(invalid)) {
      for (action in c('generate','normalize')) {
        # Restore the last known-good result even when evaluating the old code.
        pmf_final(last_valid); pmf_global$df_final <- last_valid
        draft(invalid[[name]])
        click(action)
        feedback <- read_ui(output$input_feedback)
        retained <- identical(pmf_final(),last_valid) && identical(pmf_global$df_final,last_valid)
        html_same <- identical(read_ui(output$joint_table_html),last_html)
        record(module,paste(name,action,sep='_'),retained && html_same && nzchar(feedback),
          list(retained=retained,table_unchanged=html_same,message=feedback))
      }
    }
    pmf_final(last_valid); pmf_global$df_final <- last_valid
    draft(character(0),numeric(0),numeric(0))
    for(action in c('generate','normalize','uniform')) {
      click(action)
      record(module,paste0('empty_',action),identical(pmf_final(),last_valid) &&
        identical(pmf_global$df_final,last_valid) && nzchar(read_ui(output$input_feedback)))
    }
    record(module,'empty_table_recovery_controls',grepl('Add Row',read_ui(output$input_panel),fixed=TRUE))
    click('add_row')
    record(module,'add_after_empty',nrow(pmf_edit())==1L)

    for (name in names(valid)) {
      case <- valid[[name]]
      draft(case$p,if(is.null(case$x)) c(0,0,1,1) else case$x,
                    if(is.null(case$y)) c(0,1,0,1) else case$y)
      click('generate')
      actual <- pmf_final()
      probability_ok <- length(actual$p_value)==length(case$expected) &&
        all(abs(actual$p_value-case$expected)<1e-12) && abs(sum(actual$p_value)-1)<1e-12
      input_ok <- all(abs(vapply(actual$p_input,parse_user_prob,numeric(1))-actual$p_value)<1e-14)
      input_ui <- read_ui(output$input_panel)
      input_ok <- input_ok && all(vapply(actual$p_input,function(p) grepl(p,input_ui,fixed=TRUE),logical(1)))
      mat <- xtabs(p_value~x+y,actual)
      expected_table <- rbind(cbind(mat,rowSums(mat)),c(colSums(mat),1))
      displayed <- table_values(read_ui(output$joint_table_html))
      table_ok <- length(displayed)==length(expected_table) &&
        all(abs(displayed-as.vector(t(expected_table)))<1.1e-5)
      graph_ok <- TRUE
      if(module=='joint') {
        traces <- jsonlite::fromJSON(output$plot3d,simplifyVector=FALSE)$x$data
        z <- vapply(traces,function(trace) tail(unlist(trace$z),1),numeric(1))
        graph_ok <- length(z)==nrow(actual) && all(abs(z-actual$p_value)<1e-12)
      } else if(module=='conditional') {
        session$setInputs(cond_type='f(Y | X = x0)',x0='0'); session$flushReact()
        sub <- actual[actual$x==0,]; expected_cond <- sub$p_value/sum(sub$p_value)
        if(sum(sub$p_value)>0) {
          traces <- jsonlite::fromJSON(output$plot_bird_cond,simplifyVector=FALSE)$x$data
          z <- unlist(lapply(traces,function(trace)trace$y),use.names=FALSE)
          graph_ok <- length(z)==nrow(sub) && all(abs(z-expected_cond)<1e-12)
        }
      } else {
        text <- read_ui(output$expectation_results)
        graph_ok <- grepl(sprintf('%.6f',sum(actual$x*actual$p_value)),text,fixed=TRUE) &&
          grepl(sprintf('%.6f',sum(actual$y*actual$p_value)),text,fixed=TRUE)
      }
      record(module,paste0('valid_',name),probability_ok && input_ok && table_ok && graph_ok &&
        !nzchar(read_ui(output$input_feedback)),list(probability_passed=probability_ok,
        input_passed=input_ok,table_passed=table_ok,downstream_passed=graph_ok,probabilities=actual$p_value))
    }
    draft(c('1','2','3','4')); previous <- pmf_final(); click('normalize')
    normalized <- pmf_edit()
    record(module,'normalize_draft_only',all(abs(normalized$p_value-c(.1,.2,.3,.4))<1e-12) &&
      all(abs(vapply(normalized$p_input,parse_user_prob,numeric(1))-normalized$p_value)<1e-14) &&
      identical(pmf_final(),previous))
    # Generate immediately, without any new input-binding events from the client.
    click('generate')
    record(module,'generate_after_normalize',all(abs(pmf_final()$p_value-c(.1,.2,.3,.4))<1e-12))
    draft(c('abc','1','1','1')); previous <- pmf_final(); click('uniform')
    record(module,'uniform_repairs_draft',all(abs(pmf_edit()$p_value-.25)<1e-12) && identical(pmf_final(),previous))
    click('generate')
    record(module,'generate_after_uniform',all(abs(pmf_final()$p_value-.25)<1e-12))
    previous <- pmf_final(); removed_ids <- pmf_edit()$id
    for(id in removed_ids) {
      do.call(session$setInputs,setNames(list(1L),paste0('del_',id)))
      session$flushReact()
    }
    record(module,'delete_all_retains_result',nrow(pmf_edit())==0L && identical(pmf_final(),previous))
    click('add_row'); new_id <- pmf_edit()$id
    record(module,'deleted_ids_not_reused',length(new_id)==1L && new_id>max(removed_ids))
    do.call(session$setInputs,setNames(list('1'),paste0('p_',new_id)))
    click('generate')
    record(module,'regenerate_after_empty',nrow(pmf_final())==1L && pmf_final()$p_value==1)
  })
}
pmf_global <- reactiveValues(df_edit=NULL,df_final=NULL,counter=0,has_final=FALSE)
for(module in c('joint','conditional','expectation')) source(file.path(module_dir,paste0('module_',module,'.R')),encoding='UTF-8')
testServer(function(input,output,session) {
  joint_Server('j',pmf_global); conditional_Server('c',pmf_global); expectation_Server('e',pmf_global)
}, {
  check_views <- function(expected) {
    all(vapply(c('j','c','e'),function(prefix) {
      html <- read_ui(output[[paste0(prefix,'-joint_table_html')]])
      values <- table_values(html)
      # Four probabilities and their marginals in a 2x2 grid.
      mat <- matrix(expected,nrow=2,byrow=TRUE)
      target <- rbind(cbind(mat,rowSums(mat)),c(colSums(mat),1))
      length(values)==9L && all(abs(values-as.vector(t(target)))<1.1e-5)
    },logical(1)))
  }
  session$setInputs('j-p_1'='1','j-p_2'='2','j-p_3'='3','j-p_4'='4','j-generate'=1L)
  session$flushReact()
  record('integration','joint_commit_updates_three_views',check_views(c(.1,.2,.3,.4)))
  committed <- isolate(pmf_global$df_final); ids <- committed$id
  do.call(session$setInputs,c(setNames(list('-1'),paste0('c-p_',ids[1])),list('c-generate'=1L)))
  session$flushReact()
  record('integration','conditional_invalid_commit_keeps_three_views',
    identical(isolate(pmf_global$df_final),committed) && check_views(c(.1,.2,.3,.4)) &&
      nzchar(read_ui(output[['c-input_feedback']])))
  do.call(session$setInputs,c(setNames(list('abc'),paste0('e-p_',ids[1])),list('e-normalize'=1L)))
  session$flushReact()
  record('integration','expectation_invalid_normalize_keeps_three_views',
    identical(isolate(pmf_global$df_final),committed) && check_views(c(.1,.2,.3,.4)) &&
      nzchar(read_ui(output[['e-input_feedback']])))
  do.call(session$setInputs,c(setNames(rep(list('2'),4),paste0('e-p_',ids)),list('e-generate'=1L)))
  session$flushReact()
  record('integration','expectation_commit_updates_three_views',check_views(rep(.25,4)))
})
stopifnot(length(results$cases)==124L)
report <- list(issue='R1-06',date=format(Sys.time(),'%Y-%m-%d',tz='Pacific/Auckland'),
  environment=list(R=R.version.string,shiny=as.character(packageVersion('shiny'))),
  source_md5=as.list(tools::md5sum(list.files(module_dir,pattern='(module_(joint|conditional|expectation)|pmf_helpers)\\.R$',full.names=TRUE))),
  total=length(results$cases),passed=sum(vapply(results$cases,function(x)x$passed,logical(1))),cases=results$cases)
jsonlite::write_json(report,destination,auto_unbox=TRUE,pretty=TRUE,digits=16)
cat(report$passed,'/',report$total,'R1-06 module cases passed.\n')
if(report$passed!=report$total) quit(status=1)
