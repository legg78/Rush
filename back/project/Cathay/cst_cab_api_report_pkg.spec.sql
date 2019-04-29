create or replace package cst_cab_api_report_pkg is

procedure pos_epos_settlement_trans (
    o_xml                   out clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_start_date        in      date
  , i_end_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
);

procedure pos_epos_settlement_stat (
    o_xml                   out clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_start_date        in      date
  , i_end_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
);

procedure late_payment_charge (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_start_date     in     date
  , i_end_date       in     date
  , i_inst_id        in     com_api_type_pkg.t_inst_id  default null
);

procedure credit_card_bill_repayment (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_start_date     in     date
  , i_end_date       in     date
  , i_inst_id        in     com_api_type_pkg.t_inst_id  default null
);

function get_latest_redemption_type(
    i_account_id        in      com_api_type_pkg.t_account_id
)return com_api_type_pkg.t_name;

procedure loyalty_daily_redemption (
    o_xml                   out clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date                            default null
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
);

procedure loyalty_monthly_redemption (
    o_xml                   out clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date                            default null
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
);

function get_account_extra_limit(
    i_account_id        in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_money;

procedure credit_interest_charged(
    o_xml                   out clob
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_start_date        in      date                            default null
  , i_end_date          in      date                            default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
);

procedure credit_aging(
    o_xml                   out clob
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_start_date        in      date                            default null
  , i_end_date          in      date                            default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
);

procedure export_exceed_limit(
    o_xml                   out clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_object_id         in      com_api_type_pkg.t_medium_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
);

end cst_cab_api_report_pkg;
/
