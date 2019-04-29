create or replace package pmo_ui_template_pkg as
/************************************************************
 * UI for Payment Order Templates<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_TEMPLATE_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                   out com_api_type_pkg.t_long_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id     default null
  , i_purpose_id        in     com_api_type_pkg.t_short_id
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_is_prepared_order in     com_api_type_pkg.t_boolean
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_entity_type       in     com_api_type_pkg.t_dict_value    default null
  , i_object_id         in     com_api_type_pkg.t_long_id       default null
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_amount            in     com_api_type_pkg.t_money         default null
  , i_currency          in     com_api_type_pkg.t_curr_code     default null
);

procedure modify(
    i_id                in     com_api_type_pkg.t_long_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id
  , i_purpose_id        in     com_api_type_pkg.t_short_id
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_is_prepared_order in     com_api_type_pkg.t_boolean
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_entity_type       in     com_api_type_pkg.t_dict_value    default null
  , i_object_id         in     com_api_type_pkg.t_long_id       default null
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_amount            in     com_api_type_pkg.t_money         default null
  , i_currency          in     com_api_type_pkg.t_curr_code     default null
);

procedure remove(
    i_id                in     com_api_type_pkg.t_long_id
);

end pmo_ui_template_pkg;
/
