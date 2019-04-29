create or replace force view iss_linked_account_vw
as
select a.id
     , a.account_id
     , a.entity_type
     , a.object_id
     , a.split_hash
     , a.usage_order
     , a.is_pos_default
     , a.is_atm_default
     , a.is_atm_currency
     , a.is_pos_currency
     , a.account_seq_number
     , 1 as link_flag
     , null as procedure_name
     , 1 account_rownum
  from acc_account_object a
union all
select u.id
     , u.account_id
     , o.entity_type
     , o.object_id
     , o.split_hash
     , u.usage_order
     , u.is_pos_default
     , u.is_atm_default
     , u.is_atm_currency
     , u.is_pos_currency
     , null as account_seq_number
     , 0    as link_flag
     , o.procedure_name
     , row_number() over(partition by o.object_id, o.entity_type, o.split_hash, o.procedure_name order by o.eff_date desc, o.id desc) as account_rownum 
  from evt_event_object o
  join acc_unlink_account u on u.entity_type = o.entity_type and u.object_id = o.object_id  + 0 and u.split_hash = o.split_hash + 0
  left join acc_account_object ao on ao.object_id = o.object_id and ao.entity_type = o.entity_type and ao.account_id = u.account_id
  join evt_event e on e.id = o.event_id and e.event_type = 'EVNT0116'  -- delink account
 where o.entity_type    = 'ENTTCARD'
   and o.procedure_name in ( 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS'
                           , 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS'
                           , 'ITF_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS'
                           ) 
   and o.status         = 'EVST0001'
   and ao.id is null
/   
