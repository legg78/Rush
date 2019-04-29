create or replace force view din_ui_addendum_vw
as
select a.id as addendum_id
     , a.fin_id
     , a.function_code
     , t.description as function_code_desc
     , t.message_category
     , get_article_text(
           i_article => t.message_category
         , i_lang    => l.lang
       ) as message_category_desc
     , a.file_id
     , a.record_number
     , l.lang
  from      din_addendum     a
  join      din_message_type t    on t.function_code = a.function_code
 cross join com_language_vw  l
/
