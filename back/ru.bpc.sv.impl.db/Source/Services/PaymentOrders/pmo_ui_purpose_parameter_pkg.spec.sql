create or replace package pmo_ui_purpose_parameter_pkg as
/************************************************************
 * UI for Payment Order Purpose Parameters<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 14.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_PURPOSE_PARAMETER_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                       out com_api_type_pkg.t_short_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_order_stage           in     com_api_type_pkg.t_dict_value
  , i_display_order         in     com_api_type_pkg.t_tiny_id
  , i_is_mandatory          in     com_api_type_pkg.t_boolean
  , i_is_template_fixed     in     com_api_type_pkg.t_boolean
  , i_is_editable           in     com_api_type_pkg.t_boolean
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_default_value_char    in     com_api_type_pkg.t_name
  , i_default_value_num     in     com_api_type_pkg.t_rate
  , i_default_value_date    in     date
  , i_param_function        in     com_api_type_pkg.t_name          default null
);

procedure modify(
    i_id                    in     com_api_type_pkg.t_short_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_order_stage           in     com_api_type_pkg.t_dict_value
  , i_display_order         in     com_api_type_pkg.t_tiny_id
  , i_is_mandatory          in     com_api_type_pkg.t_boolean
  , i_is_template_fixed     in     com_api_type_pkg.t_boolean
  , i_is_editable           in     com_api_type_pkg.t_boolean
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_default_value_char    in     com_api_type_pkg.t_name
  , i_default_value_num     in     com_api_type_pkg.t_rate
  , i_default_value_date    in     date
  , i_param_function        in     com_api_type_pkg.t_name          default null
);

procedure remove(
    i_id                    in     com_api_type_pkg.t_short_id
  , i_seqnum                in     com_api_type_pkg.t_seqnum
);

procedure add_value(
    o_id                       out com_api_type_pkg.t_medium_id
  , i_purp_param_id         in     com_api_type_pkg.t_short_id
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_value_char            in     com_api_type_pkg.t_name
  , i_value_num             in     com_api_type_pkg.t_rate
  , i_value_date            in     date
);

procedure modify_value(
    i_id                    in     com_api_type_pkg.t_medium_id
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_value_char            in     com_api_type_pkg.t_name
  , i_value_num             in     com_api_type_pkg.t_rate
  , i_value_date            in     date
);

procedure remove_value(
    i_id                    in     com_api_type_pkg.t_medium_id
);

end pmo_ui_purpose_parameter_pkg;
/
