library("ncdf4")
#system("wget https://raw.githubusercontent.com/NOAA-CEFI-Portal/cefi-cookbook/main/environment.yml")

# Specify the OPeNDAP server URL (using regular grid output)
url <- "http://psl.noaa.gov/thredds/dodsC/Projects/CEFI/regional_mom6/northwest_atlantic/hist_run/ocean_cobalt_daily_2d.19930101-20191231.btm_o2.nc"
url <- "http://psl.noaa.gov/thredds/dodsC/Projects/CEFI/regional_mom6/northwest_atlantic/hist_run/ocean_cobalt_omip_sfc.199301-201912.dissicos.nc"

# Open a NetCDF file lazily and remotely
ncopendap <- ncdf4::nc_open(url)
# Read the data into memory
timeslice = 1
lon <- ncvar_get(ncopendap, "lon")
lat <- ncvar_get(ncopendap, "lat")
time <- ncvar_get(ncopendap, "time",start = c(timeslice), count = c(1))

# Read a slice of the data into memory
sos <- ncvar_get(ncopendap, "sos", start = c(1, 1, timeslice), count = c(-1, -1, 1))

# Get the units
tunits <- ncatt_get(ncopendap, "time", "units")
datesince <- tunits$value
datesince <- substr(datesince, nchar(datesince)-9, nchar(datesince))
datesince
# convert the number to datetime (input should be in second while the time is in unit of days)
datetime_var <- as.POSIXct(time*86400, origin=datesince, tz="UTC")
datetime_var
filled.contour(lon, lat, sos, main = paste("Sea surface salinity at ", 
                                           datetime_var), 
               xlab = "Longitude", 
               ylab = "Latitude", levels = pretty(c(20,40), 20))


df <- expand.grid(X = lon, Y = lat)
data <- as.vector(t(sos))
df$Data <- data
names(df) <- c("lon", "lat", "sos")


# Read the coordinate into memory
timeslice = 1
xh <- ncvar_get(ncopendap, "xh")
yh <- ncvar_get(ncopendap, "yh")
time <- ncvar_get(ncopendap, "time",start = c(timeslice), count = c(1))

# Read a slice of the data into memory
dissicos <- ncvar_get(ncopendap, "dissicos", start = c(1, 1, timeslice), count = c(-1, -1, 1))