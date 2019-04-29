create or replace force view opr_ui_entity_oper_type_vw as
select 
    n.id
    , n.seqnum
    , n.inst_id
    , n.entity_type
    , n.oper_type
    , get_article_text(
          i_article     => n.oper_type
        , i_lang        => l.lang
      ) oper_type_name
    , n.invoke_method
    , n.reason_lov_id
    , n.object_type
    , n.wizard_id
    , n.entity_object_type
    , get_text(
          i_table_name  => 'opr_entity_oper_type'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , l.lang
from 
    opr_entity_oper_type n
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
