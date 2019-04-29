create or replace package pmo_api_const_pkg as
/************************************************************
 * Constants for Payment Order<br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 24.08.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_API_CONST_PKG <br />
 * @headcom
 ************************************************************/
 
ENTITY_TYPE_PAYMENT_ORDER            constant com_api_type_pkg.t_dict_value := 'ENTTPMNO';
ENTITY_TYPE_SERVICE_PROVIDER         constant com_api_type_pkg.t_dict_value := 'ENTTSRVP';
    
PROVIDER_HOST_SCALE_TYPE             constant com_api_type_pkg.t_dict_value := 'SCTPPOPH';
PURPOSE_SCALE_TYPE                   constant com_api_type_pkg.t_dict_value := 'SCTPPPUC';

PAYMENT_HOST_ALG_PRIORITY            constant com_api_type_pkg.t_dict_value := 'POHAHOST';
PAYMENT_TMPL_STATUS_VALD             constant com_api_type_pkg.t_dict_value := 'POTSVALD';
PAYMENT_TMPL_STATUS_INVD             constant com_api_type_pkg.t_dict_value := 'POTSINVD';
PAYMENT_TMPL_STATUS_SUSP             constant com_api_type_pkg.t_dict_value := 'POTSSUSP';
PAYMENT_ORD_EXC_TYPE_ONLN            constant com_api_type_pkg.t_dict_value := 'POETONLN';
PAYMENT_ORD_EXC_TYPE_OFFLN           constant com_api_type_pkg.t_dict_value := 'POETOFFL';
PAYMENT_ORD_EXC_TYPE_ECCM            constant com_api_type_pkg.t_dict_value := 'POETECCM';
PAYMENT_ORD_STAGE_1                  constant com_api_type_pkg.t_dict_value := 'POOS0001';
--  RESP
SERVICE_NOT_ALLOWED                  constant com_api_type_pkg.t_dict_value := 'RESP0032';
CUSTOMER_NOT_FOUND                   constant com_api_type_pkg.t_dict_value := 'RESP0035';
ACCOUNT_NOT_FOUND                    constant com_api_type_pkg.t_dict_value := 'RESP0034';
CHANNEL_NOT_AVAILABLE                constant com_api_type_pkg.t_dict_value := 'RESP0039';
SUCCESSFUL_AUTHORIZATION             constant com_api_type_pkg.t_dict_value := 'RESP0001';
    
PMO_STATUS_AWAITINGPROC         constant com_api_type_pkg.t_dict_value := 'POSA0001';
PMO_STATUS_WAIT_CONFIRM         constant com_api_type_pkg.t_dict_value := 'POSA0002';
PMO_STATUS_PROCESSED            constant com_api_type_pkg.t_dict_value := 'POSA0010';
PMO_STATUS_CANCELED             constant com_api_type_pkg.t_dict_value := 'POSA0020';
PMO_STATUS_PREPARATION          constant com_api_type_pkg.t_dict_value := 'POSA0100';
PMO_STATUS_NOT_PAID             constant com_api_type_pkg.t_dict_value := 'POSA5001';
PMO_STATUS_REQUIRE_MATCHING     constant com_api_type_pkg.t_dict_value := 'POSA0030';

PMO_PERIODIC_PAYMENT_CYCLE      constant com_api_type_pkg.t_dict_value := 'CYTP1401';
DIRECT_DEBIT_EXP_CARD_CYCLE     constant com_api_type_pkg.t_dict_value := 'CYTP1402';
DIRECT_DEBIT_EXP_ACC_CYCLE      constant com_api_type_pkg.t_dict_value := 'CYTP1403';
DIRECT_DEBIT_EXP_CUST_CYCLE     constant com_api_type_pkg.t_dict_value := 'CYTP1404';
PMO_MERCHAND_SETTLEMENT_CYCLE   constant com_api_type_pkg.t_dict_value := 'CYTP0214';

PMO_AMOUNT_ALGO_IMCOMING        constant com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPER_AMOUNT_ALG_REQUESTED;
PMO_AMOUNT_ALGO_MAD             constant com_api_type_pkg.t_dict_value := 'POAA0001';
PMO_AMOUNT_ALGO_TAD             constant com_api_type_pkg.t_dict_value := 'POAA0002';
PMO_AMOUNT_ALGO_FIXED           constant com_api_type_pkg.t_dict_value := 'POAA0003';
PMO_AMOUNT_ALGO_TAD_PCT         constant com_api_type_pkg.t_dict_value := 'POAA0004';
PMO_AMOUNT_ALGO_TAD_OVD_MAD     constant com_api_type_pkg.t_dict_value := 'POAA0005';
PMO_AMOUNT_ALGO_REMAIN_AMOUNT   constant com_api_type_pkg.t_dict_value := 'POAA0006';
PMO_AMOUNT_ALGO_ATT_OPER_AMNT   constant com_api_type_pkg.t_dict_value := 'POAA0009';

TRANSFER_TO_PERSON              constant com_api_type_pkg.t_short_id   := 10000001;
TRANSFER_TO_ORGANIZATION        constant com_api_type_pkg.t_short_id   := 10000002;
INTERNAL_TRANSFER               constant com_api_type_pkg.t_short_id   := 10000003;
INTERNAL_TRANSFER_TO_ORG        constant com_api_type_pkg.t_short_id   := 10000005;
TRANSFER_BETWEEN_ONE_CLIENT     constant com_api_type_pkg.t_short_id   := 10000006;
REJECTION_OF_ADVANCE            constant com_api_type_pkg.t_short_id   := 10000007;
EXTERNAL_INCOMING_PAYMENT       constant com_api_type_pkg.t_short_id   := 10000008;
TOPUP_FROM_LINKED_CARD          constant com_api_type_pkg.t_short_id   := 10000009;
TOPUP_FROM_NOTLINKED_CARD       constant com_api_type_pkg.t_short_id   := 10000010;

ATTR_MIN_PAYMENT_AMOUNT         constant com_api_type_pkg.t_name       := 'MIN_PAYMENT_AMOUNT';
ATTR_MAX_PAYMENT_AMOUNT         constant com_api_type_pkg.t_name       := 'MAX_PAYMENT_AMOUNT';

FEE_TYPE_MIN_PAYMENT            constant com_api_type_pkg.t_dict_value := 'FETP1401';
FEE_TYPE_MAX_PAYMENT            constant com_api_type_pkg.t_dict_value := 'FETP1402';
FEE_TYPE_SETTLEMENT_THRESHOLD   constant com_api_type_pkg.t_dict_value := 'FETP0232';

CHOOSE_HOST_MODE_ALG            constant com_api_type_pkg.t_dict_value := 'CHMD0010';
CHOOSE_HOST_MODE_HOST           constant com_api_type_pkg.t_dict_value := 'CHMD0020';

LINKED_CARD_STATUS_NOT_CONF     constant com_api_type_pkg.t_dict_value := 'LNCS0001';
LINKED_CARD_STATUS_CONFIRMED    constant com_api_type_pkg.t_dict_value := 'LNCS0002';
LINKED_CARD_STATUS_NOT_VALID    constant com_api_type_pkg.t_dict_value := 'LNCS0003';

PROVIDER_HOST_ACTIVE            constant com_api_type_pkg.t_dict_value := 'PHST0100';
PROVIDER_HOST_INACTIVE          constant com_api_type_pkg.t_dict_value := 'PHST0200';

PURPOSE_STAGE_1                 constant com_api_type_pkg.t_dict_value := 'POOS0001';

CLIENT_ID_TYPE_SRVP_NUMBER      constant com_api_type_pkg.t_dict_value := 'CITPSRVP';

EVENT_TYPE_PAY_ORDER_CREATE     constant com_api_type_pkg.t_dict_value := 'EVNT1403';

PARAM_TRANSFER_RECIPIENT_ACC    constant com_api_type_pkg.t_short_id   := 10000004;
PARAM_CBS_CLIENT_ID_TYPE        constant com_api_type_pkg.t_short_id   := 10000010;
PARAM_CBS_CLIENT_ID_VALUE       constant com_api_type_pkg.t_short_id   := 10000011;
PARAM_SOURCE_CLIENT_ID_TYPE     constant com_api_type_pkg.t_short_id   := 10000013;
PARAM_SOURCE_CLIENT_ID_VALUE    constant com_api_type_pkg.t_short_id   := 10000014;
PARAM_OPER_SURCHARGE_AMOUNT     constant com_api_type_pkg.t_short_id   := 10000029;
PARAM_OPER_REASON               constant com_api_type_pkg.t_short_id   := 10000030;

PMO_PARAM_PMT_PHONE             constant com_api_type_pkg.t_short_id   := 10000032;
PMO_PARAM_PMT_MOBILE_PHONE      constant com_api_type_pkg.t_short_id   := 10000033;
PMO_PARAM_PMT_ACCOUNT           constant com_api_type_pkg.t_short_id   := 10000034;
PMO_PARAM_PMT_CONTRACT          constant com_api_type_pkg.t_short_id   := 10000035;

PMO_RESPONSE_CODE_PROCESSED     constant com_api_type_pkg.t_dict_value := 'PORC0001';
PMO_RESPONSE_CODE_FAILED        constant com_api_type_pkg.t_dict_value := 'PORC0002';
PMO_RESPONSE_CODE_EXPIRED       constant com_api_type_pkg.t_dict_value := 'PORC0003';

PMO_SCM_MARK_ORDER_PROCESSED    constant com_api_type_pkg.t_dict_value := 'PSCM0001';
PMO_SCM_WAIT_FOR_RESPONSE       constant com_api_type_pkg.t_dict_value := 'PSCM0002';

EVENT_TYPE_PMO_EXPIRED_CARD     constant com_api_type_pkg.t_dict_value := 'EVNT1404';
EVENT_TYPE_PMO_EXPIRED_ACC      constant com_api_type_pkg.t_dict_value := 'EVNT1405';
EVENT_TYPE_PMO_EXPIRED_CUST     constant com_api_type_pkg.t_dict_value := 'EVNT1406';

EVENT_TYPE_PMO_RESPONSE_LOADED  constant com_api_type_pkg.t_dict_value := 'EVNT1407';
EVENT_TYPE_PMO_LOADED           constant com_api_type_pkg.t_dict_value := 'EVNT1408';

DIR_DEBIT_CYCLE_RETRY_ACCOUNT   constant com_api_type_pkg.t_dict_value := 'CYTP1408';
DIR_DEBIT_CYCLE_RETRY_CARD      constant com_api_type_pkg.t_dict_value := 'CYTP1409';
DIR_DEBIT_CYCLE_RETRY_CUSTOMER  constant com_api_type_pkg.t_dict_value := 'CYTP1410';

end pmo_api_const_pkg;
/
