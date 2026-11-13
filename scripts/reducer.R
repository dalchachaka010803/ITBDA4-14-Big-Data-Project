#!/usr/bin/env Rscript
# reducer.R
# Input : sorted <document \t row,column> pairs on stdin (from shuffle & sort)
# Output: <document \t number_of_hits \t (row,col) (row,col) ...>

con <- file("stdin", open = "r")
current_doc <- NULL
positions   <- character(0)

emit <- function(doc, pos) {
  rc  <- do.call(rbind, strsplit(pos, ","))
  ord <- order(as.integer(rc[, 1]), as.integer(rc[, 2]))   # sort by row, then column
  out <- paste0("(", rc[ord, 1], ",", rc[ord, 2], ")", collapse = " ")
  cat(doc, "\t", length(pos), "\t", out, "\n", sep = "")
}

while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  if (!nzchar(line)) next
  parts <- strsplit(line, "\t", fixed = TRUE)[[1]]
  doc <- parts[1]; pos <- trimws(parts[2])
  if (!is.null(current_doc) && doc != current_doc) {        # key changed -> flush
    emit(current_doc, positions)
    positions <- character(0)
  }
  current_doc <- doc
  positions   <- c(positions, pos)
}
if (!is.null(current_doc)) emit(current_doc, positions)     # last key
close(con)

