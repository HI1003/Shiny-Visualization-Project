# ============================================================
# Module: Probability Distribution UI
# ============================================================

# ---- Load Required Packages ----
library(shiny)
library(ggplot2)
library(latex2exp)

# ---- UI Module Definition ----
prob_UI <- function(id) {
  ns<-NS(id)
  tagList(
    div(class="learning-module",
      learning_module_header(ns,"Probability Distributions",
        "Review the key ideas, then change parameters and read the plots. Self-check questions are optional.",
        c("Review key ideas"="theory","Explore plots & parameters"="explorer","Past-exam questions (optional)"="practice")),
      uiOutput(ns("path_description")),
      learning_section(ns,"theory","1. Review the key ideas",
        uiOutput(ns("concept_review")),
        conditionalPanel(condition=paste0("input['",ns("dist_type"),"'] == 'discrete'"),
          uiOutput(ns("dist_desc")),tags$details(class="learning-more-theory",tags$summary("Model formulas"),withMathJax(uiOutput(ns("formula"))))),
        conditionalPanel(condition=paste0("input['",ns("dist_type"),"'] == 'continuous'"),
          uiOutput(ns("dist_desc_cont")),
          tags$details(class="learning-more-theory",tags$summary("Optional mathematical formulas"),
            withMathJax(HTML("For a continuous model: \\(F(x)=\\int_{-\\infty}^x f(t)dt\\) and \\(f(x)=F'(x)\\) where differentiable.")),
            withMathJax(uiOutput(ns("formula_cont"))))),class="learning-theory"),
      div(id=ns("explorer"),class="learning-overview-explorer",tabindex="-1",
        learning_section(ns,"controls","Model and parameters",
          radioButtons(ns("dist_type"),"Distributions in this learning path",c("Discrete"="discrete","Continuous"="continuous"),selected="discrete",inline=TRUE),
          selectInput(ns("plot_example"),"Visualization example",choices=c("CDF illustration: Bernoulli(p=0.4)"="bern04")),
          actionButton(ns("load_plot_example"),"Load example",class="btn-primary"),
          helpText("Load applies the selected preset. Moving sliders explores a different model; practice questions keep their stated parameters."),
          uiOutput(ns("example_note")),
          conditionalPanel(condition=paste0("input['",ns("dist_type"),"'] == 'discrete'"),
            selectInput(ns("dist"), "Choose discrete distribution", c(
            "Bernoulli" = "bern",
            "Binomial" = "binom",
            "Negative Binomial" = "nbinom",
            "Geometric" = "geom",
            "Poisson" = "pois",
            "Hypergeometric" = "hyper",
            "Discrete Uniform" = "dunifd"
          ), selected = "bern"),
          
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'bern'"),
            sliderInput(ns("p_bern"), "p", min = 0, max = 1, value = 0.40, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'binom'"),
            sliderInput(ns("n"), "n", min = 1, max = 20, value = 5, step = 1),
            sliderInput(ns("p"), "p", min = 0, max = 1, value = 0.5, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'nbinom'"),
            sliderInput(ns("r_nb"), "k", min = 1, max = 20, value = 5, step = 1),
            sliderInput(ns("p_nb"), "p", min = 0.01, max = 1, value = 0.5, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'geom'"),
            sliderInput(ns("pg"), "p", min = 0.01, max = 1, value = 0.50, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'pois'"),
            sliderInput(ns("lambda"), "λ (mean count over the stated interval)", min = 0.01, max = 30, value = 5, step = 0.1)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'hyper'"),
            sliderInput(ns("n_hy"), "n (sample size)", min = 1, max = 30, value = 10, step = 1),
            sliderInput(ns("M_hy"), "M (successes in population)", min = 1, max = 30, value = 10, step = 1),
            sliderInput(ns("N_hy"), "N (population size)", min = 10, max = 30, value = 20, step = 1)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'dunifd'"),
            sliderInput(ns("N_du"), "N", min = 1, max = 5, value = 1, step = 1)
          )),
          conditionalPanel(condition=paste0("input['",ns("dist_type"),"'] == 'continuous'"),
            selectInput(ns("dist_cont"), "Choose continuous distribution", c(
            "Uniform" = "unif",
            "Exponential" = "exp",
            "Gamma" = "gamma",
            "Normal" = "norm",
            "Beta" = "beta",
            "Chi-Squared" = "chisq",
            "Student's t" = "t",
            "F" = "f"
          ), selected = "unif"),
          
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'unif'"),
            sliderInput(ns("a_unif"), "a", min = -10, max = 0,  value = -5, step = 0.01),
            sliderInput(ns("b_unif"), "b", min =   0, max = 200, value =  5, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'exp'"),
            sliderInput(ns("rate_exp"), "Rate (λ)", min = 0.01, max = 10, value = 1, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'gamma'"),
            sliderInput(ns("shape_gam"), "Shape (k)", min = 0.01, max = 10, value = 1, step = 0.01),
            sliderInput(ns("rate_gam"),  "Rate  (λ)", min = 0.01, max = 10,  value = 1, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'norm'"),
            sliderInput(ns("mean_norm"), "μ", min = -100, max = 100, value = 0, step = 0.01),
            sliderInput(ns("sd_norm"),   "σ",   min = 0.01, max = 5, value = 1, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'beta'"),
            sliderInput(ns("alpha_beta"), "α", min = 0.01, max = 5, value = 1, step = 0.01),
            sliderInput(ns("beta_beta"),  "β", min = 0.01, max = 5, value = 1, step = 0.01)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'chisq'"),
            sliderInput(ns("df_chi"), "ν", min = 1, max = 20, value = 5, step = 1)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 't'"),
            sliderInput(ns("df_t"), "ν", min = 1, max = 20, value = 5, step = 1)
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'f'"),
            sliderInput(ns("df1_f"), "d1", min = 1, max = 20, value = 5, step = 1),
            sliderInput(ns("df2_f"), "d2", min = 1, max = 20, value = 5, step = 1)
          )),class="learning-overview-controls"),
        learning_section(ns,"plots","Plots and selected value",
          conditionalPanel(condition=paste0("input['",ns("dist_type"),"'] == 'discrete'"),
            div(class="learning-plot-pair",
              div(h4(HTML("PMF: P(X = x)")),plotOutput(ns("pmf_plot"),height=320,click=ns("click_pmf"))),
              div(h4(HTML("CDF: P(X &le; x)")),plotOutput(ns("cdf_plot"),height=320,click=ns("click_cdf")))),
            helpText("Click a graph to select x. The PMF gives its point probability; the CDF includes all outcomes up to x."),
            h4("Current Selection"),verbatimTextOutput(ns("sel_text")),uiOutput(ns("selection_precision"))),
          conditionalPanel(condition=paste0("input['",ns("dist_type"),"'] == 'continuous'"),
            div(class="learning-plot-pair",
              div(h4("PDF: probability is area"),plotOutput(ns("pdf_plot_cont"),height=320,click=ns("click_pdf_cont"))),
              div(h4(HTML("CDF: P(X &le; x)")),plotOutput(ns("cdf_plot_cont"),height=320,click=ns("click_cdf_cont")))),
            helpText("Click a graph to select x. For a continuous variable, P(X = x) = 0; a density value is not a point probability."),
            h4("Current Selection"),verbatimTextOutput(ns("sel_text_cont")),uiOutput(ns("selection_precision_cont"))),class="learning-overview-plots")),
      learning_optional_practice(ns,"3. Optional past-exam questions",uiOutput(ns("practice_section")))))
}

prob_Server <- function(id, course_path=function() "core", plot_request=function() NULL) {
  moduleServer(id, function(input, output, session) {
    path <- reactive(learning_path(course_path()))
    examples <- learning_graph_examples()
    requested_example <- reactiveVal(NULL)
    allowed_examples <- reactive(names(examples)[vapply(examples,function(ex) path() %in% ex$paths,logical(1))])
    discrete_key <- reactive({
      req(path() %in% c("core","legacy"), input$dist)
      validate(need(input$dist %in% c("bern","binom","geom","nbinom","pois","hyper","dunifd"),"Choose a discrete distribution."))
      input$dist
    })
    continuous_key <- reactive({
      allowed <- learning_continuous_choices(path());req(length(allowed)>0,input$dist_cont)
      if(input$dist_cont %in% allowed) input$dist_cont else unname(allowed[1])
    })
    observeEvent(path(), {
      kind <- if(path()=="core") "discrete" else if(path()=="legacy") isolate(input$dist_type) else "continuous"
      if(is.null(kind)) kind <- "discrete"
      choices <- if(path()=="core") c("Discrete (STATS125)"="discrete") else if(path()=="legacy") c("Discrete"="discrete","Continuous"="continuous") else c("Continuous (optional)"="continuous")
      updateRadioButtons(session,"dist_type",choices=choices,selected=kind)
      allowed <- learning_continuous_choices(path())
      if(length(allowed)) {
        previous <- isolate(input$dist_cont)
        selected <- if(!is.null(previous) && previous %in% allowed) previous else unname(allowed[1])
        updateSelectInput(session,"dist_cont",choices=allowed,selected=selected)
      }
      keys <- allowed_examples()
      updateSelectInput(session,"plot_example",choices=stats::setNames(keys,vapply(examples[keys],`[[`,character(1),"label")),selected=keys[1])
      requested_example(NULL)
    })
    output$path_description <- renderUI(tags$p(class="small-note",switch(path(),
      core="STATS125 Core: review the seven discrete models and explore their PMFs and CDFs. Self-check questions are optional.",
      preview="Optional STATS210 preview: explore density as area, waiting times, and location/scale. Calculus and formula memorisation are not prerequisites for these observations.",
      further="Optional further exploration: additional continuous models and mathematical formulas.",
      "Original distribution library for reference checks.")))
    current_example <- reactive({
      key <- requested_example()
      if(is.null(key) || !key %in% allowed_examples()) return(NULL)
      ex <- examples[[key]]
      distribution <- if(ex$type=="discrete") discrete_key() else continuous_key()
      if(!identical(distribution,ex$dist)) return(NULL)
      matches <- vapply(names(ex$inputs),function(name) {
        actual <- input[[name]];expected <- ex$inputs[[name]]
        length(actual)==1L && is.finite(actual) && abs(actual-expected)<1e-12
      },logical(1))
      if(all(matches)) ex else NULL
    })
    apply_example <- function(key) {
      if(is.null(key) || !key %in% allowed_examples()) return(invisible(NULL))
      ex <- examples[[key]]
      updateRadioButtons(session,"dist_type",selected=ex$type)
      updateSelectInput(session,if(ex$type=="discrete") "dist" else "dist_cont",selected=ex$dist)
      updateSelectInput(session,"plot_example",selected=key)
      for(name in names(ex$inputs)) updateSliderInput(session,name,value=ex$inputs[[name]])
      requested_example(key)
      session$sendCustomMessage("learning-focus",list(id=session$ns("explorer")))
      invisible(NULL)
    }
    observeEvent(input$load_plot_example,apply_example(input$plot_example))
    observeEvent(plot_request(),{request <- plot_request();req(request$key);apply_example(request$key)},ignoreNULL=TRUE)
    output$example_note <- renderUI({ex <- current_example();if(is.null(ex)) return(NULL);tags$p(class="alert alert-info",ex$note)})
    practice_questions <- learning_questions(list(),"overview",shiny::isolate(course_path()))
    practice <- learning_practice_server(input,output,session,practice_questions,"overview",course_path,open_plot=apply_example)
    output$concept_review <- renderUI({
      if(path() %in% c("core","legacy")) tagList(
        tags$ul(tags$li("A PMF gives point probabilities; supported values have non-negative probabilities summing to 1."),
          tags$li("The CDF F(x)=P(X<=x) includes its endpoint. For integer-valued X, P(X>=k)=1-F(k-1)."),
          tags$li("Define the outcome being counted, its support, model assumptions and parameters before interpreting a distribution.")),
        tags$p(class="learning-observe",tags$strong("What to explore: "),"Move the Bernoulli probability from 0.2 to 0.8. Compare the mass at 1 with the CDF at 0; then explore a count model such as Binomial."))
      else tagList(tags$ul(
        tags$li("A density is not a point probability: probabilities are areas over intervals, and P(X=x)=0 for a continuous model."),
        tags$li("The CDF is the probability up to x. A tail probability is one minus that CDF."),
        tags$li("Distinguish a Normal standard deviation from its variance, and an Exponential rate from its mean waiting time.")),
        tags$p(class="learning-observe",tags$strong("What to explore: "),"Compare equal-width Uniform intervals, increase the Exponential rate, and move a Normal mean separately from its standard deviation."))
    })
    output$practice_section <- renderUI({
      if(path()=="core") learning_practice_ui(session$ns,"Selected STATS125 past-exam extract")
      else learning_practice_ui(session$ns,"Selected STATS125 past-exam extracts")
    })

    
    #================================================
    # default range
    #================================================
    default_range <- reactive({
      req(discrete_key())
      switch(discrete_key(),
             bern = c(0, 1),
             binom = c(0, input$n),
             nbinom = {
               r <- input$r_nb
               p <- input$p_nb
               c(0, max(10, qnbinom(0.999, size = r, prob = p)))
             },
             geom = {
               p <- input$pg
               kmax <- if (p == 1) 0 else qgeom(0.999, prob = p)
               c(0, max(10, kmax))
             },
             pois  = {
               c(0, qpois(0.999, lambda = input$lambda))
             },
             hyper = {
               n <- input$n_hy; M <- input$M_hy; N <- input$N_hy
               M <- max(0, min(M, N)); n <- max(0, min(n, N))
               lo <- max(0, n + M - N)
               hi <- min(n, M)
               c(lo, hi)
             },
             dunifd = {
               N <- input$N_du
               c(1, N)
             }
      )
    })
    
    default_range_cont <- reactive({
      req(continuous_key())
      switch(continuous_key(),
             unif = {
               a <- input$a_unif; b <- input$b_unif
               validate(need(!is.null(a) && !is.null(b) && a < b, "Uniform requires a < b. Choose a wider interval."))
               c(a, b)
             },
             exp  = c(0, qexp(0.999, rate = input$rate_exp)),
             gamma = c(0, qgamma(0.999, shape = input$shape_gam, rate = input$rate_gam)),
             norm = c(input$mean_norm - 4*input$sd_norm, input$mean_norm + 4*input$sd_norm),
             beta = c(0, 1),
             chisq = c(0, qchisq(0.999, df = input$df_chi)),
             t = c(qt(0.001, df = input$df_t), qt(0.999, df = input$df_t)),
             f = c(0, qf(0.999, df1 = input$df1_f, df2 = input$df2_f)),
             c(0, 10)
      )
    })
        
        #================================================
        # Data frame
        #================================================
        dist_df <- reactive({
          rng <- default_range()
          
          if (discrete_key() == "bern") {
            k <- 0:1
            p <- input$p_bern
            pmf <- ifelse(k == 1, p, 1 - p)
            cdf <- cumsum(pmf)
            mean_val <- p
            
          } else if (discrete_key() == "binom") {
            k <- seq(rng[1], rng[2])
            pmf <- dbinom(k, size = input$n, prob = input$p)
            cdf <- pbinom(k, size = input$n, prob = input$p)
            mean_val <- input$n * input$p
            
          } else if (discrete_key() == "nbinom") {
            k <- seq(max(0, rng[1]), max(0, rng[2]))
            p <- input$p_nb
            pmf <- dnbinom(k, size = input$r_nb, prob = p)
            cdf <- pnbinom(k, size = input$r_nb, prob = p)
            mean_val <- input$r_nb * (1 - p) / p
            
          } else if (discrete_key() == "geom") {
            k <- seq(max(0, rng[1]), max(0, rng[2]))
            p <- input$pg
            pmf <- dgeom(k, prob = p)
            cdf <- pgeom(k, prob = p)
            mean_val <- (1 - p) / p
            
          } else if (discrete_key() == "pois") {
            k <- seq(rng[1], rng[2])
            pmf <- dpois(k, lambda = input$lambda)
            cdf <- ppois(k, lambda = input$lambda)
            mean_val <- input$lambda
            
          } else if (discrete_key() == "hyper") {
            n <- input$n_hy; M <- input$M_hy; N <- input$N_hy
            M <- max(0, min(M, N)); n <- max(0, min(n, N))
            lo <- max(0, n + M - N); hi <- min(n, M)
            k <- if (lo <= hi) seq(lo, hi) else integer(0)
            pmf <- if (length(k)) dhyper(k, m = M, n = N - M, k = n) else numeric(0)
            cdf <- if (length(k)) cumsum(pmf) else numeric(0)
            mean_val <- n * (M / N)
            
          } else { # dunifd
            N <- input$N_du
            k <- 1:N
            pmf <- rep(1 / N, N)
            cdf <- cumsum(pmf)
            mean_val <- (N + 1) / 2
          }
          
          df <- data.frame(k = k, pmf = pmf, cdf = pmin(1, cdf), mean = mean_val)
          validate(need(nrow(df) > 0, "There is no valid support set for the parameter combination. Please adjust the parameters."))
          df
        })
        
        dist_df_cont <- reactive({
          rng <- default_range_cont()
          x <- seq(rng[1], rng[2], length.out = 600)
          
          if (continuous_key() == "unif") {
            a <- input$a_unif; b <- input$b_unif
            validate(need(!is.null(a) && !is.null(b) && a < b, "Uniform requires a < b. Choose a wider interval."))
            pdf <- dunif(x, min = a, max = b)
            cdf <- punif(x, min = a, max = b)
          } else if (continuous_key() == "exp") {
            pdf <- dexp(x, rate = input$rate_exp)
            cdf <- pexp(x, rate = input$rate_exp)
          } else if (continuous_key() == "gamma") {
            pdf <- dgamma(x, shape = input$shape_gam, rate = input$rate_gam)
            cdf <- pgamma(x, shape = input$shape_gam, rate = input$rate_gam)
          } else if (continuous_key() == "norm") {
            pdf <- dnorm(x, mean = input$mean_norm, sd = input$sd_norm)
            cdf <- pnorm(x, mean = input$mean_norm, sd = input$sd_norm)
          } else if (continuous_key() == "beta") {
            pdf <- dbeta(x, shape1 = input$alpha_beta, shape2 = input$beta_beta)
            cdf <- pbeta(x, shape1 = input$alpha_beta, shape2 = input$beta_beta)
          } else if (continuous_key() == "chisq") {
            pdf <- dchisq(x, df = input$df_chi)
            cdf <- pchisq(x, df = input$df_chi)
          } else if (continuous_key() == "t") {
            pdf <- dt(x, df = input$df_t)
            cdf <- pt(x, df = input$df_t)
          } else if (continuous_key() == "f") {
            pdf <- df(x, df1 = input$df1_f, df2 = input$df2_f)
            cdf <- pf(x, df1 = input$df1_f, df2 = input$df2_f)
          } else {
            pdf <- rep(NA_real_, length(x))
            cdf <- rep(NA_real_, length(x))
          }
          data.frame(x = x, pdf = pdf, cdf = cdf)
        })
        
    
    #================================================
    # Define interaction variables and click logic
    #================================================
    
    # Store the currently highlighted discrete value
    selected_k <- reactiveVal(NULL)
    observeEvent(list(dist_df(),requested_example()), ignoreInit = TRUE, {
      df <- dist_df();ex <- current_example()
      selected_k(if(!is.null(ex) && ex$type=="discrete") df$k[which.min(abs(df$k-ex$x))] else df$k[which.max(df$pmf)])
    })
    
    nearest_k <- function(x_click, ks) {
      if (is.null(x_click)) return(NULL)
      ks[which.min(abs(ks - x_click))]
    }
    
    observeEvent(input$click_pmf, {
      k_new <- nearest_k(input$click_pmf$x, dist_df()$k)
      if (!is.null(k_new)) selected_k(k_new)
    })
    observeEvent(input$click_cdf, {
      k_new <- nearest_k(input$click_cdf$x, dist_df()$k)
      if (!is.null(k_new)) selected_k(k_new)
    })
    
    observeEvent(input$N_hy, {
      req(input$N_hy)
      N <- input$N_hy
      
      updateSliderInput(session, "M_hy", max = N)
      updateSliderInput(session, "n_hy", max = N)
      
      M <- isolate(input$M_hy); n <- isolate(input$n_hy)
      if (!is.null(M)) updateSliderInput(session, "M_hy", value = max(0, min(M, N)))
      if (!is.null(n)) updateSliderInput(session, "n_hy", value = max(0, min(n, N)))
    }, ignoreInit = TRUE)
    
    observeEvent(list(input$M_hy, input$n_hy, input$N_hy), {
      req(input$N_hy, input$M_hy, input$n_hy)
      N <- input$N_hy; M <- input$M_hy; n <- input$n_hy
      if (M < 0 || M > N) updateSliderInput(session, "M_hy", value = max(0, min(M, N)))
      if (n < 0 || n > N) updateSliderInput(session, "n_hy", value = max(0, min(n, N)))
    }, ignoreInit = TRUE)
    
    selected_x_cont <- reactiveVal(NULL)
    
    observeEvent(list(dist_df_cont(),requested_example()), ignoreInit = TRUE, {
      rng <- default_range_cont();ex <- current_example()
      selected_x_cont(if(!is.null(ex) && ex$type=="continuous") ex$x else mean(rng))
    })
    
    output$sel_text <- renderText({
      df <- dist_df()
      k_sel <- selected_k()
      if (is.null(k_sel) || !(k_sel %in% df$k))
        return("You can select any x in the figure to highlight it")
      p <- df$pmf[df$k == k_sel]
      Fk <- df$cdf[df$k == k_sel]
      sprintf("x = %d\nP(X = %d) %s\nF(%d) = P(X ≤ %d) %s",
              k_sel, k_sel, number_reading(p), k_sel, k_sel, number_reading(Fk))
    })
    output$selection_precision <- renderUI({
      df<-dist_df();k<-selected_k();req(k,k %in% df$k)
      tags$details(class="number-precision",tags$summary("More precision"),
        tags$pre(paste0("P(X = ",k,") = ",number_full(df$pmf[df$k==k]),"\nF(",k,") = ",number_full(df$cdf[df$k==k]))))
    })
    
    #================================================
    # Calculate the PDF/CDF of the current continuous distribution
    #================================================
    pdf_cdf_at_cont <- function(x0) {
      d <- continuous_key()
      out_pdf <- NA_real_; out_cdf <- NA_real_
      
      switch(d,
             unif = {
               a <- input$a_unif; b <- input$b_unif
               validate(need(!is.null(a) && !is.null(b) && a < b, "Uniform requires a < b. Choose a wider interval."))
               out_pdf <- dunif(x0, min = a, max = b)
               out_cdf <- punif(x0, min = a, max = b)
             },
             exp = {
               out_pdf <- dexp(x0, rate = input$rate_exp)
               out_cdf <- pexp(x0, rate = input$rate_exp)
             },
             gamma = {
               out_pdf <- dgamma(x0, shape = input$shape_gam, rate = input$rate_gam)
               out_cdf <- pgamma(x0, shape = input$shape_gam, rate = input$rate_gam)
             },
             norm = {
               out_pdf <- dnorm(x0, mean = input$mean_norm, sd = input$sd_norm)
               out_cdf <- pnorm(x0, mean = input$mean_norm, sd = input$sd_norm)
             },
             beta = {
               out_pdf <- dbeta(x0, shape1 = input$alpha_beta, shape2 = input$beta_beta)
               out_cdf <- pbeta(x0, shape1 = input$alpha_beta, shape2 = input$beta_beta)
             },
             chisq = {
               out_pdf <- dchisq(x0, df = input$df_chi)
               out_cdf <- pchisq(x0, df = input$df_chi)
             },
             t = {
               out_pdf <- dt(x0, df = input$df_t)
               out_cdf <- pt(x0, df = input$df_t)
             },
             f = {
               out_pdf <- df(x0, df1 = input$df1_f, df2 = input$df2_f)
               out_cdf <- pf(x0, df1 = input$df1_f, df2 = input$df2_f)
             }
      )
      
      list(pdf = out_pdf, cdf = out_cdf)
    }
    
    #================================================
    # Continuous: Click interaction logic
    #================================================
    
    # Continuous: Click on PDF plot
    observeEvent(input$click_pdf_cont, {
      x_new <- input$click_pdf_cont$x
      if (!is.null(x_new)) selected_x_cont(x_new)
    })
    
    # Continuous: Click on CDF plot
    observeEvent(input$click_cdf_cont, {
      x_new <- input$click_cdf_cont$x
      if (!is.null(x_new)) selected_x_cont(x_new)
    })
    
    # Continuous: Current selection reading
    output$sel_text_cont <- renderText({
      x_sel <- selected_x_cont()
      if (is.null(x_sel)) {
        return("You can select any x in the figure to highlight it")
      }
      vals <- pdf_cdf_at_cont(x_sel)
      sprintf(
        paste0(
          "x = %s\n",
          "fX(%s) %s\n",
          "F(%s) = P(X ≤ %s) %s"
        ),
        number_label(x_sel,"decimal"),number_label(x_sel,"decimal"),number_reading(vals$pdf),
        number_label(x_sel,"decimal"),number_label(x_sel,"decimal"),number_reading(vals$cdf)
      )
    })
    output$selection_precision_cont <- renderUI({
      x<-selected_x_cont();req(!is.null(x));values<-pdf_cdf_at_cont(x)
      tags$details(class="number-precision",tags$summary("More precision"),
        tags$pre(paste0("x = ",number_full(x),"\nfX(x) = ",number_full(values$pdf),"\nF(x) = ",number_full(values$cdf))))
    })
    
    #================================================
    # Distribution plot
    #================================================
    
    # Discrete PMF plot
    output$pmf_plot <- renderPlot({
      df <- dist_df()
      k_sel <- selected_k()
      p_sel <- if (!is.null(k_sel) && k_sel %in% df$k) df$pmf[df$k == k_sel] else NA_real_
      
      rng <- default_range()
      x_min <- if (discrete_key() == "bern") -1 else -3
      
      g <- ggplot(df, aes(k, pmf)) +
        geom_col(width = 0.9, fill = "#9ecae1") +
        scale_x_continuous(
          limits = c(x_min, rng[2] + 1.5),
          breaks = unique(round(pretty(c(max(x_min, rng[1]), rng[2]), n = 8)))
        ) +
        scale_y_continuous(limits = c(0, 1)) +
        labs(x = "x", y = "Probability") +
        theme_minimal(base_size = 13) +
        theme(panel.grid.minor = element_blank())
      
      if (!is.null(k_sel) && k_sel %in% df$k) {
        g <- g +
          geom_col(data = subset(df, k == k_sel), aes(k, pmf), fill = "#2171b5") +
          annotate("text", x = k_sel, y = p_sel,
                   label = sprintf("x=%d\nP %s", k_sel, number_reading(p_sel)),
                   vjust = -0.6, size = 4)
      }
      g
    })
    
    # Discrete CDF plot
    output$cdf_plot <- renderPlot({
      df <- dist_df()
      k_sel <- selected_k()
      F_sel <- if (!is.null(k_sel) && k_sel %in% df$k) df$cdf[df$k == k_sel] else NA_real_
      
      rng <- default_range()
      x_min <- if (discrete_key() == "bern") -1 else -3
      
      seg_df <- data.frame(
        x_start = c(x_min, df$k),
        x_end   = c(df$k, df$k[length(df$k)] + 1),
        y       = c(0, df$cdf)
      )
      
      g <- ggplot() +
        geom_segment(
          data = seg_df,
          aes(x = x_start, xend = x_end, y = y, yend = y),
          color = "#238b45", linewidth = 1
        ) +
        geom_point(data = df,
                   aes(x = k, y = dplyr::lag(cdf, default = 0)),
                   shape = 1, size = 2, color = "#238b45") +
        geom_point(data = df,
                   aes(x = k, y = cdf),
                   shape = 16, size = 2, color = "#238b45") +
        scale_x_continuous(
          limits = c(x_min, rng[2] + 1.5),
          breaks = unique(round(pretty(c(max(x_min, rng[1]), rng[2]), n = 8)))
        ) +
        coord_cartesian(ylim = c(0, 1)) +
        labs(x = "x", y = "Cumulative probability") +
        theme_minimal(base_size = 13) +
        theme(panel.grid.minor = element_blank())
      
      if (!is.null(k_sel) && k_sel %in% df$k) {
        g <- g +
          geom_point(data = subset(df, k == k_sel), aes(x = k, y = cdf),
                     color = "#238b45", size = 3, shape = 16) +
          annotate("text", x = k_sel, y = F_sel,
                   label = sprintf("F(%d) %s", k_sel, number_reading(F_sel)),
                   vjust = -0.8, size = 4, color = "#238b45")
      }
      g
    })
    
    # ---- Continuous PDF plot ----
    output$pdf_plot_cont <- renderPlot({
      df <- dist_df_cont()
      rng <- default_range_cont()
      
      if (continuous_key() == "unif") {
        a <- input$a_unif
        b <- input$b_unif
        h <- 1 / (b - a)
        
        rect_df <- data.frame(x = c(a, a, b, b), y = c(0, h, h, 0))
        
        g <- ggplot(rect_df, aes(x, y)) +
          geom_area(fill = "#ffb81c", alpha = 0.3) +
          geom_line(color = "#ffb81c", linewidth = 1.2) +
          annotate("segment", x = a, xend = a, y = 0, yend = h, color = "#ffb81c", linewidth = 1) +
          annotate("segment", x = b, xend = b, y = 0, yend = h, color = "#ffb81c", linewidth = 1) +
          scale_x_continuous(limits = c(rng[1]-1, rng[2]+1),
                             breaks = pretty(c(rng[1], rng[2]), n = 8)) +
          # 不强行限制到 1，避免高密度被截掉
          scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
          labs(x = "x", y = "Density") +
          theme_minimal(base_size = 13) +
          theme(panel.grid.minor = element_blank())
      } else {
        g <- ggplot(df[is.finite(df$pdf), ], aes(x, pdf)) +
          geom_area(fill = "#ffb81c", alpha = 0.3) +
          geom_line(color = "#ffb81c", linewidth = 1.2) +
          scale_x_continuous(limits = c(rng[1] - 1, rng[2] + 1),
                             breaks = pretty(c(rng[1], rng[2]), n = 8)) +
          scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
          labs(x = "x", y = "Density") +
          theme_minimal(base_size = 13) +
          theme(panel.grid.minor = element_blank())
      }
      if (any(!is.finite(df$pdf))) g <- g + labs(caption =
        "Density is unbounded at a support endpoint; that endpoint is omitted.\nFinite sampling may not resolve a sharp peak. Use the CDF for probabilities.")
      g
    })
    
    # ---- Continuous CDF plot ----
    output$cdf_plot_cont <- renderPlot({
      df <- dist_df_cont()
      rng <- default_range_cont()
      ggplot(df, aes(x, cdf)) +
        geom_line(color = "#ff5722", linewidth = 1) +
        scale_x_continuous(limits = c(rng[1] - 1, rng[2] + 1),
                           breaks = pretty(c(rng[1], rng[2]), n = 8)) +
        coord_cartesian(ylim = c(0, 1)) +
        labs(x = "x", y = "Cumulative probability") +
        theme_minimal(base_size = 13) +
        theme(panel.grid.minor = element_blank())
    })
    
    #================================================
    # Distribution description
    #================================================
    
    # Discrete distribution description
    output$dist_desc <- renderUI({
      if (discrete_key() == "bern") {
        HTML("
        <b>Bernoulli Distribution</b><br>
        A random variable Y is called a <b>Bernoulli</b> random variable if it has only two possible values, 0 and 1.<br>
        Y ~ Bernoulli(p) means P(Y = 1) = p and P(Y = 0) = 1 − p, where p is the parameter of the distribution.")
      } else if (discrete_key() == "binom") {
        HTML("
        <b>Binomial Distribution</b><br>
        Let <em>X</em> be the number of successes in <em>n</em> independent Bernoulli trials,
        each with success probability <em>p</em>. Then <em>X</em> has the <b>Binomial</b> distribution
        with parameters <em>n</em> and <em>p</em>. We write
        <em>X ~ Binomial(n, p)</em> (or <em>X ~ Bin(n, p)</em>).<br>
        Thus, the binomial distribution counts the number of successes in a fixed number of Bernoulli trials.
        ")
      } else if (discrete_key() == "nbinom") {
        HTML("
        <b>Negative Binomial Distribution</b><br>
        Let <em>X</em> be the number of failures before the <em>k</em>-th success occurs 
        in a sequence of independent Bernoulli trials, each with success probability <em>p</em>. 
        Then <em>X</em> has the <b>Negative Binomial</b> distribution with parameters <em>k</em> and <em>p</em>, 
        and we write <em>X ~ NegBin(k, p)</em>.<br>
        ")
      } else if (discrete_key() == "geom") {
        HTML("
        <b>Geometric Distribution</b><br>
        Let <em>X</em> be the number of failures before the first success occurs 
        in a sequence of independent Bernoulli trials, each with probability of success <em>p</em> on a single trial. 
        Then <em>X</em> has the <b>Geometric</b> distribution with parameter <em>p</em>, 
        and we write <em>X ~ Geometric(p)</em>.
        ")
      } else if (discrete_key() == "pois") {
        HTML("
        <b>Poisson Distribution</b><br>
        A discrete random variable <em>X</em> is said to have a <b>Poisson</b> distribution with parameter 
        <em>&lambda; &gt; 0</em>. The parameter <em>&lambda;</em> represents the expected number of events
        in a fixed interval of time or space. The Poisson distribution is commonly used to model the number of 
        arrivals, occurrences, or events happening independently at a constant rate. For this distribution, the 
        mean and variance are both equal to <em>&lambda;</em>.
        ")
      } else if (discrete_key() == "hyper") {
        HTML("
        <b>Hypergeometric Distribution</b><br>
        Let <em>X</em> be the number of “successes” in <em>n</em> draws without replacement 
        from a finite population of size <em>N</em>, of which <em>M</em> are “successes”. 
        Then <em>X</em> has the <b>Hypergeometric</b> distribution with parameters 
        <em>n</em>, <em>M</em>, and <em>N</em>, and we write <em>X ~ HYP(n, M, N)</em> 
        (or <em>X ~ Hypergeometric(n, M, N)</em>).<br><br>
        The support is <em>x = max(0, n - N + M), ..., min(n, M)</em>.
        ")
      } else if (discrete_key() == "dunifd") {
        HTML("
        <b>Discrete Uniform Distribution</b><br>
        Suppose <em>X</em> is equally likely to take any integer value from 
        <em>a</em> to <em>b</em>. Then <em>X</em> has a 
        <b>discrete uniform</b> distribution on {a, a+1, …, b}, 
        and we write <em>X ~ DU(a, b)</em>.<br><br>
        Each outcome in the set has the same probability, 
        and the support is {a, a+1, …, b}.
        ")
      }
    })
    
    #================================================
    # Continuous distribution description
    #================================================
    
    output$dist_desc_cont <- renderUI({
      if (continuous_key() == "unif") {
        HTML("
        <b>Uniform Distribution</b><br>
        A random variable <em>X</em> is said to have a <b>Uniform distribution</b> 
        on the interval <em>(a, b)</em> if it is equally likely to take any value in that interval.<br>
        We write <em>X ~ Uniform(a, b)</em> (or <em>X ~ U(a, b)</em>).<br>
        The pdf is constant over the interval and zero otherwise. Equal-length subintervals have equal probability; every individual point has probability zero.
        ")
      } else if (continuous_key() == "exp") {
        HTML("
        <b>Exponential Distribution</b><br>
        A random variable <em>X</em> has an <b>Exponential distribution</b> with rate parameter 
        <em>λ > 0</em> if it models the waiting time between independent events occurring at rate λ.<br>
        We write <em>X ~ Exp(λ)</em>.<br>
        ")
      } else if (continuous_key() == "gamma") {
        HTML("
        <b>Gamma Distribution</b><br>
        The <b>Gamma(k, λ)</b> distribution is a flexible family of distributions.<br><br>
        For a positive integer shape <em>k</em>, it is the sum of <em>k</em> independent Exponential(λ) random variables. The Gamma density also permits any real shape k &gt; 0:<br>
        If <em>X<sub>1</sub>, …, X<sub>k</sub> ~ Exponential(λ)</em> are independent, then<br>
        <em>X<sub>1</sub> + X<sub>2</sub> + ··· + X<sub>k</sub> ~ Gamma(k, λ)</em>.<br><br>
        <b>Special Case:</b> When k = 1, Gamma(1, λ) = Exponential(λ).<br>
        ")
      } else if (continuous_key() == "norm") {
        HTML("
        <b>Normal Distribution</b><br>
        A random variable <em>X</em> is said to have a <b>Normal distribution</b> 
        with mean <em>μ</em> and variance <em>σ²</em> if its pdf is bell-shaped and symmetric about μ.<br>
        We write <em>X ~ Normal(μ, σ²)</em>.<br>
        ")
      } else if (continuous_key() == "beta") {
        HTML("
        <b>Beta Distribution</b><br>
        A random variable <em>X</em> has a <b>Beta distribution</b> with parameters 
        <em>α > 0</em> and <em>β > 0</em> if it is supported on (0,1) with pdf proportional to 
        <em>x<sup>α−1</sup>(1−x)<sup>β−1</sup></em>.<br>
        We write <em>X ~ Beta(α, β)</em>.<br>
        ")
      } else if (continuous_key() == "chisq") {
        HTML("
        <b>Chi-Squared Distribution</b><br>
        A random variable <em>X</em> has a <b>Chi-squared distribution</b> with 
        <em>ν</em> degrees of freedom if it is the sum of squares of ν independent standard normal variables.<br>
        We write <em>X ~ χ²(ν)</em>.<br>
        ")
      } else if (continuous_key() == "t") {
        HTML("
        <b>Student's t Distribution</b><br>
        A random variable <em>X</em> has a <b>t distribution</b> with <em>ν</em> degrees of freedom 
        if it is the ratio of a standard normal variable to the square root of a chi-squared variable 
        (scaled by its degrees of freedom), with the normal and chi-squared variables independent.<br>
        We write <em>X ~ t(ν)</em>.<br>
        ")
      } else if (continuous_key() == "f") {
        HTML("
        <b>F Distribution</b><br>
        A random variable <em>X</em> has an <b>F distribution</b> with 
        <em>d₁</em> and <em>d₂</em> degrees of freedom if it is the ratio of two independent chi-squared variables, each divided by its degrees of freedom.<br>
        We write <em>X ~ F(d₁, d₂)</em>.<br>
        ")
      }
    })
    
    #================================================
    #Formula
    #================================================
    
    #Discrete distribution formula
    output$formula <- renderUI({
      spec <- list(
        bern = "<ul>
  <li><b>PMF</b>: $$f_Y(y)=\\begin{cases}
      p, & y=1 \\\\
      1-p, & y=0 \\\\
      0, & \\text{otherwise}
    \\end{cases}$$</li>

  <li><b>CDF</b>: $$F_Y(y)=\\begin{cases}
      0, & y<0 \\\\
      1-p, & 0 \\le y < 1 \\\\
      1, & y \\ge 1
    \\end{cases}$$</li>

  <li><b>Mean</b>: $$\\mathbb{E}[Y]=0\\times(1-p)+1\\times p = p$$</li>

  <li><b>Variance</b>: $$\\text{Var}(Y)=\\mathbb{E}[Y^2]-(\\mathbb{E}[Y])^2
      =0^2\\times(1-p)+1^2\\times p - p^2 = p - p^2 = p(1-p)$$</li>
</ul>"
        ,
        binom = "<ul>
  <li><b>PMF</b>:
    $$ f_X(x) = P(X = x) = \\binom{n}{x} \\, p^{x} (1-p)^{\\,n-x}, \\quad x = 0,1,\\ldots,n. $$ 
  </li>

  <li><b>CDF</b>:
    $$ F_X(x) = P(X \\le x) =
      \\begin{cases}
        0, & x < 0, \\\\
        \\displaystyle \\sum_{y=0}^{\\lfloor x \\rfloor} \\binom{n}{y} \\, p^{y} (1-p)^{\\,n-y}, & 0 \\le x < n, \\\\
        1, & x \\ge n. 
      \\end{cases}
    $$
  </li>

  <li><b>Mean</b>:
    $$ \\mathbb{E}[X] = np. $$
  </li>

  <li><b>Variance</b>:
    $$ \\mathrm{Var}(X) = np(1-p) = npq, \\quad \\text{where } q = 1-p. $$
  </li>
</ul>"
        ,
        nbinom = "<ul>
  <li><b>PMF</b>:
    $$ f_X(x) = P(X = x) = \\binom{k+x-1}{x} p^k (1-p)^x, \\quad x=0,1,2,\\ldots $$
  </li>

  <li><b>CDF</b>:
    $$ F_X(x) = P(X \\le x) = \\sum_{i=0}^{x} 
       \\binom{i+k-1}{i} (1-p)^i p^k, \\quad x=0,1,2,\\ldots $$
  </li>
  
  <li><b>Mean</b>:
    $$ \\mathbb{E}[X] = \\frac{k(1-p)}{p} = \\frac{kq}{p}, \\quad q=1-p. $$
  </li>

  <li><b>Variance</b>:
    $$ \\mathrm{Var}(X) = \\frac{k(1-p)}{p^2} = \\frac{kq}{p^2}, \\quad q=1-p. $$
  </li>
</ul>"
        ,
        geom = "<ul>
  <li><b>PMF</b>:
    $$ f_X(x) = P(X = x) = (1-p)^{x} p, \\quad x = 0,1,2,\\ldots $$
  </li>

  <li><b>CDF</b>:
    $$ F_X(x) = P(X \\le x) = 1 - (1-p)^{x+1}, \\quad x = 0,1,2,\\ldots $$
  </li>

  <li><b>Mean</b>:
    $$ \\mathbb{E}[X] = \\frac{1-p}{p} = \\frac{q}{p}, \\quad q = 1-p. $$
  </li>

  <li><b>Variance</b>:
    $$ \\mathrm{Var}(X) = \\frac{1-p}{p^2} = \\frac{q}{p^2}, \\quad q = 1-p. $$
  </li>
</ul>"
        ,
        pois = "<ul>
        <li><b>PMF</b>:
    $$ f_X(x) = P(X = x) = \\dfrac{\\lambda^{x} e^{-\\lambda}}{x!}, 
       \\quad x=0,1,2,\\ldots $$
  </li>

  <li><b>CDF</b>:
    $$ F_X(x) = P(X \\le x) =
      \\sum_{y=0}^{\\lfloor x \\rfloor} \\dfrac{\\lambda^{y} e^{-\\lambda}}{y!}
      = e^{-\\lambda} \\sum_{y=0}^{\\lfloor x \\rfloor} \\dfrac{\\lambda^{y}}{y!}. $$
  </li>

  <li><b>Mean</b>:
    $$ \\mathbb{E}[X] = \\lambda. $$
  </li>

  <li><b>Variance</b>:
    $$ \\mathrm{Var}(X) = \\lambda. $$
  </li>
      </ul>",
        hyper = "<ul>
  <li><b>PMF</b>:
    $$ f_X(x) = \\mathbb{P}(X = x) =
      \\dfrac{\\binom{M}{x} \\, \\binom{N-M}{n-x}}{\\binom{N}{n}}, 
      \\quad x = \\max(0, n+M-N),\\ldots,\\min(n,M). $$
  </li>

  <li><b>CDF</b>:
    $$ F_X(x) = \\mathbb{P}(X \\le x) =
      \\sum_{y=\\max(0, n+M-N)}^{x} 
      \\dfrac{\\binom{M}{y} \\, \\binom{N-M}{n-y}}{\\binom{N}{n}}. $$
  </li>
  
  <li><b>Mean</b>:
    $$ \\mathbb{E}[X] = n \\cdot \\dfrac{M}{N}. $$
  </li>

  <li><b>Variance</b>:
    $$ \\mathrm{Var}(X) = 
      n \\cdot \\dfrac{M}{N} \\Bigl(1 - \\dfrac{M}{N}\\Bigr) 
      \\cdot \\dfrac{N-n}{N-1}. $$
  </li>
      </ul>",
        dunifd = "<ul>
  <li><b>PMF</b>:
    $$ f_X(x) = \\mathbb{P}(X = x) = \\dfrac{1}{N}, 
       \\quad x = 1,2,\\ldots,N. $$
  </li>

  <li><b>CDF</b>:
    $$ F_X(x) = \\mathbb{P}(X \\le x) = 
      \\begin{cases}
        0, & x < 1 \\\\
        \\dfrac{\\lfloor x \\rfloor}{N}, & 1 \\le x \\le N \\\\
        1, & x > N
      \\end{cases} $$
  </li>

  <li><b>Mean</b>:
    $$ \\mathbb{E}[X] = \\dfrac{N+1}{2}. $$
  </li>

  <li><b>Variance</b>:
    $$ \\mathrm{Var}(X) = \\dfrac{N^2 - 1}{12}. $$
  </li>
</ul>"
        
      )
      withMathJax(HTML(spec[[discrete_key()]]))
    })
    
    #Continuous distribution formula
    output$formula_cont <- renderUI({
      spec <- list(
        unif = "<ul>
      <li><b>Distribution</b>:
        $$ f_X(x) =
          \\begin{cases}
            \\dfrac{1}{b-a}, & a < x < b, \\\\
            0, & \\text{otherwise}.
          \\end{cases} $$
        <br>
        $$ F_X(x) =
          \\begin{cases}
            0, & x \\le a, \\\\
            \\dfrac{x-a}{b-a}, & a < x < b, \\\\
            1, & x \\ge b.
          \\end{cases} $$
      </li>
      <li><b>Mean</b>: $$ \\mathbb{E}[X] = \\dfrac{a+b}{2} $$</li>
      <li><b>Variance</b>: $$ \\mathrm{Var}(X) = \\dfrac{(b-a)^2}{12} $$</li>
    </ul>",
        
        exp = "<ul>
      <li><b>Distribution</b>:
        $$ f_X(x) =
          \\begin{cases}
            \\lambda e^{-\\lambda x}, & x > 0, \\\\
            0, & x \\le 0
          \\end{cases} $$
        <br>
        $$ F_X(x) =
          \\begin{cases}
            1 - e^{-\\lambda x}, & x > 0, \\\\
            0, & x \\le 0
          \\end{cases} $$
      </li>
      <li><b>Mean</b>: $$ \\mathbb{E}[X] = \\dfrac{1}{\\lambda} $$</li>
      <li><b>Variance</b>: $$ \\mathrm{Var}(X) = \\dfrac{1}{\\lambda^2} $$</li>
    </ul>",
        
        gamma = "<ul>
      <li><b>Distribution</b>:
        $$ f_X(x) =
          \\begin{cases}
            \\dfrac{\\lambda^k}{\\Gamma(k)} x^{k-1} e^{-\\lambda x}, & x > 0, \\\\
            0, & x \\le 0
          \\end{cases} $$
        <br>
        where $$ \\Gamma(k) = \\int_0^{\\infty} y^{k-1} e^{-y} dy. $$
      </li>
      <li><b>Mean</b>: $$ \\mathbb{E}[X] = \\dfrac{k}{\\lambda} $$</li>
      <li><b>Variance</b>: $$ \\mathrm{Var}(X) = \\dfrac{k}{\\lambda^2} $$</li>
    </ul>",
        
        norm = "<ul>
      <li><b>Distribution</b>:
        $$ f_X(x) = \\dfrac{1}{\\sqrt{2\\pi\\sigma^2}} 
          e^{-\\dfrac{(x-\\mu)^2}{2\\sigma^2}}, 
          \\quad -\\infty < x < \\infty $$
        <br>
        The CDF has no closed form, usually written as $$ F_X(x) = \\mathbb{P}(X \\le x). $$
      </li>
      <li><b>Mean</b>: $$ \\mathbb{E}[X] = \\mu $$</li>
      <li><b>Variance</b>: $$ \\mathrm{Var}(X) = \\sigma^2 $$</li>
    </ul>",
        
        beta = "<ul>
      <li><b>Distribution</b>:
        $$ f_X(x) =
          \\begin{cases}
            \\dfrac{1}{B(\\alpha, \\beta)} x^{\\alpha - 1} (1 - x)^{\\beta - 1}, & 0 < x < 1, \\\\
            0, & \\text{otherwise}.
          \\end{cases} $$
        <br>
        where $$ B(\\alpha, \\beta) = \\int_0^1 x^{\\alpha - 1}(1-x)^{\\beta - 1} dx 
        = \\dfrac{\\Gamma(\\alpha)\\Gamma(\\beta)}{\\Gamma(\\alpha+\\beta)}. $$
      </li>
      <li><b>Mean</b>: $$ \\mathbb{E}[X] = \\dfrac{\\alpha}{\\alpha + \\beta} $$</li>
      <li><b>Variance</b>: $$ \\mathrm{Var}(X) = \\dfrac{\\alpha \\beta}{(\\alpha+\\beta)^2 (\\alpha+\\beta+1)} $$</li>
    </ul>",
        
        chisq = "<ul>
      <li><b>Distribution</b>:
        $$ f_X(x) = \\dfrac{1}{2^{\\nu/2}\\Gamma(\\nu/2)} x^{\\nu/2 - 1} e^{-x/2}, \\quad x > 0 $$
        <br>
        where ν is the degrees of freedom.
      </li>
      <li><b>Mean</b>: $$ \\mathbb{E}[X] = \\nu $$</li>
      <li><b>Variance</b>: $$ \\mathrm{Var}(X) = 2\\nu $$</li>
    </ul>",
        
        t = "<ul>
      <li><b>Distribution</b>:
        $$ f_X(x) = \\dfrac{\\Gamma((\\nu+1)/2)}{\\sqrt{\\nu\\pi}\\,\\Gamma(\\nu/2)} 
        \\Big(1+\\dfrac{x^2}{\\nu}\\Big)^{-(\\nu+1)/2}, 
        \\quad -\\infty < x < \\infty $$
        <br>
        The CDF has no closed form, written as $$ F_X(x) = \\mathbb{P}(X \\le x). $$
      </li>
      <li><b>Mean</b>: $$ 0, \\quad (\\nu > 1) $$</li>
      <li><b>Variance</b>: $$ \\dfrac{\\nu}{\\nu-2}, \\quad (\\nu > 2) $$</li>
    </ul>",
        
        f = "<ul>
      <li><b>Distribution</b>:
        $$ f_X(x) = \\dfrac{\\Gamma((d_1+d_2)/2)}{\\Gamma(d_1/2)\\Gamma(d_2/2)} 
        \\Big(\\dfrac{d_1}{d_2}\\Big)^{d_1/2} 
        \\dfrac{x^{d_1/2 - 1}}{(1 + \\tfrac{d_1}{d_2}x)^{(d_1+d_2)/2}}, 
        \\quad x > 0 $$
        <br>
        The CDF has no closed form, written as $$ F_X(x) = \\mathbb{P}(X \\le x). $$
      </li>
      <li><b>Mean</b>: $$ \\dfrac{d_2}{d_2 - 2}, \\quad (d_2 > 2) $$</li>
      <li><b>Variance</b>: $$ \\dfrac{2 d_2^2 (d_1 + d_2 - 2)}{d_1 (d_2 - 2)^2 (d_2 - 4)}, \\quad (d_2 > 4) $$</li>
    </ul>"
      )
      
      withMathJax(HTML(spec[[continuous_key()]]))
    })
    practice
  })   
}
