create or replace force view atm_ui_dispenser_sum_vw as
select d.terminal_id
     , d.currency
     , c.name
     , get_text('com_currency', 'name', c.id) currency_name
     , sum(nvl(y.note_loaded, 0)) note_loaded
     , com_api_currency_pkg.get_amount_str(sum(nvl(y.note_loaded, 0)*d.face_value*power(10, c.exponent)), d.currency) sum_loaded
     , sum(nvl(y.note_dispensed, 0)) note_dispensed
     , com_api_currency_pkg.get_amount_str(sum(nvl(y.note_dispensed, 0)*d.face_value*power(10, c.exponent)), d.currency) sum_dispensed
     , sum(nvl(y.note_rejected, 0)) note_rejected
     , com_api_currency_pkg.get_amount_str(sum(nvl(y.note_rejected, 0)*d.face_value*power(10, c.exponent)), d.currency) sum_rejected
     , sum(nvl(y.note_remained, 0)) note_remained
     , com_api_currency_pkg.get_amount_str(sum(nvl(y.note_remained, 0)*d.face_value*power(10, c.exponent)), d.currency) sum_remained
  from atm_dispenser d
     , atm_dispenser_dynamic y
     , com_currency c
 where d.id = y.id(+)
   and d.currency = c.code
 group by d.terminal_id, d.currency, c.name, c.id  
/