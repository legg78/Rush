create or replace package evt_api_const_pkg as

    INITIATOR_KEY                  constant    com_api_type_pkg.t_dict_value := 'ENSI';
    INITIATOR_OPERATOR             constant    com_api_type_pkg.t_dict_value := 'ENSIOPER';
    INITIATOR_CLIENT               constant    com_api_type_pkg.t_dict_value := 'ENSICLNT';
    INITIATOR_SYSTEM               constant    com_api_type_pkg.t_dict_value := 'ENSISSTM';

    EVENT_STATUS_KEY               constant    com_api_type_pkg.t_dict_value := 'EVST';
    EVENT_STATUS_READY             constant    com_api_type_pkg.t_dict_value := 'EVST0001';
    EVENT_STATUS_PROCESSED         constant    com_api_type_pkg.t_dict_value := 'EVST0002';
    EVENT_STATUS_DO_NOT_PROCES     constant    com_api_type_pkg.t_dict_value := 'EVST0003';

    EVENT_OBJ_LOAD_STATUS_KEY      constant    com_api_type_pkg.t_dict_value := 'EOLS';
    EVENT_OBJ_LOAD_ST_ALL          constant    com_api_type_pkg.t_dict_value := 'EOLSALL';
    EVENT_OBJ_LOAD_ST_ALREADY_LOAD constant    com_api_type_pkg.t_dict_value := 'EOLSALLD';
    EVENT_OBJ_LOAD_ST_NOT_LOADED   constant    com_api_type_pkg.t_dict_value := 'EOLSNOTL';

    EVENT_KEY                      constant    com_api_type_pkg.t_dict_value := 'EVNT';

    LOV_ID_EVENT_TYPES             constant    com_api_type_pkg.t_tiny_id    := 87;

    AMOUNT_SELECTION_ALGORITH_MAX  constant    com_api_type_pkg.t_dict_value := 'ASADMAXA';
    AMOUNT_SELECTION_ALGORITH_MIN  constant    com_api_type_pkg.t_dict_value := 'ASADMINA';

    ENTITY_TYPE_EVENT              constant    com_api_type_pkg.t_dict_value := 'ENTT0067';

end;
/
