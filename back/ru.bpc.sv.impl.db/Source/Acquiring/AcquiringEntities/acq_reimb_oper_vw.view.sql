create or replace force view acq_reimb_oper_vw as
select
    id
  , batch_id
  , channel_id
  , pos_batch_id
  , oper_date
  , posting_date
  , sttl_day
  , reimb_date
  , merchant_id
  , account_id
  , iss_api_token_pkg.decode_card_number(i_card_number => card_number) as card_number
  , auth_code
  , refnum
  , gross_amount
  , service_charge
  , tax_amount
  , net_amount
  , inst_id
  , split_hash
from acq_reimb_oper
/
