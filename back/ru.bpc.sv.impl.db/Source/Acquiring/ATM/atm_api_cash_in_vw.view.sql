create or replace force view atm_api_cash_in_vw as
select
    a.id
  , a.terminal_id
  , a.face_value
  , a.currency
  , a.denomination_code
  , a.is_active
  , a.note_encashed_type4
  , a.note_encashed_type3
  , a.note_encashed_type2
  , a.note_retracted_type4
  , a.note_retracted_type3
  , a.note_retracted_type2
  , a.note_counterfeit_type3
  , a.note_counterfeit_type2
from
    atm_cash_in_vw a
/
