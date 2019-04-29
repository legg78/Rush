create or replace force view scr_ui_grade_vw
as
select a.id
     , a.seqnum
     , a.evaluation_id
     , a.total_score
     , a.grade
     , get_text(
           i_table_name  => 'SCR_GRADE'
         , i_column_name => 'NAME'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) value_name
     , b.lang
  from scr_grade_vw a
     , com_language_vw b
/
