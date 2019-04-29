create or replace force view atm_ui_dispenser_vw as
select d.id
     , d.terminal_id
     , d.disp_number
     , d.face_value face_value
     , d.currency
     , com_api_currency_pkg.get_amount_str(d.face_value * power(10, c.exponent), d.currency) face_value_name
     , d.denomination_id
     , t.disp_rest_warn
     , d.dispenser_type 
     , get_article_text(d.dispenser_type) as dispenser_type_name
     , nvl(y.note_loaded, 0) note_loaded
     , com_api_currency_pkg.get_amount_str(nvl(y.note_loaded, 0) * d.face_value * power(10, c.exponent), d.currency) sum_loaded
     , nvl(y.note_dispensed, 0) note_dispensed
     , com_api_currency_pkg.get_amount_str(nvl(y.note_dispensed, 0) * d.face_value * power(10, c.exponent), d.currency) sum_dispensed
     , nvl(y.note_rejected, 0) note_rejected
     , com_api_currency_pkg.get_amount_str(nvl(y.note_rejected, 0) * d.face_value * power(10, c.exponent), d.currency) sum_rejected
     , nvl(y.note_remained, 0) note_remained
     , com_api_currency_pkg.get_amount_str(nvl(y.note_remained, 0) * d.face_value * power(10, c.exponent), d.currency) sum_remained
     , nvl(y.cassette_status, 'CSSTDSBL') cassette_status
     , get_article_text(nvl(y.cassette_status, 'CSSTDSBL')) as cassette_status_name
  from atm_dispenser d
     , atm_dispenser_dynamic y
     , atm_terminal t
     , com_currency c
 where d.id = y.id(+)
   and d.currency = c.code
   and d.terminal_id = t.id
   and nvl(set_ui_value_pkg.get_system_param_v(i_param_name => 'FACE_VALUE_FORMAT'), 'FVFT0002') = 'FVFT0002'
 union all
select d.id
     , d.terminal_id
     , d.disp_number
     , d.face_value face_value
     , d.currency
     , com_api_currency_pkg.get_amount_str(d.face_value * power(10, c.exponent), d.currency) face_value_name
     , d.denomination_id
     , t.disp_rest_warn
     , d.dispenser_type 
     , get_article_text(d.dispenser_type) as dispenser_type_name
     , nvl(y.note_loaded, 0) note_loaded
     , com_api_currency_pkg.get_amount_str(nvl(y.note_loaded, 0) * d.face_value * power(10, c.exponent), d.currency) sum_loaded
     , nvl(y.note_dispensed, 0) note_dispensed
     , com_api_currency_pkg.get_amount_str(nvl(y.note_dispensed, 0) * d.face_value * power(10, c.exponent), d.currency) sum_dispensed
     , nvl(y.note_rejected, 0) note_rejected
     , com_api_currency_pkg.get_amount_str(nvl(y.note_rejected, 0) * d.face_value * power(10, c.exponent), d.currency) sum_rejected
     , nvl(y.note_remained, 0) note_remained
     , com_api_currency_pkg.get_amount_str(nvl(y.note_remained, 0) * d.face_value * power(10, c.exponent), d.currency) sum_remained
     , nvl(y.cassette_status, 'CSSTDSBL') cassette_status
     , get_article_text(nvl(y.cassette_status, 'CSSTDSBL')) as cassette_status_name
  from atm_dispenser d
     , atm_dispenser_dynamic y
     , atm_terminal t
     , com_currency c
 where d.id = y.id(+)
   and d.currency = c.code
   and d.terminal_id = t.id
   and set_ui_value_pkg.get_system_param_v(i_param_name => 'FACE_VALUE_FORMAT') = 'FVFT0001'
/
