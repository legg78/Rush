create or replace package cst_woo_report_pkg as

procedure batch_file_rpt(
    o_xml                  out clob
  , i_report_id         in     com_api_type_pkg.t_dict_value  
  , i_lang              in     com_api_type_pkg.t_dict_value    default null    
  , i_date_start        in     date                             default null
  , i_date_end          in     date                             default null
);

end;
/
