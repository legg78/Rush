create or replace force view gui_ui_wizard_vw as
select n.id
     , n.seqnum
     , get_text (
           i_table_name    => 'gui_wizard'
         , i_column_name => 'name'
         , i_object_id   => n.id
         , i_lang        => l.lang
       ) name
     , l.lang
     , n.maker_privilege_id
     , n.checker_privilege_id
  from gui_wizard n
     , com_language_vw l
/
