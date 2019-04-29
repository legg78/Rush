create or replace package body net_ui_local_bin_range_pkg is

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
    ) is
    begin
        if i_pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN_RANGE'
              , i_env_param1 => i_pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => i_pan_low
              , i_env_param4 => i_pan_high
              , i_env_param5 => i_iss_network_id
              , i_env_param6 => i_card_network_id
            );
        end if;

        o_id := net_local_bin_range_seq.nextval;
        o_seqnum := 1;
        
        insert into net_local_bin_range_vw (
            id
            , seqnum
            , pan_low
            , pan_high
            , pan_length
            , priority
            , card_type_id
            , country
            , iss_network_id
            , iss_inst_id
            , card_network_id
            , card_inst_id
        ) values (
            o_id
            , o_seqnum
            , i_pan_low
            , i_pan_high
            , i_pan_length
            , i_priority
            , i_card_type_id
            , i_country
            , i_iss_network_id
            , i_iss_inst_id
            , i_card_network_id
            , i_card_inst_id
        );
        
        net_api_bin_pkg.sync_local_bins;
    end;

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
    ) is
    begin
        if i_pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN_RANGE'
              , i_env_param1 => i_pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => i_pan_low
              , i_env_param4 => i_pan_high
              , i_env_param5 => i_iss_network_id
              , i_env_param6 => i_card_network_id
            );
        end if;

        update
            net_local_bin_range_vw
        set
            seqnum = io_seqnum
            , pan_low = i_pan_low
            , pan_high = i_pan_high
            , pan_length = i_pan_length
            , priority = i_priority
            , card_type_id = i_card_type_id
            , country = i_country
            , iss_network_id = i_iss_network_id
            , iss_inst_id = i_iss_inst_id
            , card_network_id = i_card_network_id
            , card_inst_id = i_card_inst_id
        where
            id = i_id;
        
        io_seqnum := io_seqnum + 1;

        net_api_bin_pkg.sync_local_bins;
    end;

    procedure remove (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            net_local_bin_range_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            net_local_bin_range_vw
        where
            id = i_id;

        net_api_bin_pkg.sync_local_bins;
    end;

end; 
/
