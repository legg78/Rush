create or replace force view fcl_ui_fee_vw as
select a.id
     , a.seqnum
     , a.fee_type
     , a.currency
     , a.fee_rate_calc
     , a.fee_base_calc
     , a.limit_id
     , a.cycle_id
     , a.inst_id
     , fcl_ui_fee_pkg.get_fee_desc(a.id) description
     , b.need_length_type
  from fcl_fee a
     , fcl_fee_type b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
   and a.fee_type = b.fee_type
/
