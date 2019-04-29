create or replace package cst_amk_epw_report_pkg as

procedure reconciliation_results(
    o_xml                  out clob 
  , i_file_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value default null
);

end;
/

