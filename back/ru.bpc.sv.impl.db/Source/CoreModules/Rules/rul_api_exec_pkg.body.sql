create or replace package body rul_api_exec_pkg is

procedure execute_procedure (
    i_procedure_name      in com_api_type_pkg.t_name
) is
begin
    rul_api_exec_static_pkg.execute_procedure(i_procedure_name);
exception
    when com_api_error_pkg.e_rollback_process_stage 
      or com_api_error_pkg.e_stop_process_stage 
      
      or com_api_error_pkg.e_rollback_execute_rule_set
      or com_api_error_pkg.e_stop_execute_rule_set 
      
      or com_api_error_pkg.e_rollback_process_operation
      or com_api_error_pkg.e_stop_process_operation
      
      or com_api_error_pkg.e_application_error then
        trc_log_pkg.debug(
            i_text          => 'Exception while executing rule [#2] : #1'
          , i_env_param1    => sqlerrm
          , i_env_param2    => i_procedure_name
        );
        raise;    
    when com_api_error_pkg.e_stop_cycle_repetition then
        raise;
    when others then
        trc_log_pkg.error(
            i_text          => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
          , i_env_param2    => i_procedure_name 
        );
        raise;
end;

procedure execute_procedure (
    i_proc_id      in com_api_type_pkg.t_tiny_id
) is
begin
    for r in (select proc_name
                from rul_proc
               where id = i_proc_id)
    loop
       execute_procedure(r.proc_name);
       return;
    end loop;
    trc_log_pkg.error(
        i_text          => 'UNDEFINED_RULE'
      , i_env_param1    => i_proc_id  
    );
end;


end;
/
