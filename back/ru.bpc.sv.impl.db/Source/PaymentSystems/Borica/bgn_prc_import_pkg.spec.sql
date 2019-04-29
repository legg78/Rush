create or replace package bgn_prc_import_pkg as

    g_file_rec      bgn_api_type_pkg.t_bgn_file_rec;

procedure process_eo(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
);

procedure process_qo(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
);

procedure process_fo(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
);

procedure process_so(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_network_id    in  com_api_type_pkg.t_inst_id  
);

procedure import_bin_table;

end bgn_prc_import_pkg;
/
 