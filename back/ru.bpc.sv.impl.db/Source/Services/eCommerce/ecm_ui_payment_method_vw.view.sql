create or replace force view ecm_ui_payment_method_vw as
select m.id merchant_id
     , p.id purpose_id
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
   , ecm_payment_method pm
   , ecm_merchant m
   , com_language_vw b
where pm.purpose_id = p.id
  and pm.merchant_id = m.id
/
