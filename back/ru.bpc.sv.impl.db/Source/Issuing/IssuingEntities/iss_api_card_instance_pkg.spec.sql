create or replace package iss_api_card_instance_pkg is
/*********************************************************
*  Api for issuing card instances <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 08.12.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate:: $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: iss_api_card_instance_pkg  <br />
*  @headcom
**********************************************************/

/*
 * Get card instance identifier.
 * @param  i_card_id           - Card identifier
 * @param  i_seq_number        - Card instance sequential number
 * @param  i_expir_date        - Card instance expiration date;
 *                               only year and month specification is required, day is not taken into consideration
 */
function get_card_instance_id (
    i_card_id               in com_api_type_pkg.t_medium_id
    , i_seq_number          in com_api_type_pkg.t_tiny_id := null
    , i_expir_date          in date := null
) return com_api_type_pkg.t_medium_id;

/*
 * [2th overloaded function] Get card instance identifier by 2 of 4 possible parameters: 
 * i_card_id or i_card_number must be present TOGETHER with i_seq_number or i_expir_date 
 * @param  i_card_id      - Card identifier
 * @param  i_seq_number   - Card instance sequential number 
 * @param  i_expir_date   - Card instance expiration date;
 *                          only year and month specification is required, day is not taken into consideration
 * @param  i_raise_error  – Raise exception CARD_INSTANCE_NOT_FOUND if searching process failed 
 */
function get_card_instance_id(
    i_card_id               in com_api_type_pkg.t_medium_id
  , i_card_number           in com_api_type_pkg.t_card_number   
  , i_seq_number            in com_api_type_pkg.t_tiny_id
  , i_expir_date            in date
  , i_raise_error           in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id;

/*
 * [3th overloaded function] Get card instance identifier by 4 parameters, 
 *                           (i_seq_number and i_expir_date are interchangeable parameters): 
 * @param  i_card_id      - Card identifier
 * @param  i_seq_number   - Card instance sequential number 
 * @param  i_expir_date   - Card instance expiration date;
 *                          only year and month specification is required, day is not taken into consideration
 * @param  i_status       - Preferable card instance's status, it is an optional parameter, so that if instance 
 *                          with such status doesn't exist then minimal card instance's identifier will be returned
 * @param  i_raise_error  – Raise exception CARD_INSTANCE_NOT_FOUND if searching process failed
 */
function get_card_instance_id(
    i_card_id               in com_api_type_pkg.t_medium_id
  , i_seq_number            in com_api_type_pkg.t_tiny_id
  , i_expir_date            in date
  , i_state                 in com_api_type_pkg.t_dict_value
  , i_raise_error           in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id;

/*
 * Register new pvv value.
 * @param  i_card_instance_id  - Card instance identifier
 * @param  i_pvv               - New pvv value
 * @param  i_change_id         - Transaction identifier which changed when PVV
 * @param  i_pvk_index         - PVK Index used for PVV generation
 */
procedure register_pvv (
    i_card_instance_id      in com_api_type_pkg.t_medium_id
    , i_pvv                 in com_api_type_pkg.t_tiny_id
    , i_pin_block           in com_api_type_pkg.t_pin_block
    , i_change_id           in com_api_type_pkg.t_long_id
    , i_pvk_index           in com_api_type_pkg.t_tiny_id := null
);

/*
 * Update sensitive data of a card's instance.
 */
procedure update_sensitive_data(
    i_id                    in com_api_type_pkg.t_medium_id
  , i_pvk_index             in com_api_type_pkg.t_tiny_id
  , i_pvv                   in com_api_type_pkg.t_tiny_id
  , i_pin_offset            in com_api_type_pkg.t_cmid
  , i_pin_block             in com_api_type_pkg.t_pin_block
  , i_pin_block_format      in com_api_type_pkg.t_dict_value
);

procedure update_sensitive_data (
    i_id                    in com_api_type_pkg.t_medium_tab
    , i_pvk_index           in com_api_type_pkg.t_tiny_tab
    , i_pvv                 in com_api_type_pkg.t_tiny_tab
    , i_pin_offset          in com_api_type_pkg.t_cmid_tab
    , i_pin_block           in com_api_type_pkg.t_varchar2_tab
    , i_pin_block_format    in com_api_type_pkg.t_dict_tab
);

/*
 * Rollback pvv value.
 * @param  i_card_instance_id  - Card instance identifier
 * @param  i_change_id         - Transaction identifier which changed when PVV
 */
procedure rollback_pvv (
    i_card_instance_id      in com_api_type_pkg.t_medium_id
    , i_change_id           in com_api_type_pkg.t_long_id
);

/*
 * Add card instance.
 * @param  i_card_number       - Card number identifier uses if <i_card> is null 
 * @param  io_card_instance    - Card instance record from iss_api_type_pkg, fields <id> and <card_id> are overwritten 
 * @param  i_register_event    - Register event flag ( 1-Yes, 0 - No )
 * @param  i_status_reason     - Card status reason
 * @param  i_reissue_command   - Card reissue command
 */
procedure add_card_instance(
    i_card_number           in     com_api_type_pkg.t_card_number
  , io_card_instance        in out iss_api_type_pkg.t_card_instance
  , i_register_event        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_status_reason         in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_command       in     com_api_type_pkg.t_dict_value    default null
);

/*
 * Add card instance.
 * @param  i_card_number       - Card number identifier uses if <i_card> is null 
 * @param  io_card_instance    - Card instance record from iss_api_type_pkg, fields <id> and <card_id> are overwritten 
 * @param  i_register_event    - Register event flag ( 1-Yes, 0 - No )
 * @param  i_status_reason     - Card status reason
 * @param  i_reissue_command   - Card reissue command
 */
procedure add_card_instance(
    i_card_number           in     com_api_type_pkg.t_card_number
  , io_card_instance        in out iss_api_type_pkg.t_card_instance
  , i_register_event        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_status_reason         in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_command       in     com_api_type_pkg.t_dict_value    default null
  , i_need_postponed_event  in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , io_postponed_event_tab  in out nocopy evt_api_type_pkg.t_postponed_event_tab
);

/*
 * Change agent for active card instances of a contract 
 * @param  i_contract_id       - All card's instances for this contract will be processed 
 * @param  i_new_agent_id      - Id of the new agent 
 */
procedure change_agent(
    i_contract_id           in     com_api_type_pkg.t_medium_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_new_agent_id          in     com_api_type_pkg.t_agent_id
);

/*
 * Change card instance state. 
 * @param  i_id              - card instance identifier 
 * @param  i_card_state      - new card instance state (CSTE dictionary) 
 */
procedure change_card_state(
    i_id                    in     com_api_type_pkg.t_medium_id
  , i_card_state            in     com_api_type_pkg.t_dict_value
  , i_raise_error           in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

function get_card_uid (
    i_card_instance_id      in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name;

/*
 * Get card instance record. 
 * @param  i_id              - card instance identifier 
 * @param  i_card_id         - card identifier may be optionally checked during a search
 */
function get_instance(
    i_id                    in     com_api_type_pkg.t_medium_id
  , i_card_id               in     com_api_type_pkg.t_medium_id     default null
  , i_raise_error           in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_card_instance;

procedure set_preceding_instance_id(
    i_instance_id           in     com_api_type_pkg.t_medium_id
  , i_preceding_instance_id in     com_api_type_pkg.t_medium_id
);

/*
 * Register new pin offset value.For IBM3624 method.
 * @param  i_card_instance_id  - Card instance identifier
 * @param  i_pin_offset        - New Pin offset value
 * @param  i_change_id         - Transaction identifier which changed when Pin offset
 * @param  i_pvk_index         - PVK Index used for Pin offset generation
 */
procedure register_pin_offset (
    i_card_instance_id      in     com_api_type_pkg.t_medium_id
  , i_pin_offset            in     com_api_type_pkg.t_cmid
  , i_pin_block             in     com_api_type_pkg.t_pin_block
  , i_change_id             in     com_api_type_pkg.t_long_id
  , i_pvk_index             in     com_api_type_pkg.t_tiny_id := null
);

end iss_api_card_instance_pkg;
/
