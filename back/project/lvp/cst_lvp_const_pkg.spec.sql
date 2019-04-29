create or replace package cst_lvp_const_pkg as

ARRAY_FEE_MACROS_TYPE          constant com_api_type_pkg.t_short_id        := -50000025;
ARRAY_DEBIT_FEE_MACROS_TYPE    constant com_api_type_pkg.t_short_id        := -50000026;
ARRAY_CREDIT_FEE_MACROS_TYPE   constant com_api_type_pkg.t_short_id        := -50000027;
ARRAY_CARDHLDR_CR_MACROS_TYPE  constant com_api_type_pkg.t_short_id        := -50000028;

LIMIT_TYPE_CARD_CREDIT         constant com_api_type_pkg.t_dict_value      := 'LMTP0131';
LIMIT_TYPE_CARD_CASH           constant com_api_type_pkg.t_dict_value      := 'LMTP0143';

DEBT_LEVEL_1                   constant com_api_type_pkg.t_dict_value      := 'DBTL0001';
DEBT_LEVEL_2                   constant com_api_type_pkg.t_dict_value      := 'DBTL0002';
DEBT_LEVEL_3                   constant com_api_type_pkg.t_dict_value      := 'DBTL0003';
DEBT_LEVEL_4                   constant com_api_type_pkg.t_dict_value      := 'DBTL0004';

PMO_STATUS_NOT_PAID            constant com_api_type_pkg.t_dict_value      := 'POSA5001';
BUNCH_GL_ROUTING               constant com_api_type_pkg.t_name            := 'BUNCH_GL_ROUTING';

DEBT_LEVEL_FLEXIBLE_FIELD      constant com_api_type_pkg.t_name            := 'CST_LVP_ACC_DEBT_LEVEL';

end cst_lvp_const_pkg;
/
