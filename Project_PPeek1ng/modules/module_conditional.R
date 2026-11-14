# =====================================================================
#  module_conditional.R — Conditional Distribution Module
# =====================================================================
# ---- Helper: MathJax (v2) ----
conditional_mathjax <- tags$head(
  # 使用 MathJax v2 并允许在 renderUI 动态刷新
  tags$script(type = "text/x-mathjax-config", HTML("
    MathJax.Hub.Config({
      tex2jax: { inlineMath: [['\\\\(','\\\\)'], ['$', '$']] },
      'HTML-CSS': { scale: 100 }
    });
  ")),
  tags$script(src = "https://cdn.jsdelivr.net/npm/mathjax@2/MathJax.js?config=TeX-AMS_HTML")
)

# ---- Helper: CSS ----
conditional_css <- tags$head(tags$style(HTML("
.pmf-table { border-collapse: collapse; margin-top: 10px; }
.pmf-table th, .pmf-table td {
  border: 1.6px solid #333; padding: 6px 10px; text-align: center;
}
.pmf-table th.corner { font-style: italic; white-space: nowrap; }
.pmf-table .sumcell { font-weight: 600; background:#fafafa; }
")))


# ---- Shared probability parsing and validation ----
# main.R loads pmf_helpers.R before this module; direct module tests must do so too.

simp_frac <- function(x, tol = 1e-12, max_den = 500) {
  if (is.na(x) || !is.finite(x)) return("?")
  for (den in 1:max_den) {
    num <- round(x * den)
    if (num == 0 && x != 0) next
    if (abs(num / den - x) < tol) return(paste0(num, "/", den))
  }
  format(signif(x, 10), scientific = FALSE, trim = TRUE)
}

to_tex_frac <- function(s) {
  if (grepl("/", s)) {
    ab <- strsplit(s, "/", fixed = TRUE)[[1]]
    paste0("\\(\\frac{", ab[1], "}{", ab[2], "}\\)")
  } else paste0("\\(", s, "\\)")
}

# ---- 包装 HTML/MathJax 容器 ----
wrap_div <- function(id, content) {
  div(
    id = id,
    style = "padding: 8px; font-size: 16px; line-height: 1.6;",
    content
  )
}

# =====================================================================
# ✅ Flexible Answer Checker (fuzzy match for numeric / fraction / text)
# =====================================================================
# Answer validation is shared in pmf_helpers.R.
# =====================================================================
#  UI
# =====================================================================
conditional_UI <- function(id) {
  tagList(learning_table_module_ui(id,"Conditional Distribution",
    theory=withMathJax(
                 tagList(
                   h4("Conditional Probability"),
                   p("A conditional PMF describes the probability distribution of one variable when the other variable is known."),
                   
                   tags$hr(),
                   
                   h5("Definition"),
                   p("The conditional PMFs are defined as:"),
                   HTML("$$f_{X|Y}(x|y) = \\frac{f_{X,Y}(x,y)}{f_Y(y)}, \\quad \\text{for } f_Y(y) > 0$$"),
                   HTML("$$f_{Y|X}(y|x) = \\frac{f_{X,Y}(x,y)}{f_X(x)}, \\quad \\text{for } f_X(x) > 0$$"),
                   p("These formulas describe how the probability of one random variable depends on a specific value of the other."),
                   
                   tags$hr(),
                   
                   h5("Relationship with the Joint PMF"),
                   p("The joint PMF can always be written as the product of a marginal and a conditional PMF:"),
                   HTML("$$f_{X,Y}(x,y) = f_X(x)f_{Y|X}(y|x) = f_Y(y)f_{X|Y}(x|y)$$"),
                   p("Each column or row of a joint PMF table becomes a conditional distribution once it is normalized to sum to 1."),
                   
                   tags$hr(),
                   
                   h5("Finding Conditional PMFs from a Joint Table"),
                   tags$ul(
                     tags$li("Step 1 – Find the marginal distribution (either \\(f_X(x)\\) or \\(f_Y(y)\\)) by summing over the other variable."),
                     tags$li("Step 2 – Divide each joint probability in the selected row or column by the corresponding marginal value."),
                     tags$li("Step 3 – Verify that the conditional PMF sums to 1 for the conditioning variable.")
                   ),
                   p("Example: For a fixed value \\(Y = y_0\\),"),
                   HTML("$$f_{X|Y}(x|y_0) = \\frac{f_{X,Y}(x, y_0)}{\\sum_x f_{X,Y}(x, y_0)}$$"),
                   p("Similarly, for \\(X = x_0\\):"),
                   HTML("$$f_{Y|X}(y|x_0) = \\frac{f_{X,Y}(x_0, y)}{\\sum_y f_{X,Y}(x_0, y)}$$"),
                   
                   tags$hr(),
                   
                   h5("Interpretation"),
                   p("Conditional PMFs show how the distribution of one variable depends on the value of another."),
                   p("If all conditional PMFs are identical for different conditioning values, then X and Y are independent."),
                   p("Later modules will build on this to compare joint and conditional distributions more deeply.")
                 )
               ),plot_ids="plot_bird_cond"))
}
# =====================================================================
#  SERVER
# =====================================================================
conditional_Server <- function(id, shared = new_pmf_state(), course_path = function() "core", open_plot = NULL) {
  pmf_global <- shared
  moduleServer(id, function(input, output, session) {
    # --- Safeguard: ensure id column exists (wrapped in isolate) ---
    isolate({
      if (!is.null(pmf_global$df_edit) && !"id" %in% names(pmf_global$df_edit)) {
        pmf_global$df_edit$id <- seq_len(nrow(pmf_global$df_edit))
      }
      if (!is.null(pmf_global$df_final) && !"id" %in% names(pmf_global$df_final)) {
        pmf_global$df_final$id <- seq_len(nrow(pmf_global$df_final))
      }
    })
    
    ns <- session$ns
    # ==========================输入逻辑与概率表===========================================
    # ---- 初始化 ----
    init_df <- data.frame(
      x = c(0, 0, 1, 1),
      y = c(0, 1, 0, 1),
      p_input = c("188/221", "16/221", "16/221", "1/221"),
      id = 1:4,
      stringsAsFactors = FALSE
    )
    init_df$p_value <- sapply(init_df$p_input, parse_user_prob)
    
    # ---- 初始化或加载全局 ----
    isolate({
      if (is.null(pmf_global$df_edit) || !isTRUE(pmf_global$has_final)) {
        pmf_global$df_edit  <- init_df
        pmf_global$df_final <- init_df
        pmf_global$counter  <- nrow(init_df)
        pmf_global$has_final <- FALSE
      }
    })
    
    # 一旦任一模块 Generate 过（has_final=TRUE），三个模块自动用全局值。
    pmf_edit    <- reactiveVal(isolate(pmf_global$df_edit))
    pmf_final   <- reactiveVal(isolate(pmf_global$df_final))
    row_counter <- reactiveVal(isolate(pmf_global$counter))
    
    # Accept committed data after Generate; keep the dependency reactive.
    observe({
      req(isTRUE(pmf_global$has_final))
      pmf_edit(pmf_global$df_edit)
      pmf_final(pmf_global$df_final)
      row_counter(pmf_global$counter)
    })
    
    # ---- 输入区域 ----
    output$input_panel <- renderUI({
      df <- pmf_edit()
      if (is.null(df) || !"id" %in% names(df)) {
        return(tags$div(style="color:#888; padding:10px;", "Initializing table..."))
      }
      tagList(
        h4("Outcomes and probabilities"),
        helpText("Enter non-negative probabilities or weights. Generate Table merges repeated outcomes and normalizes the total to 1. Normalize changes the draft inputs only."),
        uiOutput(ns("input_feedback")),
        lapply(seq_len(nrow(df)), function(i) {
          div(class = "pmf-edit-row",
            pmf_probability_input(ns,df$id[i],df$p_input[i]),
            div(class = "pmf-edit-coordinate", numericInput(ns(paste0("x_", df$id[i])), "x", value = df$x[i])),
            div(class = "pmf-edit-coordinate", numericInput(ns(paste0("y_", df$id[i])), "y", value = df$y[i])),
            actionButton(ns(paste0("del_", df$id[i])), "Delete", class = "btn-danger btn-sm")
          )
        }),
        hr(),
        actionButton(ns("add_row"), "Add Row"),
        actionButton(ns("normalize"), "Normalize"),
        actionButton(ns("uniform"), "Uniform"),
        br(), br(),
        actionButton(ns("generate"), "Generate Table", class = "btn-primary")
      )
    })
    
    # ---- 数据反应 ----
    df_current <- reactive({
      df <- pmf_edit()
      for (i in df$id) {
        p_in <- input[[paste0("p_", i)]]
        x_in <- input[[paste0("x_", i)]]
        y_in <- input[[paste0("y_", i)]]
        df <- pmf_read_probability(df,i,p_in)
        if (!is.null(x_in)) df$x[df$id == i] <- as.numeric(x_in)
        if (!is.null(y_in)) df$y[df$id == i] <- as.numeric(y_in)
      }
      df
    })
    
    # ---- 增删改查 ----
    observeEvent(input$add_row, {
      df <- df_current()
      needed_cols  <- c("x", "y", "p_input", "p_value", "id")
      missing_cols <- setdiff(needed_cols, names(df))
      if (length(missing_cols) > 0) {
        for (col in missing_cols) {
          df[[col]] <- switch(col,
                              x = 0, y = 0, p_input = "0", p_value = 0, id = seq_len(nrow(df)))
        }
      }
      new_id <- row_counter() + 1L
      row_counter(new_id)
      new_row <- data.frame(x = 1, y = 1, p_input = "0", p_value = 0, id = new_id)
      df <- dplyr::bind_rows(df, new_row)
      
      pmf_edit(df)
      pmf_global$df_edit <- df
      pmf_global$counter <- new_id
    })
    
    observe({
      df <- pmf_edit()
      lapply(df$id, function(i) {
        observeEvent(input[[paste0("del_", i)]], {
          isolate({
            df_now <- pmf_edit()
            df_now <- df_now[df_now$id != i, ]
            pmf_edit(df_now)
            pmf_global$df_edit <- df_now
            pmf_global$counter <- row_counter()
          })
        }, ignoreInit = TRUE)
      })
    })
    
    display_mode <- reactive(number_mode(pmf_global$number_format))

    pmf_actions <- pmf_bind_actions(input, output, session, df_current, pmf_edit,
                     pmf_final, row_counter, pmf_global, module = "conditional")

    # ---- Joint + Conditional Probability Table ----
    output$joint_table_html <- renderUI({
      df <- pmf_final()
      if (is.null(df) || nrow(df) == 0) return(NULL)
      
      mat <- xtabs(p_value ~ x + y, data = df)
      xs <- as.numeric(rownames(mat))
      ys <- as.numeric(colnames(mat))
      row_tot <- rowSums(mat)
      col_tot <- colSums(mat)
      
      # --- 联合概率表 ---
      joint_html <- tags$table(
        class = "pmf-table",
        tags$thead(
          tags$tr(
            tags$th(class = "corner outer", HTML("\\(x \\backslash y\\)")),
            lapply(ys, function(y) tags$th(HTML(paste0("\\(y=", y, "\\)")))),
            tags$th(class = "sumcell", HTML("\\(f_X(x)\\)"))
          )
        ),
        tags$tbody(
          lapply(seq_along(xs), function(i) {
            xi <- xs[i]
            sub <- df[df$x == xi, ]
            tags$tr(
              tags$th(HTML(paste0("\\(x=", xi, "\\)"))),
              lapply(ys, function(yv) {
                value <- sub$p_value[sub$y == yv]
                if (!length(value)) value <- 0
                number_cell(value,display_mode())
              }),
              number_cell(row_tot[i],display_mode(),"sumcell")
            )
          }),
          tags$tr(
            tags$th(class = "sumcell", HTML("\\(f_Y(y)\\)")),
            lapply(seq_along(ys), function(j)
              number_cell(col_tot[j],display_mode(),"sumcell")
            ),
            number_cell(1,display_mode(),"sumcell")
          )
        )
      )
      
      tagList(
        withMathJax(),
        joint_html,
        tags$p(class="small-note",HTML("\\(\\sum_x \\sum_y f_{X,Y}(x,y) = 1\\)"))
      )
    })
    # ==========================输入逻辑与概率表===========================================    
    # ==========================条件概率表===========================================
    conditional_slice <- reactive({
      df <- pmf_final()
      req(input$cond_type)
      
      if (input$cond_type == "f(Y | X = x0)") {
        req(input$x0)
        x0 <- as.numeric(input$x0)
        sub <- df %>% filter(x == x0)
        total_x <- sum(sub$p_value)
        validate(need(is.finite(total_x) && total_x > 0,
                      paste0("Conditional distribution is undefined: P(X = ", x0,
                             ") must be positive.")))
        sub$cond_p <- sub$p_value / total_x
        title <- paste0("f(Y | X = ", x0, ")")
        var_col <- "y"
      } else {
        req(input$y0)
        y0 <- as.numeric(input$y0)
        sub <- df %>% filter(y == y0)
        total_y <- sum(sub$p_value)
        validate(need(is.finite(total_y) && total_y > 0,
                      paste0("Conditional distribution is undefined: P(Y = ", y0,
                             ") must be positive.")))
        sub$cond_p <- sub$p_value / total_y
        title <- paste0("f(X | Y = ", y0, ")")
        var_col <- "x"
      }
      
      list(data=sub,title=title,variable=var_col)
    })

    output$cond_table_html <- renderUI({
      slice <- conditional_slice()
      sub <- slice$data
      withMathJax(
        tags$table(
          class = "pmf-table",
          tags$thead(
            tags$tr(
              tags$th(HTML(paste0("\\(", slice$title, "\\)"))),
              tags$th(HTML("\\(Probability\\)"))
            )
          ),
          tags$tbody(
            lapply(seq_len(nrow(sub)), function(i) {
              tags$tr(
                tags$td(HTML(paste0("\\(", slice$variable, "=", sub[[slice$variable]][i], "\\)"))),
                number_cell(sub$cond_p[i],display_mode())
              )
            }),
            tags$tr(
              tags$th(class = "sumcell", HTML("\\(\\sum =\\)")),
              number_cell(sum(sub$cond_p),display_mode(),"sumcell")
            )
          )
        )
      )
    })
    # ==========================条件概率表===========================================
    # ========================== 生成条件值选择==========================================
    output$cond_value_select <- renderUI({
      df <- pmf_final()
      req(input$cond_type)
      by_x <- input$cond_type == "f(Y | X = x0)"
      id <- if (by_x) "x0" else "y0"
      values <- sort(unique(if (by_x) df$x else df$y))
      selected <- intersect(as.character(isolate(input[[id]])), as.character(values))
      selectInput(ns(id), if (by_x) "x0 =" else "y0 =", choices = values,
                  selected = if (length(selected)) selected[1] else values[1])
    })
    # ========================== 生成条件值选择==========================================  
    # Use the same conditional slice and number format as the probability table.
    output$plot_bird_cond <- renderPlotly({
      slice <- tryCatch(conditional_slice(),validation=identity)
      if(inherits(slice,"validation")) return(
        plot_ly(x=numeric(0),y=numeric(0),type="bar") %>% layout(
          xaxis=list(visible=FALSE),yaxis=list(visible=FALSE),
          annotations=list(list(text="Undefined for this condition",x=.5,y=.5,
            xref="paper",yref="paper",showarrow=FALSE,font=list(size=14))),
          plot_bgcolor="#ffffff",paper_bgcolor="#ffffff",showlegend=FALSE))
      sub <- slice$data
      labels <- number_label(sub$cond_p,display_mode())
      exact <- mapply(number_same,sub$cond_p,vapply(labels,parse_user_prob,numeric(1)))
      labels <- paste0(ifelse(exact,"","\u2248 "),labels)
      hover_text <- paste0(slice$variable,"=",sub[[slice$variable]],
                           "<br>",slice$title," = ",labels)
      plot_width <- session$clientData[[paste0("output_",ns("plot_bird_cond"),"_width")]]
      if(is.null(plot_width) || plot_width<=0) plot_width <- 600
      label_size <- min(13,floor(((plot_width-75)/nrow(sub)-6)/(max(nchar(labels))*.6)))
      plot_ly(
        x=sub[[slice$variable]],y=sub$cond_p,type="bar",
        marker=list(color=if(slice$variable=="y") "steelblue" else "#d87819"),
        text=labels,texttemplate="%{text}",textposition=if(label_size>=10) "outside" else "none",
        textfont=list(size=max(8,label_size)),cliponaxis=FALSE,
        hovertext=hover_text,hoverinfo="text"
      ) %>% layout(
        title=list(text=slice$title,font=list(size=14)),
        xaxis=list(title=toupper(slice$variable),tickmode="array",tickvals=sub[[slice$variable]],
                   fixedrange=TRUE),
        yaxis=list(title="Conditional probability",range=c(0,1.12),
                   tickvals=c(0,.25,.5,.75,1),fixedrange=TRUE),
        margin=list(l=60,r=15,b=45,t=40),
        plot_bgcolor="#ffffff",paper_bgcolor="#ffffff",showlegend=FALSE
      ) %>% config(displaylogo=FALSE,
        modeBarButtonsToRemove=c("select2d","lasso2d","autoScale2d","resetScale2d"))
    })

    # ============================================================
    # 题库 
    # ============================================================
    
    get_condition_question_bank <- function() {
      list(
        list(
          id = 1,
          story = HTML("
    <h4>🌽 Problem 1</h4>
    <p>Every morning on your uncle’s corn farm, he tells you how many rows of corn to inspect that day.</p>
    <p>Let \\(X\\) denote the number of rows selected for inspection. For each row, you randomly select one plant and record whether it shows signs of insect damage.</p>
    <p>Assume that each plant has a damage probability of 0.2, independently of all others. Let \\(Y\\) be the total number of damaged plants found that day.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Once we condition on \\(\\{X=x\\}\\), what is the conditional distribution of \\(Y\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          ans_text = "Binomial",
          ans_frac = NA,
          ans_val  = NA,
          
          hint1 = HTML("
    Given \\(X=x\\), there are \\(x\\) independent Bernoulli trials (each plant).  
    Think: what named distribution counts the number of successes in \\(x\\) trials?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    For fixed \\(X=x\\), the number of damaged plants follows a Binomial distribution with parameters \\(n=x,\\;p=0.2\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Conditioning on \\(X=x\\) fixes the number of inspected rows.  
    Each row contributes one independent Bernoulli(0.2) trial (damage = success).  
    Hence:
    \\[
      Y\\mid X=x \\sim Binomial(n=x,\\,p=0.2).
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 2,
          story = HTML("
    <h4>🌽 Problem 2</h4>
    <p>Under the same farm setting, suppose that the number of rows selected for inspection is fixed at \\(X=5\\).</p>
    <p>Each plant in a row independently has a 0.2 probability of being damaged.</p>
    <p>You want to know the probability that at least one damaged plant is found that day.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Compute the conditional probability \\(P(Y\\ge1\\mid X=5)\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = 0.67232,
          
          hint1 = HTML("
    Recall that if \\(Y\\mid X=5\\sim Binomial(5,0.2)\\), then  
    \\(P(Y\\ge1\\mid X=5)=1-P(Y=0\\mid X=5)\\).  
    What is \\(P(Y=0\\mid X=5)\\) for a Binomial distribution?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    \\[
      P(Y=0\\mid X=5)=(1-0.2)^5=0.32768,\\quad
      P(Y\\ge1\\mid X=5)=1-0.32768=0.67232.
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given \\(X=5\\), we have \\(Y\\mid X=5\\sim Binomial(5,0.2)\\).<br><br>
    The probability of finding at least one damaged plant is:
    \\[
      P(Y\\ge1\\mid X=5)=1-P(Y=0\\mid X=5)
      =1-(1-0.2)^5=1-0.32768=0.67232.
    \\]
    <b>Therefore, the conditional probability is approximately 0.6723.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 3,
          story = HTML("
    <h4>🐔 Problem 3</h4>
    <p>You are helping your uncle collect eggs from the chicken coop each morning.</p>
    <p>The number of eggs laid per hour depends on the weather condition that day:</p>
    <ul>
      <li>On a <b>sunny</b> day: rate = 4 eggs/hour.</li>
      <li>On a <b>cloudy</b> day: rate = 2 eggs/hour.</li>
    </ul>
    <p>Let \\(Y\\) denote the total number of eggs collected in 6 hours, and \\(W\\) the weather condition (Sunny or Cloudy). Given the weather, assume arrivals form a Poisson process with the stated constant rate.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Once we condition on the weather \\(W\\), what is the conditional distribution of \\(Y\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          ans_text = "Poisson",
          ans_frac = NA,
          ans_val  = NA,
          
          hint1 = HTML("
    Recall: a Poisson process with rate \\(\\lambda\\) per hour over \\(t\\) hours gives \\(Y\\sim Poisson(\\lambda t)\\).
    <br>How do the two weather conditions change \\(\\lambda\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    When Sunny: \\(\\lambda=4\\) per hour for 6 hours → \\(Poisson(24)\\).<br>
    When Cloudy: \\(\\lambda=2\\) per hour for 6 hours → \\(Poisson(12)\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given weather condition \\(W\\):<br>
    \\[
      Y\\mid W=Sunny \\sim Poisson(6\\times4)=Poisson(24), \\quad
      Y\\mid W=Cloudy \\sim Poisson(6\\times2)=Poisson(12).
    \\]
    The conditional distribution is Poisson, but the rate parameter depends on the weather.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 4,
          story = HTML("
    <h4>🐔 Problem 4</h4>
    <p>On a cloudy day, you continue collecting eggs from the chicken coop for 6 hours.</p>
    <p>The egg-laying rate on cloudy days is 2 eggs per hour, so the total number of eggs collected, \\(Y\\), follows a Poisson distribution with mean \\(6\\times2=12\\).</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Compute the probability of collecting no more than 10 eggs:<br>
    \\(P(Y\\le10\\mid W=\\text{Cloudy})\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = ppois(10, lambda = 12),
          
          hint1 = HTML("
    Given \\(Y\\mid W=\\text{Cloudy}\\sim Poisson(12)\\).  
    Recall the Poisson probability mass function:  
    \\(P(Y=k)=e^{-\\lambda}\\lambda^k/k!\\).
    <br>To find \\(P(Y\\le10)\\), sum these from \\(k=0\\) to 10.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    \\[
      P(Y\\le10\\mid W=\\text{Cloudy})
      =\\sum_{k=0}^{10} e^{-12}\\frac{12^k}{k!}
      \\approx0.3472.
    \\]
    (Round the final probability to four decimal places.)
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Since \\(Y\\mid W=\\text{Cloudy}\\sim Poisson(12)\\), we compute:<br><br>
    \\[
      P(Y\\le10\\mid W=\\text{Cloudy})
      =\\sum_{k=0}^{10} e^{-12}\\frac{12^k}{k!}
      \\approx0.3472.
    \\]
    Thus, there is about a <b>34.72% chance</b> of collecting 10 or fewer eggs on a cloudy day.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 5,
          story = HTML("
    <h4>🐄 Problem 5</h4>
    <p>Each worker repeatedly attempts to fill one full bucket of milk.</p>
    <p>Each attempt succeeds with probability \\(p\\), depending on the worker’s skill level \\(S\\):</p>
    <ul>
      <li>Experienced worker: \\(p=0.4\\)</li>
      <li>Novice worker: \\(p=0.2\\)</li>
    </ul>
    <p>Let \\(Y\\) denote the number of attempts required for the first success.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Let \\(Z=Y-1\\) count failures before success. Given \\(S=s\\), what is the named distribution of \\(Z\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          ans_text = "Geometric",
          ans_frac = NA,
          ans_val  = NA,
          
          hint1 = HTML("
    \\(Y\\) counts attempts including success; \\(Z=Y-1\\) counts failures in independent Bernoulli trials before success.
    Think: which named distribution models that waiting time?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Given \\(S=s\\), the success probability is \\(p_s\\).  
    Therefore \\(Z\\mid S=s\\sim Geometric(p_s)\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given \\(S=s\\), \\(Y\\) counts attempts including success; \\(Z=Y-1\\) counts failures in independent Bernoulli trials before success.
    Hence the conditional distribution is:<br><br>
    \\[
      Z=Y-1\\mid S=s \\sim Geometric(p_s), \\quad Z=0,1,2,\\ldots,
    \\]
    where \\(p_s\\) is the success probability for the worker’s skill level \\(s\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 6,
          story = HTML("
    <h4>🐄 Problem 6</h4>
    <p>Under the same milking setup, consider a novice worker with success probability \\(p=0.2\\).</p>
    <p>Let \\(Y\\) be the number of attempts required for the first successful full bucket.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Compute the probability that the novice worker takes at least 3 attempts to succeed:<br>
    \\(P(Y\\ge3\\mid S=\\text{Novice})\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = 0.64,
          
          hint1 = HTML("
    With \\(Z=Y-1\\mid S=\\text{Novice}\\sim Geometric(0.2)\\),
    then \\(P(Y\\ge3)=(1-p)^{3-1}\\).  
    Try substituting \\(p=0.2\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    \\[
      P(Y\\ge3\\mid S=\\text{Novice})
      =(1-0.2)^{2}=0.64.
    \\]
    The probability the novice worker needs at least 3 tries is 0.64.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given \\(S=\\text{Novice}\\), \\(Z=Y-1\\sim Geometric(0.2)\\), with \\(Y=1,2,\\ldots\\). At least three attempts means at least two failures.<br><br>
    The probability of needing at least 3 attempts is:<br>
    \\[
      P(Y\\ge3\\mid S=\\text{Novice})=(1-0.2)^{2}=0.64.
    \\]
    Thus, a novice worker has a 64% chance of needing 3 or more attempts before success.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 7,
          story = HTML("
    <h4>🌧 Problem 7</h4>
    <p>Every morning at 6 a.m., you start recording the time (in hours) until it rains on your uncle’s farm.</p>
    <p>The rain rate depends on the cloud condition \\(C\\):</p>
    <table class='pmf-table'>
      <thead>
        <tr><th>Condition</th><th>Rate parameter \\(\\lambda\\) (per hour)</th></tr>
      </thead>
      <tbody>
        <tr><td>Sunny</td><td>0.1</td></tr>
        <tr><td>Cloudy</td><td>0.5</td></tr>
        <tr><td>Stormy</td><td>1.2</td></tr>
      </tbody>
    </table>
    <p>Let \\(Y\\) be the time (in hours) until the first rainfall starts.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Once we condition on the cloud condition \\(\\{C=c\\}\\), what is the conditional distribution of \\(Y\\)? 
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_text = "Exponential",
          ans_frac = NA,
          ans_val  = NA,
          
          hint1 = HTML("
    When waiting time between events follows a Poisson process with rate \\(\\lambda\\),  
    the waiting time to the first event has an Exponential(\\(\\lambda\\)) distribution.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Given \\(C=c\\), the rain time is exponentially distributed with rate \\(\\lambda(c)\\).  
    Therefore, \\(Y\\mid C=c\\sim Exponential(\\lambda=\\lambda(c))\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Conditioning on the cloud condition determines the rain rate parameter.  
    \\[
      Y\\mid C=c \\sim Exponential(\\lambda=\\lambda(c)).
    \\]
    Specifically:<br><br>
    \\[
      Y\\mid C=Sunny \\sim Exponential(0.1),\\quad
      Y\\mid C=Cloudy \\sim Exponential(0.5),\\quad
      Y\\mid C=Stormy \\sim Exponential(1.2).
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 8,
          story = HTML("
    <h4>🌧 Problem 8 — Conditional Probability</h4>
    <p>Under the same setup, find the probability that rain begins within the first 2 hours on a <b>cloudy</b> day.</p>
    <script>
      if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    </script>
  "),
          
          question = HTML("
    Compute:<br>
    \\[
      P(Y\\le2\\mid C=Cloudy).
    \\]
    <script>
      if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    </script>
  "),
          
          ans_val = pexp(2, rate = 0.5),
          ans_frac = NA,
          
          hint1 = HTML("
    For an Exponential(\\(\\lambda\\)) random variable,  
    the CDF is \\(P(Y\\le y)=1-e^{-\\lambda y}\\).  
    Substitute \\(\\lambda=0.5\\) and \\(y=2\\).
    <script>
      if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    </script>
  "),
          
          hint2 = HTML("
    \\(P(Y\\le2\\mid C=Cloudy)=1-e^{-0.5\\times2}=1-e^{-1}\\approx0.6321.\\)
    <script>
      if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    </script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Using the exponential CDF \\(1-e^{-\\lambda y}\\):<br>
    \\[
      P(Y\\le2\\mid C=Cloudy)=1-e^{-0.5\\times2}=1-e^{-1}\\approx0.6321.
    \\]
    <p>Thus, on a cloudy day, there is approximately a 63% chance that rain begins within 2 hours.</p>
    <script>
      if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    </script>
  ")
        ),
        list(
          id = 9,
          story = HTML("
    <h4>🍓 Problem 9</h4>
    <p>You are helping your uncle measure the average weight of strawberries from different plots of land.</p>
    <p>Each plot has a fertility score \\(X\\), which affects how large the strawberries grow.</p>
    <p>Based on past data, the distribution of a strawberry’s weight \\(Y\\) (in grams) given the fertility level \\(X=x\\) is approximately normal:</p>
    \\[
      Y\\mid X=x\\sim N(\\mu=50+5x,\\,\\sigma^2=9).
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Once we condition on the fertility level \\(\\{X=x\\}\\), what is the conditional distribution of \\(Y\\)? 
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_text = "Normal",
          ans_frac = NA,
          ans_val  = NA,
          
          hint1 = HTML("
    A normal model with mean depending on \\(x\\) represents a conditional Normal distribution.  
    The variance stays the same (\\(\\sigma^2\\) constant), but the mean shifts with \\(x\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Given \\(X=x\\), \\(Y\\) is Normal with parameters \\(\\mu=50+5x\\) and \\(\\sigma^2=9\\):  
    \\[
      Y\\mid X=x\\sim Normal(\\mu=50+5x,\\,\\sigma^2=9).
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Conditioning on the fertility level \\(X=x\\) fixes the mean and variance parameters.  
    \\[
      Y\\mid X=x\\sim Normal(\\mu=50+5x,\\,\\sigma^2=9).
    \\]
    The mean increases linearly with fertility \\(x\\), while the variance remains constant.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 10,
          story = HTML("
    <h4>🍓 Problem 10</h4>
    <p>Suppose a particular plot has fertility level \\(X=3\\).</p>
    <p>Then \\(Y\\mid X=3\\sim N(65,9)\\).</p>
    <p>Find the probability that a randomly selected strawberry from this plot weighs more than 70 grams.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Compute \\(P(Y>70\\mid X=3)\\). 
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = pnorm(70, mean = 65, sd = 3, lower.tail = FALSE),
          
          hint1 = HTML("
    Standardize the Normal variable:  
    \\[
      Z = \\frac{Y-\\mu}{\\sigma}.
    \\]
    Then \\(P(Y>70)=P(Z>\\frac{70-65}{3})=P(Z>5/3)\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    The variance is 9, so the standard deviation is 3. Retain the exact z-score 5/3 until the final step: \\(P(Z>5/3)=1-\\Phi(5/3)\\approx0.0478.\\)
    Hence, \\(P(Y>70\\mid X=3)\\approx0.0478.\\)
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given \\(Y\\mid X=3\\sim N(65,9)\\),  
    \\[
      P(Y>70\\mid X=3)=1-\\Phi\\left(\\frac{70-65}{3}\\right)
      =1-\\Phi(5/3)\\approx0.0478.
    \\]
    Therefore, even in a highly fertile plot (\\(X=3\\)),  
    only about 4.8% of strawberries exceed 70 grams in weight.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 11,
          story = HTML("
    <h4>🐑 Problem 11</h4>
    <p>Every afternoon, you record how far the sheep wander from the barn.</p>
    <p>The distance \\(Y\\) (in meters) depends on the wind level \\(W\\): for this illustrative model, higher wind categories are associated with a larger roaming range.</p>
    <p>For this exercise, assume the maximum roaming distance increases linearly with wind level \\(W\\):</p>
    \\[
      Y\\mid W=w \\sim Uniform(0,\\,100+20w),
    \\]
    where \\(w=0,1,2,\\dots\\) represents the wind strength category.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Once we condition on the wind level \\(\\{W=w\\}\\), what is the conditional distribution of \\(Y\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_text = "Uniform",
          ans_frac = NA,
          ans_val  = NA,
          
          hint1 = HTML("
    For a continuous Uniform(a,b) model, equal-length subintervals within the support have equal probability.
    The upper bound \\(b\\) here depends on the wind level \\(w\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Given \\(W=w\\), the grazing distance follows a uniform distribution on \\([0,100+20w]\\):  
    \\[
      Y\\mid W=w \\sim Uniform(0,\\,100+20w).
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Conditioning on wind level \\(W=w\\), the grazing distance range becomes fixed.  
    \\[
      Y\\mid W=w \\sim Uniform(0,\\,100+20w).
    \\]
    The higher the wind level, the wider the uniform range of possible grazing distances.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 12,
          story = HTML("
    <h4>🐑 Problem 12</h4>
    <p>Under the same setup, find the probability that a sheep grazes more than 50 meters away from the barn when the wind level is \\(W=2\\).</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Compute \\(P(Y>50\\mid W=2)\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = "9/14",
          ans_val  = 90/140,
          
          hint1 = HTML("
    For \\(Uniform(a,b)\\), the probability that \\(Y>y\\) is  
    \\[
      P(Y>y)=\\frac{b-y}{b-a},\\quad a\\le y\\le b.
    \\]
    Substitute \\(a=0\\), \\(b=100+20\\times2=140\\), and \\(y=50\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Compute:  
    \\[
      P(Y>50\\mid W=2)=\\frac{140-50}{140-0}=\\frac{90}{140}\\approx0.6429.
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given \\(Y\\mid W=2\\sim Uniform(0,140)\\):  
    \\[
      P(Y>50\\mid W=2)=\\frac{140-50}{140-0}=\\frac{90}{140}\\approx0.6429.
    \\]
    When the wind is moderate (\\(W=2\\)),  
    there is about a 64% chance that the sheep will roam farther than 50 meters —  
    illustrating how the uniform range widens with wind level.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 13,
          story = HTML("
    <h4>☀️ Problem 13 </h4>
    <p>On your uncle’s farm, the total solar energy produced during the daytime (in kWh) is denoted by \\(Y\\).</p>
    <p>The sunlight duration \\(H\\) (in hours) varies from day to day and affects output variability.</p>
    <p>Assume the sunlight duration is positive. Conditional on \\(H=h\\), the total energy output follows a Gamma model:</p>
    \\[
      Y\\mid H=h\\sim Gamma(\\alpha=h,\\,\\beta=2),
    \\]
    where we use the <i>shape–rate</i> parameterization (shape \\(=\\alpha\\), rate \\(=\\beta\\)).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Once we condition on \\(\\{H=h\\}\\), what is the conditional distribution of \\(Y\\)? 
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_text = "Gamma",
          ans_frac = NA,
          ans_val  = NA,
          
          hint1 = HTML("
    A Gamma(\\(\\alpha,\\beta\\)) distribution often models waiting times or total accumulated outputs.  
    Here, longer sunlight (larger \\(h\\)) increases the shape \\(\\alpha\\), while the rate \\(\\beta\\) stays constant.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Given \\(H=h\\), the output is Gamma-distributed with shape \\(\\alpha=h\\) and rate \\(\\beta=2\\):  
    \\[
      Y\\mid H=h \\sim Gamma(\\alpha=h,\\,\\beta=2).
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Conditioning on sunlight duration \\(H=h\\) fixes the Gamma shape parameter:  
    \\[
      Y\\mid H=h \\sim Gamma(\\alpha=h,\\,\\beta=2).
    \\]
    Longer sunlight (larger \\(h\\)) increases the mean \\(E[Y|H=h]=\\alpha/\\beta=h/2\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        )
      )
    }
    # ============================================================
    # 题目逻辑
    # ============================================================
    
    # ==== 题库 ====
    question_bank <- get_condition_question_bank()
    practice_questions <- learning_questions(question_bank, "conditional",shiny::isolate(course_path()))
    practice <- learning_practice_server(input, output, session, practice_questions,
      "conditional", course_path, load_pmf=pmf_actions$load_example, open_plot=open_plot)
    # Stable references also support regression of the unchanged original question library.
    current_index <- practice$current_index
    prob <- practice$prob
    result <- practice$result
    tries <- practice$tries
    practice
  })
}
