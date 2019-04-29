create or replace package body net_api_device_pkg is

    procedure set_signed_on (
        i_device_id             in com_api_type_pkg.t_short_id
        , i_is_signed_on        in com_api_type_pkg.t_boolean
    ) is
        l_inst_id               com_api_type_pkg.t_inst_id;
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_prev_status           com_api_type_pkg.t_boolean;
    begin
        begin
            select inst_id
              into l_inst_id
              from cmn_device
             where id = i_device_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'CMN_DEVICE_NOT_FOUND'
                  , i_env_param1  => i_device_id
                );
        end;

        begin
            select is_signed_on
              into l_prev_status
              from net_device_dynamic
             where device_id = i_device_id;
            update net_device_dynamic
               set is_signed_on = i_is_signed_on
             where device_id = i_device_id;
        exception
            when no_data_found then
                insert into net_device_dynamic (device_id, is_signed_on)
                values (i_device_id, i_is_signed_on);
        end;

        if l_prev_status is null or l_prev_status <> i_is_signed_on then
            evt_api_event_pkg.register_event (
                i_event_type     => case when i_is_signed_on = com_api_type_pkg.FALSE then cmn_api_const_pkg.EVENT_CONNECTION_SIGNED_OFF else cmn_api_const_pkg.EVENT_CONNECTION_SIGNED_ON end
                , i_eff_date     => get_sysdate
                , i_entity_type  => cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
                , i_object_id    => i_device_id
                , i_inst_id      => l_inst_id
                , i_split_hash   => com_api_const_pkg.DEFAULT_SPLIT_HASH
                , i_param_tab    => l_param_tab
            );
        end if;
    end;

    procedure set_connected_on (
        i_device_id             in com_api_type_pkg.t_short_id
        , i_is_connected        in com_api_type_pkg.t_boolean
    ) is
        l_inst_id               com_api_type_pkg.t_inst_id;
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_prev_status           com_api_type_pkg.t_boolean;
    begin
        begin
            select inst_id
              into l_inst_id
              from cmn_device
             where id = i_device_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'CMN_DEVICE_NOT_FOUND'
                  , i_env_param1  => i_device_id
                );
        end;

        begin
            select is_connected
              into l_prev_status
              from net_device_dynamic
             where device_id = i_device_id;
            update net_device_dynamic
               set is_connected = i_is_connected
             where device_id = i_device_id;
        exception
            when no_data_found then
                insert into net_device_dynamic (device_id, is_connected)
                values (i_device_id, i_is_connected);
        end;

        if l_prev_status is null or l_prev_status <> i_is_connected then
            evt_api_event_pkg.register_event (
                i_event_type     => case when i_is_connected = com_api_type_pkg.FALSE then cmn_api_const_pkg.EVENT_CONNECTION_LOST else cmn_api_const_pkg.EVENT_CONNECTION_ESTABL end
                , i_eff_date     => get_sysdate
                , i_entity_type  => cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
                , i_object_id    => i_device_id
                , i_inst_id      => l_inst_id
                , i_split_hash   => com_api_const_pkg.DEFAULT_SPLIT_HASH
                , i_param_tab    => l_param_tab
            );
        end if;
    end;

    procedure set_stand_in (
        i_device_id             in com_api_type_pkg.t_short_id
        , i_is_stand_in         in com_api_type_pkg.t_boolean
    ) is
        l_inst_id               com_api_type_pkg.t_inst_id;
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_prev_status           com_api_type_pkg.t_boolean;
    begin
        begin
            select inst_id
              into l_inst_id
              from cmn_device
             where id = i_device_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'CMN_DEVICE_NOT_FOUND'
                  , i_env_param1  => i_device_id
                );
        end;

        begin
            select is_in_stand_in
              into l_prev_status
              from net_device_dynamic
             where device_id = i_device_id;
            update net_device_dynamic
               set is_in_stand_in = i_is_stand_in
             where device_id = i_device_id;
        exception
            when no_data_found then
                insert into net_device_dynamic (device_id, is_in_stand_in)
                values (i_device_id, i_is_stand_in);
        end;

        if l_prev_status is null or l_prev_status <> i_is_stand_in then
            evt_api_event_pkg.register_event (
                i_event_type     => (case when i_is_stand_in = com_api_type_pkg.FALSE then
                                               cmn_api_const_pkg.EVENT_CONNECTION_STAND_IN_OFF
                                          else cmn_api_const_pkg.EVENT_CONNECTION_STAND_IN_ON
                                     end)
                , i_eff_date     => get_sysdate
                , i_entity_type  => cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
                , i_object_id    => i_device_id
                , i_inst_id      => l_inst_id
                , i_split_hash   => com_api_const_pkg.DEFAULT_SPLIT_HASH
                , i_param_tab    => l_param_tab
            );
        end if;
    end set_stand_in;

end;
/
