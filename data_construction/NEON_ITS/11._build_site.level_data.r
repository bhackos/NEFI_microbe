#Getting site-level NEON data for site-level prediction.
#clear environment, source paths.
#Need to aggregate:
#mat, map, NPP - spatial products.
#forest (0,1), conifer (0,1), relEM - forest data.
#pC, C:N, pH, soil moisture - soil data.
rm(list = ls())
library(runjags)
source('paths.r')
source('NEFI_functions/hierarch_core.means_JAGS.r')
source('NEFI_functions/hierarch_plot.means_JAGS.r')
source('NEFI_functions/crib_fun.r')

#load core level data.
core.dat <- readRDS(core.table.path)
core.dat <- core.dat[,c('siteID','plotID','sampleID','soilMoisture','soilInWaterpH')]

moisture <- hierarch_core.means_JAGS(x_mu = core.dat$soilMoisture , core_plot = core.dat$plotID)
      pH <- hierarch_core.means_JAGS(x_mu = core.dat$soilInWaterpH, core_plot = core.dat$plotID)

#load plot level data.
plot.dat <- readRDS(plot.table.path)
organicCpercent <- hierarch_plot.means_JAGS(x_mu = plot.dat$organicCPercent, plot_site = plot.dat$siteID)
        CNratio <- hierarch_plot.means_JAGS(x_mu = plot.dat$CNratio        , plot_site = plot.dat$siteID)


#Get relative abundance EM
dp.10098.plot <- readRDS(dp1.10098.00_plot.level.path)
to.ag <- dp.10098.plot[,c('plotID','siteID','relEM','basal_live')]
#gotta crib and logit transform to scale up.
to.ag$relEM <- boot::logit(crib_fun(to.ag$relEM))
relEM <- hierarch_plot.means_JAGS(x_mu = to.ag$relEM, plot_site = to.ag$siteID, gamma_variance = T)
basal <- hierarch_plot.means_JAGS(x_mu = to.ag$basal_live, plot_site = to.ag$siteID)

#Get wheter its a forest or not.Colin just got this from the site descriptions, data is below.
#Consider dropping STER, its agriculture.
siteID <- c('DSNY','HARV','BART','JERC','ORNL','SCBI','TALL','UNDE','CPER','STER','WOOD')
forest <- c(0,1,1,0,1,1,1,1,0,0,0)
forest.data <- data.frame(siteID,forest)
