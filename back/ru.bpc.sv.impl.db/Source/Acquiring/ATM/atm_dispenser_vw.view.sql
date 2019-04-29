create or replace force view atm_dispenser_vw as
select
    a.id
  , a.terminal_id
  , a.disp_number
  , a.face_value
  , a.currency
  , a.denomination_id
  , a.dispenser_type
from
    atm_dispenser a
/
