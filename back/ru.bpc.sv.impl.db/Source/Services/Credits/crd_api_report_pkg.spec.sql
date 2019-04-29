create or replace package crd_api_report_pkg is
/************************************************************
* Reports for Credit module <br />
* Created by Mashonkin V.(mashonkin@bpcbt.com) at 06.03.2014  <br />
* Module: CRD_API_REPORT_PKG <br />
* @headcom
************************************************************/

procedure run_report (
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_invoice_id        in     com_api_type_pkg.t_medium_id
  , i_mode              in     com_api_type_pkg.t_dict_value    default crd_api_const_pkg.CREDIT_STMT_MODE_DATA_ONLY
);

procedure credit_loyalty_statement(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_invoice_id        in     com_api_type_pkg.t_medium_id
);

procedure instant_credit_statement(
    o_xml                  out clob
  , i_account_number    in     com_api_type_pkg.t_account_number
  , i_settl_date        in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

function calculate_interest(
    i_account_id        in     com_api_type_pkg.t_long_id
  , i_debt_id           in     com_api_type_pkg.t_long_id        default null  
  , i_eff_date          in     date
  , i_period_date       in     date                              default null
  , i_split_hash        in     com_api_type_pkg.t_tiny_id        default null
  , i_service_id        in     com_api_type_pkg.t_short_id
  , i_product_id        in     com_api_type_pkg.t_short_id
  , i_alg_calc_intr     in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_money;

procedure credit_statement_event (
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value     default null
  , i_eff_date          in     date                              default null
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id        default null
  , i_lang              in     com_api_type_pkg.t_dict_value     default null
);

procedure run_prc_report (
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
);

procedure mad_overdue (
    o_xml                  out clob
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
);

procedure run_prc_credit_full(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
);

procedure run_prc_credit_dpp(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
);

procedure run_prc_credit_lty(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
);

end;
/
