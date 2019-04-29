create or replace package opr_cst_shared_data_pkg is

procedure collect_global_oper_params(
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
);

procedure collect_oper_params(
    i_oper          in              opr_api_type_pkg.t_oper_rec         default null
  , i_iss_part      in              opr_api_type_pkg.t_oper_part_rec    default null 
  , i_acq_part      in              opr_api_type_pkg.t_oper_part_rec    default null 
  , io_params       in out nocopy   com_api_type_pkg.t_param_tab    
);

end opr_cst_shared_data_pkg;
/