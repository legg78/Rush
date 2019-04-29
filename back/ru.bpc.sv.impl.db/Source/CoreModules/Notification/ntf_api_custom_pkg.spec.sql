create or replace package ntf_api_custom_pkg is
/*********************************************************
 *  Custom events and custom event objects API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 12.02.2016 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2016-12-12 10:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: NTF_API_CUSTOM_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Procedure inserts a new custom EVENT's record or updates existed one if its ID is passed.
 * @io_id     ID of record that should be updated,
              if it is NOT passed, it will contain ID of a new (inserted) record
 */
procedure set_custom_event(
    io_id                   in out com_api_type_pkg.t_medium_id
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_channel_id            in     com_api_type_pkg.t_tiny_id
  , i_delivery_address      in     com_api_type_pkg.t_full_desc
  , i_delivery_time         in     com_api_type_pkg.t_name
  , i_status                in     com_api_type_pkg.t_dict_value
  , i_mod_id                in     com_api_type_pkg.t_tiny_id
  , i_start_date            in     date
  , i_end_date              in     date
  , i_customer_id           in     com_api_type_pkg.t_long_id
  , i_contact_type          in     com_api_type_pkg.t_dict_value
);

/*
 * Procedure inserts/updates a custom OBJECT's record by unique key i_custom_event_id + i_object_id.
 */
procedure set_custom_object(
    i_custom_event_id       in     com_api_type_pkg.t_short_id
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_is_active             in     com_api_type_pkg.t_boolean
);

/*
 * Function returns count of custom objects that are linked with specified custom event.
 * @i_custom_event_id       ID of parent custom event which custom object should be calculated
 * @i_excluded_object_id    custom object ID that should NOT be calculated (optional)
 */
function get_active_objects_count(
    i_custom_event_id       in     com_api_type_pkg.t_medium_id
  , i_excluded_object_id    in     com_api_type_pkg.t_long_id      default null
) return com_api_type_pkg.t_count;

/*
 * Procedure insert/update record in ntf_custom_event and related record in ntf_custom_object.
 */
procedure set_event_with_object(
    io_id                   in out com_api_type_pkg.t_medium_id
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_channel_id            in     com_api_type_pkg.t_tiny_id
  , i_delivery_address      in     com_api_type_pkg.t_full_desc
  , i_delivery_time         in     com_api_type_pkg.t_name
  , i_status                in     com_api_type_pkg.t_dict_value
  , i_mod_id                in     com_api_type_pkg.t_tiny_id
  , i_start_date            in     date
  , i_end_date              in     date
  , i_customer_id           in     com_api_type_pkg.t_long_id
  , i_contact_type          in     com_api_type_pkg.t_dict_value
  , i_linked_object_id      in     com_api_type_pkg.t_medium_id
  , i_is_active             in     com_api_type_pkg.t_boolean
);

--procedure remove_custom_event(
--    i_id                    in     com_api_type_pkg.t_medium_id
--);

--procedure remove_custom_object(
--    i_id                    in     com_api_type_pkg.t_long_id
--);

/**
*    Parse a string with comma-separated phones and store the data in ntf_custom_*
*    @param i_mobile              - string with comma-separated phones
*    @param i_card_id             - card identifier
*    @param i_customer_id         - customer identifier
*    @param i_scheme_notification - notification schema identifier
*/
procedure add_custom_events(
    i_mobile                in     com_api_type_pkg.t_name
  , i_card_id               in     com_api_type_pkg.t_medium_id
  , i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_scheme_notification   in     com_api_type_pkg.t_tiny_id
);

procedure deactivate_custom_event(
    i_custom_event_id       in     com_api_type_pkg.t_medium_id
);

procedure clone_custom_event(
    i_src_object_id             in     com_api_type_pkg.t_long_id
  , i_src_entity_type           in     com_api_type_pkg.t_dict_value
  , i_dst_object_id             in     com_api_type_pkg.t_long_id
  , i_dst_entity_type           in     com_api_type_pkg.t_dict_value
  , i_linked_object_id          in     com_api_type_pkg.t_medium_id
  , i_is_active                 in     com_api_type_pkg.t_boolean
);

end;
/
