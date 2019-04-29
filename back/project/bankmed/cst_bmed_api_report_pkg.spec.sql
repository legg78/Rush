create or replace package cst_bmed_api_report_pkg as
/*********************************************************
*  BankMed custom reports <br />
*  Created by Alalykin A. (alalykin@bpcbt.com) at 31.01.2017 <br />
*  Module: cst_bmed_api_report_pkg <br />
*  @headcom
**********************************************************/

/*
 * The report displays chargeback cases/applications for an ISSUER by specified
 * report period, IPS, and case status (application status).
 * Note: list of dispute application flows is defined in according to LOV app_api_const_pkg.LOV_ID_DISPUTE_FLOWS.
 * @i_ips              - value from dictionary RIPS, null value is considered as any IPS
 * @i_status           - case/application status, null value is considered as any possible status
 */
procedure issuing_chargeback_disputes(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_ips               in     com_api_type_pkg.t_dict_value
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * The report displays chargeback cases/applications for an ACQUIRER by specified
 * report period, IPS, and case status (application status).
 * Note: list of dispute application flows is defined in according to LOV app_api_const_pkg.LOV_ID_DISPUTE_FLOWS.
 * @i_ips              - value from dictionary RIPS, null value is considered as any IPS
 * @i_status           - case/application status, null value is considered as any possible status
 */
procedure acquring_chargeback_disputes(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_ips               in     com_api_type_pkg.t_dict_value
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_lang              in     com_api_type_pkg.t_dict_value
);

/*
 * The report displays merchant's transactions and terminal/installation fees).
 */
procedure merchant_statement(
    o_xml                  out clob
  , i_merchant_id       in     com_api_type_pkg.t_short_id
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure credit_statement_with_loyalty(
    o_xml                  out  clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_invoice_id        in      com_api_type_pkg.t_medium_id
);

end;
/
