create or replace package iss_prc_export_pkg as
/************************************************************
 * API for process files <br />
 * Created by Necheukhin I. (necheukhin@bpcbt.com)  at 18.11.2009 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-12-01 20:52:00 +0300#$ <br />
 * Revision: $LastChangedRevision: 60179 $ <br />
 * Module: iss_prc_export_pkg <br />
 * @headcom
 ***********************************************************/

procedure export_cards_status(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_card_status         in     com_api_type_pkg.t_dict_value    default null
  , i_export_state        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_type_of_date_range  in     com_api_type_pkg.t_dict_value    default null
);

/*
 * Process for cards' unloading.
 * @param i_full_export       – information about all cards will be unloaded.
 * @param i_include_address   – include or not block of cardholder's address.
 * @param i_include_limits    – include or not block of card's limits.
 * @param i_export_clear_pan  – if it is FALSE then process unloads undecoded
 *     PANs (tokens) for case when Message Bus is capable to handle them.
 * @param i_count             – count of <card_info> blocks per one XML-file.
 * @param i_include_notif     – include cardholder notification settings block.
 * @param i_subscriber_name   – subscriber procedure name.
 * @param i_include_contact   – include cardholder primary contact block.
 * @param i_lang              - preffered language of retrieving address(es)
 * @param i_exclude_npz_cards – exclude not personalized cards.
 */
procedure export_cards_numbers(
    i_full_export                in     com_api_type_pkg.t_boolean       default null
  , i_event_type                 in     com_api_type_pkg.t_dict_value    default null
  , i_include_address            in     com_api_type_pkg.t_boolean       default null
  , i_include_limits             in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan           in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_count                      in     com_api_type_pkg.t_count
  , i_include_notif              in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name            in     com_api_type_pkg.t_name          default null
  , i_include_contact            in     com_api_type_pkg.t_boolean       default null
  , i_lang                       in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type                   in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards          in     com_api_type_pkg.t_boolean       default null
  , i_include_service            in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_array_account_type         in     com_api_type_pkg.t_dict_value    default null
  , i_replace_inst_id_by_number  in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

/*
 * It returns XML structure with card limits, it is for using in SQL-query.
 */
--function get_card_limits(
--    i_card_id           in     com_api_type_pkg.t_medium_id
--) return xmltype;

/*
 * It returns XML structure with addresses of all address types for a specified
 * cardholder/person, it is for using in SQL-query. 
 * @param i_cardholder_id – primary entity object for retrieving address(es)
 * @param i_customer_id   – secondary entity object for retrieving address(es)
 * @param i_lang          – preffered language of retrieving address(es)
 */
--function generate_address_xml(
--    i_cardholder_id     in     com_api_type_pkg.t_medium_id
--  , i_customer_id       in     com_api_type_pkg.t_medium_id
--  , i_lang              in     com_api_type_pkg.t_dict_value
--) return xmltype;

procedure export_persons(
    i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_count                      in     com_api_type_pkg.t_count
  , i_full_export                in     com_api_type_pkg.t_boolean    default null
  , i_lang                       in     com_api_type_pkg.t_dict_value default null
);

procedure export_companies(
    i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_full_export                in     com_api_type_pkg.t_boolean    default null
  , i_lang                       in     com_api_type_pkg.t_dict_value default null
);

end iss_prc_export_pkg;
/
