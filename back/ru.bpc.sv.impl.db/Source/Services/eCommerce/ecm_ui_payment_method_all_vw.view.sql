create or replace force view ecm_ui_payment_method_all_vw as
select p.id purpose_id
     , get_text ('pmo_service'
               , 'label'
               , p.service_id
               , b.lang)
       || ' - '
       || get_text ('pmo_provider'
                  , 'label'
                  , p.provider_id
                  , b.lang)
        label
      , b.lang
from pmo_purpose p
   , pmo_provider_host h
   , com_language_vw b
where p.provider_id = h.provider_id
  and h.execution_type = 'POETECCM'
/
