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
# i <- 1
# while (i < 35) {
#   
#   m.url <- meta.data.file[i, 15]
#   my.url <- as.character(m.url)
#   
#   tic()
#   download.file(url=my.url, destfile = paste0(download.dir, basename(my.url)))
#   toc()
#   i = i+1
# }

#renaming the files. This is a pain!!!

i <- 1
while (i < 35) {

  m.url <- meta.data.file[i, 15]
  my.url <- as.character(m.url)
  
  if (length(grep('SampleSheet', my.url, value=TRUE)) != 0 ) {
    i <- i+1
  }
  else {
    
    tic()
    download.file(url=my.url, destfile = paste0(download.dir, basename(my.url)))
    toc()
    i <- i + 1 
  }  
}

# list the files that were downloaded
url.vector <- list.files(path = "/projectnb/talbot-lab-data/NEFI_data/metagenomes/raw_sequences", pattern = NULL, all.files = FALSE,
           full.names = FALSE, recursive = FALSE,
           ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)

from1 <- url.vector
to1 <- numeric()


if (length(grep('gen', url.vector[1], value=TRUE)) != 0 ) {
 
  c.url <-url.vector[1]
  front <- substr(c.url, 1, 11)
  middle <- substr(c.url, 18, 26)
  c <- "comp-"
  end <- substr(c.url, 31, 41)
  new <- paste0(front, middle, c, end)
  to1[1] <- new
  
}



#OSBS_001-M-20140917-comp_R1.fastq.gz
#BART_004-O-20140619-comp-R1.fastq.gz



