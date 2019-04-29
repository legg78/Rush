create or replace package crd_api_const_pkg as

    CREATE_DEBT_EVENT                   constant com_api_type_pkg.t_dict_value := 'EVNT1001';
    INTEREST_CHARGING_EVENT             constant com_api_type_pkg.t_dict_value := 'EVNT1002';
    APPLY_PAYMENT_EVENT                 constant com_api_type_pkg.t_dict_value := 'EVNT1003';
    OVERPAYMENT_EVENT                   constant com_api_type_pkg.t_dict_value := 'EVNT1004';
    OVERDUE_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1005';
    OVERLIMIT_EVENT                     constant com_api_type_pkg.t_dict_value := 'EVNT1006';
    ENABLE_CREDIT_EVENT                 constant com_api_type_pkg.t_dict_value := 'EVNT1007';
    DISABLE_CREDIT_EVENT                constant com_api_type_pkg.t_dict_value := 'EVNT1008';
    PAY_OFF_CREDIT                      constant com_api_type_pkg.t_dict_value := 'EVNT1009';
    AGING_EVENT                         constant com_api_type_pkg.t_dict_value := 'EVNT1010';
    AGING_0_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1030';
    AGING_1_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1011';
    AGING_2_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1012';
    AGING_3_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1013';
    AGING_4_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1014';
    AGING_5_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1015';
    AGING_6_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1023';
    AGING_7_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1024';
    AGING_8_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1025';
    AGING_9_EVENT                       constant com_api_type_pkg.t_dict_value := 'EVNT1026';
    AGING_10_EVENT                      constant com_api_type_pkg.t_dict_value := 'EVNT1027';
    AGING_11_EVENT                      constant com_api_type_pkg.t_dict_value := 'EVNT1028';
    AGING_12_EVENT                      constant com_api_type_pkg.t_dict_value := 'EVNT1029';
    AGING_13_EVENT                      constant com_api_type_pkg.t_dict_value := 'EVNT1031';
    MAD_REPAYMENT_EVENT                 constant com_api_type_pkg.t_dict_value := 'EVNT1016';
    TAD_REPAYMENT_EVENT                 constant com_api_type_pkg.t_dict_value := 'EVNT1017';
    INVOICE_CREATION_EVENT              constant com_api_type_pkg.t_dict_value := 'EVNT1018';
    DEBT_IN_COLLECTION_EVENT            constant com_api_type_pkg.t_dict_value := 'EVNT1019';
    DEBT_MIGRATION_EVENT                constant com_api_type_pkg.t_dict_value := 'EVNT1020';
    INCREASE_LIMIT_EVENT                constant com_api_type_pkg.t_dict_value := 'EVNT1021';
    CANCEL_PAYMENT_EVENT                constant com_api_type_pkg.t_dict_value := 'EVNT1022';
    NON_OVERDUE_EVENT                   constant com_api_type_pkg.t_dict_value := 'EVNT1034';
    PUNISHED_EVENT                      constant com_api_type_pkg.t_dict_value := 'EVNT1954';

    DEBT_STATUS_ACTIVE                  constant com_api_type_pkg.t_dict_value := 'DBTSACTV';
    DEBT_STATUS_PAID                    constant com_api_type_pkg.t_dict_value := 'DBTSPAID';
    DEBT_STATUS_COLLECT                 constant com_api_type_pkg.t_dict_value := 'DBTSINCL';
    DEBT_STATUS_SUSPENDED               constant com_api_type_pkg.t_dict_value := 'DBTSSSPN';
    DEBT_STATUS_CANCELED                constant com_api_type_pkg.t_dict_value := 'DBTSCNCL';

    PAYMENT_STATUS_ACTIVE               constant com_api_type_pkg.t_dict_value := 'PMTSACTV';
    PAYMENT_STATUS_SPENT                constant com_api_type_pkg.t_dict_value := 'PMTSSPNT';

    INTEREST_RATE_FEE_TYPE              constant com_api_type_pkg.t_dict_value := 'FETP1001';
    MAD_PERCENTAGE_FEE_TYPE             constant com_api_type_pkg.t_dict_value := 'FETP1002';
    PENALTY_RATE_FEE_TYPE               constant com_api_type_pkg.t_dict_value := 'FETP1003';
    LIMIT_VALUE_FEE_TYPE                constant com_api_type_pkg.t_dict_value := 'FETP1004';
    PROVIDE_LIMIT_FEE_TYPE              constant com_api_type_pkg.t_dict_value := 'FETP1005';
    CHANGE_LIMIT_FEE_TYPE               constant com_api_type_pkg.t_dict_value := 'FETP1006';
    MINIMUM_MAD_FEE_TYPE                constant com_api_type_pkg.t_dict_value := 'FETP1007';
    MAD_TOLERANCE_FEE_TYPE              constant com_api_type_pkg.t_dict_value := 'FETP1008';
    TAD_TOLERANCE_FEE_TYPE              constant com_api_type_pkg.t_dict_value := 'FETP1009';
    CREDIT_SERVICING_FEE_TYPE           constant com_api_type_pkg.t_dict_value := 'FETP1010';
    GRACE_REPAYMENT_FEE_TYPE            constant com_api_type_pkg.t_dict_value := 'FETP1011';
    GRACE_INTEREST_FEE_TYPE             constant com_api_type_pkg.t_dict_value := 'FETP1012';
    ADDIT_INTEREST_RATE_FEE_TYPE        constant com_api_type_pkg.t_dict_value := 'FETP1013';
    CRD_INV_CREATE_THRSHD_FEE_TYPE      constant com_api_type_pkg.t_dict_value := 'FETP1015';
    EXTRA_MAD_FEE_TYPE                  constant com_api_type_pkg.t_dict_value := 'FETP1016';
    PROMO_INTEREST_RATE_FEE_TYPE        constant com_api_type_pkg.t_dict_value := 'FETP1019';
    MAD_THRESHOLD_FEE_TYPE              constant com_api_type_pkg.t_dict_value := 'FETP1018';

    INVOICING_PERIOD_CYCLE_TYPE         constant com_api_type_pkg.t_dict_value := 'CYTP1001';
    GRACE_PERIOD_CYCLE_TYPE             constant com_api_type_pkg.t_dict_value := 'CYTP1002';
    DUE_DATE_CYCLE_TYPE                 constant com_api_type_pkg.t_dict_value := 'CYTP1003';
    PENALTY_PERIOD_CYCLE_TYPE           constant com_api_type_pkg.t_dict_value := 'CYTP1004';
    INTEREST_CHARGE_CYCLE_TYPE          constant com_api_type_pkg.t_dict_value := 'CYTP1005';
    FORCE_INT_CHARGE_CYCLE_TYPE         constant com_api_type_pkg.t_dict_value := 'CYTP1006';
    CREDIT_SERV_FEE_CYCLE_TYPE          constant com_api_type_pkg.t_dict_value := 'CYTP1007';
    OVERDUE_DATE_CYCLE_TYPE             constant com_api_type_pkg.t_dict_value := 'CYTP1008';
    WAIVE_INTEREST_CYCLE_TYPE           constant com_api_type_pkg.t_dict_value := 'CYTP1009';
    ZERO_PERIOD_CYCLE                   constant com_api_type_pkg.t_dict_value := 'CYTP1011';
    PERIODIC_INTEREST_CHARGE            constant com_api_type_pkg.t_dict_value := 'CYTP1012';
    INCREASE_CREDIT_LIMIT_PERIOD        constant com_api_type_pkg.t_dict_value := 'CYTP1015';
    AGING_PERIOD_CYCLE_TYPE             constant com_api_type_pkg.t_dict_value := 'CYTP1016';
    PROMOTIONAL_PERIOD_CYCLE_TYPE       constant com_api_type_pkg.t_dict_value := 'CYTP1018';

    ACCOUNT_CASH_VALUE_LIMIT_TYPE       constant com_api_type_pkg.t_dict_value := 'LMTP0408';

    TRUNCATION_TYPE_MONHTLY             constant com_api_type_pkg.t_dict_value := 'TRTPMNTH';
    TRUNCATION_TYPE_DUE_DATE            constant com_api_type_pkg.t_dict_value := 'TRTPDUE1';
    TRUNCATION_TYPE_DUE_DATE_2          constant com_api_type_pkg.t_dict_value := 'TRTPDUE2';

    REPAYMENT_PRIORITY                  constant com_api_type_pkg.t_name       := 'CRD_REPAYMENT_PRIORITY';
    GRACE_PERIOD_ENABLE                 constant com_api_type_pkg.t_name       := 'CRD_GRACE_PERIOD_ENABLE';
    FLOATING_INVOICE_PERIOD             constant com_api_type_pkg.t_name       := 'CRD_FLOATING_INVOICE_PERIOD';
    PAYMENT_CONDITION                   constant com_api_type_pkg.t_name       := 'CRD_REPAYMENT_CONDITION';
    USE_OWN_FUNDS                       constant com_api_type_pkg.t_name       := 'CRD_USE_OWN_FUNDS';
    CHARGE_PENALTY                      constant com_api_type_pkg.t_name       := 'CRD_CHARGE_PENALTY';
    INTEREST_CALC_START_DATE            constant com_api_type_pkg.t_name       := 'CRD_INTEREST_CALC_START_DATE';
    INTEREST_START_DATE_TRANSFORM       constant com_api_type_pkg.t_name       := 'CRD_INTEREST_START_DATE_TRANSFORMATION';
    REPAY_MAD_FIRST                     constant com_api_type_pkg.t_name       := 'CRD_REPAY_MAD_FIRST';
    ADDITIONAL_INTEREST_RATE            constant com_api_type_pkg.t_name       := 'CRD_ADDITIONAL_INTEREST_RATE';
    ALGORITHM_CALC_INTEREST             constant com_api_type_pkg.t_name       := 'CRD_ALGORITHM_CALC_INTEREST';
    CHARGE_INTR_BEFORE_PAYMENT          constant com_api_type_pkg.t_name       := 'CRD_CHARGE_INTR_BEFORE_PAYMENT';
    PAYMENT_REV_PROC_METHOD             constant com_api_type_pkg.t_name       := 'CRD_PAYMENT_REV_PROC_METHOD';
    ALGORITHM_CALC_PENALTY              constant com_api_type_pkg.t_name       := 'CRD_ALGORITHM_CALC_PENALTY';
    SEND_BLANK_STATEMENT                constant com_api_type_pkg.t_name       := 'CRD_SEND_BLANK_STATEMENT';
    DIRECT_DEBIT_AMOUNT                 constant com_api_type_pkg.t_name       := 'CRD_DIRECT_DEBIT_AMOUNT';
    ALGORITHM_CALC_RTRN_INTEREST        constant com_api_type_pkg.t_name       := 'CRD_ALGORITHM_CALC_RETURN_INTEREST_PART';
    INTEREST_CALC_END_DATE              constant com_api_type_pkg.t_name       := 'CRD_INTEREST_CALC_END_DATE';
    CREDIT_STATEMENT_MESSAGE            constant com_api_type_pkg.t_name       := 'CRD_STATEMENT_MESSAGE';
    SETTLEMENT_DATE                     constant com_api_type_pkg.t_name       := 'CRD_SETTLEMENT_DATE';
    LAST_INVOICE_DATE                   constant com_api_type_pkg.t_name       := 'CRD_LAST_INVOICE_DATE';
    GRACE_DATE                          constant com_api_type_pkg.t_name       := 'CRD_GRACE_DATE';
    PENALTY_DATE                        constant com_api_type_pkg.t_name       := 'CRD_PENALTY_DATE';
    TAD_IN_INVOICE                      constant com_api_type_pkg.t_name       := 'CRD_TAD_IN_INVOICE';
    TAD_NOT_PAID                        constant com_api_type_pkg.t_name       := 'CRD_TAD_NOT_PAID';
    MAD_IN_INVOICE                      constant com_api_type_pkg.t_name       := 'CRD_MAD_IN_INVOICE';
    MAD_NOT_PAID                        constant com_api_type_pkg.t_name       := 'CRD_MAD_NOT_PAID';
    TAD                                 constant com_api_type_pkg.t_name       := 'CRD_TAD';
    OVERDUE_SUM                         constant com_api_type_pkg.t_name       := 'CRD_OVERDUE_SUM';
    WAIVE_INTEREST_AMOUNT               constant com_api_type_pkg.t_name       := 'CRD_WAIVE_INTEREST_AMOUNT';
    PURCH_INTR_RATE                     constant com_api_type_pkg.t_name       := 'CRD_PURCHASE_INTEREST_RATE';
    PURCH_OVRD_INTR_RATE                constant com_api_type_pkg.t_name       := 'CRD_PURCHASE_OVERDUE_INTEREST_RATE';
    CASH_INTR_RATE                      constant com_api_type_pkg.t_name       := 'CRD_CASH_INTEREST_RATE';
    CASH_OVRD_INTR_RATE                 constant com_api_type_pkg.t_name       := 'CRD_CASH_OVERDUE_INTEREST_RATE';
    NOT_CHRG_INTERESTS                  constant com_api_type_pkg.t_name       := 'CRD_NOT_CHARGED_INTERESTS';
    AGING_PERIOD                        constant com_api_type_pkg.t_name       := 'CRD_AGING_PERIOD';
    AGING_PERIOD_NAME                   constant com_api_type_pkg.t_name       := 'CRD_AGING_PERIOD_NAME';
    CONTRACT_HISTORY                    constant com_api_type_pkg.t_name       := 'CRD_CONTRACT_HISTORY';
    CARD_PORTFOLIO_RATE                 constant com_api_type_pkg.t_name       := 'CRD_CARD_PORTFOLIO_RATE';
    REG_MAD_EVNT_IN_PENALTY_PERIOD      constant com_api_type_pkg.t_name       := 'CRD_REG_MAD_EVENT_IN_PENALTY_PERIOD';
    EXTRA_MANDATORY_AMOUNT_DUE          constant com_api_type_pkg.t_name       := 'CRD_EXTRA_MAD';
    MAD_CALCULATION_ALGORITHM           constant com_api_type_pkg.t_name       := 'CRD_MAD_CALC_ALGORITHM';
    MAD_ROUNDING_UP_EXPONENT            constant com_api_type_pkg.t_name       := 'CRD_MAD_ROUNDING_UP_EXPONENT';
    CUMULATIVE_INTR_INDUE               constant com_api_type_pkg.t_name       := 'CRD_CUMULATIVE_INTR_INDUE';
    CUMULATIVE_INTR_OVERDUE             constant com_api_type_pkg.t_name       := 'CRD_CUMULATIVE_INTR_OVERDUE';
    CHARGE_WAIVED_INTEREST              constant com_api_type_pkg.t_name       := 'CRD_CHARGE_WAIVED_INTEREST';
    WAIVE_INTEREST_PERIOD               constant com_api_type_pkg.t_name       := 'CRD_WAIVE_INTEREST_PERIOD';
    AGING_ALGORITHM                     constant com_api_type_pkg.t_name       := 'CRD_AGING_ALGORITHM';
    AGING_EVENT_TYPE                    constant com_api_type_pkg.t_name       := 'CRD_AGING_EVENT_TYPE';
    ZERO_PERIOD                         constant com_api_type_pkg.t_name       := 'CRD_AGING_ZERO_PERIOD';
    STOP_AGING_EVENT                    constant com_api_type_pkg.t_name       := 'CRD_STOP_AGING_EVENT';
    INVOICING_DELIVERY_STMT_METHOD      constant com_api_type_pkg.t_name       := 'CRD_INVOICING_DELIVERY_STATEMENT_METHOD';
    CLOSING_BALANCE                     constant com_api_type_pkg.t_name       := 'CRD_CLOSING_BALANCE';
    DUE_BALANCE                         constant com_api_type_pkg.t_name       := 'CRD_DUE_BALANCE';
    NOT_CHARGED_INTERESTS               constant com_api_type_pkg.t_name       := 'CRD_NOT_CHARGED_INTERESTS';
    OWN_FUNDS_BALANCE                   constant com_api_type_pkg.t_name       := 'CRD_OWN_FUNDS_BALANCE';
    UNSETTLED_AMOUNT                    constant com_api_type_pkg.t_name       := 'CRD_UNSETTLED_AMOUNT';
    MAD_CALC_THRESHOLD                  constant com_api_type_pkg.t_name       := 'CRD_MAD_CALC_THRESHOLD';
    DEBT_REPAYMENTS_SORTING_ALGO        constant com_api_type_pkg.t_name       := 'CRD_DEBT_REPAYMENTS_SORTING_ALGORITHM';
    CURRENT_BALANCE                     constant com_api_type_pkg.t_name       := 'CRD_CURRENT_BALANCE';
    INTEREST_RATE_EFF_DATE              constant com_api_type_pkg.t_name       := 'CRD_INTEREST_RATE_EFF_DATE';
    
    INVOICE_TYPE_REGULAR                constant com_api_type_pkg.t_dict_value := 'IVTP0010';
    INVOICE_TYPE_SPECIAL                constant com_api_type_pkg.t_dict_value := 'IVTP0020';

    ENTITY_TYPE_DEBT                    constant com_api_type_pkg.t_dict_value := 'ENTTDEBT';
    ENTITY_TYPE_INVOICE                 constant com_api_type_pkg.t_dict_value := 'ENTTINVC';
    ENTITY_TYPE_PAYMENT                 constant com_api_type_pkg.t_dict_value := 'ENTTPAYM';
    ENTITY_TYPE_AGING                   constant com_api_type_pkg.t_dict_value := 'ENTTAGNG';

    REPAY_COND_NO_CONDITION             constant com_api_type_pkg.t_dict_value := 'RPCD0001';
    REPAY_COND_INVOICED_DEBT            constant com_api_type_pkg.t_dict_value := 'RPCD0002';
    REPAY_COND_BETW_INVOICE_DUE         constant com_api_type_pkg.t_dict_value := 'RPCD0003';

    OPERATION_TYPE_PROVIDE_CREDIT       constant com_api_type_pkg.t_dict_value := 'OPTP1001';

    BALANCE_TYPE_ASSIGNED_EXCEED        constant com_api_type_pkg.t_dict_value := 'BLTP1001';
    BALANCE_TYPE_OVERDRAFT              constant com_api_type_pkg.t_dict_value := acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT;
    BALANCE_TYPE_UNUSED_EXCEED          constant com_api_type_pkg.t_dict_value := 'BLTP1012';

    INTEREST_CALC_DATE_POSTING          constant com_api_type_pkg.t_dict_value := 'ICSD0001';
    INTEREST_CALC_DATE_TRANSACTION      constant com_api_type_pkg.t_dict_value := 'ICSD0002';
    INTEREST_CALC_DATE_INVOICING        constant com_api_type_pkg.t_dict_value := 'ICSD0004';
    INTEREST_CALC_DATE_SETTLEMENT       constant com_api_type_pkg.t_dict_value := 'ICSD0005';
    INTEREST_CALC_DATE_TRANS_NEXT       constant com_api_type_pkg.t_dict_value := 'ICSD0006';

    INTER_DATE_TRNSFM_START_OF_DAY      constant com_api_type_pkg.t_dict_value := 'ISDT0001';
    INTER_DATE_TRNSF_REAL_TIME          constant com_api_type_pkg.t_dict_value := 'ISDT0002';
    INTER_DATE_TRNSF_END_OF_DAY         constant com_api_type_pkg.t_dict_value := 'ISDT0003';

    INTER_CALC_END_DATE_BLNC            constant com_api_type_pkg.t_dict_value := 'ICEDBLNC';
    INTER_CALC_END_DATE_DDUE            constant com_api_type_pkg.t_dict_value := 'ICEDDDUE';

    ALGORITHM_INTER_RTRN_EXCLUDE        constant com_api_type_pkg.t_dict_value := 'ACIR0000';
    ALGORITHM_INTER_RTRN_NDAYDUE        constant com_api_type_pkg.t_dict_value := 'ACIR0001';

    CREDIT_SERVICE_TYPE_ID              constant com_api_type_pkg.t_short_id   := 10000403;

    FILE_TYPE_MIGRATION                 constant com_api_type_pkg.t_dict_value := 'FLTPCMGR';

    BALANCE_TYPE_INTEREST               constant com_api_type_pkg.t_dict_value := 'BLTP1003';
    BALANCE_TYPE_OVERDUE                constant com_api_type_pkg.t_dict_value := acc_api_const_pkg.BALANCE_TYPE_OVERDUE;
    BALANCE_TYPE_OVERDUE_INTEREST       constant com_api_type_pkg.t_dict_value := 'BLTP1005';
    BALANCE_TYPE_PENALTY                constant com_api_type_pkg.t_dict_value := 'BLTP1006';
    BALANCE_TYPE_OVERLIMIT              constant com_api_type_pkg.t_dict_value := acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT;
    BALANCE_TYPE_INTR_OVERLIMIT         constant com_api_type_pkg.t_dict_value := 'BLTP1008';
    BALANCE_TYPE_LENDING                constant com_api_type_pkg.t_dict_value := 'BLTP1015';
    BALANCE_TYPE_WRT_OFF_PRINCIPAL      constant com_api_type_pkg.t_dict_value := 'BLTP1016';
    BALANCE_TYPE_WRT_OFF_INTEREST       constant com_api_type_pkg.t_dict_value := 'BLTP1017';
    BALANCE_TYPE_WRT_OFF_FEE            constant com_api_type_pkg.t_dict_value := 'BLTP1018';
    BALANCE_TYPE_INSTALLMENT            constant com_api_type_pkg.t_dict_value := 'BLTP1019';
    BALANCE_TYPE_TMP_OVERLIMIT          constant com_api_type_pkg.t_dict_value := 'BLTP1020';

    ALGORITHM_CALC_INTR_STANDARD        constant com_api_type_pkg.t_dict_value := 'ACIL0001';
    ALGORITHM_CALC_INTR_NOT_DECIM       constant com_api_type_pkg.t_dict_value := 'ACIL0002';

    PAYM_REV_METHOD_REG_DEBT            constant com_api_type_pkg.t_dict_value := 'PRPM0001';
    PAYM_REV_METHOD_REVERT              constant com_api_type_pkg.t_dict_value := 'PRPM0002';

    ALG_CALC_PENALTY_PLAIN_FEE          constant com_api_type_pkg.t_dict_value := 'PLTA0010';

    CARD_PORDFOLIO_LOV_ID               constant com_api_type_pkg.t_tiny_id    := 600;
    CARD_PORTFOLIO_RATING               constant com_api_type_pkg.t_dict_value := 'DICTCRPR';
    QUALIFICATION_A                     constant com_api_type_pkg.t_dict_value := 'CRPRQULA';
    QUALIFICATION_B                     constant com_api_type_pkg.t_dict_value := 'CRPRQULB';
    QUALIFICATION_C                     constant com_api_type_pkg.t_dict_value := 'CRPRQULC';
    QUALIFICATION_D                     constant com_api_type_pkg.t_dict_value := 'CRPRQULD';
    QUALIFICATION_E                     constant com_api_type_pkg.t_dict_value := 'CRPRQULE';
    QUALIFICATION_K                     constant com_api_type_pkg.t_dict_value := 'CRPRQULK';

    ALGORITHM_MAD_CALCULATION           constant com_api_type_pkg.t_dict_value := 'DICTMADA';
    ALGORITHM_MAD_CALC_DEFAULT          constant com_api_type_pkg.t_dict_value := 'MADADFLT';
    ALGORITHM_MAD_CALC_THRESHOLD        constant com_api_type_pkg.t_dict_value := 'MADATRES';

    ALGORITHM_AGING_DEFAULT             constant com_api_type_pkg.t_dict_value := 'AGAL0000';
    ALGORITHM_AGING_INDEPENDENT         constant com_api_type_pkg.t_dict_value := 'AGAL0001';

    ALGO_ENTR_PT_MODIFY_MAD_INV_CR      constant com_api_type_pkg.t_dict_value := 'ALGE1001';
    ALGO_ENTR_PT_CHECK_MAD_REPAYM       constant com_api_type_pkg.t_dict_value := 'ALGE1002';
    ALGO_ENTR_PT_CHECK_RESET_AGING      constant com_api_type_pkg.t_dict_value := 'ALGE1003';
    ALGO_ENTR_PT_CHECKING_OVERDUE       constant com_api_type_pkg.t_dict_value := 'ALGE1004';
    ALGO_ENTR_PT_GETTING_UI_INFO        constant com_api_type_pkg.t_dict_value := 'ALGE1005';

    DATE_FORMAT                         constant com_api_type_pkg.t_name       := 'dd.mm.yyyy';
    NUMBER_FORMAT                       constant com_api_type_pkg.t_name       := 'FM999999999999999990.00';

    EVENT_TYPE_ARRAY_ID                 constant com_api_type_pkg.t_short_id   := 10000072;
    FEE_TYPE_ARRAY_ID                   constant com_api_type_pkg.t_short_id   := 10000070;

    AGING_ARRAY_ID                      constant com_api_type_pkg.t_short_id   := 10000078;
    AGING_ARRAY_TYPE_ID                 constant com_api_type_pkg.t_short_id   := 1056;

    OPERATION_TYPE_REDUCE_LIMIT         constant com_api_type_pkg.t_dict_value := 'OPTP0423';

    DEBT_REPAYMENT_SORTING_FIFO         constant com_api_type_pkg.t_dict_value := 'DRSA0000';
    DEBT_REPAYMENT_SORTING_LIFO         constant com_api_type_pkg.t_dict_value := 'DRSA0001';

    INTEREST_RATE_POSTING_DATE          constant com_api_type_pkg.t_dict_value := 'IREF0000';
    INTEREST_RATE_CURRENT_DATE          constant com_api_type_pkg.t_dict_value := 'IREF0001';

    CREDIT_STMT_MODE_FULL               constant com_api_type_pkg.t_dict_value := 'CRMDFULL';
    CREDIT_STMT_MODE_DATA_ONLY          constant com_api_type_pkg.t_dict_value := 'CRMDCRED';
    CREDIT_STMT_MODE_DATA_N_DPP         constant com_api_type_pkg.t_dict_value := 'CRMDCRIP';
    CREDIT_STMT_MODE_DATA_N_LTY         constant com_api_type_pkg.t_dict_value := 'CRMDCDLT';

end;
/
