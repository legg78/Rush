create or replace package sec_api_rsa_certificate_pkg is
/**********************************************************
 * API for RSA certificate
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
 * Revision: $LastChangedRevision: 8281 $ <br /> 
 * Module: sec_api_rsa_certificate_pkg
 * @headcom
 **********************************************************/    

/*
 * Getting certificate
 * @param i_certificate_id    Certificate identifier
 */
    function get_certificate (
        i_authority_key_id          in com_api_type_pkg.t_medium_id
        , i_certified_key_id        in com_api_type_pkg.t_medium_id
        , i_mask_error              in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return sec_api_type_pkg.t_rsa_certificate_rec;
    
/*
 * Set certificate
 * @param i_id                  Certificate identifier
 */
    procedure set_certificate (
        io_id                       in out com_api_type_pkg.t_medium_id
        , i_certified_key_id        in com_api_type_pkg.t_medium_id
        , i_authority_key_id        in com_api_type_pkg.t_medium_id
        , i_authority_id            in com_api_type_pkg.t_tiny_id
        , i_state                   in com_api_type_pkg.t_dict_value
        , i_certificate             in com_api_type_pkg.t_key
        , i_reminder                in com_api_type_pkg.t_key
        , i_hash                    in com_api_type_pkg.t_key
        , i_expir_date              in date
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_serial_number           in sec_api_type_pkg.t_serial_number
        , i_visa_service_id         in com_api_type_pkg.t_dict_value
    );
    
    procedure set_certificate (
        i_certified_key_id          in com_api_type_pkg.t_medium_id
        , i_authority_key_id        in com_api_type_pkg.t_medium_id
        , i_authority_id            in com_api_type_pkg.t_tiny_id
        , i_state                   in com_api_type_pkg.t_dict_value
        , i_certificate             in com_api_type_pkg.t_key
        , i_reminder                in com_api_type_pkg.t_key
        , i_hash                    in com_api_type_pkg.t_key
        , i_expir_date              in date
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_serial_number           in sec_api_type_pkg.t_serial_number
        , i_visa_service_id         in com_api_type_pkg.t_dict_value
    );

/*
 * Set certificate state
 * @param  i_id    - Certificate identifier
 * @param  i_state - Certificate identifier
 */
    procedure set_certificate_state (
        i_id                      in com_api_type_pkg.t_medium_id
        , i_state                 in com_api_type_pkg.t_dict_value
    );
        
/*
 * Getting CA public key hash data
 * @param ...
 */    
    procedure get_ca_pk_hash_data (
        i_hsm_device_id             in com_api_type_pkg.t_tiny_id
        , i_key_index               in com_api_type_pkg.t_tiny_id
        , i_exponent                in com_api_type_pkg.t_exponent
        , i_public_key              in com_api_type_pkg.t_key
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , o_hash                    out com_api_type_pkg.t_key
    );
    
/*
 * Make certificate request
 * @param  i_key_index        - Issuer Public Key Index
 * @param  i_tracking_number  - Tracking Number
 * @param  i_subject_id       - Certificate Subject
 * @param  i_authority_type   - Authority type
 * @param  i_certificate_data - Self-certified Issuer Public Key Certificate data
 * @param  i_certificate_hash - Self-certified Issuer Public Key Certificate hash
 */    
    procedure make_certificate_request (
        i_key_index                 in com_api_type_pkg.t_tiny_id
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , i_subject_id              in sec_api_type_pkg.t_subject_id
        , i_authority_type          in com_api_type_pkg.t_dict_value
        , i_certificate_data        in com_api_type_pkg.t_key
        , i_certificate_hash        in com_api_type_pkg.t_key
    );

/*
 * Read certificate response
 * @param  i_authority_type      - Authority type
 * @param  i_issuer_cert_data    - Issuer Public Key Certificate data
 * @param  i_authority_key_index - Authority Public Key Index
 * @param  i_authority_cert_data - Authority Public Key Certificate data
 * @param  i_authority_cert_hash - Authority Public Key Certificate hash
 * @param  o_issuer_key          - Issuer Public Key 
 * @param  o_authority_key       - Payment System Public Key
 * @param  o_issuer_cert         - Issuer Public Key Certificate
 */
    procedure read_certificate_response (
        i_authority_type            in com_api_type_pkg.t_dict_value
        , i_issuer_cert_data        in blob
        , i_authority_cert_data     in blob
        , i_authority_cert_hash     in blob
        , i_issuer_key_index        in com_api_type_pkg.t_tiny_id
        , i_authority_key_index     in com_api_type_pkg.t_tiny_id
        , i_tracking_number         in sec_api_type_pkg.t_tracking_number
        , o_issuer_key              out sec_api_type_pkg.t_rsa_key_rec
        , o_authority_key           out sec_api_type_pkg.t_rsa_key_rec
        , o_issuer_cert             out sec_api_type_pkg.t_rsa_certificate_rec
    );
    
/*
 * Validate a Certification Authority Self-Signed Certificate
 * Validate an Issuer Public Key Certificate
 * @param  i_issuer_key     - Issuer Public Key 
 * @param  io_authority_key - Authority Public Key
 * @param  i_issuer_cert    - Issuer Public Key Certificate
 * @param  i_hsm_device_id  - HSM device identifier
 */
    procedure validate_iss_certificate (
        i_issuer_key                in sec_api_type_pkg.t_rsa_key_rec
        , io_authority_key          in out sec_api_type_pkg.t_rsa_key_rec
        , i_issuer_cert             in sec_api_type_pkg.t_rsa_certificate_rec
        , i_hsm_device_id           in com_api_type_pkg.t_tiny_id
    );
 
end;
/
