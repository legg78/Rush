create or replace force view gui_ui_wizard_step_vw as
select 
    n.id
    , n.seqnum
    , n.wizard_id
    , n.step_order
    , n.step_source
    , get_text (
        i_table_name    => 'gui_wizard_step'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , l.lang
from 
    gui_wizard_step n
    , com_language_vw l
/
