create or replace package iss_api_card_token_pkg is
/*********************************************************
*  Api for issuing card tokens <br />
*  Created by Manoli M.(manoli@bpcbt.com)  at 10.03.2017 <br />
*  Module: iss_api_card_token_pkg  <br />
*  @headcom
**********************************************************/

/*
 * Add card token.
 * @param  io_token_id         - Token identifier
 * @param  i_card_id           - Card number identifier
 * @param  i_card_instance_id  - Card instance identifier
 * @param  i_token             - Card token
 * @param  i_split_hash        - Split hash value
 * @param  i_init_oper_id      - Operation identifier which create card token
 * @param  i_wallet_provider   - Wallet provider
 */
procedure add_token(
    i_token_id         in      com_api_type_pkg.t_medium_id
  , i_card_id          in      com_api_type_pkg.t_medium_id
  , i_card_instance_id in      com_api_type_pkg.t_medium_id
  , i_token            in      com_api_type_pkg.t_card_number
  , i_split_hash       in      com_api_type_pkg.t_tiny_id
  , i_init_oper_id     in      com_api_type_pkg.t_long_id
  , i_wallet_provider  in      com_api_type_pkg.t_dict_value
);

/*
 * Change card token status.
 * @param  i_token_id           - Token identifier
 * @param  i_card_instance_id   - Card instance identifier
 * @param  i_status             - New status for token
 * @param  i_close_sess_file_id - Session_file_id of closing token (set status to suspended)
 */
procedure change_token_status(
    i_token_id              in com_api_type_pkg.t_medium_id
  , i_status                in com_api_type_pkg.t_dict_value
  , i_card_instance_id      in com_api_type_pkg.t_medium_id   default null
  , i_close_sess_file_id    in com_api_type_pkg.t_long_id     default null
  , i_init_oper_id          in com_api_type_pkg.t_long_id     default null
);

procedure change_token_status(
    i_event_type            in com_api_type_pkg.t_dict_value
  , i_initiator             in com_api_type_pkg.t_dict_value
  , i_card_instance_id      in com_api_type_pkg.t_medium_id   default null
  , i_reason                in com_api_type_pkg.t_dict_value
  , i_inst_id               in com_api_type_pkg.t_tiny_id     default null
  , i_eff_date              in date                           default null
);

/*
 * Relink card tokens to new card.
 * @param  i_card_instance_id  - Card instance identifier
 */
procedure relink_token(
    i_card_instance_id      in com_api_type_pkg.t_medium_id
);

function get_token(
    i_card_id               in com_api_type_pkg.t_medium_id
  , i_mask_error            in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_card_token_rec;

function get_token(
    i_token                 in com_api_type_pkg.t_card_number
  , i_mask_error            in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_card_token_rec;

function get_card_id(
    i_token                 in com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_medium_id;

function get_token_id(
    i_token                 in com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_medium_id;

end iss_api_card_token_pkg;
/
