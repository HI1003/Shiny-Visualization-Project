# The distributable app contains no examination text, tables or answers.
# A local, ignored JSON bank is verified against the local source PDFs at startup.
exam_bank_path <- function() {
  configured<-Sys.getenv("STATS125_EXAM_BANK",unset="")
  if(nzchar(configured)) return(configured)
  roots<-c(getwd(),dirname(getwd()))
  candidates<-file.path(roots,".local","past-exams","bank.json")
  found<-candidates[file.exists(candidates)]
  if(length(found)) found[1] else candidates[1]
}
read_local_exam_bank <- function(path=exam_bank_path()) {
  empty<-list(status="missing",questions=list(),tables=list(),graphs=list(),sources=list())
  if(!file.exists(path)) return(empty)
  tryCatch({
    bank_file<-normalizePath(path,winslash="/",mustWork=TRUE)
    if(grepl("/www/",bank_file,ignore.case=TRUE)) stop("Private bank must not be web-served")
    bank<-jsonlite::read_json(path,simplifyVector=FALSE)
    stopifnot(identical(bank$schema_version,1L)||identical(bank$schema_version,1),length(bank$sources)>0,
      is.list(bank$questions),is.list(bank$tables),is.list(bank$graphs))
    for(source in bank$sources) {
      stopifnot(identical(source$course,"STATS125"),identical(source$document_type,"final_exam"),
        file.exists(source$question_path),file.exists(source$solution_path),
        identical(unname(tools::md5sum(source$question_path)),source$question_md5),
        identical(unname(tools::md5sum(source$solution_path)),source$solution_md5))
    }
    keys<-character(0)
    for(q in bank$questions) {
      stopifnot(is.character(q$key),length(q$key)==1,!q$key %in% keys,
        q$module %in% c("overview","joint","conditional","expectation"),q$track %in% c("core","preview","further"),
        q$source_id %in% names(bank$sources),is.logical(q$adapted),length(q$adapted)==1,
        is.character(q$source_question),nzchar(q$source_question),length(q$fields)>0,
        length(q$question)==1,is.character(q$question),length(q$solution)==1,is.character(q$solution))
      keys<-c(keys,q$key)
      for(field in q$fields) {
        stopifnot(field$kind %in% c("numeric","choice","distribution"),is.character(field$key),nzchar(field$key))
        if(field$kind=="numeric") stopifnot(is.numeric(field$expected),length(field$expected)==1,is.finite(field$expected))
        else stopifnot(is.character(field$expected),length(field$expected)==1,nzchar(field$expected))
      }
      if(!is.null(q$pmf_example)) stopifnot(q$pmf_example %in% names(bank$tables))
      if(length(q$plot_examples)) stopifnot(all(unlist(q$plot_examples) %in% names(bank$graphs)))
    }
    for(table in bank$tables) {
      stopifnot(length(table$rows)>0)
      coordinates<-character(0);mass<-0
      for(row in table$rows) {
        stopifnot(is.finite(row$x),is.finite(row$y),is.finite(row$p_value),row$p_value>=0)
        key<-paste(row$x,row$y,sep=":");stopifnot(!key %in% coordinates);coordinates<-c(coordinates,key);mass<-mass+row$p_value
      }
      stopifnot(abs(mass-1)<1e-10,is.character(table$label),is.character(table$note))
    }
    for(graph in bank$graphs) stopifnot(graph$type %in% c("discrete","continuous"),length(graph$inputs)>0,
      is.finite(graph$x),all(vapply(graph$inputs,function(x)is.numeric(x)&&length(x)==1&&is.finite(x),logical(1))))
    bank$status<-"verified";bank
  },error=function(e) {empty$status<-"invalid";empty})
}
local_exam_bank <- read_local_exam_bank()
exam_questions <- function(module) {
  questions<-Filter(function(q)identical(q$module,module),local_exam_bank$questions)
  lapply(seq_along(questions),function(i) {
    q<-questions[[i]];q$id<-i;q$is_exam<-TRUE;q$legacy<-FALSE;q$ans_val<-NA_real_
    q$source<-local_exam_bank$sources[[q$source_id]]
    q$plot_examples<-unlist(q$plot_examples,use.names=FALSE)
    q$fields<-lapply(q$fields,function(field) {
      if(is.null(field$nonnegative))field$nonnegative<-field$kind!="numeric"||field$expected>=0
      if(!is.null(field$choices))field$choices<-unlist(field$choices)
      field
    })
    q
  })
}
exam_pmf_example <- function(key) {
  table<-local_exam_bank$tables[[key]]
  if(is.null(table))return(NULL)
  rows<-lapply(table$rows,function(row)data.frame(x=row$x,y=row$y,p_input=as.character(row$p_value),p_value=row$p_value))
  df<-do.call(rbind,rows);df$id<-seq_len(nrow(df));df
}
exam_pmf_notes <- function() vapply(local_exam_bank$tables,`[[`,character(1),"note")
exam_graph_examples <- function() lapply(local_exam_bank$graphs,function(graph) {
  graph$paths<-unlist(graph$paths);graph
})
