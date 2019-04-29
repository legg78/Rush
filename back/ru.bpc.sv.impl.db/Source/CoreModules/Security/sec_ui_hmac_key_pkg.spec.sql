create or replace package sec_ui_hmac_key_pkg as
/************************************************************
 * User interface for HMAC crypto keys <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 01.04.2010 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: sec_ui_hmac_key_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add HMAC key into db
 * @param  o_id            - Key identifier
 * @param  o_seqnum        - Sequence number
 * @param  i_object_id     - Object identifier
 * @param  i_entity_type   - Entity type
 * @param  i_hsm_device_id - HSM device identifier
 * @param  i_key_index     - Key index
 * @param  i_key_length    - Key length
 * @param  i_key_value     - Key value
 */
    procedure add_hmac_key (
        o_id                  out com_api_type_pkg.t_medium_id
        , o_seqnum            out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
    );

/*
 * Generate HMAC key and save into db
 * @param  o_id            - Key identifier
 * @param  o_seqnum        - Sequence number
 * @param  i_object_id     - Object identifier
 * @param  i_entity_type   - Entity type
 * @param  i_hsm_device_id - HSM device identifier
 * @param  i_key_index     - Key index
 * @param  i_key_length    - Key length
 */
    procedure generate_hmac_key (
        o_id                  out com_api_type_pkg.t_medium_id
        , o_seqnum            out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_length        in com_api_type_pkg.t_tiny_id
    );

/*
 * Remove HMAC key from db
 * @param  o_id            - Key identifier
 * @param  o_seqnum        - Sequence number
 */
    procedure remove_hmac_key (
        i_id                  in com_api_type_pkg.t_medium_id
        , i_seqnum            in com_api_type_pkg.t_seqnum
    );

end;
/
