create or replace force view com_ui_flexible_field_usage_vw as
select a.id
     , a.field_id
     , a.usage
     , b.lang
     , get_article_text(a.usage, b.lang) as usage_name 
     , get_article_desc(a.usage, b.lang) as usage_description
  from com_flexible_field_usage a
     , com_language_vw b
/
