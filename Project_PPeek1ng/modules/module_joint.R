# =====================================================================
#  module_joint.R — Joint Distribution Module
# =====================================================================
library(shiny)
library(shinyjs)
library(dplyr)
# ---- bind global pmf ----
pmf_global <- get0("pmf_global", envir = .GlobalEnv, inherits = FALSE)
if (is.null(pmf_global)) {
  stop("pmf_global is not initialised in .GlobalEnv. Define it in main.R before sourcing modules.")
}

# ---- Helper: Table CSS ----
joint_css <- tags$head(tags$style(HTML("
.pmf-table { border-collapse: collapse; margin-top: 10px; }
.pmf-table th, .pmf-table td {
  border: 1.6px solid #333; padding: 6px 10px; text-align: center;
}
.pmf-table th.corner { font-style: italic; white-space: nowrap; }
.pmf-table .sumcell { font-weight: 600; background:#fafafa; }
")))

# ---- parse: 分数/小数 -> 数值（保留5位） ----
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

# ---- 小数近似成分数（边际展示用）----
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

# ============================================================
# 🔧 Local helper functions (only for this module)
# ============================================================

# ---- Wrap HTML/MathJax container ----
wrap_div <- function(id, content) {
  div(
    id = id,
    style = "padding: 8px; font-size: 16px; line-height: 1.6;",
    content
  )
}

# ---- Flexible answer check (5 decimal places, rounded) ----
is_correct <- function(user_input, ans_val = NA, ans_frac = NA, ans_text = NA, tol = 1e-4) {
  # 空输入直接 FALSE
  if (is.null(user_input) || trimws(user_input) == "") return(FALSE)
  input_str <- trimws(user_input)
  
  # ---- 1️⃣ 文字题模糊匹配（不区分大小写）----
  if (!is.na(ans_text) && is.character(ans_text)) {
    keyword <- tolower(trimws(ans_text))
    user_lower <- tolower(input_str)
    # 模糊匹配：输入包含关键词即可
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
    # 支持多个正确数值（任意一个匹配即可）
    return(any(abs(user_val - ans_val) < tol, na.rm = TRUE))
  }
  
  # ---- 4️⃣ 如果定义了 ans_frac（例如 "1/9"）----
  if (!is.na(ans_frac) && is.character(ans_frac)) {
    frac_val <- parse_to_numeric(ans_frac)
    return(!is.na(user_val) && abs(user_val - frac_val) < tol)
  }
  
  # ---- 5️⃣ 否则都不匹配 ----
  FALSE
}


# =====================================================================
#  UI 
# =====================================================================
joint_UI <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    useShinyjs(),
    joint_css, 
    fluidRow(
      # ---------------- 左侧：公式 + 参数输入 ----------------
      column(
        width = 3,
        box(
          title = "Joint Distribution Theory",
          width = 12, status = "primary",solidHeader = TRUE,
          withMathJax(
            tagList(
              h4("Joint Probability"),
              p("The joint probability mass functiondescribes how two discrete random variables, X and Y, take on values together."),
              HTML("$$f_{X,Y}(x,y) = P(X = x, Y = y)$$"),
              
              tags$hr(),
              
              h5("Definition"),
              p("The joint PMF gives the probability that X equals x and Y equals y simultaneously:"),
              HTML("$$f_{X,Y}(x,y) \\ge 0, \\quad \\sum_x \\sum_y f_{X,Y}(x,y) = 1$$"),
              
              tags$hr(),
              
              h5("Marginal Distributions"),
              p("From the joint PMF, we can find the marginal PMFs by summing over the other variable:"),
              HTML("$$f_X(x) = \\sum_y f_{X,Y}(x,y), \\qquad f_Y(y) = \\sum_x f_{X,Y}(x,y)$$"),
              p("These marginals show the individual behavior of X and Y, ignoring the other variable."),
              
              tags$hr(),
              
              h5("Interpretation"),
              p("Tabulating or plotting the joint PMF helps us visualize how X and Y vary together."),
              p("High probability cells indicate likely combinations of (x, y), while low probability cells show rare outcomes.")
            )
          )
        ),
        box(
          title = "Parameter Input", width = 12, status = "info", solidHeader = TRUE,
          uiOutput(ns("input_panel"))
        )
      ),
      
      # ---------------- 右侧：表格 + 图 + 练习 ----------------
      column(
        width = 9,
        box(
          title = "Probability Table", width = 12, status = "primary", solidHeader = TRUE,
          # ✅ 用 withMathJax() 让表格中的公式渲染
          withMathJax(uiOutput(ns("joint_table_html")))
        ),
        
        # 3D + Bird's-eye 并列
        fluidRow(
          column(
            width = 6,
            box(
              title = "3D Joint PMF", width = 12, status = "info",solidHeader = TRUE,
              plotlyOutput(ns("plot3d"), height = "400px")
            )
          ),
          column(
            width = 6,
            box(
              title = "Bird’s-eye View (Joint)", width = 12, status = "info",solidHeader = TRUE,
              plotlyOutput(ns("plot_bird"), height = "400px")
            )
          )
        ),
        
        # ---------------- 练习模块 ----------------
        box(
          title = NULL, width = 12, status = "warning", solidHeader = FALSE,
          tags$h4(
            "Joint Exercises",
            style = "margin-top:0; font-weight:600; color:#333;"
          ),
          
          # ✅ 整个练习部分都包在 withMathJax() 里
          withMathJax(
            # ==== 居中区域（题目表格 + 题干）====
            div(
              style = "text-align:center; margin-top:10px;",
              uiOutput(ns("table_out"))
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
            
            # ==== 答案输入 ====
            textInput(
              ns("ans"),
              label = NULL,
              placeholder = "Input fractions such as 3/7 or decimals",
              width = "100%"
            ),
            
            actionButton(
              ns("check"), "Submit",
              class = "btn btn-success btn-block",
              style = "margin-top:5px; font-weight:600;"
            ),
            
            # ==== 反馈与翻页 ====
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

# =========================================================
#  SERVER
# =========================================================
joint_Server <- function(id) {
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
    
    # 本地副本（用 isolate 取初值，防访问冲突）
    pmf_edit    <- reactiveVal(isolate(pmf_global$df_edit))
    pmf_final   <- reactiveVal(isolate(pmf_global$df_final))
    row_counter <- reactiveVal(isolate(pmf_global$counter))
    
    # 仅在 has_final=TRUE 时，接受全局推送（避免刚进入被旧数据覆盖）
    observe({
      req(isTRUE(isolate(pmf_global$has_final)))
      pmf_edit(pmf_global$df_edit)
      pmf_final(pmf_global$df_final)
      row_counter(pmf_global$counter)
    })
    
    # ==========================================================
    # 🧩 Input UI
    # ==========================================================
    output$input_panel <- renderUI({
      df <- pmf_edit()
      # 防止启动时 id 不存在导致报错
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
    
    # ==========================================================
    # 数据更新逻辑
    # ==========================================================
    df_current <- reactive({
      df <- pmf_edit()
      
      needed_cols  <- c("x", "y", "p_input", "p_value", "id")
      missing_cols <- setdiff(needed_cols, names(df))
      if (length(missing_cols) > 0) {
        for (col in missing_cols) {
          df[[col]] <- switch(col,
                              x = 0, y = 0, p_input = "0", p_value = 0, id = seq_len(nrow(df)))
        }
      }
      
      for (i in df$id) {
        p_in <- input[[paste0("p_", i)]]
        x_in <- input[[paste0("x_", i)]]
        y_in <- input[[paste0("y_", i)]]
        if (!is.null(p_in)) {
          df$p_input[df$id == i] <- p_in
          df$p_value[df$id == i] <- parse_user_prob(p_in, digits = 5)
        }
        if (!is.null(x_in)) df$x[df$id == i] <- as.numeric(x_in)
        if (!is.null(y_in)) df$y[df$id == i] <- as.numeric(y_in)
      }
      df
    })
    
    # ==========================================================
    # Add Row
    # ==========================================================
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
    
    # ==========================================================
    # Normalize
    # ==========================================================
    observeEvent(input$normalize, {
      df <- df_current()
      total <- sum(df$p_value, na.rm = TRUE)
      if (total > 0) {
        df$p_value <- df$p_value / total
        df$p_input <- sprintf("%.5f", df$p_value)
        pmf_edit(df)
        pmf_global$df_edit <- df
      } else {
        showNotification("All probabilities are zero — cannot normalize.", type = "error")
      }
    })
    
    # ==========================================================
    # Uniform
    # ==========================================================
    observeEvent(input$uniform, {
      df <- pmf_edit()
      if (nrow(df) > 0) {
        df$p_value <- rep(1 / nrow(df), nrow(df))
        df$p_input <- sprintf("%.5f", df$p_value)
        pmf_edit(df)
        pmf_global$df_edit <- df
      }
    })
    
    # ==========================================================
    # Delete Row
    # ==========================================================
    observe({
      df <- pmf_edit()
      ids <- df$id
      if (length(ids) == 0) return(NULL)
      lapply(ids, function(i) {
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
    
    # ---- Joint Table ----
    output$joint_table_html <- renderUI({
      df <- pmf_final()
      if (is.null(df) || nrow(df) == 0)
        return(HTML("<i>No PMF generated yet.</i>"))
      
      mat <- xtabs(p_value ~ x + y, data = df)
      xs <- as.numeric(rownames(mat))
      ys <- as.numeric(colnames(mat))
      row_tot <- rowSums(mat)
      col_tot <- colSums(mat)
      
      table_html <- tags$table(
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
      
      tagList(
        withMathJax(),
        fluidRow(
          column(width = 4),  
          column(width = 8,
                 table_html,
                 tags$div(style = "margin-top:8px; color:#666; font-size:13px;",
                          HTML("\\(\\sum_x \\sum_y f_{X,Y}(x,y) = 1\\)"))
          )
        )
      )
    })
    # ==========================输入逻辑与概率表===========================================

    # ==== 3D Joint PMF Plot ====
    output$plot3d <- renderPlotly({
      req(pmf_global$df_final)   # 🔁 从全局同步
      df <- pmf_global$df_final
      if (is.null(df) || nrow(df) == 0) return(NULL)
      
      # 确保字段名一致（有些版本用 p_value）
      if (!"p" %in% names(df)) df$p <- df$p_value
      
      p <- plot_ly()
      for (i in seq_len(nrow(df))) {
        p <- add_trace(
          p, type = "scatter3d", mode = "lines",
          x = c(df$x[i], df$x[i]),
          y = c(df$y[i], df$y[i]),
          z = c(0, df$p[i]),
          line = list(color = "steelblue", width = 8),
          hoverinfo = "text",
          text = paste0("X=", df$x[i], "<br>Y=", df$y[i], "<br>P=", round(df$p[i], 4)),
          showlegend = FALSE
        )
      }
      
      p %>% layout(
        title = "3D Joint PMF",
        scene = list(
          xaxis = list(title = "X"),
          yaxis = list(title = "Y"),
          zaxis = list(title = "f₍X,Y₎(x,y)")
        ),
        margin = list(l = 0, r = 0, b = 0, t = 40)
      )
    })
    # ==== 3D Joint PMF Plot ====
    # ==== Bird’s-eye View ====
    output$plot_bird <- renderPlotly({
      req(pmf_global$df_final)
      df <- pmf_global$df_final
      if (is.null(df) || nrow(df) == 0) return(NULL)
      
      if (!"p" %in% names(df)) df$p <- df$p_value
      
      plot_ly(
        df, x = ~x, y = ~y,
        type = "scatter", mode = "markers",
        text = ~paste0("X=", x, "<br>Y=", y, "<br>P=", round(p, 4)),
        hoverinfo = "text"
      ) %>%
        layout(
          title = "Bird’s-eye View (2D)",
          xaxis = list(title = "X"),
          yaxis = list(title = "Y"),
          plot_bgcolor = "#f9f9f9",
          paper_bgcolor = "#f9f9f9"
        )
    })
    # ==== Bird’s-eye View ====
    # ============================================================
    # 📘 Joint PMF Question Bank
    # ============================================================
    
    get_joint_question_bank <- function() {
      list(
        # === Q1 — Joint probability (lookup) ===
        list(
          id = 1,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead>
      <tr>
        <th class='corner outer'>\\(f_{X,Y}(x,y)\\)</th>
        <th>\\(x=0\\)</th><th>\\(x=1\\)</th><th>\\(x=2\\)</th>
      </tr>
    </thead>
    <tbody>
      <tr><th>\\(y=0\\)</th><td>\\(\\tfrac{1}{8}\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{24}\\)</td></tr>
      <tr><th>\\(y=1\\)</th><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{8}\\)</td><td>\\(\\tfrac{1}{24}\\)</td></tr>
      <tr><th>\\(y=2\\)</th><td>\\(\\tfrac{1}{24}\\)</td><td>\\(\\tfrac{1}{24}\\)</td><td>\\(\\tfrac{1}{8}\\)</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Find the joint probability \\(P(X=1,\\,Y=1)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '1/8',
          ans_val  = 1/8,
          
          # Hint1：定位交叉单元格
          hint1 = HTML("
    Locate the cell at column \\(X=1\\) and row \\(Y=1\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # Hint2：强调“该单元格即为联合概率”，但不直接给数值
          hint2 = HTML("
    The entry at that intersection equals \\(P(X=1, Y=1)\\).
    Use the value shown in the table (you may express it as a simplified fraction or as a decimal to 5 places).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    The intersection of \\(X=1\\) and \\(Y=1\\) gives \\(f_{X,Y}(1,1)=\\tfrac{1}{8}.\\)
    Hence, \\(P(X=1, Y=1)=\\tfrac{1}{8}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q2 — Joint probability (lookup #2) ===
        list(
          id = 2,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead>
      <tr>
        <th class='corner outer'>\\(f_{X,Y}(x,y)\\)</th>
        <th>\\(x=0\\)</th><th>\\(x=1\\)</th><th>\\(x=2\\)</th>
      </tr>
    </thead>
    <tbody>
      <tr><th>\\(y=0\\)</th><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{20}\\)</td><td>\\(\\tfrac{1}{20}\\)</td></tr>
      <tr><th>\\(y=1\\)</th><td>\\(\\tfrac{1}{5}\\)</td><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{20}\\)</td></tr>
      <tr><th>\\(y=2\\)</th><td>\\(\\tfrac{1}{20}\\)</td><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{10}\\)</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Find the joint probability \\(P(X=2,\\,Y=1)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '1/20',
          ans_val  = 1/20,
          
          # Hint1：引导定位
          hint1 = HTML("
    Locate the cell corresponding to \\(X=2\\) (column) and \\(Y=1\\) (row).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # Hint2：提示该单元格即目标，但不泄露答案数值
          hint2 = HTML("
    The value at that cell represents \\(P(X=2, Y=1)\\).
    Read the number directly from the table and enter it as a fraction or decimal rounded to 5 digits.
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    The intersection of \\(X=2\\) and \\(Y=1\\) gives \\(f_{X,Y}(2,1)=\\tfrac{1}{20}.\\)
    Hence, \\(P(X=2, Y=1)=\\tfrac{1}{20}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q3 — Marginal f_X(1) ===
        list(
          id = 3,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead><tr>
      <th class='corner outer'>\\(f_{X,Y}(x,y)\\)</th>
      <th>\\(x=0\\)</th><th>\\(x=1\\)</th><th>\\(x=2\\)</th>
    </tr></thead>
    <tbody>
      <tr><th>\\(y=0\\)</th><td>\\(\\tfrac{1}{9}\\)</td><td>\\(\\tfrac{1}{9}\\)</td><td>\\(\\tfrac{1}{9}\\)</td></tr>
      <tr><th>\\(y=1\\)</th><td>\\(\\tfrac{1}{18}\\)</td><td>\\(\\tfrac{1}{6}\\)</td><td>\\(\\tfrac{1}{18}\\)</td></tr>
      <tr><th>\\(y=2\\)</th><td>\\(\\tfrac{1}{18}\\)</td><td>\\(\\tfrac{1}{9}\\)</td><td>\\(\\tfrac{1}{6}\\)</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Compute the marginal probability \\(f_X(1)=\\sum_y f_{X,Y}(1,y)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '7/18',
          ans_val  = 7/18,
          
          # ✅ Hint1：说明要对 y 求和
          hint1 = HTML("
    To compute the marginal \\(f_X(1)\\), sum all joint probabilities in the column where \\(x=1\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Hint2：引导到计算过程，但不直接给结果
          hint2 = HTML("
    Identify the values in the column for \\(x=1\\): \\(f_{X,Y}(1,0), f_{X,Y}(1,1), f_{X,Y}(1,2)\\). 
    Then add them together to obtain \\(f_X(1)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ 完整解答
          solution = HTML("
    <b>Solution:</b><br>
    \\(f_X(1)=f_{X,Y}(1,0)+f_{X,Y}(1,1)+f_{X,Y}(1,2)\\)<br>
    \\(=\\tfrac{1}{9}+\\tfrac{1}{6}+\\tfrac{1}{9}=\\tfrac{7}{18}\\approx0.389.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q4 — Marginal f_Y(0) ===
        list(
          id = 4,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead><tr>
      <th class='corner outer'>\\(f_{X,Y}(x,y)\\)</th>
      <th>\\(x=0\\)</th><th>\\(x=1\\)</th><th>\\(x=2\\)</th><th>\\(x=3\\)</th>
    </tr></thead>
    <tbody>
      <tr><th>\\(y=0\\)</th><td>\\(\\tfrac{1}{24}\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{8}\\)</td><td>\\(\\tfrac{1}{24}\\)</td></tr>
      <tr><th>\\(y=1\\)</th><td>\\(\\tfrac{1}{24}\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{8}\\)</td><td>\\(\\tfrac{1}{24}\\)</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Compute the marginal probability \\(f_Y(0)=\\sum_x f_{X,Y}(x,0)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '1/4',
          ans_val  = 1/4,
          
          # ✅ Hint1：说明行方向求和
          hint1 = HTML("
    To find the marginal \\(f_Y(0)\\), add up all the joint probabilities in the row where \\(y=0\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Hint2：引导识别哪些单元格相加，不直接给结果
          hint2 = HTML("
    Identify each cell along the row \\(y=0\\): \\(f_{X,Y}(0,0), f_{X,Y}(1,0), f_{X,Y}(2,0), f_{X,Y}(3,0)\\).
    Then sum these four probabilities to obtain \\(f_Y(0)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Solution：完整计算过程
          solution = HTML("
    <b>Solution:</b><br>
    \\(f_Y(0)=f_{X,Y}(0,0)+f_{X,Y}(1,0)+f_{X,Y}(2,0)+f_{X,Y}(3,0)\\)<br>
    \\(=\\tfrac{1}{24}+\\tfrac{1}{12}+\\tfrac{1}{8}+\\tfrac{1}{24}=\\tfrac{1}{4}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q5 — Region event: P(X>0, Y≤1) ===
        list(
          id = 5,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead><tr>
      <th class='corner outer'>\\(f_{X,Y}(x,y)\\)</th>
      <th>\\(x=0\\)</th><th>\\(x=1\\)</th><th>\\(x=2\\)</th>
    </tr></thead>
    <tbody>
      <tr><th>\\(y=0\\)</th><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{5}\\)</td></tr>
      <tr><th>\\(y=1\\)</th><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{10}\\)</td></tr>
      <tr><th>\\(y=2\\)</th><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{10}\\)</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Find \\(P(X>0,\\,Y\\le1)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '2/5',
          ans_val  = 2/5,
          
          # ✅ Hint1：说明选取哪些区域
          hint1 = HTML("
    The event \\(X>0, Y\\le1\\) includes all cells where \\(x=1,2\\) and \\(y=0,1\\).
    Highlight those four cells in the table.
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Hint2：说明如何相加，不直接给出结果
          hint2 = HTML("
    Add the probabilities of the four selected cells:
    \\(f_{X,Y}(1,0), f_{X,Y}(1,1), f_{X,Y}(2,0), f_{X,Y}(2,1)\\).
    Their sum gives \\(P(X>0, Y\\le1)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Solution：完整解答
          solution = HTML("
    <b>Solution:</b><br>
    \\(P(X>0, Y\\le1) = f_{X,Y}(1,0) + f_{X,Y}(1,1) + f_{X,Y}(2,0) + f_{X,Y}(2,1)\\)<br>
    \\(= \\tfrac{1}{10} + \\tfrac{1}{10} + \\tfrac{1}{5} + \\tfrac{1}{10} = \\tfrac{2}{5}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q6 — Region event: P(X+Y≥3) ===
        list(
          id = 6,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead><tr>
      <th class='corner outer'>\\(f_{X,Y}(x,y)\\)</th>
      <th>\\(x=0\\)</th><th>\\(x=1\\)</th><th>\\(x=2\\)</th>
    </tr></thead>
    <tbody>
      <tr><th>\\(y=0\\)</th><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{6}\\)</td></tr>
      <tr><th>\\(y=1\\)</th><td>\\(\\tfrac{1}{8}\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{8}\\)</td></tr>
      <tr><th>\\(y=2\\)</th><td>\\(\\tfrac{1}{24}\\)</td><td>\\(\\tfrac{1}{8}\\)</td><td>\\(\\tfrac{1}{6}\\)</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Compute \\(P(X+Y\\ge3)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '7/24',
          ans_val  = 7/24,
          
          # ✅ Hint1：帮助学生确定条件区域
          hint1 = HTML("
    Identify all \\((x,y)\\) pairs where \\(x + y \\ge 3\\).
    Mark those cells in the table before summing their probabilities.
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Hint2：提示哪些具体格子被选中，但不直接给数值
          hint2 = HTML("
    The qualifying cells are where \\(x+y=3\\) or \\(x+y>3\\), for example \\((1,2)\\), \\((2,1)\\), and \\((2,2)\\).
    Add their probabilities to get \\(P(X+Y\\ge3)\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Solution：展示计算过程
          solution = HTML("
    <b>Solution:</b><br>
    The cells satisfying \\(x+y\\ge3\\) are \\((1,2), (2,1), (2,2)\\).<br>
    \\(P(X+Y\\ge3) = f_{X,Y}(1,2) + f_{X,Y}(2,1) + f_{X,Y}(2,2)\\)<br>
    \\(= \\tfrac{1}{8} + \\tfrac{1}{8} + \\tfrac{1}{6} = \\tfrac{7}{24}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q7 — Missing entry (normalization) ===
        list(
          id = 7,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead><tr>
      <th class='corner outer'>\\(f_{X,Y}(x,y)\\)</th>
      <th>\\(x=0\\)</th><th>\\(x=1\\)</th><th>\\(x=2\\)</th>
    </tr></thead>
    <tbody>
      <tr><th>\\(y=0\\)</th><td>\\(\\tfrac{1}{8}\\)</td><td>\\(\\tfrac{1}{8}\\)</td><td>?</td></tr>
      <tr><th>\\(y=1\\)</th><td>\\(\\tfrac{1}{6}\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{8}\\)</td></tr>
      <tr><th>\\(y=2\\)</th><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{6}\\)</td><td>\\(\\tfrac{1}{12}\\)</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Find the missing probability value (?) so that \\(\\sum_x\\sum_y f_{X,Y}(x,y) = 1\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '1/8',
          ans_val  = 1/8,
          
          # ✅ Hint1：提示整体思路
          hint1 = HTML("
    Add up all the known probabilities in the table.  
    The total must equal 1 after including the missing cell.
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Hint2：提示代数关系，不直接给结果
          hint2 = HTML("
    Let the missing value be \\(p\\).  
    Then \\(p = 1 - (\\text{sum of all known entries})\\).  
    Compute the sum of all visible fractions, and solve for \\(p\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Solution：详细演算步骤
          solution = HTML("
    <b>Solution:</b><br>
    Let the missing entry be \\(p\\).  
    All probabilities must sum to 1, so
    \\[
      p = 1 - \\Big(
        \\tfrac{1}{8} + \\tfrac{1}{8} + \\tfrac{1}{6} + \\tfrac{1}{12} + 
        \\tfrac{1}{8} + \\tfrac{1}{12} + \\tfrac{1}{6} + \\tfrac{1}{12}
      \\Big)
      = 1 - \\tfrac{7}{8} = \\tfrac{1}{8}.
    \\]
    Therefore, the missing probability is \\(\\tfrac{1}{8}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q8 — Unknown a (normalization constant) ===
        list(
          id = 8,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead><tr>
      <th class='corner outer'>\\(f_{X,Y}(x,y)\\)</th>
      <th>\\(x=0\\)</th><th>\\(x=1\\)</th><th>\\(x=2\\)</th>
    </tr></thead>
    <tbody>
      <tr><th>\\(y=0\\)</th><td>\\(\\tfrac{1}{5}\\)</td><td>\\(\\tfrac{1}{10}\\)</td><td>\\(a\\)</td></tr>
      <tr><th>\\(y=1\\)</th><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{5}\\)</td><td>\\(\\tfrac{1}{10}\\)</td></tr>
      <tr><th>\\(y=2\\)</th><td>\\(a\\)</td><td>\\(\\tfrac{1}{10}\\)</td><td>\\(\\tfrac{1}{5}\\)</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Find the value of \\(a\\) such that the total probability equals 1:
    \\[
      \\sum_x \\sum_y f_{X,Y}(x,y) = 1.
    \\]
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '1/10',
          ans_val  = 1/10,
          
          # ✅ Hint1：整体思路
          hint1 = HTML("
    To find the constant \\(a\\), sum all probabilities in the table.  
    The total must equal 1.  
    Identify which cells contain \\(a\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Hint2：引导建立方程
          hint2 = HTML("
    The total probability can be written as  
    \\[
      (\\text{sum of numeric entries}) + (\\text{number of } a \\text{ terms})\\times a = 1.
    \\]
    There are two cells with \\(a\\), so form the equation \\(0.8 + 2a = 1\\), then solve for \\(a\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Solution：完整推导
          solution = HTML("
    <b>Solution:</b><br>
    Sum all fixed probabilities:
    \\[
      \\tfrac{1}{5} + \\tfrac{1}{10} + \\tfrac{1}{10} + \\tfrac{1}{5} + \\tfrac{1}{10} + \\tfrac{1}{10} + \\tfrac{1}{5} = 0.8.
    \\]
    There are two unknown cells with value \\(a\\), so
    \\[
      0.8 + 2a = 1 \\Rightarrow a = 0.1 = \\tfrac{1}{10}.
    \\]
    Therefore, \\(a = \\tfrac{1}{10}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q9 — Parameter k ===
        list(
          id = 9,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead><tr>
      <th>x</th><th>y</th><th>\\(f_{X,Y}(x,y)\\)</th>
    </tr></thead>
    <tbody>
      <tr><td>0</td><td>0</td><td>0</td></tr>
      <tr><td>0</td><td>1</td><td>k</td></tr>
      <tr><td>0</td><td>2</td><td>2k</td></tr>
      <tr><td>1</td><td>0</td><td>k</td></tr>
      <tr><td>1</td><td>1</td><td>2k</td></tr>
      <tr><td>1</td><td>2</td><td>3k</td></tr>
      <tr><td>2</td><td>0</td><td>2k</td></tr>
      <tr><td>2</td><td>1</td><td>3k</td></tr>
      <tr><td>2</td><td>2</td><td>4k</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Find the value of \\(k\\) such that
    \\[
      \\sum_x \\sum_y f_{X,Y}(x,y) = 1.
    \\]
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '1/18',
          ans_val  = 1/18,
          
          # ✅ Hint1：引导思路
          hint1 = HTML("
    Observe that each probability is a multiple of \\(k\\).  
    Add up all the coefficients of \\(k\\); their total must equal 1.
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Hint2：建立方程，但不直接给结果
          hint2 = HTML("
    The coefficients of \\(k\\) are: 1, 2, 1, 2, 3, 2, 3, 4.  
    Summing them gives 18.  
    Form the equation \\(18k = 1\\) and solve for \\(k\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          # ✅ Solution：完整推导
          solution = HTML("
    <b>Solution:</b><br>
    Sum all nonzero entries:
    \\[
      (1 + 2 + 1 + 2 + 3 + 2 + 3 + 4)k = 18k.
    \\]
    To satisfy the normalization condition \\(\\sum_x\\sum_y f_{X,Y}(x,y)=1\\),
    \\[
      18k = 1 \\Rightarrow k = \\tfrac{1}{18}.
    \\]
    Therefore, \\(k = \\tfrac{1}{18}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        ),
        
        # === Q10 — Parameter p ===
        list(
          id = 10,
          table_ui = HTML("
  <table class='pmf-table'>
    <thead><tr>
      <th>\\(x\\)</th>
      <th>\\(y=0\\)</th>
      <th>\\(y=1\\)</th>
      <th>\\(y=2\\)</th>
      <th>\\(\\sum_y f_{X,Y}(x,y)\\)</th>
    </tr></thead>
    <tbody>
      <tr><th>\\(x=0\\)</th><td>\\(p\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>\\(\\tfrac{1}{6}\\)</td><td>?</td></tr>
      <tr><th>\\(x=1\\)</th><td>\\(\\tfrac{1}{12}\\)</td><td>\\(p\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>?</td></tr>
      <tr><th>\\(x=2\\)</th><td>\\(\\tfrac{1}{6}\\)</td><td>\\(\\tfrac{1}{12}\\)</td><td>\\(p\\)</td><td>?</td></tr>
      <tr><th>\\(\\sum_x f_{X,Y}(x,y)\\)</th><td>?</td><td>?</td><td>?</td><td>1</td></tr>
    </tbody>
  </table>
  <script type='text/javascript'>
    if (window.MathJax && MathJax.Hub) {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
    }
  </script>
  "),
          
          question = HTML("
    Find the value of \\(p\\) such that
    \\[
      \\sum_x \\sum_y f_{X,Y}(x,y) = 1.
    \\]
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          ans_frac = '1/9',
          ans_val  = 1/9,
          
          hint1 = HTML("
    Each entry represents \\(f_{X,Y}(x,y)\\).  
    Add all the table values together (including those containing \\(p\\)),  
    and ensure the total equals 1.
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          hint2 = HTML("
    There are three cells with \\(p\\).  
    Sum all numeric probabilities first:
    \\[
      \\tfrac{1}{6} + \\tfrac{1}{6} + 4\\times\\tfrac{1}{12} = \\tfrac{2}{3}.
    \\]
    Form the normalization equation:
    \\[
      3p + \\tfrac{2}{3} = 1.
    \\]
    Solve for \\(p\\).
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  "),
          
          solution = HTML("
    <b>Solution:</b><br>
    Using the total probability condition:
    \\[
      3p + \\tfrac{2}{3} = 1 \\Rightarrow p = \\tfrac{1}{9}.
    \\]
    Therefore, \\(p = \\tfrac{1}{9}.\\)
    <script type='text/javascript'>
      if (window.MathJax && MathJax.Hub) {
        MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
      }
    </script>
  ")
        )
      )
    }
    # ============================================================
    # 题目逻辑 
    # ============================================================
    
    # ==== 题库 ====
    question_bank <- get_joint_question_bank()
    
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
    # 1️⃣ 题目表格输出
    # ============================================================
    output$table_out <- renderUI({
      p <- prob(); validate(need(!is.null(p), ""))
      tbl <- p$table_ui
      if (is.character(tbl)) tbl <- HTML(tbl)
      
      # 直接输出表格（无需 MathJax 手动刷新）
      div(
        id = ns("tbl_mjx"),
        style = "display:inline-block;",
        tbl
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
      
      ok <- is_correct(input$ans, p$ans_val, p$ans_frac)
      result(list(status = if (ok) "ok" else "no"))
      tries(tries() + if (ok) 3 else 1)
    })
    
    output$feedback <- renderUI({
      st <- result(); p <- prob()
      if (is.null(st) || is.null(p)) return(NULL)
      
      # 用 HTML() 确保公式正常渲染
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
  })
}