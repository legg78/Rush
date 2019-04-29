create or replace package body rul_api_process_pkg is
/********************************************************* 
 *  Acquiring application API  <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 21.01.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: rul_api_process_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

function get_rule_tab(
    i_rule_set_id    in com_api_type_pkg.t_tiny_id
) return t_rule_tab
result_cache
relies_on (rul_rule, rul_proc, rul_proc_param, rul_rule_param_value)
is
    l_rule_tab          t_rule_tab;
begin
    -- This method with "result_cache" can contain only one "select" query without other package methods and global variables.
    select rp.proc_name
         , rp.rule_id
         , rp.proc_id
         , rp.param_name
         , v.param_value
         , rp.is_mandatory
         , rp.param_id
      bulk collect into l_rule_tab
      from (select p.proc_name
                 , r.id          as rule_id
                 , p.id          as proc_id
                 , pp.id         as param_id
                 , pp.param_name
                 , r.exec_order
                 , pp.is_mandatory
              from rul_rule r
                 , rul_proc p
                 , rul_proc_param pp
             where r.rule_set_id = i_rule_set_id
               and p.id          = r.proc_id
               and pp.proc_id(+) = r.proc_id
           ) rp
         , rul_rule_param_value v
     where v.rule_id(+)       = rp.rule_id
       and v.proc_param_id(+) = rp.param_id
  order by rp.exec_order
         , rp.rule_id;                

    return l_rule_tab;
end get_rule_tab;

procedure execute_rule_set(
    i_rule_set_id   in            com_api_type_pkg.t_tiny_id
  , o_rules_count      out        number
  , io_params       in out nocopy com_api_type_pkg.t_param_tab
) is
    l_rule_tab      t_rule_tab;
    l_params   com_api_type_pkg.t_param_tab;
begin
    savepoint processing_rule_set;
        
    trc_log_pkg.info (
        i_text        => 'Executing rule set [#1]'
      , i_env_param1  => i_rule_set_id
    );
    
    l_params := io_params;
    o_rules_count := 0;

    l_rule_tab := get_rule_tab(
                      i_rule_set_id  =>  i_rule_set_id
                  );

    for i in 1 .. l_rule_tab.count loop
        if l_rule_tab(i).param_name is not null then
            if  l_rule_tab(i).is_mandatory = com_api_const_pkg.TRUE
            and l_rule_tab(i).param_value is null then
                  com_api_error_pkg.raise_error(
                      i_error      => 'MANDATORY_PARAM_VALUE_NOT_DEFINED'
                    , i_env_param1 => i_rule_set_id
                    , i_env_param2 => l_rule_tab(i).rule_id
                    , i_env_param3 => l_rule_tab(i).param_id
                    , i_env_param4 => l_rule_tab(i).param_name
                  );
            end if;
            if l_rule_tab(i).param_value is not null
                or (l_rule_tab(i).param_value is null
                    and not l_params.exists(l_rule_tab(i).param_name)
                   )
            then
                rul_api_param_pkg.set_param (
                    i_name        => l_rule_tab(i).param_name
                  , i_value       => l_rule_tab(i).param_value
                  , io_params     => io_params 
                );
            end if;
        end if;
            
        if (not l_rule_tab.exists(i+1)) or (l_rule_tab(i+1).rule_id != l_rule_tab(i).rule_id) then
            o_rules_count := o_rules_count + 1;
                
            trc_log_pkg.info (
                i_text      => 'Executing rule [' || l_rule_tab(i).rule_id || '][' || l_rule_tab(i).proc_name || '] STARTING' 
            );
              
            rul_api_exec_pkg.execute_procedure(l_rule_tab(i).proc_name);
                
            trc_log_pkg.info (
                i_text      => 'Executing rule [' || l_rule_tab(i).rule_id || '][' || l_rule_tab(i).proc_name || '] FINISHED' 
            );
        end if;
    end loop;

exception
    when com_api_error_pkg.e_stop_cycle_repetition then
        raise;
    when com_api_error_pkg.e_stop_execute_rule_set then
        null;
    when com_api_error_pkg.e_rollback_execute_rule_set then
        rollback to savepoint processing_rule_set;            
    when others then
        raise;
end execute_rule_set;
    
end rul_api_process_pkg;
/
