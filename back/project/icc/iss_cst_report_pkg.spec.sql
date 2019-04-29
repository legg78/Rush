create or replace package iss_cst_report_pkg as

procedure card_mailer_report(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id      default null
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
);

procedure card_holder_statement_report(
    o_xml                  out      nocopy clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_eff_date              in      date                            default null
  , i_product_id            in      com_api_type_pkg.t_short_id     default null
  , i_contract_number       in      com_api_type_pkg.t_name         default null
  , i_customer_number       in      com_api_type_pkg.t_name         default null
  , i_currency              in      com_api_type_pkg.t_curr_code    default null
  , i_introduced_by         in      com_api_type_pkg.t_name         default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
);

procedure card_holder_statement_rep_ext(
    o_xml                  out      nocopy clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_date_from             in      date                            default null
  , i_date_to               in      date
  , i_product_id            in      com_api_type_pkg.t_short_id     default null
  , i_contract_number       in      com_api_type_pkg.t_name         default null
  , i_customer_number       in      com_api_type_pkg.t_name         default null
  , i_currency              in      com_api_type_pkg.t_curr_code    default null
  , i_introduced_by         in      com_api_type_pkg.t_name         default null
  , i_statement_service     in      com_api_type_pkg.t_boolean      default null
  , i_e_statement_service   in      com_api_type_pkg.t_boolean      default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
);

procedure card_holder_sttmnt_rep_determ(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date                            default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
);

procedure card_hold_stmnt_rep_ext_determ(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date                            default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
);

procedure card_holder_sttmnt_rep_event(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
);

procedure card_mailer_list_report(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_agent_id              in      com_api_type_pkg.t_agent_id     default null
  , i_product_id            in      com_api_type_pkg.t_short_id     default null
  , i_customer_number       in      com_api_type_pkg.t_name         default null
  , i_card_mask             in      com_api_type_pkg.t_card_number  default null
  , i_is_express_card       in      com_api_type_pkg.t_boolean      default null
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
);

end iss_cst_report_pkg;
/
