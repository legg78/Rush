create or replace force view app_ui_dependence_vw as
select a.id
    , (select min(s.appl_type) from app_structure s where s.id in (a.struct_id, a.depend_struct_id) and appl_type is not null) appl_type
    , (select e.name from app_element e, app_structure s where s.id = a.struct_id and e.id = s.element_id)
      ||' ('||(select e.name from app_element e, app_structure s where s.id = a.struct_id and e.id = s.parent_element_id )
      ||')'  element_name
    , (select e.name from app_element e, app_structure s where s.id = a.depend_struct_id and e.id = s.element_id)
      ||' ('||(select e.name from app_element e, app_structure s where s.id = a.depend_struct_id and e.id = s.parent_element_id )
      ||')'  depend_element_name
    , (select a.dependence||' '
            ||get_text (i_table_name    => 'com_dictionary',
                        i_column_name   => 'name',
                        i_object_id     => x.id,
                        i_lang          => b.lang)
              name
         from com_dictionary x where x.dict||x.code = a.dependence) description 
    , a.condition
    , a.struct_id
    , a.depend_struct_id
    , a.dependence
    , a.seqnum
    , b.lang
    , affected_zone
    , get_article_text(a.affected_zone, b.lang) affected_zone_name 
 from app_dependence a
    , com_language_vw b
/

