create or replace force view acq_ui_reimb_channel_vw as
select a.id
     , a.channel_number
     , a.payment_mode
     , a.currency
     , a.inst_id
     , a.seqnum
     , get_text('acq_reimb_channel', 'name', a.id, b.lang) name
     , b.lang
  from acq_reimb_channel a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/
