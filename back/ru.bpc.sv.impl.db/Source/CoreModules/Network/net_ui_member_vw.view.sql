create or replace force view net_ui_member_vw as
select
    n.id
    , n.seqnum
    , n.network_id
    , n.inst_id
    , s1.standard_id        online_standard_id
    , s2.standard_id        offline_standard_id
    , n.participant_type
    , n.status
    , n.inactive_till
    , n.scale_id
    , get_text (
        i_table_name    => 'net_member'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
    ) description
    , get_text (
        i_table_name => 'cmn_standard'
        , i_column_name => 'label'
        , i_object_id => s1.standard_id
        , i_lang => l.lang
    ) online_standard_name
    , get_text (
        i_table_name => 'cmn_standard'
        , i_column_name => 'label'
        , i_object_id => s2.standard_id
        , i_lang => l.lang
    ) as offline_standard_name
    , l.lang
from
    net_member n
    , com_language_vw l
    , cmn_standard_object s1
    , cmn_standard_object s2
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
    and n.id                = s1.object_id(+)
    and s1.entity_type(+)   = 'ENTTHOST'
    and s1.standard_type(+) = 'STDT0001'
    and n.id                = s2.object_id(+)
    and s2.entity_type(+)   = 'ENTTHOST'
    and s2.standard_type(+) = 'STDT0201'
/
