create or replace package sec_api_des_key_pkg as
/**********************************************************
 * API for 3DES keys
 * Created by Kopachev D.(kopachev@bpcbt.com) at 21.05.2010
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br /> 
 * Module: sec_api_des_key_pkg
 * @headcom
 **********************************************************/    

/*
 * Add 3DES key
 */
    procedure add_des_key (
        o_key_id              out com_api_type_pkg.t_medium_id
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_check_value       in sec_api_type_pkg.t_check_value
    );

/*
 * Modify 3DES key
 */
    procedure modify_des_key (
        i_entity_type         in com_api_type_pkg.t_dict_value
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_check_value       in sec_api_type_pkg.t_check_value
        , i_key_value         in sec_api_type_pkg.t_key_value
    );

/*
 * Remove 3DES key
 */
    procedure remove_des_key (
        i_key_id              in com_api_type_pkg.t_medium_id
        , i_seqnum            in com_api_type_pkg.t_seqnum
    );

/*
 * Getting 3DES key
 */    
    procedure get_key (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , o_key_length        out com_api_type_pkg.t_tiny_id
        , o_key_value         out sec_api_type_pkg.t_key_value
        , o_key_prefix        out sec_api_type_pkg.t_key_prefix
        , o_check_value       out sec_api_type_pkg.t_check_value
    );

/*
 * Getting 3DES key record
 */    
    function get_key (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_mask_error        in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return sec_api_type_pkg.t_des_key_rec;

/*
 * Getting 3DES key record
 */    
    function get_key (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := null
        , i_mask_error        in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return sec_api_type_pkg.t_des_key_rec;

/*
 * Generate key check value
 */    
    procedure generate_key_check_value (
        i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , o_check_value       out sec_api_type_pkg.t_check_value
    );

/*
 * Validate key check value
 */        
    function validate_key_check_value (
        i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_key_type          in com_api_type_pkg.t_dict_value
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix 
        , i_check_value       in sec_api_type_pkg.t_check_value
    ) return com_api_type_pkg.t_boolean;
    
end;
/