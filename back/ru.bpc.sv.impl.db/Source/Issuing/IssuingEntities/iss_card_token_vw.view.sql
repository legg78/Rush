create or replace force view iss_card_token_vw as
select t.id
     , t.card_id
     , t.card_instance_id
     , t.token
     , t.status
     , t.split_hash
     , t.init_oper_id
     , t.close_session_file_id
     , t.wallet_provider
  from iss_card_token t
/
