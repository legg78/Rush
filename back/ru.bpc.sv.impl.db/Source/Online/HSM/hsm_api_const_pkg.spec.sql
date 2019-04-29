create or replace package hsm_api_const_pkg is

    ACTION_HSM_PERSONALIZATION          constant com_api_type_pkg.t_dict_value := 'HSMAPSWE';
    ACTION_HSM_AUTHORIZATION            constant com_api_type_pkg.t_dict_value := 'HSMAAURZ';

    HSM_MANUFACTURER_THALES             constant com_api_type_pkg.t_dict_value := 'HSMMTHAL';
    HSM_MANUFACTURER_SAFENET            constant com_api_type_pkg.t_dict_value := 'HSMMSAFE';

    HSM_CONN_STATUS_ACTIVE              constant com_api_type_pkg.t_dict_value := 'DCNSGOOD';
    HSM_CONN_STATUS_CONF_ERROR          constant com_api_type_pkg.t_dict_value := 'DCNSCFGE';
    HSM_CONN_STATUS_COMM_ERROR          constant com_api_type_pkg.t_dict_value := 'DCNSCOME';
    HSM_CONN_STATUS_UNDEFINED           constant com_api_type_pkg.t_dict_value := 'DCNSUDFN';

    ENTITY_TYPE_HSM                     constant com_api_type_pkg.t_dict_value := 'ENTTHSMD';

    RESULT_CODE_OK                      constant pls_integer :=  0;
    RESULT_CODE_COMMON_ERROR            constant pls_integer := -1;
    RESULT_CODE_CONNECTION_ERROR        constant pls_integer := -2;

end;
/
