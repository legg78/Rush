create or replace package cst_bnv_napas_report_pkg as

procedure reconciliate_results_not_sv(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id default null
  , i_lang              in     com_api_type_pkg.t_dict_value default null
);

procedure reconciliate_results_not_napas(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id default null
  , i_lang              in     com_api_type_pkg.t_dict_value default null
);

end;
/
