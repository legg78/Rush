create or replace package fcl_ui_fee_pkg as

procedure add_fee_type(
    io_fee_type         in out  com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_cycle_type        in      com_api_type_pkg.t_dict_value       default null
  , i_limit_type        in      com_api_type_pkg.t_dict_value       default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_need_length_type  in      com_api_type_pkg.t_boolean          default null
  , o_seqnum               out  com_api_type_pkg.t_seqnum
);

procedure modify_fee_type(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_need_length_type  in      com_api_type_pkg.t_boolean          default null
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
);

procedure remove_fee_type(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_fee_rate(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_rate_type         in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , o_fee_rate_id          out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
);

procedure modify_fee_rate(
    i_fee_rate_id       in      com_api_type_pkg.t_tiny_id
  , i_rate_type         in      com_api_type_pkg.t_dict_value
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
);

procedure remove_fee_rate(
    i_fee_rate_id       in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_fee(
    i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_fee_rate_calc     in      com_api_type_pkg.t_dict_value
  , i_fee_base_calc     in      com_api_type_pkg.t_dict_value
  , i_limit_id          in      com_api_type_pkg.t_long_id          default null
  , i_cycle_id          in      com_api_type_pkg.t_short_id         default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , o_fee_id               out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
);

procedure modify_fee(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_fee_rate_calc     in      com_api_type_pkg.t_dict_value
  , i_fee_base_calc     in      com_api_type_pkg.t_dict_value
  , i_limit_id          in      com_api_type_pkg.t_long_id
  , i_cycle_id          in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
);

procedure remove_fee(
    i_fee_id            in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_fee_tier(
    i_fee_id                in      com_api_type_pkg.t_short_id
  , i_fixed_rate            in      com_api_type_pkg.t_money
  , i_percent_rate          in      com_api_type_pkg.t_money
  , i_min_value             in      com_api_type_pkg.t_money
  , i_max_value             in      com_api_type_pkg.t_money
  , i_length_type           in      com_api_type_pkg.t_dict_value
  , i_sum_threshold         in      com_api_type_pkg.t_money
  , i_count_threshold       in      com_api_type_pkg.t_long_id
  , i_length_type_algorithm in      com_api_type_pkg.t_dict_value   default null
  , o_fee_tier_id              out  com_api_type_pkg.t_short_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
);

procedure modify_fee_tier(
    i_fee_tier_id           in      com_api_type_pkg.t_short_id
  , i_fixed_rate            in      com_api_type_pkg.t_money
  , i_percent_rate          in      com_api_type_pkg.t_money
  , i_min_value             in      com_api_type_pkg.t_money
  , i_max_value             in      com_api_type_pkg.t_money
  , i_length_type           in      com_api_type_pkg.t_dict_value
  , i_sum_threshold         in      com_api_type_pkg.t_money
  , i_count_threshold       in      com_api_type_pkg.t_long_id
  , i_length_type_algorithm in      com_api_type_pkg.t_dict_value      default null
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
);

procedure remove_fee_tier(
    i_fee_tier_id       in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

function get_fee_desc(
    i_fee_id            in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_full_desc;

end;
/
