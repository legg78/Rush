create or replace package pap_api_application_pkg as

procedure process_application(
    i_appl_id              in            com_api_type_pkg.t_long_id  default null
);

end;
/
