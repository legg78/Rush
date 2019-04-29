create or replace force view csm_ui_unpaired_item_vw as
select o.id
     , o.msg_type
     , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as card_number
     , coalesce(mf.de025, vf.reason_code) as reason_code
     , coalesce(mf.de072, vf.member_msg_text) as mmt
     , o.sttl_amount
     , o.sttl_currency
     , o.merchant_name
     , o.terminal_number
     , o.merchant_number
     , p.auth_code
     , o.network_refnum as arn
  from csm_unpaired_item u
     , opr_ui_operation_vw o
     , opr_participant p
     , opr_card c
     , mcw_fin mf
     , vis_fin_message vf
 where u.is_unpaired_item    = 1
   and o.id                  = u.id
   and p.oper_id(+)          = o.id
   and p.participant_type(+) = 'PRTYISS'
   and c.oper_id(+)          = p.oper_id
   and c.participant_type(+) = p.participant_type
   and mf.id(+)              = o.id
   and vf.id(+)              = o.id
/
