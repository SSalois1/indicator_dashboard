#library(raster)
library(lubridate)
library(dplyr)
library(sf)
## Process Biological Sampling Monitoring data
#bsm_data <- here::here('app/data/ILXSMdata_10-19-2023_10-25-2023.csv')
process_bsm_data <- function(bsm_data) {
  dat <- read.csv(bsm_data)
  dat <- dat %>%
    mutate(PARAM_VALUE_NUM = case_when(PARAM_TYPE == 'ML' & UNIT_MEASURE == 'CM' ~ PARAM_VALUE_NUM * 10, 
                                       PARAM_TYPE == 'ML' & UNIT_MEASURE == 'MM'~ PARAM_VALUE_NUM, 
                                       PARAM_TYPE == 'WT' & UNIT_MEASURE == 'GM' ~ PARAM_VALUE_NUM, 
                                       PARAM_TYPE == 'OW' & UNIT_MEASURE == 'GM' ~ PARAM_VALUE_NUM))
  dat$date <-lubridate::dmy(dat$LAND_DATE)
  dat <- dat %>%
    mutate(year = lubridate::year(date),
           month = lubridate::month(date),
           week = lubridate::week(date), 
           day = lubridate::day(date))
    
}


## Process Study Fleet data  
process_sf_data <- function(sf_data) {
  df <- read.csv(sf_data)
  #df$DATE <-lubridate::ymd(df$DATE)
  sf.df <- df
  unq_years = unique(df$YEAR)
  raster_list <- list()
  df_list <- list()
  for (i in 1:length(unq_years)){
    tmp <- df %>% filter(YEAR == unq_years[i]) %>% 
             drop_na('START_HAUL_LON','START_HAUL_LAT')
    #Setting the bin size here 
    raster_grid <- raster(xmn=min(tmp$START_HAUL_LON), # note END_SET_LON range is odd
                          xmx=max(tmp$START_HAUL_LON), 
                          ymn=min(tmp$START_HAUL_LAT),
                          ymx=max(tmp$START_HAUL_LAT),
                          res=0.33333)
    
    #Setting coordinates for the VTR data
    coordinates(tmp) <- c('START_HAUL_LON','START_HAUL_LAT')
    
    #Creating catch rasters
    catch_raster <- rasterize(tmp %>% st_as_sf(),
                              raster_grid,'SUM_Illex_CATCH',
                              fun=function(x, ...) sum(na.omit(x))) #Sets the function for the raster cells (could be mean or a sum or somrthing else)
    # id_raster_sub is 0,1 based on conditional statement, here dividing the 
    # raster by itself makes all 0s NAs, so mask works. 
    id_raster <- rasterize(tmp %>% st_as_sf(),
                           raster_grid,'VESSEL_PERMIT_NUM',
                           fun=function(x, ...) length(unique(x)))
    id_raster_sub <- id_raster[[1]]>2
    catch_raster_sub <- mask(catch_raster,id_raster_sub/id_raster_sub) 
    #Converting the raster over to a df
    catch_raster_sub_spdf <- as(catch_raster_sub, "SpatialPixelsDataFrame")
    catch_raster_sub_df <- as.data.frame(catch_raster_sub_spdf)
    colnames(catch_raster_sub_df) <- c("value", "x", "y")
    #assign(paste0('sf_conf_', unq_years[i]), catch_raster_sub_df) 
   # ls[i] <- assign(paste0('r_', unq_years[i]), catch_raster_sub)
    # return(assign(paste0('sf_conf_', unq_years[i]), catch_raster_sub_df)) 
    # return(assign(paste0('r_', unq_years[i]), catch_raster_sub)) 
   # df_list[[length(df_list) + 1]] <- assign(paste0('sf_conf_', unq_years[i]), catch_raster_sub_df)
    raster_list[[length(raster_list) + 1]] <- assign(paste0('r_', unq_years[i]), catch_raster_sub)
  }
  #ls <- as.list(raster_list)
  #s = stack(ls)
  raster_list[[length(raster_list) + 1]]<- sf.df
  return(raster_list)
  # out <- list(y, z)              # Store output in list
  # return(out)                    # Return output
  
}
# r.2021 <- r_list[[1]]
# r.2022 <- raster_list[[2]]
# writeRaster(r_list[[1]], filename = 'sf_conf_2021.tif', format = 'GTiff')
# writeRaster(r_list[[2]], filename = 'sf_conf_2022.tif', format = 'GTiff')

## Process eMOLT data
process_emolt_data <- function(emolt_data, currentweek) {
  emolt <- read.csv(emolt_data)
  emolt <- emolt[,-1]
  # add additional date variables
  emolt$datet <- ymd_hms(emolt$datet)
  emolt <- emolt %>% 
    mutate(year = year(datet),
           month = month(datet),
           week = week(datet), 
           day = day(datet)) %>%
    as.data.frame()
  # subset by current week for years of interest
  ls <- list(assign(paste('e_2023', sep='_', currentweek),emolt %>% 
                      filter(year == 2023 & week == currentweek)), 
             assign(paste('e_2022', sep='_', currentweek),emolt %>% 
                      filter(year == 2022 & week == currentweek)))
  # set up to get min/max mean temps across years to set scale 
  y23 <- ls[[1]] %>% 
    summarise(min.temp = min(mean_temp), max.temp = max(mean_temp)) 
  y22 <-ls[[2]] %>% 
    summarise(min.temp = min(na.omit(mean_temp)), max.temp = max(na.omit(mean_temp)))
  mintemps <- c(y22$min.temp,y23$min.temp)
  maxtemps <- c(y22$max.temp,y23$max.temp)
  loc.min = which.min(mintemps)
  loc.max = which.min(maxtemps)
  ls[[3]] <- mintemps; ls[[4]]<-maxtemps; ls[[5]] <- loc.min; ls[[6]] <- loc.max
  names(ls) <- c('y23', 'y22', 'mintemps', 'maxtemps', 'loc.min', 'loc.max')
  return(ls)
}

