create or replace package cst_ibbl_report_pkg as

procedure run_report(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_invoice_id        in     com_api_type_pkg.t_medium_id
);

procedure prepaid_card_statement(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_account_number    in     com_api_type_pkg.t_account_number
  , i_start_date        in     date                              default null
  , i_end_date          in     date                              default null
  , i_lang              in     com_api_type_pkg.t_dict_value     default null
);

procedure prepaid_card_statement_wrapped(
    o_xml               out    clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_entity_type       in     com_api_type_pkg.t_dict_value  DEFAULT acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
);

procedure prepaid_statement_event(
    o_xml               out    clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure run_report_wrapped(
    o_xml                  out clob
  , i_account_id        in     com_api_type_pkg.t_account_id
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

procedure credit_payment(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , i_date              in     date
  , i_card_number       in     com_api_type_pkg.t_card_number   default null
  , i_tran_status       in     com_api_type_pkg.t_tiny_id       default null
  , i_src_system        in     com_api_type_pkg.t_tiny_id       default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

procedure rit_report(
    o_xml                   out clob
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_month             in      com_api_type_pkg.t_tiny_id
  , i_year              in      com_api_type_pkg.t_tiny_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
);

procedure run_prc_report(
    o_xml                   out clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
);

end cst_ibbl_report_pkg;
/
