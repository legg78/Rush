create or replace force view acc_ui_selection_priority_vw as
select a.id
     , a.seqnum
     , a.inst_id
     , a.oper_type
     , a.account_type
     , a.account_status
     , a.party_type
     , a.priority
     , a.msg_type
     , a.mod_id
     , get_text('rul_mod', 'name', a.mod_id, l.lang) as mod_name
     , account_currency
     , l.lang
  from acc_selection_priority a
     , com_language_vw l
/
