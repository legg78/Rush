create or replace force view aap_ui_merchant_account_vw as
select m.lang
     , c.inst_id
     , m.id merchant_id
     , a.id account_id
     , a.account_number
     , m.merchant_number
     , m.merchant_name
     , c.contract_number
     , account_type||' '||currency||' '||account_number account_label
     , m.contract_id
     , (select count(id)
          from acc_account_object o
         where o.entity_type = 'ENTTMRCH'
           and o.object_id   = m.id
           and o.account_id  = a.id) is_linked
     , m.partner_id_code
     , m.mc_assigned_id
  from acc_account a
     , prd_contract c
     , acq_ui_merchant_vw m
 where c.id = a.contract_id
   and c.id = m.contract_id
/
