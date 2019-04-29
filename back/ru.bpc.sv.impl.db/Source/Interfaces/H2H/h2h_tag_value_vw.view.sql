create or replace force view h2h_tag_value_vw as
select v.id
     , v.part_key
     , v.fin_id
     , v.tag_id
     , v.tag_value
  from h2h_tag_value v
