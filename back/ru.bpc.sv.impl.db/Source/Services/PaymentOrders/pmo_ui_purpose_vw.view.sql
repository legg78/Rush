create or replace force view pmo_ui_purpose_vw as
select a.id
     , a.provider_id
     , a.service_id
     , a.host_algorithm
     , a.oper_type
     , terminal_id
     , mcc 
     , nvl(get_text('pmo_purpose', 'label', a.id, b.lang)
        ,  get_text('pmo_service', 'label', a.service_id, b.lang) 
           || ' - ' ||  
           get_text('pmo_provider', 'label', a.provider_id, b.lang)
       ) label  
     , a.purpose_number  
     , b.lang
     , a.mod_id
     , a.amount_algorithm
     , a.inst_id
  from pmo_purpose_vw a
     , com_language_vw b
 where a.inst_id in (select inst_id from acm_cu_inst_vw)
/
