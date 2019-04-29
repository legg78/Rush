create or replace package pmo_ui_template_data_pkg as
/************************************************************
 * UI for Payment Order template data<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_ui_template_data_pkg <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                   out com_api_type_pkg.t_long_id
  , i_template_id       in     com_api_type_pkg.t_long_id
  , i_param_id          in     com_api_type_pkg.t_short_id
  , i_param_value       in     com_api_type_pkg.t_name
);

procedure modify(
    i_id                in     com_api_type_pkg.t_long_id
  , i_template_id       in     com_api_type_pkg.t_long_id
  , i_param_id          in     com_api_type_pkg.t_short_id
  , i_param_value       in     com_api_type_pkg.t_name
);

procedure remove(
    i_id                in     com_api_type_pkg.t_long_id
);

end pmo_ui_template_data_pkg;
/
