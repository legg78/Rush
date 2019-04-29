create or replace package cst_woo_prc_incoming_pkg as
pragma serially_reusable;
/************************************************************
 * Import batch files from Woori bank CBS <br />
 * Created by:
    Chau Huynh (huynh@bpcbt.com)
    Man Do     (m.do@bpcbt.com)  at 2017-03-03     <br />
 * Last changed by $Author: Chau Huynh           $ <br />
 * $LastChangedDate:        2017-04-14 10:00     $ <br />
 * Revision: $LastChangedRevision:  11           $ <br />
 * Module: CST_WOO_PRC_INCOMING_PKG                <br />
 * @headcom
 *************************************************************/
/*
 * Payment infomation
 */
procedure process_f59(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Excess amount that can not be transferred to a virtual account
 */
procedure process_f65(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Load Exchange Rate Information from CBS
 */
procedure process_f67(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Load Debit Card refund response from CBS (response to file 66)
 */
procedure process_f68(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Load Employee Information from CBS
 */
procedure process_f70(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Receiving the result of depositing a point into an account
 */
procedure process_f73(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Customer information loaded from CBS (will be updated in BO)
 */
procedure process_f77(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Cash advance and check approval comparison
 */
procedure process_f78(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Customer accident information from CBS to SV
 */
procedure process_f79(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Card delivery status is updated to issured
 */
procedure process_f127(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Card delivery status is updated to Delivering
 */
procedure process_f128(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Load Bank Overdue from CBS
 */
procedure process_f129(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Load Virtual account from CBS
 */
procedure process_f130(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Account Closure – Prepaid card and Debit Account - received data from CBS
 */
procedure process_f136(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Load Debit card account level offline fees from CBS
 */
procedure process_f138(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

/*
 * Load GL adjustments from CBS
 */
procedure process_f140(
    i_inst_id         in com_api_type_pkg.t_inst_id default null
);

end cst_woo_prc_incoming_pkg;
/
