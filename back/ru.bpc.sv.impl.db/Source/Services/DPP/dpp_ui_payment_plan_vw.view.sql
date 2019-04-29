create or replace force view dpp_ui_payment_plan_vw as
select a.id
     , a.oper_id
     , b.oper_type
     , get_article_text(i_article => b.oper_type, i_lang    => d.lang)
       || case when b.merchant_name is not null   then ' / ' || b.merchant_name end
       || case when b.merchant_city is not null   then ' / ' || b.merchant_city end
       || case when b.merchant_street is not null then ', '  || b.merchant_street end
       as oper_desc
     , b.merchant_name
     , b.merchant_city
     , b.merchant_street
     , a.instalment_amount
     , a.instalment_total
     , a.instalment_billed
     , a.next_instalment_date
     , a.debt_balance
     , a.account_id
     , e.account_number
     , e.currency
     , a.card_id
     , f.card_mask
     , a.product_id
     , a.oper_date
     , a.oper_amount
     , a.oper_currency
     , a.dpp_amount
     , a.dpp_currency
     , a.interest_amount
     , a.status
     , a.inst_id
     , a.split_hash
     , a.reg_oper_id
     , a.posting_date
     , d.lang
  from dpp_payment_plan a
     , opr_operation_participant_vw b
     , acc_account_vw e
     , iss_card f
     , com_language_vw d
 where a.oper_id    = b.id
   and a.account_id = e.id
   and a.card_id    = f.id(+)
   and a.inst_id in (select inst_id from acm_cu_inst_vw)
/
