create or replace package csm_ui_stop_list_pkg as
/*********************************************************
 *  API for IPS stop lists <br />
 *  Created by Alalykin A. (alalykin@bpcbt.com) at 02.03.2017 <br />
 *  Module: CSM_UI_STOP_LIST_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Function returns true if a dispute belongs to VISA or MasterCard network.
 */
function is_visa_or_mastercard(
    i_dispute_id            in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function is_put_stop_list_enable(
    i_dispute_id            in     com_api_type_pkg.t_long_id
)
return com_api_type_pkg.t_boolean;

/*
 * Fucntion returns LOV ID of VISA stop list types if card belongs to VISA network,
 * and it returns LOV ID of MasterCard stop list types if card belongs to MasterCard network.
 */
function get_lov_id(
    i_dispute_id            in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_tiny_id;

/*
 * Procedure tries to register a new event of specified type for a certain card instance;
 * on success it adds a new record into stop list table with event object ID, otherwise it raises an error.
 */
procedure send_card_to_stop_list(
    i_card_instance_id      in     com_api_type_pkg.t_long_id
  , i_stop_list_type        in     com_api_type_pkg.t_dict_value
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_purge_date            in     date
  , i_region_list           in     com_api_type_pkg.t_name
  , i_product               in     com_api_type_pkg.t_dict_value default null
);

procedure get_last_csm_stop_list(
    i_card_instance_id      in     com_api_type_pkg.t_long_id
  , o_id                    out    com_api_type_pkg.t_long_id
  , o_stop_list_type        out    com_api_type_pkg.t_dict_value
  , o_reason_code           out    com_api_type_pkg.t_dict_value
  , o_purge_date            out    date
  , o_region_list           out    com_api_type_pkg.t_short_desc
  , o_product               out    com_api_type_pkg.t_dict_value
);

end;
/
