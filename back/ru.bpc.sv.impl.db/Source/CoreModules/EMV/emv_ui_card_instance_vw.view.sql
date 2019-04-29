create or replace force view emv_ui_card_instance_vw as
select
    ci.id as card_instance_id
    , oc.inst_id
    , get_text('ost_institution', 'name', oc.inst_id, l.lang) as inst_name
    , ci.status
    , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
    , oc.card_mask
    , ci.seq_number
    , ci.expir_date
    , ap.id as appl_scheme_id
    , get_text('emv_appl_scheme', 'name', ap.id, l.lang) as appl_scheme_name
    , ap.type as appl_type
    , l.lang
    , m.customer_number
from
    iss_card_instance ci
    , iss_card oc
    , iss_card_number cn
    , iss_product_card_type pd
    , prd_contract cn
    , prd_customer m
    , emv_appl_scheme ap
    , com_language_vw l
where
    oc.inst_id in (select inst_id from acm_cu_inst_vw)
    and oc.id = ci.card_id
    and oc.id = cn.card_id
    and pd.bin_id = ci.bin_id
    and pd.card_type_id = oc.card_type_id
    and oc.contract_id = cn.id
    and cn.product_id = pd.product_id
    and ci.seq_number between pd.seq_number_low and pd.seq_number_high
    and ap.id = pd.emv_appl_scheme_id
    and m.id = oc.customer_id
/
