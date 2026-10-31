# =====================================================================
#  module_joint.R — Joint Distribution Module
# =====================================================================
library(shiny)
library(shinyjs)
library(dplyr)

# ---- Helper: Table CSS ----
joint_css <- tags$head(tags$style(HTML("
.pmf-table { border-collapse: collapse; margin-top: 10px; }
.pmf-table th, .pmf-table td {
  border: 1.6px solid #333; padding: 6px 10px; text-align: center;
}
.pmf-table th.corner { font-style: italic; white-space: nowrap; }
.pmf-table .sumcell { font-weight: 600; background:#fafafa; }
")))

# ---- Shared probability parsing and validation ----
# main.R loads pmf_helpers.R before this module; direct module tests must do so too.

# ---- 小数近似成分数（边际展示用）----
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
# Answer validation is shared in pmf_helpers.R.


# =====================================================================
#  UI 
# =====================================================================
joint_UI <- function(id) {
  tagList(useShinyjs(), joint_css, learning_table_module_ui(id,"Joint Distribution",
    theory=withMathJax(
            tagList(
              h4("Joint Probability"),
              p("The joint probability mass function describes how two discrete random variables, X and Y, take on values together."),
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
          ),plot_ids=c("plot_bird","plot3d")))
}

# =========================================================
#  SERVER
# =========================================================
joint_Server <- function(id, shared = new_pmf_state(), course_path = function() "core", open_plot = NULL) {
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
    
    # 本地副本（用 isolate 取初值，防访问冲突）
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
    
    # ==========================================================
    # 🧩 Input UI
    # ==========================================================
    output$input_panel <- renderUI({
      df <- pmf_edit()
      # 防止启动时 id 不存在导致报错
      if (is.null(df) || !"id" %in% names(df)) {
        return(tags$div(style="color:#888; padding:10px;", "Initializing table..."))
      }
      tagList(
        selectInput(ns("pmf_example"), "Worked example", choices = c("Two Ace indicators"="cards", "20 fictional observations"="counts20", "Zero conditioning probability"="zero_x")),
        actionButton(ns("load_pmf_example"), "Load worked example", class="btn-outline-primary"),
        h4("Input (x, y, p):"),
        helpText("Enter non-negative probabilities or weights. Generate Table merges repeated outcomes and normalizes the total to 1. Normalize changes the draft inputs only."),
        uiOutput(ns("input_feedback")),
        lapply(seq_len(nrow(df)), function(i) {
          div(class = "pmf-edit-row",
            div(class = "pmf-edit-prob", textInput(ns(paste0("p_", df$id[i])), "p", value = df$p_input[i])),
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
          df$p_value[df$id == i] <- parse_user_prob(p_in)
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
      
      new_id <- row_counter() + 1L
      row_counter(new_id)
      new_row <- data.frame(x = 1, y = 1, p_input = "0", p_value = 0, id = new_id)
      df <- dplyr::bind_rows(df, new_row)
      
      pmf_edit(df)
      pmf_global$df_edit <- df
      pmf_global$counter <- new_id
    })
    
    # Shared validation and draft/commit actions
    pmf_actions <- pmf_bind_actions(input, output, session, df_current, pmf_edit,
                     pmf_final, row_counter, pmf_global)
    
    
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
            pmf_global$counter <- row_counter()
          })
        }, ignoreInit = TRUE)
      })
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
        table_html,
        tags$div(class="small-note",style="margin-top:8px; font-size:13px;",
                 HTML("\\(\\sum_x \\sum_y f_{X,Y}(x,y) = 1\\)"))
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
      # Integer weights are the single source for each table, answer and explanation.
      matrix_rows <- function(values, columns=3) matrix(values,ncol=columns,byrow=TRUE)
      specs <- list(
        list(w=matrix_rows(c(3,2,8,2,3,1,1,1,3)),d=24,kind="lookup",x=1,y=1),
        list(w=matrix_rows(c(6,1,1,4,2,1,1,2,2)),d=20,kind="lookup",x=2,y=1),
        list(w=matrix_rows(c(3,2,2,1,3,1,1,2,3)),d=18,kind="marginal_x",x=1),
        list(w=matrix_rows(c(1,2,3,1,11,2,3,1),4),d=24,kind="marginal_y",y=0),
        list(w=matrix_rows(c(1,1,2,1,1,1,1,1,1)),d=10,kind="region"),
        list(w=matrix_rows(c(2,2,4,3,2,3,1,3,4)),d=24,kind="sum"),
        list(w=matrix_rows(c(3,3,0,4,2,3,2,4,2)),d=24,kind="parameter",
             parameter="p",missing=TRUE,coeff=matrix_rows(c(0,0,1,0,0,0,0,0,0))),
        list(w=matrix_rows(c(2,1,0,1,2,1,0,1,2)),d=10,kind="parameter",
             parameter="a",coeff=matrix_rows(c(0,0,1,0,0,0,1,0,0))),
        list(w=matrix_rows(rep(0,9)),d=1,kind="parameter",parameter="k",
             layout="list",coeff=matrix_rows(c(0,1,2,1,2,3,2,3,4))),
        list(w=matrix_rows(c(0,1,2,1,0,1,2,1,0)),d=12,kind="parameter",
             parameter="p",layout="margins",coeff=diag(3))
      )
      gcd <- function(a,b) { while(b!=0) { remainder<-a%%b; a<-b; b<-remainder }; a }
      fraction <- function(n,d=1) { common<-gcd(abs(n),d); c(n=n/common,d=d/common) }
      plain <- function(f) if(f[["d"]]==1) as.character(f[["n"]]) else paste0(f[["n"]],"/",f[["d"]])
      tex <- function(f) if(f[["d"]]==1) as.character(f[["n"]]) else paste0("\\tfrac{",f[["n"]],"}{",f[["d"]],"}")
      math <- function(text) paste0("\\(",text,"\\)")
      paragraph <- function(text) paste0("<p>",text,"</p>")
      typeset <- "<script>if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);</script>"
      html <- function(text) HTML(paste0(text,typeset))
      lapply(seq_along(specs),function(id) {
        spec<-specs[[id]]; w<-spec$w; den<-spec$d
        xs<-seq_len(ncol(w))-1L; ys<-seq_len(nrow(w))-1L
        grid<-expand.grid(x=xs,y=ys)
        weights<-as.vector(t(w))
        coefficients<-if(is.null(spec$coeff)) rep(0,length(weights)) else as.vector(t(spec$coeff))
        parameter_question<-spec$kind=="parameter"
        if(parameter_question) {
          answer<-fraction(den-sum(weights),den*sum(coefficients))
          label<-spec$parameter; selected<-integer(0)
        } else {
          selected<-which(switch(spec$kind,
            lookup=grid$x==spec$x & grid$y==spec$y,
            marginal_x=grid$x==spec$x,marginal_y=grid$y==spec$y,
            region=grid$x>0 & grid$y<=1,sum=grid$x+grid$y>=3))
          answer<-fraction(sum(weights[selected]),den)
          label<-switch(spec$kind,
            lookup=paste0("P(X=",spec$x,",Y=",spec$y,")"),
            marginal_x=paste0("f_X(",spec$x,")"),marginal_y=paste0("f_Y(",spec$y,")"),
            region="P(X>0,\\,Y\\le1)",sum="P(X+Y\\ge3)")
        }
        completed<-weights/den+coefficients*answer[["n"]]/answer[["d"]]
        stopifnot(all(completed>=0),abs(sum(completed)-1)<1e-12)
        cell_text<-vapply(seq_along(weights),function(i) {
          if(coefficients[i]>0) {
            if(isTRUE(spec$missing)) return("?")
            return(paste0(if(coefficients[i]==1) "" else coefficients[i],spec$parameter))
          }
          tex(fraction(weights[i],den))
        },character(1))
        cells<-matrix(cell_text,nrow=nrow(w),byrow=TRUE)
        td<-function(text) paste0("<td>",math(text),"</td>")
        th<-function(text) paste0("<th>",math(text),"</th>")
        if(identical(spec$layout,"list")) {
          header<-paste0("<tr><th>x</th><th>y</th>",th("f_{X,Y}(x,y)"),"</tr>")
          rows<-vapply(seq_along(weights),function(i) paste0("<tr><td>",grid$x[i],"</td><td>",grid$y[i],"</td><td>",cell_text[i],"</td></tr>"),character(1))
          orientation<-"Each row lists one (x,y) outcome and its joint probability."
        } else if(identical(spec$layout,"margins")) {
          header<-paste0("<tr>",th("x"),paste0(vapply(ys,function(y) th(paste0("y=",y)),character(1)),collapse=""),th("f_X(x)"),"</tr>")
          rows<-vapply(seq_along(xs),function(i) paste0("<tr>",th(paste0("x=",xs[i])),paste0(vapply(cells[,i],td,character(1)),collapse=""),td("?"),"</tr>"),character(1))
          rows<-c(rows,paste0("<tr>",th("f_Y(y)"),paste0(rep(td("?"),length(ys)),collapse=""),td("1"),"</tr>"))
          orientation<-"Rows show X and columns show Y. The '?' cells are marginal totals; use only the nine interior joint probabilities when normalizing."
        } else {
          header<-paste0("<tr>",th("f_{X,Y}(x,y)"),paste0(vapply(xs,function(x) th(paste0("x=",x)),character(1)),collapse=""),"</tr>")
          rows<-vapply(seq_along(ys),function(i) paste0("<tr>",th(paste0("y=",ys[i])),paste0(vapply(cells[i,],td,character(1)),collapse=""),"</tr>"),character(1))
          orientation<-"Rows show Y and columns show X."
        }
        table<-paste0("<table class='pmf-table'><thead>",header,"</thead><tbody>",paste0(rows,collapse=""),"</tbody></table>")
        if(!parameter_question) {
          coordinates<-paste0("(",grid$x[selected],",",grid$y[selected],")")
          terms<-paste0("f_{X,Y}(",grid$x[selected],",",grid$y[selected],")")
          values<-vapply(weights[selected],function(n) tex(fraction(n,den)),character(1))
          question<-paste0("Find ",math(label),".")
          hint1<-switch(spec$kind,
            lookup="Read the joint probability at the intersection of the requested X column and Y row.",
            marginal_x="Keep X fixed and sum over every Y value in that column.",
            marginal_y="Keep Y fixed and sum over every X value in that row.",
            region="Include only cells satisfying both X>0 and Y<=1; check the boundary Y=1.",
            sum="Include all cells with X+Y at least 3, including the boundary X+Y=3.")
          hint2<-paste0(if(length(selected)==1) "Use the cell " else "Add the cells ",math(paste0(coordinates,collapse=", ")),".")
          solution<-paste0("<b>Solution:</b>",
            paragraph(math(paste0(label," = ",paste0(terms,collapse=" + ")))),
            paragraph(math(paste0(paste0(values,collapse=" + ")," = ",tex(answer)))),
            paragraph(paste0("Therefore ",math(paste0(label," = ",tex(answer))),".")))
        } else {
          known<-fraction(sum(weights),den); coefficient_sum<-sum(coefficients)
          unknown_term<-paste0(if(coefficient_sum==1) "" else coefficient_sum,spec$parameter)
          known_terms<-vapply(weights[coefficients==0],function(n) tex(fraction(n,den)),character(1))
          question<-if(isTRUE(spec$missing)) "Find the missing probability '?' so that the completed table is a joint PMF." else
            paste0("Find ",math(paste0(spec$parameter,"\\ge0"))," so that the joint probabilities sum to 1.")
          hint1<-"Every entry must be non-negative, and the joint probabilities must sum to 1. First add the fixed entries."
          hint2<-paste0("The fixed probabilities sum to ",math(tex(known)),". The unknown contribution is ",
            math(unknown_term),"; solve ",math(paste0(tex(known)," + ",unknown_term," = 1")),".")
          if(isTRUE(spec$missing)) hint2<-paste0("Let the missing cell be ",math("p"),". ",hint2)
          if(id==10) hint1<-paste0(hint1," Do not add the marginal totals to the interior probabilities.")
          solution<-paste0("<b>Solution:</b>",
            if(isTRUE(spec$missing)) paragraph(paste0("Let the missing probability be ",math("p"),".")) else "",
            paragraph(paste0("Fixed entries: ",math(paste0(paste0(known_terms,collapse=" + ")," = ",tex(known))),".")),
            paragraph(paste0("The unknown contribution is ",math(unknown_term),".")),
            paragraph(math(paste0(tex(known)," + ",unknown_term," = 1 \\quad\\Rightarrow\\quad ",spec$parameter," = ",tex(answer)))),
            paragraph(paste0("Check: ",math(paste0(tex(known)," + ",coefficient_sum,"\\times(",tex(answer),") = 1")),
              "; all completed probabilities are non-negative.")))
          if(id==8) solution<-paste0(solution,paragraph("Zero probabilities are allowed: the fixed entries already contain all the probability mass."))
        }
        list(id=id,table_ui=html(table),
          question=html(paste0(paragraph(orientation),paragraph(question),paragraph("Unlisted outcomes have probability zero."))),
          ans_frac=plain(answer),ans_val=unname(answer[["n"]]/answer[["d"]]),
          hint1=html(paragraph(hint1)),hint2=html(paragraph(hint2)),solution=html(solution))
      })
    }

    # ============================================================
    # 题目逻辑 
    # ============================================================
    
    # ==== 题库 ====
    question_bank <- get_joint_question_bank()
    practice_questions <- learning_questions(question_bank, "joint")
    practice <- learning_practice_server(input, output, session, practice_questions,
      "joint", course_path, load_pmf=pmf_actions$load_example, open_plot=open_plot)
    # Stable references also support regression of the unchanged original question library.
    current_index <- practice$current_index
    prob <- practice$prob
    result <- practice$result
    tries <- practice$tries
    practice
  })
}
