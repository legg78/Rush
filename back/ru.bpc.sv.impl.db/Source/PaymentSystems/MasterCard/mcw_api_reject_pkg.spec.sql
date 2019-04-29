create or replace package mcw_api_reject_pkg is

procedure create_incoming_file_reject (
    i_mes_rec                in     mcw_api_type_pkg.t_mes_rec
  , i_file_id                in     com_api_type_pkg.t_short_id
  , i_network_id             in     com_api_type_pkg.t_tiny_id
  , i_host_id                in     com_api_type_pkg.t_tiny_id
  , i_standard_id            in     com_api_type_pkg.t_tiny_id
  , i_create_rev_reject      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
);

procedure create_incoming_msg_reject (
    i_mes_rec                in     mcw_api_type_pkg.t_mes_rec
  , i_next_mes_rec           in     mcw_api_type_pkg.t_mes_rec
  , i_file_id                in     com_api_type_pkg.t_short_id
  , i_network_id             in     com_api_type_pkg.t_tiny_id
  , i_host_id                in     com_api_type_pkg.t_tiny_id
  , i_standard_id            in     com_api_type_pkg.t_tiny_id
  , i_validate_record        in     com_api_type_pkg.t_boolean
  , o_rejected_msg_found        out com_api_type_pkg.t_boolean
  , i_create_rev_reject      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
);

function validate_mcw_record (
    i_reject_data_id         in     com_api_type_pkg.t_long_id
  , i_mcw_rec                in     mcw_api_type_pkg.t_mes_rec
  , i_pds_tab                in     mcw_api_type_pkg.t_pds_tab
) return com_api_type_pkg.t_boolean;

-- creates reversal operation, register reject event, set oper_status = REJECTED (OPST700), register oper stage = REJECTED
procedure finalize_rejected_oper (
    i_oper_id                in     com_api_type_pkg.t_long_id
);

procedure validate_mcw_record_auth(
    i_oper_id                in     com_api_type_pkg.t_long_id
  , i_mes_rec                in     mcw_api_type_pkg.t_mes_rec
  , i_pds_tab                in     mcw_api_type_pkg.t_pds_tab
  , i_create_rev_reject      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
);

procedure create_reversal_operation (
    i_oper_id                in     com_api_type_pkg.t_long_id
);

function create_duplicate_operation (
    i_oper_id                in     com_api_type_pkg.t_long_id
  , i_fin_msg_type           in     com_api_type_pkg.t_text -- visa, mastercard
  , i_create_reversal        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id ;

end;
/
