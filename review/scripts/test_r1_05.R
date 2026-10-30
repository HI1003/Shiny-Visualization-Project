# Regression check of the real module outputs; run from the repository root.
# Rscript --vanilla review/scripts/test_r1_05.R [result.json]
.libPaths(c(normalizePath('.R-library'), .libPaths()))
if (.Platform$OS.type == 'windows') Sys.setlocale('LC_CTYPE', '.UTF-8')
suppressPackageStartupMessages({
  library(shiny)
  library(plotly)
  library(dplyr)
  library(latex2exp)
})
pmf_global <- reactiveValues(df_edit=NULL, df_final=NULL, counter=0, has_final=FALSE)
source('Project_PPeek1ng/modules/module_conditional.R', encoding='UTF-8')

make_pmf <- function(xs, ys, probabilities) {
  data.frame(x=xs, y=ys, p_input=as.character(probabilities),
             p_value=probabilities, id=seq_along(probabilities))
}
cases <- list()
add_case <- function(name, data, direction, value, expected) {
  cases[[length(cases)+1L]] <<- list(name=name, data=data,
    direction=direction, value=value, expected=expected)
}
default <- make_pmf(c(0,0,1,1), c(0,1,0,1),
                    round(c(188,16,16,1)/221, 5))
# Match the existing five-decimal input parser; do not change R1-06 here.
add_case('default_Y_given_X0', default, 'Y|X', 0, default$p_value[1:2]/sum(default$p_value[1:2]))
add_case('default_Y_given_X1', default, 'Y|X', 1, default$p_value[3:4]/sum(default$p_value[3:4]))
add_case('default_X_given_Y0', default, 'X|Y', 0, default$p_value[c(1,3)]/sum(default$p_value[c(1,3)]))
add_case('default_X_given_Y1', default, 'X|Y', 1, default$p_value[c(2,4)]/sum(default$p_value[c(2,4)]))
unequal <- make_pmf(c(0,0,0,1,1,1), c(0,1,2,0,1,2), c(.1,.05,.15,.2,.3,.2))
add_case('unequal_Y_given_X0', unequal, 'Y|X', 0, c(1/3,1/6,1/2))
add_case('unequal_Y_given_X1', unequal, 'Y|X', 1, c(2/7,3/7,2/7))
add_case('unequal_X_given_Y0', unequal, 'X|Y', 0, c(1/3,2/3))
add_case('unequal_X_given_Y1', unequal, 'X|Y', 1, c(1/7,6/7))
add_case('unequal_X_given_Y2', unequal, 'X|Y', 2, c(3/7,4/7))
zero_x <- make_pmf(c(0,0,1,1), c(0,1,0,1), c(0,0,.3,.7))
zero_y <- make_pmf(c(0,0,1,1), c(0,1,0,1), c(0,.4,0,.6))
add_case('zero_X_marginal', zero_x, 'Y|X', 0, NULL)
add_case('zero_Y_marginal', zero_y, 'X|Y', 0, NULL)
results <- new.env(parent=emptyenv())
results$records <- list()

testServer(conditional_Server, {
  for (case in cases) {
    pmf_global$df_final <- case$data
    pmf_global$df_edit <- case$data
    pmf_global$has_final <- TRUE
    pmf_final(case$data)
    session$setInputs(cond_type=if(case$direction=='Y|X') 'f(Y | X = x0)' else 'f(X | Y = y0)',
                      x0=as.character(case$value), y0=as.character(case$value))
    session$flushReact()
    rendered <- tryCatch(output$cond_table_html, error=function(e) e)
    if (is.null(case$expected)) {
      message <- if(inherits(rendered,'error')) conditionMessage(rendered) else ''
      passed <- inherits(rendered,'validation') && grepl('undefined', message, ignore.case=TRUE)
      record <- list(name=case$name, passed=passed, expected='undefined', message=message)
    } else if (inherits(rendered,'error')) {
      record <- list(name=case$name, passed=FALSE, error=conditionMessage(rendered))
    } else {
      html <- rendered$html
      values <- as.numeric(regmatches(html, gregexpr('[0-9]+\\.[0-9]{5}', html))[[1]])
      expected_display <- c(round(case$expected,5), 1)
      table_ok <- length(values)==length(expected_display) &&
        all(abs(values-expected_display)<1e-8)
      # Compare the table with both actual graph outputs, not a copy of their formula.
      bird <- jsonlite::fromJSON(output$plot_bird_cond, simplifyVector=FALSE)$x$data
      bird_values <- unlist(lapply(bird, function(trace) trace$y), use.names=FALSE)
      plot3d <- jsonlite::fromJSON(output$plot3d_cond, simplifyVector=FALSE)$x$data
      plot3d_values <- vapply(plot3d, function(trace) tail(unlist(trace$z),1), numeric(1))
      bird_ok <- length(bird_values)==length(case$expected) &&
        all(abs(bird_values-case$expected)<1e-10)
      plot3d_ok <- length(plot3d_values)==length(case$expected) &&
        all(abs(plot3d_values-case$expected)<1e-10)
      record <- list(name=case$name, passed=table_ok && bird_ok && plot3d_ok,
        expected=case$expected, displayed=values, bird=bird_values, plot3d=plot3d_values,
        table_passed=table_ok, bird_passed=bird_ok, plot3d_passed=plot3d_ok)
    }
    results$records[[length(results$records)+1L]] <- record
  }
})
args <- commandArgs(trailingOnly=TRUE)
destination <- if(length(args)) args[[1]] else 'review/evidence/r1_05_regression.json'
report <- list(issue='R1-05', date='2026-10-30',
  environment=list(R=R.version.string, shiny=as.character(packageVersion('shiny')),
                   dplyr=as.character(packageVersion('dplyr')),
                   plotly=as.character(packageVersion('plotly'))),
  source_md5=unname(tools::md5sum('Project_PPeek1ng/modules/module_conditional.R')),
  total=length(results$records), passed=sum(vapply(results$records,function(x)x$passed,logical(1))),
  cases=results$records)
stopifnot(report$total==11L)
jsonlite::write_json(report, destination, auto_unbox=TRUE, pretty=TRUE, digits=16)
cat(report$passed, '/', report$total, ' module output cases passed.\n')
if(report$passed != report$total) quit(status=1)
