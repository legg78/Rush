create or replace package prd_api_service_pkg is
/*********************************************************
 *  API for services of products <br />
 *  Created by Kopachev D. (kopachev@bpcbt.com)  at 20.10.2011 <br />
 *  Module: PRD_API_SERVICE_PKG <br />
 *  @headcom
 **********************************************************/

procedure add_service_log (
    i_service_object_id   in     com_api_type_pkg.t_medium_id
  , i_start_date          in     date
  , i_end_date            in     date
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
);

function get_active_service_id(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_attr_name           in     com_api_type_pkg.t_name
  , i_service_type_id     in     com_api_type_pkg.t_short_id     default null
  , i_split_hash          in     com_api_type_pkg.t_tiny_id      default null
  , i_eff_date            in     date
  , i_last_active         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_mask_error          in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_inst_id             in     com_api_type_pkg.t_inst_id      default null
) return com_api_type_pkg.t_short_id;

function get_active_service_id(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_attr_type           in     com_api_type_pkg.t_name
  , i_eff_date            in     date
) return com_api_type_pkg.t_short_id;

procedure change_service_status(
    i_id                  in     com_api_type_pkg.t_long_id
  , i_sysdate             in     date
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_enable_event_type   in     com_api_type_pkg.t_dict_value
  , i_disable_event_type  in     com_api_type_pkg.t_dict_value
  , i_forced              in     com_api_type_pkg.t_boolean
  , i_params              in     com_api_type_pkg.t_param_tab
  , i_split_hash          in     com_api_type_pkg.t_tiny_id       default null
);

procedure change_service_status(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_sysdate               in     date
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_enable_event_type     in     com_api_type_pkg.t_dict_value
  , i_disable_event_type    in     com_api_type_pkg.t_dict_value
  , i_forced                in     com_api_type_pkg.t_boolean
  , i_params                in     com_api_type_pkg.t_param_tab
  , i_split_hash            in     com_api_type_pkg.t_tiny_id     default null
  , i_need_postponed_event  in     com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , o_postponed_event          out evt_api_type_pkg.t_postponed_event
);

procedure change_service_object(
    i_service_id          in     com_api_type_pkg.t_tiny_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_params              in     com_api_type_pkg.t_param_tab
  , i_status              in     com_api_type_pkg.t_dict_value
);

procedure get_available_service_list(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_device_id           in     com_api_type_pkg.t_short_id
  , o_ref_cursor             out sys_refcursor
);

procedure get_service_parameters(
    i_service_id          in     com_api_type_pkg.t_short_id
  , o_ref_cursor             out sys_refcursor
);

procedure close_service(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id       default null
  , i_eff_date            in     date                             default null
  , i_service_id          in     com_api_type_pkg.t_tiny_id       default null
  , i_params              in     com_api_type_pkg.t_param_tab
);

/**************************************************
 * @return service's number is generated by the custom name format
 ***************************************************/
function generate_service_number(
    i_service_id          in     com_api_type_pkg.t_short_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_eff_date            in     date                             default null
) return com_api_type_pkg.t_name;

/**************************************************
 * @return service's ID by the service's number and institute's ID
 ***************************************************/
function get_service_id(
    i_service_number      in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_mask_error          in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id;

function get_service_type_id(
    i_attr_name           in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_short_id
result_cache;

function message_no_active_service(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_limit_type          in     com_api_type_pkg.t_name
  , i_eff_date            in     date
) return com_api_type_pkg.t_short_id;

function check_conditional_service(
    i_service_id         com_api_type_pkg.t_short_id
  , i_product_id         com_api_type_pkg.t_short_id
  , i_service_count      com_api_type_pkg.t_count
) return com_api_type_pkg.t_boolean;

procedure check_conditional_service(
    i_service_id         com_api_type_pkg.t_short_id
  , i_contract_id        com_api_type_pkg.t_medium_id
  , i_entity_type        com_api_type_pkg.t_dict_value
  , i_object_id          com_api_type_pkg.t_long_id
  , i_date               date
);

procedure update_service_object(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_contract_id       in      com_api_type_pkg.t_medium_id
);

function check_service_attached(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_service_type_id       in  com_api_type_pkg.t_short_id
  , i_eff_date              in  date                          default null
) return com_api_type_pkg.t_boolean;

function get_service_rec(
    i_service_id            in  com_api_type_pkg.t_short_id
) return prd_api_type_pkg.t_service  result_cache;

procedure check_service_is_attached(
    i_service_id    in com_api_type_pkg.t_medium_id
  , i_entity_type   in com_api_type_pkg.t_dict_value
  , i_object_id     in com_api_type_pkg.t_long_id
  , i_event_date    in date
);

end prd_api_service_pkg;
/
