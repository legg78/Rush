create or replace force view prd_ui_customer_name_vw as
select
    lang.lang
  , n.id
  , n.seqnum
  , n.entity_type
  , n.object_id
  , n.customer_number
  , n.contract_id
  , n.inst_id
  , n.split_hash
  , case n.entity_type
    when 'ENTTCOMP' then get_text('COM_COMPANY','LABEL', object_id, lang.lang)
    when 'ENTTPERS' then com_ui_person_pkg.get_person_name(n.object_id, lang.lang)
    end customer_name
  , n.status
  , n.reg_date
from prd_customer n
   , com_language_vw lang
where n.inst_id in (select inst_id from acm_cu_inst_vw)
/    
    
