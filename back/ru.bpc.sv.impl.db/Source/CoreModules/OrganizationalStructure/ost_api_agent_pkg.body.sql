create or replace package body ost_api_agent_pkg as

function get_inst_id(
    i_agent_id          in      com_api_type_pkg.t_agent_id
) return com_api_type_pkg.t_inst_id is
    l_result            com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_result
      from ost_agent_vw
     where id = i_agent_id;
    
    return l_result;
exception
    when no_data_found then
        return null;
end get_inst_id;

/*
 * Function return agent ID; it uses i_agent_id for searching if is not NULL,
 * otherwise, it uses i_agent_number.
 */
function get_agent_id(
    i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_agent_number      in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_mask_error        in      com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_agent_id
is
    l_agent_id          com_api_type_pkg.t_agent_id;
begin
    begin
        if i_agent_id is not null then
            select a.id
              into l_agent_id
              from ost_agent a
             where a.id = i_agent_id;
        elsif i_agent_number is not null then
            select a.id
              into l_agent_id
              from ost_agent a
             where a.agent_number = i_agent_number
               and a.inst_id      = i_inst_id;
        else
            raise no_data_found;
        end if;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'AGENT_NOT_FOUND'
                  , i_env_param1 => nvl(i_agent_id, i_agent_number)
                  , i_env_param2 => i_inst_id
                );
            end if;
    end;

    return l_agent_id;
end get_agent_id;

function generate_agent_number(
    i_agent_id          in      com_api_type_pkg.t_medium_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date                            default com_api_sttl_day_pkg.get_sysdate() 
) return com_api_type_pkg.t_name is
    l_params            com_api_type_pkg.t_param_tab;
    l_result            com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.generate_agent_number: initialization of l_params: ' ||
                        'i_agent_id [#1], i_inst_id [#2], i_eff_date [#3]'
      , i_env_param1 => i_agent_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_eff_date
    );
    
    l_params.delete;
    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => ost_api_const_pkg.AGENT_NAME_FORMAT_AGENT_ID
      , i_value   => i_agent_id
    );
    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => ost_api_const_pkg.AGENT_NAME_FORMAT_INST_ID
      , i_value   => i_inst_id
    );
    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => ost_api_const_pkg.AGENT_NAME_FORMAT_EFF_DATE
      , i_value   => i_eff_date
    );

    l_result := rul_api_name_pkg.get_name(
        i_format_id           => ost_api_const_pkg.AGENT_NAME_FORMAT_ID
      , i_param_tab           => l_params
    );
        
    return l_result;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.generate_agent_number: sqleerm [#1]'
          , i_env_param1 => sqlerrm
        );
        raise;            
end generate_agent_number;

procedure check_agent_id(
    i_agent_id          in      com_api_type_pkg.t_agent_id
) is
    l_agent_id                  com_api_type_pkg.t_agent_id;
begin
    select a.agent_id
      into l_agent_id
      from acm_cu_agent_vw a
     where a.agent_id = i_agent_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'AGENT_NOT_ACCESS'
          , i_env_param1 => i_agent_id
        );                                 
end check_agent_id;

end ost_api_agent_pkg;
/
