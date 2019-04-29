create or replace package csm_api_report_pkg is
/**********************************************************
 * Create reports for disputes <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 06.12.2016 <br />
 * Module: CSM_API_REPORT_PKG
 * @headcom
 **********************************************************/

procedure create_notification_report(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
);

/*
 * Procedure gather dispute application data for generating a report.
 */
procedure dispute_application_data(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * Procedure gather dispute application data for generating a report  with date.
 */
procedure dispute_application_data_date(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_actual_date       in     date
);

/*
 * Procedure gather dispute application data for generating a repor with amount.
 */
procedure dispute_application_data_amnt(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_amount            in     com_api_type_pkg.t_money
);

/*
 * Procedure gather dispute application data for generating a repor with denominations.
 */
procedure dispute_application_data_denom(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_denom1            in     com_api_type_pkg.t_long_id
  , i_denom2            in     com_api_type_pkg.t_long_id
);

/*
 * Procedure gather dispute application data for generating a repor with text.
 */
procedure dispute_application_data_text(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_text              in     com_api_type_pkg.t_full_desc
);

/*
 * Procedure gather dispute application data for generating a repor with attached docs.
 */
procedure dispute_application_data_docs(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value  
);

/*
 * Procedure gather dispute application data for generating a repor with manager.
 */
procedure dispute_application_data_mgr(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_title             in     com_api_type_pkg.t_dict_value
  , i_name              in     com_api_type_pkg.t_name
);

/*
 * The report displays a number of new created issuing cases grouped by specified period, IPS, and case category.
 */
procedure new_issuing_cases(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * The report displays a number and total amount of incoming representments and outgoing
 * (arbitration )chargebacks processed by the issuer and grouped by message types and IPS.
 */
procedure issuing_items_grouped(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * The report displays a number and total amount of outgoing representments and incoming
 * (arbitration )chargebacks processed by the acquirer and grouped by message types and IPS.
 */
procedure acquiring_items_grouped(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure issuing_items_not_grouped(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure acquiring_items_not_grouped(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure issuing_chargebacks_grouped(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure acquiring_chargebacks_grouped(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * The report displays detail information about retrieval requests for both
 * an acquirer (incoming) and an issuer (outgoing) without grouping.
 */
procedure retrieval_requests_daily(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * The report displays a number and total amount of retrieval requests for both
 * an acquirer (incoming) and an issuer (outgoing) grouped by dispute side and IPS.
 */
procedure retrieval_requests_monthly(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * The report displays final accounting entries that may be qualified as
 * 'Credit card account' and 'Debit merchant/ATM account'.
 * Field <period> is formatted in according to csm_api_const_pkg.GROUPING_PERIOD_DAY.
 */
procedure accounting_transactions_day(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * The report displays final accounting entries that may be qualified as
 * 'Credit card account' and 'Debit merchant/ATM account'.
 * Field <period> is formatted in according to csm_api_const_pkg.GROUPING_PERIOD_MONTH.
 */
procedure accounting_transactions_month(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);


/*
 * The report displays acquirer cases assigned to the particular team
 */
procedure cases_by_team_acq(
    o_xml                  out clob
  , i_team              in     com_api_type_pkg.t_tiny_id
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

/*
 * The report displays issuing cases assigned to the particular team
 */
procedure cases_by_team_iss(
    o_xml                  out clob
  , i_team              in     com_api_type_pkg.t_tiny_id
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

/*
 * The report displays late presented transaction (acquirer)
 */
procedure late_presented_trans_acq(
    o_xml                  out clob
  , i_count_days        in     com_api_type_pkg.t_tiny_id
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_card_type_id      in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

/*
 * The report displays late presented transaction (issuer)
 */
procedure late_presented_trans_iss(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

/*
 * The report displays duplicated transaction (issuer)
 */
procedure duplicated_transaction_iss(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

/*
 * The report displays duplicated transaction (acquirer)
 */
procedure duplicated_transaction_acq(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_date              in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

end;
/
