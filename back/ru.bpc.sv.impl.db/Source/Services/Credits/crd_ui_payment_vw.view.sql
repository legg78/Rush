create or replace force view crd_ui_payment_vw as
select a.id
     , a.oper_id
     , a.is_reversal
     , a.original_oper_id
     , a.account_id
     , a.card_id
     , a.product_id
     , a.posting_date
     , a.sttl_day
     , a.currency 
     , a.amount
     , a.pay_amount
     , a.is_new
     , a.status
     , a.inst_id
     , a.agent_id
     , a.split_hash
     , b.account_number
     , b.inst_id as account_inst_id
     , c.card_mask
     , iss_api_token_pkg.decode_card_number(i_card_number => d.card_number) as card_number
     , o.oper_date
     , (select nvl(sum(cd.amount), 0) 
          from crd_debt cd
         where cd.original_id = a.oper_id
           and cd.is_reversal = 1
       ) as reverted_amount
  from crd_payment a
     , acc_account b
     , iss_card c
     , iss_card_number d
     , opr_operation o
 where a.account_id = b.id
   and a.card_id    = c.id(+)
   and c.id         = d.card_id(+)
   and o.id         = a.oper_id 
/
