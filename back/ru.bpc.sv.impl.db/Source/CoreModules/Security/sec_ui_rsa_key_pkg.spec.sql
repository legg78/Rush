create or replace package sec_ui_rsa_key_pkg is
/************************************************************
 * User interface for RSA keys <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: sec_ui_rsa_key_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Generate RSA key and save into db
 */
    procedure generate_rsa_keypair (
        o_id                    out com_api_type_pkg.t_medium_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_key_type            in com_api_type_pkg.t_dict_value
        , i_key_index           in com_api_type_pkg.t_tiny_id := null
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value := null
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_expir_date          in date := null
    );
    
/*
 * Add/modify RSA key into db
 * @param  o_id                  - Key identifier
 * @param  o_seqnum              - Sequence number
 * @param  i_authority_id        - Authority identifier
 * @param  i_object_id           - Object identifier to which linked key
 * @param  i_entity_type         - Entity type to which linked key
 * @param  i_hsm_device_id       - HSM device identifier
 * @param  i_key_index           - Key index
 * @param  i_sign_algorithm      - Key signature algorithm
 * @param  i_modulus_length      - Public key modulus length in bit
 * @param  i_exponent            - Public key exponent
 * @param  i_expir_date          - Certificate expiration date
 * @param  i_tracking_number     - Certificate request number or member identifier assigned by certificate authority
 * @param  i_subject_id          - Certificate subject identifier
 * @param  i_visa_service_id     - Identifies specific Visa service
 * @param  i_lang                - Language
 * @param  i_description         - Key description
 * @param  i_authority_key_index - Authority key index 
 */
    procedure generate_rsa_keypair (
        o_id                    out com_api_type_pkg.t_medium_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_authority_id        in com_api_type_pkg.t_tiny_id
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_key_index           in com_api_type_pkg.t_tiny_id
        , i_sign_algorithm      in com_api_type_pkg.t_dict_value
        , i_modulus_length      in com_api_type_pkg.t_tiny_id
        , i_exponent            in com_api_type_pkg.t_exponent
        , i_expir_date          in date
        , i_tracking_number     in sec_api_type_pkg.t_tracking_number
        , i_subject_id          in sec_api_type_pkg.t_subject_id
        , i_visa_service_id     in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_description         in com_api_type_pkg.t_full_desc
        , i_authority_key_index in com_api_type_pkg.t_tiny_id := null
    );

/*
 * Remove RSA key from db
 * @param  i_id                  - Key identifier
 * @param  i_seqnum              - Sequence number 
 */
    procedure remove_rsa_keypair (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

/*
 * Link authority key index with certified key
 * @param  i_certified_key_index - Certified key index
 * @param  i_authority_key_index - Authority key index
 */
    procedure link_authority_key_index (
        i_certified_key_id      in com_api_type_pkg.t_medium_id
        , i_authority_key_index in com_api_type_pkg.t_tiny_id
    );

/*
 * Save (add or modify) rsa key into db
 * @param  io_id                - Key identifier
 * @param  i_object_id          - Object identifier to which linked key
 * @param  i_entity_type        - Entity type to which linked key
 * @param  i_lmk_id             - HSM lmk identifier
 * @param  i_key_type           - Key type
 * @param  i_key_index          - Key index
 * @param  i_expir_date         - Certificate expiration date
 * @param  i_sign_algorithm     - Key signature algorithm
 * @param  i_modulus_length     - Public key modulus length in bit
 * @param  i_exponent           - Public key exponent
 * @param  i_public_key         - Public key
 * @param  i_private_key        - Private key
 * @param  i_public_key_mac     - MAC of public component
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
    
end;
/
