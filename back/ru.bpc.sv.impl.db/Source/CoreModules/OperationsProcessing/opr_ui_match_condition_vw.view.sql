create or replace force view opr_ui_match_condition_vw as
select
    c.id
    , c.inst_id
    , c.condition
    , c.seqnum
    , get_text (
      i_table_name    => 'opr_match_condition'
      , i_column_name => 'name'
      , i_object_id   => c.id
      , i_lang        => l.lang
    ) name
    , l.lang
from
    opr_match_condition c
    , com_language_vw l
where
    c.inst_id in (select inst_id from acm_cu_inst_vw)
/
