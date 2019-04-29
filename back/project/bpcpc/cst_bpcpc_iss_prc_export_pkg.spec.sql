create or replace package cst_bpcpc_iss_prc_export_pkg as

/*
 * Process for cards' unloading.
 * @param i_full_export        information about all cards will be unloaded.
 * @param i_include_address    include or not block of cardholder's address.
 * @param i_include_limits     include or not block of card's limits.
 * @param i_export_clear_pan   if it is FALSE then process unloads undecoded
 *     PANs (tokens) for case when Message Bus is capable to handle them.
 * @param i_count              count of <card_info> blocks per one XML-file.
 * @param i_include_notif      include cardholder notification settings block.
 * @param i_subscriber_name    subscriber procedure name.
 * @param i_include_contact    include cardholder primary contact block.
 * @param i_lang              - preffered language of retrieving address(es)
 * @param i_exclude_npz_cards  exclude not personalized cards.
 */
procedure export_cards_numbers(
    i_full_export         in     com_api_type_pkg.t_boolean    default null
  , i_event_type          in     com_api_type_pkg.t_dict_value default null
  , i_include_address     in     com_api_type_pkg.t_boolean    default null
  , i_include_limits      in     com_api_type_pkg.t_boolean    default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name       default null
  , i_include_contact     in     com_api_type_pkg.t_boolean    default null
  , i_lang                in     com_api_type_pkg.t_dict_value default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean    default null
);

function get_limit_id(
    i_entity_type         in      com_api_type_pkg.t_dict_value
  , i_object_id           in      com_api_type_pkg.t_long_id
  , i_instance_id         in      com_api_type_pkg.t_long_id
  , i_limit_type          in      com_api_type_pkg.t_dict_value
  , i_service_id          in      com_api_type_pkg.t_short_id     default null
  , i_eff_date            in      date                            default null
  , i_split_hash          in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error          in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id;

end cst_bpcpc_iss_prc_export_pkg;
/
