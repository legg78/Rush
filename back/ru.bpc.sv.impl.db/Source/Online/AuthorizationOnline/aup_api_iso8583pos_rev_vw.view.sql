create or replace force view aup_api_iso8583pos_rev_vw as
select sum(
           case when iso_msg_type = 410 and substr(proc_code, 1, 2) not in ('20', '94') then 1
                else 0
           end
          ) reversal_count
     , sum(
           case when iso_msg_type = 210 and substr(proc_code, 1, 2) = '20' then 1
                when iso_msg_type = 410 and substr(proc_code, 1, 2) = '20' then -1
                else 0
           end
          ) return_count
     , sum(
           case when iso_msg_type = 210 and substr (proc_code, 1, 2) = '94' then 1
                when iso_msg_type = 410 and substr (proc_code, 1, 2) = '94' then -1
                else 0
           end
          ) completion_count
     , sum(amount *
           case when iso_msg_type = 210 and substr(proc_code, 1, 2) in ('00', '09') then 1
                when iso_msg_type = 410 and substr(proc_code, 1, 2) = '20'          then 1
                when iso_msg_type = 410 and substr(proc_code, 1, 2) in ('00', '09') then -1
                when iso_msg_type = 210 and substr(proc_code, 1, 2) = '20'          then -1
                else 0
           end
          ) set_amount
     , rrn
  from aup_iso8583pos
 where resp_code = '000'
   and iso_msg_type in (110, 210, 410)
 group by rrn
/
