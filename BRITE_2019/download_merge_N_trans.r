source("paths.r")
library(neonUtilities)  
library(neonNTrans) 

NTR <- loadByProduct(site = "all", dpID = "DP1.10080.001", package = "basic", check.size = F)
#NTR.new <- loadByProduct(site = "all", dpID = "DP1.10080.001", package = "expanded", check.size = F)


nitr.out <- def.calc.ntrans(kclInt = NTR$ntr_internalLab, 
                       kclIntBlank = NTR$ntr_internalLabBlanks, 
                       kclExt = NTR$ntr_externalLab, 
                       soilMoist = NTR$sls_soilMoisture,
                       keepAll = T)
head(nitr.out)

#getPackage(site_code = "HARV", dpID = "DP1.10080.001", package = "expanded", year_month="2018-04")


# soil physical properties
dat <- loadByProduct(site = "all", dpID = "DP1.10086.001", package = "basic", check.size = F)
dat <- phys

# Rename dataframes
core.data <- dat$sls_soilCoreCollection
moisture.data <- dat$sls_soilMoisture
pH.data <- dat$sls_soilpH

# Merge moisture into soil cores
moist.merge <- moisture.data[,!(colnames(moisture.data) %in% colnames(core.data))]
moist.merge$sampleID <- moisture.data$sampleID
core.data <- merge(core.data,moist.merge, all = T)

# Merge pH into soil cores
pH.merge <- pH.data[,!(colnames(pH.data) %in% colnames(core.data))]
pH.merge$sampleID <- pH.data$sampleID
output <- merge(core.data,pH.merge, all = T)

# Add a couple columns for later
output$dateID <- substr(output$collectDate,1,7)
output$site_date <- paste(output$siteID, output$dateID)

# Add precise geolocation data
core.data <- geoNEON::def.calc.geo.os(output, 'sls_soilCoreCollection')
dim(core.data)



# merge soil core data with N cycling data
merge.output <- merge(core.data, nitr.out, by = c("sampleID", "plotID", "nTransBoutType", "collectDate"))

# save output
merge.output
saveRDS(merge.output, N_data_path)

