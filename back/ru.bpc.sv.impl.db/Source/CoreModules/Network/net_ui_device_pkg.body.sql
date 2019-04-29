create or replace package body net_ui_device_pkg is

procedure add (
    i_host_member_id    in      com_api_type_pkg.t_tiny_id
  , i_device_id         in      com_api_type_pkg.t_short_id
) is
    l_device_standard           com_api_type_pkg.t_tiny_id;
    l_host_standard             com_api_type_pkg.t_tiny_id;
begin
    begin
        select
            s1.standard_id
            , s2.standard_id
        into
            l_device_standard
            , l_host_standard
        from
            cmn_standard_object s1
            , cmn_standard_object s2
        where
            s1.object_id(+) = i_device_id
            and s1.entity_type(+) = cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
            and s1.standard_type(+) = cmn_api_const_pkg.STANDART_TYPE_NETW_COMM
            and s2.object_id(+) = i_host_member_id
            and s2.entity_type(+) = net_api_const_pkg.ENTITY_TYPE_HOST
            and s2.standard_type(+) = cmn_api_const_pkg.STANDART_TYPE_NETW_COMM;
            
        if l_device_standard = l_host_standard then
            null;
        else
            com_api_error_pkg.raise_error (
                i_error             => 'HOST_DEVICE_STANDARD_MISMATCH'
                , i_env_param1      => i_host_member_id
                , i_env_param2      => l_host_standard 
                , i_env_param3      => i_device_id
                , i_env_param4      => l_device_standard 
            );
        end if;
    exception
        when no_data_found then null;
    end;

    insert into net_device_vw (
        host_member_id
      , device_id  
    ) values (
        i_host_member_id 
      , i_device_id
    );
    
    insert into net_device_dynamic (
        device_id
        , is_signed_on
    ) values (
        i_device_id
        , com_api_type_pkg.FALSE
    );
end;

procedure remove (
    i_device_id         in      com_api_type_pkg.t_short_id
) is
begin
    delete from net_device_vw
     where device_id = i_device_id;
     
    delete from net_device_dynamic
     where device_id = i_device_id;
end;


procedure remove_device (
    i_host_member_id    in      com_api_type_pkg.t_tiny_id
) is
begin
    delete from net_device_dynamic
     where device_id in (
         select distinct device_id
           from net_device_vw
          where host_member_id = i_host_member_id
    );

    delete from net_device_vw
     where host_member_id = i_host_member_id;

end;

end; 
/
