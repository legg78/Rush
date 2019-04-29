create or replace package prc_ui_parameter_pkg as
/************************************************************
 * User interface for process parameters <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 15.11.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_UI_PARAMETER_PKG <br />
 * @headcom
 ************************************************************/

/*
 * Change process parameter number
 * @param i_param_id          Parameter identifier
 * @param i_value             Value of number
 * @param i_container_id      Process of container identifier
 * @param io_param_prc_id     Record identifier
 */
procedure set_parameter_value_num(
    io_id                   in out com_api_type_pkg.t_short_id
  , i_container_id          in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_param_value           in     number
);

/*
 * Change process parameter date
 * @param i_container_id      Process of containers identifier
 * @param i_param_id          Parameter identifier
 * @param i_value             Value of date
 * @param io_param_prc_id     Record identifier
 */
procedure set_parameter_value_date(
    io_id                   in out com_api_type_pkg.t_short_id
  , i_container_id          in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_param_value           in     date
);

/*
 * Change process parameter char
 * @param io_param_prc_id Record identifier
 * @param i_param_id      Parameter identifier
 * @param i_value         Value of char
 * @param i_container_id  Process of containers identifier
 */
procedure set_parameter_value_char(
    io_id                   in out com_api_type_pkg.t_short_id
  , i_container_id          in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_param_value           in     com_api_type_pkg.t_param_value
);

/*
 * Remove procedure parameter
 * @param i_param_id Parameter identifier
 */
procedure remove_parameter_value(
    i_id                    in com_api_type_pkg.t_short_id
);

/*
 * Add parameters
 */
procedure add_parameter(
    o_id                       out com_api_type_pkg.t_short_id
  , i_param_name            in     com_api_type_pkg.t_attr_name
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_lov_id                in     com_api_type_pkg.t_tiny_id
  , i_parent_id             in     com_api_type_pkg.t_short_id
  , i_label                 in     com_api_type_pkg.t_short_desc
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
);

/*
 * Modify parameters
 */
procedure modify_parameter(
    i_id                    in com_api_type_pkg.t_short_id
  , i_param_name            in com_api_type_pkg.t_attr_name
  , i_data_type             in com_api_type_pkg.t_dict_value
  , i_lov_id                in com_api_type_pkg.t_tiny_id
  , i_parent_id             in com_api_type_pkg.t_short_id
  , i_label                 in com_api_type_pkg.t_short_desc
  , i_description           in com_api_type_pkg.t_full_desc
  , i_lang                  in com_api_type_pkg.t_dict_value
);

/*
 * Remove parameter
 * @param i_id Parameter identifier
 */
procedure remove_parameter(
    i_id                    in com_api_type_pkg.t_short_id
);

/*
 * Add parameter to procedure
 */
procedure add_process_parameter(
    o_id                       out com_api_type_pkg.t_short_id
  , i_process_id            in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_default_value_char    in     com_api_type_pkg.t_name
  , i_default_value_num     in     number
  , i_default_value_date    in     date
  , i_display_order         in     com_api_type_pkg.t_tiny_id
  , i_is_format             in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_is_mandatory          in     com_api_type_pkg.t_boolean
  , i_lov_id                in     com_api_type_pkg.t_tiny_id    default null
  , i_description           in     com_api_type_pkg.t_full_desc  default null
  , i_lang                  in     com_api_type_pkg.t_dict_value default null
);

function allow_process_parameter_modify(
    i_process_id            in com_api_type_pkg.t_short_id
  , i_mask_error            in com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_boolean;

procedure modify_process_parameter_desc (
    i_object_id           in     com_api_type_pkg.t_short_id
  , i_description         in     com_api_type_pkg.t_full_desc
  , i_lang                in     com_api_type_pkg.t_dict_value
);

/*
 * Modify parameter to procedure
 */
procedure modify_process_parameter(
    i_id                    in com_api_type_pkg.t_short_id
  , i_default_value_char    in com_api_type_pkg.t_name
  , i_default_value_num     in number
  , i_default_value_date    in date
  , i_display_order         in com_api_type_pkg.t_tiny_id
  , i_is_format             in com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_is_mandatory          in com_api_type_pkg.t_boolean
  , i_lov_id                in com_api_type_pkg.t_tiny_id    default null
  , i_description           in com_api_type_pkg.t_full_desc  default null
  , i_lang                  in com_api_type_pkg.t_dict_value default null
  
);

/*
 * Remove parameter from procedure
 * @param i_id Record identifier
 */
procedure remove_process_parameter(
    i_id                    in com_api_type_pkg.t_short_id
);

procedure sync_container_parameters(
    i_container_process_id  in com_api_type_pkg.t_short_id
  , i_process_id            in com_api_type_pkg.t_short_id
);

procedure remove_container_parameters(
    i_container_id          in com_api_type_pkg.t_short_id
);

/* Check procedure parameters.
 * See log in trc_log
 * @param i_prc_id
 */
procedure check_process_param(
    i_process_id            in com_api_type_pkg.t_short_id
);

end prc_ui_parameter_pkg;
/
