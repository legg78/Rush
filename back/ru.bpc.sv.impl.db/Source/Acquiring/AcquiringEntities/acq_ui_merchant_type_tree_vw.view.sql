create or replace force view acq_ui_merchant_type_tree_vw as
select id
     , seqnum
     , merchant_type
     , parent_merchant_type
     , inst_id
  from acq_merchant_type_tree
 where inst_id in (select inst_id from acm_cu_inst_vw)
/
