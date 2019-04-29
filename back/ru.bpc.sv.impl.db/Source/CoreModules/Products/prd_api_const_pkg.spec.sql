create or replace package prd_api_const_pkg is
/**********************************************************
*  Product constants <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 15.10.2010 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
*  Revision: $LastChangedRevision: 8281 $ <br />
*  Module: PRD_API_CONST_PKG <br />
*  @headcom
***********************************************************/
PRODUCT_STATUS_ACTIVE          constant  com_api_type_pkg.t_dict_value := 'PRDS0100';
PRODUCT_STATUS_INACTIVE        constant  com_api_type_pkg.t_dict_value := 'PRDS0200';

ATTRIBUTE_DEFIN_LVL_OBJECT     constant  com_api_type_pkg.t_dict_value := 'SADLOBJT';
ATTRIBUTE_DEFIN_LVL_PRODUCT    constant  com_api_type_pkg.t_dict_value := 'SADLPRDT';
ATTRIBUTE_DEFIN_LVL_SERVICE    constant  com_api_type_pkg.t_dict_value := 'SADLSRVC';

ENTITY_TYPE_CUSTOMER           constant  com_api_type_pkg.t_dict_value := com_api_const_pkg.ENTITY_TYPE_CUSTOMER;
ENTITY_TYPE_CONTRACT           constant  com_api_type_pkg.t_dict_value := com_api_const_pkg.ENTITY_TYPE_CONTRACT;
ENTITY_TYPE_SERVICE            constant  com_api_type_pkg.t_dict_value := 'ENTTSRVC';
ENTITY_TYPE_SERVICE_TYPE       constant  com_api_type_pkg.t_dict_value := 'ENTTSRVT';
ENTITY_TYPE_PRODUCT            constant  com_api_type_pkg.t_dict_value := 'ENTTPROD';
ENTITY_TYPE_SERVICE_PROVIDER   constant  com_api_type_pkg.t_dict_value := 'ENTTSRVP';
ENTITY_TYPE_PRODUCT_ATTRIBUTE  constant  com_api_type_pkg.t_dict_value := 'ENTTATTR';
ENTITY_TYPE_PRODUCT_ATTR_VAL   constant  com_api_type_pkg.t_dict_value := 'ENTT0109';

PRODUCT_TYPE_ISS               constant  com_api_type_pkg.t_dict_value := 'PRDT0100';
PRODUCT_TYPE_ACQ               constant  com_api_type_pkg.t_dict_value := 'PRDT0200';
PRODUCT_TYPE_INST              constant  com_api_type_pkg.t_dict_value := 'PRDT0300';

SERVICE_STATUS_ACTIVE          constant  com_api_type_pkg.t_dict_value := 'SRVS0001';
SERVICE_STATUS_INACTIVE        constant  com_api_type_pkg.t_dict_value := 'SRVS0002';

SERVICE_OBJECT_STATUS_INACTIVE constant  com_api_type_pkg.t_dict_value := 'SROS0010';
SERVICE_OBJECT_STATUS_ACTIVE   constant  com_api_type_pkg.t_dict_value := 'SROS0020';
SERVICE_OBJECT_STATUS_CLOSED   constant  com_api_type_pkg.t_dict_value := 'SROS0030';

CUSTOMER_STATUS_ACTIVE         constant  com_api_type_pkg.t_dict_value := 'CTST0010';
CUSTOMER_STATUS_INACTIVE       constant  com_api_type_pkg.t_dict_value := 'CTST0020';
CUSTOMER_STATUS_ACTIV_REQUIRED constant  com_api_type_pkg.t_dict_value := 'CTST0030';


EVENT_CUSTOMER_CREATION        constant  com_api_type_pkg.t_dict_value := 'EVNT0004';
EVENT_CUSTOMER_MODIFY          constant  com_api_type_pkg.t_dict_value := 'EVNT0005';
EVENT_PRODUCT_CHANGE           constant  com_api_type_pkg.t_dict_value := 'EVNT0901';
EVENT_ATTRIBUTE_CHANGE_PRODUCT constant  com_api_type_pkg.t_dict_value := 'EVNT0980';
EVENT_ATTR_CHANGE_PRD_ATTR_LVL constant  com_api_type_pkg.t_dict_value := 'EVNT1080';
EVENT_PRODUCT_ATTR_END_CHANGE  constant  com_api_type_pkg.t_dict_value := 'EVNT0981';
EVENT_ATTR_CHANGE_CUSTOMER     constant  com_api_type_pkg.t_dict_value := 'EVNT1180';
EVENT_ADD_SERVICE              constant  com_api_type_pkg.t_dict_value := 'EVNT0982';
EVENT_REFERRAL_CUST_REGISTER   constant  com_api_type_pkg.t_dict_value := 'EVNT0009';

CONTRACT_TYPE_SERVICE_PROVIDER constant  com_api_type_pkg.t_dict_value := 'CNTPSRVP';
CONTRACT_TYPE_SERVICE_CUSTOMER constant  com_api_type_pkg.t_dict_value := 'CNTPCUSR';
CONTRACT_TYPE_INSTANT_CARD     constant  com_api_type_pkg.t_dict_value := 'CNTPINIC'; 
CONTRACT_TYPE_PREPAID_CARD     constant  com_api_type_pkg.t_dict_value := 'CNTPPRPD';
CONTRACT_TYPE_AGENT            constant  com_api_type_pkg.t_dict_value := 'CNTPAGNT';
CONTRACT_TYPE_ACCOUNT_POOL     constant  com_api_type_pkg.t_dict_value := 'CNTPACPL';

FILE_TYPE_PRODUCTS             constant  com_api_type_pkg.t_dict_value := 'FLTPPROD';
FILE_TYPE_CUSTOMERS            constant  com_api_type_pkg.t_dict_value := 'FLTPCUST';
FILE_TYPE_SETTL_ACKNOWLEDG     constant  com_api_type_pkg.t_dict_value := 'FLTPSTAL';

CND_GROUP_MANY                 constant  com_api_type_pkg.t_dict_value := 'CNDSMANY';
CND_GROUP_ONE                  constant  com_api_type_pkg.t_dict_value := 'CNDSONE';
CND_GROUP_NOT_MORE_THAN_ONE    constant  com_api_type_pkg.t_dict_value := 'CNDSNOMO';

UNLIMITED_SERVICE_COUNT        constant  com_api_type_pkg.t_tiny_id    := 9999;

-- Parameters (rul_mod_param) are used in generation of a product's number
PRODUCT_NAME_FORMAT_ID         constant  com_api_type_pkg.t_tiny_id    := 1290;
PRODUCT_NAME_FORMAT_INST_ID    constant  com_api_type_pkg.t_name       := 'INST_ID';
PRODUCT_NAME_FORMAT_PRODUCT_ID constant  com_api_type_pkg.t_name       := 'PRODUCT_ID';
PRODUCT_NAME_FORMAT_EFF_DATE   constant  com_api_type_pkg.t_name       := 'SYS_DATE';

-- Parameters (rul_mod_param) are used in generation of a service's number
SERVICE_NAME_FORMAT_ID         constant  com_api_type_pkg.t_tiny_id    := 1291;
SERVICE_NAME_FORMAT_INST_ID    constant  com_api_type_pkg.t_name       := 'INST_ID';
SERVICE_NAME_FORMAT_SERVICE_ID constant  com_api_type_pkg.t_name       := 'SERVICE_ID';
SERVICE_NAME_FORMAT_EFF_DATE   constant  com_api_type_pkg.t_name       := 'SYS_DATE';

CUSTOMER_MAINTENANCE_SERVICE   constant  com_api_type_pkg.t_short_id   := 10003288;
CUST_CRED_LIMIT_EXCH_RATE_TYPE constant  com_api_type_pkg.t_name       := 'CUST_CREDIT_LIMIT_EXCH_RATE_TYPE';
CRD_CUSTOMER_CRED_LIMIT_VALUE  constant  com_api_type_pkg.t_name       := 'CRD_CUSTOMER_CREDIT_LIMIT_VALUE';
CUSTOMER_REFERRER_CODE_SERVICE constant  com_api_type_pkg.t_short_id   := 10004360;

CRD_INTEREST_RATE              constant  com_api_type_pkg.t_name       := 'CRD_INTEREST_RATE';

REFERR_CALCULATION_ALGORITHM   constant  com_api_type_pkg.t_name       := 'REWARD_CALCULATION_ALGORITHM';

end;
/
