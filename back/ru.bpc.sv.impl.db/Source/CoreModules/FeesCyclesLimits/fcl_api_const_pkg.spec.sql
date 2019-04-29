create or replace package fcl_api_const_pkg as

    FEE_RATE_FLAT_PERCENTAGE        constant com_api_type_pkg.t_dict_value  := 'FEEM0001';
    FEE_RATE_FIXED_VALUE            constant com_api_type_pkg.t_dict_value  := 'FEEM0002';
    FEE_RATE_MIN_FIXED_PERCENT      constant com_api_type_pkg.t_dict_value  := 'FEEM0003';
    FEE_RATE_MAX_FIXED_PERCENT      constant com_api_type_pkg.t_dict_value  := 'FEEM0004';
    FEE_RATE_SUM_FIXED_PERCENT      constant com_api_type_pkg.t_dict_value  := 'FEEM0005';

    FEE_BASE_INCOMING_AMOUNT        constant com_api_type_pkg.t_dict_value  := 'FEEB0001';
    FEE_BASE_DIFF_THRESHOLD         constant com_api_type_pkg.t_dict_value  := 'FEEB0002';
    FEE_BASE_THRESHOLD              constant com_api_type_pkg.t_dict_value  := 'FEEB0003';
    FEE_BASE_TIRED_BASIS            constant com_api_type_pkg.t_dict_value  := 'FEEB0004';
    FEE_BASE_PREV_TURNOVER          constant com_api_type_pkg.t_dict_value  := 'FEEB0005';
    FEE_BASE_THRESHOLD_AMOUNT       constant com_api_type_pkg.t_dict_value  := 'FEEB0006';

    CYCLE_LENGTH_HOUR               constant com_api_type_pkg.t_dict_value  := 'LNGT0001';
    CYCLE_LENGTH_DAY                constant com_api_type_pkg.t_dict_value  := 'LNGT0002';
    CYCLE_LENGTH_WEEK               constant com_api_type_pkg.t_dict_value  := 'LNGT0003';
    CYCLE_LENGTH_MONTH              constant com_api_type_pkg.t_dict_value  := 'LNGT0004';
    CYCLE_LENGTH_YEAR               constant com_api_type_pkg.t_dict_value  := 'LNGT0005';
    CYCLE_LENGTH_MINUTE             constant com_api_type_pkg.t_dict_value  := 'LNGT0006';
    CYCLE_LENGTH_SECOND             constant com_api_type_pkg.t_dict_value  := 'LNGT0007';

    CYCLE_SHIFT_WEEK_DAY            constant com_api_type_pkg.t_dict_value  := 'CSHTWDAY';
    CYCLE_SHIFT_WORK_DAY            constant com_api_type_pkg.t_dict_value  := 'CSHTWRKD';
    CYCLE_SHIFT_PERIOD              constant com_api_type_pkg.t_dict_value  := 'CSHTPERD';
    CYCLE_SHIFT_MONTH_DAY           constant com_api_type_pkg.t_dict_value  := 'CSHTMDAY';
    CYCLE_SHIFT_END_MONTH           constant com_api_type_pkg.t_dict_value  := 'CSHTENDM';
    CYCLE_SHIFT_CERTAIN_YEAR        constant com_api_type_pkg.t_dict_value  := 'CSHTCRTY';

    ENTITY_TYPE_FEE_TYPE            constant com_api_type_pkg.t_dict_value  := 'ENTTFETP';
    ENTITY_TYPE_CYCLE_TYPE          constant com_api_type_pkg.t_dict_value  := 'ENTTCYTP';
    ENTITY_TYPE_LIMIT_TYPE          constant com_api_type_pkg.t_dict_value  := 'ENTTLMTP';

    ENTITY_TYPE_FEE                 constant com_api_type_pkg.t_dict_value  := 'ENTTFEES';
    ENTITY_TYPE_CYCLE               constant com_api_type_pkg.t_dict_value  := 'ENTTCYCL';
    ENTITY_TYPE_LIMIT               constant com_api_type_pkg.t_dict_value  := 'ENTTLIMT';
    
    TAX_INCLUSIVE                   constant com_api_type_pkg.t_dict_value  := 'TXIM0001';
    TAX_EXCLUSIVE                   constant com_api_type_pkg.t_dict_value  := 'TXIM0002';
    TAX_NOT_IMPLEMENTED             constant com_api_type_pkg.t_dict_value  := 'TXIM0003';

    FEE_CURRENCY_TYPE_BASE          constant com_api_type_pkg.t_dict_value  := 'FCCR0001';
    FEE_CURRENCY_TYPE_FEE           constant com_api_type_pkg.t_dict_value  := 'FCCR0002';

    ATTR_MISS_RISE_ERROR            constant com_api_type_pkg.t_dict_value  := 'TMAM0000';
    ATTR_MISS_STOP_EXECUTE          constant com_api_type_pkg.t_dict_value  := 'TMAM0001';
    ATTR_MISS_ZERO_VALUE            constant com_api_type_pkg.t_dict_value  := 'TMAM1001';
    ATTR_MISS_IGNORE                constant com_api_type_pkg.t_dict_value  := 'TMAM2001';
    ATTR_MISS_UNBOUNDED_VALUE       constant com_api_type_pkg.t_dict_value  := 'TMAM3001';
    ATTR_MISS_PROHIBITIVE_VALUE     constant com_api_type_pkg.t_dict_value  := 'TMAM3002';

    LIMIT_COUNT_PROHIBITIVE_VALUE   constant com_api_type_pkg.t_long_id := 0;
    LIMIT_COUNT_UNBOUNDED_VALUE     constant com_api_type_pkg.t_long_id := -1;
    LIMIT_SUM_PROHIBITIVE_VALUE     constant com_api_type_pkg.t_money := 0;
    LIMIT_SUM_UNBOUNDED_VALUE       constant com_api_type_pkg.t_money := -1;

    FEE_TYPE_STATUS_KEY             constant com_api_type_pkg.t_dict_value := 'FETP';

    START_DATE_CURRENT_DATE         constant com_api_type_pkg.t_dict_value  := 'CYSD0001';
    START_DATE_PREV_END_DATE        constant com_api_type_pkg.t_dict_value  := 'CYSD0002';

    DATE_TYPE_DICTIONARY_TYPE       constant com_api_type_pkg.t_dict_value  := 'DICTCYDT';
    DATE_TYPE_SYSTEM_DATE           constant com_api_type_pkg.t_dict_value  := 'CYDT0001';
    DATE_TYPE_SETTLEMENT_DATE       constant com_api_type_pkg.t_dict_value  := 'CYDT0002';

    CHECK_TYPE_OR                   constant com_api_type_pkg.t_dict_value  := 'LCHT0001';
    CHECK_TYPE_AND                  constant com_api_type_pkg.t_dict_value  := 'LCHT0002';

    ALG_CALC_LIMIT_WITHDRAW_CREDIT  constant com_api_type_pkg.t_dict_value  := 'ACCL0001';
    ALG_CALC_LIMIT_SPENDING_CARD    constant com_api_type_pkg.t_dict_value  := 'ACCL0002';
    ALG_CALC_LIMIT_SPENDING_CUST    constant com_api_type_pkg.t_dict_value  := 'ACCL0003';
    ALG_CALC_LIMIT_THRESHOLD_MOD    constant com_api_type_pkg.t_dict_value  := 'ACCL0004';
    ALG_CALC_LIMIT_WTHDRW_LESS_FEE  constant com_api_type_pkg.t_dict_value  := 'ACCL0005';
    ALG_CALC_LIMIT_SPEND_CUS_INTER  constant com_api_type_pkg.t_dict_value  := 'ACCL0006';

    ALG_NUMBER_DAYS_OF_YEAR_360     constant com_api_type_pkg.t_dict_value  := 'NDYR0001';
    ALG_NUMBER_DAYS_OF_YEAR_365     constant com_api_type_pkg.t_dict_value  := 'NDYR0002';
    ALG_NUMBER_DAYS_OF_YEAR_FACT    constant com_api_type_pkg.t_dict_value  := 'NDYR0003';
    
    ALG_MONTH_EXP_CALC_NOMINAL      constant com_api_type_pkg.t_dict_value  := 'NRCAMNEX';

    LIMIT_USAGE_SUM_COUNT           constant com_api_type_pkg.t_dict_value  := 'LIMUCTSM';
    LIMIT_USAGE_COUNT_ONLY          constant com_api_type_pkg.t_dict_value  := 'LIMUOCNT';
    LIMIT_USAGE_SUM_ONLY            constant com_api_type_pkg.t_dict_value  := 'LIMUOSUM';

end;
/
