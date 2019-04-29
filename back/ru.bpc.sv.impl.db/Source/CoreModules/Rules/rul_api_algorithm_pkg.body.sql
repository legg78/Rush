create or replace package body rul_api_algorithm_pkg is

function get_algorithm_procedure(
    i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value     default null
) return com_api_type_pkg.t_name
result_cache relies_on (rul_algorithm, rul_proc)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_algorithm_procedure';
    l_proc_name                    com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_algorithm [#1], i_entry_point [#2]'
      , i_env_param1 => i_algorithm
      , i_env_param2 => i_entry_point
    );

    select proc.proc_name
      into l_proc_name
      from rul_algorithm    algo
      join rul_proc         proc    on proc.id = algo.proc_id
     where algo.algorithm    = i_algorithm
       and nvl(algo.entry_point, 'null') = nvl(i_entry_point, 'null')
       and proc.proc_name is not null;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> [#1]'
      , i_env_param1 => l_proc_name
    );

    return l_proc_name;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'ALGORITHM_NOT_DEFINED'
          , i_env_param1 => i_algorithm
          , i_env_param2 => i_entry_point
        );
    when others then
        raise;    
    
end get_algorithm_procedure;

procedure execute_algorithm(
    i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value     default null
) is
    l_algorithm_proc_name          com_api_type_pkg.t_name;
begin
    l_algorithm_proc_name := get_algorithm_procedure(
                                 i_algorithm      => i_algorithm
                               , i_entry_point    => i_entry_point
                             );
    trc_log_pkg.info(
        i_text        => 'ALGORITHM_RULE_STARTED'
      , i_env_param1  => i_algorithm
      , i_env_param2  => l_algorithm_proc_name
      , i_env_param3  => i_entry_point
    );

    rul_api_exec_pkg.execute_procedure(i_procedure_name => l_algorithm_proc_name);

    trc_log_pkg.info(
        i_text        => 'ALGORITHM_RULE_FINISHED'
      , i_env_param1  => i_algorithm
      , i_env_param2  => l_algorithm_proc_name
      , i_env_param3  => i_entry_point
    );
end execute_algorithm;

/*
 * Procedure used for back compatible in places where is needed choice either old user-exit procedure or new algorithm-procedure.
 */
function check_algorithm_exists(
    i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value     default null
) return com_api_type_pkg.t_boolean is
    l_result            com_api_type_pkg.t_boolean;
begin
    select case when count(1) > 0 then 1 else 0 end
      into l_result
      from rul_algorithm    algo
      join rul_proc         proc    on proc.id = algo.proc_id
     where algo.algorithm    = i_algorithm
       and nvl(algo.entry_point, 'null') = nvl(i_entry_point, 'null')
       and proc.proc_name is not null;
     
     return l_result;
end;

end;
/
