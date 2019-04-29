create or replace package dpp_api_const_pkg is
/*********************************************************
*  Constants for DPP module <br />
*  Created by  E.(fomichev@bpc.ru)  at 10.08.2010 <br />
*  Module: DPP_API_CONST_PKG <br />
*  @headcom
**********************************************************/

DPP_OPERATION_STATUS_KEY          constant com_api_type_pkg.t_dict_value := 'DOST';
DPP_OPERATION_ACTIVE              constant com_api_type_pkg.t_dict_value := 'DOST0100';
DPP_OPERATION_PAID                constant com_api_type_pkg.t_dict_value := 'DOST0200';
DPP_OPERATION_CANCELED            constant com_api_type_pkg.t_dict_value := 'DOST0300';

DPP_PLAN_ACCELERATION_KEY         constant com_api_type_pkg.t_dict_value := 'DPAT';
DPP_ACCELERT_NEW_INSTLMT_CNT      constant com_api_type_pkg.t_dict_value := 'DPAT0100';
DPP_ACCELERT_KEEP_INSTLMT_AMT     constant com_api_type_pkg.t_dict_value := 'DPAT0200';
DPP_ACCELERT_KEEP_INSTLMT_CNT     constant com_api_type_pkg.t_dict_value := 'DPAT0300';
DPP_RESTRUCTURIZATION             constant com_api_type_pkg.t_dict_value := 'DPAT0400';

DPP_SERVICE_TYPE_ID               constant com_api_type_pkg.t_short_id   := 10000884;
DPP_MERCHANT_SERVICE_TYPE_ID      constant com_api_type_pkg.t_short_id   := 10003485;

ATTR_ALGORITHM                    constant com_api_type_pkg.t_name       := 'DPP_ALGORITHM';
ATTR_RATE_ALGORITHM               constant com_api_type_pkg.t_name       := 'DPP_RATE_CALC_ALGRORITHM';

DPP_ALGORITHM_KEY                 constant com_api_type_pkg.t_dict_value := 'DPPA';
DPP_ALGORITHM_ANNUITY             constant com_api_type_pkg.t_dict_value := 'DPPAANNU';
DPP_ALGORITHM_DIFFERENTIATED      constant com_api_type_pkg.t_dict_value := 'DPPADIFF';
DPP_ALGORITHM_FIXED_AMOUNT        constant com_api_type_pkg.t_dict_value := 'DPPAFIXD';
DPP_ALGORITHM_BALLOON             constant com_api_type_pkg.t_dict_value := 'DPPABALN';

DPP_RATE_ALGORITHM_LINEAR         constant com_api_type_pkg.t_dict_value := 'DPPRLINR';
DPP_RATE_ALGORITHM_EXPONENTIAL    constant com_api_type_pkg.t_dict_value := 'DPPREXPN';

ATTR_INSTALMENT_COUNT             constant com_api_type_pkg.t_name       := 'DPP_INSTALMENT_COUNT';
ATTR_INSTALMENT_AMOUNT            constant com_api_type_pkg.t_name       := 'DPP_INSTALMENT_FIXED_AMOUNT';
ATTR_FEE_ID                       constant com_api_type_pkg.t_name       := 'DPP_INTEREST_RATE';
ATTR_FIRST_CYCLE_ID               constant com_api_type_pkg.t_name       := 'DPP_FIRST_INSTALMENT_DATE';
ATTR_MAIN_CYCLE_ID                constant com_api_type_pkg.t_name       := 'DPP_INSTALMENT_PERIOD';
ATTR_LIMIT                        constant com_api_type_pkg.t_name       := 'DPP_LIMIT';
ATTR_CANCEL_FEE_ID                constant com_api_type_pkg.t_name       := 'DPP_CANCELATION_FEE';
ATTR_MIN_EARLY_REPAYMENT          constant com_api_type_pkg.t_name       := 'DPP_MIN_EARLY_REPAYMENT';
ATTR_ACCEL_FEE_ID                 constant com_api_type_pkg.t_name       := 'DPP_ACCELERATION_FEE';
ATTR_FIXED_INSTALMENTS            constant com_api_type_pkg.t_name       := 'DPP_FIXED_INSTALMENTS';
ATTR_MACROS_TYPE_ID               constant com_api_type_pkg.t_name       := 'DPP_INSTALMENT_MACROS_TYPE';
ATTR_MACROS_INTR_TYPE_ID          constant com_api_type_pkg.t_name       := 'DPP_INSTALMENT_MACROS_INTEREST_TYPE';
ATTR_REPAY_MACROS_TYPE_ID         constant com_api_type_pkg.t_name       := 'DPP_EARLY_REPAYMENT_MACROS_TYPE';
ATTR_INTEREST_SINCE_LAST_BILL     constant com_api_type_pkg.t_name       := 'DPP_CALC_INTEREST_SINCE_LAST_BILL_DATE';
ATTR_USE_AUTOCREATION             constant com_api_type_pkg.t_name       := 'DPP_USE_AUTOCREATION';
ATTR_MERCHANT_FEE_ID              constant com_api_type_pkg.t_name       := 'DPP_INTEREST_RATE_MERCHANT';
ATTR_CANCEL_M_TYPE_ID             constant com_api_type_pkg.t_name       := 'DPP_CANCEL_MACROS_TYPE';
ATTR_CANCEL_M_INTR_TYPE_ID        constant com_api_type_pkg.t_name       := 'DPP_CANCEL_MACROS_INTEREST_TYPE';
ATTR_USURY_RATE                   constant com_api_type_pkg.t_name       := 'DPP_USURY_RATE';
ATTR_ALLOW_BILLED_OPER            constant com_api_type_pkg.t_name       := 'DPP_ALLOW_BILLED_OPER_REGISTR';
ATTR_CREDIT_MACROS_TYPE           constant com_api_type_pkg.t_name       := 'DPP_CREDIT_MACROS_TYPE';
ATTR_CREDIT_MACROS_INTR_TYPE      constant com_api_type_pkg.t_name       := 'DPP_CREDIT_MACROS_INTR_TYPE';
ATTR_CREDIT_REPAY_MACROS_TYPE     constant com_api_type_pkg.t_name       := 'DPP_EARLY_REPAYMENT_CREDIT_MACROS_TYPE';
ATTR_CANCEL_CREDIT_M_TYPE         constant com_api_type_pkg.t_name       := 'DPP_CANCEL_CREDIT_MACROS_TYPE';
ATTR_CANCEL_INTR_CREDIT_M_TYPE    constant com_api_type_pkg.t_name       := 'DPP_CANCEL_INTEREST_CREDIT_MACROS_TYPE';
ATTR_BALLOON_RATE                 constant com_api_type_pkg.t_name       := 'DPP_BALLOON_RATE';

EVENT_TYPE_ENABLE_SERVICE         constant com_api_type_pkg.t_name       := 'EVNT1501';
EVENT_TYPE_DISABLE_SERVICE        constant com_api_type_pkg.t_name       := 'EVNT1502';
EVENT_TYPE_REGISTER_PLAN          constant com_api_type_pkg.t_name       := 'EVNT1503';
EVENT_TYPE_ACCELERATE_PLAN        constant com_api_type_pkg.t_name       := 'EVNT1504';
EVENT_TYPE_CANCEL_PLAN            constant com_api_type_pkg.t_name       := 'EVNT1505';
EVENT_TYPE_REPAID                 constant com_api_type_pkg.t_name       := 'EVNT1510';
EVENT_TYPE_USURY_ACCELEARTION     constant com_api_type_pkg.t_name       := 'EVNT2105';
EVENT_TYPE_INSTALMNT_DATE_COME    constant com_api_type_pkg.t_name       := 'EVNT2109';

ENTITY_TYPE_INSTALMENT            com_api_type_pkg.t_name                := 'ENTTDPPI';
ENTITY_TYPE_PAYMENT_PLAN          com_api_type_pkg.t_name                := 'ENTT0059';

OPERATION_TYPE_DPP_PURCHASE       constant com_api_type_pkg.t_name       := 'OPTP1500';
OPERATION_TYPE_DPP_REGISTER       constant com_api_type_pkg.t_name       := 'OPTP1501';
OPERATION_TYPE_DPP_RESTRUCT       constant com_api_type_pkg.t_dict_value := 'OPTP1502';

FEE_TYPE_INTEREST                 constant com_api_type_pkg.t_name       := 'FETP1501';
FEE_TYPE_ACCELERATION             constant com_api_type_pkg.t_name       := 'FETP1502';
FEE_TYPE_MIN_AMOUNT_EARLY         constant com_api_type_pkg.t_name       := 'FETP1503';
FEE_TYPE_CANCELATION              constant com_api_type_pkg.t_name       := 'FETP1504';
FEE_TYPE_DEBT_LIMIT               constant com_api_type_pkg.t_name       := 'FETP1505';
FEE_TYPE_FIXED_PAYMENT            constant com_api_type_pkg.t_name       := 'FETP1506';
FEE_TYPE_MINIMUM_AMOUNT           constant com_api_type_pkg.t_name       := 'FETP0409';
FEE_TYPE_AUTOCREATION_THRSHLD     constant com_api_type_pkg.t_name       := 'FETP0410';
FEE_TYPE_INTEREST_MERCHANT        constant com_api_type_pkg.t_name       := 'FETP0227';
FEE_TYPE_USURY_RATE               constant com_api_type_pkg.t_name       := 'FETP0420';
FEE_TYPE_BALLOON_RATE             constant com_api_type_pkg.t_name       := 'FETP1511';
FEE_TYPE_HOLIDAY                  constant com_api_type_pkg.t_dict_value := 'FETP1510';

CYCLE_TYPE_HOLIDAY_FEE            constant com_api_type_pkg.t_dict_value := 'CYTP1505';

BUNCH_TYPE_ID_OVERDRAFT_REGSTR    constant com_api_type_pkg.t_tiny_id    := 1021;
BUNCH_TYPE_ID_OVERLIMIT_REGSTR    constant com_api_type_pkg.t_tiny_id    := 1022;
BUNCH_TYPE_ID_CREDIT_LENDING      constant com_api_type_pkg.t_tiny_id    := 1053;

DPP_RESTRUCT_INSTALMENTS          constant com_api_type_pkg.t_name       := 'DPP_RESTRUCT_INSTALMENTS';
DPP_RESTRUCT_INFO                 constant com_api_type_pkg.t_name       := 'DPP_RESTRUCT_INFO';

FILE_TYPE_DPP_REGISTRATION        constant com_api_type_pkg.t_dict_value := 'FLTPDPPR';

OPER_REASON_GENERATED_BY_DPP      constant com_api_type_pkg.t_dict_value := 'OPRS1501';

function get_dpp_service_type return com_api_type_pkg.t_short_id;

end;
/
