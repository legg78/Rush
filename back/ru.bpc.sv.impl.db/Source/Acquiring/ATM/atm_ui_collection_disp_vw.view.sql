create or replace force view atm_ui_collection_disp_vw as
    select f.collection_id
         , f.disp_number
         , f.currency
         , f.face face_value
         , com_api_currency_pkg.get_amount_str(f.face * power(10, com_api_currency_pkg.get_currency_exponent(f.currency)), f.currency) face_value_name
         , sum(case when d.oper_type in ('OPTP0801', 'OPTP0802') then b.note_remained else 0 end) note_loaded
         , com_api_currency_pkg.get_amount_str(sum((case when d.oper_type in ('OPTP0801', 'OPTP0802') then b.note_remained else 0 end) * f.face * power(10, com_api_currency_pkg.get_currency_exponent(f.currency))), f.currency) sum_loaded
      from (
        select a.auth_id
             , a.tech_id
             , t.dispenser_id
             , t.disp_number
             , t.terminal_id
             , t.collection_id
             , t.face
             , t.currency
          from (
            select distinct l.id collection_id
                 , i.terminal_id
                 , i.disp_number
                 , first_value(i.face_value) over (partition by l.id, i.dispenser_id order by i.change_date) face
                 , first_value(i.currency) over (partition by l.id, i.dispenser_id order by i.change_date) currency
                 , i.dispenser_id
                 , l.start_date
                 , l.end_date
              from (
                select h.change_date 
                     , nvl(h.face_value, c.face_value ) face_value
                     , nvl(h.currency, c.currency) currency
                     , c.id dispenser_id
                     , c.terminal_id
                     , c.disp_number
                  from atm_dispenser_history h 
                     , atm_dispenser c
                 where h.dispenser_id(+) = c.id
                   and h.terminal_id(+)  = c.terminal_id
                   and h.disp_number(+)  = c.disp_number
                union 
                select null cahnge_date
                    , d.face_value
                    , d.currency
                    , d.id dispenser_id
                    , d.terminal_id
                    , d.disp_number
                from
                    atm_dispenser d
                ) i
                , atm_collection l
            where l.terminal_id     = i.terminal_id
              and (i.change_date is null
               or (l.start_date <= i.change_date)
              )
          ) t
          , aup_atm a
      where t.collection_id = a.collection_id(+)
        and t.terminal_id   = a.terminal_id(+)
     ) f    
     , aup_atm_disp b
     , opr_operation d
     , com_currency u
 where f.tech_id = b.tech_id(+)
   and f.disp_number = b.disp_number(+)
   and f.auth_id = d.id(+)
   and f.currency = u.code(+)      
 group by f.collection_id
     , f.disp_number
     , f.currency
     , f.face
     , u.exponent
/   
     