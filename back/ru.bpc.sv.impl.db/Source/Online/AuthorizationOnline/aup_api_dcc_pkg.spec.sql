create or replace package aup_api_dcc_pkg is
/****************************************************************************
 *  The package for processing authorizations with DCC functionality <br />
 *
 *  Created by B. Madan (madan@bpcbt.com) at 31.12.2014 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate$ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: aup_api_dcc_pkg <br />
 *  @headcom
 ****************************************************************************/

/****************************************************************************
 *
 * The function returns the currency of the card's account.
 *
 * @param i_card_number  Card number (Primary Account Number)
 * @return Currency of the card's account
 *
 ****************************************************************************/
function get_currency_by_card_number (
    i_card_number  in  com_api_type_pkg.t_card_number
) return
    com_api_type_pkg.t_curr_code;

/****************************************************************************
 *
 * The function checks for DCC is possible for the operation on the terminal.
 * If it is possible then the function returns DCC conversion parameters.
 *
 * @param i_terminal_id         Terminal's ID
 * @param i_card_number         Card number (Primary Account Number)
 * @param i_amount              Amount of the operation
 * @param i_currency            Currency of the operation
 * @param o_conversion_amount   Resulted amount in conversion currency
 * @param o_conversion_currency Currency for conversion
 * @param o_conversion_rate     Rate used for conversion
 * @param o_conversion_fee      Fee for using of DCC
 * @return TRUE or FALSE depending on the DCC checks result
 *
 ****************************************************************************/
function is_dcc_possible (
    i_terminal_id           in com_api_type_pkg.t_short_id
  , i_card_number           in com_api_type_pkg.t_card_number
  , i_amount                in com_api_type_pkg.t_money
  , i_currency              in com_api_type_pkg.t_curr_code
  , o_conversion_amount    out com_api_type_pkg.t_money
  , o_conversion_currency  out com_api_type_pkg.t_curr_code
  , o_conversion_rate      out com_api_type_pkg.t_rate
  , o_conversion_fee       out com_api_type_pkg.t_money
) return
    com_api_type_pkg.t_boolean;

end aup_api_dcc_pkg;
/
