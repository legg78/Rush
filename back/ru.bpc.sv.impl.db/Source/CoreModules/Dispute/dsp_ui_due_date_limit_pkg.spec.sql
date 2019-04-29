create or replace package dsp_ui_due_date_limit_pkg is
/**************************************************
 *  Dispute due date limits UI <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 02.12.2016 <br />
 *  Module: DSP_UI_DUE_DATE_LIMIT_PKG <br />
 *  @headcom
 ***************************************************/ 

/*
 * Get a due date limit for a dispute application.
 */
function get_due_date(
    i_message_type          in     com_api_type_pkg.t_dict_value
  , i_oper_date             in     date
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_standard_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_is_manual             in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_usage_code            in     com_api_type_pkg.t_byte_char     default null
) return date;

/*
 * Get a due date limit for a dispute application.
 */
function get_due_date(
    i_init_rule             in     com_api_type_pkg.t_tiny_id
  , i_oper_date             in     date
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_usage_code            in     com_api_type_pkg.t_byte_char     default null
) return date;

/*
 * Update value of dispute application element DUE_DATE, switch a notification cycle (optional).
 * @i_dispute_id     - it is used for searching an application if @i_appld_is is not specified
 * @i_expir_notif    - if TRUE then set/switch associated notification cycle
 * @i_due_date       - a base for calculation a new (updated) due date
 */
procedure update_due_date(
    i_dispute_id            in     com_api_type_pkg.t_long_id
  , i_appl_id               in     com_api_type_pkg.t_long_id
  , i_due_date              in     date
  , i_expir_notif           in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_mask_error            in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure add(
    i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_message_type          in     com_api_type_pkg.t_dict_value
  , i_is_incoming           in     com_api_type_pkg.t_boolean
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_respond_due_date      in     com_api_type_pkg.t_tiny_id       default null
  , i_resolve_due_date      in     com_api_type_pkg.t_tiny_id       default null
  , i_usage_code            in     com_api_type_pkg.t_boolean       default null
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , o_id                       out com_api_type_pkg.t_tiny_id
  , i_mask_error            in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE 
);

procedure modify(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_message_type          in     com_api_type_pkg.t_dict_value
  , i_is_incoming           in     com_api_type_pkg.t_boolean
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_respond_due_date      in     com_api_type_pkg.t_tiny_id       default null
  , i_resolve_due_date      in     com_api_type_pkg.t_tiny_id       default null
  , i_usage_code            in     com_api_type_pkg.t_boolean       default null
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_mask_error            in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure remove(
    i_id                    in     com_api_type_pkg.t_tiny_id  
);

end dsp_ui_due_date_limit_pkg;
/
