create or replace package rul_api_exec_pkg is

procedure execute_procedure (
    i_procedure_name      in com_api_type_pkg.t_name
);

procedure execute_procedure (
    i_proc_id      in com_api_type_pkg.t_tiny_id
);

end;
/
