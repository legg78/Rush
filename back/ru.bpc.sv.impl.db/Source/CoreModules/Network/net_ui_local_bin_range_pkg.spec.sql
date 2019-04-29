create or replace package net_ui_local_bin_range_pkg is

/*
 * Register new local bin ranges
 * @param o_id                  Local bin ranges identificator
 * @param o_seqnum              Sequence number
 * @param i_pan_low             Range low value
 * @param i_pan_high            Range high value
 * @param i_pan_length          Card number length
 * @param i_priority            Priority
 * @param i_card_type_id        Card type identifier
 * @param i_country             Country code
 * @param i_iss_network_id      Network identifier
 * @param i_iss_inst_id         Institution identifier
 * @param i_card_network_id     Card owner network identifier
 * @param i_card_inst_id        Card owner institution identifier
 */  
    procedure add (
        o_id                    out com_api_type_pkg.t_short_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_pan_low             in com_api_type_pkg.t_card_number
        , i_pan_high            in com_api_type_pkg.t_card_number
        , i_pan_length          in com_api_type_pkg.t_tiny_id
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_card_type_id        in com_api_type_pkg.t_tiny_id
        , i_country             in com_api_type_pkg.t_country_code
        , i_iss_network_id      in com_api_type_pkg.t_tiny_id
        , i_iss_inst_id         in com_api_type_pkg.t_tiny_id
        , i_card_network_id     in com_api_type_pkg.t_tiny_id
        , i_card_inst_id        in com_api_type_pkg.t_tiny_id
    );

/*
 * Register local bin ranges
 * @param i_id                  Local bin ranges identificator
 * @param io_seqnum             Sequence number
 * @param i_pan_low             Range low value
 * @param i_pan_high            Range high value
 * @param i_pan_length          Card number length
 * @param i_priority            Priority
 * @param i_card_type_id        Card type identifier
 * @param i_country             Country code
 * @param i_iss_network_id      Network identifier
 * @param i_iss_inst_id         Institution identifier
 * @param i_card_network_id     Card owner network identifier
 * @param i_card_inst_id        Card owner institution identifier
 */  
    procedure modify (
        i_id                    in com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_pan_low             in com_api_type_pkg.t_card_number
        , i_pan_high            in com_api_type_pkg.t_card_number
        , i_pan_length          in com_api_type_pkg.t_tiny_id
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_card_type_id        in com_api_type_pkg.t_tiny_id
        , i_country             in com_api_type_pkg.t_country_code
        , i_iss_network_id      in com_api_type_pkg.t_tiny_id
        , i_iss_inst_id         in com_api_type_pkg.t_tiny_id
        , i_card_network_id     in com_api_type_pkg.t_tiny_id
        , i_card_inst_id        in com_api_type_pkg.t_tiny_id
    );

/*
 * Remove local bin ranges
 * @param i_id                  Local bin ranges identificator
 * @param i_seqnum              Sequence number
 */  
    procedure remove (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

end; 
/
