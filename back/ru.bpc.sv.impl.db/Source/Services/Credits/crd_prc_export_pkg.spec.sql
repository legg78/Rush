create or replace package crd_prc_export_pkg is

procedure process_account(
    i_inst_id       in  com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
  , i_account_type  in  com_api_type_pkg.t_dict_value   default acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
);

procedure export_closed_cards (
    i_card_inst_id          in com_api_type_pkg.t_inst_id
  , i_start_date            in date
  , i_end_date              in date
);

procedure export_cards_with_overdue(
    i_card_inst_id          in com_api_type_pkg.t_inst_id
  , i_start_date            in date
  , i_end_date              in date
);

/*
 * Unloading credit statements in SVXP format.
 */    
procedure process_credit_statement(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_account_number    in     com_api_type_pkg.t_account_number
  , i_sttl_date         in     date
);

end crd_prc_export_pkg;
/
