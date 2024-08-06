source(here::here('app/dbconnection.R'))
trip <- dplyr::tbl(con.db1, dbplyr::in_schema("FVTR", "COMBINED_VERS_VIEW"))
trip_tot  <- trip |> group_by(TRIP_ID) %>% 
  summarise(SUM=sum(HAIL_AMOUNT,na.rm=TRUE)) %>% collect()

sql_pull <- "SELECT * from fvtr.COMBINED_VERS_VIEW"
## Use username/password authentication.
con.db1 <- dbConnect(drv, username = usr, password = pswd,
                     dbname = connect.string)
sql_pull_bt <- "SELECT * from NERS.GTE_EFFORTS"
sql_pull_db_bt <- dbplyr::dbGetQuery(con.db1,sql_pull_bt)


left join BSM.BSM_Tally_View tv
on tv.tally_no = vv.tally_no
left join (select trip_id, effort_num,species_itis, common_name,
           sum(hail_amount)over(partition by trip_id, effort_num, species_itis, common_name,hail_amount_uom) as total_effort_catch,
           hail_amount_uom from FVTR.combined_vers_view) f
on v.vtr_serial_num = cast(f.trip_id as varchar2 (14)) and v.effort_num = cast(f.effort_num as varchar2 (4 byte)) and v.species_itis = f.species_itis
left join NERS.gte_efforts n
on v.vtr_serial_num = cast(n.trip_id as varchar2 (14)) and v.effort_num = n.effort_num
where (ORGANISM_ID >= 1) and (sample_source_code ='05')
order by TALLY_NO, ORGANISM_ID

































