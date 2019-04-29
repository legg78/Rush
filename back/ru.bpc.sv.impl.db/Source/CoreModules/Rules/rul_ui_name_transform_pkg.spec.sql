create or replace package rul_ui_name_transform_pkg as
/************************************************************
 * UI for transform function. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 24.01.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: RUL_UI_NAME_TRANSFORM_PKG <br />
 * @headcom
 *************************************************************/
procedure add(
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_function_name       in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_description         in     com_api_type_pkg.t_full_desc
);

procedure modify(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_function_name       in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_description         in     com_api_type_pkg.t_full_desc
);

procedure remove(
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
);

end rul_ui_name_transform_pkg;
/
