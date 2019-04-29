create or replace package body asc_api_scenario_pkg as
/*********************************************************
 *  API for Authorization scenarios <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 19.03.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: asc_api_scenario_pkg <br />
 *  @headcom
 **********************************************************/

procedure get_scenario_id(
    i_param_tab         in      com_api_type_pkg.t_param_tab
  , o_scenario_id          out  com_api_type_pkg.t_tiny_id
) is
    l_oper_type                 com_api_type_pkg.t_dict_value;
    l_is_reversal               com_api_type_pkg.t_boolean;
    l_sttl_type                 com_api_type_pkg.t_dict_value;
    l_msg_type                  com_api_type_pkg.t_dict_value;
    l_terminal_type             com_api_type_pkg.t_dict_value;
    l_oper_reason               com_api_type_pkg.t_dict_value;
begin

    l_oper_type   := rul_api_param_pkg.get_param_char('OPER_TYPE', i_param_tab);
    l_is_reversal := rul_api_param_pkg.get_param_num('IS_REVERSAL', i_param_tab);
    l_sttl_type   := rul_api_param_pkg.get_param_char('STTL_TYPE', i_param_tab);
    l_msg_type    := rul_api_param_pkg.get_param_char('MSG_TYPE', i_param_tab);
    l_terminal_type := rul_api_param_pkg.get_param_char('TERMINAL_TYPE', i_param_tab);
    l_oper_reason := rul_api_param_pkg.get_param_char('OPER_REASON', i_param_tab);
    
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.get_scenario_id: l_oper_type [#1], l_is_reversal [#2], '
                     || 'l_sttl_type [#3], , l_msg_type [#4], l_terminal_type [#5], l_oper_reason [#6]'
      , i_env_param1 => l_oper_type
      , i_env_param2 => l_is_reversal
      , i_env_param3 => l_sttl_type
      , i_env_param4 => l_msg_type
      , i_env_param5 => l_terminal_type
      , i_env_param6 => l_oper_reason
    );

    for scenarios in (
        select
            r.scenario_id
            , r.mod_id
        from
            asc_scenario_selection_vw r
        where
            r.oper_type = l_oper_type
            and r.is_reversal = l_is_reversal
            and r.sttl_type = l_sttl_type
            and r.msg_type = l_msg_type
            and nvl(l_terminal_type, '%') like r.terminal_type
            and nvl(l_oper_reason, '%') like r.oper_reason
        order by
            r.priority
    ) loop
        if scenarios.mod_id is not null then
            if rul_api_mod_pkg.check_condition(scenarios.mod_id, i_param_tab) = com_api_type_pkg.TRUE then
                o_scenario_id := scenarios.scenario_id;
                return;
            end if;
        else
            o_scenario_id := scenarios.scenario_id;
            return;
        end if;
    end loop;

    return;

    com_api_error_pkg.raise_error(
        i_error         => 'AUTH_SCENARIO_COULD_NOT_BE_DEFINED'
      , i_env_param1    => l_oper_type
      , i_env_param2    => l_is_reversal
      , i_env_param3    => l_sttl_type
      , i_env_param4    => l_msg_type
      , i_env_param5    => l_terminal_type
      , i_env_param6    => l_oper_reason
    );
end get_scenario_id;

end;
/
