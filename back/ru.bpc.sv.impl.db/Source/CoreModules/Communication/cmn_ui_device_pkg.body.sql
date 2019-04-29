create or replace package body cmn_ui_device_pkg as

procedure check_text(
    i_object_id             in com_api_type_pkg.t_inst_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_text                in com_api_type_pkg.t_name
)is
l_count                 com_api_type_pkg.t_tiny_id;
    
begin       
    if i_object_id is null then
        select count(1)    
          into l_count
          from com_i18n_vw i 
             , cmn_device_vw c  
         where i.table_name = 'CMN_DEVICE'
           and i.column_name = 'CAPTION'  
           and i.text = i_text
           and c.id = i.object_id
           and c.inst_id = i_inst_id;
    else
        select count(1)
          into l_count
          from com_i18n_vw i
             , cmn_device_vw c  
         where i.table_name = 'CMN_DEVICE'
           and i.column_name = 'CAPTION'  
           and i.text        = i_text
           and c.id = i.object_id
           and i.object_id   != i_object_id
           and c.inst_id = i_inst_id;      
    end if;
        
    trc_log_pkg.debug (
        i_text          => 'l_count ' || l_count
    );
        
    if l_count > 0 then
        com_api_error_pkg.raise_error(
              i_error           => 'DEVICE_NAME_ALREADY_EXISTS'
            , i_env_param1      => i_text 
            , i_env_param2      => i_inst_id 
        );            
    end if;         
end;

procedure add_device (
    o_device_id       out com_api_type_pkg.t_short_id
  , i_comm_plugin  in     com_api_type_pkg.t_dict_value
  , i_standard_id  in     com_api_type_pkg.t_tiny_id
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_caption      in     com_api_type_pkg.t_short_desc
  , i_description  in     com_api_type_pkg.t_full_desc default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
) is
begin
    
    check_text(
        i_object_id             => o_device_id
        , i_inst_id             => i_inst_id
        , i_text                => i_caption
    );
    
    o_device_id := cmn_device_seq.nextval;

    insert into cmn_device_vw (
        id
      , communication_plugin
      , seqnum
      , inst_id
    ) values (
        o_device_id
      , i_comm_plugin
      , 1
      , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
    );
        
    cmn_ui_standard_object_pkg.add_standard_object (
        i_entity_type     => cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
      , i_object_id       => o_device_id
      , i_standard_id     => i_standard_id
    );

    if i_caption is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'CMN_DEVICE'
          , i_column_name  => 'CAPTION'
          , i_object_id    => o_device_id
          , i_lang         => i_lang
          , i_text         => i_caption
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'CMN_DEVICE'
          , i_column_name  => 'DESCRIPTION'
          , i_object_id    => o_device_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;

end;

procedure modify_device (
    i_device_id     in      com_api_type_pkg.t_short_id
  , i_comm_plugin   in      com_api_type_pkg.t_dict_value
  , i_standard_id   in      com_api_type_pkg.t_tiny_id
  , io_seqnum       in out  com_api_type_pkg.t_seqnum
  , i_caption       in      com_api_type_pkg.t_short_desc
  , i_description   in      com_api_type_pkg.t_full_desc default null
  , i_lang          in      com_api_type_pkg.t_dict_value default null
) is
    l_host_member_id        com_api_type_pkg.t_short_id;
    l_host_standard_id      com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_inst_id;    
begin
    trc_log_pkg.debug (
        i_text        => 'modify device io_seqnum[#1]'
      , i_env_param1  => io_seqnum
    );
    
    select inst_id
      into l_inst_id 
      from cmn_device_vw 
     where id = i_device_id;  
        
    check_text(
        i_object_id             => i_device_id
        , i_inst_id             => l_inst_id
        , i_text                => i_caption
    );
    
    begin
        select d.host_member_id
             , s1.standard_id
          into l_host_member_id
             , l_host_standard_id
          from net_device d
             , cmn_standard_object s1
         where d.device_id         = i_device_id
           and d.host_member_id    = s1.object_id(+)
           and s1.entity_type(+)   = net_api_const_pkg.ENTITY_TYPE_HOST
           and s1.standard_type(+) = cmn_api_const_pkg.STANDART_TYPE_NETW_COMM;
                
        if l_host_standard_id = i_standard_id then 
            null;
        else
            com_api_error_pkg.raise_error (
                i_error       => 'HOST_DEVICE_STANDARD_MISMATCH'
              , i_env_param1  => l_host_member_id
              , i_env_param2  => l_host_standard_id
              , i_env_param3  => i_device_id
              , i_env_param4  => i_standard_id 
            );
        end if;
    exception
        when no_data_found then null;
    end;

    if i_caption is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'CMN_DEVICE'
          , i_column_name  => 'CAPTION'
          , i_object_id    => i_device_id
          , i_lang         => i_lang
          , i_text         => i_caption
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text (
            i_table_name   => 'CMN_DEVICE'
          , i_column_name  => 'DESCRIPTION'
          , i_object_id    => i_device_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;

    update cmn_device_vw
       set communication_plugin = i_comm_plugin
         , seqnum               = io_seqnum
     where id                   = i_device_id;
            
    cmn_ui_standard_object_pkg.add_standard_object (
        i_entity_type   => cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
      , i_object_id     => i_device_id
      , i_standard_id   => i_standard_id
    );
        
    io_seqnum := io_seqnum + 1;
        
    update cmn_tcp_ip
       set seqnum  = io_seqnum
     where id      = i_device_id;

    trc_log_pkg.debug (
        i_text          => 'modify device ok'
      , i_env_param1    => io_seqnum
    );
end;

procedure remove_device (
    i_device_id   in     com_api_type_pkg.t_short_id
  , i_seqnum      in     com_api_type_pkg.t_seqnum
) is
    l_count       pls_integer;
begin
    select count(1)
      into l_count
      from net_device_vw
     where device_id = i_device_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error  => 'COMMUNICATION_DEVICE_NETWORK_FOUND'
        );
    end if;

    select count(1)
      into l_count
      from acq_terminal_vw
     where device_id = i_device_id
       and status    = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error  => 'COMMUNICATION_DEVICE_TERMINAL_FOUND'
        );
    end if;

    cmn_ui_standard_object_pkg.remove_standard_object (
        i_entity_type  => cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
      , i_object_id    => i_device_id
    );

    update cmn_device_vw
       set seqnum = i_seqnum
     where id     = i_device_id;

    delete from cmn_device_vw
     where id = i_device_id;


    com_api_i18n_pkg.remove_text (
        i_table_name   => 'CMN_DEVICE'
      , i_object_id    => i_device_id
    );
end;

procedure set_is_enabled (
    i_device_id           in     com_api_type_pkg.t_short_id
  , i_is_enabled          in     com_api_type_pkg.t_boolean
  , io_seqnum             in out com_api_type_pkg.t_seqnum
) is
begin
    update cmn_device_vw
       set is_enabled = i_is_enabled
         , seqnum     = io_seqnum
     where id         = i_device_id;
     
    io_seqnum := io_seqnum + 1;

    update cmn_tcp_ip
       set seqnum     = io_seqnum
     where id         = i_device_id;

end;

end;
/