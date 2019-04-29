create or replace package body net_ui_card_type_map_pkg is

    procedure add (
        o_id                    out com_api_type_pkg.t_short_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_network_card_type   in com_api_type_pkg.t_dict_value
        , i_country             in com_api_type_pkg.t_country_code
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_card_type_id        in com_api_type_pkg.t_tiny_id
    ) is
    begin
        o_id := net_card_type_map_seq.nextval;
        o_seqnum := 1;
        
        insert into net_card_type_map_vw (
            id
            , seqnum
            , standard_id
            , network_card_type
            , country
            , priority
            , card_type_id
        ) values (
            o_id
            , o_seqnum
            , i_standard_id
            , i_network_card_type
            , i_country
            , i_priority
            , i_card_type_id
        );
    end;

    procedure modify (
        i_id                    in com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_network_card_type   in com_api_type_pkg.t_dict_value
        , i_country             in com_api_type_pkg.t_country_code
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_card_type_id        in com_api_type_pkg.t_tiny_id
    ) is
    begin
        update
            net_card_type_map_vw
        set
            seqnum = io_seqnum
            , standard_id = i_standard_id
            , network_card_type = i_network_card_type
            , country = i_country
            , priority = i_priority
            , card_type_id = i_card_type_id
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
    end;

    procedure remove (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            net_card_type_map_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            net_card_type_map_vw
        where
            id = i_id;
    end;

end; 
/
