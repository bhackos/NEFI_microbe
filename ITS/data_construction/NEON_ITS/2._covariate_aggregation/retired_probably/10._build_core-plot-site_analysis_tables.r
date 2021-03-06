#formatting neon data for spatial prediction.
#1. observation (y) table with core, plot and site IDs.
#2. core level predictor (x_core) table with core, plot and site IDs.
#3. plot level predictor (x_plot) table with plot and site IDs.
#4. site level predictor (x_site) table with site IDs.

#clearn envirionment, source paths.
rm(list=ls())
source('paths.r')
source('NEFI_functions/crib_fun.r')

##### 1. Build observation table. ####
#this currently uses the data Lee Stanish sent to CA personally.
#Will be replaced by pipeline CA builds to pull all NEON ITS data from MG-RAST, and process into taxonomy and functional group tables stored on geo.
#otu table will become an ASV table, trimmed to only include ASV's that are fungal.
#map file with link to DP1.10801.001 by dnaSampleID. dnaSampleID will also be the column names of the OTU table. ASVs will be rownames of otu and tax tables.
#in addition to ASV table microbial functional group (mfg) table will already be prepped as part of a FUNGuild script.
fun <- readRDS(its_fun.path)
dp1.10801 <- readRDS(dp1.10108.00_output.path)
fun$dnaSampleID <- paste0(fun$geneticSampleID,'-DNA1')

#we lose 342 observatinos here because they are not in dp1.10801.001. Retain 716.
obs.table <- merge(fun,dp1.10801)

#For spatial forecast I want FIRST time soils were sampled, at peak green-ness.
#Get unique site-date combinations, sort by date.
site_dates <- list()
sites <- unique(obs.table$siteID)
for(i in 1:length(sites)){
  site_dates[[i]] <- sort(unique(obs.table[obs.table$siteID == sites[i],]$dateID))
}
names(site_dates) <- sites

#All sites have either a 2014-07 or 2014-08 observation. Lets build spatial prediction on this.
#214 unique observations over 11 NEON sites to model.
to_keep <- c()
for(i in 1:length(site_dates)){
  z <- site_dates[[i]][site_dates[[i]] %in% c('2014-07','2014-08')]
  to_keep[i] <- paste0(names(site_dates[i]),'-',z[1])
}
obs.table$site_date <- paste0(obs.table$siteID,'-',obs.table$dateID)
obs.table <- obs.table[obs.table$site_date %in% to_keep,]
obs.table$site_date_plot <- paste0(obs.table$site_date,'-',obs.table$plotID)


#### 2. Build core table. ####
#These are observations made on the same soil cores as molecular data.
#temperature, moisture, pH, depth, horizon.
dp1.10086 <- readRDS(dp1.10086.00_output.path)
dp1.10086$site_date <- paste0(dp1.10086$siteID,'-',dp1.10086$dateID)
core.table <- dp1.10086[dp1.10086$site_date %in% obs.table$site_date,]
core.table$site_date_plot <- paste0(core.table$site_date,'-',core.table$plotID)

#### 3. Build plot table. ####
#Aggregate data at the plot scale to a mean and a sd for all predicts.
#This is soil %C and %N and C:N.
dp1.10078 <- readRDS(dp1.10078.00_output.path)
dp1.10078$site_date_plot <- paste0(dp1.10078$siteID,'-',dp1.10078$dateID,'-',dp1.10078$plotID)
#begin aggregation
#get mean and sd of %C, %N and C:N by plot. 
to.ag <- dp1.10078[,c('plotID','nitrogenPercent','organicCPercent','CNratio')]
plot.table <- aggregate(.~plotID, to.ag, mean, na.rm=T)
plot.sd <- aggregate(.~plotID, to.ag, sd, na.rm=T)
colnames(plot.sd)[2:ncol(plot.sd)] <- paste0(colnames(plot.sd)[2:ncol(plot.sd)],'_sd')
plot.table <- merge(plot.table, plot.sd)
plot.table$siteID <- substr(plot.table$plotID,1,4)

#Get relative abundance EM
dp.10098.plot <- readRDS(dp1.10098.00_plot.level.path)
to.ag <- dp.10098.plot[,c('plotID','relEM','basal_live')]
#gotta crib and logit transform to scale up.
to.ag$relEM <- boot::logit(crib_fun(to.ag$relEM))
EM.plot.table <- aggregate(.~plotID, to.ag, mean, na.rm=T)
#EM.plot.sd    <- aggregate(.~plotID, to.ag,   sd, na.rm=T)

##### 4. Build site table. ####
#this is easy since I don't have any time series data in here yet, just historical. Will want this months rainfall/temperature eventually.
site.table <- readRDS(site_level_data.path)



#### Save the output. ####
saveRDS( obs.table, obs.table.path)
saveRDS(core.table,core.table.path)
saveRDS(plot.table,plot.table.path)
saveRDS(site.table,site.table.path)
