create or replace package fcl_api_cycle_pkg as
/************************************************************
 * The API for cycles <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010 <br />
 * Module: FCL_API_CYCLE_PKG <br />
 * @headcom
 ************************************************************/

procedure calc_next_date(
    i_cycle_id             in     com_api_type_pkg.t_short_id
  , i_start_date           in     date                            default null
  , i_forward              in     com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , o_next_date               out date
  , i_cycle_calc_date_type in     com_api_type_pkg.t_dict_value   default null
  , i_object_params        in     com_api_type_pkg.t_param_tab    default cast(null as com_api_type_pkg.t_param_tab)
);

function calc_next_date(
    i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_start_date        in      date                            default null
  , i_forward           in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_raise_error       in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) return date;

function calc_next_date(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_start_date        in      date                            default null
  , i_eff_date          in      date                            default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_forward           in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_raise_error       in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_product_id        in      com_api_type_pkg.t_short_id     default null
) return date;

procedure switch_cycle(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_start_date        in      date                            default null
  , i_eff_date          in      date                            default null
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , o_new_finish_date      out  date
  , i_test_mode         in      com_api_type_pkg.t_dict_value   default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
  , i_forward           in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_cycle_id          in      com_api_type_pkg.t_short_id     default null
);

procedure get_cycle_date(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_add_counter       in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , o_prev_date            out  date
  , o_next_date            out  date
);

-- This procedure updates next cycle date .This is needed for example after merchant product is changed.
procedure add_cycle_counter(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_next_date         in      date                            default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure remove_cycle_counter(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
);

/**********************************************************
 * Reset cycle counter - set next date into null
 *********************************************************/
procedure reset_cycle_counter(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
);

end fcl_api_cycle_pkg;
/
