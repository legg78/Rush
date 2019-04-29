create or replace force view com_ui_company_info_vw as
select c.id
     , c.embossed_name
     , c.seqnum
     , c.incorp_form
     , l.lang
     , c.label
     , c.description
     , d.id doc_id
     , d.id_type
     , d.id_series
     , d.id_number
     , a.address_type
     , a.adr_id
     , a.country
     , a.region
     , a.city
     , a.street
     , a.house
     , a.apartment
     , a.postal_code
     , a.region_code
from com_ui_company_vw c, com_language_vw l
  , (select x.object_id, x.id, x.id_type, x.id_series, x.id_number
          , row_number() over(partition by object_id order by x.id desc) rn
     from com_id_object x 
     where x.entity_type = 'ENTTCOMP') d
  , (select x.object_id, x.address_id, row_number() over (partition by object_id order by x.id desc) rn, x.address_type
          , a.id adr_id, a.lang adr_lang, a.country, a.region, a.city, a.street, a.house
          , a.apartment, a.postal_code, a.region_code
     from com_address_object x
        , com_address a
     where x.entity_type = 'ENTTCOMP'
       and a.id          = x.address_id ) a  
where c.id    = d.object_id(+) and d.rn(+) = 1
  and c.id    = a.object_id(+) and a.rn(+) = 1
  and c.lang  = a.adr_lang(+)
  and c.lang  = l.lang  
/