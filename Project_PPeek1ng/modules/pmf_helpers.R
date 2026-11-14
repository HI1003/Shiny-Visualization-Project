# Shared parsing and draft/committed PMF actions for the three table modules.
parse_user_prob <- function(s, digits = NULL) {
  if (is.null(s) || length(s) != 1L || is.na(s)) return(NA_real_)
  s <- trimws(as.character(s))
  number <- "^[+-]?([0-9]+\\.?[0-9]*|\\.[0-9]+)([eE][+-]?[0-9]+)?$"
  parts <- trimws(strsplit(s, "/", fixed = TRUE)[[1]])
  if (length(parts) == 2L && !endsWith(s, "/") && all(grepl(number, parts))) {
    values <- suppressWarnings(as.numeric(parts))
    if (any(!is.finite(values)) || values[2] == 0) return(NA_real_)
    value <- values[1] / values[2]
  } else if (grepl(number, s)) {
    value <- suppressWarnings(as.numeric(s))
  } else return(NA_real_)
  if (is.finite(value)) value else NA_real_
}

pmf_prepare <- function(df, merge_duplicates = FALSE, uniform = FALSE) {
  if (is.null(df) || nrow(df) == 0L) stop("Add at least one outcome before generating a probability table.", call. = FALSE)
  if (!all(c("x", "y", "p_input") %in% names(df))) stop("The input table is incomplete. Add valid outcomes and probabilities.", call. = FALSE)
  bad_coordinates <- which(!is.finite(df$x) | !is.finite(df$y))
  if (length(bad_coordinates)) stop(paste0("Row ", bad_coordinates[1], ": x and y must be finite numbers."), call. = FALSE)
  weights <- if (uniform) rep(1, nrow(df)) else vapply(df$p_input, parse_user_prob, numeric(1))
  bad <- which(!is.finite(weights) | weights < 0)
  if (length(bad)) stop(paste0("Row ", bad[1], ": enter a finite, non-negative probability or weight (decimal or fraction)."), call. = FALSE)
  scale <- max(weights)
  if (scale <= 0) stop("The total probability or weight must be greater than zero.", call. = FALSE)
  # Scale before summing, so valid large weights cannot overflow their total.
  df$p_value <- weights / scale
  if (merge_duplicates) {
    df <- dplyr::summarise(dplyr::group_by(df, x, y),
                           p_value = sum(p_value), .groups = "drop")
    df <- as.data.frame(df)
  }
  df$p_value <- df$p_value / sum(df$p_value)
  # Enough digits to round-trip the value; never round a small negative to zero.
  df$p_input <- vapply(df$p_value, function(p) {
    short <- as.character(p)
    if (identical(as.numeric(short), p)) short else sprintf("%.17g", p)
  }, character(1))
  df
}

pmf_bind_actions <- function(input, output, session, df_current, pmf_edit,
                             pmf_final, row_counter, shared, module = NULL) {
  error_message <- shiny::reactiveVal(NULL)
  output$input_feedback <- shiny::renderUI({
    message <- error_message()
    if (is.null(message)) return(NULL)
    shiny::tags$div(class = "alert alert-danger", role = "alert", message)
  })
  prepare <- function(merge_duplicates = FALSE, uniform = FALSE) {
    tryCatch({
      df <- pmf_prepare(df_current(), merge_duplicates, uniform)
      error_message(NULL)
      df
    }, error = function(e) {
      error_message(conditionMessage(e))
      NULL
    })
  }
  update_draft <- function(df) {
    # Fresh, monotone IDs prevent old browser values from overwriting new inputs.
    df$id <- row_counter() + seq_len(nrow(df))
    row_counter(max(df$id))
    pmf_edit(df)
    shared$df_edit <- df
    shared$counter <- max(df$id)
    df
  }
  shiny::observeEvent(input$normalize, {
    df <- prepare()
    if (!is.null(df)) update_draft(df)
  })
  shiny::observeEvent(input$uniform, {
    df <- prepare(uniform = TRUE)
    if (!is.null(df)) update_draft(df)
  })
  shiny::observeEvent(input$generate, {
    df <- prepare(merge_duplicates = TRUE)
    if (is.null(df)) return(NULL)
    df <- update_draft(df)
    pmf_final(df)
    shared$df_final <- df
    shared$has_final <- TRUE
  })
  load_example <- function(key) {
    if(is.null(key) || !key %in% names(learning_pmf_notes)) {
      error_message("Choose a listed worked example.");return(invisible(NULL))
    }
    df <- pmf_prepare(learning_pmf_example(key),merge_duplicates=TRUE)
    df <- update_draft(df)
    pmf_final(df);shared$df_final <- df;shared$has_final <- TRUE
    shiny::updateSelectInput(session,"pmf_example",selected=key)
    error_message(NULL)
    invisible(NULL)
  }
  example_keys <- unname(unlist(learning_pmf_example_choices(module), use.names = FALSE))
  shiny::observeEvent(input$pmf_example, {
    key <- input$pmf_example
    shiny::req(nzchar(key), key %in% example_keys)
    if (!identical(key, learning_pmf_example_key(pmf_final()))) load_example(key)
  }, ignoreInit = TRUE)
  shiny::observeEvent(pmf_final(), {
    key <- learning_pmf_example_key(pmf_final())
    if (is.null(key) || !key %in% example_keys) key <- ""
    if (!identical(input$pmf_example, key)) shiny::updateSelectInput(session, "pmf_example", selected = key)
  })
  output$pmf_example_note <- shiny::renderUI(shiny::tags$p(class="small-note",learning_pmf_caption(pmf_final())))
  list(load_example=load_example)
}
# A fresh state is created by the app server for each browser session.
new_pmf_state <- function() {
  shiny::reactiveValues(df_edit = NULL, df_final = NULL, counter = 0, has_final = FALSE, number_format = "auto")
}

# Presentation is separate from p_input/p_value, which retain round-trip precision.
number_mode <- function(value) {
  if(length(value)==1L && !is.na(value) && value %in% c("auto","decimal","fraction")) value else "auto"
}
number_same <- function(a,b) {
  is.finite(a) && is.finite(b) && if(a==0 || b==0) a==b else abs(a-b)<=4*.Machine$double.eps*max(abs(a),abs(b))
}
number_full <- function(x) vapply(x,function(v) {
  if(!is.finite(v))return(as.character(v))
  short<-as.character(v)
  if(identical(as.numeric(short),as.numeric(v)))short else sprintf("%.17g",v)
},character(1),USE.NAMES=FALSE)
number_decimal <- function(x,digits=4L) vapply(x,function(v) {
  if(!is.finite(v))return(as.character(v))
  if(v==0)return("0")
  if(abs(v)<.5*10^-digits || abs(v)>=1e6) {
    return(format(signif(v,digits),scientific=TRUE,trim=TRUE))
  }
  text<-sprintf(paste0("%.",digits,"f"),v)
  text<-sub("0+$","",text);text<-sub("[.]$","",text)
  # printf may round an exact half-way boundary to zero (e.g. 0.00005).
  if(suppressWarnings(as.numeric(text))==0)return(format(signif(v,digits),scientific=TRUE,trim=TRUE))
  text
},character(1),USE.NAMES=FALSE)
number_fraction <- function(value,max_den=500L) {
  if(!is.finite(value) || abs(value)>1e12)return(NULL)
  if(value==round(value))return(number_full(value))
  for(den in seq_len(max_den)) {
    num<-round(value*den)
    if(num!=0 && number_same(num/den,value))return(paste0(number_full(num),"/",den))
  }
  NULL
}
number_label <- function(x,mode="auto") vapply(x,function(value) {
  mode<-number_mode(mode);decimal<-number_decimal(value)
  if(mode=="decimal" || !is.finite(value))return(decimal)
  if(mode=="auto" && number_same(parse_user_prob(decimal),value))return(decimal)
  fraction<-number_fraction(value)
  if(is.null(fraction))decimal else fraction
},character(1),USE.NAMES=FALSE)
number_tex <- function(x,mode="auto") vapply(number_label(x,mode),function(text) {
  if(grepl("/",text,fixed=TRUE)) {
    parts<-strsplit(text,"/",fixed=TRUE)[[1]]
    paste0("\\frac{",parts[1],"}{",parts[2],"}")
  }else if(grepl("e",text,fixed=TRUE)) {
    parts<-strsplit(text,"e",fixed=TRUE)[[1]]
    paste0(parts[1],"\\times 10^{",as.integer(parts[2]),"}")
  }else text
},character(1),USE.NAMES=FALSE)
number_relation <- function(x,mode="auto") {
  shown<-number_label(x,mode)
  if(all(mapply(number_same,x,vapply(shown,parse_user_prob,numeric(1))))) " = " else " \\approx "
}
number_reading <- function(x,mode="decimal") {
  labels <- number_label(x,mode)
  exact <- mapply(number_same,x,vapply(labels,parse_user_prob,numeric(1)))
  paste0(ifelse(exact,"= ","\u2248 "),labels)
}
number_cell <- function(value,mode="auto",class=NULL) {
  label<-number_label(value,mode)
  rounded<-!number_same(value,parse_user_prob(label))
  shiny::tags$td(class=class,`data-number-value`=number_full(value),`data-number-text`=label,
    shiny::HTML(paste0("\\(",if(rounded)"\\approx " else "",number_tex(value,mode),"\\)")))
}
number_formula <- function(formula,result) {
  shiny::tags$p(`data-number-value`=number_full(result),shiny::HTML(formula))
}
number_hover <- function(x) number_label(x,"decimal")
pmf_editor_value <- function(source) vapply(source,function(text) {
  value<-parse_user_prob(text)
  if(is.finite(value))number_label(value) else as.character(text)
},character(1),USE.NAMES=FALSE)
pmf_probability_input <- function(ns,id,source) {
  value<-parse_user_prob(source);shown<-pmf_editor_value(source)
  rounded<-is.finite(value) && !number_same(value,parse_user_prob(shown))
  shiny::tags$div(class="pmf-edit-prob",
    shiny::textInput(ns(paste0("p_",id)),if(rounded) "p (approx.)" else "p",value=shown))
}
pmf_read_probability <- function(df,id,value) {
  if(is.null(value))return(df)
  row<-match(id,df$id)
  # An unchanged compact input is only a display binding, not a new probability.
  if(!identical(as.character(value),pmf_editor_value(df$p_input[row])))df$p_input[row]<-as.character(value)
  df$p_value[row]<-parse_user_prob(df$p_input[row]);df
}
# Backward-compatible entry point for formula callers; all new rendering uses number_tex.
display_probability <- function(x) number_label(x,"decimal")

# Match the complete name, allowing only documented spelling aliases.
distribution_answer_matches <- function(value, expected) {
  if (is.null(value) || length(value) != 1L || is.na(value)) return(FALSE)
  canonical <- function(s) {
    s <- gsub("[-_[:space:]]+", " ", tolower(trimws(s)))
    trimws(sub(" distribution$", "", s))
  }
  aliases <- list(binomial = c("binomial", "binom", "bin"),
    poisson = "poisson", geometric = c("geometric", "geom"),
    exponential = c("exponential", "exp"), normal = c("normal", "gaussian"),
    uniform = c("uniform", "continuous uniform"), gamma = "gamma")
  key <- canonical(expected)
  allowed <- aliases[[key]]
  if (is.null(allowed)) allowed <- key
  canonical(value) %in% allowed
}

is_correct <- function(user_input, ans_val = NA, ans_frac = NA,
                       ans_text = NA, tol = 1e-4) {
  if (length(ans_text) == 1L && !is.na(ans_text))
    return(distribution_answer_matches(user_input, ans_text))
  value <- parse_user_prob(user_input)
  if (!is.finite(value)) return(FALSE)
  expected <- if (all(is.na(ans_val))) parse_user_prob(ans_frac) else ans_val
  any(is.finite(expected) & abs(value - expected) < tol)
}
