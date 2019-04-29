create or replace package body rul_api_regen_pkg is

procedure gen_static_pkg is
    l_package_source        clob;
    l_header                com_api_type_pkg.t_text;
    l_footer                com_api_type_pkg.t_text;
    c_crlf        constant  com_api_type_pkg.t_name := chr(13)||chr(10);
begin
    l_header    :=
'create or replace package body rul_api_exec_static_pkg is

procedure execute_procedure (
    i_procedure_name      in com_api_type_pkg.t_name
) is
begin
    case lower(i_procedure_name)
';
    
    l_footer    := 
   '    else
        begin
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || ''.execute_procedure: using dynamic SQL for procedure ['' || i_procedure_name || '']'');
            execute immediate ''begin '' || i_procedure_name || ''; end;'';
        end;   
    end case; 
end;

end rul_api_exec_static_pkg;';
    
    for rec in (
        select '    when ''' || proc_name || ''' then ' || proc_name || ';' prc
          from rul_proc
    ) loop
        l_package_source    := l_package_source || rec.prc || c_crlf;
    end loop;
    
    l_package_source    :=
        l_header
     || l_package_source 
     || l_footer;
     
    execute immediate l_package_source;
    
end gen_static_pkg;

procedure gen_dynamic_pkg is
begin
    execute immediate
'create or replace package body rul_api_exec_static_pkg is

procedure execute_procedure (
    i_procedure_name      in com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || ''.execute_procedure: execute immediate ['' || i_procedure_name || '']'');
    execute immediate ''begin '' || i_procedure_name || ''; end;'';    
end;

end rul_api_exec_static_pkg;
    ';
end;

end rul_api_regen_pkg;
/
