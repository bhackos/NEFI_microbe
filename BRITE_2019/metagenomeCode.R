# #download nitrogen data 
# NTR <- loadByProduct(dpID="DP1.10080.001", site="all", startdate="2017-03", enddate="2019-03",
#                      package="expanded", check.size=F)
# 
# #nitrogen rates calculation package
# out <- def.calc.ntrans(kclInt = NTR$ntr_internalLab, 
#                        kclIntBlank = NTR$ntr_internalLabBlanks, 
#                        kclExt = NTR$ntr_externalLab, 
#                        soilMoist = NTR$sls_soilMoisture)
source("BRITE-paths.r")
library(neonUtilities)  
library(neonNTrans) 
library(ggplot2)

out <- readRDS(N_data_path)
meta.dat <- loadByProduct(site = "all", dpID = "DP1.10107.001", package="basic", check.size=F)
seq <- meta.dat[["mms_metagenomeSequencing"]]
#dim = 80 rows

# pseudocode

# subset both dfs (out and seq) to 2017
# something like: substr(out$dateID, 1, 4) == "2017"
n_2017 <- out[substr(out$dateID, 1, 4) == "2017",]
seq_2017 <- seq[substr(seq$collectDate, 1, 4) == "2017", ]

# create new mergeID for both
# first part of sampleID (without date)
# i <- 1
# while (i < 1709) {
#   initial <- n_2017$sampleID[i]
#   final <- substr(n_2017$sampleID[i], 1, nchar(as.character(n_2017$sampleID[i]))-9)
#   n_2017$sampleID <- sub(initial, final, n_2017$sampleID)
#   i = i + 1
# }

# n_2017$mergeSampleID <- NA
# for (i in unique(n_2017$incubationPairID)){
#   samp <- unique(n_2017$incubationPairID)[i]
#   samp_rows <- n_2017[n_2017$incubationPairID == samp,]
#   samp_first_date <- samp_rows[samp_rows$nTransBoutType=="tInitial",]$dateID
#   mergeSampleID <- paste0(substr(samp_rows$sampleID[i], 1, 10), "-", samp_first_date)
#   n_2017[n_2017$incubationPairID == samp,]$mergeSampleID <- mergeSampleID
# }

# in N_data, create ID with site/plot/year-month
# new <- n_2017
# but <- new[complete.cases(new[ , 1]), ]
# but2 <- but[complete.cases(but[ , 98]), ]
# but3 <- but2[complete.cases(but2[, 63]), ]


n_2017$mergeSampleID <- NA
for (i in 1:1708) {
  samp <- n_2017$incubationPairID[i]
  samp_rows <- n_2017[n_2017$incubationPairID == samp, ]
  samp_first_date <- samp_rows[samp_rows$nTransBoutType=="tInitial",]$dateID
  mergeSampleID <- paste0(substr(samp_rows$sampleID[1], 1, 10), "-", samp_first_date)
  n_2017[n_2017$incubationPairID == samp,]$mergeSampleID <- mergeSampleID
}

# in sequence data, create ID with site/plot/year-month

seq_2017$mergeSampleID <- NA
for (i in 1:209) {
  samp <- seq_2017$dnaSampleID[i]
  new_date <- substr(seq_2017$collectDate[i], 1, 7)
  samp_first_date <- new_date
  mergeSampleID <- paste0(substr(seq_2017$dnaSampleID[i], 1, 10), "-", samp_first_date)
  seq_2017[seq_2017$dnaSampleID == samp,]$mergeSampleID <- mergeSampleID
}


# i <- 1
# while (i < 1708) {
#   initial <- n_2017$sampleID[i]
#   final <- substr(n_2017$sampleID[i], 1, 10)
#   n_2017$sampleID <- sub(initial, final, n_2017$sampleID)
#   i = i + 1
# }
# 
# j <- 1
# while (j < 210) {
#   binitial <- seq_2017$dnaSampleID[j]
#   bfinal <- substr(seq_2017$dnaSampleID[j], 1, 10)
#   seq_2017$dnaSampleID <- sub(binitial, bfinal, seq_2017$dnaSampleID)
#   j = j + 1
# }

# subset nitrogen data to nTransBoutType.x == "tFinal"
n_2017 <- n_2017[n_2017$nTransBoutType == "tFinal", ]

# merge by mergeID

merge1 <- merge(n_2017, seq_2017, by = "mergeSampleID")
# print dim, print the # of plots at each site

# make a boxplot of the N data - 2 plots (one for Nmin, one for Nitrification)
# separated by siteID, like https://plot.ly/r/box-plots/
# or use ggplot2, or base R

#get rid of duplicated columns 
newmerge <- merge1[!duplicated(as.list(merge1))]

#N min
p <- ggplot(newmerge, aes(x= siteID.x, y= netNminugPerGramPerDay)) +
  geom_boxplot()
p

#nitrification
d <- ggplot(newmerge, aes(x= siteID.x, y= netNitugPerGramPerDay)) +
  geom_boxplot()
d

# save metadata 

#### download code - make separate file ####

# source functions:
source("../NEFI_functions/tic_toc.r")

# read in the file that Lee sent, with the urls

# set a path for where things should download

# loop through list of URLs
# time the downloads
# tic()
# download
# toc()

#### old

new_meta_sequence <- merge(out, meta.dat[["mms_metagenomeSequencing"]], by.x = "collectDate.x", by.y = "collectDate")

#dim = 405 rows
new_meta_dna <- merge(out, meta.dat[["mms_metagenomeDnaExtraction"]], by.x = "collectDate", by.y = "collectDate")