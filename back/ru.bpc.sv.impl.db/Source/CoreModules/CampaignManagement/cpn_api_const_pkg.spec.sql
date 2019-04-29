create or replace package cpn_api_const_pkg is

ENTITY_TYPE_CAMPAIGN            constant com_api_type_pkg.t_dict_value   := 'ENTTCMPN';

PARAM_NAME_CAMPAIGN_ID          constant com_api_type_pkg.t_name         := 'CAMPAIGN_ID';
PARAM_NAME_INST_ID              constant com_api_type_pkg.t_name         := 'INST_ID';
PARAM_NAME_CAMPAIGN_TYPE        constant com_api_type_pkg.t_name         := 'CAMPAIGN_TYPE';

CAMPAIGN_TYPE_DICTIONARY        constant com_api_type_pkg.t_dict_value   := 'CPNT';
CAMPAIGN_TYPE_PRODUCT_CAMPAIGN  constant com_api_type_pkg.t_dict_value   := 'CPNTPROD';
CAMPAIGN_TYPE_PROMO_CAMPAIGN    constant com_api_type_pkg.t_dict_value   := 'CPNTPROM';

EVENT_PROMO_CMPGN_ATTR_CHANGE   constant com_api_type_pkg.t_dict_value   := 'EVNT4701';

CYCLE_TYPE_PROMO_CAMPAIGN       constant com_api_type_pkg.t_dict_value   := 'CYTP4701';

end;
/
