create or replace force view hsm_ui_device_vw as
select 
    a.id    
    , a.is_enabled
    , a.comm_protocol
    , a.plugin
    , b.status_ok
    , b.status_conf_error
    , b.status_comm_error
    , b.status_unknown
    , b.max_connection
    , a.seqnum
    , a.manufacturer
    , a.serial_number
    , a.lmk_id
    , a.model_number
    , get_text (
        i_table_name    => 'hsm_device'
        , i_column_name => 'description'
        , i_object_id   => a.id
        , i_lang        => c.lang
    ) description
    , c.lang 
from 
    hsm_device a
    , ( select
            x.device_id
            , x.max_connection
            , x.status_ok
            , x.status_conf_error
            , x.status_comm_error
            , greatest( x.max_connection - x.status_ok - x.status_conf_error - x.status_comm_error, 0 ) status_unknown
        from (
            select
                t.id device_id
                , t.max_connection
                , count( decode(status, 'DCNSGOOD', 1) ) status_ok
                , count( decode(status, 'DCNSCFGE', 1) ) status_conf_error
                , count( decode(status, 'DCNSCOME', 1) ) status_comm_error
            from
                hsm_connection d
                , hsm_tcp_ip t
            where
                d.hsm_device_id(+) = t.id
            group by
                t.id
                , t.max_connection
        ) x
    ) b
    , com_language_vw c
where
    a.id = b.device_id(+)
/
