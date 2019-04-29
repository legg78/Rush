create or replace force view csm_ui_stop_list_vw
as
select sl.id
     , ci.id                           as card_instance_id
     , cn.card_number
     , c.card_mask
     , trunc(ci.expir_date, 'mm')      as card_expiration_date
     , e.event_type
     , sl.stop_list_type
     , sl.purge_date
     , sl.reason_code
     , com_api_dictionary_pkg.get_articles_list_desc(
           i_article_list     => sl.region_list
         , i_len_article_part => 1
         , i_text_in_begin    => 0
         , i_lang             => l.lang
       )                               as region_list
     , eo.status
     , eo.eff_date                     as event_date
     , com_api_dictionary_pkg.get_article_text(
           i_article => e.event_type
         , i_lang    => l.lang
       )                               as event_type_desc
     , com_api_dictionary_pkg.get_article_text(
           i_article => sl.stop_list_type
         , i_lang    => l.lang
       )                               as stop_list_type_desc
     , com_api_dictionary_pkg.get_article_text(
           i_article => sl.reason_code
         , i_lang    => l.lang
       )                               as reason_code_desc
     , com_api_dictionary_pkg.get_article_text(
           i_article => eo.status
         , i_lang    => l.lang
       )                               as status_desc
     , l.lang
     , sl.product
  from      evt_event_object    eo
  join      csm_stop_list       sl    on sl.id      = eo.id
  join      evt_event           e     on e.id       = eo.event_id
  join      iss_card_instance   ci    on ci.id      = eo.object_id
  join      iss_card            c     on c.id       = ci.card_id
  join      iss_card_number     cn    on cn.card_id = ci.card_id
 cross join com_language_vw     l
 where eo.entity_type = 'ENTTCINS'
/

