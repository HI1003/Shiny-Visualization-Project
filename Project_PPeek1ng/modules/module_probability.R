# ============================================================
# Module: Probability Distribution UI
# ============================================================

# ---- Load Required Packages ----
library(shiny)
library(ggplot2)
library(latex2exp)

# ---- UI Module Definition ----
prob_UI <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    tags$head(tags$style(HTML('body {font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, "Noto Sans", "Apple Color Emoji", "Segoe UI Emoji";} .small-note{color:#666;font-size:12px}'))),
    titlePanel("Probability Distributions"),
    sidebarLayout(
      sidebarPanel(
        withMathJax(HTML("<h4>Discrete and Continuous</h4>")),
        
        radioButtons(
          inputId = ns("dist_type"),
          label   = "There are two major classes of probability distributions.",
          choices = c("Discrete" = "discrete", "Continuous" = "continuous"),
          selected = "discrete",
          inline = TRUE
        ),
        
        #================================================
        # Discrete Sidebar
        #================================================
        conditionalPanel(
          condition = paste0("input['", ns('dist_type'), "'] == 'discrete'"),
          withMathJax(HTML("
            <p>
              A discrete random variable \\(X\\) is called <em>discrete</em> if its set of possible values is finite or countably infinite.
              For a discrete random variable, there exist unique nonnegative functions: the
              <span style='color:#2171b5;font-weight:bold;'>probability mass function</span> (PMF) \\(f_X(x)\\) and the
              <span style='color:#238b45;font-weight:bold;'>cumulative distribution function</span> (CDF) \\(F_X(x)\\), defined by
            </p>
            <ul>
              <li>\\( f_X(x) = P(X = x) \\)</li>
              <li>\\( F_X(x) = P(X \\le x) ; -\\infty < x < \\infty \\)</li>
            </ul>
            <p>
              Choose one of the following major discrete distributions to visualize. The <span style='color:#2171b5;font-weight:bold;'>PMF</span> is shown in 
              <span style='color:#2171b5;font-weight:bold;'>blue</span> and the <span style='color:#238b45;font-weight:bold;'>CDF</span> in 
              <span style='color:#238b45;font-weight:bold;'>green</span>.
            </p>
          ")),
          
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
            sliderInput(ns("p_bern"), "p", min = 0, max = 1, value = 0.50, step = 0.01)
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
            sliderInput(ns("lambda"), "λ", min = 0.01, max = 10, value = 5, step = 0.1)
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
          ),
          
          hr(),
          uiOutput(ns("dist_desc")),
          h4("Formula"),
          withMathJax(uiOutput(ns("formula"))),
          hr(),
          helpText("Click on the graph to highlight a value x, and the panel will display P(X = x) and F(x) = P(X ≤ x)")
        ),
        
        #================================================
        # Continuous Sidebar
        #================================================
        conditionalPanel(
          condition = paste0("input['", ns('dist_type'), "'] == 'continuous'"),
          withMathJax(HTML("
    <p>
      A continuous random variable \\(X\\) is called <em>continuous</em> if it can take values in an interval on the real line.
      For a continuous random variable, there exist functions: the
      <span style='color:#ffb81c;font-weight:bold;'>probability density function</span> (PDF) \\(f_X(x)\\) and the
      <span style='color:#ff5722;font-weight:bold;'>cumulative distribution function</span> (CDF) \\(F_X(x)\\), defined by
    </p>
    <ul>
      <li>\\( f_X(x) = \\frac{d}{dx} F_X(x) \\)</li>
      <li>\\( F_X(x) = \\mathbb{P}(X \\le x) = \\int_{-\\infty}^x f_X(t) dt \\)</li>
    </ul>
    <p>
      Choose one of the following major continuous distributions to visualize. 
      The <span style='color:#ffb81c;font-weight:bold;'>PDF</span> is shown in <span style='color:#ffb81c;'>yellow</span> 
      and the <span style='color:#ff5722;font-weight:bold;'>CDF</span> in <span style='color:#ff5722;'>orange</span>.
    </p>
  ")),
          
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
            sliderInput(ns("b_unif"), "b", min =   0, max = 10, value =  5, step = 0.01)
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
            sliderInput(ns("mean_norm"), "μ", min = -10, max = 10, value = 0, step = 0.01),
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
          ),
          
          hr(),
          uiOutput(ns("dist_desc_cont")),
          h4("Formula"),
          withMathJax(uiOutput(ns("formula_cont"))),
          hr(),
          helpText("Click on the graph to highlight a value x, and the panel will display P(X = x) and F(x) = P(X ≤ x)")
        )
      ),
      
      #================================================
      # Right plot main panel
      #================================================
      mainPanel(
        # Discrete Plot
        conditionalPanel(
          condition = paste0("input['", ns('dist_type'), "'] == 'discrete'"),
          fluidRow(
            column(6,
                   withMathJax(HTML("<h4>PMF: f<sub>X</sub>(x) = ℙ(X = x)</h4>")),
                   plotOutput(ns("pmf_plot"), height = 360, click = ns("click_pmf"))
            ),
            column(6,
                   withMathJax(HTML("<h4>CDF: F<sub>X</sub>(x) = ℙ(X ≤ x)</h4>")),
                   plotOutput(ns("cdf_plot"), height = 360, click = ns("click_cdf"))
            )
          ),
          fluidRow(
            column(12, h4("Current Selection"), verbatimTextOutput(ns("sel_text")))
          )
        ),
        
        # Continuous graph
        conditionalPanel(
          condition = paste0("input['", ns('dist_type'), "'] == 'continuous'"),
          fluidRow(
            column(6, 
                   withMathJax(HTML("<h4>PDF: \\( f_X(x) = \\frac{d}{dx} F_X(x) \\)</h4>")),
                   plotOutput(ns("pdf_plot_cont"), height = 360, click = ns("click_pdf_cont"))
            ),
            column(6, 
                   withMathJax(HTML("<h4>CDF: F<sub>X</sub>(x) = ℙ(X ≤ x)</h4>")),
                   plotOutput(ns("cdf_plot_cont"), height = 360, click = ns("click_cdf_cont"))
            )
          ),
          fluidRow(
            column(12, h4("Current Selection"), verbatimTextOutput(ns("sel_text_cont")))
          )
        )
      )
    )
  )
}

prob_Server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    #================================================
    # default range
    #================================================
    default_range <- reactive({
      switch(input$dist,
             bern = c(0, 1),
             binom = c(0, input$n),
             nbinom = {
               r <- input$r_nb
               p <- max(0.001, min(0.999, input$p_nb))
               mu <- r * (1 - p) / p
               sigma <- sqrt(r * (1 - p) / (p^2))     # Var = r(1-p)/p^2
               lo <- max(0, floor(mu - 6 * sigma))
               hi <- ceiling(mu + 6 * sigma)
               c(lo, max(lo + 10, hi))
             },
             geom = {
               p <- max(0.001, min(0.999, input$pg))
               kmax <- ceiling(log(1 - 0.999) / log(1 - p)-1)
               c(0, max(10, kmax))
             },
             pois  = {
               mu <- input$lambda
               lo <- max(0, floor(mu - 6 * sqrt(mu)))
               hi <- ceiling(mu + 6 * sqrt(mu))
               c(lo, hi)
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
      switch(input$dist_cont,
             unif = {
               a <- input$a_unif; b <- input$b_unif
               if (!is.null(a) && !is.null(b) && a >= b) b <- a + 1e-6
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
          
          if (input$dist == "bern") {
            k <- 0:1
            p <- input$p_bern
            pmf <- ifelse(k == 1, p, 1 - p)
            cdf <- cumsum(pmf)
            mean_val <- p
            
          } else if (input$dist == "binom") {
            k <- seq(rng[1], rng[2])
            pmf <- dbinom(k, size = input$n, prob = input$p)
            cdf <- pbinom(k, size = input$n, prob = input$p)
            mean_val <- input$n * input$p
            
          } else if (input$dist == "nbinom") {
            k <- seq(max(0, rng[1]), max(0, rng[2]))
            p <- max(0.001, min(0.999, input$p_nb))
            pmf <- dnbinom(k, size = input$r_nb, prob = p)
            cdf <- pnbinom(k, size = input$r_nb, prob = p)
            mean_val <- input$r_nb * (1 - p) / p
            
          } else if (input$dist == "geom") {
            k <- seq(max(0, rng[1]), max(0, rng[2]))
            p <- max(0.001, min(0.999, input$pg))
            pmf <- dgeom(k, prob = p)
            cdf <- pgeom(k, prob = p)
            mean_val <- (1 - p) / p
            
          } else if (input$dist == "pois") {
            k <- seq(rng[1], rng[2])
            pmf <- dpois(k, lambda = input$lambda)
            cdf <- ppois(k, lambda = input$lambda)
            mean_val <- input$lambda
            
          } else if (input$dist == "hyper") {
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
          
          if (input$dist_cont == "unif") {
            a <- input$a_unif; b <- input$b_unif
            if (!is.null(a) && !is.null(b) && a >= b) b <- a + 1e-6
            pdf <- dunif(x, min = a, max = b)
            cdf <- punif(x, min = a, max = b)
          } else if (input$dist_cont == "exp") {
            pdf <- dexp(x, rate = input$rate_exp)
            cdf <- pexp(x, rate = input$rate_exp)
          } else if (input$dist_cont == "gamma") {
            pdf <- dgamma(x, shape = input$shape_gam, rate = input$rate_gam)
            cdf <- pgamma(x, shape = input$shape_gam, rate = input$rate_gam)
          } else if (input$dist_cont == "norm") {
            pdf <- dnorm(x, mean = input$mean_norm, sd = input$sd_norm)
            cdf <- pnorm(x, mean = input$mean_norm, sd = input$sd_norm)
          } else if (input$dist_cont == "beta") {
            pdf <- dbeta(x, shape1 = input$alpha_beta, shape2 = input$beta_beta)
            cdf <- pbeta(x, shape1 = input$alpha_beta, shape2 = input$beta_beta)
          } else if (input$dist_cont == "chisq") {
            pdf <- dchisq(x, df = input$df_chi)
            cdf <- pchisq(x, df = input$df_chi)
          } else if (input$dist_cont == "t") {
            pdf <- dt(x, df = input$df_t)
            cdf <- pt(x, df = input$df_t)
          } else if (input$dist_cont == "f") {
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
    observeEvent(dist_df(), ignoreInit = TRUE, {
      df <- dist_df()
      selected_k(df$k[which.max(df$pmf)])
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
    
    observeEvent(dist_df_cont(), ignoreInit = TRUE, {
      rng <- default_range_cont()
      selected_x_cont(mean(rng))
    })
    
    output$sel_text <- renderText({
      df <- dist_df()
      k_sel <- selected_k()
      if (is.null(k_sel) || !(k_sel %in% df$k))
        return("You can select any x in the figure to highlight it")
      p <- df$pmf[df$k == k_sel]
      Fk <- df$cdf[df$k == k_sel]
      sprintf("x = %d\nP(X = %d) = %.6f\nF(%d) = P(X ≤ %d) = %.6f",
              k_sel, k_sel, p, k_sel, k_sel, Fk)
    })
    
    #================================================
    # Calculate the PDF/CDF of the current continuous distribution
    #================================================
    pdf_cdf_at_cont <- function(x0) {
      d <- input$dist_cont
      out_pdf <- NA_real_; out_cdf <- NA_real_
      
      switch(d,
             unif = {
               a <- input$a_unif; b <- input$b_unif
               if (!is.null(a) && !is.null(b) && a >= b) b <- a + 1e-6
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
          "x = %.4f\n",
          "fX(%.4f) = %.6f\n",
          "F(%.4f) = P(X ≤ %.4f) = %.6f"
        ),
        x_sel, x_sel, vals$pdf, x_sel, x_sel, vals$cdf
      )
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
      x_min <- if (input$dist == "bern") -1 else -3
      
      g <- ggplot(df, aes(k, pmf)) +
        geom_col(width = 0.9, fill = "#9ecae1") +
        scale_x_continuous(
          limits = c(x_min, rng[2] + 1.5),
          breaks = seq(x_min, rng[2], by = 1)
        ) +
        scale_y_continuous(limits = c(0, 1)) +
        labs(x = "x", y = "Probability") +
        theme_minimal(base_size = 13) +
        theme(panel.grid.minor = element_blank())
      
      if (!is.null(k_sel) && k_sel %in% df$k) {
        g <- g +
          geom_col(data = subset(df, k == k_sel), aes(k, pmf), fill = "#2171b5") +
          annotate("text", x = k_sel, y = p_sel,
                   label = sprintf("x=%d\nP=%.4f", k_sel, p_sel),
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
      x_min <- if (input$dist == "bern") -1 else -3
      
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
          breaks = seq(x_min, rng[2], by = 1)
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
                   label = sprintf("F(%d)=%.4f", k_sel, F_sel),
                   vjust = -0.8, size = 4, color = "#238b45")
      }
      g
    })
    
    # ---- Continuous PDF plot ----
    output$pdf_plot_cont <- renderPlot({
      df <- dist_df_cont()
      rng <- default_range_cont()
      
      if (input$dist_cont == "unif") {
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
        g <- ggplot(df, aes(x, pdf)) +
          geom_area(fill = "#ffb81c", alpha = 0.3) +
          geom_line(color = "#ffb81c", linewidth = 1.2) +
          scale_x_continuous(limits = c(rng[1] - 1, rng[2] + 1),
                             breaks = pretty(c(rng[1], rng[2]), n = 8)) +
          scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
          labs(x = "x", y = "Density") +
          theme_minimal(base_size = 13) +
          theme(panel.grid.minor = element_blank())
      }
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
      if (input$dist == "bern") {
        HTML("
        <b>Bernoulli Distribution</b><br>
        A random variable Y is called a <b>Bernoulli</b> random variable if it has only two possible values, 0 and 1.<br>
        Y ~ Bernoulli(p) means P(Y = 1) = p and P(Y = 0) = 1 − p, where p is the parameter of the distribution.")
      } else if (input$dist == "binom") {
        HTML("
        <b>Binomial Distribution</b><br>
        Let <em>X</em> be the number of successes in <em>n</em> independent Bernoulli trials,
        each with success probability <em>p</em>. Then <em>X</em> has the <b>Binomial</b> distribution
        with parameters <em>n</em> and <em>p</em>. We write
        <em>X ~ Binomial(n, p)</em> (or <em>X ~ Bin(n, p)</em>).<br>
        Thus, the binomial distribution counts the number of successes in a fixed number of Bernoulli trials.
        ")
      } else if (input$dist == "nbinom") {
        HTML("
        <b>Negative Binomial Distribution</b><br>
        Let <em>X</em> be the number of failures before the <em>k</em>-th success occurs 
        in a sequence of independent Bernoulli trials, each with success probability <em>p</em>. 
        Then <em>X</em> has the <b>Negative Binomial</b> distribution with parameters <em>k</em> and <em>p</em>, 
        and we write <em>X ~ NegBin(k, p)</em>.<br>
        ")
      } else if (input$dist == "geom") {
        HTML("
        <b>Geometric Distribution</b><br>
        Let <em>X</em> be the number of failures before the first success occurs 
        in a sequence of independent Bernoulli trials, each with probability of success <em>p</em> on a single trial. 
        Then <em>X</em> has the <b>Geometric</b> distribution with parameter <em>p</em>, 
        and we write <em>X ~ Geometric(p)</em>.
        ")
      } else if (input$dist == "pois") {
        HTML("
        <b>Poisson Distribution</b><br>
        A discrete random variable <em>X</em> is said to have a <b>Poisson</b> distribution with parameter 
        <em>&lambda; &gt; 0</em>. The parameter <em>&lambda;</em> represents the average rate of occurrence of events 
        in a fixed interval of time or space. The Poisson distribution is commonly used to model the number of 
        arrivals, occurrences, or events happening independently at a constant rate. For this distribution, the 
        mean and variance are both equal to <em>&lambda;</em>.
        ")
      } else if (input$dist == "hyper") {
        HTML("
        <b>Hypergeometric Distribution</b><br>
        Let <em>X</em> be the number of “successes” in <em>n</em> draws without replacement 
        from a finite population of size <em>N</em>, of which <em>M</em> are “successes”. 
        Then <em>X</em> has the <b>Hypergeometric</b> distribution with parameters 
        <em>n</em>, <em>M</em>, and <em>N</em>, and we write <em>X ~ HYP(n, M, N)</em> 
        (or <em>X ~ Hypergeometric(n, M, N)</em>).<br><br>
        The support is <em>x = max(0, n - N + M), ..., min(n, M)</em>.
        ")
      } else if (input$dist == "dunifd") {
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
      if (input$dist_cont == "unif") {
        HTML("
        <b>Uniform Distribution</b><br>
        A random variable <em>X</em> is said to have a <b>Uniform distribution</b> 
        on the interval <em>(a, b)</em> if it is equally likely to take any value in that interval.<br>
        We write <em>X ~ Uniform(a, b)</em> (or <em>X ~ U(a, b)</em>).<br>
        The pdf is constant over the interval and zero otherwise.
        ")
      } else if (input$dist_cont == "exp") {
        HTML("
        <b>Exponential Distribution</b><br>
        A random variable <em>X</em> has an <b>Exponential distribution</b> with rate parameter 
        <em>λ > 0</em> if it models the waiting time between independent events occurring at rate λ.<br>
        We write <em>X ~ Exp(λ)</em>.<br>
        ")
      } else if (input$dist_cont == "gamma") {
        HTML("
        <b>Gamma Distribution</b><br>
        The <b>Gamma(k, λ)</b> distribution is a flexible family of distributions.<br><br>
        It can be defined as the sum of <em>k</em> independent Exponential(λ) random variables:<br>
        If <em>X<sub>1</sub>, …, X<sub>k</sub> ~ Exponential(λ)</em> are independent, then<br>
        <em>X<sub>1</sub> + X<sub>2</sub> + ··· + X<sub>k</sub> ~ Gamma(k, λ)</em>.<br><br>
        <b>Special Case:</b> When k = 1, Gamma(1, λ) = Exponential(λ).<br>
        ")
      } else if (input$dist_cont == "norm") {
        HTML("
        <b>Normal Distribution</b><br>
        A random variable <em>X</em> is said to have a <b>Normal distribution</b> 
        with mean <em>μ</em> and variance <em>σ²</em> if its pdf is bell-shaped and symmetric about μ.<br>
        We write <em>X ~ Normal(μ, σ²)</em>.<br>
        ")
      } else if (input$dist_cont == "beta") {
        HTML("
        <b>Beta Distribution</b><br>
        A random variable <em>X</em> has a <b>Beta distribution</b> with parameters 
        <em>α > 0</em> and <em>β > 0</em> if it is supported on (0,1) with pdf proportional to 
        <em>x<sup>α−1</sup>(1−x)<sup>β−1</sup></em>.<br>
        We write <em>X ~ Beta(α, β)</em>.<br>
        ")
      } else if (input$dist_cont == "chisq") {
        HTML("
        <b>Chi-Squared Distribution</b><br>
        A random variable <em>X</em> has a <b>Chi-squared distribution</b> with 
        <em>ν</em> degrees of freedom if it is the sum of squares of ν independent standard normal variables.<br>
        We write <em>X ~ χ²(ν)</em>.<br>
        ")
      } else if (input$dist_cont == "t") {
        HTML("
        <b>Student's t Distribution</b><br>
        A random variable <em>X</em> has a <b>t distribution</b> with <em>ν</em> degrees of freedom 
        if it is the ratio of a standard normal variable to the square root of a chi-squared variable 
        (scaled by its degrees of freedom).<br>
        We write <em>X ~ t(ν)</em>.<br>
        ")
      } else if (input$dist_cont == "f") {
        HTML("
        <b>F Distribution</b><br>
        A random variable <em>X</em> has an <b>F distribution</b> with 
        <em>d₁</em> and <em>d₂</em> degrees of freedom if it is the ratio of two scaled chi-squared variables.<br>
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
      withMathJax(HTML(spec[[input$dist]]))
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
      
      withMathJax(HTML(spec[[input$dist_cont]]))
    })
  })   
}   
