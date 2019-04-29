create or replace package body ntf_ui_custom_pkg is

procedure set_custom_event (
    io_id                   in out  com_api_type_pkg.t_medium_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_channel_id            in      com_api_type_pkg.t_tiny_id
  , i_delivery_address      in      com_api_type_pkg.t_full_desc
  , i_delivery_time         in      com_api_type_pkg.t_name
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_mod_id                in      com_api_type_pkg.t_tiny_id
  , i_start_date            in      date
  , i_end_date              in      date
  , i_customer_id           in      com_api_type_pkg.t_long_id
  , i_contact_type          in      com_api_type_pkg.t_dict_value
) is
    l_delivery_time                 com_api_type_pkg.t_name;
begin
    l_delivery_time := lpad(substr(i_delivery_time, 1, instr(i_delivery_time, '-') - 1), 2, '0') || '-' ||
                       replace(lpad(substr(i_delivery_time, instr(i_delivery_time, '-') + 1), 2, '0'), '00', '24');

    if io_id is null then
        io_id := ntf_custom_event_seq.nextval;

        insert into ntf_custom_event_vw (
            id
          , event_type
          , entity_type
          , object_id
          , channel_id
          , delivery_address
          , delivery_time
          , mod_id
          , start_date
          , end_date
          , status
          , customer_id
          , contact_type
        ) values (
            io_id
          , i_event_type
          , i_entity_type
          , i_object_id
          , i_channel_id
          , i_delivery_address
          , l_delivery_time
          , i_mod_id
          , i_start_date
          , i_end_date
          , i_status
          , i_customer_id
          , i_contact_type
        );
    else
        update ntf_custom_event_vw
           set channel_id       = i_channel_id
             , delivery_address = i_delivery_address
             , delivery_time    = l_delivery_time
             , mod_id           = i_mod_id
             , start_date       = i_start_date
             , end_date         = i_end_date
             , event_type       = i_event_type
             , status           = i_status
             , customer_id      = i_customer_id
             , contact_type     = i_contact_type
         where id               = io_id;
    end if;
end;

procedure remove_custom_event (
    i_id                    in      com_api_type_pkg.t_medium_id
) is
begin
    delete from ntf_custom_object_vw
     where custom_event_id = i_id;
        
    delete from ntf_custom_event_vw
     where id = i_id;
end;

procedure set_custom_object (
    io_id                   in out  com_api_type_pkg.t_long_id
  , i_custom_event_id       in      com_api_type_pkg.t_medium_id
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_is_active             in      com_api_type_pkg.t_boolean
  , i_entity_type           in      com_api_type_pkg.t_dict_value    default null
) is
begin
    if io_id is null then
        io_id := ntf_custom_object_seq.nextval;

        insert into ntf_custom_object_vw (
            id
            , custom_event_id
            , object_id
            , entity_type
            , is_active
        ) values (
            io_id
            , i_custom_event_id
            , i_object_id
            , i_entity_type
            , i_is_active
        );
    else
        update ntf_custom_object_vw
           set is_active = i_is_active
         where id = io_id;
    end if;
end;

procedure remove_custom_object (
    i_id                    in      com_api_type_pkg.t_long_id
) is
begin
    delete from ntf_custom_object_vw
     where id = i_id;
end;

end; 
/
