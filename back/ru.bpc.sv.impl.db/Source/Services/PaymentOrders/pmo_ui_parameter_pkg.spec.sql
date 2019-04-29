create or replace package pmo_ui_parameter_pkg as
/************************************************************
 * UI for Payment Order parameters <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 13.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_PARAMETER_PKG <br />
 * @headcom
 ************************************************************/
procedure add(
    o_id                   out com_api_type_pkg.t_short_id
  , o_seqnum               out com_api_type_pkg.t_seqnum
  , i_param_name        in     com_api_type_pkg.t_name
  , i_data_type         in     com_api_type_pkg.t_dict_value
  , i_lov_id            in     com_api_type_pkg.t_tiny_id
  , i_pattern           in     com_api_type_pkg.t_name
  , i_tag_id            in     com_api_type_pkg.t_medium_id
  , i_param_function    in     com_api_type_pkg.t_full_desc
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id                in     com_api_type_pkg.t_short_id
  , io_seqnum           in out com_api_type_pkg.t_seqnum
  , i_param_name        in     com_api_type_pkg.t_name
  , i_data_type         in     com_api_type_pkg.t_dict_value
  , i_lov_id            in     com_api_type_pkg.t_tiny_id
  , i_pattern           in     com_api_type_pkg.t_name
  , i_tag_id            in     com_api_type_pkg.t_medium_id
  , i_param_function    in     com_api_type_pkg.t_full_desc
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id                in     com_api_type_pkg.t_short_id
  , i_seqnum            in     com_api_type_pkg.t_seqnum
);

end pmo_ui_parameter_pkg;
/

