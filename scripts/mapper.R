#!/usr/bin/env Rscript
# mapper.R
# Input : lines of ONE document on stdin (one input split = one document)
# Output: <document \t row,column> for every occurrence of the keyword

# keyword comes from the command line or from the KEYWORD env variable (-cmdenv)
args    <- commandArgs(trailingOnly = TRUE)
keyword <- if (length(args) >= 1) args[1] else Sys.getenv("KEYWORD")
if (!nzchar(keyword)) stop("mapper.R: no keyword supplied")
keyword <- tolower(trimws(keyword))

# Hadoop Streaming exposes the file being processed as an environment variable
doc <- Sys.getenv("mapreduce_map_input_file", Sys.getenv("map_input_file", "unknown_doc"))
doc <- basename(doc)

# escape regex special characters, then match the keyword as a whole word
kw_escaped <- gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", keyword)
pattern    <- paste0("(?<![[:alnum:]])", kw_escaped, "(?![[:alnum:]])")

con <- file("stdin", open = "r")
row <- 0
while (length(line <- readLines(con, n = 1, warn = FALSE, encoding = "UTF-8")) > 0) {
  row  <- row + 1                                     # row = line number in the document
  hits <- gregexpr(pattern, line, ignore.case = TRUE, perl = TRUE)[[1]]   # case-insensitive
  if (hits[1] != -1) {
    for (col in hits) {                               # col = character position in the line
      cat(doc, "\t", row, ",", col, "\n", sep = "")   # emit <key, value>
    }
  }
}
close(con)

