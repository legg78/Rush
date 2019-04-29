create or replace package body net_ui_member_pkg is
/*********************************************************
 *  Interface for Network members and hosts  <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 01.06.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: net_ui_member_pkg  <br />
 *  @headcom
 **********************************************************/

procedure add (
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_network_id            in      com_api_type_pkg.t_tiny_id
)  is
    l_count                 com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_count 
      from net_member 
     where inst_id = i_inst_id
       and network_id = i_network_id;
 
    if l_count > 0 then      
        com_api_error_pkg.raise_error(
            i_error      => 'NET_MEMBER_ALREADY_EXISTS'
          , i_env_param1 => ost_ui_institution_pkg.get_inst_name(i_inst_id)
          , i_env_param2 => get_text ('net_network', 'name', i_network_id, get_user_lang)
        );
    end if;
    
    o_id := net_member_seq.nextval;
    o_seqnum := 1;

    insert into net_member_vw (
        id
      , seqnum
      , network_id
      , inst_id
      , participant_type
      , status
      , inactive_till
      , scale_id
    ) values (
        o_id
      , o_seqnum
      , i_network_id
      , i_inst_id
      , null
      , null
      , null
      , null
    );
end;

procedure remove (
    i_id          in      com_api_type_pkg.t_tiny_id
  , i_seqnum      in      com_api_type_pkg.t_seqnum
) is
    l_count               com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug (
        i_text        => 'net_ui_member_pkg.remove [#1] [#2]'
      , i_env_param1  => i_id
      , i_env_param2  => i_seqnum
    );

    select count(1)
      into l_count
      from net_member_vw n
      where ( exists (select 1
                       from cmn_standard_object_vw s
                      where s.object_id = n.id
                        and s.entity_type = net_api_const_pkg.entity_type_host
                        and s.standard_type in ( cmn_api_const_pkg.standart_type_netw_clearing,cmn_api_const_pkg.standart_type_netw_comm))
            or exists (select 1
                         from net_interface_vw i
                        where i.host_member_id = n.id)
            )
        and n.id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NET_MEMBER_REGISTRED_AS_HOST_CANNOT_DELETE'
        );
    end if;

    select count(1)
      into l_count
      from net_interface_vw
     where i_id in (consumer_member_id, msp_member_id);

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NET_MEMBER_ASSOCIATED_WITH_HOST_CANNOT_DELETE'
        );
    end if;

    update net_member_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete net_member_vw
     where id     = i_id;

    com_api_i18n_pkg.remove_text (
        i_table_name  => 'net_member'
      , i_object_id   => i_id
    );

    cmn_ui_standard_object_pkg.remove_standard_object (
        i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id     => i_id
    );
end;

procedure add_host(
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_network_id            in      com_api_type_pkg.t_tiny_id
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_online_standard_id    in      com_api_type_pkg.t_tiny_id
  , i_offline_standard_id   in      com_api_type_pkg.t_tiny_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_status                in      com_api_type_pkg.t_dict_value := 'HSST0001'
  , i_scale_id              in      com_api_type_pkg.t_tiny_id := null
) is
    l_count                 com_api_type_pkg.t_count := 0;
begin

    for rec in (
        select get_text(
                   i_table_name    => 'net_network'
                 , i_column_name   => 'name'
                 , i_object_id     => a.network_id
                 , i_lang          => get_user_lang
               ) as net_name
             , a.id
             , a.seqnum
          from net_member a
         where a.network_id       = i_network_id
           and a.inst_id          = i_inst_id
           and(a.participant_type = i_participant_type
               or a.participant_type is null
               or i_participant_type is null)
    ) loop        
        
        select count(1)
          into l_count
          from cmn_standard_object s
         where s.object_id = rec.id
           and s.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST;
    
        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'NET_MEMBER_ALREADY_EXISTS'
              , i_env_param1 => ost_ui_institution_pkg.get_inst_name(i_inst_id)
              , i_env_param2 => rec.net_name
              , i_env_param3 => i_participant_type
            );
        else
            o_id := rec.id;
            o_seqnum := rec.seqnum;
            
            modify_host (
                i_id                    => rec.id
              , io_seqnum               => o_seqnum
              , i_participant_type      => i_participant_type
              , i_online_standard_id    => i_online_standard_id
              , i_offline_standard_id   => i_offline_standard_id
              , i_lang                  => i_lang
              , i_description           => i_description
              , i_status                => i_status
              , i_scale_id              => i_scale_id
            );       
            
            return; 
        end if;
    end loop;

    o_id := net_member_seq.nextval;
    o_seqnum := 1;

    insert into net_member_vw (
        id
      , seqnum
      , network_id
      , inst_id
      , participant_type
      , status
      , inactive_till
      , scale_id
    ) values (
        o_id
      , o_seqnum
      , i_network_id
      , i_inst_id
      , i_participant_type
      , i_status
      , null
      , null
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'net_member'
      , i_column_name   => 'description'
      , i_object_id     => o_id
      , i_lang          => i_lang
      , i_text          => i_description
    );

    cmn_ui_standard_object_pkg.add_standard_object (
        i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id     => o_id
      , i_standard_id   => i_online_standard_id
    );
    
    cmn_ui_standard_object_pkg.add_standard_object (
        i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id     => o_id
      , i_standard_id   => i_offline_standard_id
    );
    
    cmn_ui_standard_object_pkg.add_standard_object (
        i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id     => o_id
      , i_standard_id   => net_api_standard_pkg.get_basic_standard
    );
end;

procedure modify_host (
    i_id                    in      com_api_type_pkg.t_tiny_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_participant_type      in      com_api_type_pkg.t_dict_value
  , i_online_standard_id    in      com_api_type_pkg.t_tiny_id
  , i_offline_standard_id   in      com_api_type_pkg.t_tiny_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_status                in      com_api_type_pkg.t_dict_value    := 'HSST0001'
  , i_scale_id              in      com_api_type_pkg.t_tiny_id
) is
    l_check_device                  com_api_type_pkg.t_short_id;
    l_check_standard                com_api_type_pkg.t_tiny_id;
begin
    -- check
    for rec in (
        select get_text(
                   i_table_name    => 'net_network'
                 , i_column_name   => 'name'
                 , i_object_id     => b.network_id
                 , i_lang          => get_user_lang
               ) as net_name
             , b.inst_id
          from net_member a
             , net_member b
         where a.network_id       = b.network_id
           and a.inst_id          = b.inst_id
           and b.id               = i_id
           and a.id              != i_id
           and(a.participant_type = i_participant_type
            or a.participant_type is null
            or i_participant_type is null)
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'NET_MEMBER_ALREADY_EXISTS'
          , i_env_param1 => ost_ui_institution_pkg.get_inst_name(rec.inst_id)
          , i_env_param2 => rec.net_name
          , i_env_param3 => i_participant_type
        );
    end loop;

    begin
        select n.device_id
             , s.standard_id
          into l_check_device
             , l_check_standard
          from net_device n
             , cmn_standard_object s
         where n.host_member_id = i_id
           and n.device_id      = s.object_id
           and s.entity_type    = cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
           and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_COMM
           and decode(i_online_standard_id, s.standard_id, 1, 0) = 0
           and rownum < 2;

        com_api_error_pkg.raise_error (
            i_error       => 'HOST_DEVICE_STANDARD_MISMATCH'
          , i_env_param1  => i_id
          , i_env_param2  => i_online_standard_id
          , i_env_param3  => l_check_device
          , i_env_param4  => l_check_standard
        );
    exception
        when no_data_found then null;
    end;

    update net_member_vw
       set seqnum           = io_seqnum
         , status           = i_status
         , scale_id         = i_scale_id
         , participant_type = i_participant_type
     where id       = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'net_member'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_description
    );

    if i_online_standard_id is not null then
        cmn_ui_standard_object_pkg.add_standard_object (
            i_entity_type    => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id      => i_id
          , i_standard_id    => i_online_standard_id
        );
    else
        cmn_ui_standard_object_pkg.remove_standard_object (
            i_entity_type    => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id      => i_id
          , i_standard_type  => cmn_api_const_pkg.STANDART_TYPE_NETW_COMM
        );
    end if;

    if i_offline_standard_id is not null then
        cmn_ui_standard_object_pkg.add_standard_object (
            i_entity_type    => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id      => i_id
          , i_standard_id    => i_offline_standard_id
        );
    else
        cmn_ui_standard_object_pkg.remove_standard_object (
            i_entity_type    => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id      => i_id
          , i_standard_type  => cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
        );
    end if;
end;

procedure remove_host (
    i_id       in      com_api_type_pkg.t_tiny_id
  , io_seqnum  in out  com_api_type_pkg.t_seqnum
) is
    l_count   com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_count
      from net_device_vw b
     where b.host_member_id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NET_HOST_ASSOCIATED_WITH_DEVICE_CANNOT_DELETE'
        );
    end if;
   
    update net_member_vw
       set seqnum  = io_seqnum
     where id      = i_id;

    io_seqnum := io_seqnum + 1;

    delete from net_interface_vw where host_member_id = i_id;

    cmn_ui_standard_object_pkg.remove_standard_object (
        i_entity_type     => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id       => i_id
    );

    --net_ui_device_pkg.remove_device(i_host_member_id => i_id);
end;

end;
/