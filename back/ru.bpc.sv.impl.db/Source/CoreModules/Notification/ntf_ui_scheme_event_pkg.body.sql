CREATE OR REPLACE package body ntf_ui_scheme_event_pkg is

procedure add_scheme_event (
    o_id                       out  com_api_type_pkg.t_short_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_scheme_id             in      com_api_type_pkg.t_tiny_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_contact_type          in      com_api_type_pkg.t_dict_value
  , i_notif_id              in      com_api_type_pkg.t_tiny_id
  , i_channel_id            in      com_api_type_pkg.t_tiny_id
  , i_delivery_time         in      com_api_type_pkg.t_name
  , i_is_customizable       in      com_api_type_pkg.t_boolean
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_is_batch_send         in      com_api_type_pkg.t_boolean
  , i_scale_id              in      com_api_type_pkg.t_tiny_id
  , i_priority              in      com_api_type_pkg.t_tiny_id
) is
    l_cnt                           binary_integer;
    l_delivery_time                 com_api_type_pkg.t_name;
begin
    select count(1)
      into l_cnt
      from ntf_scheme_event
     where scheme_id    = i_scheme_id
       and event_type   = i_event_type
       and entity_type  = i_entity_type
       and contact_type = i_contact_type
       and notif_id     = i_notif_id
       and channel_id   = i_channel_id;

    trc_log_pkg.debug (
        i_text         => 'i_scheme_id [#1] i_event_type [#2] i_entity_type [#3] i_contact_type [#4] i_notif_id [#5] i_channel_id [#6]'
        , i_env_param1 => i_scheme_id
        , i_env_param2 => i_event_type
        , i_env_param3 => i_entity_type
        , i_env_param4 => i_contact_type
        , i_env_param5 => i_notif_id
        , i_env_param6 => i_channel_id
    );

    if l_cnt > 0 then
        raise dup_val_on_index;

    end if;

    o_id     := ntf_scheme_event_seq.nextval;
    o_seqnum := 1;
    
    l_delivery_time := lpad(substr(i_delivery_time, 1, instr(i_delivery_time, '-') - 1), 2, '0') || '-' ||
                       replace(lpad(substr(i_delivery_time, instr(i_delivery_time, '-') + 1), 2, '0'), '00', '24');

    insert into ntf_scheme_event_vw (
        id
        , seqnum
        , scheme_id
        , event_type
        , entity_type
        , contact_type
        , notif_id
        , channel_id
        , delivery_time
        , is_customizable
        , is_batch_send
        , scale_id
        , priority
        , status
    ) values (
        o_id
        , o_seqnum
        , i_scheme_id
        , i_event_type
        , i_entity_type
        , i_contact_type
        , i_notif_id
        , i_channel_id
        , l_delivery_time
        , i_is_customizable
        , i_is_batch_send
        , i_scale_id
        , i_priority
        , i_status
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error             => 'NOTIFICATION_SCHEME_EVENT_ALREADY_EXIST'
        );
end;

procedure modify_scheme_event (
    i_id                    in      com_api_type_pkg.t_short_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_scheme_id             in      com_api_type_pkg.t_tiny_id
  , i_notif_id              in      com_api_type_pkg.t_tiny_id
  , i_contact_type          in      com_api_type_pkg.t_dict_value
  , i_channel_id            in      com_api_type_pkg.t_tiny_id
  , i_delivery_time         in      com_api_type_pkg.t_name
  , i_is_customizable       in      com_api_type_pkg.t_boolean
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_is_batch_send         in      com_api_type_pkg.t_boolean
  , i_scale_id              in      com_api_type_pkg.t_tiny_id
  , i_priority              in      com_api_type_pkg.t_tiny_id
) is
    l_cnt                           binary_integer;
    l_delivery_time                 com_api_type_pkg.t_name;
begin
    select count(1)
      into l_cnt
      from ntf_scheme_event e1
         , ntf_scheme_event e2
     where e1.scheme_id    = i_scheme_id
       and e1.event_type   = e2.event_type
       and e1.entity_type  = e2.entity_type
       and e1.contact_type = i_contact_type
       and e1.notif_id     = i_notif_id
       and e1.channel_id   = i_channel_id
       and e2.id = i_id
       and e1.id <> e2.id;

    trc_log_pkg.debug (
        i_text         => 'i_scheme_id [#1] i_contact_type [#2] i_notif_id [#3] i_id [#4] i_channel_id[#5]'
        , i_env_param1 => i_scheme_id
        , i_env_param2 => i_contact_type
        , i_env_param3 => i_notif_id
        , i_env_param4 => i_id
        , i_env_param5 => i_channel_id
    );

    if l_cnt > 0 then
        raise dup_val_on_index;

    end if;

    l_delivery_time := lpad(substr(i_delivery_time, 1, instr(i_delivery_time, '-') - 1), 2, '0') || '-' ||
                       replace(lpad(substr(i_delivery_time, instr(i_delivery_time, '-') + 1), 2, '0'), '00', '24');

    update ntf_scheme_event_vw
       set seqnum          = io_seqnum
         , scheme_id       = i_scheme_id
         , notif_id        = i_notif_id
         , channel_id      = i_channel_id
         , delivery_time   = l_delivery_time
         , is_customizable = i_is_customizable
         , is_batch_send   = i_is_batch_send
         , scale_id        = i_scale_id
         , contact_type    = i_contact_type
         , priority        = i_priority
         , status          = i_status
     where id              = i_id;

    io_seqnum := io_seqnum + 1;
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error             => 'NOTIFICATION_SCHEME_EVENT_ALREADY_EXIST'
        );
end;

procedure remove_scheme_event (
    i_id                    in      com_api_type_pkg.t_short_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
  , i_scheme_id             in      com_api_type_pkg.t_tiny_id
) is
    l_check_cnt             com_api_type_pkg.t_count := 0;
begin
    select
        count(c.id)
    into
        l_check_cnt
    from
        ntf_custom_event c
    where
        (c.event_type, c.entity_type) in (
            select
                e.event_type
                , e.entity_type
            from
                ntf_scheme_event e
            where
                e.id = i_id
        );

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'NOTIFICATION_SCHEME_EVENT_ALREADY_USED'
        );
    end if;

    select count(1)
      into l_check_cnt
      from acm_role r
     where r.notif_scheme_id = i_scheme_id ;

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'NOTIFICATION_SCHEME_ALREADY_USED'
        );
    end if;

    update ntf_scheme_event_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete ntf_scheme_event_vw
     where id = i_id;
end;

end;
/


