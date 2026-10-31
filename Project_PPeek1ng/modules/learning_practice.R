# Shared practice rendering, grading, and path-specific progress.
learning_practice_ui <- function(ns,title="Practice") {
  shiny::tagList(
    if(!is.null(title)) shiny::tags$h4(title),shiny::uiOutput(ns("practice_status")),shiny::uiOutput(ns("question_meta")),
    shiny::withMathJax(
      shiny::uiOutput(ns("story_out")),shiny::uiOutput(ns("table_out")),
      shiny::uiOutput(ns("given_out")),shiny::uiOutput(ns("qtext")),
      shiny::uiOutput(ns("example_action")),shiny::uiOutput(ns("answer_input")),
      shiny::uiOutput(ns("submit_control")),shiny::uiOutput(ns("feedback")),shiny::uiOutput(ns("nav_buttons"))))
}
learning_answer_fields <- function(q) {
  if(!is.null(q$fields)) return(lapply(q$fields,function(field) {
    field$input_id<-paste0("answer_",q$key,"_",field$key);field
  }))
  if(!is.null(q$ans_pair)) return(list(
    c(learning_field("sunny","Sunny: E[Y | W = Sunny]",q$ans_pair[["sunny"]]),list(input_id="ans_sunny")),
    c(learning_field("cloudy","Cloudy: E[Y | W = Cloudy]",q$ans_pair[["cloudy"]]),list(input_id="ans_cloudy"))))
  named<-all(is.na(q$ans_val)) && !is.null(q$ans_text) && !is.na(q$ans_text)
  list(c(learning_field("answer",NULL,if(named) q$ans_text else if(all(is.na(q$ans_val))) parse_user_prob(q$ans_frac) else q$ans_val,
    if(named) "distribution" else "numeric",nonnegative=startsWith(q$key,"J")),list(input_id="ans")))
}
learning_field_correct <- function(value,field,tolerance=1e-4) {
  if(field$kind=="choice") return(is.character(value) && length(value)==1L && identical(value,field$expected))
  if(field$kind=="distribution") return(distribution_answer_matches(value,field$expected))
  parsed<-parse_user_prob(value)
  if(!is.finite(parsed) || (isTRUE(field$nonnegative) && parsed<0)) return(FALSE)
  is_correct(value,field$expected,tol=tolerance)
}
learning_practice_server <- function(input,output,session,questions,module,course_path,
                                     load_pmf=NULL,open_plot=NULL) {
  ns<-session$ns
  path<-shiny::reactive(learning_path(course_path()))
  active_indices<-shiny::reactive(learning_indices(questions,module,path()))
  initial<-shiny::isolate(active_indices())
  current_index<-shiny::reactiveVal(if(length(initial)) initial[1] else NA_integer_)
  result<-shiny::reactiveVal(NULL);tries<-shiny::reactiveVal(0L)
  solved<-shiny::reactiveVal(character(0))
  prob<-shiny::reactive({
    indices<-active_indices();idx<-current_index()
    if(!length(indices) || is.na(idx) || !idx %in% indices) return(NULL)
    questions[[idx]]
  })
  reset_feedback<-function() {result(NULL);tries(0L)}
  shiny::observeEvent(path(), {
    indices<-active_indices();current_index(if(length(indices)) indices[1] else NA_integer_)
    reset_feedback()
  },ignoreInit=TRUE)
  shiny::observeEvent(current_index(),reset_feedback(),ignoreInit=TRUE)
  completed<-shiny::reactive({
    keys<-vapply(questions[active_indices()],`[[`,character(1),"key")
    sum(keys %in% solved())
  })
  total<-shiny::reactive(length(active_indices()))
  output$practice_status<-shiny::renderUI({
    if(!total()) return(shiny::tags$div(class="alert alert-info",
      if(path()=="core") "No core questions in this section." else
      "This section has no questions in the selected path. STATS125 joint-table practice is available in STATS125 Core; optional preview questions are in Conditional and Expectation."))
    shiny::tags$div(class="practice-progress",role="status",
      paste0(learning_path_label(path()),": ",completed()," / ",total()," answered correctly."),
      if(completed()==total()) shiny::tags$p("This section is complete. You can revisit any question; optional paths have separate progress."))
  })
  output$question_meta<-shiny::renderUI({
    q<-prob();if(is.null(q)) return(NULL)
    position<-match(current_index(),active_indices())
    stage<-switch(q$stage,foundation="Discrete foundations: STATS125 Chapter 5",joint="Joint tables: STATS125 Chapter 7",
                  conditional="First study joint/conditional PMFs; conditional means build on STATS125 Chapter 8")
    shiny::tagList(shiny::tags$p(class="question-path",paste0("Exercise ",position," of ",total()," | Reference ",q$key," | ",learning_path_label(q$track))),
      shiny::tags$p(class="small-note",if(q$track=="core") stage else "Optional: the concepts and formulas are provided. This question does not count towards STATS125 Core completion."),
      if(!isTRUE(q$legacy)) shiny::tags$h4(q$title))
  })
  output$story_out<-shiny::renderUI({
    q<-prob();if(is.null(q)||module=="joint") return(NULL)
    shiny::withMathJax(shiny::HTML(q$story))
  })
  output$table_out<-shiny::renderUI({
    q<-prob();if(is.null(q)||module!="joint") return(NULL)
    shiny::HTML(q$table_ui)
  })
  output$given_out<-shiny::renderUI({q<-prob();if(is.null(q)||is.null(q$given)) return(NULL);shiny::HTML(q$given)})
  output$qtext<-shiny::renderUI({q<-prob();if(is.null(q)) return(NULL);shiny::withMathJax(shiny::tags$div(class="practice-question",shiny::HTML(q$question)))})
  output$example_action<-shiny::renderUI({
    q<-prob();if(is.null(q)) return(NULL)
    if(!is.null(q$pmf_example) && !is.null(load_pmf)) return(shiny::tagList(
      shiny::helpText("Use the table in this question. The button replaces the table above with this worked example."),
      shiny::actionButton(ns("explore_example"),"Load this example into the tables and plots",class="btn-outline-primary")))
    if(!is.null(q$plot_examples) && !is.null(open_plot)) {
      examples<-learning_graph_examples();keys<-q$plot_examples
      choices<-stats::setNames(keys,vapply(examples[keys],`[[`,character(1),"label"))
      return(shiny::tagList(shiny::helpText("This exercise uses its stated model. Load it before comparing with the plots; changing plot parameters does not change the question or its answer."),
        if(length(keys)>1) shiny::selectInput(ns(paste0("plot_choice_",q$key)),"Scenario to explore",choices),
        shiny::actionButton(ns("explore_example"),"Open this example in Overview",class="btn-outline-primary")))
    }
    NULL
  })
  shiny::observeEvent(input$explore_example, {
    q<-prob();shiny::req(q)
    if(!is.null(q$pmf_example) && !is.null(load_pmf)) load_pmf(q$pmf_example)
    else if(!is.null(q$plot_examples) && !is.null(open_plot)) {
      choice<-input[[paste0("plot_choice_",q$key)]]
      if(is.null(choice) || !choice %in% q$plot_examples) choice<-q$plot_examples[1]
      open_plot(choice)
    }
  })
  output$answer_input<-shiny::renderUI({
    q<-prob();if(is.null(q)) return(NULL)
    fields<-learning_answer_fields(q)
    controls<-lapply(fields,function(field) {
      control<-if(field$kind=="choice") shiny::selectInput(ns(field$input_id),field$label,field$choices,selected="",width="100%")
      else shiny::textInput(ns(field$input_id),field$label,
        placeholder=if(field$kind=="distribution") "Distribution name only; parameters are not required in this field" else "Enter a decimal or fraction (e.g. 3/5)",width="100%")
      if(length(fields)>1) shiny::column(6,control) else control
    })
    if(length(fields)>1) shiny::fluidRow(controls) else shiny::tagList(controls)
  })
  output$submit_control<-shiny::renderUI({if(is.null(prob())) return(NULL)
    shiny::actionButton(ns("check"),"Submit",class="btn btn-success btn-block")})
  shiny::observeEvent(input$check, {
    q<-prob();shiny::req(q)
    fields<-learning_answer_fields(q);tolerance<-if(is.null(q$tolerance)) 1e-4 else q$tolerance
    checks<-vapply(fields,function(field) learning_field_correct(input[[field$input_id]],field,tolerance),logical(1))
    ok<-all(checks);detail<-NULL
    if(!ok && length(fields)>1) {
      if(!is.null(q$ans_pair)) {
        names<-c("Sunny","Cloudy")[!checks]
        detail<-paste0("Check the ",paste(names,collapse=" and ")," answer",if(length(names)>1) "s" else "",
                       ". Both conditions must be answered correctly.")
      } else detail<-paste0("Check: ",paste(vapply(fields[!checks],`[[`,character(1),"label"),collapse="; "),". Every field must be correct.")
    }
    result(list(status=if(ok) "ok" else "no",detail=detail))
    tries(tries()+if(ok) 3L else 1L)
    if(ok) solved(union(solved(),q$key))
  })
  output$feedback<-shiny::renderUI({
    st<-result();q<-prob();if(is.null(st)||is.null(q)) return(NULL)
    text<-if(st$status=="ok" || tries()>=3) q$solution else if(tries()==1) q$hint1 else q$hint2
    klass<-if(st$status=="ok") "alert-success" else if(tries()>=3) "alert-info" else "alert-warning"
    shiny::withMathJax(shiny::tags$div(id=ns("fb_mjx"),if(!is.null(st$detail)) shiny::tags$p(st$detail),
      shiny::tags$div(class=paste("alert",klass),shiny::HTML(text))))
  })
  output$nav_buttons<-shiny::renderUI({
    indices<-active_indices();if(!length(indices)) return(NULL)
    at<-match(current_index(),indices)
    if(is.na(at)) return(NULL)
    shiny::fluidRow(
      if(at>1) shiny::column(6,shiny::actionButton(ns("back_q"),"\u2190 Back",class="btn btn-secondary btn-block")),
      if(at<length(indices)) shiny::column(6,shiny::actionButton(ns("next_q"),"Next \u2192",class="btn btn-primary btn-block")))
  })
  move<-function(delta) {
    indices<-active_indices();at<-match(current_index(),indices)
    if(!is.na(at) && at+delta>=1 && at+delta<=length(indices)) {current_index(indices[at+delta]);reset_feedback()}
  }
  shiny::observeEvent(input$back_q,move(-1L))
  shiny::observeEvent(input$next_q,move(1L))
  list(current_index=current_index,prob=prob,result=result,tries=tries,solved=solved,
       active_indices=active_indices,completed=completed,total=total,questions=questions)
}
