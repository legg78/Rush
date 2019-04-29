create or replace package body net_api_map_pkg as

g_net_card_type_map com_api_type_pkg.t_param_tab;

function get_oper_type(
    i_network_oper_type in      com_api_type_pkg.t_dict_value
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_dict_value is
    l_result            com_api_type_pkg.t_dict_value;
begin
    select oper_type
    into l_result
    from (
        select oper_type
          from net_oper_type_map
         where i_network_oper_type like network_oper_type 
           and standard_id = i_standard_id
      order by priority
    )
    where rownum = 1;

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text          => 'Operation type except [#1][#2]'
              , i_env_param1    => i_network_oper_type
              , i_env_param2    => i_standard_id
            );

            return l_result;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'OPERATION_TYPE_EXCEPT'
                , i_env_param1  => i_network_oper_type
                , i_env_param2  => i_standard_id
            );
        end if;
end;

function get_network_type(
    i_oper_type         in      com_api_type_pkg.t_dict_value
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_dict_value is
    l_result            com_api_type_pkg.t_dict_value;
begin
    select network_oper_type
    into l_result
    from (
        select network_oper_type
          from net_oper_type_map
         where oper_type    = i_oper_type
           and standard_id  = i_standard_id
      order by priority
    )
    where rownum = 1;

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text          => 'Network operation type except [#1][#2]'
              , i_env_param1    => i_oper_type
              , i_env_param2    => i_standard_id
            );
            
            return l_result;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'NET_OPERATION_TYPE_EXCEPT'
              , i_env_param1    => i_oper_type
              , i_env_param2    => i_standard_id
            );
        end if;
end;

function get_msg_type(
    i_network_msg_type  in      com_api_type_pkg.t_dict_value
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_dict_value is
    l_result            com_api_type_pkg.t_dict_value;
begin
    select msg_type
    into l_result
    from (
        select msg_type
          from net_msg_type_map
         where i_network_msg_type like network_msg_type
           and standard_id = i_standard_id
      order by priority
    )
    where rownum = 1;

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text          => 'Network message type except [#1][#2]'
              , i_env_param1    => i_network_msg_type
              , i_env_param2    => i_standard_id
            );

            return l_result;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'NETWORK_MESSAGE_TYPE_EXCEPT'
              , i_env_param1    => i_network_msg_type
              , i_env_param2    => i_standard_id
            );
        end if;
end;

function get_network_card_type_list(
    i_card_type_id      in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_dict_tab
is
    l_result com_api_type_pkg.t_dict_tab;
begin
    select nctm.network_card_type
      bulk collect into l_result 
      from net_card_type_map nctm,
           (select id
              from net_card_type
           connect by prior parent_type_id = id
             start with id = i_card_type_id) nct 
     where nct.id = nctm.card_type_id;

    return l_result;
end;

function get_card_type_network_id(
    i_card_type_id    in    com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id  
is
begin
    if g_net_card_type_map.exists(i_card_type_id) then
        return g_net_card_type_map(i_card_type_id);
    else 
        return null;
        
    end if;
end get_card_type_network_id;

procedure init_net_card_type_map
is
begin
    for card_types in (select nct.id
                            , nct.network_id      
                         from net_card_type nct
                      )
    loop
        g_net_card_type_map(card_types.id) := card_types.network_id;  
    end loop;
    
end init_net_card_type_map;  

begin
    init_net_card_type_map();
end;
/
