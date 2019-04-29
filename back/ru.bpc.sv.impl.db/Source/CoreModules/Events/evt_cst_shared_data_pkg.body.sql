create or replace package body evt_cst_shared_data_pkg is

procedure collect_event_params(
    io_params       in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.collect_event_params: dummy'
    );    
end collect_event_params;

end;
/