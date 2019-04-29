create or replace force view atm_api_dispenser_vw as
select a.id
     , a.terminal_id
     , a.disp_number
     , a.face_value
     , a.currency
     , a.denomination_id
     , nvl(b.note_loaded, 0) note_loaded
     , nvl(b.note_dispensed, 0) note_dispensed
     , nvl(b.note_remained, 0) note_remained
     , nvl(b.note_rejected, 0) note_rejected
     , b.cassette_status
  from atm_dispenser a
     , atm_dispenser_dynamic b
 where a.id = b.id(+)
   and not exists(select 1 from acq_terminal t where t.id = a.terminal_id and t.is_template = 1) 
/
