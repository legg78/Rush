create or replace package way_api_const_pkg as
/*********************************************************
*  Visa API constants <br />
*  Created by Dolgikh D.(dolgikh@bpcbt.com)  at 12.07.2016 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: vis_api_const_pkg <br />
*  @headcom
**********************************************************/

MSG_RET_PRESENTMENT_REV              constant varchar2(32) := 'DpR--00-';
MSG_RET_PRESENTMENT                  constant varchar2(32) := 'DpP--00-';
MSG_ATM_PRESENTMENT                  constant varchar2(32) := 'DpP--01 -';
MSG_ATM_PRESENTMENT_REV              constant varchar2(32) := 'DpR--01 -';
MSG_CH_DB_PRESENTMENT_REV            constant varchar2(32) := 'DpR--1X-';
MSG_CH_DB_PRESENTMENT                constant varchar2(32) := 'DpP--1X-';
MSG_CASH_PRESENTMENT_REV             constant varchar2(32) := 'DpR--12-';
MSG_CASH_PRESENTMENT                 constant varchar2(32) := 'DpP--12-';
MSG_CREDIT_PRESENTMENT               constant varchar2(32) := 'DpP--20-';
MSG_CREDIT_PRESENTMENT_REV           constant varchar2(32) := 'DpR--20-';

MSG_CREDIT_FULFILMENT                constant varchar2(32) := 'QRP--20-';
MSG_DEBIT_FULFILMENT                 constant varchar2(32) := 'QRP--1X-';
MSG_RET_CHARGEBACK                   constant varchar2(32) := 'DcP--00-';
MSG_CREDIT_CHARGEBACK                constant varchar2(32) := 'DcP--20-';
MSG_CASH_CHARGEBACK                  constant varchar2(32) := 'DcP--12-';
MSG_RET_CHARGEBACK_REV               constant varchar2(32) := 'DcR--00-';
MSG_CREDIT_CHARGEBACK_REV            constant varchar2(32) := 'DcR--20-';
MSG_CASH_CHARGEBACK_REV              constant varchar2(32) := 'DcR--12-';
MSG_FEE_COL_PRESENTMENT              constant varchar2(32) := 'FpP--1Z-';
MSG_FUNDS_DISB_PRESENTMENT           constant varchar2(32) := 'FpP--2Z-';

FILE_TYPE_CLEARING_WAY4              constant com_api_type_pkg.t_dict_value := 'FLTPWAY4';
WAY4_DIALECT                         constant com_api_type_pkg.t_name       := 'WAY4_DIALECT';
WAY4_CMID                            constant com_api_type_pkg.t_name       := 'WAY4_CMID';
WAY4_SENDER                          constant com_api_type_pkg.t_name       := 'WAY4_SENDER_ID';
WAY4_RECEIVER                        constant com_api_type_pkg.t_name       := 'WAY4_RECEIVER_ID';
WAY4_FORMAT_VERSION                  constant com_api_type_pkg.t_name       := 'WAY4_FORMAT_VERSION';

WAY4_MCC_GROUP_REFERENCE             constant com_api_type_pkg.t_short_id   := 10000097;
WAY4_MESSAGE_CODES                   constant com_api_type_pkg.t_short_id   := 10000098;
WAY4_FILE_NAMING_ID                  constant com_api_type_pkg.t_tiny_id    := 1313;

WAY4_STANDARD                        constant com_api_type_pkg.t_tiny_id    := 1036;

end way_api_const_pkg;
/
