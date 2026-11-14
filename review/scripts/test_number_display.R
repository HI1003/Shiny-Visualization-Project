# Display rounding must never become an unrequested edit of the stored PMF.
.libPaths(c(normalizePath('.R-library'),.libPaths()))
if(.Platform$OS.type=='windows')Sys.setlocale('LC_CTYPE','.UTF-8')
suppressPackageStartupMessages({library(shiny);library(shinyjs);library(plotly);library(dplyr);library(latex2exp)})
for(f in c('pmf_helpers.R','past_exam_bank.R','learning_content.R','learning_practice.R','module_joint.R','module_conditional.R','module_expectation.R','module_probability.R'))source(file.path('Project_PPeek1ng/modules',f),encoding='UTF-8')
cases<-list()
record<-function(group,name,passed){cases[[length(cases)+1L]]<<-list(group=group,name=name,passed=isTRUE(passed));if(!isTRUE(passed))cat('FAIL:',group,name,'\n')}
html<-function(x)if(is.null(x))''else x$html
for(pair in list(list(.2,'0.2'),list(1/3,'1/3'),list(1/6,'1/6'),list(16/221,'16/221'),list(.123456789,'0.1235'),list(0,'0'),list(1,'1'))){
  record('format',paste0('auto_',pair[[2]]),number_label(pair[[1]])==pair[[2]])
}
record('format','fraction_mode',number_label(.25,'fraction')=='1/4')
record('format','decimal_mode',number_label(1/3,'decimal')=='0.3333')
record('format','hover_uses_only_four_decimals',identical(number_hover(c(188/221,1/3,.123456789)),c('0.8507','0.3333','0.1235')))
record('format','approximate_decimal_not_invented_fraction',number_label(.333333333333)=='0.3333')
record('format','rounded_value_has_approximation_mark',grepl('approx',as.character(number_cell(.123456789)),fixed=TRUE))
record('format','exact_value_not_marked_approximate',!grepl('approx',as.character(number_cell(.25)),fixed=TRUE))
for(value in c(1e-8,1e-14,1e-100,-1e-8))record('format',paste0('small_',format(value)),parse_user_prob(number_label(value))!=0&&number_same(parse_user_prob(number_label(value)),value))
record('format','near_one_is_not_exact_one',grepl('approx',as.character(number_cell(1-1e-9)),fixed=TRUE))
record('format','large_weights_remain_compact',nchar(pmf_editor_value('1e308'))<12)
record('format','rounding_boundaries_stay_positive',all(vapply(number_decimal(c(5e-5,5e-7,5e-9)),parse_user_prob,numeric(1))>0))
for(module in c('joint','conditional','expectation')){
  state<-new_pmf_state();server_fn<-get(paste0(module,'_Server'))
  testServer(server_fn,args=list(shared=state),{
    session$flushReact()
    session$setInputs(pmf_example='counts20')
    record(module,'example_selection_loads_table_automatically',max(abs(pmf_final()$p_value-c(.3,.2,.1,.4)))<2e-15)
    session$setInputs(pmf_example='cards')
    probabilities<-c(1/3,1/7,1/11,1-1/3-1/7-1/11)
    frame<-data.frame(x=c(0,0,1,1),y=c(0,1,0,1),p_input=number_full(probabilities),p_value=probabilities,id=row_counter()+1:4)
    pmf_edit(frame);row_counter(max(frame$id));state$df_edit<-frame;state$counter<-row_counter();session$flushReact()
    count<-0L
    bind_visible<-function(){
      frame<-pmf_edit();values<-as.list(pmf_editor_value(frame$p_input));names(values)<-paste0('p_',frame$id)
      do.call(session$setInputs,values);session$flushReact()
    }
    bind_visible()
    record(module,'display_bindings_keep_exact_source',identical(df_current()$p_input,frame$p_input))
    record(module,'editor_is_compact',all(nchar(pmf_editor_value(pmf_edit()$p_input))<=12))
    for(i in 1:8){bind_visible();count<-count+1L;session$setInputs(generate=count)}
    record(module,'eight_repeated_generates_keep_precision',max(abs(pmf_final()$p_value-probabilities))<2e-15)
    baseline<-pmf_final();before_ids<-pmf_edit()$id
    for(mode in c('decimal','fraction','auto')){
      state$number_format<-mode;session$flushReact()
      cells<-xml2::xml_find_all(xml2::read_html(html(output$joint_table_html)),'//td[@data-number-value]')
      values<-as.numeric(xml2::xml_attr(cells,'data-number-value'))
      labels<-xml2::xml_attr(cells,'data-number-text')
      expected_mode<-if(module=='joint'&&mode=='auto')'fraction'else mode
      record(module,paste0(mode,'_table_uses_requested_format'),identical(unname(labels),number_label(values,expected_mode)))
      record(module,paste0(mode,'_format_does_not_change_data'),identical(pmf_final(),baseline)&&identical(pmf_edit()$id,before_ids))
      record(module,paste0(mode,'_no_high_precision_tooltips'),all(is.na(xml2::xml_attr(cells,'title'))))
      if(module=='expectation') {
        weighted<-weighted_mean_data()
        rows<-xml2::xml_find_all(xml2::read_html(html(output$total_expectation_breakdown)),'//tbody/tr')
        rows<-rows[weighted$groups$weight>0]
        flow<-xml2::read_html(html(output$total_expectation_flow))
        products<-xml2::xml_find_all(flow,'//*[contains(@class,"expectation-flow-product")]')
        matching<-length(products)==length(rows)&&all(vapply(seq_along(products),function(i) {
          labels<-xml2::xml_attr(xml2::xml_find_all(rows[[i]],'td[@data-number-text]'),'data-number-text')
          flow_labels<-xml2::xml_attr(xml2::xml_find_all(products[[i]],'.//*[@data-number-text]'),'data-number-text')
          identical(flow_labels,labels)
        },logical(1)))
        record(module,paste0(mode,'_flow_uses_table_labels'),matching)
      }
    }
    first<-pmf_edit()$id[1];do.call(session$setInputs,setNames(list('0.3'),paste0('p_',first)))
    record(module,'real_edit_is_recognised',df_current()$p_value[1]==.3)
    session$setInputs(generate=count+1L);expected<-probabilities;expected[1]<-.3;expected<-expected/sum(expected)
    record(module,'real_edit_is_committed',max(abs(pmf_final()$p_value-expected))<2e-15)
    bind_visible();draft_before<-pmf_edit();result_before<-pmf_final();session$setInputs(normalize=1)
    record(module,'normalise_retains_committed_result',identical(pmf_final(),result_before))
    bind_visible();session$setInputs(generate=count+2L)
    record(module,'generate_after_normalise_preserves_precision',max(abs(pmf_final()$p_value-expected))<2e-15)
    first<-pmf_edit()$id[1];do.call(session$setInputs,setNames(list('-1e-14'),paste0('p_',first)));session$setInputs(generate=count+3L)
    record(module,'negative_edit_rejected_without_rounding_to_zero',max(abs(pmf_final()$p_value-expected))<2e-15&&grepl('non-negative',html(output$input_feedback),fixed=TRUE))
  })
}
# The application always uses auto; the removed control cannot change it.
previous<-getwd();setwd('Project_PPeek1ng');app<-new.env(parent=globalenv());sys.source('main.R',app);setwd(previous)
testServer(app$server,{
  record('application','automatic_display_is_default',shared$number_format=='auto')
  session$setInputs(number_format='fraction')
  record('application','removed_setting_cannot_override_auto',shared$number_format=='auto')
})
args<-commandArgs(trailingOnly=TRUE)
report<-list(date=format(Sys.time(),'%Y-%m-%d',tz='Pacific/Auckland'),total=length(cases),passed=sum(vapply(cases,`[[`,logical(1),'passed')),cases=cases,
  source_md5=as.list(tools::md5sum(list.files('Project_PPeek1ng',pattern='[.][Rr]$',recursive=TRUE,full.names=TRUE))))
jsonlite::write_json(report,if(length(args))args[1]else'review/evidence/numbers_precision.json',auto_unbox=TRUE,pretty=TRUE)
cat(report$passed,'/',report$total,'number-display checks passed.\n');if(report$passed!=report$total)quit(status=1)
