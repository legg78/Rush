create or replace package sec_api_rsa_key_pkg is
/**********************************************************
 * API for RSA crypto keys
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
 * Revision: $LastChangedRevision: 8281 $ <br /> 
 * Module: sec_api_rsa_key_pkg
 * @headcom
 **********************************************************/    

/*
 * Getting RSA key set
 * @param i_id          - RSA key set identifier
 * @param i_object_id   - Owner entity identifier
 * @param i_entity_type - Owner entity type
 * @param i_key_type    - Key type
 * @param i_key_index   - Key index
 * @param i_mask_error  - Mask error when not found key
 */
    function get_rsa_key (
        i_id                    in com_api_type_pkg.t_medium_id
        , i_object_id           in com_api_type_pkg.t_long_id := null
        , i_entity_type         in com_api_type_pkg.t_dict_value := null
        , i_key_type            in com_api_type_pkg.t_dict_value := null
        , i_key_index           in com_api_type_pkg.t_tiny_id := null
        , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return sec_api_type_pkg.t_rsa_key_rec;

/*
 * Getting authority RSA key set
 * @param i_key_index   - Key index
 * @param i_object_id   - Authority identifier
 * @param i_mask_error  - Mask error when not found key
 */
    function get_authority_key (
        i_key_index             in com_api_type_pkg.t_tiny_id
        , i_authority_id        in com_api_type_pkg.t_tiny_id
        , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return sec_api_type_pkg.t_rsa_key_rec;

/*
 * Getting issuer RSA key set
 * @param i_key_index   - Key index
 * @param i_mask_error  - Mask error when not found key
 */
    function get_issuer_key (
        i_key_index             in com_api_type_pkg.t_tiny_id
        , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return sec_api_type_pkg.t_rsa_key_rec;
    
/*
 * Add/Modify RSA key set
 * @param i_id                  RSA key set identifier
 */
     procedure set_rsa_keypair (
        io_id                   in out com_api_type_pkg.t_medium_id
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_lmk_id              in com_api_type_pkg.t_tiny_id
        , i_key_type            in com_api_type_pkg.t_dict_value
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_expir_date          in date := null
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value := null
        , i_modulus_length      in com_api_type_pkg.t_tiny_id := null
        , i_exponent            in com_api_type_pkg.t_exponent := null
        , i_public_key          in com_api_type_pkg.t_key := null
        , i_private_key         in com_api_type_pkg.t_key := null
        , i_public_key_mac      in com_api_type_pkg.t_pin_block := null
    );

/*
 * Generate issuer RSA key set (MasterCard/Visa)
 * @param                   ...
 */
    procedure generate_rsa_keypair (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_expir_date          in date
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in com_api_type_pkg.t_dict_value
        , i_serial_number       in sec_api_type_pkg.t_tracking_number
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
        , i_authority_type      in com_api_type_pkg.t_dict_value
        , o_key                 out sec_api_type_pkg.t_rsa_key_rec
        , o_certificate         out com_api_type_pkg.t_key
        , o_hash                out com_api_type_pkg.t_key
    );

/*
 * Generate RSA key set
 * @param                   ...
 */    
    procedure generate_rsa_keypair (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , o_public_key          out com_api_type_pkg.t_key
        , o_private_key         out com_api_type_pkg.t_key
    );

    procedure remove_rsa_key (
        i_key_id              in com_api_type_pkg.t_medium_id
        , i_seqnum            in com_api_type_pkg.t_seqnum
    );

end;
/
