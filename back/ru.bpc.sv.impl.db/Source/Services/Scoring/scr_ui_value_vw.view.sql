create or replace force view scr_ui_value_vw
as
select a.id
     , a.seqnum
     , a.criteria_id
     , a.score
     , get_text(
           i_table_name  => 'SCR_VALUE'
         , i_column_name => 'NAME'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) value_name
     , b.lang
  from scr_value_vw a
     , com_language_vw b
/
