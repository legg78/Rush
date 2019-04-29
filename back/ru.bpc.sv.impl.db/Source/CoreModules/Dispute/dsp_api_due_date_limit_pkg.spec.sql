create or replace package dsp_api_due_date_limit_pkg is
/**************************************************
 *  Dispute due date limits API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 02.12.2016 <br />
 *  Module: DSP_API_DUE_DATE_LIMIT_PKG <br />
 *  @headcom
 ***************************************************/

/*
 * Get a due date limit for a dispute application.
 */
function get_due_date(
    i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_message_type          in     com_api_type_pkg.t_dict_value
  , i_eff_date              in     date
  , i_is_incoming           in     com_api_type_pkg.t_boolean
  , i_usage_code            in     com_api_type_pkg.t_byte_char  default null
  , i_reason_code           in     com_api_type_pkg.t_dict_value default null
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

end;
/
