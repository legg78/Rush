create or replace force view prs_ui_batch_card_vw as
select 
    n.id
    , n.batch_id
    , n.process_order
    , n.card_instance_id
    , n.pin_request
    , n.pin_generated
    , n.pin_mailer_request
    , n.pin_mailer_printed
    , n.embossing_request
    , n.embossing_done
    , oc.card_mask
    , ci.seq_number
    , nvl(ci.cardholder_name, trim(upper(ci.embossed_surname||' '||ci.embossed_first_name))) as cardholder_name
    , oc.inst_id
    , ci.agent_id
    , ct.product_id
    , oc.card_type_id
    , ci.blank_type_id
    , ci.perso_priority
    , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
    , ci.reissue_reason
    , ost_ui_agent_pkg.get_agent_number(i_agent_id => ci.agent_id) as agent_number
    , oc.cardholder_id
    , com_ui_person_pkg.get_first_name(ch.person_id, null) as first_name
    , com_ui_person_pkg.get_surname(ch.person_id, null)    as surname
    , com_ui_user_env_pkg.get_user_lang as lang
    , ci.card_uid
from 
    prs_batch_card n
    , iss_card_instance ci
    , iss_card oc
    , iss_card_number cn
    , iss_cardholder ch
    , prd_contract ct
where
    n.card_instance_id = ci.id
    and oc.id = ci.card_id
    and oc.contract_id = ct.id
    and oc.id = cn.card_id
    and ch.id(+) = oc.cardholder_id
/
