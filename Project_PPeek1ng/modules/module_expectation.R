# =====================================================================
#  module_expectation.R — Expectation Module
# =====================================================================

# ---- Helper: Table CSS ----
expectation_css <- tags$head(tags$style(HTML("
.pmf-table { border-collapse: collapse; margin-top: 10px; }
.pmf-table th, .pmf-table td {
  border: 1.6px solid #333; padding: 6px 10px; text-align: center;
}
.pmf-table th.corner { font-style: italic; white-space: nowrap; }
.pmf-table .sumcell { font-weight: 600; background:#fafafa; }
")))

# ---- Shared probability parsing and validation ----
# main.R loads pmf_helpers.R before this module; direct module tests must do so too.

# ---- 小数近似成分数（显示）----
simp_frac <- function(x, tol = 1e-12, max_den = 500) {
  if (is.na(x) || !is.finite(x)) return("?")
  for (den in 1:max_den) {
    num <- round(x * den)
    if (num == 0 && x != 0) next
    if (abs(num / den - x) < tol) return(paste0(num, "/", den))
  }
  format(signif(x, 10), scientific = FALSE, trim = TRUE)
}

# ---- 转成 LaTeX 分数显示 ----
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
expectation_UI <- function(id) {
  tagList(learning_table_module_ui(id,"Expectation",
    theory=withMathJax(
                 tagList(
                   h4("Expectation"),
                   p("In this module, we study the expected values of discrete random variables and how to compute conditional expectations based on the joint and conditional PMFs."),
                   
                   tags$hr(),
                   
                   h5("Expectation of a Discrete Random Variable"),
                   p("For a discrete random variable X with PMF \\(f_X(x)\\), the expected value (or mean) is defined as:"),
                   HTML("$$E[X] = \\sum_x x f_X(x)$$"),
                   p("This represents the long-run average value of X when the experiment is repeated many times."),
                   
                   tags$hr(),
                   
                   h5("Expectation of a Function of Two Variables"),
                   p("If X and Y have a joint PMF \\(f_{X,Y}(x,y)\\), then for any function \\(g(X,Y)\\):"),
                   HTML("$$E[g(X,Y)] = \\sum_x \\sum_y g(x,y) f_{X,Y}(x,y)$$"),
                   p("Common examples include expectations such as \\(E[X + Y]\\), \\(E[XY]\\), or \\(E[X^2]\\). These are computed by multiplying each value of \\(g(x, y)\\) by its probability and summing over all pairs \\((x, y)\\)."),
                   
                   tags$hr(),
                   
                   h5("Conditional Expectation"),
                   p("When the value of one variable is known, we can find the conditional expectation of the other variable."),
                   p("The conditional expectation of Y given X = x is:"),
                   HTML("$$E[Y|X=x] = \\sum_y y f_{Y|X}(y|x)$$"),
                   p("Similarly, the conditional expectation of X given Y = y is:"),
                   HTML("$$E[X|Y=y] = \\sum_x x f_{X|Y}(x|y)$$"),
                   p("Conditional expectations describe how the expected value of one variable changes when we condition on the other."),
                   
                   tags$hr(),
                   
                   h5("Law of Total Expectation"),
                   p("The joint and conditional expectations are connected through the law of total expectation:"),
                   HTML("$$E[Y] = \\sum_x E[Y|X=x] f_X(x)$$"),
                   p("This law states that the overall expectation of Y can be found by averaging the conditional expectations \\(E[Y|X=x]\\), weighted by the probability of each \\(X=x\\).")
                   )
               ),plot_ids=NULL))
}

# =====================================================================
#  SERVER
# =====================================================================
expectation_Server <- function(id, shared = new_pmf_state(), course_path = function() "core", open_plot = NULL) {
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
    
    # ========================== 输入逻辑与概率表 ============================
    init_df <- data.frame(
      x = c(0, 0, 1, 1),
      y = c(0, 1, 0, 1),
      p_input = c("188/221", "16/221", "16/221", "1/221"),
      id = 1:4,
      stringsAsFactors = FALSE
    )
    init_df$p_value <- sapply(init_df$p_input, parse_user_prob)
    

    # 初始化或加载全局（避免首次进入拿到旧数据）
    isolate({
      if (is.null(pmf_global$df_edit) || !isTRUE(pmf_global$has_final)) {
        pmf_global$df_edit  <- init_df
        pmf_global$df_final <- init_df
        pmf_global$counter  <- nrow(init_df)
        pmf_global$has_final <- FALSE
      }
    })
    
    # 本模块的本地副本（用 isolate 取初值，避免“在 reactive 外访问”错误）
    pmf_edit    <- reactiveVal(isolate(pmf_global$df_edit))
    pmf_final   <- reactiveVal(isolate(pmf_global$df_final))
    row_counter <- reactiveVal(isolate(pmf_global$counter))
    
    # 只有全局 has_final=TRUE 时，才自动把全局同步灌入当前模块
    observe({
      req(isTRUE(pmf_global$has_final))
      pmf_edit(pmf_global$df_edit)
      pmf_final(pmf_global$df_final)
      row_counter(pmf_global$counter)
    })
    
    # ---- 输入区 ----
    output$input_panel <- renderUI({
      df <- pmf_edit()
      if (is.null(df) || !"id" %in% names(df)) {
        return(tags$div(style="color:#888; padding:10px;", "Initializing table..."))
      }
      tagList(
        selectInput(ns("pmf_example"), "Worked example", choices = learning_pmf_example_choices()),
        actionButton(ns("load_pmf_example"), "Load worked example", class="btn-outline-primary"),
        h4("Input (x, y, p):"),
        helpText("Enter non-negative probabilities or weights. Generate Table merges repeated outcomes and normalizes the total to 1. Normalize changes the draft inputs only."),
        helpText("Compact values are shown below. Hover for full precision. Unedited entries retain full precision."),
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
    
    # ---- 数据更新 ----
    df_current <- reactive({
      df <- pmf_edit()
      needed_cols  <- c("x", "y", "p_input", "p_value", "id")
      missing_cols <- setdiff(needed_cols, names(df))
      if (length(missing_cols) > 0) {
        for (col in missing_cols) {
          df[[col]] <- switch(col,
                              x = 0, y = 0, p_input = "0", p_value = 0, id = seq_len(nrow(df))
          )
        }
      }
      
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
                              x = 0, y = 0, p_input = "0", p_value = 0, id = seq_len(nrow(df))
          )
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
                     pmf_final, row_counter, pmf_global)

    # ---- 联合概率表 + 右侧计算区 ----
    output$joint_table_html <- renderUI({
      df <- pmf_final()
      if (is.null(df) || nrow(df) == 0) return(NULL)
      
      mat <- xtabs(p_value ~ x + y, data = df)
      xs <- as.numeric(rownames(mat))
      ys <- as.numeric(colnames(mat))
      row_tot <- rowSums(mat)
      col_tot <- colSums(mat)
      
      # 联合表
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
      
      # 右侧：计算控件 + 输出
      cond_panel <- tagList(
        tags$h5("Expectation Calculation", style = "color:#444; margin-bottom:8px;"),
        selectInput(
          ns("cond_type"), "Type:",
          choices = c("E[Y | X]" = "yx", "E[X | Y]" = "xy")
        ),
        tags$hr(style="margin:8px 0;"),
        uiOutput(ns("expectation_results")),
        tags$hr(style="margin:8px 0;"),
        uiOutput(ns("expectation_detail"))
      )
      
      tagList(
        withMathJax(),
        div(class = "pmf-table-layout",
          div(class = "pmf-table-scroll", joint_html,
            tags$p(HTML("\\(\\sum_x \\sum_y f_{X,Y}(x,y) = 1\\)"))),
          div(class = "pmf-calculation-panel", cond_panel)
        )
      )
    })
    # ========================== 输入逻辑与概率表 ============================
    
    # ========================== 期望计算 ============================
    # ---- 普通期望 ----
    output$expectation_results <- renderUI({
      df <- pmf_final(); req(nrow(df) > 0)
      
      fx <- df %>% group_by(x) %>% summarise(px = sum(p_value), .groups="drop") %>% arrange(x)
      fy <- df %>% group_by(y) %>% summarise(py = sum(p_value), .groups="drop") %>% arrange(y)
      
      EX <- sum(fx$x * fx$px)
      EY <- sum(fy$y * fy$py)
      
      ex_formula <- paste0(
        "\\(E[X] = \\sum_x x f_X(x)",number_relation(fx$px,display_mode()),
        paste0(fx$x, "\\cdot ", number_tex(fx$px,display_mode()), collapse = " + "),
        number_relation(c(fx$px,EX),display_mode()), number_tex(EX,display_mode()), "\\)"
      )
      ey_formula <- paste0(
        "\\(E[Y] = \\sum_y y f_Y(y)",number_relation(fy$py,display_mode()),
        paste0(fy$y, "\\cdot ", number_tex(fy$py,display_mode()), collapse = " + "),
        number_relation(c(fy$py,EY),display_mode()), number_tex(EY,display_mode()), "\\)"
      )
      
      withMathJax(
        tagList(
          number_formula(ex_formula,EX),
          number_formula(ey_formula,EY)
        )
      )
    })
    
    # ---- 条件期望 ----
    output$expectation_detail <- renderUI({
      df <- pmf_final(); req(nrow(df) > 0)
      type <- input$cond_type; if (is.null(type)) type <- "yx"
      
      if (type == "yx") {
        xvals <- sort(unique(df$x))
        formulas <- lapply(xvals, function(x0) {
          sub <- df[df$x == x0, c("y","p_value")]
          den <- sum(sub$p_value)
          num_expr <- paste0(sub$y, "\\cdot ", number_tex(sub$p_value,display_mode()), collapse = " + ")
          if (den <= 0) return(tags$p(paste0("Conditional expectation is undefined: P(X = ", x0, ") = 0.")))
          val <- if (den > 0) sum(sub$y * sub$p_value) / den else NA
          formula <- paste0(
            "\\(E[Y | X=", x0, "]",number_relation(c(sub$p_value,den),display_mode()),"\\frac{", num_expr, "}{", number_tex(den,display_mode()), "}",
            number_relation(c(sub$p_value,den,val),display_mode()), number_tex(val,display_mode()), "\\)"
          )
          number_formula(formula,val)
        })
      } else {
        yvals <- sort(unique(df$y))
        formulas <- lapply(yvals, function(y0) {
          sub <- df[df$y == y0, c("x","p_value")]
          den <- sum(sub$p_value)
          num_expr <- paste0(sub$x, "\\cdot ", number_tex(sub$p_value,display_mode()), collapse = " + ")
          if (den <= 0) return(tags$p(paste0("Conditional expectation is undefined: P(Y = ", y0, ") = 0.")))
          val <- if (den > 0) sum(sub$x * sub$p_value) / den else NA
          formula <- paste0(
            "\\(E[X | Y=", y0, "]",number_relation(c(sub$p_value,den),display_mode()),"\\frac{", num_expr, "}{", number_tex(den,display_mode()), "}",
            number_relation(c(sub$p_value,den,val),display_mode()), number_tex(val,display_mode()), "\\)"
          )
          number_formula(formula,val)
        })
      }
      
      withMathJax(
        tagList(
          tags$h5(if (type == "yx") "E[Y | X=x]" else "E[X | Y=y]", style="margin:0 0 8px; color:#444;"),
          formulas
        )
      )
    })
    # ========================== 期望计算 ============================
    # ============================================================
    # 题库
    # ============================================================
    get_expectation_question_bank <- function() {
      list(
        list(
          id = 1,
          story = HTML("
    <h4>🌽 Problem 1</h4>
    <p>Each day you inspect <b>n = 10</b> rows of corn.</p>
    <p>Inspect one plant per row. Each inspected plant has damage probability 0.2, independently of the others.</p>
    <p>Let \\(X\\) be the total number of damaged plants found that day.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Find the expected number of damaged plants \\(E[X]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = 2,
          
          hint1 = HTML("
    Start by recalling the general formula for the mean of a Binomial random variable. 
    What is the relationship between \\(n\\), \\(p\\), and \\(E[X]\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    For \\(X \\sim Binomial(n, p)\\), the expectation is \\(E[X] = n p\\). 
    Substitute \\(n=10\\) and \\(p=0.2\\) to compute the result numerically.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Since \\(X\\) counts the number of successes in 10 independent Bernoulli(0.2) trials, 
    \\[
      E[X] = n p = 10 \\times 0.2 = 2.
    \\]
    <b>Therefore, the expected number of damaged plants is 2.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 2,
          story = HTML("
    <h4>🐔 Problem 2</h4>
    <p>During a 6-hour day, chickens lay eggs following a Poisson process with an average rate of <b>4 eggs per hour</b>.</p>
    <p>Let \\(X\\) be the total number of eggs collected during the day.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Find the expected number of eggs collected \\(E[X]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = 24,
          
          hint1 = HTML("
    Recall the key property of the Poisson distribution: it models the number of events in a fixed time interval at a known average rate \\(\\lambda\\).
    What is the mean of a Poisson random variable?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    For \\(X \\sim Poisson(\\lambda)\\), the expectation is \\(E[X] = \\lambda\\). 
    Compute the total rate for 6 hours when the hourly rate is 4 eggs/hour.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    The total rate over 6 hours is \\(\\lambda = 6 \\times 4 = 24\\).<br>
    Therefore, since \\(E[X] = \\lambda\\), we have:
    \\[
      E[X] = 24.
    \\]
    <b>Thus, on average 24 eggs are collected per day.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 3,
          story = HTML("
    <h4>🌧 Problem 3</h4>
    <p>Let \\(X\\) be the waiting time (in hours) until it starts raining on your uncle’s farm.</p>
    <p>Rainfall events follow an exponential model with rate parameter \\(\\lambda = 0.5\\) per hour.</p>
    <p>You want to find the average waiting time before the first rainfall begins.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Find the expected waiting time \\(E[X]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_text = "E[X] = 1 / λ",
          ans_frac = NA,
          ans_val  = 2,
          
          hint1 = HTML("
    Recall that the exponential distribution models the waiting time between events in a Poisson process.  
    What general formula gives its expected value in terms of the rate \\(\\lambda\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    For \\(X \\sim Exponential(\\lambda)\\), we have \\(E[X] = 1 / \\lambda\\).  
    Substitute the rate \\(\\lambda = 0.5\\) to compute the result numerically.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Since \\(E[X] = 1 / \\lambda\\) for an exponential distribution, we have:
    \\[
      E[X] = \\frac{1}{0.5} = 2.
    \\]
    <b>Therefore, the expected waiting time before it rains is 2 hours.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 4,
          story = HTML("
    <h4>🐑 Problem 4 — Uniform: Sheep Grazing Distance</h4>
    <p>Let \\(X \\sim Uniform(0,100)\\), representing how far a sheep grazes from the barn (in meters).</p>
    <p>You want to find the expected value of the square of the grazing distance.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("Give an exact fraction or round to two decimal places.<br>
    Find the expected value \\(E[X^2]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = "10000/3",
          ans_val  = 10000/3,
          tolerance = 0.005,
          
          hint1 = HTML("
    Think about the general formula for the second moment of a Uniform(\\(a,b\\)) random variable.  
    The mean is at the midpoint, but how do you express \\(E[X^2]\\) in terms of \\(a\\) and \\(b\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    For \\(X \\sim Uniform(a,b)\\), the expected value of \\(X^2\\) is  
    \\[
      E[X^2] = \\frac{a^2 + a b + b^2}{3}.
    \\]  
    Substitute \\(a = 0\\) and \\(b = 100\\) to find the numerical result.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Using the Uniform(0,100) formula:
    \\[
      E[X^2] = \\frac{a^2 + a b + b^2}{3} 
              = \\frac{0^2 + 0\\times100 + 100^2}{3} 
              = \\frac{10000}{3} \\approx 3333.33.
    \\]
    <b>Therefore, the expected value of the squared grazing distance is approximately 3333.33.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 5,
          story = HTML("
    <h4>🍓 Problem 5</h4>
    <p>Let \\(X \\sim N(50, 9)\\) represent the weight of a strawberry (in grams).</p>
    <p>You want to find the expected squared deviation of \\(X\\) from its mean weight of 50 grams.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Find \\(E[(X - 50)^2]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = 9,
          
          hint1 = HTML("
    For any random variable with finite variance, the expected squared deviation from its mean equals its variance.
    What does \\(E[(X - μ)^2]\\) represent in terms of variance?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    For any Normal(μ, σ²), the second central moment equals the variance:  
    \\[
      E[(X - μ)^2] = Var(X) = σ^2.
    \\]
    Substitute \\(σ^2 = 9\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Since \\(X \\sim N(50, 9)\\),  
    \\[
      E[(X - 50)^2] = Var(X) = 9.
    \\]
    <b>Therefore, the expected squared deviation of strawberry weight from its mean is 9.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 6,
          story = HTML("
    <h4>☀️ Problem 6 </h4>
    <p>Let \\(X \\sim Exponential(\\lambda = 2)\\) represent the time (in hours) between two bursts of solar radiation on the farm.</p>
    <p>You are asked to compute the expected value of \\(X^2\\).</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Find \\(E[X^2]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = 0.5,
          
          hint1 = HTML("
    For an exponential distribution, both the mean and higher moments can be expressed in terms of the rate \\(\\lambda\\).  
    Start from the general formula for the second moment.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    For \\(X \\sim Exponential(\\lambda)\\),  
    \\[
      E[X^2] = \\frac{2}{\\lambda^2}.
    \\]
    Substitute \\(\\lambda = 2\\) and simplify the result.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Using the formula \\(E[X^2] = 2 / \\lambda^2\\),  
    \\[
      E[X^2] = \\frac{2}{2^2} = \\frac{2}{4} = 0.5.
    \\]
    <b>Therefore, the expected value of \\(X^2\\) is 0.5.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 7,
          story = HTML("
    <h4>🌽 Problem 7 — Binomial: Corn Inspection</h4>
    <p>Given that \\(Y | X = x \\sim Binomial(n = x, p = 0.2)\\).</p>
    <p>Suppose today you inspected \\(X = 10\\) rows of corn.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          question = HTML("
    Compute the conditional expectation \\(E[Y \\mid X = 10]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          ans_frac = NA,
          ans_val  = 2,   # 10 × 0.2
          hint1 = HTML("
    Recall that for a Binomial(\\(n, p\\)) random variable, \\(E[Y] = n p\\).  
    Plug in the given values for \\(n\\) and \\(p\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          hint2 = HTML("
    Use \\(E[Y|X=10] = 10 \\times 0.2\\).  
    Simplify your answer.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          solution = HTML("
    <b>Solution:</b><br>
    \\[
      E[Y|X=10] = 10 \\times 0.2 = 2.
    \\]
    <b>Therefore, the expected number of damaged plants is 2.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 8,
          story = HTML("
    <h4>🐔 Problem 8 — Poisson: Egg Collection by Weather</h4>
    <p>The total number of eggs collected in a day, denoted by \\(Y\\), depends on the weather condition \\(W\\).</p>
    <p>Empirical records show that:</p>
    <ul>
      <li>On sunny days: \\(Y \\mid W = \\text{Sunny} \\sim Poisson(24)\\)</li>
      <li>On cloudy days: \\(Y \\mid W = \\text{Cloudy} \\sim Poisson(12)\\)</li>
    </ul>
    <p>You want to find the expected number of eggs collected under each weather condition.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Compute the conditional expectations \\(E[Y \\mid W = \\text{Sunny}]\\) and \\(E[Y \\mid W = \\text{Cloudy}]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = 24,
          ans_pair = c(sunny = 24, cloudy = 12),
          
          hint1 = HTML("
    Recall that for a Poisson(\\(\\lambda\\)) random variable, the mean equals its rate parameter.  
    Each weather condition provides a different \\(\\lambda\\) value — what does that imply for \\(E[Y|W]\\)?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Use the property \\(E[Y|W=w] = \\lambda_w\\).  
    Substitute the given rates for sunny (24) and cloudy (12) conditions to compute both expectations.
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    For a Poisson distribution, the mean equals the rate parameter:  
    \\[
      E[Y|W=\\text{Sunny}] = 24, \\quad
      E[Y|W=\\text{Cloudy}] = 12.
    \\]
    <b>Therefore, the farm collects on average 24 eggs on sunny days and 12 on cloudy days.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        ),
        list(
          id = 9,
          story = HTML("
    <h4>🍓 Problem 9 — Normal: Strawberry Fertility Effect (Conditional Expectation)</h4>
    <p>The weight of strawberries, denoted by \\(Y\\), depends on the fertility level of the field, represented by \\(X\\).</p>
    <p>From farm data, the conditional distribution of strawberry weight is modeled as:</p>
    <p>\\(Y \\mid X = x \\sim N(50 + 5x, 9)\\)</p>
    <p>For a particular plot where the fertility level is \\(x = 3\\), you want to find the expected strawberry weight.</p>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          question = HTML("
    Compute \\(E[Y \\mid X = 3]\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          ans_frac = NA,
          ans_val  = 65,
          
          hint1 = HTML("
    Recall that for a Normal distribution, the expected value equals its mean parameter.  
    Here the mean depends on \\(x\\); plug in \\(x = 3\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    The conditional mean is \\(E[Y|X=x] = 50 + 5x\\).  
    Substitute \\(x = 3\\) to find \\(E[Y|X=3] = 65\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    From \\(E[Y|X=x] = 50 + 5x\\),  
    \\[
      E[Y|X=3] = 50 + 5(3) = 65.
    \\]
    <b>Therefore, the expected strawberry weight for this plot is 65 grams.</b>
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  ")
        )
      )
    }
    # ============================================================
    # 题目逻辑
    # ============================================================
    
    # ==== 题库 ====
    question_bank <- get_expectation_question_bank()
    practice_questions <- learning_questions(question_bank, "expectation",shiny::isolate(course_path()))
    practice <- learning_practice_server(input, output, session, practice_questions,
      "expectation", course_path, load_pmf=pmf_actions$load_example, open_plot=open_plot)
    # Stable references also support regression of the unchanged original question library.
    current_index <- practice$current_index
    prob <- practice$prob
    result <- practice$result
    tries <- practice$tries
    practice
  })
}
