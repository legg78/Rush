create or replace force view acq_api_terminal_online_vw as
    select   t.id
        , t.seqnum terminal_seqnum
        , t.terminal_number
        , t.inst_id
        , t.terminal_type
        , t.status
        , t.card_data_input_cap
        , t.crdh_auth_cap
        , t.card_capture_cap
        , t.term_operating_env
        , t.crdh_data_present
        , t.card_data_present
        , t.card_data_input_mode
        , t.crdh_auth_method
        , t.crdh_auth_entity
        , t.card_data_output_cap
        , t.term_data_output_cap
        , t.pin_capture_cap
        , t.cat_level
        , t.device_id
        , t.mcc_template_id
        , t.is_mac
        , m.id merchant_id
        , m.merchant_number
        , m.merchant_name
        , m.mcc
        , s.application_plugin
        , s.id standard_id
        , t.gmt_offset
        , nvl(p.pos_batch_method, 'PSBMBTVM') pos_batch_method
        , nvl(p.partial_approval, get_false) partial_approval
        , nvl(p.purchase_amount, get_false) purchase_amount
        , nvl(p.instalment_support, get_false) instalment_support
        , m.risk_indicator
        , m.mc_assigned_id
    from
        acq_terminal t
        , acq_merchant m
        , cmn_standard_object o
        , cmn_standard s
        , pos_terminal p
    where
        m.id(+) = t.merchant_id
        and (t.is_template+0) = 0
        and o.object_id(+) = t.id
        and o.entity_type(+) = 'ENTTTRMN'
        and o.standard_type(+) = 'STDT0002'
        and s.id(+) = o.standard_id
        and t.id = p.id(+)
        and t.status = 'TRMS0001'
        and m.status(+) = 'MRCS0001'
/
