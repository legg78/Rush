create or replace force view ost_ui_institution_all_vw as
select a.id
     , a.seqnum
     , a.parent_id
     , a.network_id
     , a.inst_type
     , institution_number
     , get_text('OST_INSTITUTION', 'NAME', a.id, b.lang ) short_desc
     , get_text('OST_INSTITUTION', 'DESCRIPTION', a.id, b.lang ) full_desc
     , status
     , b.lang
  from ost_institution_vw a
     , com_language_vw b
/
