create or replace force view crd_ui_debt_vw as
select a.id
     , a.account_id
     , a.card_id
     , a.product_id
     , a.service_id
     , a.oper_id
     , a.oper_type
     , a.sttl_type
     , a.fee_type
     , a.terminal_type
     , a.oper_date
     , a.posting_date
     , a.sttl_day
     , a.currency
     , a.amount
     , a.debt_amount
     , a.mcc
     , a.aging_period
     , crd_ui_account_info_pkg.get_aging_period_name(i_aging_period => a.aging_period) as aging_period_name
     , a.is_new
     , a.status
     , a.inst_id
     , a.agent_id
     , a.split_hash
     , b.account_number
     , c.card_mask
     , iss_api_token_pkg.decode_card_number(i_card_number => d.card_number) as card_number
     , a.macros_type_id 
     , a.is_grace_enable
     , m.amount_purpose
     , s.sttl_date
     , a.is_reversal
     , (select nvl(sum(cp.amount), 0) 
          from crd_payment cp
         where cp.original_oper_id = a.oper_id
           and cp.is_reversal = 1
       ) as reverted_amount
  from crd_debt a
     , acc_account b
     , iss_card c
     , iss_card_number d
     , acc_macros m
     , com_settlement_day s
 where a.account_id = b.id
   and a.card_id    = c.id(+)
   and c.id         = d.card_id(+)
   and a.id         = m.id(+)
   and a.sttl_day   = s.sttl_day
   and a.inst_id    = s.inst_id
/
