create or replace package bgn_cst_borica_pkg is

function define_acquirer_inst(
    i_fin_rec       in  bgn_api_type_pkg.t_bgn_fin_rec
  , i_file_code     in  com_api_type_pkg.t_dict_value  
) return com_api_type_pkg.t_inst_id;

function is_borica_terminal(
    i_terminal_id       in  com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

procedure sttl_postprocess(
    io_fin_rec          in out nocopy   bgn_api_type_pkg.t_bgn_fin_rec
  , io_oper             in out nocopy   opr_api_type_pkg.t_oper_rec
  , io_iss_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , io_acq_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
);

procedure oper_status_postprocess(
    io_fin_rec          in out nocopy   bgn_api_type_pkg.t_bgn_fin_rec
  , io_oper             in out nocopy   opr_api_type_pkg.t_oper_rec
  , io_iss_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , io_acq_part         in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , i_file_code         in              com_api_type_pkg.t_dict_value  
);

function outgoing_oper_type(
    io_fin_rec          in out nocopy   bgn_api_type_pkg.t_bgn_fin_rec
  , i_oper_id           in              com_api_type_pkg.t_long_id    
  , i_oper_type         in              com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_tiny_id;

end bgn_cst_borica_pkg;
/
 