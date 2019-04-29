create or replace force view iss_ui_card_token_vw as
select t.id
     , t.card_id
     , t.card_instance_id
     , ci.expir_date
     , t.status
     , t.token
     , t.init_oper_id
     , t.wallet_provider
  from iss_card_token t
     , iss_card_instance ci
 where t.card_instance_id = ci.id
/
