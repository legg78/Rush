create or replace force view opr_ui_participant_vw as
select
    p.oper_id
    , p.participant_type
    , p.inst_id
    , p.network_id
    , p.split_hash
    , p.client_id_type
    , p.client_id_value
    , p.customer_id
    , p.auth_code
    , p.card_id
    , p.card_instance_id
    , p.card_type_id
    , iss_api_card_pkg.get_card_mask(i_card_number => r.card_number) as card_mask
    , p.card_hash
    , p.card_seq_number
    , p.card_expir_date
    , p.card_service_code
    , p.card_country
    , p.card_network_id
    , p.card_inst_id
    , p.account_id
    , p.account_type
    , p.account_number
    , p.account_amount
    , p.account_currency
    , p.merchant_id
    , p.terminal_id
    , c.customer_number
    , iss_api_token_pkg.decode_card_number(i_card_number => r.card_number) as card_number
from
    opr_participant p
    , prd_customer c
    , opr_card r
where
    p.inst_id in (select inst_id from acm_cu_inst_vw)
    and c.id(+) = p.customer_id
    and r.oper_id(+) = p.oper_id
    and r.participant_type(+) = p.participant_type
/
