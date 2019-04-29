create or replace package cst_bsm_api_report_pkg is
/**********************************************************
 * API for Banco Santander Mexico reports <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 15.02.2017 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_CCS_API_REPORT_PKG
 * @headcom
 **********************************************************/
procedure acquirer_operations_for_period(
    o_xml           out clob
  , i_lang           in com_api_type_pkg.t_dict_value default null
  , i_inst_id        in com_api_type_pkg.t_inst_id
  , i_currency       in com_api_type_pkg.t_curr_code
  , i_rate_type      in com_api_type_pkg.t_dict_value
  , i_operation_type in com_api_type_pkg.t_dict_value
  , i_start_date     in date
  , i_end_date       in date
);

end cst_bsm_api_report_pkg;
/
