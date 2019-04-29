create or replace package cst_cab_api_const_pkg as
/*********************************************************
 *  Cathay custom API constants <br />
 *  Created by ChauHuynh (huynhv@bpcbt.com) at 17.07.2018 <br />
 *  Module: CST_CAB_API_CONST_PKG <br />
 *  @headcom
 **********************************************************/

DEFAULT_INST                        constant    com_api_type_pkg.t_inst_id      := 1001;
LOYALTY_CURR                        constant    com_api_type_pkg.t_curr_code    := '990';
CURRENCY_CODE_US_DOLLAR             constant    com_api_type_pkg.t_curr_code    := '840';
MACROS_CREDIT_OPERATION             constant    com_api_type_pkg.t_inst_id      := 1003;
MACROS_SPENT_LOYALTY_POINT          constant    com_api_type_pkg.t_inst_id      := 7004;
MACROS_MERCHANT_DEBIT_FEE           constant    com_api_type_pkg.t_inst_id      := 1015;
LOYALTY_REDEMPTION_CASHBACK         constant    com_api_type_pkg.t_dict_value   := 'OPTP0040';
LOYALTY_REDEMPTION_COUPON           constant    com_api_type_pkg.t_dict_value   := 'OPTP5001';
CARD_LOYALTY_SERVICE                constant    com_api_type_pkg.t_short_id     := 70000004;

RPT_DATE_FORMAT                     constant    com_api_type_pkg.t_name         := 'DD-MM-YYYY';
COUNTRY_CAMBODIA                    constant    com_api_type_pkg.t_country_code := '116';

ACCT_TYPE_LOYALTY                   constant    com_api_type_pkg.t_dict_value   := 'ACTPLOYT';
ACCT_TYPE_DPP_INSTALMENT            constant    com_api_type_pkg.t_dict_value   := 'ACTP1500';
FEE_TYPE_DPP_REGISTER               constant    com_api_type_pkg.t_name         := 'FETP0425';
CARD_FEE_TIER                       constant    com_api_type_pkg.t_name         := 'CST_CAB_CARD_FEE_TIER';
OPER_TYPE_MANUAL_PURCHASE           constant    com_api_type_pkg.t_dict_value   := 'OPTP0003';
OPER_TYPE_PAYMENT_CBS_DD            constant    com_api_type_pkg.t_dict_value   := 'OPTP7011';
OPER_TYPE_PAYMENT_MANUAL            constant    com_api_type_pkg.t_dict_value   := 'OPTP7033';

CONTACT_TYPE_SECONDARY              constant    com_api_type_pkg.t_dict_value   := 'CNTTSCNC';
BALANCE_TYPE_LOYALTY                constant    com_api_type_pkg.t_dict_value   := 'BLTP5001';
BALANCE_TYPE_COLLECTION             constant    com_api_type_pkg.t_dict_value   := 'BLTP1014';

end cst_cab_api_const_pkg;
/
