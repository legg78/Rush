create or replace package gui_api_external_pkg as
/**********************************************************
 * API for external GUI <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 17.02.2017 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: GUI_API_EXTERNAL_PKG
 * @headcom
 **********************************************************/
procedure get_dict_identity_types(
    i_owner_entity_type  in    com_api_type_pkg.t_dict_value   default com_api_const_pkg.ENTITY_TYPE_PERSON
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_customer_list(
    i_customer_number    in    com_api_type_pkg.t_name         default null
  , i_customer_name      in    com_api_type_pkg.t_name         default null
  , i_customer_mobile    in    com_api_type_pkg.t_name         default null
  , i_identity_type      in    com_api_type_pkg.t_dict_value   default null
  , i_identity_series    in    com_api_type_pkg.t_name         default null
  , i_identity_number    in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

function get_first_customer_id(
    i_customer_number    in    com_api_type_pkg.t_name         default null
  , i_customer_name      in    com_api_type_pkg.t_name         default null
  , i_customer_mobile    in    com_api_type_pkg.t_name         default null
  , i_identity_type      in    com_api_type_pkg.t_dict_value   default null
  , i_identity_series    in    com_api_type_pkg.t_name         default null
  , i_identity_number    in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id;

procedure get_main_customer_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id    default null
  , i_customer_number    in    com_api_type_pkg.t_name         default null
  , i_customer_name      in    com_api_type_pkg.t_name         default null
  , i_customer_mobile    in    com_api_type_pkg.t_name         default null
  , i_identity_type      in    com_api_type_pkg.t_dict_value   default null
  , i_identity_series    in    com_api_type_pkg.t_name         default null
  , i_identity_number    in    com_api_type_pkg.t_name         default null
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_contacts_customer_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id    default null
  , i_contact_id         in    com_api_type_pkg.t_medium_id    default null
  , i_contact_type       in    com_api_type_pkg.t_dict_value   default null
  , i_commun_method      in    com_api_type_pkg.t_dict_value   default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_addresses_customer_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id    default null
  , i_address_id         in    com_api_type_pkg.t_medium_id    default null
  , i_address_type       in    com_api_type_pkg.t_dict_value   default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang               in    com_api_type_pkg.t_dict_value
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_main_billing_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_main_cards_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_card_type_feature(
    i_card_number        in    com_api_type_pkg.t_card_number
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_customer_limit_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_customer_crd_invoice_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_crd_invoice_payments_info(
    i_invoice_id         in    com_api_type_pkg.t_medium_id
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure get_customer_marketing_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_months_ago         in    com_api_type_pkg.t_byte_id
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
);

procedure close_ref_cursor(
    i_ref_cursor         in    com_api_type_pkg.t_ref_cur
);

end gui_api_external_pkg;
/
