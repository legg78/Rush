create or replace package cst_bmed_api_const_pkg as
/*********************************************************
*  BankMed custom API constants <br />
*  Created by Alalykin A. (alalykin@bpcbt.com) at 04.02.2017 <br />
*  Module: CST_BMED_API_CONST_PKG <br />
*  @headcom
**********************************************************/

REPORT_IPS_VISA                  constant com_api_type_pkg.t_dict_value     := 'RIPSVISA';
REPORT_IPS_MASTERCARD            constant com_api_type_pkg.t_dict_value     := 'RIPSMCRD';

PMO_STATUS_NOT_PAID              constant com_api_type_pkg.t_dict_value     := 'POSA5001';
POSINP_OPER_ARRAY_TYPE_ID        constant com_api_type_pkg.t_tiny_id        := 1017;
POSINP_OPER_ARRAY_ID             constant com_api_type_pkg.t_short_id       := -50000024;

FREE_GATEWAY_FILE_TYPE           constant com_api_type_pkg.t_dict_value     := 'BMGWFGWF';  -- Free Gateway File
MONTHLY_FEE_FILE_TYPE            constant com_api_type_pkg.t_dict_value     := 'BMGWMFEE';  -- Monthly Maintenance Fees File
RECHARGE_GATEWAY_FILE_TYPE       constant com_api_type_pkg.t_dict_value     := 'BMGWRSGW';  -- Recharge Services Gateway File

LBPOUND                          constant com_api_type_pkg.t_curr_code      := '422';

FE_ACC_STATUS_ARRAY_TYPE_ID      constant com_api_type_pkg.t_tiny_id        := 1077;
FE_ACC_STATUS_ARRAY_ID           constant com_api_type_pkg.t_short_id       := -50000062;

BAL_REF_FILE_UPLOAD_EVNT_TYPE    constant com_api_type_pkg.t_dict_value     := 'EVNT5103';

end;
/
