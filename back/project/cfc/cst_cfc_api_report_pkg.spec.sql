create or replace package cst_cfc_api_report_pkg as

procedure approved_appl_report(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id      default null
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_appl_status           in      com_api_type_pkg.t_dict_value   default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
);

procedure cards_operation(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_rejected_only     in     com_api_type_pkg.t_boolean
  , i_lang              in     com_api_type_pkg.t_dict_value default com_api_const_pkg.DEFAULT_LANGUAGE
);

procedure rejected_cards_operation(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value default com_api_const_pkg.DEFAULT_LANGUAGE
);

procedure all_cards_operation(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value default com_api_const_pkg.DEFAULT_LANGUAGE  
);

procedure report_card_account_operation(
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_notify_party_type in      com_api_type_pkg.t_dict_value   := null
  , i_src_entity_type   in      com_api_type_pkg.t_dict_value   := null
  , i_src_object_id     in      com_api_type_pkg.t_long_id      := null
);

end;
/
