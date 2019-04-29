create or replace force view adt_ui_trail_vw as
select id
     , entity_type
     , object_id
     , case entity_type
       when 'ENTTCUST' then
           (select max(c.customer_number)
              from prd_customer c
             where c.id = t.object_id)
       when 'ENTTCNTR' then
           (select max(c.contract_number)
              from prd_contract c
             where c.id = t.object_id)
       when 'ENTTACCT' then
           (select max(a.account_number)
              from acc_account a
             where a.id = t.object_id)
       when 'ENTTCARD' then
           (select max(iss_api_card_pkg.get_card_mask(i_card_number => c.card_number))
              from iss_card_number c
             where c.card_id = t.object_id)
       when 'ENTTMRCH' then
           (select max(m.merchant_number)
              from acq_merchant m
             where m.id = t.object_id)
       when 'ENTTTRMN' then
           (select max(tm.terminal_number)
              from acq_terminal tm
             where tm.id = t.object_id)
       when 'ENTTAPPL' then
           (select max(a.appl_number)
              from app_application a
             where a.id = t.object_id)
       end as object_number
     , action_type
     , action_time
     , user_id
     , priv_id
     , session_id
     , status
  from adt_trail t
/
