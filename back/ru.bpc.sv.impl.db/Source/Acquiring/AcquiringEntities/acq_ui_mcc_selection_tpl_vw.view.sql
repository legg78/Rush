create or replace force view acq_ui_mcc_selection_tpl_vw as
select
    a.id
    , a.seqnum
    , get_text (
        i_table_name    => 'acq_mcc_selection_tpl'
        , i_column_name => 'name'
        , i_object_id   => a.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'acq_mcc_selection_tpl'
        , i_column_name => 'description'
        , i_object_id   => a.id
        , i_lang        => l.lang
      ) description
    , l.lang
from
    acq_mcc_selection_tpl a
    , com_language_vw l
/
