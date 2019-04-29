create or replace force view rpt_ui_tag_vw as
select
    a.id
  , a.seqnum
  , a.inst_id
  , get_text(
      i_table_name  => 'rpt_tag'
    , i_column_name => 'label'
    , i_object_id   => a.id
    , i_lang        => b.lang
    ) label
  , get_text(
      i_table_name  => 'rpt_tag'
    , i_column_name => 'description'
    , i_object_id   => a.id
    , i_lang        => b.lang
    ) description
  , b.lang
from
    rpt_tag_vw a
  , com_language_vw b
where a.inst_id in (select inst_id from acm_cu_inst_vw)
/

