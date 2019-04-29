create or replace package net_api_const_pkg is

MODULE_CODE_NETWORKING          constant com_api_type_pkg.t_dict_value := 'NET';

UNIDENTIFIED_NETWORK            constant com_api_type_pkg.t_network_id := 9998;
DEFAULT_NETWORK                 constant com_api_type_pkg.t_network_id := 9999;

ENTITY_TYPE_NETWORK             constant com_api_type_pkg.t_dict_value := 'ENTTNETW';
ENTITY_TYPE_HOST                constant com_api_type_pkg.t_dict_value := 'ENTTHOST';
ENTITY_TYPE_MEMBER              constant com_api_type_pkg.t_dict_value := 'ENTTMEMB';
ENTITY_TYPE_INTERFACE           constant com_api_type_pkg.t_dict_value := 'ENTTNIFC';

CLEARING_MSG_STATUS_KEY         constant com_api_type_pkg.t_dict_value := 'CLMS';
CLEARING_MSG_STATUS_READY       constant com_api_type_pkg.t_dict_value := 'CLMS0010';
CLEARING_MSG_STATUS_UPLOADED    constant com_api_type_pkg.t_dict_value := 'CLMS0020';
CLEARING_MSG_STATUS_NOT_UPLOAD  constant com_api_type_pkg.t_dict_value := 'CLMS0030';
CLEARING_MSG_STATUS_LOADED      constant com_api_type_pkg.t_dict_value := 'CLMS0040';
CLEARING_MSG_STATUS_PENDING     constant com_api_type_pkg.t_dict_value := 'CLMS0060';
CLEARING_MSG_STATUS_INVALID     constant com_api_type_pkg.t_dict_value := 'CLMS0080';
CLEARING_MSG_STATUS_UPLOAD_ERR  constant com_api_type_pkg.t_dict_value := 'CLMS0050';
CLEARING_MSG_STATUS_MATCHED     constant com_api_type_pkg.t_dict_value := 'CLMS0110';
CLEARING_MSG_STATUS_MATCH_SKIP  constant com_api_type_pkg.t_dict_value := 'CLMS0130';
CLEARING_MSG_STATUS_MATCH_ERR   constant com_api_type_pkg.t_dict_value := 'CLMS0150';
CLEARING_MSG_STAT_MISS_IN_SV    constant com_api_type_pkg.t_dict_value := 'CLMS0220';
CLEARING_MSG_STAT_MISS_IN_FILE  constant com_api_type_pkg.t_dict_value := 'CLMS0230';

CARD_FEATURE_KEY                constant com_api_type_pkg.t_dict_value := 'CFCH';
CARD_FEATURE_STATUS_DEBIT       constant com_api_type_pkg.t_dict_value := 'CFCHDEBT';
CARD_FEATURE_STATUS_CREDIT      constant com_api_type_pkg.t_dict_value := 'CFCHCRDT';
CARD_FEATURE_STATUS_VIRTUAL     constant com_api_type_pkg.t_dict_value := 'CFCHVIRT';
CARD_FEATURE_STATUS_OVERDRAFT   constant com_api_type_pkg.t_dict_value := 'CFCHOVER';
CARD_FEATURE_STATUS_ELECTRON    constant com_api_type_pkg.t_dict_value := 'CFCHELEC';
CARD_FEATURE_STATUS_PREPAID     constant com_api_type_pkg.t_dict_value := 'CFCHPRPD';
CARD_FEATURE_STATUS_CNCTLESS    constant com_api_type_pkg.t_dict_value := 'CFCHCNTL';

HOST_STATUS_ACTIVE              constant com_api_type_pkg.t_dict_value := 'HSST0001';
HOST_STATUS_INACTIVE            constant com_api_type_pkg.t_dict_value := 'HSST0002';

STATUS_CHANGE_REASON_AGG        constant com_api_type_pkg.t_dict_value := 'HSCR0001'; -- Aggregator is not available
STATUS_CHANGE_REASON_PROV       constant com_api_type_pkg.t_dict_value := 'HSCR0002'; -- Aggregator is available, provider is not available
STATUS_CHANGE_REASON_SRV        constant com_api_type_pkg.t_dict_value := 'HSCR0003'; -- Service is disallowed
STATUS_CHANGE_REASON_INIT       constant com_api_type_pkg.t_dict_value := 'HSCR0004'; -- Initiate

MCC_CASH                        constant com_api_type_pkg.t_mcc        := '6010';
MCC_ATM                         constant com_api_type_pkg.t_mcc        := '6011';

end;
/
