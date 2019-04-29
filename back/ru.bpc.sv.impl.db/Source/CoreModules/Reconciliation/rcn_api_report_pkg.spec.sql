create or replace package rcn_api_report_pkg is

procedure reconciliation_report ( 
    o_xml              out clob
  , i_recon_type    in     com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_COMMON
  , i_start_date    in     date
  , i_end_date      in     date
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_inst_id       in     com_api_type_pkg.t_tiny_id
);

procedure atm_reconcilation_statistic(
    o_xml             out  clob
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_inst_id      in      com_api_type_pkg.t_inst_id default null
  , i_start_date   in      date default null
  , i_end_date     in      date default null
);

procedure host_reconcilation_statistic(
    o_xml            out clob
  , i_recon_type  in     com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_COMMON
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_date_start  in     date
  , i_date_end    in     date
  , i_lang        in     com_api_type_pkg.t_dict_value
);

procedure srvp_reconcilation_statistic(
    o_xml              out clob
  , i_recon_type    in     com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_SRVP
  , i_start_date    in     date
  , i_end_date      in     date
  , i_lang          in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id       in     com_api_type_pkg.t_tiny_id
  , i_recon_status  in     com_api_type_pkg.t_dict_value    default null
);

end rcn_api_report_pkg;
/
