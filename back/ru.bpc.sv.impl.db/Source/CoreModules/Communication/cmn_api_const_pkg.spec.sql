CREATE OR REPLACE package cmn_api_const_pkg is

    ENTITY_TYPE_CMN_PARAMETER           constant com_api_type_pkg.t_dict_value := 'ENTTSDPR';
    ENTITY_TYPE_CMN_STANDARD            constant com_api_type_pkg.t_dict_value := 'ENTTSTDR';
    ENTITY_TYPE_CMN_STANDARD_VERS       constant com_api_type_pkg.t_dict_value := 'ENTTSTVR';
    ENTITY_TYPE_CMN_DEVICE              constant com_api_type_pkg.t_dict_value := 'ENTTCMDV';
    ENTITY_TYPE_CMN_TCP_IP              constant com_api_type_pkg.t_dict_value := 'ENTTTCIP';

    STANDART_TYPE_NETW_COMM             constant com_api_type_pkg.t_dict_value := 'STDT0001';
    STANDART_TYPE_TERM_COMM             constant com_api_type_pkg.t_dict_value := 'STDT0002';
    STANDART_TYPE_NETW_CLEARING         constant com_api_type_pkg.t_dict_value := 'STDT0201';
    STANDART_TYPE_NETW_BASIC            constant com_api_type_pkg.t_dict_value := 'STDT0000';
    STANDART_TYPE_HSM                   constant com_api_type_pkg.t_dict_value := 'STDT0301';
    

    TCP_INITIATOR_HOST                  constant com_api_type_pkg.t_dict_value := 'TCPIHOST';
    TCP_INITIATOR_REMOTE                constant com_api_type_pkg.t_dict_value := 'TCPIREMT';

    COMMUN_PLUGIN_TCP_IP                constant com_api_type_pkg.t_dict_value := 'CMPLTCIP';
    COMMUN_PLUGIN_HTTP                  constant com_api_type_pkg.t_dict_value := 'CMPLHTTP';
    COMMUN_PLUGIN_WEB_SERVICE           constant com_api_type_pkg.t_dict_value := 'CMPLWSRV';

    EVENT_CONNECTION_SIGNED_OFF         constant com_api_type_pkg.t_dict_value := 'EVNT1903';
    EVENT_CONNECTION_SIGNED_ON          constant com_api_type_pkg.t_dict_value := 'EVNT1902';
    EVENT_CONNECTION_ESTABL             constant com_api_type_pkg.t_dict_value := 'EVNT1901';
    EVENT_CONNECTION_LOST               constant com_api_type_pkg.t_dict_value := 'EVNT1900';
    EVENT_CONNECTION_STAND_IN_ON        constant com_api_type_pkg.t_dict_value := 'EVNT1904';
    EVENT_CONNECTION_STAND_IN_OFF       constant com_api_type_pkg.t_dict_value := 'EVNT1905';

    STANDARD_ID_SVXP_DICT               constant com_api_type_pkg.t_tiny_id    := 1046;
    STANDARD_VERSION_ID_2_1             constant com_api_type_pkg.t_tiny_id    := 1095;

    STANDARD_ID_SV_FRONTEND             constant com_api_type_pkg.t_tiny_id    := 1053;

end;
/
