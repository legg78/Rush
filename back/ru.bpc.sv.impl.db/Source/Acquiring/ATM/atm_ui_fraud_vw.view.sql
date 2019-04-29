create or replace force view atm_ui_fraud_vw as
select f.object_id as terminal_id
     , o.oper_date
     , o.oper_type
     , get_article_text(i_article => o.oper_type, i_lang => l.lang) oper_type_name
     , o.oper_currency
     , get_text('com_currency', 'label', c.id, l.lang) oper_currency_name
     , c.exponent
     , o.oper_amount
     , f.event_type
     , get_article_text(i_article => f.event_type, i_lang => l.lang) event_type_name
     , f.case_id
     , get_text('frp_case', 'label', f.case_id, l.lang) case_label
     , iss_api_token_pkg.decode_card_number(i_card_number => p.card_number) as card_number
     , iss_api_card_pkg.get_card_mask(i_card_number => p.card_number) as card_mask
     , l.lang
  from frp_fraud f
     , opr_operation o
     , opr_card p
     , com_currency c
     , com_language_vw l
 where f.entity_type = 'ENTTTRMN'
   and f.auth_id = o.id
   and o.id = p.oper_id(+)
   and p.participant_type(+) = 'PRTYISS'
/