create or replace package body cmn_ui_tcp_ip_pkg as
/********************************************************* 
 *  UI for tcp_ip <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 12.11.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: cmn_ui_tcp_ip_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure check_data(
    i_initiator             in com_api_type_pkg.t_dict_value
  , i_local_port            in com_api_type_pkg.t_name
  , i_remote_port           in com_api_type_pkg.t_name
  , i_remote_address        in com_api_type_pkg.t_name
  , i_id                    in com_api_type_pkg.t_short_id default null
    ) is
begin
    if i_local_port is not null then
        for r1 in (
            select
                a.id
              , a.initiator
            from
                cmn_tcp_ip_vw a
            where
                a.local_port = i_local_port
            and
                (a.id <> i_id or i_id is null))
        loop
            if r1.initiator = cmn_api_const_pkg.TCP_INITIATOR_HOST then
            --  1. local port with TCP HOST
                com_api_error_pkg.raise_error(
                    i_error      => 'TCPIP_LOCAL_PORT_ALREADY_USED'
                  , i_env_param1 => i_local_port
                  , i_env_param2 => r1.id
                );
            elsif r1.initiator = cmn_api_const_pkg.TCP_INITIATOR_REMOTE
                and i_initiator = cmn_api_const_pkg.TCP_INITIATOR_HOST then
            -- 2. local port with TCP REMOTE
                com_api_error_pkg.raise_error(
                    i_error      => 'TCPIP_LOCAL_PORT_ALREADY_USED'
                  , i_env_param1 => i_local_port
                  , i_env_param2 => r1.id
                );
            end if;
        end loop;
    end if;

    if i_initiator = cmn_api_const_pkg.TCP_INITIATOR_HOST and i_remote_address is null then
        -- 3. empty remote address
        com_api_error_pkg.raise_error(
            i_error => 'TCPIP_EMPTY_REMOTE_ADDRESS'
        );
    end if;

    if i_initiator = cmn_api_const_pkg.TCP_INITIATOR_REMOTE and i_local_port is null then
        -- 4. empty local port
        com_api_error_pkg.raise_error(
            i_error => 'TCPIP_EMPTY_LOCAL_PORT'
        );
    end if;


    if i_initiator = cmn_api_const_pkg.TCP_INITIATOR_REMOTE then
        if i_local_port is not null then
            for rec in (
                select
                    a.id
                  , a.initiator
                  , a.remote_address
                  , a.remote_port
                from
                    cmn_tcp_ip_vw a
                where
                    a.local_port = i_local_port
                and
                    a.initiator =  cmn_api_const_pkg.TCP_INITIATOR_REMOTE
                and
                    (a.id <> i_id or i_id is null))
            loop
                if nvl(rec.remote_address,'0.0.0.0') = nvl(i_remote_address, '0.0.0.0')
                    and ( nvl(rec.remote_port,'ANY') = 'ANY' or nvl(i_remote_port, 'ANY') = 'ANY')
                then
                -- 5.1
                    com_api_error_pkg.raise_error(
                        i_error      => 'TCPIP_CHECK_RANGE'
                      , i_env_param1 => rec.id
                    );
                elsif (nvl(rec.remote_address, '0.0.0.0') = '0.0.0.0' 
                          or nvl(i_remote_address, '0.0.0.0') = '0.0.0.0'
                      ) and (rec.remote_port is null and i_remote_port is null)
                then
                    -- 5.2
                    com_api_error_pkg.raise_error(
                        i_error      => 'TCPIP_CHECK_RANGE'
                      , i_env_param1 => rec.id
                    );
                elsif (nvl(rec.remote_address,'0.0.0.0') = '0.0.0.0' and nvl(rec.remote_port, 'ANY') = 'ANY')
                    or (nvl(i_remote_address,'0.0.0.0') = '0.0.0.0' and nvl(i_remote_port, 'ANY') = 'ANY')
                then
                    -- 5.3
                    com_api_error_pkg.raise_error(
                        i_error      => 'TCPIP_CHECK_RANGE'
                      , i_env_param1 => rec.id
                    );
                elsif rec.remote_address = i_remote_address and (rec.remote_port is null or i_remote_port is null)
                then
                    -- 5.4
                    com_api_error_pkg.raise_error(
                        i_error      => 'TCPIP_CHECK_RANGE'
                      , i_env_param1 => rec.id
                    );
                end if;
            end loop;
        end if;
    end if;

end check_data;

procedure add_tcp_ip (
    i_tcp_ip_id           in     com_api_type_pkg.t_short_id
  , i_remote_address      in     com_api_type_pkg.t_name
  , i_local_port          in     com_api_type_pkg.t_name
  , i_remote_port         in     com_api_type_pkg.t_name
  , i_initiator           in     com_api_type_pkg.t_dict_value
  , i_format              in     com_api_type_pkg.t_name
  , i_keep_alive          in     com_api_type_pkg.t_boolean
  , i_is_enabled          in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , i_monitor_connection  in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , i_multiple_connection in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , o_seqnum                 out com_api_type_pkg.t_seqnum
) is
begin
    check_data(
        i_initiator       => i_initiator
      , i_local_port      => i_local_port
      , i_remote_port     => i_remote_port
      , i_remote_address  => i_remote_address
    );
    
    select seqnum
      into o_seqnum
      from cmn_device
     where id = i_tcp_ip_id;

    insert into cmn_tcp_ip_vw (
        id
      , remote_address
      , local_port
      , remote_port
      , initiator
      , format
      , keep_alive
      , is_enabled
      , seqnum
      , monitor_connection
      , multiple_connection
    ) values (
        i_tcp_ip_id
      , i_remote_address
      , i_local_port
      , nvl(i_remote_port, 'ANY')
      , i_initiator
      , i_format
      , i_keep_alive
      , i_is_enabled
      , o_seqnum
      , i_monitor_connection
      , i_multiple_connection
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error       => 'DEVICE_ALREADY_REGISTERED'
          , i_env_param1  => i_remote_address
          , i_env_param2  => nvl(i_remote_port, 'ANY')
          , i_env_param3  => i_local_port
        );
end;

procedure modify_tcp_ip (
    i_tcp_ip_id           in out com_api_type_pkg.t_short_id
  , i_remote_address      in     com_api_type_pkg.t_name
  , i_local_port          in     com_api_type_pkg.t_name
  , i_remote_port         in     com_api_type_pkg.t_name
  , i_initiator           in     com_api_type_pkg.t_dict_value
  , i_format              in     com_api_type_pkg.t_name
  , i_keep_alive          in     com_api_type_pkg.t_boolean
  , i_monitor_connection  in     com_api_type_pkg.t_boolean
  , i_multiple_connection in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , io_seqnum             in out com_api_type_pkg.t_seqnum
) is
    l_param_tab                  com_api_type_pkg.t_param_tab;
begin

    for rec in (
        select
            a.*
        from
            cmn_ui_tcp_ip_vw a
        where
            a.id = i_tcp_ip_id)
    loop
        if rec.is_enabled = com_api_type_pkg.TRUE then

            com_api_error_pkg.raise_error (
                i_error       => 'CANNOT_MODIFY_ENABLED_CMN_TCP'
              , i_env_param1  => i_tcp_ip_id
            );

        end if;

        if rec.initiator      <> i_initiator or
           rec.remote_address <> i_remote_address or
           rec.local_port     <> i_local_port or
           rec.remote_port    <> i_remote_port
        then
            check_data(
                i_initiator       => i_initiator
              , i_local_port      => i_local_port
              , i_remote_port     => i_remote_port
              , i_remote_address  => i_remote_address
              , i_id              => i_tcp_ip_id
            );
        end if;

        --delete from cmn_device_connection_vw
        -- where device_id = i_tcp_ip_id;

        update cmn_tcp_ip_vw
           set remote_address      = i_remote_address
             , local_port          = i_local_port
             , remote_port         = i_remote_port
             , initiator           = i_initiator
             , format              = i_format
             , keep_alive          = i_keep_alive
             , monitor_connection  = i_monitor_connection
             , multiple_connection = i_multiple_connection
             , seqnum              = io_seqnum
         where id                  = i_tcp_ip_id;

         io_seqnum := io_seqnum + 1;

        update cmn_device
           set seqnum     = io_seqnum
         where id         = i_tcp_ip_id;

        for rec_terminal in (
            select t.id
                 , t.inst_id
                 , t.split_hash
              from cmn_tcp_ip i
                 , cmn_device d
                 , acq_terminal t
             where i.id          = i_tcp_ip_id
               and d.id          = i.id
               and t.is_template = com_api_type_pkg.FALSE
               and decode(t.terminal_type, 'TRMT0002', decode(t.status, 'TRMS0001', t.device_id)) = d.id
               -- If we used the package constants TERMINAL_TYPE_ATM and TERMINAL_STATUS_ACTIVE then we have got the full scan of the acq_terminal table.
               --and decode(t.terminal_type, acq_api_const_pkg.TERMINAL_TYPE_ATM, decode(t.status, acq_api_const_pkg.TERMINAL_STATUS_ACTIVE, t.device_id)) = d.id
        ) loop
            evt_api_event_pkg.register_event(
                i_event_type      => acq_api_const_pkg.EVENT_TERMINAL_ATTR_CHANGE
              , i_eff_date        => get_sysdate
              , i_entity_type     => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
              , i_object_id       => rec_terminal.id
              , i_inst_id         => rec_terminal.inst_id
              , i_split_hash      => rec_terminal.split_hash
              , i_param_tab       => l_param_tab
            );
        end loop;

    end loop;
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error       => 'DEVICE_ALREADY_REGISTERED'
          , i_env_param1  => i_remote_address
          , i_env_param2  => i_remote_port
          , i_env_param3  => i_local_port
        );
end;

procedure remove_tcp_ip (
    i_tcp_ip_id           in     com_api_type_pkg.t_short_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
) is
    l_is_enabled                 com_api_type_pkg.t_boolean;
begin
    select is_enabled
      into l_is_enabled
      from cmn_ui_tcp_ip_vw
     where id = i_tcp_ip_id;
            
    if l_is_enabled = com_api_const_pkg.TRUE then
        com_api_error_pkg.raise_error (
            i_error       => 'CANNOT_REMOVE_ENABLED_CMN_TCP'
          , i_env_param1  => i_tcp_ip_id
        );
    end if;

    --delete from cmn_device_connection_vw
    -- where device_id = i_tcp_ip_id;

    update cmn_tcp_ip_vw
       set seqnum = i_seqnum
     where id     = i_tcp_ip_id;
            
    delete from cmn_tcp_ip_vw
     where id = i_tcp_ip_id;
end;

end;
/
