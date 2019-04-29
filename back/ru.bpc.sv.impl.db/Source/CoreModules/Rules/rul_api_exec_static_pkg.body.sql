create or replace package body rul_api_exec_static_pkg is

procedure execute_procedure (
    i_procedure_name      in com_api_type_pkg.t_name
) is
begin
    execute immediate 'begin ' || i_procedure_name || '; end;';    
end;

end rul_api_exec_static_pkg;
/