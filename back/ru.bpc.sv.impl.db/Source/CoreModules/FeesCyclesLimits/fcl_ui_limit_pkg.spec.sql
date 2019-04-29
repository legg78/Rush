create or replace package fcl_ui_limit_pkg as

/***********************************************************
* User interface prcedures for limits
*
* Created by Filimonov A.(filimonov@bpc.ru)  at 07.08.2009
* Last changed by $Author$
* $LastChangedDate::                           $
* Revision: $LastChangedRevision$
* Module: FCL_UI_LIMIT_PKG
* @headcom
***********************************************************/

procedure add_limit_type(
    io_limit_type       in out  com_api_type_pkg.t_dict_value
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_is_internal       in      com_api_type_pkg.t_boolean
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_posting_method    in      com_api_type_pkg.t_dict_value   default null
  , i_counter_algorithm in      com_api_type_pkg.t_dict_value   default null
  , o_limit_type_id        out  com_api_type_pkg.t_tiny_id
  , i_limit_usage       in      com_api_type_pkg.t_dict_value   default null
);

procedure modify_limit_type(
    i_limit_type_id     in      com_api_type_pkg.t_tiny_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_is_internal       in      com_api_type_pkg.t_boolean
  , i_seqnum            in      com_api_type_pkg.t_seqnum
  , i_posting_method    in      com_api_type_pkg.t_dict_value   default null
  , i_counter_algorithm in      com_api_type_pkg.t_dict_value   default null
);

/***********************************************************
* Remove limit type
* @param i_limit_type_id Identifier of limit type to remove
***********************************************************/
procedure remove_limit_type(
    i_limit_type_id  in      com_api_type_pkg.t_tiny_id
  , i_seqnum         in      com_api_type_pkg.t_seqnum
);

procedure add_limit_rate(
    i_limit_type     in      com_api_type_pkg.t_dict_value
  , i_rate_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , o_limit_rate_id     out  com_api_type_pkg.t_tiny_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
);

procedure modify_limit_rate(
    i_limit_rate_id  in      com_api_type_pkg.t_tiny_id
  , i_rate_type      in      com_api_type_pkg.t_dict_value
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
);

procedure remove_limit_rate(
    i_limit_rate_id  in      com_api_type_pkg.t_tiny_id
  , i_seqnum         in      com_api_type_pkg.t_seqnum
);

procedure add_limit(
    i_limit_type     in      com_api_type_pkg.t_dict_value
  , i_cycle_id       in      com_api_type_pkg.t_short_id
  , i_count_limit    in      com_api_type_pkg.t_long_id
  , i_sum_limit      in      com_api_type_pkg.t_money
  , i_currency       in      com_api_type_pkg.t_curr_code
  , i_posting_method in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_is_custom      in      com_api_type_pkg.t_boolean      default null
  , i_limit_base     in      com_api_type_pkg.t_dict_value
  , i_limit_rate     in      com_api_type_pkg.t_money
  , i_check_type     in      com_api_type_pkg.t_dict_value   default null
  , i_counter_algorithm in   com_api_type_pkg.t_dict_value   default null
  , o_limit_id          out  com_api_type_pkg.t_long_id
  , i_count_max_bound   in      com_api_type_pkg.t_long_id   default null
  , i_sum_max_bound     in      com_api_type_pkg.t_money     default null
);

procedure modify_limit(
    i_limit_id       in      com_api_type_pkg.t_long_id
  , i_cycle_id       in      com_api_type_pkg.t_short_id
  , i_count_limit    in      com_api_type_pkg.t_long_id
  , i_sum_limit      in      com_api_type_pkg.t_money
  , i_currency       in      com_api_type_pkg.t_curr_code
  , i_posting_method in      com_api_type_pkg.t_dict_value
  , i_seqnum         in      com_api_type_pkg.t_seqnum
  , i_limit_base     in      com_api_type_pkg.t_dict_value
  , i_limit_rate     in      com_api_type_pkg.t_money
  , i_check_type     in      com_api_type_pkg.t_dict_value     default null    
  , i_counter_algorithm in   com_api_type_pkg.t_dict_value     default null
  , i_count_max_bound   in      com_api_type_pkg.t_long_id     default null
  , i_sum_max_bound     in      com_api_type_pkg.t_money       default null
);

procedure remove_limit(
    i_limit_id       in      com_api_type_pkg.t_long_id
  , i_seqnum         in      com_api_type_pkg.t_seqnum
);

function get_limit_desc(
    i_limit_id       in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name;

procedure get_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id         default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_map         in      com_param_map_tpt
  , io_currency         in out  com_api_type_pkg.t_curr_code
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , o_last_reset_date      out  date
  , o_count_curr           out  com_api_type_pkg.t_long_id
  , o_count_limit          out  com_api_type_pkg.t_long_id
  , o_sum_limit            out  com_api_type_pkg.t_money
  , o_sum_curr             out  com_api_type_pkg.t_money
);

procedure switch_limit_counter(
    i_limit_type         in      com_api_type_pkg.t_dict_value
  , i_product_id         in      com_api_type_pkg.t_short_id         default null
  , i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_param_map          in      com_param_map_tpt
  , i_count_value        in      com_api_type_pkg.t_long_id          default null
  , i_sum_value          in      com_api_type_pkg.t_money
  , i_currency           in      com_api_type_pkg.t_curr_code
  , i_eff_date           in      date                                default null
  , i_split_hash         in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id            in      com_api_type_pkg.t_inst_id          default null
  , i_check_overlimit    in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_switch_limit       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_source_entity_type in      com_api_type_pkg.t_dict_value       default null
  , i_source_object_id   in      com_api_type_pkg.t_long_id          default null
  , i_service_id         in      com_api_type_pkg.t_short_id         default null
  , i_test_mode          in      com_api_type_pkg.t_dict_value       default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
);

procedure switch_limit_counter(
    i_limit_type         in      com_api_type_pkg.t_dict_value
  , i_product_id         in      com_api_type_pkg.t_short_id         default null
  , i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_param_map          in      com_param_map_tpt
  , i_count_value        in      com_api_type_pkg.t_long_id          default null
  , i_sum_value          in      com_api_type_pkg.t_money
  , i_currency           in      com_api_type_pkg.t_curr_code
  , i_eff_date           in      date                                default null
  , i_split_hash         in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id            in      com_api_type_pkg.t_inst_id          default null
  , i_check_overlimit    in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_switch_limit       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_source_entity_type in      com_api_type_pkg.t_dict_value       default null
  , i_source_object_id   in      com_api_type_pkg.t_long_id          default null
  , i_service_id         in      com_api_type_pkg.t_short_id         default null
  , i_test_mode          in      com_api_type_pkg.t_dict_value       default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
  , o_overlimit             out  com_api_type_pkg.t_boolean
);

function get_limit_id(
    i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_limit_type         in      com_api_type_pkg.t_dict_value
  , i_inst_id            in      com_api_type_pkg.t_inst_id          default null
  , i_split_hash         in      com_api_type_pkg.t_tiny_id          default null
) return com_api_type_pkg.t_long_id;

procedure get_limit_counters(
    i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id          default null
  , i_split_hash         in      com_api_type_pkg.t_tiny_id          default null
  , o_ref_cursor         out     sys_refcursor  
);

end;
/
