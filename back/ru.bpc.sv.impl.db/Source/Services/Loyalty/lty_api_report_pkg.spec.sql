create or replace package lty_api_report_pkg as

procedure loyalty_statement(
    i_account_id        in      com_api_type_pkg.t_medium_id
  , i_start_date        in      date
  , i_end_date          in      date
  , i_lang              in      com_api_type_pkg.t_dict_value
  , o_xml                  out  clob
);

procedure loyalty_statement_batch(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
);

procedure loyalty_statement_notify(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
);

end;
/
