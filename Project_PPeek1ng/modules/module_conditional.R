# =====================================================================
#  module_conditional.R — Conditional Distribution Module
# =====================================================================
# ---- bind global pmf ----
pmf_global <- get0("pmf_global", envir = .GlobalEnv, inherits = FALSE)
if (is.null(pmf_global)) {
  stop("pmf_global is not initialised in .GlobalEnv. Define it in main.R before sourcing modules.")
}
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


# ---- Helper: 分数/小数解析 ----
parse_user_prob <- function(s, digits = 5) {
  s <- trimws(s)
  if (s == "") return(NA_real_)
  if (grepl("^[-+]?[0-9]+\\s*/\\s*[0-9]+$", s)) {
    parts <- strsplit(gsub("\\s+", "", s), "/", fixed = TRUE)[[1]]
    num <- suppressWarnings(as.numeric(parts[1]))
    den <- suppressWarnings(as.numeric(parts[2]))
    if (is.na(num) || is.na(den) || den == 0) return(NA_real_)
    return(round(num / den, digits))
  }
  if (grepl("^[-+]?[0-9]*\\.?[0-9]+$", s)) {
    val <- suppressWarnings(as.numeric(s))
    if (is.na(val)) return(NA_real_)
    return(round(val, digits))
  }
  NA_real_
}

simp_frac <- function(x, tol = 1e-5, max_den = 500) {
  if (is.na(x) || !is.finite(x)) return("?")
  for (den in 1:max_den) {
    num <- round(x * den)
    if (abs(num / den - x) < tol) return(paste0(num, "/", den))
  }
  sprintf("%.5f", x)
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
is_correct <- function(user_input, ans_val = NA, ans_frac = NA, ans_text = NA, tol = 1e-4) {
  # 空输入直接 FALSE
  if (is.null(user_input) || trimws(user_input) == "") return(FALSE)
  input_str <- trimws(user_input)
  
  # ---- 1️⃣ 文字题模糊匹配（不区分大小写）----
  if (!is.na(ans_text) && is.character(ans_text)) {
    keyword <- tolower(trimws(ans_text))
    user_lower <- tolower(input_str)
    # 模糊匹配：输入中包含关键词即可，例如 "Poisson", "Normal"
    return(grepl(keyword, user_lower, fixed = TRUE))
  }
  
  # ---- 2️⃣ 数值或分数输入解析 ----
  parse_to_numeric <- function(s) {
    s <- trimws(s)
    # 分数形式 a/b
    if (grepl("^[-+]?[0-9]+\\s*/\\s*[0-9]+$", s)) {
      parts <- strsplit(gsub("\\s+", "", s), "/", fixed = TRUE)[[1]]
      num <- suppressWarnings(as.numeric(parts[1]))
      den <- suppressWarnings(as.numeric(parts[2]))
      if (!is.na(num) && !is.na(den) && den != 0) {
        return(num / den)
      }
    }
    # 小数形式
    if (grepl("^[-+]?[0-9]*\\.?[0-9]+$", s)) {
      return(suppressWarnings(as.numeric(s)))
    }
    NA_real_
  }
  
  user_val <- parse_to_numeric(input_str)
  
  # ---- 3️⃣ 如果 ans_val 是数值型 ----
  if (!all(is.na(ans_val))) {
    # 支持多个正确数值，只要接近任意一个即算对
    return(any(abs(user_val - ans_val) < tol, na.rm = TRUE))
  }
  
  # ---- 4️⃣ 如果定义了分数字符串（例如 "3/7"）----
  if (!is.na(ans_frac) && is.character(ans_frac)) {
    frac_val <- parse_to_numeric(ans_frac)
    return(!is.na(user_val) && abs(user_val - frac_val) < tol)
  }
  
  # ---- 5️⃣ 否则不匹配 ----
  FALSE
}
# =====================================================================
#  UI
# =====================================================================
conditional_UI <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      # 左侧：公式 + 参数输入
      column(width = 3,
             box(
               title = "Conditional Distribution Theory",
               width = 12, status = "primary", solidHeader = TRUE,
               
               withMathJax(
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
               )
             ),
             box(
               title = "Parameter Input", width = 12, status = "info", solidHeader = TRUE,
               uiOutput(ns("input_panel"))
             )
      ),
      
      # 右侧：表格 + 图 + 练习
      column(width = 9,
             box(
               title = "Probability Table", width = 12, status = "primary", solidHeader = TRUE,
               uiOutput(ns("joint_table_html"))
             ),
             
             # 3D + Bird's-eye 并列
             fluidRow(
               column(
                 width = 6,
                 box(
                   title = "3D Conditional PMF", width = 12, status = "info", solidHeader = TRUE,
                   plotlyOutput(ns("plot3d_cond"), height = "400px")
                 )
               ),
               column(
                 width = 6,
                 box(
                   title = "Bird’s-eye View (Conditional)", width = 12, status = "info", solidHeader = TRUE,
                   plotlyOutput(ns("plot_bird_cond"), height = "400px")
                 )
               )
             )
             ,
             # ---------------- 练习模块 ----------------
             box(
               title = NULL, width = 12, status = "warning", solidHeader = FALSE,
               tags$h4(
                 "Conditional Farm",
                 style = "margin-top:0; font-weight:600; color:#333;"
               ),
               withMathJax(
                 div(
                   style = "text-align:center; margin-top:10px;",
                   uiOutput(ns("story_out"))
                 ),
                 div(
                   style = "text-align:center; margin-top:10px;",
                   uiOutput(ns("given_out"))
                 ),
                 
                 tags$hr(),
                 div(
                   style = "text-align:center; margin-top:10px;",
                   uiOutput(ns("qtext"))
                 ),
                 uiOutput(ns("answer_input")),
                 actionButton(
                   ns("check"), "Submit",
                   class = "btn btn-success btn-block",
                   style = "margin-top:5px; font-weight:600;"
                 ),
                 tags$hr(style = "margin: 15px 0;"),
                 uiOutput(ns("feedback")),
                 div(
                   style = "margin-top:15px;",
                   uiOutput(ns("nav_buttons"))
                 )
               )
             )
      )
    )
  )
}
# =====================================================================
#  SERVER
# =====================================================================
conditional_Server <- function(id) {
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
    
    # 只有在 has_final=TRUE 时才从全局推送更新，避免一进页就把旧数据灌回来
    observe({
      req(isTRUE(isolate(pmf_global$has_final)))
      pmf_edit(pmf_global$df_edit)
      pmf_final(pmf_global$df_final)
      row_counter(pmf_global$counter)
    })
    
    # ---- 输入区域 ----
    output$input_panel <- renderUI({
      df <- pmf_edit()
      if (is.null(df) || nrow(df) == 0 || !"id" %in% names(df)) {
        return(tags$div(style="color:#888; padding:10px;", "Initializing table..."))
      }
      tagList(
        h4("Input (x, y, p):"),
        lapply(seq_len(nrow(df)), function(i) {
          fluidRow(
            column(3, textInput(ns(paste0("p_", df$id[i])), "p", value = df$p_input[i])),
            column(3, numericInput(ns(paste0("x_", df$id[i])), "x", value = df$x[i])),
            column(3, numericInput(ns(paste0("y_", df$id[i])), "y", value = df$y[i])),
            column(3, actionButton(ns(paste0("del_", df$id[i])), "Delete", class = "btn-danger btn-sm"))
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
        if (!is.null(p_in)) {
          df$p_input[df$id == i] <- p_in
          df$p_value[df$id == i] <- parse_user_prob(p_in)
        }
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
      new_id  <- ifelse("id" %in% names(df), max(df$id, na.rm = TRUE) + 1, nrow(df) + 1)
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
            pmf_global$counter <- nrow(df_now)
          })
        }, ignoreInit = TRUE)
      })
    })
    
    observeEvent(input$normalize, {
      df <- df_current()
      total <- sum(df$p_value, na.rm = TRUE)
      if (total > 0) {
        df$p_value <- df$p_value / total
        df$p_input <- sprintf("%.5f", df$p_value)
        pmf_edit(df)
        pmf_global$df_edit <- df
      }
    })
    
    observeEvent(input$uniform, {
      df <- pmf_edit()
      if (nrow(df) > 0) {
        df$p_value <- rep(1 / nrow(df), nrow(df))
        df$p_input <- sprintf("%.5f", df$p_value)
        pmf_edit(df)
        pmf_global$df_edit <- df
      }
    })
    
    # ---- Generate PMF ----
    observeEvent(input$generate, {
      df <- df_current()
      df <- df %>%
        dplyr::group_by(x, y) %>%
        dplyr::summarise(
          p_input = dplyr::first(p_input),
          p_value = sum(p_value),
          .groups = "drop"
        )
      df$p_value <- df$p_value / sum(df$p_value)
      if (!"id" %in% names(df)) df$id <- seq_len(nrow(df))
      
      pmf_final(df)
      pmf_global$df_edit   <- df
      pmf_global$df_final  <- df
      pmf_global$counter   <- nrow(df)
      pmf_global$has_final <- TRUE
    })
    
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
                raw_input <- sub$p_input[sub$y == yv]
                if (length(raw_input) == 0) raw_input <- "0"
                tags$td(HTML(paste0("\\(", raw_input, "\\)")))
              }),
              tags$td(class = "sumcell", HTML(to_tex_frac(simp_frac(row_tot[i]))))
            )
          }),
          tags$tr(
            tags$th(class = "sumcell", HTML("\\(f_Y(y)\\)")),
            lapply(seq_along(ys), function(j)
              tags$td(class = "sumcell", HTML(to_tex_frac(simp_frac(col_tot[j]))))
            ),
            tags$td(class = "sumcell", HTML("\\(1\\)"))
          )
        )
      )
      
      # --- 条件控件 ---
      cond_panel <- tagList(
        fluidRow(
          column(
            12,
            div(style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;",
                div(style="min-width:220px;",
                    selectInput(ns("cond_type"), "Conditional slice:",
                                choices = c("f(Y | X = x0)", "f(X | Y = y0)"),
                                width = "100%")
                ),
                div(style="min-width:160px;", uiOutput(ns("cond_value_select")))
            )
          )
        ),
        uiOutput(ns("cond_table_html"))
      )
      
      # --- 输出组合 ---
      tagList(
        withMathJax(),
        fluidRow(
          column(width = 2),  
          column(
            width = 3,
            joint_html,
            tags$div(
              style = "margin-top:8px; color:#666; font-size:13px;",
              HTML("\\(\\sum_x \\sum_y f_{X,Y}(x,y) = 1\\)")
            )
          ),
          column(
            width = 5,
            div(style="border-left:1px solid #ddd; padding-left:16px;"),
            cond_panel
          ),
          column(width = 2)
        )
      )
    })
    # ==========================输入逻辑与概率表===========================================    
    # ==========================条件概率表===========================================
    output$cond_table_html <- renderUI({
      df <- pmf_final()
      req(input$cond_type)
      
      if (input$cond_type == "f(Y | X = x0)") {
        req(input$x0)
        x0 <- as.numeric(input$x0)
        sub <- df %>% filter(x == x0)
        total_x <- sum(sub$p_value)
        sub <- sub %>% mutate(cond_p = ifelse(total_x > 0, p_value / total_x, 0))
        title <- paste0("f(Y | X = ", x0, ")")
        var_col <- "y"
      } else {
        req(input$y0)
        y0 <- as.numeric(input$y0)
        sub <- df %>% filter(y == y0)
        total_y <- sum(sub$p_value)
        sub <- sub %>% mutate(cond_p = ifelse(total_y > 0, p_value / total_y, 0))
        title <- paste0("f(X | Y = ", y0, ")")
        var_col <- "x"
      }
      
      withMathJax(
        tags$table(
          class = "pmf-table",
          tags$thead(
            tags$tr(
              tags$th(HTML(paste0("\\(", title, "\\)"))),
              tags$th(HTML("\\(Probability\\)"))
            )
          ),
          tags$tbody(
            lapply(seq_len(nrow(sub)), function(i) {
              tags$tr(
                tags$td(HTML(paste0("\\(", var_col, "=", sub[[var_col]][i], "\\)"))),
                tags$td(HTML(sprintf("\\(%.5f\\)", sub$cond_p[i])))
              )
            }),
            tags$tr(
              tags$th(class = "sumcell", HTML("\\(\\sum =\\)")),
              tags$td(class = "sumcell", HTML(sprintf("\\(%.5f\\)", sum(sub$cond_p))))
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
      if (input$cond_type == "f(Y | X = x0)") {
        selectInput(ns("x0"), "x0 =", choices = sort(unique(df$x)))
      } else {
        selectInput(ns("y0"), "y0 =", choices = sort(unique(df$y)))
      }
    })
    # ========================== 生成条件值选择==========================================  
    # ==== 3D Conditional PMF ====
    output$plot3d_cond <- renderPlotly({
      req(pmf_global$df_final)
      df <- pmf_global$df_final
      if (is.null(df) || nrow(df) == 0) return(NULL)
      if (!"p" %in% names(df)) df$p <- df$p_value
      
      type <- input$cond_type
      if (is.null(type)) return(NULL)
      
      p <- plot_ly()
      
      if (type == "f(Y | X = x0)") {
        req(input$x0)
        x0 <- as.numeric(input$x0)
        sub <- df[df$x == x0, c("y", "p")]
        denom <- sum(sub$p)
        if (denom <= 0) return(NULL)
        sub$p <- sub$p / denom
        sub <- sub[order(sub$y), ]
        
        for (i in seq_len(nrow(sub))) {
          p <- add_trace(
            p, type = "scatter3d", mode = "lines",
            x = c(x0, x0),
            y = c(sub$y[i], sub$y[i]),
            z = c(0, sub$p[i]),
            line = list(color = "steelblue", width = 8),
            hoverinfo = "text",
            text = paste0("X=", x0, "<br>Y=", sub$y[i], "<br>f(Y|X)=", round(sub$p[i], 4)),
            showlegend = FALSE
          )
        }
        
        p %>% layout(
          title = "3D Conditional PMF (Y|X)",
          scene = list(
            xaxis = list(title = "X"),
            yaxis = list(title = "Y"),
            zaxis = list(title = "𝑓₍Y|X₎(y|x)")
          ),
          margin = list(l = 0, r = 0, b = 0, t = 40)
        )
        
      } else if (type == "f(X | Y = y0)") {
        req(input$y0)
        y0 <- as.numeric(input$y0)
        sub <- df[df$y == y0, c("x", "p")]
        denom <- sum(sub$p)
        if (denom <= 0) return(NULL)
        sub$p <- sub$p / denom
        sub <- sub[order(sub$x), ]
        
        for (i in seq_len(nrow(sub))) {
          p <- add_trace(
            p, type = "scatter3d", mode = "lines",
            x = c(sub$x[i], sub$x[i]),
            y = c(y0, y0),
            z = c(0, sub$p[i]),
            line = list(color = "orange", width = 8),
            hoverinfo = "text",
            text = paste0("X=", sub$x[i], "<br>Y=", y0, "<br>f(X|Y)=", round(sub$p[i], 4)),
            showlegend = FALSE
          )
        }
        
        p %>% layout(
          title = "3D Conditional PMF (X|Y)",
          scene = list(
            xaxis = list(title = "X"),
            yaxis = list(title = "Y"),
            zaxis = list(title = "𝑓₍X|Y₎(x|y)")
          ),
          margin = list(l = 0, r = 0, b = 0, t = 40)
        )
      }
    })
    # ==== 3D Conditional PMF ====
    
    # ==== Bird’s-eye Conditional View ====
    output$plot_bird_cond <- renderPlotly({
      req(pmf_global$df_final)
      df <- pmf_global$df_final
      if (is.null(df) || nrow(df) == 0) return(NULL)
      if (!"p" %in% names(df)) df$p <- df$p_value
      
      type <- input$cond_type
      if (is.null(type)) return(NULL)
      
      if (type == "f(Y | X = x0)") {
        req(input$x0)
        x0 <- as.numeric(input$x0)
        sub <- df[df$x == x0, c("y", "p")]
        denom <- sum(sub$p)
        if (denom <= 0) return(NULL)
        sub$p <- sub$p / denom
        
        plot_ly(
          sub, x = ~y, y = ~p,
          type = "bar", marker = list(color = "steelblue"),
          text = ~paste0("Y=", y, "<br>f(Y|X=", x0, ")=", round(p, 4)),
          hoverinfo = "text"
        ) %>% layout(
          title = paste0("Bird’s-eye View: f(Y|X=", x0, ")"),
          xaxis = list(title = "Y"),
          yaxis = list(title = "𝑓₍Y|X₎(y|x)", range = c(0, 1)),
          plot_bgcolor = "#f9f9f9",
          paper_bgcolor = "#f9f9f9"
        )
        
      } else if (type == "f(X | Y = y0)") {
        req(input$y0)
        y0 <- as.numeric(input$y0)
        sub <- df[df$y == y0, c("x", "p")]
        denom <- sum(sub$p)
        if (denom <= 0) return(NULL)
        sub$p <- sub$p / denom
        
        plot_ly(
          sub, x = ~x, y = ~p,
          type = "bar", marker = list(color = "orange"),
          text = ~paste0("X=", x, "<br>f(X|Y=", y0, ")=", round(p, 4)),
          hoverinfo = "text"
        ) %>% layout(
          title = paste0("Bird’s-eye View: f(X|Y=", y0, ")"),
          xaxis = list(title = "X"),
          yaxis = list(title = "𝑓₍X|Y₎(x|y)", range = c(0, 1)),
          plot_bgcolor = "#f9f9f9",
          paper_bgcolor = "#f9f9f9"
        )
      }
    })
    # ==== Bird’s-eye Conditional View ====
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
    <p>Let \\(Y\\) denote the total number of eggs collected in 6 hours, and \\(W\\) the weather condition (Sunny or Cloudy).</p>
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
          ans_val  = 0.263,  # approximate value
          
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
      \\approx0.263.
    \\]
    (Exact value may vary slightly depending on rounding.)
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Since \\(Y\\mid W=\\text{Cloudy}\\sim Poisson(12)\\), we compute:<br><br>
    \\[
      P(Y\\le10\\mid W=\\text{Cloudy})
      =\\sum_{k=0}^{10} e^{-12}\\frac{12^k}{k!}
      \\approx0.263.
    \\]
    Thus, there is about a <b>26.3% chance</b> of collecting 10 or fewer eggs on a cloudy day.
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
    Once we condition on the skill level \\(\\{S=s\\}\\), what is the conditional distribution of \\(Y\\)? 
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          ans_text = "Geometric",
          ans_frac = NA,
          ans_val  = NA,
          
          hint1 = HTML("
    \\(Y\\) counts the number of independent Bernoulli trials until the first success.  
    Think: which named distribution models that waiting time?
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Given \\(S=s\\), the success probability is \\(p_s\\).  
    Therefore \\(Y\\mid S=s\\sim Geometric(p_s)\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given \\(S=s\\), \\(Y\\) counts the number of independent Bernoulli trials until the first success.  
    Hence the conditional distribution is:<br><br>
    \\[
      Y\\mid S=s \\sim Geometric(p_s),
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
    If \\(Y\\mid S=\\text{Novice}\\sim Geometric(p=0.2)\\),  
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
    Given \\(S=\\text{Novice}\\), \\(Y\\mid S\\sim Geometric(p=0.2)\\).<br><br>
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
          
          ans_val = 0.6321,
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
      P(Y\\le2\\mid C=Cloudy)=1-e^{-0.5\\times2}=1-e^{-1}=0.6321.
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
          ans_val  = 0.0475,
          
          hint1 = HTML("
    Standardize the Normal variable:  
    \\[
      Z = \\frac{Y-\\mu}{\\sigma}.
    \\]
    Then \\(P(Y>70)=P(Z>\\frac{70-65}{3})=P(Z>1.67)\\).
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          hint2 = HTML("
    Using the standard normal table, \\(P(Z>1.67)=1-\\Phi(1.67)=1-0.9525=0.0475.\\)  
    Hence, \\(P(Y>70\\mid X=3)=0.0475.\\)
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given \\(Y\\mid X=3\\sim N(65,9)\\),  
    \\[
      P(Y>70\\mid X=3)=1-\\Phi\\left(\\frac{70-65}{3}\\right)
      =1-\\Phi(1.67)\\approx1-0.9525=0.0475.
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
    <p>The distance \\(Y\\) (in meters) depends on the wind level \\(W\\): stronger winds make the sheep stay closer.</p>
    <p>Empirically, the maximum roaming distance increases linearly with wind level \\(W\\):</p>
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
    For a \\(Uniform(a,b)\\) distribution, all values between \\(a\\) and \\(b\\) are equally likely.  
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
          ans_val  = 0.6429,
          
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
      P(Y>50\\mid W=2)=\\frac{140-50}{140-0}=\\frac{90}{140}=0.6429.
    \\]
    <script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Given \\(Y\\mid W=2\\sim Uniform(0,140)\\):  
    \\[
      P(Y>50\\mid W=2)=\\frac{140-50}{140-0}=\\frac{90}{140}=0.6429.
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
    <p>Empirically, conditional on \\(H=h\\), the total energy output follows a Gamma model:</p>
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
    
    # ==== 当前状态 ====
    current_index <- reactiveVal(1)
    result <- reactiveVal(NULL)
    tries <- reactiveVal(0)
    
    # 当前题目
    prob <- reactive({
      req(question_bank[[current_index()]])
      question_bank[[current_index()]]
    })
    
    # ============================================================
    # 1️⃣ 题目输出
    # ============================================================
 
    output$story_out <- renderUI({
      p <- prob(); validate(need(!is.null(p), ""))
      if (is.null(p$story)) return(NULL)
      
      div(
        id = ns("story_mjx"),
        style = "display:inline-block; text-align:center;",
        HTML(p$story)
      )
    })
    
    
    # ============================================================
    # 2️⃣ 题干与附加信息
    # ============================================================
    output$qtext <- renderUI({
      p <- prob(); validate(need(!is.null(p), ""))
      div(
        id = ns("q_mjx"),
        style = "display:inline-block; text-align:center;",
        HTML(p$question)
      )
    })
    
    output$given_out <- renderUI({
      p <- prob()
      if (is.null(p) || is.null(p$given)) return(NULL)
      div(class = "table-note", HTML(p$given))
    })
    
    # ============================================================
    # 3️⃣ 答案检查与反馈
    # ============================================================
    observeEvent(input$check, {
      p <- prob(); validate(need(!is.null(p), ""))
      
      if (is.na(p$ans_val) && is.na(p$ans_frac)) {
        
        correct_text <- tolower(trimws(p$ans_text))
        user_input <- tolower(trimws(input$ans))
        
        ok <- FALSE
        if (!is.null(user_input) && nzchar(user_input) && !is.null(correct_text)) {
          ok <- grepl(correct_text, user_input, ignore.case = TRUE)
        }
        
      } else {
        ok <- is_correct(input$ans, p$ans_val, p$ans_frac)
      }
      
      ok <- isTRUE(ok)
      
      result(list(status = if (ok) "ok" else "no"))
      tries(tries() + if (ok) 3 else 1)
    })
    
    
    output$feedback <- renderUI({
      st <- result(); p <- prob()
      if (is.null(st) || is.null(p)) return(NULL)
      
      ui <- if (st$status == "ok") {
        div(class = "alert alert-success", HTML(p$solution))
      } else if (st$status == "no") {
        if (tries() == 1) {
          div(class = "alert alert-warning", HTML(p$hint1))
        } else if (tries() == 2) {
          div(class = "alert alert-warning", HTML(p$hint2))
        } else {
          div(class = "alert alert-info", HTML(p$solution))
        }
      }
      tags$div(id = ns("fb_mjx"), ui)
    })
    
    # ============================================================
    # 4️⃣ 翻页按钮与逻辑
    # ============================================================
    output$nav_buttons <- renderUI({
      n_total <- length(question_bank)
      idx <- current_index()
      
      btns <- list()
      if (idx > 1)
        btns <- append(btns, list(
          actionButton(ns("back_q"), "← Back",
                       class = "btn btn-secondary btn-block")
        ))
      if (idx < n_total)
        btns <- append(btns, list(
          actionButton(ns("next_q"), "Next →",
                       class = "btn btn-primary btn-block")
        ))
      
      fluidRow(lapply(btns, function(b) column(6, b)))
    })
    
    observeEvent(input$back_q, {
      idx <- current_index()
      if (idx > 1) {
        current_index(idx - 1)
        result(NULL); tries(0)
      }
    })
    
    observeEvent(input$next_q, {
      idx <- current_index()
      if (idx < length(question_bank)) {
        current_index(idx + 1)
        result(NULL); tries(0)
      }
    })
    
    output$answer_input <- renderUI({
      p <- prob(); validate(need(!is.null(p), ""))
      
      # 🧠 判断是不是 Named Distribution 题
      is_named <- is.na(p$ans_val) && is.na(p$ans_frac)
      
      placeholder_text <- if (is_named) {
        "Input a named distribution"
      } else {
        "Input fractions such as 3/7 or decimals"
      }
      
      textInput(
        ns("ans"),
        label = NULL,
        placeholder = placeholder_text,
        width = "100%"
      )
    })
  })
}
