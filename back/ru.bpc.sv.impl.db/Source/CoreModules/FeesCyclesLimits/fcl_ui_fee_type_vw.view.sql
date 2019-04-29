create or replace force view fcl_ui_fee_type_vw as
select a.id
     , a.seqnum
     , a.fee_type
     , a.entity_type
     , a.cycle_type
     , a.limit_type
     , a.need_length_type
  from fcl_fee_type a
/
