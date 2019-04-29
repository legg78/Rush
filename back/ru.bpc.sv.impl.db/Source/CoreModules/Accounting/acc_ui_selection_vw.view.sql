create or replace force view acc_ui_selection_vw as
select
    c.id
    , c.seqnum
    , get_text (
        i_table_name    => 'acc_selection'
        , i_column_name => 'description'
        , i_object_id   => c.id
        , i_lang        => l.lang
      ) description
    , check_aval_balance
    , l.lang
from
    acc_selection c
    , com_language_vw l
/
