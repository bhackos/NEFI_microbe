#### download code ####
library(RCurl)
library(utils)
# source functions:
setwd("BRITE_2019/") # assumes you're in NEFI_microbe
source("BRITE-paths.r")
source("../NEFI_functions/tic_toc.r")

# read in the file with the urls
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

# some files from NEON data contain information in sample sheets. This gets rid of those files 
#only metagenomic data is downloaded 

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

# list the files that were downloaded. This is good for checking purposes. 
url.vector <- list.files(path = "/projectnb/talbot-lab-data/NEFI_data/metagenomes/raw_sequences", pattern = NULL, all.files = FALSE,
           full.names = FALSE, recursive = FALSE,
           ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)


# code that I used to change file names. Might be useful for reference. 
# from1 <- url.vector
# to1 <- character()
# 
# to1 <- list.files(path = "/projectnb/talbot-lab-data/NEFI_data/metagenomes/raw_sequences", pattern = NULL, all.files = FALSE,
#                          full.names = FALSE, recursive = FALSE,
#                          ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
# 
# 
#   
# for (j in 1:length(url.vector)) {
#   
#   if (length(grep('gen', url.vector[j], value=TRUE)) != 0 ) {
#     
#     if (nchar(url.vector[j]) == 39 ) {
#       
#       c.url <-url.vector[j]
#       front <- substr(c.url, 1, 11)
#       middle <- substr(c.url, 18, 26)
#       c <- "20131114-comp_"
#       end <- substr(c.url, 29, 39)
#       new <- paste0(front, c, end)
#       to1[j] <- new
# 
#     }
#     else {
#       
#       c.url <-url.vector[j]
#       front <- substr(c.url, 1, 11)
#       middle <- substr(c.url, 18, 26)
#       c <- "comp-"
#       end <- substr(c.url, 31, 41)
#       new <- paste0(front, middle, c, end)
#       to1[j] <- new
#     }  
#   }  
#   
#   else if (length(grep('Sequences', url.vector[j], value=TRUE)) != 0 ) {
#     
#     c.url<- url.vector[j]
#     front <- substr(c.url, 1, 27)
#     end <- ".fastq.gz"
#     new <- paste0(front, end)
#     to1[j] <- new
#   }
#   
#   else {
#     
#     to1[j] <- url.vector[j]
#   }
#   
# }    
# 
# to1[3] <- "DSNY_009-M-20131114-comp-R1.fastq.gz"  
# 
# 
# from1 <- intersect(from1, to1)
# 
# newto1 <- sub('comp-', 'comp_', to1)
# 
# 
# setwd("/projectnb/talbot-lab-data/NEFI_data/metagenomes/raw_sequences")
# file.rename(to1, newto1)






