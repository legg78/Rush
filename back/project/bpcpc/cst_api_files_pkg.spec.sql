create or replace package cst_api_files_pkg is

procedure load_sms_services_file(
    i_inst_id           in com_api_type_pkg.t_inst_id
);

end;
/
