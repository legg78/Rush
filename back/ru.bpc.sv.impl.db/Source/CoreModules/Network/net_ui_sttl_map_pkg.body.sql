create or replace package body net_ui_sttl_map_pkg is
/*
 * Register new mapping of institutions and networks into settlement type
 * @param o_id                  Record identifier
 * @param o_seqnum              Sequence number
 * @param i_iss_inst_id         Issuer institution identifier
 * @param i_iss_network_id      Issuer network identifier
 * @param i_acq_inst_id         Acquirer institution identifier
 * @param i_acq_network_id      Acquirer network identifier
 * @param i_card_inst_id        Card owner institution identifier
 * @param i_card_network_id     Card owner network identifier
 * @param i_priority            Priority
 * @param i_sttl_type           Settlement type
 */
procedure add (
    o_id                    out com_api_type_pkg.t_tiny_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_iss_inst_id         in com_api_type_pkg.t_inst_id
    , i_iss_network_id      in com_api_type_pkg.t_inst_id
    , i_acq_inst_id         in com_api_type_pkg.t_inst_id
    , i_acq_network_id      in com_api_type_pkg.t_inst_id
    , i_card_inst_id        in com_api_type_pkg.t_inst_id
    , i_card_network_id     in com_api_type_pkg.t_inst_id
    , i_mod_id              in com_api_type_pkg.t_tiny_id
    , i_priority            in com_api_type_pkg.t_tiny_id
    , i_sttl_type           in com_api_type_pkg.t_dict_value
    , i_match_status        in com_api_type_pkg.t_dict_value
    , i_oper_type           in com_api_type_pkg.t_dict_value    default null
) is
begin
    o_id := net_sttl_map_seq.nextval;
    o_seqnum := 1;

    insert into net_sttl_map_vw (
        id
        , seqnum
        , iss_inst_id
        , iss_network_id
        , acq_inst_id
        , acq_network_id
        , card_inst_id
        , card_network_id
        , mod_id
        , priority
        , sttl_type
        , match_status
        , oper_type
    ) values (
        o_id
        , o_seqnum
        , i_iss_inst_id
        , i_iss_network_id
        , i_acq_inst_id
        , i_acq_network_id
        , i_card_inst_id
        , i_card_network_id
        , i_mod_id
        , i_priority
        , i_sttl_type
        , i_match_status
        , i_oper_type
    );
end;

procedure modify (
    i_id                    in com_api_type_pkg.t_tiny_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_iss_inst_id         in com_api_type_pkg.t_inst_id
    , i_iss_network_id      in com_api_type_pkg.t_inst_id
    , i_acq_inst_id         in com_api_type_pkg.t_inst_id
    , i_acq_network_id      in com_api_type_pkg.t_inst_id
    , i_card_inst_id        in com_api_type_pkg.t_inst_id
    , i_card_network_id     in com_api_type_pkg.t_inst_id
    , i_mod_id              in com_api_type_pkg.t_tiny_id
    , i_priority            in com_api_type_pkg.t_tiny_id
    , i_sttl_type           in com_api_type_pkg.t_dict_value
    , i_match_status        in com_api_type_pkg.t_dict_value
    , i_oper_type           in com_api_type_pkg.t_dict_value    default null
) is
begin
    update
        net_sttl_map_vw
    set
        seqnum = io_seqnum
        , iss_inst_id = i_iss_inst_id
        , iss_network_id = i_iss_network_id
        , acq_inst_id = i_acq_inst_id
        , acq_network_id = i_acq_network_id
        , card_inst_id = i_card_inst_id
        , card_network_id = i_card_network_id
        , mod_id = i_mod_id
        , priority = i_priority
        , sttl_type = i_sttl_type
        , match_status = i_match_status
        , oper_type = i_oper_type
    where
        id = i_id;
            
    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
) is
begin
    update
        net_sttl_map_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;
            
    delete from
        net_sttl_map_vw
    where
        id = i_id;
end;

/*
 * Returns settlement type by operation's participants data. 
 */
function get_sttl_type(
    i_iss_inst_id           in com_api_type_pkg.t_inst_id
  , i_acq_inst_id           in com_api_type_pkg.t_inst_id
  , i_card_inst_id          in com_api_type_pkg.t_inst_id
  , i_iss_network_id        in com_api_type_pkg.t_tiny_id
  , i_acq_network_id        in com_api_type_pkg.t_tiny_id
  , i_card_network_id       in com_api_type_pkg.t_tiny_id
  , i_acq_inst_bin          in com_api_type_pkg.t_rrn
  , i_mask_error            in com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_oper_type             in com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_dict_value
is
    l_sttl_type             com_api_type_pkg.t_dict_value;
    l_match_status          com_api_type_pkg.t_dict_value;
begin
    net_api_sttl_pkg.get_sttl_type(
        i_iss_inst_id     => i_iss_inst_id
      , i_acq_inst_id     => i_acq_inst_id
      , i_card_inst_id    => i_card_inst_id
      , i_iss_network_id  => i_iss_network_id
      , i_acq_network_id  => i_acq_network_id
      , i_card_network_id => i_card_network_id
      , i_acq_inst_bin    => i_acq_inst_bin
      , o_sttl_type       => l_sttl_type
      , o_match_status    => l_match_status
      , i_mask_error      => i_mask_error
      , i_oper_type       => i_oper_type
    );
    return l_sttl_type;
end get_sttl_type;

end; 
/
