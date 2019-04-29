create or replace package cst_pvc_api_const_pkg as
/************************************************************
 * PVCom custom API constants                              <br />
 * Created by ChauHuynh (huynh@bpcbt.com) at 24.08.2018  $ <br />
 * Module: CST_PVC_API_CONST_PKG                           <br />
 * @headcom
 ************************************************************/

DEFAULT_INST                        constant    com_api_type_pkg.t_inst_id      := 1001;
CST_PRT_DATE_FORMAT                 constant    com_api_type_pkg.t_name         := 'DD/MM/YYYY';
MACROS_DEBIT_OPR                    constant    com_api_type_pkg.t_network_id   := 1004;

end cst_pvc_api_const_pkg;
/
