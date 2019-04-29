create or replace force view atm_ui_captured_card_vw as
select
    a.auth_id
  , a.terminal_id
  , a.coll_id
  , b.oper_date
  , d.card_id
  , iss_api_card_pkg.get_card_mask(c.card_number) as card_mask
  , t.resp_code
from
    atm_captured_card a
  , opr_operation b
  , opr_participant d
  , opr_card c
  , aut_auth t
  , atm_terminal_dynamic y
where a.auth_id = b.id
  and t.id = a.auth_id
  and b.id = d.oper_id(+)
  and d.participant_type(+) = 'PRTYISS' 
  and b.id = c.oper_id(+)
  and c.participant_type(+) = 'PRTYISS'
  and y.id = a.terminal_id
  and y.coll_id = a.coll_id 
/