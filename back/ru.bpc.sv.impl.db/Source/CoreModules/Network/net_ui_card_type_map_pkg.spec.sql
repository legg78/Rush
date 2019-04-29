create or replace package net_ui_card_type_map_pkg is
/*
 * The UI for card type map <br />
 * Created by Kopachev D.(kopachev@bpc.ru)  at 02.10.2009 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2010-06-30 15:04:48 +0400#$ <br />
 * Revision: $LastChangedRevision: 3792 $ <br />
 * Module: NET_UI_CARD_TYPE_MAP_PKG <br />
 * @headcom
 */

/*
 * Register new card type map
 * @param o_id                  Card type map identificator
 * @param o_seqnum              Sequence number
 * @param i_standard_id         Network standard
 * @param i_network_card_type   Code describing card type in payment network
 * @param i_priority            Priority to choose card type
 * @param i_card_type_id        Internal card type
 */  
    procedure add (
        o_id                    out com_api_type_pkg.t_short_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_network_card_type   in com_api_type_pkg.t_dict_value
        , i_country             in com_api_type_pkg.t_country_code default null
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_card_type_id        in com_api_type_pkg.t_tiny_id
    );

/*
 * Modify card type map
 * @param i_id                  Card type map identificator
 * @param io_seqnum             Sequence number
 * @param i_standard_id         Network standard
 * @param i_network_card_type   Code describing card type in payment network
 * @param i_priority            Priority to choose card type
 * @param i_card_type_id        Internal card type
 */  
    procedure modify (
        i_id                    in com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_network_card_type   in com_api_type_pkg.t_dict_value
        , i_country             in com_api_type_pkg.t_country_code default null
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_card_type_id        in com_api_type_pkg.t_tiny_id
    );

/*
 * Remove card type map
 * @param i_id                  Card type map identificator
 * @param i_seqnum              Sequence number
 */  
    procedure remove (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

end; 
/
