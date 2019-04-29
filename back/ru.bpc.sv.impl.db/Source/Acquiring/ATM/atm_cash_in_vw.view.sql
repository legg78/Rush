create or replace force view atm_cash_in_vw as
select
    a.id
  , a.terminal_id
  , a.face_value
  , a.currency
  , a.denomination_code
  , a.is_active
  , b.note_encashed_type4
  , b.note_encashed_type3
  , b.note_encashed_type2
  , b.note_retracted_type4
  , b.note_retracted_type3
  , b.note_retracted_type2
  , b.note_counterfeit_type3
  , b.note_counterfeit_type2
from
    atm_cash_in a
left join
    atm_bna_counts b on b.id = a.id
/
