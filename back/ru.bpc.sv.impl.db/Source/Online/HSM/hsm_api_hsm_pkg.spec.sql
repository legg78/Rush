create or replace package hsm_api_hsm_pkg is
/************************************************************
 * API for HSM commands type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 16.07.2012 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: hsm_api_hsm_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Initialization HSM device
 */
    function init_hsm_devices (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_model_number           in varchar2
        , i_firmware               in varchar2
        , i_plugin                 in varchar2
        , i_max_connection         in pls_integer
        , o_connect_status         out varchar2
        , i_connect_status_length  in pls_integer := 200
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;

/*
 * Deinitialization HSM device
 */
    function deinit_hsm_devices (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;
    
    function reopen_logs return pls_integer;

/*
 * Generate a Random PIN
 */
    function generate_random_pin (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_lmk_id               in pls_integer
        , i_hpan                 in varchar2
        , i_pin_length           in pls_integer
        , i_pin_block_format     in varchar2
        , i_key_prefix           in varchar2
        , i_key_length           in pls_integer
        , i_key_value            in varchar2
        , o_result               out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate a VISA PIN Verification Value
 */
    function generate_pvv (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_lmk_id               in pls_integer
        , i_pvk                  in varchar2
        , i_key_prefix           in varchar2
        , i_pin_block            in varchar2
        , i_hpan                 in varchar2
        , i_pvk_index            in pls_integer
        , i_ppk                  in varchar2
        , i_ppk_prefix           in varchar2
        , o_result               out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;
    
/*
 * Generate a VISA CVV
 */
    function generate_cvv (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_lmk_id               in pls_integer
        , i_cvk                  in varchar2
        , i_key_prefix           in varchar2
        , i_hpan                 in varchar2
        , i_exp_date_char        in varchar2
        , i_service_code         in varchar2
        , o_result               out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate a PIN offset using the IBM method
 */
    function derive_ibm_offset (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_lmk_id               in pls_integer
        , i_hpan                 in varchar2
        , i_pvk                  in varchar2
        , i_key_prefix           in varchar2
        , i_decimalization_table in varchar2
        , i_pinblock             in varchar2
        , i_pinblock_format      in varchar2
        , i_pin_length           in pls_integer
        , i_validation_data      in varchar2
        , i_offset_length        in pls_integer
        , i_ppk                  in varchar2
        , i_ppk_prefix           in varchar2
        , o_result               out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Derive a PIN Using the IBM Method
 */
    function derive_ibm_pin (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_lmk_id               in pls_integer
        , i_hpan                 in varchar2
        , i_pvk                  in varchar2
        , i_key_prefix           in varchar2
        , i_decimalization_table in varchar2
        , i_offset               in varchar2
        , i_pin_length           in pls_integer
        , i_validation_data      in varchar2
        , i_ppk                  in varchar2
        , i_ppk_prefix           in varchar2
        , o_result               out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Translate a PIN from LMK to ZPK Encryption
 */
    function translate_pinblock (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_input_key_type         in varchar2
        , i_input_key_prefix       in varchar2
        , i_input_key_value        in varchar2
        , i_input_pinblock_format  in varchar2
        , i_encrypted_pin_block    in varchar2
        , i_output_key_type        in varchar2
        , i_output_key_prefix      in varchar2
        , i_output_key_value       in varchar2
        , i_output_pinblock_format in varchar2
        , i_hpan                   in varchar2
        , o_result                 out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;

/*
 * Load Formatting Data to HSM
 * Print PIN/PIN and Solicitation Data
 */
    function print_pin_mailer (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_document_type        in varchar2
        , i_ppk                  in varchar2
        , i_ppk_prefix           in varchar2
        , i_hpan                 in varchar2
        , i_pin_block            in varchar2
        , i_print_format         in varchar2
        , i_print_data           in varchar2
        , i_print_encoding       in varchar2
        , o_pin_check_value      out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate a Key
 */
    function generate_des_key (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_length           in pls_integer
        , o_key_value            out varchar2
        , io_key_prefix          in out varchar2
        , o_check_value          out varchar2
        , i_check_length         in pls_integer := 6
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate a Key
 */
    function generate_des_key (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_length           in pls_integer
        , o_key_value            out varchar2
        , io_key_prefix          in out varchar2
        , o_check_value          out varchar2
        , i_check_length         in pls_integer := 6
        , i_component_num        in pls_integer
        , i_print_format         in varchar2
        , i_print_data           in varchar2
        , i_print_encoding       in varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate a Key Check Value 21.3 135
 */
    function generate_key_check_value (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_length           in pls_integer
        , i_key_value            in varchar2
        , i_key_prefix           in varchar2
        , o_check_value          out varchar2
        , i_check_length         in pls_integer := 6
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

    function validate_key_check_value (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_length           in pls_integer
        , i_key_value            in varchar2
        , i_key_prefix           in varchar2
        , i_check_value          in varchar2
        , i_check_length         in pls_integer := 6
        , o_result               out pls_integer
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
  * @param i_hsm_device_id      theDeviceID
  * @param i_zmk_prefix         theZmkPrefix
  * @param i_zmk                theZmk
  * @param i_key_type           theKeyEncZmkType
  * @param i_source_key_prefix  theKeyEncZmkPrefix
  * @param i_source_key         theKeyEncZmk
  * @param i_dest_key_prefix    theKeyEncLmkPrefix
  * @param o_dest_key           theKeyEncLmk
  * @param io_dest_key_kcv      theKeyEncLmkKCV
  * @param o_resp_message       theRespMessage
  * @param o_resp_message_size  theRespMessageSize
*/
    function translate_key_from_zmk_to_lmk (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_zmk_prefix           in varchar2
        , i_zmk                  in varchar2
        , i_key_type             in varchar2
        , i_source_key_prefix    in varchar2
        , i_source_key           in varchar2
        , i_dest_key_prefix      in varchar2
        , o_dest_key             out varchar2
        , io_dest_key_kcv        in out varchar2
        , o_resp_message         out varchar2
        , i_resp_mess_length     in pls_integer := 200
        , i_atalla_variant_support in pls_integer
    )  return pls_integer;

/*
 * Hash a Block of Data
 */
    function hash_block_data (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_hash_identifier      in varchar2
        , i_data                 in varchar2
        , i_data_length          in pls_integer
        , i_secret_key           in varchar2
        , i_secret_key_length    in pls_integer
        , o_hash_value           out varchar2
        , i_hash_value_length    in pls_integer
        , o_resp_message         out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate Static Data Authentication Signature
 */
    function sign_static_appl_data (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_hash_identifier      in varchar2
        , i_data_auth_code       in pls_integer
        , i_static_data          in varchar2
        , i_private_key_flag     in pls_integer
        , i_private_key          in varchar2
        , i_imk_dac_prefix       in varchar2
        , i_imk_dac_length       in pls_integer
        , i_imk_dac              in varchar2
        , i_hpan                 in varchar2
        , o_sign_data            out varchar2
        , i_sign_data_length     in pls_integer := 4000
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate ICC Derived Keys
 */
    function derive_icc_3des_keys (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_mode_flag            in pls_integer
        , i_kek_prefix           in varchar2
        , i_kek                  in varchar2
        , i_hpan                 in varchar2
        , i_imk_ac_prefix        in varchar2
        , i_imk_ac               in varchar2
        , i_imk_smi_prefix       in varchar2
        , i_imk_smi              in varchar2
        , i_imk_smc_prefix       in varchar2
        , i_imk_smc              in varchar2
        , i_imk_idn_prefix       in varchar2
        , i_imk_idn              in varchar2
        , i_idk_ac_length        in pls_integer := 2048
        , o_idk_ac_lmk           out varchar2
        , i_idk_smi_length       in pls_integer := 2048
        , o_idk_smi_lmk          out varchar2
        , i_idk_smc_length       in pls_integer := 2048
        , o_idk_smc_lmk          out varchar2
        , i_idk_idn_length       in pls_integer := 2048
        , o_idk_idn_lmk          out varchar2
        , i_idk_ac_kek_length    in pls_integer := 79
        , o_idk_ac_kek           out varchar2
        , o_idk_ac_kek_kcv       out varchar2
        , i_idk_smi_kek_length   in pls_integer := 79
        , o_idk_smi_kek          out varchar2
        , o_idk_smi_kek_kcv      out varchar2
        , i_idk_smc_kek_length   in pls_integer := 79
        , o_idk_smc_kek          out varchar2
        , o_idk_smc_kek_kcv      out varchar2
        , i_idk_idn_kek_length   in pls_integer := 79
        , o_idk_idn_kek          out varchar2
        , o_idk_idn_kek_kcv      out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate ICC Public/Private Keyset
 */
    function generate_icc_rsa_keypair (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_mode_flag            in pls_integer
        , i_modulus_len          in pls_integer
        , i_output_format        in varchar2
        , i_kek_prefix           in varchar2
        , i_kek                  in varchar2
        , i_encrypt_mode         in varchar2
        , i_init_vector          in pls_integer
        , i_key_data_len         in pls_integer
        , i_public_exponent      in varchar2
        , i_private_key          in varchar2
        , i_pan                  in varchar2
        , i_cert_expir_date      in varchar2
        , i_cert_serial_number   in pls_integer
        , i_auth_data            in varchar2
        , i_cert_data            in varchar2
        , i_public_key_length    in pls_integer := 2048
        , o_public_key           out varchar2
        , o_public_mac           out varchar2
        , i_private_key_length   in pls_integer := 2048
        , o_private_key          out varchar2
        , i_private_exp_length   in pls_integer := 2048
        , o_private_exp          out varchar2
        , i_private_mod_length   in pls_integer := 2048
        , o_private_mod          out varchar2
        , o_certificate          out varchar2
        , o_remainder            out varchar2
        , i_private_comp_length  in pls_integer := 2048
        , o_private_p            out varchar2
        , o_private_q            out varchar2
        , o_private_dp           out varchar2
        , o_private_dq           out varchar2
        , o_private_u            out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Sign ICC Public Key
 */
    function sign_icc_public_key (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_icc_public_key       in varchar2
        , i_icc_public_exponent  in varchar2
        , i_icc_public_mac       in varchar2
        , i_iss_private_key      in varchar2
        , i_auth_data            in varchar2
        , i_cert_data            in varchar2
        , i_cert_expir_date      in varchar2
        , i_cert_serial_number   in pls_integer
        , i_pan                  in varchar2
        , o_certificate          out varchar2
        , o_remainder            out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;
    
/*
 * Generate Issuer RSA Key Set (Visa)
 */
    function generate_rsa_keypair_visa (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_modulus_length       in pls_integer
        , i_exponent             in varchar2
        , i_expir_date           in varchar2
        , i_tracking_number      in pls_integer
        , i_subject_id           in varchar2
        , i_service_id           in varchar2
        , i_sign_algorithm       in pls_integer
        , i_user_data            in varchar2 := ''
        , i_auth_data            in varchar2 := ''
        , o_public_key           out varchar2
        , i_public_key_length    in pls_integer := 2048
        , o_private_key          out varchar2
        , i_private_key_length   in pls_integer := 2048
        , o_public_key_mac       out varchar2
        , o_cert_data            out varchar2
        , i_cert_data_length     in pls_integer := 2048
        , o_cert_hash            out varchar2
        , i_cert_hash_length     in pls_integer := 2048
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate Issuer RSA Key Set (MCI)
 */
    function generate_rsa_keypair_mc (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_index            in pls_integer
        , i_modulus_length       in pls_integer
        , i_exponent             in varchar2
        , i_expir_date           in varchar2
        , i_subject_id           in varchar2
        , i_serial_number        in pls_integer
        , i_authentication_data  in varchar2 := ''
        , o_public_key           out varchar2
        , i_public_key_length    in pls_integer := 2048
        , o_private_key          out varchar2
        , i_private_key_length   in pls_integer := 2048
        , o_public_key_mac       out varchar2
        , o_cert_data            out varchar2
        , i_cert_data_length     in pls_integer := 2048
        , o_cert_hash            out varchar2
        , i_cert_hash_length     in pls_integer := 2048
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Validate a Certification Authority Self-Signed Certificate (Visa)
 */
    function validate_ca_pk_cert_visa (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_cert_data              in varchar2
        , i_auth_data              in varchar2 := ''
        , i_ca_exponent_length     in pls_integer := 256
        , o_ca_exponent            out varchar2
        , i_ca_public_key_length   in pls_integer := 2048
        , o_ca_public_key          out varchar2
        , o_ca_public_key_mac      out varchar2
        , o_cert_expir_date        out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;

/*
 * Validate a Certification Authority Self-Signed Certificate (MCI)
 */
    function validate_ca_pk_cert_mc (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_cert_data              in varchar2
        , io_cert_hash             in out varchar2
        , i_cert_hash_length       in pls_integer := 2048
        , i_auth_data              in varchar2 := ''
        , o_cert_expir_date        out varchar2
        , o_cert_serial_number     out varchar2
        , i_ca_exponent_length     in pls_integer := 256
        , o_ca_exponent            out varchar2
        , i_ca_public_key_length   in pls_integer := 2048
        , o_ca_public_key          out varchar2
        , o_ca_public_key_mac      out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;

/*
 * Validate an Issuer Public Key Certificate (Visa)
 */
    function validate_iss_pk_cert_visa (
        i_hsm_ip                    in varchar2
        , i_hsm_port                in pls_integer
        , i_ca_public_key           in varchar2
        , i_ca_public_key_mac       in varchar2
        , i_ca_exponent             in varchar2
        , i_ca_auth_data            in varchar2 := ''
        , i_iss_public_key          in varchar2
        , i_iss_private_key         in varchar2
        , i_iss_auth_data           in varchar2 := ''
        , i_iss_cert_data           in varchar2
        , i_signature               in varchar2
        , o_iss_public_key          out varchar2
        , i_iss_public_key_length   in pls_integer := 2048
        , io_iss_public_key_mac     in out varchar2
        , o_iss_cert_hash           out varchar2
        , i_iss_cert_hash_length    in pls_integer := 2048
        , o_resp_mess               out varchar2
        , i_resp_mess_length        in pls_integer := 200
    ) return pls_integer;

/*
 * Validate an Issuer Public Key Certificate (MCI)
 */
    function validate_iss_pk_cert_mc (
        i_hsm_ip                    in varchar2
        , i_hsm_port                in pls_integer
        , i_ca_public_key           in varchar2
        , i_ca_public_key_mac       in varchar2
        , i_ca_exponent             in varchar2
        , i_ca_auth_data            in varchar2 := ''
        , i_iss_public_key          in varchar2
        , i_iss_private_key         in varchar2
        , i_iss_exponent            in varchar2
        , i_iss_auth_data           in varchar2 := ''
        , i_iss_cert_data           in varchar2
        , o_expir_date              out varchar2
        , o_serial_number           out pls_integer
        , o_iss_public_key_mac      out varchar2
        , o_iss_cert_hash           out varchar2
        , i_iss_cert_hash_length    in pls_integer := 2048
        , o_resp_mess               out varchar2
        , i_resp_mess_length        in pls_integer := 200
    ) return pls_integer;

/*
 * To decrypt a key from a KEK and return the key encrypted under a LMK pair to the host
 */
    function import_key_under_kek (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_kek_prefix           in varchar2
        , i_kek_value            in varchar2
        , i_user_key_type        in varchar2
        , i_user_key_value       in varchar2
        , i_decrypt_mode         in varchar2
        , i_init_vector          in varchar2 := ''
        , o_key_value            out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;
    
/*
 * Translate an existing key to a new key scheme
 */
    function translate_key_scheme (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_value            in varchar2
        , i_key_prefix           in varchar2
        , i_new_key_scheme       in varchar2
        , o_new_key_value        out varchar2
        , o_new_key_prefix       out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;
    
/*
 * Generate MAC
 */
    function generate_mac (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_value            in varchar2
        , i_key_prefix           in varchar2
        , i_message_data         in varchar2
        , i_message_length       in pls_integer
        , o_mac                  out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer := 200
    ) return pls_integer;

/*
 * Generate AAV using CVC2 algorithm
 */
    function generate_aav_cvc2 (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_key                    in varchar2
        , i_key_prefix             in varchar2
        , i_pan                    in varchar2
        , i_merchant_name          in varchar2
        , i_control_byte           in pls_integer
        , i_id_acs                 in pls_integer
        , i_auth_method            in pls_integer
        , i_bin_key_id             in pls_integer
        , i_tsn                    in pls_integer
        , o_aav                    out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;
    

/*
 * Generate AAV using HASH algorithm
 */
    function generate_aav_hash (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_key                    in varchar2
        , i_pan                    in varchar2
        , i_merchant_name          in varchar2
        , i_control_byte           in pls_integer
        , i_id_acs                 in pls_integer
        , i_auth_method            in pls_integer
        , i_bin_key_id             in pls_integer
        , i_tsn                    in pls_integer
        , o_aav                    out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;
    
/*
 * Generate AAV using CVC2 or HASH algorithm
 */    
    function generate_aav (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_aav_method             in varchar2
        , i_key                    in varchar2
        , i_key_prefix             in varchar2
        , i_pan                    in varchar2
        , i_merchant_name          in varchar2
        , i_control_byte           in pls_integer
        , i_id_acs                 in pls_integer
        , i_auth_method            in pls_integer
        , i_bin_key_id             in pls_integer
        , i_tsn                    in pls_integer
        , o_aav                    out varchar2
        , i_aav_length             in pls_integer := 79
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;
    
/*
 * Generate CAVV 
 */
    function generate_cavv (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_key                    in varchar2
        , i_key_prefix             in varchar2
        , i_auth_res_code          in varchar2
        , i_sec_factor_auth_code   in varchar2
        , i_key_indicator          in varchar2
        , i_pan                    in varchar2
        , i_unpredictable_number   in pls_integer
        , i_atn                    in varchar2
        , o_cavv                   out varchar2
        , i_cavv_length            in pls_integer := 79
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;
    
/*
 * Generate HMAC secret key
 */
    function generate_hmac_secret_key (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , o_secret_key             out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;    

/*
 * Generate RSA keypair
 */    
    function generate_rsa_keypair (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_modulus_length         in pls_integer
        , i_exponent_length        in pls_integer := 256
        , i_exponent               in varchar2
        , o_public_key             out varchar2
        , i_public_key_length      in pls_integer := 2048
        , o_private_key            out varchar2
        , i_private_key_length     in pls_integer := 2048
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;

/*
 * Generate RSA signature
 */     
    function generate_rsa_signature (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_data                   in varchar2
        , i_data_length            in pls_integer
        , i_private_key            in varchar2
        , i_private_key_length     in pls_integer := 2048
        , o_sign_data              out varchar2
        , i_sign_data_length       in pls_integer := 4000
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;

/*
 * Perform diagnostics - test the processor, firmware PROMs and the LMK pairs
 */ 
    function perform_diagnostics (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_lmk_value              in varchar2
        , i_lmk_value_length       in pls_integer := 200
        , o_resp_check             out varchar2
        , i_resp_check_length      in pls_integer := 8
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer;

end;
/
