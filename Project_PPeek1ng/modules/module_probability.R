# ============================================================
# Module: Probability Distribution UI
# ============================================================

# ---- Load Required Packages ----
library(shiny)
library(ggplot2)
library(latex2exp)

# Use the existing slider as the parameter value shared by both controls.
prob_parameter_input <- function(inputId, label, min, max, value, step, description,
                                 integer = step == 1) {
  div(class = "learning-parameter",
    sliderInput(inputId, label, min = min, max = max, value = value, step = step),
    div(class = "learning-parameter-number-control",
      tags$input(type = "number", class = "form-control learning-parameter-number",
        value = value, min = min, max = max, step = "any",
        `data-parameter-slider` = inputId, `data-parameter-step` = step,
        `data-parameter-integer` = tolower(as.character(integer)),
        `aria-labelledby` = paste0(inputId, "-label"),
        `aria-describedby` = paste(paste0(inputId, "-description"), paste0(inputId, "-error"))),
      div(class = "learning-parameter-steppers",
        tags$button(type = "button", `data-parameter-direction` = 1,
          `aria-label` = paste("Increase", label), tags$span(`aria-hidden` = "true", "▴")),
        tags$button(type = "button", `data-parameter-direction` = -1,
          `aria-label` = paste("Decrease", label), tags$span(`aria-hidden` = "true", "▾")))),
    tags$p(id = paste0(inputId, "-description"), class = "learning-parameter-description", description),
    tags$small(id = paste0(inputId, "-error"), class = "learning-parameter-error",
      role = "status", `aria-live` = "polite", hidden = NA))
}

# ---- UI Module Definition ----
prob_UI <- function(id) {
  ns<-NS(id)
  continuous_path <- sprintf("['preview', 'further'].includes(input['%s'])", ns("learning_path"))
  discrete_path <- paste0("!", continuous_path)
  continuous_selector_ready <- sprintf("%s && output['%s'] === input['%s']",
    continuous_path, ns("continuous_selector_path"), ns("learning_path"))
  tagList(
    div(class="learning-module",
      learning_module_header(ns,"Probability Distributions",
        "Choose a distribution, review its key ideas, then change its parameters and read the plots. Self-check questions are optional.",
        c("Review key ideas"="theory","Explore plots & parameters"="explorer","Past-exam questions (optional)"="practice")),
      div(class="learning-overview-selectors",
        selectInput(ns("learning_path"), "Learning path", choices = learning_path_labels, selected = "core"),
        conditionalPanel(condition=discrete_path,
          selectInput(ns("dist"), "Choose discrete distribution", choices=c(
            "Bernoulli"="bern", "Binomial"="binom", "Geometric"="geom", "Negative Binomial"="nbinom",
            "Hypergeometric"="hyper", "Discrete Uniform"="dunifd", "Poisson"="pois"
          ), selected="bern")),
        conditionalPanel(condition=continuous_selector_ready,
          selectInput(ns("dist_cont"), "Choose continuous distribution",
            choices=learning_continuous_choices("preview"), selected="unif"))),
      uiOutput(ns("path_description")),
      learning_section(ns,"theory","1. Review the key ideas",
        conditionalPanel(condition=discrete_path, uiOutput(ns("dist_desc"))),
        conditionalPanel(condition=continuous_path, uiOutput(ns("dist_desc_cont"))),
        uiOutput(ns("concept_review")),
        conditionalPanel(condition=discrete_path,
          tags$details(class="learning-more-theory",tags$summary("Model formulas"),withMathJax(uiOutput(ns("formula"))))),
        conditionalPanel(condition=continuous_path,
          tags$details(class="learning-more-theory",tags$summary("Optional mathematical formulas"),
            withMathJax(HTML("For a continuous model: \\(F(x)=\\int_{-\\infty}^x f(t)dt\\) and \\(f(x)=F'(x)\\) where differentiable.")),
            withMathJax(uiOutput(ns("formula_cont"))))),class="learning-theory"),
      learning_section(ns,"explorer","2. Explore plots and parameters",
        div(class="learning-overview-explorer",
        learning_section(ns,"controls","Parameters",
          conditionalPanel(condition=discrete_path,
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'bern'"),
            prob_parameter_input(ns("p_bern"), "Success probability (p)", min = 0, max = 1, value = 0.40, step = 0.1,
              description = "Chance of success in one trial. Success is coded as 1.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'binom'"),
            prob_parameter_input(ns("n"), "Number of trials (n)", min = 1, max = 20, value = 5, step = 1,
              description = "Fixed number of independent trials. Must be a whole number."),
            prob_parameter_input(ns("p"), "Success probability (p)", min = 0, max = 1, value = 0.5, step = 0.1,
              description = "The same success probability applies to every independent trial.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'nbinom'"),
            prob_parameter_input(ns("r_nb"), "Target number of successes (k)", min = 1, max = 20, value = 5, step = 1,
              description = "Stop at the kth success. X counts the failures before it."),
            prob_parameter_input(ns("p_nb"), "Success probability (p)", min = 0.01, max = 1, value = 0.5, step = 0.1,
              description = "Success probability on each independent trial. p must be positive.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'geom'"),
            prob_parameter_input(ns("pg"), "Success probability (p)", min = 0.01, max = 1, value = 0.50, step = 0.1,
              description = "Success probability per trial. X counts failures before the first success.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'pois'"),
            prob_parameter_input(ns("lambda"), "λ (mean count over the stated interval)", min = 0.01, max = 30, value = 5, step = 0.1,
              description = "Expected number of events over the full time or space interval.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'hyper'"),
            prob_parameter_input(ns("n_hy"), "n (sample size)", min = 1, max = 30, value = 10, step = 1,
              description = "Number of items drawn without replacement. Whole number, n ≤ N."),
            prob_parameter_input(ns("M_hy"), "M (successes in population)", min = 1, max = 30, value = 10, step = 1,
              description = "Number of population items counted as successes. Whole number, M ≤ N."),
            prob_parameter_input(ns("N_hy"), "N (population size)", min = 10, max = 30, value = 20, step = 1,
              description = "Total number of items in the population before sampling. Whole number.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist'), "'] == 'dunifd'"),
            prob_parameter_input(ns("N_du"), "Number of possible values (N)", min = 1, max = 5, value = 1, step = 1,
              description = "Each integer from 1 to N is equally likely. N must be a whole number.")
          )),
          conditionalPanel(condition=continuous_path,
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'unif'"),
            prob_parameter_input(ns("a_unif"), "Lower bound (a)", min = -10, max = 0, value = -5, step = 0.1,
              description = "Smallest possible value. a must be less than b."),
            prob_parameter_input(ns("b_unif"), "Upper bound (b)", min = 0, max = 200, value = 5, step = 0.1,
              description = "Largest possible value. b must be greater than a.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'exp'"),
            prob_parameter_input(ns("rate_exp"), "Rate (λ)", min = 0.01, max = 10, value = 1, step = 0.1,
              description = "Average event rate. The mean waiting time is 1/λ.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'gamma'"),
            prob_parameter_input(ns("shape_gam"), "Shape (k)", min = 0.01, max = 10, value = 1, step = 0.1,
              description = "Controls the shape and skewness. k must be positive."),
            prob_parameter_input(ns("rate_gam"),  "Rate  (λ)", min = 0.01, max = 10,  value = 1, step = 0.1,
              description = "Rate parameter. The mean is k/λ, so increasing λ reduces the mean.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'norm'"),
            prob_parameter_input(ns("mean_norm"), "Mean (μ)", min = -100, max = 100, value = 0, step = 0.1,
              description = "Sets the centre of the distribution."),
            prob_parameter_input(ns("sd_norm"), "Standard deviation (σ)", min = 0.01, max = 5, value = 1, step = 0.1,
              description = "Larger σ gives a wider curve. The variance is σ².")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'beta'"),
            prob_parameter_input(ns("alpha_beta"), "First shape parameter (α)", min = 0.01, max = 5, value = 1, step = 0.1,
              description = "With β fixed, increasing α shifts probability towards 1."),
            prob_parameter_input(ns("beta_beta"), "Second shape parameter (β)", min = 0.01, max = 5, value = 1, step = 0.1,
              description = "With α fixed, increasing β shifts probability towards 0.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'chisq'"),
            prob_parameter_input(ns("df_chi"), "Degrees of freedom (ν)", min = 1, max = 20, value = 5, step = 1, integer = FALSE,
              description = "Controls the shape. The mean is ν and the variance is 2ν.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 't'"),
            prob_parameter_input(ns("df_t"), "Degrees of freedom (ν)", min = 1, max = 20, value = 5, step = 1, integer = FALSE,
              description = "Controls tail heaviness. Smaller ν gives heavier tails.")
          ),
          conditionalPanel(
            condition = paste0("input['", ns('dist_cont'), "'] == 'f'"),
            prob_parameter_input(ns("df1_f"), "Numerator degrees of freedom (d₁)", min = 1, max = 20, value = 5, step = 1, integer = FALSE,
              description = "Degrees of freedom of the numerator chi-squared variable."),
            prob_parameter_input(ns("df2_f"), "Denominator degrees of freedom (d₂)", min = 1, max = 20, value = 5, step = 1, integer = FALSE,
              description = "Degrees of freedom of the denominator chi-squared variable.")
          )),class="learning-overview-controls"),
        learning_section(ns,"plots","Distribution plots",
          conditionalPanel(condition=discrete_path,
            div(class="learning-plot-pair",
              div(h4(HTML("PMF: P(X = x)")),plotly::plotlyOutput(ns("pmf_plot"),height=320)),
              div(h4(HTML("CDF: P(X &le; x)")),plotly::plotlyOutput(ns("cdf_plot"),height=320)))),
          conditionalPanel(condition=continuous_path,
            div(class="learning-plot-pair",
              div(h4("PDF: probability is area"),plotly::plotlyOutput(ns("pdf_plot_cont"),height=320)),
              div(h4(HTML("CDF: P(X &le; x)")),plotly::plotlyOutput(ns("cdf_plot_cont"),height=320))),
            helpText("A density value is not a point probability.")),class="learning-overview-plots")),class="learning-overview-section"),
      learning_optional_practice(ns,"3. Optional past-exam questions",uiOutput(ns("practice_section")))))
}

prob_Server <- function(id, course_path=function() "core", plot_request=function() NULL) {
  moduleServer(id, function(input, output, session) {
    path <- reactive(learning_path(course_path()))
    examples <- learning_graph_examples()
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
      allowed <- learning_continuous_choices(path())
      if(length(allowed)) {
        previous <- isolate(input$dist_cont)
        selected <- if(!is.null(previous) && previous %in% allowed) previous else unname(allowed[1])
        updateSelectInput(session,"dist_cont",choices=allowed,selected=selected)
      }
    })
    # Wait for the server to refresh the choices before accepting another model selection.
    output$continuous_selector_path <- renderText(path())
    outputOptions(output, "continuous_selector_path", suspendWhenHidden = FALSE)
    output$path_description <- renderUI(tags$p(class="small-note",switch(path(),
      core="STATS125 Core: review the seven discrete models and explore their graphs. Self-check questions are optional.",
      preview="Optional STATS210 preview: Uniform, Exponential and Normal distributions. Explore density as area, waiting times, and location/scale.",
      further="Further exploration: Gamma, Beta, Chi-Squared, Student's t and F distributions, with optional mathematical formulas.",
      "Original distribution library for reference checks.")))
    # Past-exam actions can still load the question's model and parameters.
    apply_example <- function(key) {
      if(is.null(key) || !key %in% allowed_examples()) return(invisible(NULL))
      ex <- examples[[key]]
      updateSelectInput(session,if(ex$type=="discrete") "dist" else "dist_cont",selected=ex$dist)
      for(name in names(ex$inputs)) updateSliderInput(session,name,value=ex$inputs[[name]])
      session$sendCustomMessage("learning-focus",list(id=session$ns("explorer")))
      invisible(NULL)
    }
    observeEvent(plot_request(),{request <- plot_request();req(request$key);apply_example(request$key)},ignoreNULL=TRUE)
    practice_questions <- learning_questions(list(),"overview",shiny::isolate(course_path()))
    practice <- learning_practice_server(input,output,session,practice_questions,"overview",course_path,open_plot=apply_example)
    output$concept_review <- renderUI({
      discrete <- path() %in% c("core", "legacy")
      key <- if (discrete) discrete_key() else continuous_key()
      concepts <- if (discrete) tags$ul(
        tags$li("A probability mass function (PMF) gives the probability of each possible value. These probabilities are non-negative and sum to 1."),
        tags$li(if(key=="bern")
          "The cumulative distribution function (CDF) gives F(x) = P(X ≤ x). Here, F(0) = P(X = 0) = 1 − p, because 0 is the only outcome at or below 0."
          else "The cumulative distribution function (CDF) gives F(x) = P(X ≤ x). For integer-valued X, P(X ≥ k) = 1 − F(k − 1).")
      ) else tags$ul(
        tags$li("The probability density function (PDF) gives interval probabilities through areas under the curve. The probability at a single point is zero."),
        tags$li("The cumulative distribution function (CDF) gives the probability up to and including x. The probability above x is one minus the CDF at x.")
      )
      concepts
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
        discrete_data <- function(extra=0) {
          rng <- default_range()
          rng[2] <- rng[2]+extra
          
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
        }
        dist_df <- reactive(discrete_data())
        
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
    # Keep hypergeometric population and sample parameters consistent
    #================================================
    
    observeEvent(input$N_hy, {
      req(input$N_hy)
      N <- input$N_hy
      
      updateSliderInput(session, "M_hy", max = N)
      updateSliderInput(session, "n_hy", max = N)
      
      M <- isolate(input$M_hy); n <- isolate(input$n_hy)
      if (!is.null(M)) updateSliderInput(session, "M_hy", value = max(0, min(M, N)))
      if (!is.null(n)) updateSliderInput(session, "n_hy", value = max(0, min(n, N)))
    })
    
    observeEvent(list(input$M_hy, input$n_hy, input$N_hy), {
      req(input$N_hy, input$M_hy, input$n_hy)
      N <- input$N_hy; M <- input$M_hy; n <- input$n_hy
      if (M < 0 || M > N) updateSliderInput(session, "M_hy", value = max(0, min(M, N)))
      if (n < 0 || n > N) updateSliderInput(session, "n_hy", value = max(0, min(n, N)))
    }, ignoreInit = TRUE)
    
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
    
    # Keep smooth drawing points separate from readable, shared query positions.
    continuous_query <- reactive({
      rng <- default_range_cont()
      raw_step <- diff(rng) / 100
      scale <- 10^floor(log10(raw_step))
      factors <- c(1, 2, 5, 10)
      step <- scale * factors[which(factors >= raw_step / scale - 1e-10)[1]]
      digits <- max(0L, as.integer(-floor(log10(step))))
      first <- ceiling(rng[1] / step - 1e-9)
      last <- floor(rng[2] / step + 1e-9)
      x <- round(seq(first, last) * step, digits = digits)
      x[x == 0] <- 0
      values <- pdf_cdf_at_cont(x)
      labels <- trimws(formatC(x, format = "f", digits = digits, drop0trailing = TRUE))
      # Matching signatures prevent linking two different parameter revisions.
      signature <- paste(continuous_key(), paste(format(c(x, values$pdf, values$cdf),
        digits = 17, scientific = TRUE, trim = TRUE), collapse = "|"), sep = "|")
      list(x = x, pdf = values$pdf, cdf = values$cdf, labels = labels,
        reading = list(step = step, digits = digits, signature = signature,
          x = as.list(x), labels = as.list(labels),
          density = as.list(ifelse(is.finite(values$pdf), values$pdf, NA_real_)),
          cumulative = as.list(values$cdf),
          densityText = as.list(number_reading(values$pdf)),
          cumulativeText = as.list(number_reading(values$cdf))))
    })

    # Native browser hover links the two plots without a server round trip.
    linked_plot <- function(p, peer, kind, color, xrange, ylabel, probability=TRUE,reading=NULL) {
      axis_color <- "#687b8e"
      xaxis <- list(title="x",range=xrange,zeroline=FALSE,tickformat=".4~f",
        showline=TRUE,linecolor=axis_color,linewidth=1,
        ticks="outside",tickcolor=axis_color,ticklen=4,nticks=5,automargin=TRUE,fixedrange=TRUE)
      if(kind %in% c("bar","point")) {
        # Discrete outcomes use readable integer ticks at every model size.
        ticks <- unique(round(pretty(xrange,n=5)))
        xaxis$tickmode <- "array"
        xaxis$tickvals <- ticks[ticks>=xrange[1] & ticks<=xrange[2]]
      }
      if(kind == "curve" && !is.null(reading$digits)) {
        xaxis$tickformat <- paste0(".", reading$digits, "~f")
        # Continuous hover is handled by the paired browser queries.
        p <- plotly::event_unregister(p, "plotly_hover")
        p <- plotly::event_unregister(p, "plotly_unhover")
        p <- plotly::event_unregister(p, "plotly_click")
      }
      yaxis <- list(title=ylabel,rangemode="tozero",zeroline=FALSE,tickformat=".4~f",
        showline=TRUE,linecolor=axis_color,linewidth=1,
        ticks="outside",tickcolor=axis_color,ticklen=4,automargin=TRUE,fixedrange=TRUE)
      if(probability) {
        yaxis$range <- c(0,1.05)
        yaxis$tickmode <- "array"
        yaxis$tickvals <- seq(0,1,by=.2)
      }
      p <- plotly::layout(p, showlegend=FALSE, hovermode="x", hoverdistance=-1,
        dragmode=FALSE, margin=list(l=62,r=18,t=18,b=48),
        xaxis=xaxis,yaxis=yaxis,
        paper_bgcolor="rgba(0,0,0,0)",plot_bgcolor="rgba(0,0,0,0)",
        hoverlabel=list(namelength=0))
      p <- plotly::config(p,displayModeBar=FALSE,scrollZoom=FALSE,doubleClick=FALSE,responsive=TRUE)
      htmlwidgets::onRender(p,
        "function(el,x,data){window.learningLinkDistributionPlot(el,data);}",
        data=list(peerId=session$ns(peer),kind=kind,color=color,reading=reading,probability=probability))
    }
    discrete_plot_range <- reactive({
      rng <- default_range()
      c(rng[1]-1,rng[2]+1)
    })
    continuous_plot_range <- reactive({
      rng <- default_range_cont()
      padding <- diff(rng)*.06
      rng+c(-padding,padding)
    })
    continuous_curve <- reactive({
      curve <- dist_df_cont(); query <- continuous_query()
      inside <- query$x >= min(curve$x) & query$x <= max(curve$x)
      extra <- data.frame(x = query$x[inside], pdf = query$pdf[inside], cdf = query$cdf[inside])
      curve <- rbind(curve, extra)
      curve <- curve[!duplicated(curve$x), ]
      curve[order(curve$x), ]
    })
    output$pmf_plot <- plotly::renderPlotly({
      df <- dist_df()
      p <- plotly::add_trace(plotly::plot_ly(),x=df$k,y=df$pmf,type="bar",width=.9,
        marker=list(color="#9ecae1"),
        hovertext=paste0("x = ",df$k,"<br>P(X = ",df$k,") ",number_reading(df$pmf)),
        hoverinfo="text")
      linked_plot(p,"cdf_plot","bar","#9ecae1",discrete_plot_range(),"Probability")
    })
    output$cdf_plot <- plotly::renderPlotly({
      # Include the next integer so reading the right plot boundary is exact.
      df <- discrete_data(extra=1);rng <- discrete_plot_range()
      # The hoverable trace contains only included (closed) CDF endpoints.
      # Open endpoints are visual aids and must never report F(k-1) as F(k).
      p <- plotly::plot_ly(x=df$k,y=df$cdf,type="scatter",mode="markers",
        marker=list(size=6,color="#238b45"),cliponaxis=FALSE,
        hovertext=paste0("x = ",df$k,"<br>F(",df$k,") = P(X ≤ ",df$k,") ",number_reading(df$cdf)),
        hoverinfo="text")
      starts <- c(rng[1],df$k);ends <- c(df$k,rng[2]);heights <- c(0,df$cdf)
      p <- plotly::add_trace(p,x=as.vector(rbind(starts,ends,NA_real_)),
        y=as.vector(rbind(heights,heights,NA_real_)),type="scatter",mode="lines",
        line=list(color="#238b45",width=2),hoverinfo="skip",inherit=FALSE)
      p <- plotly::add_trace(p,x=df$k,y=c(0,head(df$cdf,-1)),type="scatter",mode="markers",
        marker=list(size=6,color="#238b45",symbol="circle-open"),cliponaxis=FALSE,hoverinfo="skip",inherit=FALSE)
      reading <- list(k=as.list(df$k),probability=as.list(df$pmf),cumulative=as.list(df$cdf),
        probabilityText=as.list(number_reading(df$pmf)),cumulativeText=as.list(number_reading(df$cdf)))
      linked_plot(p,"pmf_plot","point","#238b45",rng,"Cumulative probability",reading=reading)
    })
    output$pdf_plot_cont <- plotly::renderPlotly({
      df <- continuous_curve(); rng <- default_range_cont(); query <- continuous_query()
      values <- ifelse(is.finite(df$pdf), df$pdf, NA_real_)
      finite <- is.finite(query$pdf)
      p <- plotly::plot_ly(x = query$x[finite], y = query$pdf[finite], type = "scatter", mode = "markers",
        marker = list(color = "#d88b00", size = 6, opacity = 0),
        hovertext = paste0("x = ", query$labels[finite], "<br>Density f(x) ", number_reading(query$pdf[finite]),
          "<br>Density is not P(X = x)."), hoverinfo = "text")
      p <- plotly::add_trace(p, x = df$x, y = values, type = "scatter", mode = "lines",
        line = list(color = "#d88b00", width = 2),
        fill = "tozeroy", fillcolor = "rgba(255,184,28,.2)", hoverinfo = "skip", inherit = FALSE)
      if (continuous_key() == "unif") {
        p <- plotly::add_trace(p, x = c(rng[1], rng[1], NA, rng[2], rng[2]),
          y = c(0, values[1], NA, tail(values, 1), 0), type = "scatter", mode = "lines",
          line = list(color = "#d88b00", width = 2), hoverinfo = "skip", inherit = FALSE)
      }
      p <- linked_plot(p, "cdf_plot_cont", "curve", "#d88b00", continuous_plot_range(), "Density", FALSE,
        reading = query$reading)
      if (any(!is.finite(df$pdf))) p <- plotly::layout(p, margin = list(l=62,r=18,t=18,b=82),
        annotations = list(list(x=0,y=-.23,xref="paper",yref="paper",showarrow=FALSE,xanchor="left",
          text="Unbounded endpoint density is omitted.<br>Use the CDF to read probabilities.",font=list(size=10))))
      p
    })
    output$cdf_plot_cont <- plotly::renderPlotly({
      df <- continuous_curve(); query <- continuous_query()
      p <- plotly::plot_ly(x = query$x, y = query$cdf, type = "scatter", mode = "markers",
        marker = list(color = "#d94b26", size = 6, opacity = 0),
        hovertext = paste0("x = ", query$labels, "<br>F(x) = P(X ≤ x) ",
          number_reading(query$cdf)), hoverinfo = "text")
      p <- plotly::add_trace(p, x = df$x, y = df$cdf, type = "scatter", mode = "lines",
        line = list(color = "#d94b26", width = 2), hoverinfo = "skip", inherit = FALSE)
      linked_plot(p, "pdf_plot_cont", "curve", "#d94b26", continuous_plot_range(), "Cumulative probability",
        reading = query$reading)
    })

    #================================================
    # Distribution description
    #================================================
    
    # Discrete distribution description
    output$dist_desc <- renderUI({
      if (discrete_key() == "bern") {
        HTML("
        <b>Bernoulli Distribution</b><br>
        A <b>Bernoulli</b> random variable X has only two possible values, 0 (failure) and 1 (success).<br>
        X ~ Bernoulli(p) means P(X = 1) = p and P(X = 0) = 1 − p, where p is the success probability.")
      } else if (discrete_key() == "binom") {
        HTML("
        <b>Binomial Distribution</b><br>
        Let <em>X</em> be the number of successes in <em>n</em> independent Bernoulli trials,
        each with success probability <em>p</em>. Then <em>X</em> has the <b>Binomial</b> (Bin) distribution
        with parameters <em>n</em> and <em>p</em>. We write
        <em>X ~ Binomial(n, p)</em> (or <em>X ~ Bin(n, p)</em>).<br>
        Thus, the binomial distribution counts the number of successes in a fixed number of Bernoulli trials.
        ")
      } else if (discrete_key() == "nbinom") {
        HTML("
        <b>Negative Binomial Distribution</b><br>
        Let <em>X</em> be the number of failures before the <em>k</em>-th success occurs 
        in a sequence of independent Bernoulli trials, each with success probability <em>p</em>. 
        Then <em>X</em> has the <b>Negative Binomial</b> (NegBin) distribution with parameters <em>k</em> and <em>p</em>,
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
        Then <em>X</em> has the <b>Hypergeometric</b> (HYP) distribution with parameters
        <em>n</em>, <em>M</em>, and <em>N</em>, and we write <em>X ~ HYP(n, M, N)</em> 
        (or <em>X ~ Hypergeometric(n, M, N)</em>).<br><br>
        The support is <em>x = max(0, n - N + M), ..., min(n, M)</em>.
        ")
      } else if (discrete_key() == "dunifd") {
        HTML("
        <b>Discrete Uniform Distribution</b><br>
        Here <em>N</em> is the number of possible values. The <b>discrete uniform</b> (DU) distribution
        <em>X ~ DU(N)</em> assigns probability <em>1/N</em> to each integer in {1, 2, …, N}.
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
        A continuous <b>Uniform distribution</b> has constant density between the lower bound <em>a</em>
        and upper bound <em>b</em>, with <em>a &lt; b</em>.<br>
        We write <em>X ~ Uniform(a, b)</em> (or <em>X ~ U(a, b)</em>).<br>
        The density is zero outside the interval. Equal-length subintervals within the bounds have equal probability.
        ")
      } else if (continuous_key() == "exp") {
        HTML("
        <b>Exponential Distribution</b><br>
        An <b>Exponential distribution</b> models the waiting time between successive events in a Poisson process.
        The rate <em>λ &gt; 0</em> is the expected event count per unit time, and the mean waiting time is <em>1/λ</em>.
        We write <em>X ~ Exp(λ)</em>.
        ")
      } else if (continuous_key() == "gamma") {
        HTML("
        <b>Gamma Distribution</b><br>
        The <b>Gamma(k, λ)</b> distribution has shape <em>k &gt; 0</em> and rate <em>λ &gt; 0</em>.<br><br>
        For a positive integer shape <em>k</em>, it is the sum of <em>k</em> independent Exponential(λ) random variables. The Gamma density also permits any real shape k &gt; 0:<br>
        If <em>X<sub>1</sub>, …, X<sub>k</sub> ~ Exponential(λ)</em> are independent, then<br>
        <em>X<sub>1</sub> + X<sub>2</sub> + ··· + X<sub>k</sub> ~ Gamma(k, λ)</em>.<br><br>
        <b>Special Case:</b> When k = 1, Gamma(1, λ) = Exponential(λ).<br>
        ")
      } else if (continuous_key() == "norm") {
        HTML("
        <b>Normal Distribution</b><br>
        The <b>Normal distribution</b> has a bell-shaped density centred at the mean <em>μ</em>.
        The standard deviation <em>σ &gt; 0</em> controls the spread, and <em>σ²</em> is the variance.<br>
        We write <em>X ~ Normal(μ, σ²)</em>.
        ")
      } else if (continuous_key() == "beta") {
        HTML("
        <b>Beta Distribution</b><br>
        A random variable <em>X</em> has a <b>Beta distribution</b> with shape parameters
        <em>α &gt; 0</em> and <em>β &gt; 0</em> if it is supported on (0,1) with density proportional to
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
  <li><b>PMF</b>: $$f_X(x)=\\begin{cases}
      p, & x=1 \\\\
      1-p, & x=0 \\\\
      0, & \\text{otherwise}
    \\end{cases}$$</li>

  <li><b>CDF</b>: $$F_X(x)=\\begin{cases}
      0, & x<0 \\\\
      1-p, & 0 \\le x < 1 \\\\
      1, & x \\ge 1
    \\end{cases}$$</li>

  <li><b>Mean</b>: $$\\mathbb{E}[X]=0\\times(1-p)+1\\times p = p$$</li>

  <li><b>Variance</b>: $$\\text{Var}(X)=\\mathbb{E}[X^2]-(\\mathbb{E}[X])^2
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
