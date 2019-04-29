create or replace force view prs_ui_card_vw as
select 
    ci.id card_instance_id
    , oc.card_mask
    , ci.seq_number
    , nvl(ci.cardholder_name, trim(upper(ci.embossed_surname||' '||ci.embossed_first_name))) as cardholder_name
    , oc.inst_id
    , ci.agent_id
    , ct.product_id
    , oc.card_type_id
    , ci.blank_type_id
    , ci.perso_priority
    , ci.pin_request
    , ci.embossing_request
    , ci.pin_mailer_request
    , ba.batch_id
    , nvl2(ba.batch_id, 1, 0) included
    , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
    , ci.reissue_reason
    , oc.cardholder_id
    , com_ui_person_pkg.get_first_name(ch.person_id, null) as first_name
    , com_ui_person_pkg.get_surname(ch.person_id, null)    as surname
    , com_ui_user_env_pkg.get_user_lang as lang
    , ci.card_uid
from 
    iss_card_instance ci
    , iss_card oc
    , iss_card_number cn
    , iss_cardholder ch
    , ( select
            bc.batch_id
            , bc.card_instance_id
        from
            prs_batch bt
            , prs_batch_card bc
        where
            bt.id = bc.batch_id(+)
            and bt.status in ('BTST0001', 'BTST0003')
      ) ba
    , prd_contract ct
where
    oc.id = ci.card_id
    and decode(ci.state, 'CSTE0100', 'CSTE0100') = 'CSTE0100'
    and oc.id = cn.card_id
    and ba.card_instance_id(+) = ci.id
    and oc.inst_id in (select inst_id from acm_cu_inst_vw)
    and oc.contract_id = ct.id
    and ci.icc_instance_id is null
    and ch.id(+) = oc.cardholder_id
/
