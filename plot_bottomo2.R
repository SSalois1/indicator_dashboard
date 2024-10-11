source(here::here('app/functions/func_convertdateNcdf2R.R'))
files <- list.files(path = here::here('nc_files/'), pattern = glob2rx('ocean_*.nc'),
                    full.names = TRUE)
# Stat
i=1
nc <- ncdf4::nc_open(files[i])
lat <- ncdf4::ncvar_get(nc, 'yh')
lon <- ncdf4::ncvar_get(nc, 'xh')
btm.o2 <- ncdf4::ncvar_get(nc, attributes(nc$var)$names[1]) # "btm_o2"
t <- ncdf4::ncvar_get(nc, 'time')  # Extract time 
tunits <- ncdf4::ncatt_get(nc,'time','units') # identify units for the conversion
splitt <- strsplit(tunits$value, " ") # parse time units for conversion
# convert dates!
ptime <- convertDateNcdf2R(t, unlist(splitt)[1], 
                           origin =  as.POSIXct(unlist(splitt)[3], tz = "UTC"), 
                           time.format = "%Y-%m-%d")
ptime <- lubridate::ymd_hms(ptime)
image(btm.o2[,,98])
range(na.omit(btm.o2[,,98]))

filled.contour(lon, lat, btm.o2[,,98], main = paste("Bottom O2 ", ptime[98]),
               xlab = "Longitude", ylab = "Latitude") #,levels = pretty(c(0.01,0.5), 20))
r = terra::flip(t(terra::rast(btm.o2)), direction='vertical')
terra::plot(r[[98]])
names(r) <- ptime 
terra::time(r) <- names(r) %>%  lubridate::ymd_hms() %>% as.Date() 
terra::ext(r) <- c(xmn = min(lon), xmx = max(lon), # set extent
            ymn = min(lat), ymx = max(lat))
terra::crs(r)  <- 'epsg:4326' # set a projection, WGS 84 has EPSG code 4326

# this is mol kg-1, need to convert to mg/L
# One micromole (umol) of oxygen is equal to 0.022391 milligrams
# Thus 100 umol/L O2 is equal to 2.2 mg/L O2
# kilogram-mole (kg-mol) micromole: if numol = 1, then nkgmol = 1.0 * 10-9 * 1
# kilogram-mole to micromole to mg/L
# molar mass of oxygen = 32 (31.999)
terra::plot(r[[678]],main = paste("Bottom O2 ", names(r[[678]])))
# Molarity is moles per liter, multiply by the molar mass in grams per mole and you’re there.
# Converting O2 in mass units (µmol/kg) to O2 in volume units (mg/l)
terra::values(r) <-terra::values(r)*32*1000
terra::plot(r[[9]])
df = as.data.frame(r[[9]], xy = TRUE)

# mol/kgw * g/mol * 1000mg/g
# Molality = moles per kilogram (mol/kg)
0.00034*32*1000 # 7-8 milligrams/L is normal
### squid embryo habitat requirement 160 (umol)*32/1000
# 1 ml/l of O2 is approximately 43.570 µmol/kg (assumes a molar volume of O2 of 22.392 l/mole and a constant seawater potential density of 1025 kg/m3).
# density of o2 is 1.43 grams/l and 1.458 mg/L
#moles per milliliters: v(volume) = n(moles) * Molar mass(g/mole) / density
0.00034*32/1.45
# milligrams = milliliters × 1,000 × density
0.007503448*1000*1.45
# Mg/L=M∗MW∗1000, : molarity in Moles per liter, MW molecular weight g/mol 
0.00025*32*1000 # 7-8 milligrams/L is normal
0.00010*32*1000








