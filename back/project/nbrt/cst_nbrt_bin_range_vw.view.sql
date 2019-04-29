create or replace force view cst_nbrt_bin_range_vw as
select id
     , pan_low
     , pan_high
     , pan_length
     , priority
     , country
     , iss_network_id
  from cst_nbrt_bin_range
/
