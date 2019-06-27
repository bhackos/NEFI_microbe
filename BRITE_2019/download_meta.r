#### download code - make separate file ####
library(RCurl)
library(utils)
# source functions:
source("../NEFI_functions/tic_toc.r")

# read in the file that Lee sent, with the urls
meta.data.file <- read.delim("Microbial_metagenome_sequences,_Level_0_mms_rawDataFiles_in 4.txt")

# set a path for where things should download
download.dir <- "/projectnb/talbot-lab-data/NEFI_data/metagenomes/raw_sequences/" 

#download.file(url=url, destfile = paste0(download.dir, basename(url)))
i <- 1
# while (i < 35) {
  
  m.url <- meta.data.file[i, 15]
  download.file(url=as.character(m.url), destfile = paste0(download.dir, basename(as.character(m.url))))
  # i = i+1
# }

# loop through list of URLs
# time the downloads
# tic()
# download
# toc()