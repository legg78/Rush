create or replace force view acm_ui_favorite_page_vw as
select
    p.user_id
  , p.section_id
  from
    acm_favorite_page p
/

