create or replace package qrz_ui_scheduler_running_pkg as

procedure run_scheduler;

procedure stop_scheduler;

function is_running return com_api_type_pkg.t_boolean;

end;
/