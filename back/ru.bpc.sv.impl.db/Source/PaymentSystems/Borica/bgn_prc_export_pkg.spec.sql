create or replace package bgn_prc_export_pkg as

    g_file_rec                      bgn_api_type_pkg.t_bgn_file_rec;
    g_fin_rec                       bgn_api_type_pkg.t_bgn_fin_rec;

procedure process (
    i_network_id            in com_api_type_pkg.t_network_id default null
  , i_inst_id               in com_api_type_pkg.t_inst_id default null
  , i_host_inst_id          in com_api_type_pkg.t_inst_id default null  
  , i_date_type             in com_api_type_pkg.t_dict_value default com_api_const_pkg.DATE_PURPOSE_PROCESSING
);

end bgn_prc_export_pkg;
/ 
 