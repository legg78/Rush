create or replace package dsp_ui_process_pkg is
/************************************************************
 * API for Dispute User Interface <br />
 * Created by Maslov I.(maslov@bpcbt.com)  at 27.05.2013 <br />
 * Module: DSP_UI_PROCESS_PKG <br />
 * @headcom
 ***********************************************************/

procedure get_dispute_list(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_lang                    in     com_api_type_pkg.t_dict_value    default null
  , o_dispute_list               out com_api_type_pkg.t_ref_cur
);

function check_dispute_allow(
    i_id                      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

procedure prepare_dispute(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_proc_id                 in     com_api_type_pkg.t_short_id
  , i_lang                    in     com_api_type_pkg.t_dict_value    default null
  , i_is_editing              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , o_dispute_cur                out com_api_type_pkg.t_ref_cur
);

procedure exec_dispute(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_init_rule               in     com_api_type_pkg.t_tiny_id
  , i_gen_rule                in     com_api_type_pkg.t_tiny_id
  , i_param_map               in     com_param_map_tpt
  , i_is_editing              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

/*
 * Return true if such message type for duspute already exists.
 * @param i_oper_id       - Operation ID
 * @param i_msg_type      - Message type
 * @param i_param_map     - Value list of the Dispute parameters
 */
function check_duplicated_message(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_param_map               in     com_param_map_tpt
) return com_api_type_pkg.t_boolean;

/*
 * Procedure generates and return a new dispute ID, incoming operation is marked with this ID.
 */
procedure initiate_dispute(
    i_oper_id                 in     com_api_type_pkg.t_long_id
  , o_dispute_id                 out com_api_type_pkg.t_long_id
);

/*
 * Getting dispute rules.
 */
procedure get_dispute_rule(
    i_id                      in     com_api_type_pkg.t_long_id
  , o_init_rule                  out com_api_type_pkg.t_tiny_id
  , o_gen_rule                   out com_api_type_pkg.t_tiny_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
);

/*
 * Save message into dsp_fin_message.
 */
procedure put_message(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_init_rule               in     com_api_type_pkg.t_tiny_id
  , i_gen_rule                in     com_api_type_pkg.t_tiny_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
);

/*
 * Remove dispute and related data
 */
procedure remove_dispute(
    i_id                      in     com_api_type_pkg.t_long_id
);

/*
 * Check if fin message is editable
 */  
function is_editable(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_boolean; 

function is_doc_export_import_enabled(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_boolean;

/*
 * Check if current mode is editing
 */  
function is_editing return com_api_type_pkg.t_boolean;

/*
 * Set operation id for new dispute message
 */  
procedure set_operation_id(
    i_oper_id    in     com_api_type_pkg.t_long_id
);

/*
 * Check if need "null" value when create dispute message
 */  
function is_null_value(
    i_value_null      in     com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_boolean;

end dsp_ui_process_pkg;
/
