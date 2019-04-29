create or replace package fcl_ui_cycle_pkg as

procedure add_cycle_type(
    io_cycle_type           in out com_api_type_pkg.t_dict_value
  , i_short_desc            in     com_api_type_pkg.t_short_desc
  , i_full_desc             in     com_api_type_pkg.t_full_desc
  , i_cycle_calc_start_date in     com_api_type_pkg.t_dict_value
  , i_cycle_calc_date_type  in     com_api_type_pkg.t_dict_value
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_is_repeating          in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_is_standard           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
);

procedure modify_cycle_type (
    i_cycle_type            in     com_api_type_pkg.t_dict_value
  , i_is_repeating          in     com_api_type_pkg.t_boolean
  , i_is_standard           in     com_api_type_pkg.t_boolean
  , i_cycle_calc_start_date in     com_api_type_pkg.t_dict_value
  , i_cycle_calc_date_type  in     com_api_type_pkg.t_dict_value
);

procedure remove_cycle_type(
    i_cycle_type            in     com_api_type_pkg.t_dict_value
);

procedure add_cycle(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_cycle_length      in      com_api_type_pkg.t_tiny_id
  , i_trunc_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_workdays_only     in      com_api_type_pkg.t_boolean
  , o_cycle_id             out  com_api_type_pkg.t_short_id
);

procedure modify_cycle(
    i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_cycle_length      in      com_api_type_pkg.t_tiny_id
  , i_trunc_type        in      com_api_type_pkg.t_dict_value
  , i_workdays_only     in      com_api_type_pkg.t_boolean
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure remove_cycle(
    i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_cycle_shift(
    i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_shift_type        in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
  , i_shift_sign        in      com_api_type_pkg.t_sign
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_shift_length      in      com_api_type_pkg.t_tiny_id
  , o_cycle_shift_id       out  com_api_type_pkg.t_short_id
);

procedure modify_cycle_shift(
    i_cycle_shift_id    in      com_api_type_pkg.t_short_id
  , i_shift_type        in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
  , i_shift_sign        in      com_api_type_pkg.t_sign
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_shift_length      in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure remove_cycle_shift(
    i_cycle_shift_id    in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

function get_cycle_desc(
    i_cycle_id          in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name;

procedure modify_cycle_counter(
    i_counter_id        in      com_api_type_pkg.t_short_id
  , i_next_date         in      date
);

end;
/
