create or replace force view hsm_api_auth_device_tcp_vw as
select
    d.id
    , t.address
    , t.port
    , d.comm_protocol
    , d.plugin
    , d.manufacturer
    , d.serial_number
    , d.lmk_id
    , l.check_value
    , s.action
    , s.max_connection
    , d.model_number
    , s.firmware
from
    hsm_device d
    , hsm_tcp_ip t
    , hsm_lmk l
    , ( select
            hsm_device_id, action, firmware, sum(max_connection) max_connection
        from
            hsm_selection ss
        where
            action = 'HSMAAURZ'
        group by
            hsm_device_id
            , action
            , firmware
    ) s
where
    d.id = t.id
    and l.id = d.lmk_id
    and d.comm_protocol = 'HSMCTCPC'
    and d.is_enabled = 1
    and s.hsm_device_id = d.id
/
