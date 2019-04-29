create or replace package pmo_ui_purpose_pkg as
/************************************************************
 * UI for Payment Order Purposes<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 14.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_PURPOSE_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                  out com_api_type_pkg.t_short_id
  , i_provider_id      in     com_api_type_pkg.t_short_id
  , i_service_id       in     com_api_type_pkg.t_short_id
  , i_host_algorithm   in     com_api_type_pkg.t_dict_value
  , i_oper_type        in     com_api_type_pkg.t_dict_value
  , i_terminal_id      in     com_api_type_pkg.t_short_id
  , i_mcc              in     com_api_type_pkg.t_mcc
  , i_purpose_number   in     com_api_type_pkg.t_name     default null
  , i_mod_id           in     com_api_type_pkg.t_tiny_id  default null
  , i_amount_algorithm in     com_api_type_pkg.t_name     default null
  , i_inst_id          in     com_api_type_pkg.t_inst_id  default null
);

procedure modify(
    i_id               in     com_api_type_pkg.t_short_id
  , i_provider_id      in     com_api_type_pkg.t_short_id
  , i_service_id       in     com_api_type_pkg.t_short_id
  , i_host_algorithm   in     com_api_type_pkg.t_dict_value
  , i_oper_type        in     com_api_type_pkg.t_dict_value
  , i_terminal_id      in     com_api_type_pkg.t_short_id
  , i_mcc              in     com_api_type_pkg.t_mcc
  , i_purpose_number   in     com_api_type_pkg.t_name     default null
  , i_mod_id           in     com_api_type_pkg.t_tiny_id  default null
  , i_amount_algorithm in     com_api_type_pkg.t_name     default null
  , i_inst_id          in     com_api_type_pkg.t_inst_id  default null
);

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
);

procedure get_service_provider_list(
    i_lang          in     com_api_type_pkg.t_dict_value
    , o_ref_cursor  out    sys_refcursor 
);

end pmo_ui_purpose_pkg;
/
