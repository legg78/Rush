create or replace package fcl_api_limit_pkg as
/*****************************************************************
* API for limits
* Created by Filimonov A.(filimonov@bpc.ru)  at 07.08.2009
* Last changed by $Author$
* $LastChangedDate::                           $
* Revision: $LastChangedRevision$
* Module: FCL_API_LIMIT_PKG
* @headcom
*****************************************************************/

procedure get_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_params               in      com_api_type_pkg.t_param_tab
  , io_currency            in out  com_api_type_pkg.t_curr_code
  , i_eff_date             in      date                               default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_inst_id              in      com_api_type_pkg.t_inst_id         default null
  , o_last_reset_date         out  date
  , o_count_curr              out  com_api_type_pkg.t_long_id 
  , o_count_limit             out  com_api_type_pkg.t_long_id 
  , o_sum_limit               out  com_api_type_pkg.t_money
  , o_sum_curr                out  com_api_type_pkg.t_money
); 
 
procedure switch_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_params               in      com_api_type_pkg.t_param_tab
  , i_count_value          in      com_api_type_pkg.t_long_id         default null
  , i_sum_value            in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code
  , i_eff_date             in      date                               default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_inst_id              in      com_api_type_pkg.t_inst_id         default null
  , i_check_overlimit      in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_switch_limit         in      com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
  , i_source_entity_type   in      com_api_type_pkg.t_dict_value      default null
  , i_source_object_id     in      com_api_type_pkg.t_long_id         default null
  , i_service_id           in      com_api_type_pkg.t_short_id        default null
  , i_test_mode            in      com_api_type_pkg.t_dict_value      default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
); 

procedure switch_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_params               in      com_api_type_pkg.t_param_tab
  , i_count_value          in      com_api_type_pkg.t_long_id         default null
  , i_sum_value            in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code
  , i_eff_date             in      date                               default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_inst_id              in      com_api_type_pkg.t_inst_id         default null
  , i_check_overlimit      in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_switch_limit         in      com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
  , i_source_entity_type   in      com_api_type_pkg.t_dict_value      default null
  , i_source_object_id     in      com_api_type_pkg.t_long_id         default null
  , o_sum_value               out  com_api_type_pkg.t_money
  , o_currency                out  com_api_type_pkg.t_curr_code
  , i_service_id           in      com_api_type_pkg.t_short_id        default null
  , i_test_mode            in      com_api_type_pkg.t_dict_value      default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
  , i_use_base_currency    in      com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
);

procedure switch_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_params               in      com_api_type_pkg.t_param_tab
  , i_count_value          in      com_api_type_pkg.t_long_id         default null
  , i_sum_value            in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code
  , i_eff_date             in      date                               default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_inst_id              in      com_api_type_pkg.t_inst_id         default null
  , i_check_overlimit      in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_switch_limit         in      com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
  , i_source_entity_type   in      com_api_type_pkg.t_dict_value      default null
  , i_source_object_id     in      com_api_type_pkg.t_long_id         default null
  , o_count_curr              out  com_api_type_pkg.t_long_id 
  , o_count_limit             out  com_api_type_pkg.t_long_id 
  , o_currency                out  com_api_type_pkg.t_curr_code
  , o_sum_value               out  com_api_type_pkg.t_money
  , o_sum_limit               out  com_api_type_pkg.t_money
  , o_sum_curr                out  com_api_type_pkg.t_money
  , i_service_id           in      com_api_type_pkg.t_short_id        default null
  , i_test_mode            in      com_api_type_pkg.t_dict_value      default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
  , i_use_base_currency    in      com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
); 

procedure zero_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_eff_date             in      date                               default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
); 

procedure add_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_eff_date             in      date                               default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_inst_id              in      com_api_type_pkg.t_inst_id
);

procedure remove_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
);

procedure flush_limit_buffer;

procedure put_limit_history (
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_count_value          in      com_api_type_pkg.t_long_id
  , i_sum_value            in      com_api_type_pkg.t_money
  , i_source_entity_type   in      com_api_type_pkg.t_dict_value
  , i_source_object_id     in      com_api_type_pkg.t_long_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
);

procedure get_limit_value(
    i_limit_id             in      com_api_type_pkg.t_long_id
  , o_sum_value               out  com_api_type_pkg.t_money
  , o_count_value             out  com_api_type_pkg.t_long_id
); 

function get_limit(
    i_limit_id          in      com_api_type_pkg.t_long_id
) return fcl_api_type_pkg.t_limit;

function get_sum_limit(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money;

function get_limit_currency(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_curr_code;

function get_sum_remainder(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money;

procedure rollback_limit_counters(
    i_source_entity_type   in      com_api_type_pkg.t_dict_value
  , i_source_object_id     in      com_api_type_pkg.t_long_id
);

procedure rollback_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_params               in      com_api_type_pkg.t_param_tab
  , i_sum_value            in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code       default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_inst_id              in      com_api_type_pkg.t_inst_id         default null
  , i_source_object_id     in      com_api_type_pkg.t_long_id         default null
);

procedure get_limit_border(
    i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_limit_base           in      com_api_type_pkg.t_dict_value
  , i_limit_rate           in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code
  , i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_lock_balance         in      com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , o_border_sum              out  com_api_type_pkg.t_money
  , o_border_cnt              out  com_api_type_pkg.t_long_id
);

function get_limit_border_sum(
    i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_limit_base           in      com_api_type_pkg.t_dict_value
  , i_limit_rate           in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code
  , i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money;

function get_limit_border_count(
    i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_limit_base           in      com_api_type_pkg.t_dict_value
  , i_limit_rate           in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code
  , i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

function get_count_limit(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id; 

function get_limit_count_curr(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_limit_id             in      com_api_type_pkg.t_long_id         default null   
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

function get_limit_sum_curr(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_limit_id             in      com_api_type_pkg.t_long_id         default null   
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null          
  , i_product_id           in      com_api_type_pkg.t_short_id        default null
) return com_api_type_pkg.t_money;

procedure set_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_count_value          in      com_api_type_pkg.t_long_id
  , i_sum_value            in      com_api_type_pkg.t_money
  , i_eff_date             in      date                               default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_inst_id              in      com_api_type_pkg.t_inst_id         default null
  , i_allow_insert         in      com_api_type_pkg.t_inst_id         default com_api_const_pkg.FALSE
); 

function check_overlimit(
    i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_limit_type           in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

end fcl_api_limit_pkg;
/
