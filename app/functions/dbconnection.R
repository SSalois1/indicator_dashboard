##Setting up DB connection
#Setting up connections to  using ROracle. This can be tricky to set up, and I believe only works with R 3.6. Check out this walk through (https://medium.com/analytics-vidhya/how-to-install-roracle-on-windows-10-144b0b923dac). It covers most of the things you need to get ROracle installed (changing path variables, installing Rtools, having the Oracle instant client).

######
#Once loaded packages edit your user name and database specifics and run from here down
#You have to put in your user name
usr <- c('ssalois')
#Asks for you pswd in pop up (no need to edit here)
pswd <- .rs.askForPassword('Password')

#Database specifics
drv <- dbDriver("Oracle")
host <- 'nefscdb1.nmfs.local'
port <- 1526
sid <- 'nefscdb1'
servicename <- 'NEFSC_USERS'

#Putting all of that together
# connect.string <- paste(
#   "(DESCRIPTION=",
#   "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
#   "(CONNECT_DATA=(SID=", sid, ")))", sep = "")
connect.string <- paste(
  "(DESCRIPTION=",
  "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
  "(CONNECT_DATA=(SERVICE_NAME=", servicename, ")))", sep = "")

## Use username/password authentication.
con.db1 <- dbConnect(drv, username = usr, password = pswd,
                 dbname = connect.string)

