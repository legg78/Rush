create or replace force view scr_ui_evaluation_vw
as
select a.id
     , a.seqnum
     , inst_id
     , ost_ui_institution_pkg.get_inst_name(
           i_inst_id => inst_id
         , i_lang    => b.lang
       ) inst_name
     , get_text(
           i_table_name  => 'SCR_EVALUATION'
         , i_column_name => 'NAME'
         , i_object_id   => a.id
         , i_lang        => b.lang
       ) eval_name
     , b.lang
  from scr_evaluation_vw a
     , com_language_vw b
/
