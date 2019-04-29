CREATE OR REPLACE package body net_api_network_pkg as
/**********************************************************
*  API for networks <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 14.10.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: NET_API_NETWORK_PKG <br />
*  @headcom
***********************************************************/
function get_offline_standard(
    i_host_id               in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id is

    l_result            com_api_type_pkg.t_tiny_id;

begin
    select
        standard_id
    into
        l_result
    from
        cmn_standard_object s
    where
        s.object_id = i_host_id
        and s.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
        and s.standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING;

    if l_result is null then
        raise no_data_found;
    end if;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error             => 'NO_OFFLINE_STANDARD_FOR_HOST'
            , i_env_param1      => i_host_id
        );
end;

function get_offline_standard(
    i_network_id                in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id is
begin
    return get_offline_standard (
        i_host_id           => get_default_host(i_network_id)
    );
end;

function get_inst_id(
    i_network_id in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id is
    l_result com_api_type_pkg.t_tiny_id;
begin
    select min(inst_id)
      into l_result
      from net_network n
     where n.id = i_network_id;

    return l_result;
end;

function get_default_host (
    i_network_id                in com_api_type_pkg.t_tiny_id
    , i_host_inst_id            in com_api_type_pkg.t_inst_id  default null
) return com_api_type_pkg.t_tiny_id is

    l_result                    com_api_type_pkg.t_tiny_id;

begin
    select
        m.id
    into
        l_result
    from
        net_network n
        , net_member m
    where
        n.id = i_network_id
        and n.id = m.network_id
        and (
                (n.inst_id = m.inst_id and i_host_inst_id is null)
                or 
                (m.inst_id = i_host_inst_id)
            )
        ;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error             => 'NO_NETWORK_DEFAULT_HOST'
            , i_env_param1      => i_network_id
        );
end;

function get_member_id(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_participant_type    in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_tiny_id is
    l_result                    com_api_type_pkg.t_tiny_id;
begin
    select
        m.id
    into
        l_result
    from
        net_member m
    where
        m.network_id = i_network_id
    and
        (m.participant_type is null or m.participant_type = i_participant_type or i_participant_type is null )
    and
        m.inst_id    = i_inst_id;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error             => 'INSTITUTION_NOT_REGISTRED_IN_NETWORK'
          , i_env_param1        => i_inst_id
          , i_env_param2        => i_network_id
        );
    when too_many_rows then
        com_api_error_pkg.raise_error (
            i_error             => 'INSTITUTE_IS_CONNECTED_TO_NETWORK_FOR_SEVERAL_TIMES'
          , i_env_param1        => i_inst_id
          , i_env_param2        => i_network_id
        );
end;

function get_host_id(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_participant_type    in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_tiny_id is
    l_consumer_member_id        com_api_type_pkg.t_tiny_id;
    l_result                    com_api_type_pkg.t_tiny_id;
begin
    -- return host_id by institute and network from opr_participant 
    l_consumer_member_id :=
        get_member_id(
            i_inst_id             => i_inst_id
            , i_network_id        => i_network_id
            , i_participant_type  => i_participant_type
        );
   --
   select i.host_member_id
     into l_result
     from net_interface i
    where i.consumer_member_id = l_consumer_member_id;
    --
    return l_result;
    --
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error             => 'NET_MEMBER_NOT_REGISTRED_AS_HOST'
          , i_env_param1        => to_char(l_consumer_member_id)
          , i_env_param2        => to_char(i_inst_id)
          , i_env_param3        => to_char(i_network_id)
        );
end;

procedure get_host_info(
    i_member_id           in     com_api_type_pkg.t_tiny_id
  , i_participant_type    in     com_api_type_pkg.t_dict_value
  , o_inst_id                out com_api_type_pkg.t_inst_id
  , o_network_id             out com_api_type_pkg.t_tiny_id
) is
begin
    select
        a.inst_id
      , a.network_id
    into
        o_inst_id
      , o_network_id
    from
        net_member a
    where
        a.id = i_member_id
    and
        (a.participant_type is null or a.participant_type = i_participant_type or i_participant_type is null );
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error             => 'INSTITUTION_NOT_REGISTRED_IN_NETWORK'
          , i_env_param3        => i_member_id
          , i_env_param4        => i_participant_type
        );
end;

function get_member_interchange (
    i_mod_id                    in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_byte_char is
    l_result                    com_api_type_pkg.t_byte_char;
begin
    select
        i.value
    into
        l_result
    from
        net_member_interchange_vw i
    where
        i.mod_id = i_mod_id;

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error         => 'NO_IRD_FOR_MODIFIER'
            , i_env_param1  => i_mod_id
        );
end;

end;
/