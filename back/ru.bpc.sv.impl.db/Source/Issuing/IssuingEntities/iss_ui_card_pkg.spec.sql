create or replace package iss_ui_card_pkg is

type t_card_rec is record (
    card_id             com_api_type_pkg.t_medium_id
  , card_number         com_api_type_pkg.t_card_number
);
type t_card_tab is table of t_card_rec index by binary_integer;

type t_account_rec is record (
    account_id          com_api_type_pkg.t_medium_id
  , account_number      com_api_type_pkg.t_account_number
  , friendly_name       com_api_type_pkg.t_account_number
);
type t_account_tab is table of t_account_rec index by binary_integer;

procedure get_cardholder_cards(
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , o_cards_tab                    out iss_ui_card_pkg.t_card_tab
);

procedure get_cardholder_accounts(
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , o_account_tab                  out iss_ui_card_pkg.t_account_tab
);

/*
 * Procedure for cards' unloading in XML format.
 * @param i_appl_id           – application identifier.
 * @param i_include_limits    – include or not block of card's limits.
 * @param i_lang              - preffered language of retrieving address(es)
 * @param o_batch_id          – batch identifier.
 * @param o_cards_info        – information about cards.
 */
procedure get_cards_info(
    i_appl_id           in     com_api_type_pkg.t_long_id
  , i_include_limits    in     com_api_type_pkg.t_boolean    default null
  , i_include_service   in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_lang              in     com_api_type_pkg.t_dict_value default null
  , o_batch_id             out com_api_type_pkg.t_short_id
  , o_cards_info           out clob
);

/*
 * Procedure for card' unloading in XML format.
 * @param i_card_id           – card identifier.
 * @param i_include_limits    – include or not block of card's or account's limits.
 * @param i_include_service   – include or not block of account's services.
 * @param i_lang              - preffered language of retrieving address(es)
 * @param o_account_info      – information about account.
 * @param o_card_info         – information about card.
 */
procedure get_card_info(
    i_card_id           in     com_api_type_pkg.t_long_id
  , i_include_limits    in     com_api_type_pkg.t_boolean    default null
  , i_include_service   in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_lang              in     com_api_type_pkg.t_dict_value default null
  , o_account_info         out clob
  , o_card_info            out clob
);

end iss_ui_card_pkg;
/
