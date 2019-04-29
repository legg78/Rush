create or replace package cst_lvp_api_external_pkg as

function find_invoice_id (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_id          in     com_api_type_pkg.t_account_id
  , i_eff_date            in     date
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_medium_id;

procedure invoice_info (
    i_invoice_id          in     com_api_type_pkg.t_medium_id
  , o_ref_cursor             out sys_refcursor
);

procedure invoice_transactions (
    i_invoice_id          in     com_api_type_pkg.t_medium_id
  , i_account_id          in     com_api_type_pkg.t_account_id  default null
  , i_lang                in     com_api_type_pkg.t_dict_value  default null
  , o_ref_cursor             out sys_refcursor
);

procedure credit_client_info (
    i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_mask_error          in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , o_result                 out cst_lvp_type_pkg.t_credit_card_info_tab
);

procedure invoice_info_and_transactions (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_number      in     com_api_type_pkg.t_account_number
  , i_eff_date            in     date
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
);

procedure transactions_by_date_range (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_number      in     com_api_type_pkg.t_account_number
  , i_begin_date          in     date
  , i_end_date            in     date
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
);

procedure credit_client_info (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_customer_number     in     com_api_type_pkg.t_name
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
);

procedure credit_card_info (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_card_number         in     com_api_type_pkg.t_card_number
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
);

procedure prepaid_card_info (
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_card_number         in     com_api_type_pkg.t_card_number
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , o_result_xml             out clob
);

end cst_lvp_api_external_pkg;
/
