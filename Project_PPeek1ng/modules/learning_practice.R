# Shared practice rendering, grading, and path-specific progress.
learning_section <- function(ns,key,title,...,class="") {
  shiny::tags$section(id=ns(key),class=paste("learning-card",class),tabindex="-1",
    shiny::tags$h3(class="learning-card-title",title),
    shiny::tags$div(class="learning-card-body",...))
}
learning_module_header <- function(ns,title,description,sections) {
  shiny::tagList(shiny::tags$header(class="learning-module-heading",shiny::tags$h2(title),shiny::tags$p(description)),
    shiny::tags$nav(class="learning-section-nav",`aria-label`=paste(title,"sections"),
      lapply(seq_along(sections),function(i) shiny::tags$a(href=paste0("#",ns(sections[[i]])),
        `data-learning-jump`=ns(sections[[i]]),class=if(i==1) "btn btn-primary" else "btn btn-outline-primary",names(sections)[i]))))
}
learning_optional_practice <- function(ns,title,...) {
  shiny::tags$details(id=ns("practice"),class="learning-card learning-practice learning-optional-practice",tabindex="-1",
    shiny::tags$summary(title),shiny::tags$div(class="learning-card-body",
      shiny::tags$p(class="small-note","Optional past-exam extracts. Each available question identifies its year, semester, question number and any adaptation. Use the reference answer to check written reasoning; input checks do not assess explanations."),...))
}
learning_concept_summary <- function(title) {
  content<-switch(title,
    "Joint Distribution"=list(
      c("A joint PMF gives the probability of a pair of outcomes; all cells are non-negative and together sum to 1.",
        "Find a marginal by adding over the other variable. In the interactive table, X labels rows and Y labels columns.",
        "Independence requires each joint probability to equal the product of its marginals; one unequal pair disproves it."),
      "Choose the 20-observation worked example. Read one joint cell, then compare its row and column totals."),
    "Conditional Distribution"=list(
      c("Conditioning restricts attention to the outcomes satisfying the given event, then rescales their probabilities to sum to 1.",
        "Divide a joint probability by the marginal probability of the condition. Reversing the condition usually changes that denominator.",
        "A conditional PMF is undefined here when the conditioning probability is zero."),
      "Keep the joint table fixed and switch the conditional direction. Compare the selected slice with its original row or column."),
    "Expectation"=list(
      c("An expectation is a probability-weighted average of outcomes. For E[g(X)], transform each outcome before averaging.",
        "A conditional mean averages within the specified condition; E[Y | X=x] is a number for a fixed x.",
        "The law of total expectation recovers E[Y] by weighting those conditional means by P(X=x)."),
      "Choose the 20-observation worked example. Compare the two conditional means with the overall mean, using the X marginal as weights."))
  shiny::tagList(shiny::tags$ul(lapply(content[[1]],shiny::tags$li)),shiny::tags$p(class="learning-observe",shiny::tags$strong("What to explore: "),content[[2]]))
}
learning_table_module_ui <- function(id,title,theory,plot_ids=NULL) {
  ns<-shiny::NS(id)
  sections<-c("Review key ideas"="theory","Explore tables & plots"="explorer","Past-exam questions (optional)"="practice")
  shiny::tags$div(class="learning-module",
    learning_module_header(ns,title,"Review the key ideas, then use the table and visualizations to understand how they work. Self-checks are optional.",sections),
    learning_section(ns,"theory","1. Review the key ideas",learning_concept_summary(title),
      shiny::tags$details(class="learning-more-theory",shiny::tags$summary("Definitions and formulas"),
        shiny::tags$div(class="math-scroll",theory)),class="learning-theory"),
    shiny::tags$div(id=ns("explorer"),class=if(is.null(plot_ids)) "learning-exploration" else "learning-exploration learning-exploration-pair",tabindex="-1",
      learning_section(ns,"workbench","Interactive probability table",
        shiny::uiOutput(ns("pmf_example_note")),
        shiny::tags$div(class="math-scroll",shiny::withMathJax(shiny::uiOutput(ns("joint_table_html")))),
        shiny::tags$details(class="learning-editor",open=NA,
          shiny::tags$summary("Edit table / choose a worked example"),shiny::uiOutput(ns("input_panel"))),class="learning-workbench"),
      if(!is.null(plot_ids)) learning_section(ns,"plots","2. Explore the distribution",
      shiny::tags$h4("2D view"),plotly::plotlyOutput(ns(plot_ids[[1]]),height="320px"),
      shiny::tags$details(class="learning-3d",shiny::tags$summary("3D visualization (optional)"),
        plotly::plotlyOutput(ns(plot_ids[[2]]),height="380px")))),
    learning_optional_practice(ns,paste0("3. Optional past-exam questions — ",title),learning_practice_ui(ns,NULL)))
}
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
      "No verified past-exam extract is available in this section for the selected scope. Visual exploration is available without answering questions."))
    shiny::tags$div(class="practice-progress",role="status",
      paste0(learning_path_label(path()),": ",completed()," / ",total()," answered correctly."),
      if(completed()==total()) shiny::tags$p("All self-checks in this section have been answered correctly. You can revisit them; each scope has separate optional practice progress."))
  })
  output$question_meta<-shiny::renderUI({
    q<-prob();if(is.null(q)) return(NULL)
    position<-match(current_index(),active_indices())
    stage<-switch(q$stage,foundation="Discrete foundations: STATS125 Chapter 5",joint="Joint tables: STATS125 Chapter 7",
                  conditional="First study joint/conditional PMFs; conditional means build on STATS125 Chapter 8")
    shiny::tagList(shiny::tags$p(class="question-path",paste0("Exercise ",position," of ",total()," | Reference ",q$key," | ",learning_path_label(q$track))),
      if(isTRUE(q$is_exam)) shiny::tags$div(class="learning-exam-source",
        shiny::tags$strong(paste(q$source$course,q$source$year,q$source$semester,q$source_question,sep=" | ")),
        shiny::tags$p(paste0(if(isTRUE(q$adapted)) "Adapted presentation. " else "Original extract; formatting only. ",q$adaptation_note)),
        shiny::tags$p(paste0("Question source: ",q$source$question_file,"; page(s) ",paste(unlist(q$source_pages),collapse=", "),
          ". Reference solution: ",q$source$solution_file,"; page(s) ",paste(unlist(q$solution_pages),collapse=", "),".")))
      else shiny::tags$p(class="small-note","Historical project question used only by internal regression checks."),
      shiny::tags$p(class="small-note",if(q$track=="core") stage else "Optional self-check: the concepts and formulas are provided, and practice progress is recorded separately."),
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
      shiny::helpText("Use the reference table in this question. The button replaces the interactive probability table with this worked example."),
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
