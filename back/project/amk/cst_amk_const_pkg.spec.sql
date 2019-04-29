create or replace package cst_amk_const_pkg as

    -- Array with macros types for fee sharing:
    ARRAY_FEE_SHARING_MACROS_TYPES         constant com_api_type_pkg.t_short_id        := -50000060;

    CONTRACT_TYPE_AGNT                    constant com_api_type_pkg.t_dict_value      := 'CNTPAGNT';
    CONTRACT_TYPE_PMAG                    constant com_api_type_pkg.t_dict_value      := 'CNTPPMAG';
    CONTRACT_TYPE_PMPR                    constant com_api_type_pkg.t_dict_value      := 'CNTPPMPR';

    ACCOUNT_TYPE_BILL                      constant com_api_type_pkg.t_dict_value      := 'ACTPBILL';
    ACCOUNT_TYPE_AGTE                      constant com_api_type_pkg.t_dict_value      := 'ACTPAGTE';
    ACCOUNT_TYPE_EXPE                      constant com_api_type_pkg.t_dict_value      := 'ACTPEXPE';

    EXTERNAL_ACCOUNT_TYPE_GL               constant com_api_type_pkg.t_short_desc      := 'GL';
    EXTERNAL_ACCOUNT_TYPE_AGENT            constant com_api_type_pkg.t_short_desc      := 'AGENT';
    EXTERNAL_ACCOUNT_TYPE_BILLER           constant com_api_type_pkg.t_short_desc      := 'BILLER';
    EXTERNAL_ACCOUNT_TYPE_AGGR             constant com_api_type_pkg.t_short_desc      := 'AGGREGATOR';
    EXTERNAL_ACCOUNT_TYPE_OTHER            constant com_api_type_pkg.t_short_desc      := 'OTHER';

    DEBIT                                  constant com_api_type_pkg.t_short_desc      := 'D';
    CREDIT                                 constant com_api_type_pkg.t_short_desc      := 'C';

end cst_amk_const_pkg;
/
