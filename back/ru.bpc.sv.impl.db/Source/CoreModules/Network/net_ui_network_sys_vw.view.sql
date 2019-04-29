create or replace force view net_ui_network_sys_vw as
select
    n.id
    , n.inst_id
    , get_text (
        i_table_name    => 'net_network'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'net_network'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) full_desc
    , l.lang
from
    net_network n
    , com_language_vw l
where n.inst_id in (select inst_id from acm_cu_inst_vw)
union all
select
    9999        id
    , 9999      inst_id
    , com_api_label_pkg.get_label_text('SYS_NET_NAME', b.lang) name
    , null description
    , b.lang
from 
    com_language_vw b
/

