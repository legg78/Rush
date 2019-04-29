create or replace package cst_apc_api_external_pkg as

procedure credit_card_info (
    i_card_id             in     com_api_type_pkg.t_medium_id
  , i_date_format         in     com_api_type_pkg.t_name       default 'yyyy-mm-dd'
  , i_add_curr_name       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , o_result_xml             out clob
);

end cst_apc_api_external_pkg;
/
