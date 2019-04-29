create or replace package body opr_cst_shared_data_pkg is

procedure collect_global_oper_params(
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_global_oper_params dummy'
    );
end;

procedure collect_oper_params(
    i_oper          in              opr_api_type_pkg.t_oper_rec         default null
  , i_iss_part      in              opr_api_type_pkg.t_oper_part_rec    default null
  , i_acq_part      in              opr_api_type_pkg.t_oper_part_rec    default null
  , io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_oper_params dummy'
    );
end;

end;
/
