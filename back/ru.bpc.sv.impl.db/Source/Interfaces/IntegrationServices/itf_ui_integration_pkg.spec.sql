create or replace package itf_ui_integration_pkg as

procedure get_account_list(
    i_customer_number   in     com_api_type_pkg.t_name          default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id     default null
  , i_card_number       in     com_api_type_pkg.t_card_number   default null
  , i_card_id           in     com_api_type_pkg.t_medium_id     default null
  , i_status            in     com_api_type_pkg.t_dict_value    default null
  , i_account_type      in     com_api_type_pkg.t_dict_value    default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , i_balance_type      in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor        out    sys_refcursor
);

procedure get_account_list(
    i_customer_number   in     com_api_type_pkg.t_name          default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id     default null
  , i_card_number       in     com_api_type_pkg.t_card_number   default null
  , i_card_uid          in     com_api_type_pkg.t_name          default null
  , i_status            in     com_api_type_pkg.t_dict_value    default null
  , i_account_type      in     com_api_type_pkg.t_dict_value    default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , i_balance_type      in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor       out     sys_refcursor
);

procedure get_account_payment_details(
    i_id                in     com_api_type_pkg.t_account_id
  , io_account_number   in out com_api_type_pkg.t_account_number
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , o_recipient_name    out    com_api_type_pkg.t_name
  , o_bank_name         out    com_api_type_pkg.t_name
  , o_bic               out    com_api_type_pkg.t_name
  , o_tin               out    com_api_type_pkg.t_name
  , o_corr_account      out    com_api_type_pkg.t_name
  , o_bank_address      out    com_api_type_pkg.t_param_value
);

procedure get_rate_for_inst(
    i_rate_type         in     com_api_type_pkg.t_dict_value
  , i_src_currency      in     com_api_type_pkg.t_curr_code
  , i_dst_currency      in     com_api_type_pkg.t_curr_code
  , i_eff_date          in     date default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , o_rate              out    com_api_type_pkg.t_rate
);

procedure get_card_list(
    i_customer_number           in     com_api_type_pkg.t_name
  , i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_customer_id               in     com_api_type_pkg.t_medium_id
  , i_account_number            in     com_api_type_pkg.t_account_number
  , i_account_id                in     com_api_type_pkg.t_account_id
  , i_state                     in     com_api_type_pkg.t_dict_value        default null
  , i_get_balance               in     com_api_type_pkg.t_boolean           default null
  , i_card_mask                 in     com_api_type_pkg.t_card_number       default null
  , i_card_type_id              in     com_api_type_pkg.t_tiny_id           default null
  , i_product_id                in     com_api_type_pkg.t_short_id          default null
  , i_creation_date             in     date                                 default null
  , i_expir_date                in     date                                 default null
  , i_embossed_name             in     com_api_type_pkg.t_name              default null
  , i_cardholder_first_name     in     com_api_type_pkg.t_name              default null
  , i_cardholder_last_name      in     com_api_type_pkg.t_name              default null
  , i_cardholder_number         in     com_api_type_pkg.t_name              default null
  , i_lang                      in     com_api_type_pkg.t_dict_value        default null
  , i_impersonal_cards          in     com_api_type_pkg.t_name              default null
  , o_ref_cursor                out    sys_refcursor
);

function get_balance(
    i_card_id           in     com_api_type_pkg.t_medium_id
  , i_balance_type      in     com_api_type_pkg.t_dict_value
  , i_bin_currency      in     com_api_type_pkg.t_curr_code
  , i_inst_id           in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_name;

procedure get_card_details(
    i_card_number       in     com_api_type_pkg.t_card_number
  , i_card_id           in     com_api_type_pkg.t_medium_id
  , i_seq_number        in     com_api_type_pkg.t_inst_id
  , i_expir_date        in     date
  , i_instance_id       in     com_api_type_pkg.t_medium_id
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , i_card_type_id      in     com_api_type_pkg.t_tiny_id       default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , o_ref_cursor        out    sys_refcursor
);

procedure get_card_details(
    i_card_number       in     com_api_type_pkg.t_card_number
  , i_card_uid          in     com_api_type_pkg.t_name
  , i_seq_number        in     com_api_type_pkg.t_inst_id
  , i_expir_date        in     date
  , i_instance_id       in     com_api_type_pkg.t_medium_id
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , i_card_type_id      in     com_api_type_pkg.t_tiny_id       default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , o_ref_cursor        out    sys_refcursor
);

function get_country_name(
    i_code               in     com_api_type_pkg.t_dict_value
  , i_lang               in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name;

procedure get_customer_details(
    io_customer_id        in out com_api_type_pkg.t_medium_id
  , io_customer_number    in out com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_lang                in     com_api_type_pkg.t_dict_value default null
  , o_entity_type            out com_api_type_pkg.t_dict_value
  , o_entity_type_name       out com_api_type_pkg.t_name
  , o_category               out com_api_type_pkg.t_dict_value
  , o_category_name          out com_api_type_pkg.t_name
  , o_credit_rating          out com_api_type_pkg.t_dict_value
  , o_credit_rating_name     out com_api_type_pkg.t_name
  , o_resident               out com_api_type_pkg.t_inst_id
  , o_nationality            out com_api_type_pkg.t_dict_value
  , o_country_code           out com_api_type_pkg.t_dict_value
  , o_country_name           out com_api_type_pkg.t_name
  , o_relation               out com_api_type_pkg.t_dict_value
  , o_relation_name          out com_api_type_pkg.t_name
  , o_first_name             out com_api_type_pkg.t_name
  , o_second_name            out com_api_type_pkg.t_name
  , o_surname                out com_api_type_pkg.t_name
  , o_gender                 out com_api_type_pkg.t_dict_value
  , o_birthday               out date
  , o_place_birth            out com_api_type_pkg.t_full_desc
  , o_short_name             out com_api_type_pkg.t_name
  , o_full_name              out com_api_type_pkg.t_full_desc
  , o_incorp_form            out com_api_type_pkg.t_dict_value
  , o_incorp_form_name       out com_api_type_pkg.t_name
  , o_money_laundry_risk     out com_api_type_pkg.t_dict_value
  , o_person_title           out com_api_type_pkg.t_dict_value
  , o_person_suffix          out com_api_type_pkg.t_dict_value
  , o_marital_status         out com_api_type_pkg.t_dict_value
  , o_marital_status_date    out date
  , o_children_number        out com_api_type_pkg.t_dict_value
  , o_employment_status      out com_api_type_pkg.t_dict_value
  , o_employment_period      out com_api_type_pkg.t_dict_value
  , o_residence_type         out com_api_type_pkg.t_dict_value
  , o_income_range           out com_api_type_pkg.t_dict_value
);

procedure get_customer_addresses(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_customer_number    in    com_api_type_pkg.t_name
  , i_inst_id            in    com_api_type_pkg.t_inst_id
  , i_lang               in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor         out   sys_refcursor
);

procedure get_customer_contacts(
    i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_customer_number    in     com_api_type_pkg.t_name
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_get_only_actual    in     com_api_type_pkg.t_boolean       default null
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor            out sys_refcursor
);

procedure get_customer_documents(
    i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_customer_number    in     com_api_type_pkg.t_name
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_get_only_actual    in     com_api_type_pkg.t_boolean       default null
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor            out sys_refcursor
);

procedure get_object_operations(
    i_card_id            in    com_api_type_pkg.t_medium_id
  , i_card_number        in    com_api_type_pkg.t_name
  , i_inst_id            in    com_api_type_pkg.t_inst_id
  , i_account_id         in    com_api_type_pkg.t_account_id
  , i_account_number     in    com_api_type_pkg.t_account_number
  , i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_customer_number    in    com_api_type_pkg.t_name
  , i_lang               in    com_api_type_pkg.t_dict_value      default null
  , i_start_date         in    date
  , i_end_date           in    date
  , i_status_tab         in    com_dict_tpt                       default com_dict_tpt()
  , i_oper_type          in    com_api_type_pkg.t_dict_value      default null
  , i_msg_type           in    com_api_type_pkg.t_dict_value      default null
  , i_match_status       in    com_api_type_pkg.t_dict_value      default null
  , i_merchant_number    in    com_api_type_pkg.t_merchant_number default null
  , i_merchant_name      in    com_api_type_pkg.t_name            default null
  , o_ref_cursor         out   sys_refcursor
);

procedure get_object_operations(
    i_card_uid              in    com_api_type_pkg.t_name
  , i_card_number           in    com_api_type_pkg.t_name
  , i_inst_id               in    com_api_type_pkg.t_inst_id
  , i_account_id            in    com_api_type_pkg.t_account_id
  , i_account_number        in    com_api_type_pkg.t_account_number
  , i_customer_id           in    com_api_type_pkg.t_medium_id
  , i_customer_number       in    com_api_type_pkg.t_name
  , i_lang                  in    com_api_type_pkg.t_dict_value      default null
  , i_start_date            in    date
  , i_end_date              in    date
  , i_status_tab            in    com_dict_tpt                       default com_dict_tpt()
  , i_oper_type             in    com_api_type_pkg.t_dict_value      default null
  , i_msg_type              in    com_api_type_pkg.t_dict_value      default null
  , i_match_status          in    com_api_type_pkg.t_dict_value      default null
  , i_merchant_number       in    com_api_type_pkg.t_merchant_number default null
  , i_merchant_name         in    com_api_type_pkg.t_name            default null
  , o_ref_cursor           out    sys_refcursor
);

function get_merchant_address(
    i_merchant_postcode  in     com_api_type_pkg.t_name
  , i_merchant_country   in     com_api_type_pkg.t_name
  , i_merchant_region    in     com_api_type_pkg.t_name
  , i_merchant_city      in     com_api_type_pkg.t_name
  , i_merchant_street    in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_full_desc;

procedure get_customer_ntf_settings(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_customer_number    in    com_api_type_pkg.t_name
  , i_inst_id            in    com_api_type_pkg.t_inst_id
  , i_account_id         in    com_api_type_pkg.t_account_id
  , i_account_number     in    com_api_type_pkg.t_account_number
  , i_card_id            in    com_api_type_pkg.t_medium_id
  , i_card_number        in    com_api_type_pkg.t_name
  , i_lang               in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor         out   sys_refcursor
);

procedure get_customer_ntf_settings(
    i_customer_id       in    com_api_type_pkg.t_medium_id
  , i_customer_number   in    com_api_type_pkg.t_name
  , i_inst_id           in    com_api_type_pkg.t_inst_id
  , i_account_id        in    com_api_type_pkg.t_account_id
  , i_account_number    in    com_api_type_pkg.t_account_number
  , i_card_uid          in    com_api_type_pkg.t_name
  , i_card_number       in    com_api_type_pkg.t_name
  , i_lang              in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor       out    sys_refcursor
);

/*
 * Returns all limits for specified entity object.
 * Procedure supports searching by 3 entity types, every entity should be specified
 * either its identifier or number.
 * Searching priority: 1) card; 2) account; 3) customer.
 * @i_inst_id    is a mandatory parameter for searching by any entity type
 */
procedure get_object_limits(
    i_card_number          in    com_api_type_pkg.t_name
  , i_card_id              in    com_api_type_pkg.t_medium_id
  , i_account_id           in    com_api_type_pkg.t_account_id
  , i_account_number       in    com_api_type_pkg.t_account_number
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_customer_id          in    com_api_type_pkg.t_medium_id
  , i_customer_number      in    com_api_type_pkg.t_name
  , i_lang                 in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor           out   sys_refcursor
);

procedure get_object_limits(
    i_card_number          in    com_api_type_pkg.t_name
  , i_card_uid             in    com_api_type_pkg.t_name
  , i_account_id           in    com_api_type_pkg.t_account_id
  , i_account_number       in    com_api_type_pkg.t_account_number
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_customer_id          in    com_api_type_pkg.t_medium_id
  , i_customer_number      in    com_api_type_pkg.t_name
  , i_lang                 in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor          out    sys_refcursor
);

/*
 * Returns all authorization schemes for card's institution.
 * Start/end date are returned only for schemes that are defined directly for the card i_card_id/i_card_number and active currently.
 * @i_only_active    if TRUE then only active schemes for the card will be shown
 */
procedure get_card_auth_schemes(
    i_card_id              in    com_api_type_pkg.t_medium_id
  , i_card_number          in    com_api_type_pkg.t_name
  , i_only_active          in    com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id       default null
  , i_lang                 in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor           out   sys_refcursor
);

procedure get_card_auth_schemes(
    i_card_uid             in    com_api_type_pkg.t_name
  , i_card_number          in    com_api_type_pkg.t_name
  , i_only_active          in    com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id       default null
  , i_lang                 in    com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor           out   sys_refcursor
);

procedure get_cardholder_data(
    i_card_number          in     com_api_type_pkg.t_card_number
  , i_card_id              in     com_api_type_pkg.t_medium_id    default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id      default null
  , i_lang                 in     com_api_type_pkg.t_dict_value   default null
  , o_surname              out    com_api_type_pkg.t_name
  , o_first_name           out    com_api_type_pkg.t_name
  , o_second_name          out    com_api_type_pkg.t_name
  , o_gender               out    com_api_type_pkg.t_dict_value
  , o_birthday             out    date
  , o_cardholder_number    out    com_api_type_pkg.t_short_desc
  , o_cardholder_name      out    com_api_type_pkg.t_name
  , o_document_cursor      out    sys_refcursor
);

procedure get_cardholder_data(
    i_card_number          in     com_api_type_pkg.t_card_number
  , i_card_uid             in     com_api_type_pkg.t_name         default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id      default null
  , i_lang                 in     com_api_type_pkg.t_dict_value   default null
  , o_surname              out    com_api_type_pkg.t_name
  , o_first_name           out    com_api_type_pkg.t_name
  , o_second_name          out    com_api_type_pkg.t_name
  , o_gender               out    com_api_type_pkg.t_dict_value
  , o_birthday             out    date
  , o_cardholder_number    out    com_api_type_pkg.t_short_desc
  , o_cardholder_name      out    com_api_type_pkg.t_name
  , o_document_cursor      out    sys_refcursor
);

procedure get_cardholder_documents(
    i_cardholder_id      in     com_api_type_pkg.t_medium_id
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor         out    sys_refcursor
);

procedure get_cardholder_addresses(
    i_cardholder_id      in     com_api_type_pkg.t_medium_id
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor         out    sys_refcursor
);

procedure get_cardholder_contacts(
    i_cardholder_id      in     com_api_type_pkg.t_medium_id
  , i_lang               in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor         out    sys_refcursor
);

procedure get_cardholder_ext_data(
    i_cardholder_id        in     com_api_type_pkg.t_medium_id      default null
  , i_cardholder_number    in     com_api_type_pkg.t_name           default null
  , i_lang                 in     com_api_type_pkg.t_dict_value     default null
  , i_inst_id              in     com_api_type_pkg.t_inst_id        default null
  , o_surname              out    com_api_type_pkg.t_name
  , o_first_name           out    com_api_type_pkg.t_name
  , o_second_name          out    com_api_type_pkg.t_name
  , o_gender               out    com_api_type_pkg.t_dict_value
  , o_birthday             out    date
  , o_cardholder_number    out    com_api_type_pkg.t_short_desc
  , o_cardholder_name      out    com_api_type_pkg.t_name
  , o_document_cursor      out    sys_refcursor
  , o_address_cursor       out    sys_refcursor
  , o_contact_cursor       out    sys_refcursor
);

procedure get_last_invoice(
    i_account_number     in    com_api_type_pkg.t_name
  , i_inst_id            in    com_api_type_pkg.t_inst_id
  , o_ref_cursor         out   sys_refcursor
);


procedure get_credit_statement(
    o_xml                out   clob
  , i_account_number     in    com_api_type_pkg.t_name
  , i_inst_id            in    com_api_type_pkg.t_inst_id
  , i_lang               in    com_api_type_pkg.t_dict_value
);

procedure get_flex_fields(
    i_entity_type        in    com_api_type_pkg.t_dict_value
  , i_object_id          in    com_api_type_pkg.t_long_id
  , i_lang               in    com_api_type_pkg.t_dict_value
  , o_ref_cursor         out   sys_refcursor
);

procedure get_object_cycles(
    i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
  , o_ref_cursor           out    sys_refcursor
);

function get_available_balance_amount(
    i_account_id           in     com_api_type_pkg.t_account_id
  , i_oper_id              in     com_api_type_pkg.t_long_id
  , i_host_date            in     date
  , i_currency             in     com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money;

procedure get_account_details(
    i_account_id           in    com_api_type_pkg.t_account_id
  , i_account_number       in    com_api_type_pkg.t_account_number
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_lang                 in    com_api_type_pkg.t_dict_value     default null
  , o_ref_cursor           out   sys_refcursor
);

procedure get_account_balances(
    i_account_id           in    com_api_type_pkg.t_account_id
  , i_account_number       in    com_api_type_pkg.t_account_number
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_lang                 in    com_api_type_pkg.t_dict_value     default null
  , o_ref_cursor           out   sys_refcursor
);

procedure get_card_features(
    i_card_number          in    com_api_type_pkg.t_card_number
  , i_card_id              in    com_api_type_pkg.t_medium_id      default null
  , i_inst_id              in    com_api_type_pkg.t_inst_id        default null
  , i_lang                 in    com_api_type_pkg.t_dict_value     default null
  , o_ref_cursor           out   sys_refcursor
);

procedure get_card_features(
    i_card_number          in    com_api_type_pkg.t_card_number
  , i_card_uid             in    com_api_type_pkg.t_name           default null
  , i_inst_id              in    com_api_type_pkg.t_inst_id        default null
  , i_lang                 in    com_api_type_pkg.t_dict_value     default null
  , o_ref_cursor           out   sys_refcursor
);

/*
 * Procedure executes search of customer by incoming card number and check match of incoming key word with a stored one.
 * If key words don't match then empty outgoing parameters will be returned.
 */
procedure get_cards_customer(
    i_card_number          in       com_api_type_pkg.t_card_number
  , i_key_word             in       com_api_type_pkg.t_name
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , io_inst_id             in  out  com_api_type_pkg.t_inst_id
);

procedure get_customer_contacts(
    i_customer_id          in    com_api_type_pkg.t_medium_id
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_lang                 in    com_api_type_pkg.t_dict_value     default null
  , o_client_name          out   com_api_type_pkg.t_full_desc
  , o_phone_number         out   com_api_type_pkg.t_name
);

procedure get_credit_account_data(
    i_account_id            in      com_api_type_pkg.t_medium_id
  , io_account_number       in out  com_api_type_pkg.t_account_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_eff_date              in      date
  , i_lang                  in      com_api_type_pkg.t_dict_value               default null
  , o_closing_date          out     date
  , o_total_amount_due      out     com_api_type_pkg.t_money
  , o_exceed_limit          out     com_api_type_pkg.t_money
  , o_interest_rate         out     com_api_type_pkg.t_money
  , o_interest_amount       out     com_api_type_pkg.t_money
  , o_overdue_rate          out     com_api_type_pkg.t_money
  , o_overdue_amount        out     com_api_type_pkg.t_money
  , o_total_income          out     com_api_type_pkg.t_money
  , o_repay_amount          out     com_api_type_pkg.t_money
  , o_repay_interest        out     com_api_type_pkg.t_money
  , o_repay_overdue         out     com_api_type_pkg.t_money
  , o_remainder_debt        out     com_api_type_pkg.t_money
  , o_overdraft_balance     out     com_api_type_pkg.t_money
  , o_interest_balance      out     com_api_type_pkg.t_money
  , o_overdue_balance       out     com_api_type_pkg.t_money
  , o_due_date              out     date
  , o_min_amount_due        out     com_api_type_pkg.t_money
);

/*
 * Searching customer's identifier by provided ID card data or personal contact (communication) data.
 * Parameter <i_inst_id> is always required.
 * For search may be used either pair of parameters <i_commun_method> and <i_commun_address>
 * or parameters <i_id_type>, <i_id_series> (optional), <i_id_number>.
 * If all parameters are provided then all of them will be used in search.
 * (In other words if provided ID card data is correct but personal contact data is wrong
 *  then NULL will be returned into outgoing parameter <o_customer_id>.)
 * Note: parameter <i_commun_address> is uppercased.
 */
procedure get_customer_by_personal_data(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_commun_method         in      com_api_type_pkg.t_dict_value
  , i_commun_address        in      com_api_type_pkg.t_full_desc
  , i_id_type               in      com_api_type_pkg.t_dict_value
  , i_id_series             in      com_api_type_pkg.t_name          default null
  , i_id_number             in      com_api_type_pkg.t_name
  , i_max_count             in      com_api_type_pkg.t_long_id       default 1
  , o_customer_id_tab          out  num_tab_tpt
);

procedure get_card_by_phone(
    i_commun_address      in      com_api_type_pkg.t_full_desc
  , i_card_mask           in      com_api_type_pkg.t_card_number
  , i_inst_id             in      com_api_type_pkg.t_inst_id         default null
  , o_card_number        out      com_api_type_pkg.t_card_number
  , o_card_mask          out      com_api_type_pkg.t_card_number
);

procedure get_contract_list(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_card_number           in      com_api_type_pkg.t_card_number    default null
  , i_card_id               in      com_api_type_pkg.t_medium_id      default null
  , i_seq_number            in      com_api_type_pkg.t_inst_id        default null
  , i_expir_date            in      date                              default null
  , i_instance_id           in      com_api_type_pkg.t_medium_id      default null
  , i_account_number        in      com_api_type_pkg.t_account_number default null
  , i_account_id            in      com_api_type_pkg.t_account_id     default null
  , o_ref_cursor           out      sys_refcursor
);

procedure get_contract_list(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_card_number           in      com_api_type_pkg.t_card_number    default null
  , i_card_uid              in      com_api_type_pkg.t_name           default null
  , i_seq_number            in      com_api_type_pkg.t_inst_id        default null
  , i_expir_date            in      date                              default null
  , i_instance_id           in      com_api_type_pkg.t_medium_id      default null
  , i_account_number        in      com_api_type_pkg.t_account_number default null
  , i_account_id            in      com_api_type_pkg.t_account_id     default null
  , o_ref_cursor           out      sys_refcursor
);

procedure get_remote_banking_activity(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , o_banking_activity     out      com_api_type_pkg.t_boolean
);

procedure get_account_balances (
    i_account_id                in  com_api_type_pkg.t_account_id
  , i_balance_type            in  com_api_type_pkg.t_dict_value
  , o_balance_amount          out com_api_type_pkg.t_money
  , o_balance_currency        out com_api_type_pkg.t_curr_code
  , o_aval_balance            out com_api_type_pkg.t_money
  , o_aval_balance_currency   out com_api_type_pkg.t_curr_code
);

procedure get_specified_invoice(
    i_account_number       in    com_api_type_pkg.t_name
  , i_inst_id            in    com_api_type_pkg.t_inst_id
  , i_lang               in    com_api_type_pkg.t_dict_value    default null
  , i_invoice_age        in    com_api_type_pkg.t_seqnum        default 0
  , o_ref_cursor         out   sys_refcursor
);

procedure get_invoice_oper_aggr_data(
    i_invoice_id         in  com_api_type_pkg.t_medium_id
  , o_ref_cursor         out sys_refcursor
);

procedure get_invoice_oper_list_data(
    i_invoice_id         in  com_api_type_pkg.t_medium_id
  , o_ref_cursor         out sys_refcursor
);

procedure get_merchant_stat(
    o_xml                   out clob
  , i_customer_number   in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_start_date        in      date
  , i_end_date          in      date
);

procedure get_iss_appl_list(
    i_customer_number   in     com_api_type_pkg.t_name          default null
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id     default null
  , i_operator_id       in     com_api_type_pkg.t_name          default null
  , i_appl_status       in     com_api_type_pkg.t_dict_value    default null
  , i_flow_id           in     com_api_type_pkg.t_dict_value    default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
  , o_ref_cursor           out sys_refcursor
);

procedure get_customer_by_card(
    i_card_number       in      com_api_type_pkg.t_card_number
  , i_lang              in      com_api_type_pkg.t_dict_value    default null
  , io_inst_id          in out  com_api_type_pkg.t_inst_id
  , o_customer_id          out  com_api_type_pkg.t_medium_id
  , o_customer_number      out  com_api_type_pkg.t_name
);

procedure get_fin_overview_list(
    i_card_number       in       com_api_type_pkg.t_card_number
  , i_account_number    in       com_api_type_pkg.t_account_number  default null
  , i_inst_id           in       com_api_type_pkg.t_inst_id         default null
  , o_cardholder_number out      com_api_type_pkg.t_name
  , o_cardholder_name   out      com_api_type_pkg.t_name
  , o_ref_cursor        out      sys_refcursor
);

procedure get_fin_overview_fee_list(
    i_account_id        in       com_api_type_pkg.t_account_id
  , o_ref_cursor        out      sys_refcursor
);

procedure get_crd_card_payment_list(
    i_card_number       in       com_api_type_pkg.t_card_number
  , i_account_number    in       com_api_type_pkg.t_account_number  default null
  , i_inst_id           in       com_api_type_pkg.t_inst_id         default null
  , o_ref_cursor        out      sys_refcursor
);

procedure get_crd_account_payment_list(
    i_account_id        in       com_api_type_pkg.t_account_id
  , o_ref_cursor        out      sys_refcursor
);

procedure accelerate_dpp(
    i_external_auth_id        in     com_api_type_pkg.t_attr_name
  , i_new_count               in     com_api_type_pkg.t_tiny_id    default null
  , i_payment_amount          in     com_api_type_pkg.t_money      default null
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
  , i_check_mad_aging_unpaid  in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
);

function get_percent_rate(
    i_account_id         in      com_api_type_pkg.t_medium_id
  , i_service_id         in      com_api_type_pkg.t_short_id        default null
  , i_product_id         in      com_api_type_pkg.t_short_id
  , i_split_hash         in      com_api_type_pkg.t_tiny_id
  , i_eff_date           in      date                               default null
  , i_fee_type           in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_money;

procedure get_customer_info(
    i_card_number         in     com_api_type_pkg.t_card_number
  , i_inst_id             in     com_api_type_pkg.t_inst_id         default null
  , i_lang                in     com_api_type_pkg.t_dict_value      default null
  , o_customer_id         out    com_api_type_pkg.t_medium_id
  , o_customer_number     out    com_api_type_pkg.t_name
  , o_customer_name       out    com_api_type_pkg.t_name
  , o_national_id         out    com_api_type_pkg.t_name
  , o_customer_document   out    com_api_type_pkg.t_name
  , o_customer_phone      out    com_api_type_pkg.t_name
  , o_card_id             out    com_api_type_pkg.t_name
  , o_card_seq_number     out    com_api_type_pkg.t_inst_id
  , o_card_expiry_date    out    date
  , o_branch_code         out    com_api_type_pkg.t_name
  , o_client_tariff       out    com_api_type_pkg.t_name
  , o_address_cursor      out    sys_refcursor
  , o_account_cursor      out    sys_refcursor
);

procedure get_transaction(
    i_inst_id                    in       com_api_type_pkg.t_inst_id
  , i_customer_id                in       com_api_type_pkg.t_medium_id
  , i_lang                       in       com_api_type_pkg.t_dict_value      default null
  , i_masked_pan                 in       com_api_type_pkg.t_card_number     default null
  , i_account_number             in       com_api_type_pkg.t_account_number  default null
  , i_card_type_id               in       com_api_type_pkg.t_inst_id         default null
  , i_transaction_date_from      in       com_api_type_pkg.t_name            default null
  , i_transaction_date_to        in       com_api_type_pkg.t_name            default null
  , i_transaction_type           in       com_api_type_pkg.t_dict_value      default null
  , i_response_code              in       com_api_type_pkg.t_dict_value      default null
  , i_transactions_sorting       in       com_param_map_tpt                  default null
  , i_transaction_direction_sort in       com_api_type_pkg.t_name            default 'DESC'
  , o_transaction_cursor         out      sys_refcursor
);

procedure get_product(
    i_inst_id           in       com_api_type_pkg.t_inst_id
  , i_customer_id       in       com_api_type_pkg.t_medium_id
  , i_lang              in       com_api_type_pkg.t_dict_value      default null
  , o_product_cursor        out  sys_refcursor
);

procedure get_dictionaries(
    i_dict_version         in            com_api_type_pkg.t_name
  , i_array_dictionary_id  in            com_api_type_pkg.t_medium_id     default null
  , i_lang                 in            com_api_type_pkg.t_dict_value    default null
  , i_inst_id              in            com_api_type_pkg.t_inst_id       default null
  , io_xml                 in out nocopy clob
);

procedure get_currency_rates(
    i_inst_id              in            com_api_type_pkg.t_inst_id        default null
  , i_base_rate_export     in            com_api_type_pkg.t_boolean        default null
  , i_rate_type            in            com_api_type_pkg.t_dict_value     default null
  , i_eff_date             in            date                              default null
  , i_dict_version         in            com_api_type_pkg.t_name
  , io_xml                 in out nocopy clob
);

procedure get_mcc(
    i_lang                 in     com_api_type_pkg.t_dict_value    default null
  , i_dict_version         in     com_api_type_pkg.t_name
  , o_xml                     out clob
);

procedure get_unbilled_debts(
    i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_account_id           in      com_api_type_pkg.t_long_id
  , i_account_number       in      com_api_type_pkg.t_account_number
  , o_unbilled_debt           out  sys_refcursor
);

procedure import_pmo_response(
    i_pmo_response_tab      in      pmo_response_tpt            default pmo_response_tpt()
  , i_create_operation      in      com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
);

procedure export_pmo(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_purpose_id                in      com_api_type_pkg.t_short_id     default null
  , i_pmo_status_change_mode    in      com_api_type_pkg.t_dict_value   default null
  , i_max_count                 in      com_api_type_pkg.t_tiny_id      default null
  , o_ref_cursor                   out  com_api_type_pkg.t_ref_cur
);

procedure export_pmo_data(
    i_order_id                  in      com_api_type_pkg.t_long_id
  , o_ref_cursor                   out  com_api_type_pkg.t_ref_cur
);

end itf_ui_integration_pkg;
/
