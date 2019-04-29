create or replace package app_api_application_pkg as
/*********************************************************
*  API for application <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 09.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_application_pkg <br />
*  @headcom
**********************************************************/
g_params                                 com_api_type_pkg.t_param_tab;

function get_app_agent_id return com_api_type_pkg.t_short_id;

function get_appl_type return com_api_type_pkg.t_dict_value;

function get_customer_appl_data_id(
    i_element_name         in            com_api_type_pkg.t_name             default null
  , i_parent_id            in            com_api_type_pkg.t_long_id          default null
) return com_api_type_pkg.t_long_id;

function get_prioritized_flag return com_api_type_pkg.t_boolean;

function get_appl_description(
    i_appl_id              in            com_api_type_pkg.t_long_id
  , i_flow_id              in            com_api_type_pkg.t_tiny_id
  , i_lang                 in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_full_desc;

/*
 * It generates and returns a new ID for inserting into APP_DATA.
 */
function get_appl_data_id(
    i_appl_id              in            com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , i_current_value        in            com_api_type_pkg.t_full_desc        default null
  , o_element_value           out nocopy com_api_type_pkg.t_full_desc
);

function get_element_value_v(
    i_element_name            in            com_api_type_pkg.t_name
  , i_parent_id               in            com_api_type_pkg.t_long_id
  , i_serial_number           in            com_api_type_pkg.t_tiny_id       default 1
) return com_api_type_pkg.t_full_desc;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , i_current_value        in            com_api_type_pkg.t_multilang_desc   default null
  , o_element_value           out nocopy com_api_type_pkg.t_multilang_desc
);

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , i_current_value        in            number                              default null
  , o_element_value           out nocopy number
);

function get_element_value_n(
    i_element_name            in            com_api_type_pkg.t_name
  , i_parent_id               in            com_api_type_pkg.t_long_id
  , i_serial_number           in            com_api_type_pkg.t_tiny_id       default 1
) return number;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , i_current_value        in            date                                default null
  , o_element_value           out nocopy date
);

function get_element_value_d(
    i_element_name            in            com_api_type_pkg.t_name
  , i_parent_id               in            com_api_type_pkg.t_long_id
  , i_serial_number           in            com_api_type_pkg.t_tiny_id       default 1
) return date;

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_desc_tab
);

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_multilang_desc_tab
);

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_number_tab
);

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy num_tab_tpt
);

procedure get_element_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_date_tab
);

procedure get_appl_data_id(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_appl_data_id            out nocopy com_api_type_pkg.t_number_tab
);
-- procedure returns block id list and it's language list at the same time
procedure get_appl_data_id(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_appl_data_id            out nocopy com_api_type_pkg.t_number_tab
  , o_appl_data_lang          out nocopy com_api_type_pkg.t_dict_tab
);

procedure get_appl_data_id(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_serial_number        in            com_api_type_pkg.t_tiny_id          default 1
  , o_appl_data_id            out nocopy com_api_type_pkg.t_long_id
);

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
);

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
  , o_appl_data_id            out nocopy com_api_type_pkg.t_long_id
);

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            number
);


procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            date
);

procedure modify_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
);

procedure modify_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_value        in            number
);

procedure modify_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_value        in            date
);

procedure merge_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
);

procedure merge_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            number
);

procedure merge_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            date
);

procedure remove_element(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
);

procedure get_appl_data(
    i_appl_id              in            com_api_type_pkg.t_long_id
);

function get_appl_data_rec(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
) return app_api_type_pkg.t_appl_data_rec;

procedure get_element_name(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , o_element_name            out nocopy com_api_type_pkg.t_name
);

function get_xml (
    i_appl_id              in            com_api_type_pkg.t_long_id
  , i_add_header           in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_export_clear_pan     in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_add_xmlns            in            com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return clob;

function get_xml_with_id (
    i_appl_id              in            com_api_type_pkg.t_long_id
) return clob;

procedure get_appl_id_value(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , o_element_value           out nocopy com_api_type_pkg.t_number_tab
  , o_appl_data_id            out nocopy com_api_type_pkg.t_number_tab
);

procedure set_value(
    i_element_name         in            com_api_type_pkg.t_name
  , io_value_char          in out nocopy varchar2
  , io_value_num           in out nocopy number
  , io_value_date          in out nocopy date
  , i_template_value       in            varchar2
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
);

procedure set_appl_id(
    i_appl_id              in            com_api_type_pkg.t_long_id
);

function get_appl_id return com_api_type_pkg.t_long_id;

/*
 * It is used to get last processed record t_appl_data_rec in basis procedure get_element_data().
 * It may be useful for logging error data when error raises inside typical procedures get_appl_data()
 * and can not be located inside get_element_data() or get_element_value() procedures. For example
 * it may be type mismatch when an outgoing value is assigned to an outgoing variable.
 */
function get_last_appl_data_rec return app_api_type_pkg.t_appl_data_rec;

/*
 * Procedure clones entire block as a branch of an application's tree,
 * i.e. it recursively runs over a branch that is specified by its root note.
 * @param i_root_appl_id     — a root node of a branch in entire application's tree
 * @param i_dest_appl_id     — a parent node for a new cloned branch
 * @param i_skipped_elements — a list of elements that should be skipped on copying
 * @param i_serial_number    — a serial number for a new root node
 * @param o_new_appl_id      — an ID of a new root node
 */
procedure clone_block(
    i_root_appl_id         in            com_api_type_pkg.t_long_id
  , i_dest_appl_id         in            com_api_type_pkg.t_long_id
  , i_skipped_elements     in            com_api_type_pkg.t_param_tab
  , i_serial_number        in            com_api_type_pkg.t_tiny_id
  , o_new_appl_id             out        com_api_type_pkg.t_long_id
);

/*
 * Function searches and returns value of APPLICATION_FLOW_ID in provided application data.
 */
function get_appl_flow return com_api_type_pkg.t_tiny_id;

function get_application(
    i_appl_id             in     com_api_type_pkg.t_long_id
  , i_raise_error         in     com_api_type_pkg.t_boolean           default com_api_const_pkg.FALSE
) return app_api_type_pkg.t_application_rec;

procedure calculate_new_card_count(
    i_card_count          in     com_api_type_pkg.t_long_id
  , i_batch_card_count    in     com_api_type_pkg.t_long_id
  , o_application_count      out com_api_type_pkg.t_long_id
  , o_non_last_card_count    out com_api_type_pkg.t_long_id
  , o_last_card_count        out com_api_type_pkg.t_long_id
);

end app_api_application_pkg;
/
