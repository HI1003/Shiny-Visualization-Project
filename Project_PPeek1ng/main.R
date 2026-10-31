# =====================================================================
#  app.R — Main Dashboard for Probability Learning System
# =====================================================================
library(shiny)
library(bs4Dash) 
library(shinyjs)  
library(plotly)

# ============================================================
# 🌐 Common Helper Functions (for all modules)
# ============================================================

# PMF state is created inside server(), independently for each student session.
# =========================================================
#  Load all module files
# =========================================================
source("modules/pmf_helpers.R")
source("modules/learning_content.R")
source("modules/learning_practice.R")
source("modules/module_joint.R")
source("modules/module_conditional.R")
source("modules/module_expectation.R")
source("modules/module_game_discrete.r")
source("modules/module_probability.R")

# =========================================================
# Dashboard UI
# =========================================================
ui <- bs4DashPage(
  
  # =========================================================
  # ✅ 顶部导航栏（Logo + 品牌标题）
  # =========================================================
  bs4DashNavbar(
    skin = "light",
    status = "white",
    title = tags$div(
      style = "display:flex; align-items:center; gap:10px;",
      tags$img(src = "img/logo.png", height = "40", style = "margin-left:20px;margin-right:20px;"),
      tags$span("PPeek1ng", 
                style = "font-weight:700; font-size:20px; color:#1a73e8; font-family:'Poppins',sans-serif;")
    )
  ),
  
  # =========================================================
  # ✅ 左侧菜单栏（含折叠子菜单）
  # =========================================================
  bs4DashSidebar(
    skin = "light",
    status = "primary",  # 蓝色主题
    elevation = 2,
    title = tags$div(
      tags$span("Navigation", style = "font-weight:600; color:#1a73e8;")
    ),
    
    div(class="learning-path-controls",
      selectInput("learning_path", "Learning path", choices=learning_path_labels, selected="core"),
      uiOutput("learning_progress")
    ),
    bs4SidebarMenu(
      id = "tabs",
      bs4SidebarMenuItem("Home", tabName = "home", icon = icon("home")),
      
      # --- 概率分布菜单（包含 Game 子项） ---
      bs4SidebarMenuItem(
        "Probability Distribution",
        tabName = "probability",
        icon = icon("percent"),
        bs4SidebarMenuSubItem("Overview", tabName = "probability", icon = icon("lightbulb")),
        bs4SidebarMenuSubItem("Game: Discrete", tabName = "game_discrete", icon = icon("dice"))
      ),
      
      # --- 其他模块 ---
      bs4SidebarMenuItem("Joint Distribution", tabName = "joint", icon = icon("chart-area")),
      bs4SidebarMenuItem("Conditional Distribution", tabName = "conditional", icon = icon("chart-bar")),
      bs4SidebarMenuItem("Expectation", tabName = "expectation", icon = icon("chart-line"))
    )
  ),
  
  bs4DashBody(
    useShinyjs(),
    uiOutput("learning_path_banner"),
    
    # ---------- 全局样式 ----------
    tags$head(
      tags$style(HTML("
        .learning-path-controls {padding:12px;}
        .learning-path-controls .shiny-input-container {width:100%;}
        .practice-progress, .question-path {font-weight:600; margin:10px 0;}
        .practice-question {margin:12px 0; line-height:1.6;}
        .pmf-edit-row {display:flex; flex-wrap:wrap; gap:8px; align-items:flex-end; border-bottom:1px solid #ddd; padding-bottom:12px; margin-bottom:12px;}
        .pmf-edit-row .form-group {margin-bottom:0; width:100%;}
        .pmf-edit-prob {flex:1 1 100%; min-width:0;}
        .pmf-edit-coordinate {flex:1 1 85px; min-width:0;}
        .pmf-table-layout {display:flex; flex-wrap:wrap; gap:24px; align-items:flex-start;}
        .pmf-table-scroll {flex:1 1 320px; min-width:0; overflow-x:auto;}
        .pmf-calculation-panel {flex:1 1 320px; min-width:0; overflow-x:auto;}
        .pmf-table-layout .shiny-input-container {max-width:100%;}
        #shiny-tab-joint .card-body, #shiny-tab-conditional .card-body,
        #shiny-tab-expectation .card-body {overflow-x:auto;}
        .sidebar-mini.sidebar-collapse .brand-link .brand-text {
    display: none !important;
  }
  .brand-link {
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
  }
        .box {
          background-color: #ffffff !important;
          border: 1px solid #dee2e6;
          border-radius: 8px;
          box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        }
        .box-title {
          font-weight: 600;
        }
        .sidebar-menu > li > a {
          font-size: 15px;
        }
        .main-header .logo {
          font-weight: bold;
          background-color: #3c8dbc !important;
          color: #ffffff !important;
        }
        .main-header .navbar {
          background-color: #3c8dbc !important;
        }
        .content {
          padding: 20px;
        }
      "))
    ),
    
    # === ✅ 新增：练习题样式 ===
    tags$style(HTML("
      .pmf-table {
        border-collapse: collapse;
        margin: 10px 0 20px 0;
        font-size: 16px;
        width: auto;
      }
      .pmf-table th, .pmf-table td {
        border: 1px solid #ddd;
        padding: 6px 12px;
        text-align: center;
        vertical-align: middle;
      }
      .pmf-table th.corner.outer {
        background-color: #f7f7f7;
        font-weight: 600;
      }
      .pmf-table th {
        background-color: #fafafa;
      }
      .alert {
        border-radius: 6px;
        margin-top: 10px;
        padding: 10px 15px;
        font-size: 15px;
      }
      .alert-success {
        background-color: #e6f4ea;
        border: 1px solid #a3d9a5;
        color: #216e39;
      }
      .alert-warning {
        background-color: #fff8e1;
        border: 1px solid #ffecb3;
        color: #8d6e00;
      }
      .alert-info {
        background-color: #e8f0fe;
        border: 1px solid #c5d5f6;
        color: #1a73e8;
      }
      .btn-block {
        width: 100%;
      }
    ")),
    
    # ✅ 加入 MathJax 重新渲染脚本
    tags$script(HTML("
      Shiny.addCustomMessageHandler('refresh_mathjax', function(msg) {
        if (window.MathJax && window.MathJax.typesetPromise) {
          if (msg.selector) {
            const el = document.querySelector(msg.selector);
            if (el) MathJax.typesetPromise([el]);
          } else {
            MathJax.typesetPromise();
          }
        }
      });
    ")),
    
    # ---------- 亮/暗主题切换样式 ----------
    tags$style(HTML("
      /* 默认亮色主题 */
      body.light-mode, .content, .main-sidebar {
        background-color: #f8f9fa !important;
      }


      /* 深色主题 */
      body.dark-mode, body.dark-mode .content, body.dark-mode .main-sidebar {
        background-color: #1c1c2b !important;
      }


      body.dark-mode .box, .content-wrapper.dark-mode .box {
        background-color: #2c3e50 !important;
        border: 1px solid #34495e;
        color: #ecf0f1 !important;
      }

      body.dark-mode h1, body.dark-mode h2, body.dark-mode h3 {
        color: #3498db !important;
      }
      body.dark-mode .card-header h3 {color: inherit !important;}
      body.dark-mode .pmf-table th, body.dark-mode .pmf-table .sumcell {
        background-color: #2c3e50 !important;
        color: #ecf0f1 !important;
      }
    ")),
    
    # ---------- Tab 内容 ----------
    tabItems(
      tabItem(tabName = "home",
              fluidRow(
                column(width = 12,
                       box(
                         width = 12, status = "info", solidHeader = TRUE,
                         title = HTML("<span style='font-weight:700; font-size:20px; 
                                 background: linear-gradient(90deg, #1a73e8, #004aad); 
                                 -webkit-background-clip: text; color: transparent;
                                 font-family: Poppins, sans-serif;'>PPk1ng Probability Learning System</span>"),
                         HTML("
<div style='padding: 10px; line-height:1.6; font-size:15px; color:#333;'>

  <p>
    <b>PPk1ng</b> is an interactive probability learning system designed to help students 
    develop an intuitive and theoretical understanding of core probability concepts 
    through <b>visualization, computation, and interactive exploration</b>.
  </p>

  <p>
    The primary audience is students currently studying STATS125. A separate optional path introduces a few ideas they may meet later in STATS210. The system integrates multiple learning modules, allowing users to experiment
    with discrete and continuous probability models, explore relationships between variables, 
    and apply concepts to structured problem-solving scenarios.
  </p>

  <hr style='margin:20px 0;'>

  <p><b>Author:</b> Chunyi Wu &nbsp;&nbsp; <b>Institution:</b> University of Auckland</p>
  <p><b>Version:</b> 1.0 &nbsp;&nbsp; <b>Last Updated:</b> October 2025</p>

  <hr style='margin:25px 0;'>

  <h4 style='color:#1a73e8;'>About the Interactive Modules</h4>
  <p>
    The dashboard is organized into five major modules. Each focuses on a distinct 
    concept of probability and provides an interactive environment combining theory, 
    computation, and visualization.
  </p>

  <ul>
    <li><b>Probability Distribution:</b> Introduces the fundamental ideas of discrete and continuous random variables, 
    visualizing PMF/PDF and CDF curves with parameter controls for direct comparison.</li>

    <li><b>Game: Discrete:</b> Applies probability reasoning in a scenario-based environment where each story 
    represents an underlying probability model. This helps reinforce abstract ideas through contextual learning.</li>

    <li><b>Joint Distribution:</b> Demonstrates the relationship between two random variables via a joint probability 
    table and 2D/3D visualizations. Users can observe marginal probabilities 
    <i>f<sub>X</sub>(x)</i> and <i>f<sub>Y</sub>(y)</i> directly.</li>

    <li><b>Conditional Distribution:</b> Explores how probability changes when conditioning on a known variable, 
    highlighting <i>f<sub>Y|X</sub>(y|x)</i> and <i>f<sub>X|Y</sub>(x|y)</i> in contrast to the joint distribution.</li>

    <li><b>Expectation:</b> Provides a computational environment for understanding expected values, 
    transformations such as <i>E[g(X)]</i>, and conditional expectations <i>E[Y|X]</i>.</li>
  </ul>

  <hr style='margin:25px 0;'>

  <h4 style='color:#1a73e8;'>Parameter Input Controls</h4>
  <p>These controls are used throughout the modules, particularly in the Joint and Conditional sections:</p>

  <ul>
    <li><b>p:</b> Probability (or relative frequency) assigned to each pair (x, y). Accepts decimal or fractional values.</li>
    <li><b>x, y:</b> Discrete values representing possible outcomes of random variables X and Y.</li>
    <li><b>Add Row:</b> Insert a new row with default entries.</li>
    <li><b>Delete:</b> Remove the selected row from the table.</li>
    <li><b>Normalize:</b> Adjust probabilities so that their total equals 1.</li>
    <li><b>Uniform:</b> Assign equal probability (1/n) to all outcomes.</li>
    <li><b>Generate Table:</b> Finalize and normalize the joint PMF, 
    ensuring all values are valid before rendering updated plots.</li>
  </ul>

  <p style='color:#555; font-style:italic; margin-top:20px;'>
    <b>STATS125 learning route:</b> Check your event, conditional probability and independence basics (Chapters 2–4).
    Start with discrete PMFs, CDFs, means and variances (Chapter 5), then the seven discrete models (Chapter 6).
    Use <b>Game: Discrete</b> after learning those models. Continue with joint/marginal tables and conditional PMFs (Chapter 7),
    then conditional means and total expectation (Chapter 8). <b>E[g(X)], variance and total expectation are part of STATS125.</b>
    The sidebar defaults to <b>STATS125 Core</b>. Uniform, Exponential and Normal provide a separate optional preview for later STATS210 study.
    Formal continuous-distribution calculations are in <b>Further exploration</b>. Skipping optional paths does not affect Core completion.
  </p>
  <details><summary>Before you start: symbols, units and conditions</summary>
    <ul>
      <li><b>X, Y:</b> define what is measured or counted, its units and its possible values (support).</li>
      <li><b>f(x,y), f_X(x), f_Y(y):</b> joint probability and the two marginals. Add over the other variable to find a marginal.</li>
      <li><b>P(Y=y | X=x):</b> restrict to X=x, then divide by P(X=x). This condition must have positive probability; reversing it changes the denominator.</li>
      <li><b>E[Y | X=x]:</b> one conditional mean. Weight these means by P(X=x) to recover E[Y].</li>
      <li><b>Model parameters:</b> state the sampling assumptions. Poisson lambda is a mean count for the stated interval; an Exponential rate is per unit time; a Normal standard deviation is the square root of its variance.</li>
    </ul>
  </details>

</div>

<script>
  if (window.MathJax && MathJax.Hub) MathJax.Hub.Queue(['Typeset', MathJax.Hub]);
</script>
")
                       )
                )
              )
      ),
      # Probability Distribution
      tabItem(tabName = "probability", prob_UI("prob1")),
      
      # Joint Distribution
      tabItem(tabName = "joint", joint_UI("joint1")),
      
      # Conditional Distribution
      tabItem(tabName = "conditional", conditional_UI("cond1")),
      
      # Expectation
      tabItem(tabName = "expectation", expectation_UI("exp1")),
      
      tabItem(
        tabName = "game_discrete",
        uiOutput("game_module_ui")
      )
    )
  )
)

# =========================================================
# Server Logic
# =========================================================
server <- function(input, output, session) {
  
  course_path <- reactive({
    value <- input$learning_path
    if(length(value)!=1 || is.na(value) || !value %in% unname(learning_path_labels)) "core" else value
  })
  plot_request <- reactiveVal(NULL)
  plot_counter <- 0L
  open_plot <- function(key) {
    plot_counter <<- plot_counter+1L
    plot_request(list(key=key, counter=plot_counter))
    bs4Dash::updatebs4TabItems(session, "tabs", "probability")
  }
  shared <- new_pmf_state()
  practice_modules <- list(
    joint=joint_Server("joint1",shared,course_path,open_plot),
    conditional=conditional_Server("cond1",shared,course_path,open_plot),
    expectation=expectation_Server("exp1",shared,course_path,open_plot),
    overview=prob_Server("prob1",course_path,plot_request)
  )
  output$learning_progress <- renderUI({
    total <- sum(vapply(practice_modules,function(x) x$total(),numeric(1)))
    complete <- sum(vapply(practice_modules,function(x) x$completed(),numeric(1)))
    tags$p(role="status",paste0(complete," / ",total," practice exercises correct"))
  })
  output$learning_path_banner <- renderUI({
    div(class="alert alert-info",strong(learning_path_label(course_path()))," — ",
      switch(course_path(),core="Discrete probability, joint/conditional PMFs, expectation and variance for STATS125. Optional paths do not count towards Core completion.",
        preview="Optional preparation for later STATS210 study. The needed concepts and formulas are provided; this is separate from the STATS125 Core path.",
        further="Optional further exploration. These exercises and formal formulas are not required to complete this tool's STATS125 Core path."),
      tags$small(" The discrete game has its own score."))
  })

  output$game_module_ui <- renderUI(game_discrete_UI("game1"))
  game_discrete_Server("game1")

  # The dashboard's theme switch controls the theme; tab navigation preserves it.
  invisible(shared)
}

# =========================================================
# Run the Dashboard
# =========================================================
shinyApp(ui, server)
