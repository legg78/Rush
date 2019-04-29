create or replace package ntf_api_notification_pkg is
/***********************************************************
* API for notifications. <br>
* Created by Kopachev D.(kopachev@bpc.ru)  at 17.09.2010  <br>
* Last changed by $Author: krukov $ <br>
* $LastChangedDate:: 2011-06-17 17:03:12 +0400#$  <br>
* Revision: $LastChangedRevision: 10160 $ <br>
* Module: NTF_API_NOTIFICATION_PKG <br>
* @headcom
*************************************************************/

type t_user_notification_rec is record (
    user_id                      com_api_type_pkg.t_short_id
  , role_id                      com_api_type_pkg.t_tiny_id
  , notif_scheme_id              com_api_type_pkg.t_tiny_id
);
type t_user_notification_tab is table of t_user_notification_rec index by binary_integer;

procedure get_email_address (
    i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
  , o_address                    out  com_api_type_pkg.t_full_desc
  , o_lang                       out  com_api_type_pkg.t_dict_value
);

procedure get_mobile_number (
    i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
  , o_address                    out  com_api_type_pkg.t_full_desc
  , o_lang                       out  com_api_type_pkg.t_dict_value
);

function get_delivery_address (
    i_address                 in      com_api_type_pkg.t_full_desc
  , i_channel_id              in      com_api_type_pkg.t_tiny_id
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_full_desc;

procedure make_notification (
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_urgency_level           in      com_api_type_pkg.t_tiny_id    := null
  , i_notify_party_type       in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type         in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id           in      com_api_type_pkg.t_long_id    := null
  , i_delivery_address        in      com_api_type_pkg.t_full_desc  := null
  , i_delivery_time           in      date                          := null
  , i_ignore_missing_service  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
);

procedure make_notification (
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_urgency_level           in      com_api_type_pkg.t_tiny_id    := null
  , i_notify_party_type       in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type         in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id           in      com_api_type_pkg.t_long_id    := null
  , i_delivery_address        in      com_api_type_pkg.t_full_desc  := null
  , i_delivery_time           in      date                          := null
  , i_ignore_missing_service  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , io_processed_count        in out  com_api_type_pkg.t_count 
);

procedure make_notification_param(
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_param_tab               in      com_api_type_pkg.t_param_tab
  , i_urgency_level           in      com_api_type_pkg.t_tiny_id    := null
  , i_notify_party_type       in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type         in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id           in      com_api_type_pkg.t_long_id    := null
  , i_delivery_address        in      com_api_type_pkg.t_full_desc  := null
  , i_delivery_time           in      date                          := null
  , i_ignore_missing_service  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , io_processed_count        in out  com_api_type_pkg.t_count
);

procedure make_notification_param(
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_param_tab               in      com_api_type_pkg.t_param_tab
  , i_urgency_level           in      com_api_type_pkg.t_tiny_id    := null
  , i_notify_party_type       in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type         in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id           in      com_api_type_pkg.t_long_id    := null
  , i_delivery_address        in      com_api_type_pkg.t_full_desc  := null
  , i_delivery_time           in      date                          := null
  , i_ignore_missing_service  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
);

procedure make_user_notification (
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_user_list               in      num_tab_tpt default null
  , i_role_list               in      num_tab_tpt default null
);

procedure make_user_notification (
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_user_list               in      num_tab_tpt default null
  , i_role_list               in      num_tab_tpt default null
  , io_processed_count        in out  com_api_type_pkg.t_count  
);

function get_gl_delivery_address
    return com_api_type_pkg.t_full_desc;

/*
 * It returns cursor with notification settings of a specified entity object that should be notified.
 * @param i_dst_entity_type    - type of entity that should be notified
 * @param i_dst_object_id      - entity object of type <i_dst_entity_type>
 */
procedure get_notification_settings(
    i_dst_entity_type         in      com_api_type_pkg.t_dict_value
  , i_dst_object_id           in      com_api_type_pkg.t_long_id
  , o_ref_cursor                 out  sys_refcursor
);

procedure get_obj_notification_settings(
    i_dst_entity_type         in      com_api_type_pkg.t_dict_value
  , i_dst_object_id           in      com_api_type_pkg.t_long_id
  , o_ref_cursor              out     sys_refcursor
);

procedure get_user_name(
    i_user_id                 in      com_api_type_pkg.t_short_id
  , o_user_name                  out  com_api_type_pkg.t_name
);

procedure get_customer_push_number(
    i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_event_type              in      com_api_type_pkg.t_dict_value      default null
  , i_contact_type            in      com_api_type_pkg.t_dict_value      default null
  , o_address                    out  com_api_type_pkg.t_name
  , o_lang                       out  com_api_type_pkg.t_dict_value
);

procedure get_postal_address (
    i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
  , o_address                    out  com_api_type_pkg.t_name
  , o_lang                       out  com_api_type_pkg.t_dict_value
);

function get_user_notification_tab(
    i_user_list               in      com_api_type_pkg.t_text
  , i_role_list               in      com_api_type_pkg.t_text
) return t_user_notification_tab result_cache;

end ntf_api_notification_pkg;
/
