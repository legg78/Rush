create or replace package sec_ui_des_key_pkg as
/************************************************************
 * User interface for 3DES crypto keys <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 01.04.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: sec_ui_des_key_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Get standart key type
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_key_type            - Internal specific key type
 */
    function get_standart_key_type (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_key_type          in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value;
    
/*
 * Get internal key type (ENKT dictionary)
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_standard_key_type   - Communication standard specific key type
 */
    function get_key_type (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_standard_key_type in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value;
    
/*
 * Add new 3DES key
 * @param  o_des_key_id          - Key identifier
 * @param  o_seqnum              - Sequence number
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_standard_key_type   - Communication standard specific key type
 * @param  i_key_index           - Key index
 * @param  i_key_length          - Key length (16 - single, 32 - double, 48 - triple)
 * @param  i_key_value           - Key value
 * @param  i_key_prefix          - Key prefix. Specify key type and using for key scheme identification by HSM
 * @param  i_check_value         - Key check value
 * @param  i_check_kcv           - Need check key check value
 */
    procedure add_des_key (
        o_des_key_id          out com_api_type_pkg.t_medium_id
        , o_seqnum            out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_check_value       in sec_api_type_pkg.t_check_value := null
        , i_check_kcv         in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    );

/*
 * Modify 3DES key
 * @param  i_des_key_id          - Key identifier
 * @param  io_seqnum             - Sequence number
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_standard_key_type   - Communication standard specific key type
 * @param  i_key_index           - Key index
 * @param  i_key_prefix          - Key prefix. Specify key type and using for key scheme identification by HSM
 * @param  i_key_length          - Key length (16 - single, 32 - double, 48 - triple)
 * @param  i_key_value           - Key value
 * @param  i_check_value         - Key check value
 * @param  i_check_kcv           - Need check key check value
 */
    procedure modify_des_key (
        i_des_key_id          in com_api_type_pkg.t_medium_id
        , io_seqnum           in out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_check_value       in sec_api_type_pkg.t_check_value := null
        , i_check_kcv         in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    );

/*
 * Remove 3DES key
 */
    procedure remove_des_key (
        i_des_key_id          in com_api_type_pkg.t_medium_id
      , i_seqnum              in com_api_type_pkg.t_seqnum
    );

/*
 * Generate new 3DES key
 * @param  io_id                - Key identifier
 * @param  io_seqnum             - Sequence number
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_standard_key_type   - Communication standard specific key type
 * @param  i_key_index           - Key index
 * @param  i_key_length          - Key length (16 - single, 32 - double, 48 - triple)
 * @param  i_key_prefix          - Key prefix. Specify key type and using for key scheme identification by HSM
 * @param  i_key_comp_num        - Key component count
 * @param  i_format_id           - Name format for print key component
 */
    procedure generate_des_key (
        io_id                 in out com_api_type_pkg.t_medium_id
        , io_seqnum           in out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_key_comp_num      in com_api_type_pkg.t_tiny_id
        , i_format_id         in com_api_type_pkg.t_tiny_id
    );

/*
 * Translate 3DES key
 * @param  io_id                - Key identifier
 * @param  io_seqnum             - Sequence number
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_standard_key_type   - Communication standard specific key type
 * @param  i_key_index           - Key index
 * @param  i_key_length          - Key length (16 - single, 32 - double, 48 - triple)
 * @param  i_source_key_prefix   - Source key prefix. Specify key type and using for key scheme identification by HSM
 * @param  i_source_key          - Source key value
 * @param  i_key_enc_key         - Key encription key
 * @param  io_dest_check_value   - Destination key check value
 * @param  i_dest_key_prefix     - Destination key prefix
 */
    procedure translate_des_key (
        io_id                 in out com_api_type_pkg.t_medium_id
        , io_seqnum           in out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_source_key_prefix in sec_api_type_pkg.t_key_prefix
        , i_source_key        in sec_api_type_pkg.t_key_value
        , i_key_enc_key       in com_api_type_pkg.t_dict_value
        , io_dest_check_value in out sec_api_type_pkg.t_check_value
        , i_dest_key_prefix   in sec_api_type_pkg.t_key_prefix
    );

/*
 * Generate key check value for key
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_standard_key_type   - Communication standard specific key type
 * @param  i_key_length          - Key length (16 - single, 32 - double, 48 - triple)
 * @param  i_key_value           - Key value
 * @param  i_key_prefix          - Key prefix. Specify key type and using for key scheme identification by HSM
 * @param  o_check_value         - Key check value
 */
    procedure generate_key_check_value (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , o_check_value       out sec_api_type_pkg.t_check_value
    );

/*
 * Validate key check value
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_standard_key_type   - Communication standard specific key type
 * @param  i_key_length          - Key length (16 - single, 32 - double, 48 - triple)
 * @param  i_key_value           - Key value
 * @param  i_key_prefix          - Key prefix. Specify key type and using for key scheme identification by HSM
 * @param  i_check_value         - Key check value
 */
    function validate_key_check_value (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_check_value       in sec_api_type_pkg.t_check_value
    ) return com_api_type_pkg.t_boolean;

/*
 * Getting 3DES key identifier
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_standard_key_type   - Communication standard specific key type
 * @param  i_key_index           - Key index
 */
    function get_des_key (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
    ) return com_api_type_pkg.t_medium_id;

end;
/
