create or replace force view acm_ui_filter_vw as
select a.id
    , a.seqnum
    , get_text(
        i_table_name  => 'acm_filter'
      , i_column_name => 'name'
      , i_object_id   => a.id
      , i_lang        => b.lang
      ) as name
    , a.section_id
    , a.inst_id
    , a.user_id
    , a.display_order
    , b.lang
from acm_filter_vw a
   , com_language_vw b
where a.inst_id in (select inst_id from acm_cu_inst_vw)
/

