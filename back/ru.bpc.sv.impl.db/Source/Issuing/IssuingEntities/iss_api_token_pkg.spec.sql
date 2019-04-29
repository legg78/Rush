create or replace package iss_api_token_pkg is
/************************************************************
 * Tokenizator API <br />
 * Created by Alalykin A. (alalykin@bpcbt.com) at 22.09.2014 <br />
 * Last changed by $Author: alalykin $ <br />
 * $LastChangedDate:: 2014-09-22 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 40000 $ <br />
 * Module: iss_api_token_pkg <br />
 * @headcom
 ************************************************************/

/*
 * We check if tokenization is enabled and cache setting parameter for the package,
 * then try to connect to SVTOKEN using address TOKENIZATOR_HOST:TOKENIZATOR_PORT.
 * Procedure should be normally called during the package's initialization (once per a session).
 */
procedure initialization;

/*
 * Function determines tokenization settings in system;
 * if it is enabled then function returns a token as a result of encoding of incoming PAN,
 * otherwise it returns incoming PAN without changes.
 */
function encode_card_number(
    i_card_number         in     com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_card_number deterministic;

/*
 * Function determines tokenization settings in system;
 * if it is enabled then function treats an incoming parameter as a token, decode it and returns PAN,
 * otherwise it returns incoming PAN without changes.
 * @i_mask_error — if flag is TRUE then errors aren't raised but ERROR messages are put into log
 */
function decode_card_number(
    i_card_number         in     com_api_type_pkg.t_card_number
  , i_mask_error          in     com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_card_number deterministic;

/*
 * Function determines if tokenization is used; it is necessary for searching procedures.
 */
function is_token_enabled return com_api_type_pkg.t_boolean;

end;
/
