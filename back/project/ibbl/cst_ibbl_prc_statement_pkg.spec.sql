create or replace package cst_ibbl_prc_statement_pkg as

procedure create_prepaid_card_statements(
    i_report_id  in     com_api_type_pkg.t_short_id
  , i_lang       in     com_api_type_pkg.t_dict_value   default null
);


end cst_ibbl_prc_statement_pkg;
/
