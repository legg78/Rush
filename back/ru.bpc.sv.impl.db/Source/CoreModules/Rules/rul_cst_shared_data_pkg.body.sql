create or replace package body rul_cst_shared_data_pkg is

procedure load_oper_params(
    i_oper_id  in             com_api_type_pkg.t_long_id
  , io_params  in out nocopy  com_api_type_pkg.t_param_tab
) is
begin
    trc_log_pkg.debug(
        i_text => 'rul_cst_shared_data_pkg.load_oper_params dummy'
    );
end;

end rul_cst_shared_data_pkg;
/
