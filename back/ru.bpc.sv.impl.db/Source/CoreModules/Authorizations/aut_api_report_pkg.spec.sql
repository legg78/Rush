create or replace package aut_api_report_pkg is

procedure approved_auth_statistics(
    o_xml                         out clob
  , i_start_date                   in date
  , i_end_date                     in date
  , i_currency                     in com_api_type_pkg.t_curr_code  default null
  , i_inst_id                      in com_api_type_pkg.t_inst_id    default null
  , i_party_type                   in com_api_type_pkg.t_dict_value default null
  , i_lang                         in com_api_type_pkg.t_dict_value default null
);

end aut_api_report_pkg;
/
