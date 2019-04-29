create or replace package body app_api_flow_transition_pkg as
/*********************************************************
 *  Flow transition application API  <br />
 *  Created by Gogolev I.(i.gogolev@bpcbt.com)  at 12.01.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_api_flow_transition_pkg <br />
 *  @headcom
 **********************************************************/
function check_available_transition(
    i_appl_id               in            com_api_type_pkg.t_long_id
  , i_flow_id               in            com_api_type_pkg.t_tiny_id        default null
  , i_new_appl_status       in            com_api_type_pkg.t_dict_value     default null
  , i_new_reject_code       in            com_api_type_pkg.t_dict_value     default null
  , i_old_appl_status       in            com_api_type_pkg.t_dict_value     default null
  , i_old_reject_code       in            com_api_type_pkg.t_dict_value     default null
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_available_transition: ';
    
    l_application           app_api_type_pkg.t_application_rec;
    l_flow_id               com_api_type_pkg.t_tiny_id;
    l_old_appl_status       com_api_type_pkg.t_dict_value;
    l_old_reject_code       com_api_type_pkg.t_dict_value;
    
    l_result                com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text              => LOG_PREFIX || 'start with params - appl_id [#1], flow_id [#2], new_appl_status [#3], new_reject_code [#4], old_appl_status [#5], old_reject_code [#6]'
      , i_env_param1        => i_appl_id
      , i_env_param2        => i_flow_id
      , i_env_param3        => i_new_appl_status
      , i_env_param4        => i_new_reject_code
      , i_env_param5        => i_old_appl_status
      , i_env_param6        => i_old_reject_code
    );
    
    if i_flow_id is null 
        or i_old_appl_status is null
        or i_old_reject_code is null
    then
        l_application := 
            app_api_application_pkg.get_application(
                i_appl_id     => i_appl_id
              , i_raise_error => com_api_const_pkg.TRUE
            );
    end if;
    l_flow_id         := nvl(i_flow_id, l_application.flow_id);
    l_old_appl_status := nvl(i_old_appl_status, l_application.appl_status);
    l_old_reject_code := nvl(i_old_reject_code, l_application.reject_code);
    
    select decode(count(*), 1, com_api_const_pkg.TRUE, com_api_const_pkg.FALSE)
      into l_result
      from app_flow_transition ft
         , app_flow_stage fso
         , app_flow_stage fsn
     where fso.flow_id = l_flow_id
       and fso.appl_status = l_old_appl_status
       and (l_old_reject_code is null or fso.reject_code is null or l_old_reject_code = fso.reject_code)
       and fso.id = ft.stage_id 
       and fsn.id = ft.transition_stage_id
       and (i_new_appl_status is null or fsn.appl_status = i_new_appl_status)
       and (i_new_reject_code is null or fsn.reject_code is null or i_new_reject_code = fsn.reject_code)
       and rownum < 2;
    return l_result;
exception
    when others then
        trc_log_pkg.debug(
            i_text              => LOG_PREFIX
                                || 'Finished failed with params - appl_id [#1], flow_id [#2], new_appl_status [#3], new_reject_code [#4], old_appl_status [#5], old_reject_code [#6]'
          , i_env_param1        => i_appl_id
          , i_env_param2        => l_flow_id
          , i_env_param3        => i_new_appl_status
          , i_env_param4        => i_new_reject_code
          , i_env_param5        => l_old_appl_status
          , i_env_param6        => l_old_reject_code
        );
        
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end check_available_transition;

procedure get_new_transition_data(
    i_flow_id               in            com_api_type_pkg.t_tiny_id
  , i_old_appl_status       in            com_api_type_pkg.t_dict_value
  , i_old_reject_code       in            com_api_type_pkg.t_dict_value     default null
  , i_reason_code           in            com_api_type_pkg.t_dict_value     default null
  , io_new_appl_status      in out        com_api_type_pkg.t_dict_value
  , io_new_reject_code      in out        com_api_type_pkg.t_dict_value
  , io_event_type           in out        com_api_type_pkg.t_dict_value
)
is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_new_transition_data: ';
    
    l_new_appl_status       com_api_type_pkg.t_dict_value;
    l_new_reject_code       com_api_type_pkg.t_dict_value;
    l_event_type            com_api_type_pkg.t_dict_value;

begin
    trc_log_pkg.debug(
        i_text              => LOG_PREFIX || 'start with params - flow_id [#1], old_appl_status [#2], old_reject_code [#3], new_appl_status [#4], new_reject_code [#5], event_type [#6'
                            || '] reason_code [' || i_reason_code || ']'
      , i_env_param1        => i_flow_id
      , i_env_param2        => i_old_appl_status
      , i_env_param3        => i_old_reject_code
      , i_env_param4        => io_new_appl_status
      , i_env_param5        => io_new_reject_code
      , i_env_param6        => io_event_type
    );
    begin
        select src.appl_status
             , src.reject_code
             , src.event_type
          into l_new_appl_status
             , l_new_reject_code
             , l_event_type
          from (select fsn.appl_status
                     , fsn.reject_code
                     , ft.event_type
                     , row_number() over(order by case
                                                      when ((fso.reject_code is null and i_old_reject_code is null)
                                                            or (fso.reject_code = i_old_reject_code)
                                                           )
                                                           and 
                                                           (fsn.appl_status = io_new_appl_status
                                                            or
                                                            fsn.reject_code = io_new_reject_code
                                                           )
                                                           and
                                                           (ft.event_type = io_event_type
                                                            or ft.event_type is not null
                                                           )
                                                           and
                                                           (ft.reason_code = i_reason_code
                                                            or (i_reason_code is null)
                                                           )
                                                          then 0
                                                      else 1
                                                  end asc
                                                , ft.id asc
                       ) as rnk
                  from app_flow_transition ft
                     , app_flow_stage fso
                     , app_flow_stage fsn
                 where fso.flow_id = i_flow_id
                   and fso.appl_status = i_old_appl_status
                   and (i_old_reject_code is null or fso.reject_code is null or i_old_reject_code = fso.reject_code)
                   and fso.id = ft.stage_id 
                   and fsn.id = ft.transition_stage_id
                   and (io_new_appl_status is null or fsn.appl_status = io_new_appl_status)
                   and (io_new_reject_code is null or fsn.reject_code is null or io_new_reject_code = fsn.reject_code)
                   and (io_event_type is null or ft.event_type is null or io_event_type = ft.event_type)
                   and (i_reason_code is null or ft.reason_code is null or i_reason_code = ft.reason_code)
          ) src
         where rnk = 1;
     exception
         when no_data_found then
             trc_log_pkg.debug(
                 i_text => LOG_PREFIX || 'Transition not found'
             );
     end;

     io_new_appl_status := nvl(l_new_appl_status, io_new_appl_status);
     io_new_reject_code := nvl(l_new_reject_code, io_new_reject_code);
     io_event_type      := nvl(l_event_type, io_event_type);

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end get_new_transition_data;

end app_api_flow_transition_pkg;
/
