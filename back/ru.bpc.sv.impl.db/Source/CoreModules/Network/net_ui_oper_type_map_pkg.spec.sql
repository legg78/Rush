create or replace package net_ui_oper_type_map_pkg is

/*
 * Register new mapping network operation types
 * @param o_id                  Mapping network operation types identificator
 * @param o_seqnum              Sequence number
 * @param i_standard_id         Network standard
 * @param i_network_oper_type   Network operation type
 * @param i_priority            Priority to choose operation type
 * @param i_oper_type           Internal operation type
 */  
    procedure add (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_network_oper_type   in com_api_type_pkg.t_dict_value
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_oper_type           in com_api_type_pkg.t_dict_value
    );

/*
 * Modify mapping network operation types
 * @param i_id                  Mapping network operation types identificator
 * @param io_seqnum             Sequence number
 * @param i_standard_id         Network standard
 * @param i_network_oper_type   Network operation type
 * @param i_priority            Priority to choose operation type
 * @param i_oper_type           Internal operation type
 */  
    procedure modify (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_network_oper_type   in com_api_type_pkg.t_dict_value
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_oper_type           in com_api_type_pkg.t_dict_value
    );

/*
 * Remove mapping network operation types
 * @param o_id                  Mapping network operation types identificator
 * @param o_seqnum              Sequence number
 */  
    procedure remove (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

end; 
/
