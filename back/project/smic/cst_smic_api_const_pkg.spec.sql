create or replace package cst_smic_api_const_pkg is
/*********************************************************
*  SMIC custom constants <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 01.03.2019 <br />
*  Module: CST_SMIC_API_CONST_PKG <br />
*  @headcom
**********************************************************/

INSTITUTE_GL_TRN_ACCOUNT        com_api_type_pkg.t_dict_value := 'ACTPGLIN'; 
INSTITUTE_GL_FEE_ACCOUNT        com_api_type_pkg.t_dict_value := 'ACTPGLFE';

ACH_ACCOUNT_INST_PARAM          com_api_type_pkg.t_attr_name  := 'ACH_ACCOUNT';
BIC_INST_PARAM                  com_api_type_pkg.t_attr_name  := 'BIC';
TRAN_TTC_SYSTEM_PARAM           com_api_type_pkg.t_attr_name  := 'TRAN_TTC';
CURRENCY_CHAR_SYSTEM_PARAM      com_api_type_pkg.t_attr_name  := 'CURRENCY_CHAR';
SENDER_IDN_SYSTEM_PARAM         com_api_type_pkg.t_attr_name  := 'SENDER_ADDRES';
RECIEVER_IDN_SYSTEM_PARAM       com_api_type_pkg.t_attr_name  := 'LOGICAL_TERM_ADDR';
 
end cst_smic_api_const_pkg;
/
