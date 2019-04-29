create or replace package cst_nbrt_api_const_pkg as

MODULE_CODE_NBRT                constant com_api_type_pkg.t_module_code  := 'NBT';

NBRT_INST                       constant com_api_type_pkg.t_inst_id      := 5016;
NBRT_NETWORK_ID                 constant com_api_type_pkg.t_tiny_id      := 5016;
NBRT_RATE_TYPE                  constant com_api_type_pkg.t_dict_value   := 'RTTPNBRT';

TAJIKISTAN_CURRENCY_CODE        constant com_api_type_pkg.t_curr_code    := '972'; -- TJS - Tajikistan Somoni

TAJIKISTAN_COUNTRY_CODE         constant com_api_type_pkg.t_country_code := '762';

ARRAY_ID_PURCHASE               constant com_api_type_pkg.t_medium_id  := -50000018;
ARRAY_ID_CASH                   constant com_api_type_pkg.t_medium_id  := -50000019;
ARRAY_ID_ON_US                  constant com_api_type_pkg.t_medium_id  := -50000020;
ARRAY_ID_ON_THEM                constant com_api_type_pkg.t_medium_id  := -50000021;
ARRAY_ID_NETWORK                constant com_api_type_pkg.t_medium_id  := -50000022;

end;
/
