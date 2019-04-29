create or replace package rul_cst_shared_data_pkg is

procedure load_oper_params(
    i_oper_id  in             com_api_type_pkg.t_long_id
  , io_params  in out nocopy  com_api_type_pkg.t_param_tab
);

end rul_cst_shared_data_pkg;
/
