create or replace force view aup_iso8583pos_sttl_vw as
  select nvl(
          sum( nvl( t.amount, t.amount )
               * decode( t.iso_msg_type, 210, 1, 230, 1, 410, -1, 430, -1,  0 )
               * decode( substr ( t.proc_code, 0, 2 ), '21', -1, '20', -1, 1 )
             )
          , 0
         ) amount
     , t.terminal_id
  from (
    select a.*
         , (select amount from aup_iso8583pos d where d.iso_msg_type = 310 and d.resp_code = '000' and d.trace = a.trace) d_amount
      from (
        select a.amount 
             , a.iso_msg_type
             , a.proc_code
             , t.id terminal_id
             , a.trace
         from aup_iso8583pos a
            , pos_batch b
            , pos_terminal t
        where a.terminal_id = t.id
          and a.auth_id > b.open_auth_id 
          and b.id = t.current_batch_id
          and a.iso_msg_type in ( 210, 230, 410, 430 )
          and a.resp_code = 0
     ) a
   ) t 
group by t.terminal_id
/
