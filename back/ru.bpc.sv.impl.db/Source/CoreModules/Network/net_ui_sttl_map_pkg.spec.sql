create or replace package net_ui_sttl_map_pkg is
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
);

/*
 * Modify mapping of institutions and networks into settlement type
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
);

/*
 * Remove mapping of institutions and networks into settlement type
 * @param i_id                  Record identifier
 * @param i_seqnum              Sequence number
 */  
procedure remove (
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
);

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
  , i_mask_error            in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_oper_type             in com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_dict_value;

end;
/
