create or replace package ntf_api_message_pkg is

    procedure create_message (
        o_id                        out com_api_type_pkg.t_long_id
        , i_channel_id              in com_api_type_pkg.t_tiny_id
        , i_text                    in clob
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_delivery_address        in com_api_type_pkg.t_full_desc
        , i_delivery_date           in date := null
        , i_urgency_level           in com_api_type_pkg.t_tiny_id := null
        , i_inst_id                 in com_api_type_pkg.t_tiny_id
        , i_event_type              in com_api_type_pkg.t_dict_value    default null
        , i_eff_date                in date                             default null
        , i_entity_type             in com_api_type_pkg.t_dict_value    default null
        , i_object_id               in com_api_type_pkg.t_long_id       default null
        , i_delivery_time           in com_api_type_pkg.t_name          default null
    );

end; 
/
