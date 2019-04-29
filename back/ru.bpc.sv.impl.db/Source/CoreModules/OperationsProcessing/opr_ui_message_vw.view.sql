create or replace force view opr_ui_message_vw
as
select
    com_api_label_pkg.get_label_text('ATM_MESSAGE', l.lang) as name
  , to_char(a.message_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_atm_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_atm         a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('CHRONOPAY_GATEWAY_MESSAGE', l.lang) as name
  , '' as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_cnpy_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_cnpy        a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('CYBERPLAT_BASED_REQUESTS', l.lang) as name
  , a.action as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_cyberplat_in_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_cyberplat_in a
  , com_language_vw  l
union
select
    com_api_label_pkg.get_label_text('E_PAY_MESSAGE', l.lang) as name
  , to_char(a.iso_msg_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_epay_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_epay        a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('ISO8583POS_MESSAGE', l.lang) as name
  , to_char(a.iso_msg_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_iso8583pos_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_iso8583pos  a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('ISO8583BIC_MESSAGE', l.lang) as name
  , to_char(a.iso_msg_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_iso8583bic_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_iso8583bic  a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('MASTERCARD_MESSAGE', l.lang) as name
  , to_char(a.iso_msg_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_mastercard_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_mastercard  a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('SVIP_MESSAGE', l.lang) as name
  , a.message_name as tech_msg_type
  , a.auth_id as oper_id
  , a.message_name as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_svip_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_svip        a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('VISA_MESSAGE', l.lang) as name
  , to_char(a.iso_msg_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_visa_basei_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_visa_basei  a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('VISA_SMS_MESSAGE', l.lang) as name
  , to_char(a.iso_msg_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_visa_sms_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_visa_sms    a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('WAY4_MESSAGE', l.lang) as name
  , to_char(a.iso_msg_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_way4_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aup_way4        a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('MASTERCARD_CLEARING_MESSAGE', l.lang) as name
  , a.mti || '/' || a.de024 as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'mcw_ui_fin_msg_vw' as view_name
  , l.lang
  , a.de012 as oper_date
from
    mcw_fin         a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('VISA_CLEARING_MESSAGE', l.lang) as name
  , a.trans_code as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'vis_ui_fin_message_vw' as view_name
  , l.lang
  , a.oper_date as oper_date
from
    vis_fin_message a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('VISA_CLEARING_RETRIEVAL', l.lang) as name
  , b.trans_code as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'vis_ui_retrieval_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    vis_retrieval        a
  , vis_fin_message b
  , com_language_vw l
where
    b.id = a.id
union
select
    com_api_label_pkg.get_label_text('AUTHORIZATIONS_MESSAGE',  l.lang) as name
  , a.resp_code as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'aut_ui_auth_msg_vw' as view_name
  , l.lang
  , a.device_date as oper_date
from
    aut_auth        a
  , com_language_vw l
where not exists(select 1
                   from opr_operation o
                  where o.id = a.id
                    and o.msg_type = 'MSGTBTCH'
                )
union
select
    com_api_label_pkg.get_label_text('MASTERCARD_CLEARING_ADDENDUM_MESSAGE', l.lang) as name
  , a.mti || '/' || a.de024 as tech_msg_type
  , a.fin_id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'mcw_ui_add_msg_vw' as view_name
  , l.lang
  , b.de012 as oper_date
from
    mcw_add         a
  , mcw_fin         b
  , com_language_vw l
where
    a.fin_id = b.id
union
select
    com_api_label_pkg.get_label_text('ACI_ATM_FIN_MESSAGE', l.lang) as name
  , a.authx_type as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'aci_ui_atm_fin_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aci_atm_fin     a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('ACI_POS_FIN_MESSAGE', l.lang) as name
  , a.authx_typ as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'aci_ui_pos_fin_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aci_pos_fin     a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('ACI_ATM_CASH_MESSAGE', l.lang) as name
  , a.term_cash_admin_cde as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'aci_ui_atm_cash_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aci_atm_cash     a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('ACI_ATM_SETL_TTL_MESSAGE', l.lang) as name
  , a.setl_ttl_admin_cde as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'aci_ui_atm_setl_ttl_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aci_atm_setl_ttl a
  , com_language_vw  l
union
select
    com_api_label_pkg.get_label_text('ACI_ATM_SETL_MESSAGE', l.lang) as name
  , a.term_setl_admin_cde as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'aci_ui_atm_setl_msg_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    aci_atm_setl    a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('SV2SV_MESSAGE', l.lang) as name
  , to_char(a.iso_msg_type) as tech_msg_type
  , a.auth_id as oper_id
  , a.tech_id as tech_id
  , a.time_mark as time_mark
  , 'aup_ui_sv2sv_msg_vw' as view_name
  , l.lang
  , a.trans_date as oper_date
from
    aup_sv2sv       a
  , com_language_vw l
union
   select com_api_label_pkg.get_label_text ('BGN_MESSAGE', l.lang) as name
        , to_char (nvl (a.message_type, a.transaction_type)) as tech_msg_type
        , a.oper_id as oper_id
        , to_char (a.id) as tech_id
        , '' as time_mark
        , 'bgn_ui_fin_msg_vw' as view_name
        , l.lang
        , a.transaction_date as oper_date
     from bgn_fin a, com_language_vw l
union
select
    com_api_label_pkg.get_label_text('COMPASS_CLEARING_MESSAGE', l.lang) as name
  , a.tran_type as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'cmp_ui_fin_message_vw' as view_name
  , l.lang
  , a.orig_time as oper_date
from
    cmp_fin_message a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('JCB_CLEARING_MESSAGE', l.lang) as name
  , a.mti || '/' || a.de024 as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'jcb_ui_fin_message_vw' as view_name
  , l.lang
  , a.de012 as oper_date
from
    jcb_fin_message a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('CUP_CLEARING_MESSAGE', l.lang) as name
  , to_char(a.trans_code) as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'cup_ui_fin_message_vw' as view_name
  , l.lang
  , /*a.orig_time*/ to_date(null) as oper_date
from
    cup_fin_message a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('DIN_CLEARING_MESSAGE', l.lang) as name
  , a.type_of_charge as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'din_ui_fin_message_vw' as view_name
  , l.lang
  , a.charge_date as oper_date
from
    din_fin_message a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text(
        i_name => 'MUP_CLEARING_MESSAGE'
      , i_lang => l.lang
    ) as name
  , a.mti || '/' || a.de024 as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'mup_ui_fin_msg_vw' as view_name
  , l.lang
  , a.de012 as oper_date
from
    mup_fin         a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('AMX_CLEARING_MESSAGE', l.lang) as name
  , a.mtid || '/' || a.func_code as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'amx_ui_fin_msg_vw' as view_name
  , l.lang
  , a.trans_date as oper_date
from
    amx_fin_message a
  , com_language_vw l
union
select
    com_api_label_pkg.get_label_text('AMX_CLEARING_ADDENDUM_MESSAGE', l.lang) as name
  , a.mtid || '/' || b.func_code || ' - ' || a.addenda_type as tech_msg_type
  , a.fin_id as oper_id
  , to_char(a.id) as tech_id
  , '' as time_mark
  , 'amx_ui_add_msg_vw' as view_name
  , l.lang
  , b.trans_date as oper_date
from
    amx_add         a
  , amx_fin_message b
  , com_language_vw l
where
    a.fin_id = b.id  
union
select
    com_api_label_pkg.get_label_text('CUP_FEE_MESSAGE', l.lang) as name
  , to_char(a.trans_type_id) as tech_msg_type
  , a.fin_msg_id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'cup_ui_fee_collection_vw' as view_name
  , l.lang
  , to_date(null) as oper_date
from
    cup_fee a
  , com_language_vw l
order by
    time_mark
  , oper_date
/
