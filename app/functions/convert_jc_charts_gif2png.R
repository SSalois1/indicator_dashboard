# This script is to read in .gif files and convert to png
library(caTools)
library(Sci)
library(stringr)
library(magick)

## Convert names
files = list.files(path=here::here('images/jc_charts/2023'), pattern = '*.gif', 
               full.names = TRUE)
for (i in 1:length(files)) {
  # x = 'entirecolor0523' # make this name of each file 
  x = substr(files[i],start = 88, stop = 102) # was 83/97 96, stop = 110
  x_letters <- gsub("[[:digit:]]", "", x) # Extract letters from character string
  x_numbers <- gsub("[^0-9.-]", "", x)                # Extract numbers from character string
  x_numbers_split <- unlist(strsplit(x_numbers, ""))  # Split characters into vector
  monthday <- paste0(x_numbers_split[1],x_numbers_split[2],'_', 
                  x_numbers_split[3],x_numbers_split[4], '_2023')
  d <- lubridate::mdy(monthday)
  weekofyear <- as.character(lubridate::isoweek(d))
  files[i] = str_replace(files[i], pattern = x_letters, 'jc_2023_wk_')
  files[i] = str_replace(files[i], pattern = x_numbers, weekofyear)
 # l <- sub('^(.{90})', '\\1_\\2', l)
}
## set wd to add newly converted and named files 


setwd(here::here('app/www'))
#files <- files[-58] # get rid of animation i made 
files.og = list.files(path=here::here('images/jc_charts/2023'), pattern = '*.gif', 
                   full.names = TRUE)
files.og = list.files(path=here::here('images/jc_charts/2021_Jan2May'), pattern = '*.gif', 
                      full.names = TRUE)
for (i in 1:length(files.og)){
  filename = substr(files[i],start = 96, stop = 107)
  png(file=paste(filename, '.png',sep=""),    width = 3000, 
      height = 2000, units = "px",bg = 'transparent')
  g = magick::image_read(files.og[i])
  plot(g)
  dev.off()
}


# annimation
list.files(path=here::here('images/jc_charts/'), pattern = '*.gif', 
           full.names = TRUE) %>% 
  image_read() %>% # reads each path file
  image_join() %>% # joins image
  image_animate(fps=4) %>% # animates, can opt for number of loops
  image_write("FileName.gif") # write to current dir
