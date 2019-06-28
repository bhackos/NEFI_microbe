#### download code ####
library(RCurl)
library(utils)
# source functions:
setwd("BRITE_2019/") # assumes you're in NEFI_microbe
source("BRITE-paths.r")
source("../NEFI_functions/tic_toc.r")

# read in the file that Lee sent, with the urls
meta.data.file <- read.delim("Microbial_metagenome_sequences.txt")

# set a path for where things should download
download.dir <- "/projectnb/talbot-lab-data/NEFI_data/metagenomes/raw_sequences/" 

# loop through list of URLs
# time the downloads
i <- 1
while (i < 35) {
  
  m.url <- meta.data.file[i, 15]
  tic()
  download.file(url=as.character(m.url), destfile = paste0(download.dir, basename(as.character(m.url))))
  toc()
  i = i+1
}
