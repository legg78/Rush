create or replace force view com_ui_translate_vw as
select a.table_name
     , a.column_name
     , a.object_id
     , a.src_lang
     , a.src_text
     , a.dst_lang
     , nvl(b.text, get_text(a.table_name, a.column_name, a.object_id, a.dst_lang)) dst_text
     , nvl2(b.id, 1, 0) translate_exists
  from (
        select a.table_name
             , a.column_name
             , a.object_id
             , a.lang src_lang
             , a.text src_text
             , c.lang dst_lang
          from com_language_vw c
             , com_i18n a
         where a.lang != c.lang
       ) a
     , com_i18n b
 where a.table_name = b.table_name(+) 
   and a.column_name = b.column_name(+) 
   and a.object_id = b.object_id(+)
   and a.dst_lang = b.lang(+)
/   