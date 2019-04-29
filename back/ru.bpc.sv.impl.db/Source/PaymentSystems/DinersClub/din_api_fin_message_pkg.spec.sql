create or replace package din_api_fin_message_pkg as
/*********************************************************
*  API for Diners Club financial messages <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 30.04.2016 <br />
*  Module: DIN_API_FIN_MESSAGE_PKG <br />
*  @headcom
**********************************************************/

/*
 * Procedure loads fields of Diners Club records by a specified function code (FUNCD).
 */
procedure load_fields_reference(
    i_function_code       in            din_api_type_pkg.t_function_code
  , o_message_field_tab      out        din_api_type_pkg.t_message_field_tab
);

function get_fin_message(
    i_id                  in            com_api_type_pkg.t_long_id
  , i_mask_error          in            com_api_type_pkg.t_boolean
) return din_api_type_pkg.t_fin_message_rec;

/*
 * Function defines internal SmartVista institution ID by provided Diners Club agent code.
 */
function get_inst_id(
    i_agent_code          in            din_api_type_pkg.t_institution_code
  , i_network_id          in            com_api_type_pkg.t_network_id
  , i_standard_id         in            com_api_type_pkg.t_tiny_id             default null
) return com_api_type_pkg.t_inst_id;

function get_impact(
    i_type_of_charge      in            din_api_type_pkg.t_type_of_charge
) return com_api_type_pkg.t_sign
result_cache;

/*
 * Function returns TRUE if incoming charge type is in the range of cash (or cash equivalent) charge types.
 */
function is_cash_charge_type(
    i_charge_type         in            din_api_type_pkg.t_charge_type
) return com_api_type_pkg.t_boolean
result_cache;
/*
 * Procedure finds appropriate SV2 operation type, reversal flag, terminal type by provided values
 * of type of charge and MCC (mapping for incoming clearing).
 */
procedure get_operation_parameters(
    i_type_of_charge      in            din_api_type_pkg.t_type_of_charge
  , i_mcc                 in            com_api_type_pkg.t_mcc
  , o_is_reversal            out        com_api_type_pkg.t_boolean
  , o_oper_type              out        com_api_type_pkg.t_dict_value
  , o_terminal_type          out        com_api_type_pkg.t_dict_value
);

function get_original_fin_message(
    i_fin_rec             in            din_api_type_pkg.t_fin_message_rec
  , i_mask_error          in            com_api_type_pkg.t_boolean
) return din_api_type_pkg.t_fin_message_rec;

procedure save_file(
    i_file_rec            in            din_api_type_pkg.t_file_rec
);

procedure save_recap(
    i_recap_rec           in            din_api_type_pkg.t_recap_rec
);

procedure save_batch(
    i_batch_rec           in            din_api_type_pkg.t_batch_rec
);

procedure save_messages(
    io_fin_tab            in out nocopy din_api_type_pkg.t_fin_message_tab
);

procedure save_addendums(
    io_addendum_tab       in out nocopy din_api_type_pkg.t_addendum_tab
  , i_addendum_value_tab  in            din_api_type_pkg.t_addendum_value_tab
);

/*
 * Function adds a new addendum to a collection
 * and returns an index to it (a pointer).
 */
function add_addendum(
    io_addendum_tab       in out nocopy din_api_type_pkg.t_addendum_tab
  , i_fin_id              in            com_api_type_pkg.t_long_id
  , i_function_code       in            din_api_type_pkg.t_function_code
) return com_api_type_pkg.t_count;

/*
 * Function adds requested amount of addendum values to a collection,
 * initializes them with IDs and parent addendum ID,
 * and returns index to the first element (addendum value) of new ones.
 */
function init_addendum_values(
    io_addendum_value_tab in out nocopy din_api_type_pkg.t_addendum_value_tab
  , i_addendum_id         in            com_api_type_pkg.t_long_id
  , i_count               in            com_api_type_pkg.t_count
) return com_api_type_pkg.t_count;

procedure create_from_auth(
    i_auth_rec            in            aut_api_type_pkg.t_auth_rec
  , i_inst_id             in            com_api_type_pkg.t_inst_id       default null
  , i_network_id          in            com_api_type_pkg.t_tiny_id       default null
  , i_message_status      in            com_api_type_pkg.t_dict_value    default null
  , io_fin_message_id     in out        com_api_type_pkg.t_long_id
);

function estimate_messages_for_export(
    i_network_id          in            com_api_type_pkg.t_tiny_id
  , i_inst_id             in            com_api_type_pkg.t_inst_id
  , i_start_date          in            date
  , i_end_date            in            date
  , i_include_affiliate   in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_count;

procedure enum_messages_for_export(
    o_fin_cur                out        sys_refcursor
  , i_network_id          in            com_api_type_pkg.t_tiny_id
  , i_inst_id             in            com_api_type_pkg.t_inst_id
  , i_start_date          in            date
  , i_end_date            in            date
  , i_include_affiliate   in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

function get_addendum_value(
    i_fin_id              in            com_api_type_pkg.t_long_id
  , i_function_code       in            din_api_type_pkg.t_function_code
) return din_api_type_pkg.t_addendum_values_tab;

end;
/
