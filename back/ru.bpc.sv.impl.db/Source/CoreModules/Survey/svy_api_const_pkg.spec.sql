create or replace package svy_api_const_pkg is

ENTITY_TYPE_SURVEY           constant com_api_type_pkg.t_dict_value := 'ENTTSUVY';
ENTITY_TYPE_SURVEY_TAG       constant com_api_type_pkg.t_dict_value := 'ENTTSYTG';
ENTITY_TYPE_QUESTIONARY      constant com_api_type_pkg.t_dict_value := 'ENTTQSTN';

SURVEY_STATUS_ACTIVE         constant com_api_type_pkg.t_dict_value := 'SYST0000';
SURVEY_STATUS_CLOSE          constant com_api_type_pkg.t_dict_value := 'SYST0001';

QUESTIONARY_STATUS_ACTIVE    constant com_api_type_pkg.t_dict_value := 'QRST0000';
QUESTIONARY_STATUS_CLOSE     constant com_api_type_pkg.t_dict_value := 'QRST0001';

end svy_api_const_pkg;
/
