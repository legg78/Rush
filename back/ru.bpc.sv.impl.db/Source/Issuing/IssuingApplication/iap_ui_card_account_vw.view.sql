create or replace force view iap_ui_card_account_vw as
select c.id    as card_id
     , a.id    as account_id
     , a.account_number
     , cn.contract_number
     , c.card_number
     , c.card_mask
     , t.name ||' '|| c.card_number                     as card_label
     , account_type||' '||currency||' '||account_number as account_label
     , c.contract_id
     , (select count(o.id)
          from acc_account_object o
         where o.entity_type = 'ENTTCARD'
           and o.object_id   = c.id
           and o.account_id  = a.id
       ) as is_linked
  from iss_ui_card_vw c
     , net_ui_card_type_vw t
     , acc_account a
     , prd_contract cn
 where c.card_type_id = t.id
   and cn.id          = a.contract_id
   and c.contract_id  = cn.id
   and t.lang         = com_ui_user_env_pkg.get_user_lang
   and c.inst_id      = a.inst_id
/
