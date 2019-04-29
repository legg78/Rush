create or replace package evt_cst_shared_data_pkg is

procedure collect_event_params(
    io_params       in out nocopy com_api_type_pkg.t_param_tab
);

end;
/