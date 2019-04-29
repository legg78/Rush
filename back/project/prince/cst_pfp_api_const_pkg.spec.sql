create or replace package cst_pfp_api_const_pkg as

    BANNER_WELCOME_HEADER_LOGO               constant com_api_type_pkg.t_text           := 'WELCOME_HEADER_LOGO';
    BANNER_WELCOME_FOOTER_LOGO               constant com_api_type_pkg.t_text           := 'WELCOME_FOOTER_LOGO';

    DATE_FORMAT_MASK_COMMON                  constant com_api_type_pkg.t_name           := 'dd/mm/yyyy';
    DATE_FORMAT_MASK_EXPIRE_DATE             constant com_api_type_pkg.t_name           := 'mm/yyyy';

    CONTRACT_TYPE_DEBIT_INSTANT              constant com_api_type_pkg.t_dict_value     := 'CNTPINIC';
    DEFAULT_INST                             constant com_api_type_pkg.t_inst_id        := 1001;

    PRD_ATTR_DAILY_CWD_AMOUNT                constant com_api_type_pkg.t_name           := 'DAILY_CASH_WITHDRAWL_TOTAL_AMOUNT_ON_ATM_AND_POS';
    PRD_ATTR_SINGLE_CWD_AMOUNT               constant com_api_type_pkg.t_name           := 'ONE_TIME_CASH_WITHDRAWAL_ATM_POS';

    BUNCH_TYPE_ID_FROM                       constant com_api_type_pkg.t_tiny_id        := 7009;
    BUNCH_TYPE_ID_TO                         constant com_api_type_pkg.t_tiny_id        := 8300;

end cst_pfp_api_const_pkg;
/
