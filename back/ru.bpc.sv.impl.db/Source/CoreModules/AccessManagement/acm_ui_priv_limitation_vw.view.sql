create or replace force view acm_ui_priv_limitation_vw as
select p.id
     , p.seqnum
     , p.priv_id
     , get_text(
           i_table_name  => 'acm_priv_limitation'
         , i_column_name => 'label'
         , i_object_id   => p.id
         , i_lang        => b.lang
       ) as label
     , b.lang
     , p.limitation_type
     , (select get_text (
            i_table_name  => 'com_dictionary'
          , i_column_name => 'name'
          , i_object_id   => dict.id
          , i_lang        => b.lang)
          from com_dictionary dict
         where dict.dict || dict.code = p.limitation_type
       ) as limitation_type_desc
  from acm_priv_limitation p
     , com_language_vw     b
/
