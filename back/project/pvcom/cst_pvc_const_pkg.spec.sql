create or replace package cst_pvc_const_pkg as
/************************************************************
 * All constants for PVCom bank custom packages <br />
 * Created by Man Do(m.do@bpcbt.com) at 12.09.2018 <br />
 * Module: CST_PVC_CONST_PKG <br />
 * @headcom
 ************************************************************/

    MACROS_TYPE_ID_DEBIT_ON_OPER        constant com_api_type_pkg.t_tiny_id     := 1004;
    MACROS_TYPE_ID_DEBIT_FEE            constant com_api_type_pkg.t_tiny_id     := 1007;
    MACROS_TYPE_ID_DPP_PRINCIPAL        constant com_api_type_pkg.t_tiny_id     := 1025;
    MACROS_TYPE_ID_DPP_INTEREST         constant com_api_type_pkg.t_tiny_id     := 7013;

    PMO_PARAM_TOTAL_AMNT_FOR_CUST       constant com_api_type_pkg.t_name        := 'CST_CBS_TOTAL_AMOUNT_FOR_CUSTOMER';

end cst_pvc_const_pkg;
/
