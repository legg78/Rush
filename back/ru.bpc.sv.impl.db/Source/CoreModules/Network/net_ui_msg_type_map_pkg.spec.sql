create or replace package net_ui_msg_type_map_pkg is

/*
 * Register new mapping network message types
 * @param o_id                  Mapping network message types identificator
 * @param o_seqnum              Sequence number
 * @param i_standard_id         Network standard
 * @param i_network_msg_type    Network message type
 * @param i_priority            Priority to choose message type
 * @param i_msg_type            Internal message type
 */  
    procedure add (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_network_msg_type    in com_api_type_pkg.t_attr_name
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_msg_type            in com_api_type_pkg.t_dict_value
    );

/*
 * Modify mapping network message types
 * @param i_id                  Mapping network message types identificator
 * @param io_seqnum             Sequence number
 * @param i_standard_id         Network standard
 * @param i_network_msg_type    Network message type
 * @param i_priority            Priority to choose message type
 * @param i_msg_type            Internal message type
 */  
    procedure modify (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_network_msg_type    in com_api_type_pkg.t_attr_name
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_msg_type            in com_api_type_pkg.t_dict_value
    );

/*
 * Remove mapping network message types
 * @param i_id                  Mapping network message types identificator
 * @param i_seqnum              Sequence number
 */  
    procedure remove (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

end; 
/
