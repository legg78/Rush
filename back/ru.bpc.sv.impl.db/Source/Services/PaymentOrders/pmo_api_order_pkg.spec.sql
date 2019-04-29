create or replace package pmo_api_order_pkg as
/************************************************************
 * API for Payment Order<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 14.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_API_ORDER_PKG <br />
 * @headcom
 ************************************************************/

procedure add_order(
    o_id                            out com_api_type_pkg.t_long_id
  , i_customer_id               in      com_api_type_pkg.t_medium_id
  , i_entity_type               in      com_api_type_pkg.t_dict_value
  , i_object_id                 in      com_api_type_pkg.t_long_id
  , i_purpose_id                in      com_api_type_pkg.t_short_id
  , i_template_id               in      com_api_type_pkg.t_tiny_id
  , i_amount                    in      com_api_type_pkg.t_money
  , i_currency                  in      com_api_type_pkg.t_curr_code
  , i_event_date                in      date
  , i_status                    in      com_api_type_pkg.t_dict_value
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_attempt_count             in      com_api_type_pkg.t_tiny_id
  , i_is_prepared_order         in      com_api_type_pkg.t_boolean
  , i_is_template               in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_dst_customer_id           in      com_api_type_pkg.t_medium_id    default null
  , i_in_purpose_id             in      com_api_type_pkg.t_medium_id    default null
  , i_split_hash                in      com_api_type_pkg.t_tiny_id      default null
  , i_payment_order_number      in      com_api_type_pkg.t_name         default null
  , i_expiration_date           in      date                            default null
  , i_resp_code                 in      com_api_type_pkg.t_dict_value   default null
  , i_resp_amount               in      com_api_type_pkg.t_money        default null
  , i_order_originator_refnum   in      com_api_type_pkg.t_rrn          default null
);

procedure register_payment(
    i_purpose_id         in     com_api_type_pkg.t_short_id
  , i_auth_id            in     com_api_type_pkg.t_long_id
  , i_template_id        in     com_api_type_pkg.t_medium_id := null
  , o_order_id              out com_api_type_pkg.t_long_id
  , o_response_code         out com_api_type_pkg.t_dict_value
);

procedure choose_host(
    i_purpose_id         in     com_api_type_pkg.t_short_id
  , i_network_id         in     com_api_type_pkg.t_tiny_id    default null
  , i_host_prev          in     com_api_type_pkg.t_tiny_id    default null
  , i_change_reason      in     com_api_type_pkg.t_dict_value default null
  , i_original_id        in     com_api_type_pkg.t_long_id    default null
  , i_amount             in     com_api_type_pkg.t_money      default null
  , i_currency           in     com_api_type_pkg.t_curr_code  default null
  , i_choose_host_mode   in     com_api_type_pkg.t_dict_value
  , io_execution_type    in out com_api_type_pkg.t_dict_value
  , o_host_member_id        out com_api_type_pkg.t_tiny_id
  , o_host_next             out com_api_type_pkg.t_boolean
  , o_response_code         out com_api_type_pkg.t_dict_value
);

procedure register_payment_parameter(
    i_order_id           in     com_api_type_pkg.t_long_id
  , i_purpose_id         in     com_api_type_pkg.t_short_id     default null
  , i_param_id_tab       in     com_api_type_pkg.t_number_tab
  , i_param_val_tab      in     com_api_type_pkg.t_desc_tab
);

procedure register_payment_parameter_web(
    i_order_id      in      com_api_type_pkg.t_long_id
  , i_purpose_id    in      com_api_type_pkg.t_short_id         default null
  , i_params        in      com_param_map_tpt
);

procedure add_order_detail (
    i_order_id      in     com_api_type_pkg.t_long_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_object_id     in     com_api_type_pkg.t_long_id
);

procedure register_payment (
    i_event_type    in     com_api_type_pkg.t_dict_value
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_object_id     in     com_api_type_pkg.t_long_id
  , i_event_date    in     date
);

function get_order_data_value(
    i_order_id      in      com_api_type_pkg.t_long_id
  , i_param_name    in      com_api_type_pkg.t_name
  , i_direction     in      com_api_type_pkg.t_sign                 default null
) return com_api_type_pkg.t_param_value;

procedure add_schedule(
    o_id                       out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_order_id              in      com_api_type_pkg.t_long_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_amount_algorithm      in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_attempt_limit         in      com_api_type_pkg.t_tiny_id      default null
  , i_cycle_id              in      com_api_type_pkg.t_long_id      default null
);

procedure modify_schedule(
    i_id                    in      com_api_type_pkg.t_medium_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_amount_algorithm      in      com_api_type_pkg.t_dict_value   default null
  , i_attempt_limit         in      com_api_type_pkg.t_tiny_id      default null
  , i_cycle_id              in      com_api_type_pkg.t_long_id      default null
  , i_event_type            in      com_api_type_pkg.t_dict_value   default null
);

procedure add_order_data(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_param_name            in      com_api_type_pkg.t_name
  , i_param_value           in      com_api_type_pkg.t_param_value
  , i_purpose_id            in      com_api_type_pkg.t_short_id     default null
);

procedure set_order_status(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value
);

procedure set_attempt_count(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_attempt_count         in      com_api_type_pkg.t_tiny_id
);

procedure set_order_amount(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_amount_rec            in      com_api_type_pkg.t_amount_rec
);

procedure get_own_template(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , o_template_tab             out  com_api_type_pkg.t_auth_long_tab
  , o_template_name_tab        out  com_api_type_pkg.t_name_tab
);

procedure set_order_purpose (
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_direction             in      com_api_type_pkg.t_sign         default null
);

procedure calc_order_amount(
    i_amount_algorithm      in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date
  , i_template_id           in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_original_order_rec    in      pmo_api_type_pkg.t_payment_order_rec    default null
  , i_order_id              in      com_api_type_pkg.t_long_id
  , io_amount               in out  com_api_type_pkg.t_amount_rec
);

procedure calc_order_amount_fixed(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_template_id           in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , io_amount               in out  com_api_type_pkg.t_amount_rec
);

procedure get_order_list(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_status                in     com_api_type_pkg.t_dict_value
  , i_service_provider_id   in     com_api_type_pkg.t_short_id default null
  , o_order_list               out sys_refcursor
);

procedure get_order_list_count(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_status                in     com_api_type_pkg.t_dict_value
  , i_service_provider_id   in     com_api_type_pkg.t_short_id default null
  , o_order_list_count         out com_api_type_pkg.t_long_id
);

procedure get_order_parameters(
    i_order_id              in      com_api_type_pkg.t_long_id
  , o_order_parameters          out sys_refcursor
);

procedure get_order_evt_list(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_subscriber_name       in     com_api_type_pkg.t_name
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , o_order_evt_list           out sys_refcursor
);

procedure get_order_evt_list_count(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_subscriber_name       in     com_api_type_pkg.t_name
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , o_order_evt_list_count     out com_api_type_pkg.t_long_id
);

function get_order(
    i_order_id          in   com_api_type_pkg.t_long_id
  , i_mask_error        in   com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) 
return pmo_api_type_pkg.t_payment_order_rec;

procedure process_pmo_response(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_resp_code             in      com_api_type_pkg.t_dict_value
  , i_resp_amount_rec       in      com_api_type_pkg.t_amount_rec
);

function check_is_pmo_expired(
    i_expiration_date   in      date
  , i_order_id          in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_tiny_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_boolean;

procedure add_order_with_params(
    io_payment_order_id     in out  com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_customer_id           in      com_api_type_pkg.t_medium_id default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_template_id           in      com_api_type_pkg.t_tiny_id
  , i_amount_rec            in      com_api_type_pkg.t_amount_rec
  , i_eff_date              in      date
  , i_order_status          in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_attempt_count         in      com_api_type_pkg.t_tiny_id
  , i_payment_order_number  in      com_api_type_pkg.t_name
  , i_expiration_date       in      date
  , i_register_event        in      com_api_type_pkg.t_boolean
  , i_is_prepared_order     in      com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
  , i_originator_refnum     in      com_api_type_pkg.t_rrn       default null
  , i_param_tab             in      com_api_type_pkg.t_param_tab
);

procedure add_order_with_params(
    io_payment_order_id     in out  com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_customer_id           in      com_api_type_pkg.t_medium_id default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_template_id           in      com_api_type_pkg.t_tiny_id
  , i_oper_id_tab           in      com_api_type_pkg.t_long_tab
  , i_eff_date              in      date
  , i_order_status          in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_attempt_count         in      com_api_type_pkg.t_tiny_id
  , i_payment_order_number  in      com_api_type_pkg.t_name
  , i_expiration_date       in      date
  , i_register_event        in      com_api_type_pkg.t_boolean
  , i_is_prepared_order     in      com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
  , i_originator_refnum     in      com_api_type_pkg.t_rrn       default null
  , io_param_tab            in out nocopy com_api_type_pkg.t_param_tab
);

function match_order_with_operation(
    i_originator_refnum     in      com_api_type_pkg.t_rrn
  , i_order_date            in      date
) return com_api_type_pkg.t_long_id;

procedure add_oper_to_prepared_order(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_oper_id               in      com_api_type_pkg.t_long_id
  , o_prepared_order_id        out  com_api_type_pkg.t_long_id
);

function check_purpose_exists(
    i_purpose_id                in      com_api_type_pkg.t_short_id
  , i_mask_error                in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_boolean;

function check_purpose_exists(
    i_purpose_number            in      com_api_type_pkg.t_name
  , i_mask_error                in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_boolean;

end pmo_api_order_pkg;
/
