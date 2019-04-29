create or replace force view din_ui_addendum_value_vw
as
select v.id 
     , v.addendum_id
     , v.field_name
     , f.description as field_desc
     , v.field_value
     , l.lang
  from      din_addendum_value v
  join      din_message_field  f    on f.field_name = v.field_name
 cross join com_language_vw    l
/
