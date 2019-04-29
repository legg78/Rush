create or replace package app_api_notification_pkg is
/*******************************************************************
*  API for notification processing in application's structure <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 18.01.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_NOTIFICATION_PKG <br />
*  @headcom
******************************************************************/

procedure process_notification(
    i_appl_data_id         in      com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_inst_id              in      com_api_type_pkg.t_tiny_id
  , i_customer_id          in      com_api_type_pkg.t_long_id
  , i_linked_object_id     in      com_api_type_pkg.t_long_id       default null
  , o_custom_event_id      out     com_api_type_pkg.t_medium_id  
  , o_is_active            out     com_api_type_pkg.t_boolean  
);

procedure report_user_appl_changed(
    o_xml                  out     clob
  , i_event_type           in      com_api_type_pkg.t_dict_value    default null
  , i_eff_date             in      date                             default null
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_inst_id              in      com_api_type_pkg.t_inst_id       default ost_api_const_pkg.DEFAULT_INST
  , i_lang                 in      com_api_type_pkg.t_dict_value
);

end;
/
