create or replace force view fcl_ui_limit_vw as
select a.id
     , a.seqnum
     , a.limit_type
     , a.cycle_id
     , a.count_limit
     , a.sum_limit
     , a.currency
     , a.limit_base
     , a.limit_rate
     , nvl(b.posting_method, a.posting_method) as posting_method
     , a.inst_id
     , fcl_ui_limit_pkg.get_limit_desc(a.id) description
     , a.check_type
     , nvl(b.counter_algorithm, a.counter_algorithm) as counter_algorithm
     , a.count_max_bound
     , a.sum_max_bound
  from fcl_limit a
     , fcl_limit_type b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
   and a.is_custom = 0
   and a.limit_type = b.limit_type
/
