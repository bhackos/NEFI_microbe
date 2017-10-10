#Processing ITS fungal OTU tables with taxonomy and mapping files sent by Lee Stanish October, 2017
rm(list=ls())
library(biomformat)
library(nneo)
#subtring function to pull from the right edge of a character entry.
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

#set output paths for cleaned otu, map, and tax files.
otu.out <- '/fs/data3/caverill/NEFI_microbial/map_otu/ITS_otu_clean.rds'
map.out <- '/fs/data3/caverill/NEFI_microbial/map_otu/ITS_map_clean.rds'
tax.out <- '/fs/data3/caverill/NEFI_microbial/map_otu/ITS_tax_clean.rds'


#load the two files sent by Lee Stanish with taxonomy.
otu.ITS.a <- read_biom('/fs/data3/caverill/NEFI_microbial/map_otu/ITS_rerun20150225_otu_table_w_taxonomy.biom')
otu_table.a <- as.data.frame(as.matrix(biom_data(otu.ITS.a)))
taxonomy.a <- observation_metadata(otu.ITS.a)
map.a <- read.table('/fs/data3/caverill/NEFI_microbial/map_otu/ITS_rerun20150225_mapping_file.txt',sep='\t' ,header=T, comment.char = "")

otu.ITS.b <- read_biom('/fs/data3/caverill/NEFI_microbial/map_otu/ITS_rerun20150922_otu_table_w_taxonomy.biom')
otu_table.b <- as.data.frame(as.matrix(biom_data(otu.ITS.b)))
taxonomy.b <- observation_metadata(otu.ITS.b)
map.b <- read.table('/fs/data3/caverill/NEFI_microbial/map_otu/ITS_rerun20150922_mapping_file.txt',sep='\t' ,header=T, comment.char = "")

#merge together mapping files.
map_merge <- rbind(map.a, map.b)
#convert sample ID to character vector
map_merge$X.SampleID <- as.character(map_merge$X.SampleID)

#Merge together OTU tables.
otu_table.a$merge_col <- rownames(otu_table.a)
otu_table.b$merge_col <- rownames(otu_table.b)
otu_merge <- merge(otu_table.a, otu_table.b, all=T)
rownames(otu_merge) <- otu_merge$merge_col
#replaces NAs with zeros.
otu_merge[is.na(otu_merge)] <- 0

#merge together two taxonomy files.
taxonomy.a$merge_col <- rownames(taxonomy.a)
taxonomy.b$merge_col <- rownames(taxonomy.b)
tax_merge <- merge(taxonomy.a,taxonomy.b, all=T)
rownames(tax_merge) <- tax_merge$merge_col

#subset to only include observations in both the OTU table and mapping files.
otu_merge <- otu_merge[,colnames(otu_merge) %in% map_merge$X.SampleID]
map_merge <- map_merge[map_merge$X.SampleID %in% colnames(otu_merge),]

#some Sample IDs have leading or trailing `.` characters. remove these.
map_merge$X.SampleID <- gsub("^\\.||\\.$", "", map_merge$X.SampleID)
colnames(otu_merge) <- gsub("^\\.||\\.$", "", colnames(otu_merge))

#put rows of map_merge in the same order as columns of otu_merge
map_merge <- map_merge[order(map_merge$X.SampleID),]
otu_merge <- otu_merge[,order(colnames(otu_merge))]

#put rows of otu table and taxonomy table in the same order.
otu_merge <- otu_merge[order(rownames(otu_merge)),]
tax_merge <- tax_merge[order(rownames(tax_merge)),]

#convert X.SampleID in mapping file to geneticSampleID format fromr rest of NEON.
#first, replace all `.` characters with `-` characters.
map_merge$geneticSampleID <- gsub('\\.','-',map_merge$X.SampleID)
#add suffix '-GEN'
map_merge$geneticSampleID <- paste(map_merge$geneticSampleID,'-GEN',sep='')
#Pull out site ID
map_merge$site <- substr(map_merge$geneticSampleID,1,4)

#Get site-level latitude and longitude for each observation.
#grab unique sites
sites <- unique(map_merge$site)
#make it a dataframe.
sites <- data.frame(sites)
sites$latitude  <- NA
sites$longitude <- NA

#loop over sites to extract latitude/longitude from nneo package.
for(i in 1:nrow(sites)){
  sites$latitude[i] <- nneo_location(sites$sites[i])$locationDecimalLatitude
  sites$longitude[i] <- nneo_location(sites$sites[i])$locationDecimalLongitude
}
#merge lat-long into mapping file
map_merge <- merge(map_merge,sites,by.x='site',by.y='sites',all.x=T)

#pull apart geneticSampleID to get date
map_merge$date <- substrRight(as.character(map_merge$geneticSampleID),12)
map_merge$date <- substr(map_merge$date,1,8)
map_merge$year  <- substr(map_merge$date,1,4)
map_merge$month <- substr(map_merge$date,5,6)
map_merge$day   <- substr(map_merge$date,7,8)
map_merge$date <- paste0(map_merge$year,'-',map_merge$month,'-',map_merge$day)
map_merge$year_month <- paste0(map_merge$year,'-',map_merge$month)
#Give it a continuous date value, with 0 = Jan 1, 2013
date.lookup <- format(seq(as.Date("2013-01-01"), as.Date("2016-12-31"), by = "1 day"))
map_merge$epoch_date <- match(map_merge$date, date.lookup)

#save output.
saveRDS(otu_merge,otu.out)
saveRDS(map_merge,map.out)
saveRDS(tax_merge,tax.out)