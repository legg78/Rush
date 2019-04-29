create or replace package cst_apc_const_pkg as
/*********************************************************
*  Asia Pacific specific constants <br />
*  Created by Alalykin A. (alalykin@bpcbt.com) at 20.12.2018 <br />
*  Module: CST_APC_CONST_PKG <br />
*  @headcom
**********************************************************/

FLEX_FIELD_EXTRA_MAD                constant com_api_type_pkg.t_name            := 'CST_CRD_EXTRA_MAD';
FLEX_FIELD_EXTRA_DUE_DATE           constant com_api_type_pkg.t_name            := 'CST_CRD_EXTRA_DUE_DATE';
FLEX_FIELD_SKIP_MAD_DATE            constant com_api_type_pkg.t_name            := 'CST_CRD_SKIP_MAD_DATE';

NEW_ACCOUNT_SKIP_MAD_WINDOW         constant com_api_type_pkg.t_name            := 'CST_CRD_NEW_ACCOUNT_SKIP_MAD_WINDOW';
REPAYMENT_SKIP_MAD_WINDOW           constant com_api_type_pkg.t_name            := 'CST_CRD_REPAYMENT_SKIP_MAD_WINDOW';
EXTRA_DUE_DATE                      constant com_api_type_pkg.t_name            := 'CST_CRD_EXTRA_DUE_DATE';
EXTRA_DUE_DATE_CYCLE_TYPE           constant com_api_type_pkg.t_dict_value      := 'CYTP1013';

ALGORITHM_MAD_CALC_TWO_MADS         constant com_api_type_pkg.t_dict_value      := 'MADATWOM';
DAILY_MAD_AMOUNT                    constant com_api_type_pkg.t_name            := 'CRD_DAILY_MAD_AMOUNT';

ROUNDING_ALGO_MATH                  constant com_api_type_pkg.t_dict_value      := '50040001';
ROUNDING_ALGO_TRUNC                 constant com_api_type_pkg.t_dict_value      := '50040002';
ROUNDING_ALGO_CEIL                  constant com_api_type_pkg.t_dict_value      := '50040003';

FEE_TYPE_CARD_ANNUAL                constant com_api_type_pkg.t_dict_value      := 'FETP0102';

ALG_CALC_LIMIT_WITHDRAW_CREDIT      constant com_api_type_pkg.t_dict_value      := 'ACCL5001';

CUSTOM_ID_START_TINY                constant com_api_type_pkg.t_tiny_id         := 5000;
CUSTOM_ID_START_SHORT               constant com_api_type_pkg.t_tiny_id         := 50000000;


end cst_apc_const_pkg;
/
