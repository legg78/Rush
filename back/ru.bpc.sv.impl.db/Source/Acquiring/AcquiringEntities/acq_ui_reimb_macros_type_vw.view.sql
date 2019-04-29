create or replace force view acq_ui_reimb_macros_type_vw as
select a.id
     , a.macros_type_id
     , get_text('acc_macros_type', 'name', a.macros_type_id, b.lang) macros_type_name
     , a.amount_type
     , a.is_reversal
     , a.inst_id
     , a.seqnum
     , b.lang
  from acq_reimb_macros_type a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/
