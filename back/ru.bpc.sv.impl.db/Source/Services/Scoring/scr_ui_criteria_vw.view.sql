create or replace force view scr_ui_criteria_vw
as
select a.id
     , a.seqnum
     , a.evaluation_id
     , a.order_num
     , get_text(
           i_table_name  => 'SCR_CRITERIA'
         , i_column_name => 'NAME'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) criteria_name
     , b.lang
  from scr_criteria_vw a
     , com_language_vw b
/
