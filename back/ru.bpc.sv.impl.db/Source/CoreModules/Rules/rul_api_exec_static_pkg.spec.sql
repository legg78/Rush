create or replace package rul_api_exec_static_pkg is

procedure execute_procedure (
    i_procedure_name      in com_api_type_pkg.t_name
);

end rul_api_exec_static_pkg;
/