create or replace package net_api_report_pkg as

procedure net_member_position_report(
    o_xml            out clob
  , i_sttl_date          date
  , i_date_start  in     date
  , i_date_end    in     date
  , i_currency    in     com_api_type_pkg.t_curr_code
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_lang        in     com_api_type_pkg.t_dict_value
);

procedure unmatched_presentments(
    o_xml            out clob
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_network_id  in     com_api_type_pkg.t_tiny_id     default null
  , i_start_date  in     date
  , i_end_date    in     date
  , i_lang        in     com_api_type_pkg.t_dict_value  default null
);


end net_api_report_pkg;
/
