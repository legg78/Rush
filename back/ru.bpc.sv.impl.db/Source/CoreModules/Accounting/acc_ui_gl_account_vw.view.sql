create or replace force view acc_ui_gl_account_vw as
select id
     , account_type
     , account_number
     , currency
     , inst_id
     , agent_id
     , status
     , contract_id
     , customer_id
     , entity_type
     , entity_id
     , split_hash
     , case when count(*) = count(balance) then sum(balance) else null end as balance
 from (
    select a.id
         , a.account_type
         , a.account_number
         , a.currency
         , a.inst_id
         , a.agent_id
         , a.status
         , a.contract_id
         , a.customer_id
         , a.entity_type
         , a.entity_id
         , a.split_hash
         , case
           when t.aval_impact = 0 then 0
           when a.currency = b.currency then t.aval_impact * b.balance
           else t.aval_impact * com_api_rate_pkg.convert_amount(b.balance, b.currency, a.currency, t.rate_type, a.inst_id, sysdate, 1, null)
           end balance
      from acc_gl_account_mvw a
         , acc_balance_vw b
         , acc_balance_type_vw t
     where a.id = b.account_id
       and a.account_type = t.account_type
       and a.inst_id = t.inst_id
       and b.balance_type = t.balance_type
       and (
            (
             entity_type = 'ENTTINST'
             and
             a.inst_id in (select inst_id from acm_cu_inst_vw)
            )
            or
            (
             entity_type = 'ENTTAGNT'
             and
             a.agent_id in (select agent_id from acm_cu_agent_vw)
            )
           ) 
      )a
 group by id
        , account_type
        , account_number
        , currency
        , inst_id
        , agent_id
        , status
        , contract_id
        , customer_id
        , entity_type
        , entity_id
        , split_hash
/    
