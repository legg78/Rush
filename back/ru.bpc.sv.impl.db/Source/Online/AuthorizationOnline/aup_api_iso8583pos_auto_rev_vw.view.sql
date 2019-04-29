create or replace force view aup_api_iso8583pos_auto_rev_vw as
select count(1) reversal_count
     , trace
     , local_date
     , terminal_id
  from aup_iso8583pos
 where iso_msg_type = 400
 group by local_date
        , trace
        , terminal_id
/
