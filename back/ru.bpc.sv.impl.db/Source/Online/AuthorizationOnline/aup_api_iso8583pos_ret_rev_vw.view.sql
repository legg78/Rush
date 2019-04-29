create or replace force view aup_api_iso8583pos_ret_rev_vw as
select count(1) reversal_count
     , rrn
     , local_date
  from aup_iso8583pos
 where iso_msg_type = 410
   and resp_code = '000'
   and substr(proc_code, 1, 2) in ('20', '94')
 group by rrn, local_date
/