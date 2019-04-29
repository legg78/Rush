create or replace package body hsm_api_hsm_pkg is
/************************************************************
 * API for HSM commands type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 16.07.2012 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: hsm_api_hsm_pkg <br />
 * @headcom
 ************************************************************/
 
    function init_hsm_devices (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_model_number           in varchar2
        , i_firmware               in varchar2
        , i_plugin                 in varchar2
        , i_max_connection         in pls_integer
        , o_connect_status         out varchar2
        , i_connect_status_length  in pls_integer
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHInit"
    parameters (
        i_hsm_ip                   string
        , i_hsm_port               int
        , i_lmk_id                 int
        , i_model_number           string
        , i_firmware               string
        , i_plugin                 string
        , i_max_connection         int
        , i_connect_status_length  int
        , o_connect_status         string
        , i_resp_mess_length       int
        , o_resp_mess              string
    );

    function deinit_hsm_devices (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHDeinit"
    parameters (
        i_hsm_ip                   string
        , i_hsm_port               int
        , i_resp_mess_length       int
        , o_resp_mess              string
    );
    
    function reopen_logs return pls_integer as external library hsm_ctlhsm_lib
    name "LHReopenLog";

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenVisaPINBlk"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_hpan                 string
        , i_pin_length           int
        , i_pin_block_format     string
        , i_key_prefix           string
        , i_key_length           int
        , i_key_value            string
        , o_result               string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenVisaPVV"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_pvk                  string
        , i_key_prefix           string
        , i_pin_block            string
        , i_hpan                 string
        , i_pvk_index            int
        , o_result               string
        , o_resp_mess            string
        , i_resp_mess_length     int
        , i_ppk_prefix           string
        , i_ppk                  string
    );

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenCVV"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_cvk                  string
        , i_key_prefix           string
        , i_hpan                 string
        , i_exp_date_char        string
        , i_service_code         string
        , o_result               string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenIBMPINOffset"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_pvk                  string
        , i_key_prefix           string
        , i_pinblock             string
        , i_pinblock_format      string
        , i_pin_length           int
        , i_hpan                 string
        , i_decimalization_table string
        , i_validation_data      string
        , o_result               string
        , i_offset_length        int
        , o_resp_mess            string
        , i_resp_mess_length     int
        , i_ppk_prefix           string
        , i_ppk                  string
    );

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenIBMPINBlk"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_pvk                  string
        , i_key_prefix           string
        , i_offset               string
        , i_pin_length           int
        , i_hpan                 string
        , i_decimalization_table string
        , i_validation_data      string
        , o_result               string
        , o_resp_mess            string
        , i_resp_mess_length     int
        , i_ppk_prefix           string
        , i_ppk                  string
    );

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
        , i_resp_mess_length       in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHTrnsPINBlk"
    parameters (
        i_hsm_ip                   string
        , i_hsm_port               int
        , i_lmk_id                 int
        , i_input_key_type         string
        , i_input_key_prefix       string
        , i_input_key_value        string
        , i_input_pinblock_format  string
        , i_encrypted_pin_block    string
        , i_output_key_type        string
        , i_output_key_prefix      string
        , i_output_key_value       string
        , i_output_pinblock_format string
        , i_hpan                   string
        , o_result                 string
        , o_resp_mess              string
        , i_resp_mess_length       int
    );

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHPrtPINMailer"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_print_format         string
        , i_document_type        string
        , i_hpan                 string
        , i_pin_block            string
        , i_print_data           string
        , i_print_encoding       string
        , o_pin_check_value      string
        , o_resp_mess            string
        , i_resp_mess_length     int
        , i_ppk_prefix           string
        , i_ppk                  string
    );

    function generate_des_key (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_length           in pls_integer
        , o_key_value            out varchar2
        , io_key_prefix          in out varchar2
        , o_check_value          out varchar2
        , i_check_length         in pls_integer
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenKey"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_key_type             string
        , i_key_length           int
        , i_check_length         int
        , o_key_value            string
        , o_check_value          string
        , io_key_prefix          string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

    function generate_des_key (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_length           in pls_integer
        , o_key_value            out varchar2
        , io_key_prefix          in out varchar2
        , o_check_value          out varchar2
        , i_check_length         in pls_integer
        , i_component_num        in pls_integer
        , i_print_format         in varchar2
        , i_print_data           in varchar2
        , i_print_encoding       in varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenKeyPrtComps"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_component_num        int
        , i_key_type             string
        , i_key_length           int
        , i_check_length         int
        , i_print_format         string
        , i_print_data           string
        , i_print_encoding       string
        , o_key_value            string
        , o_check_value          string
        , io_key_prefix          string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

    function generate_key_check_value (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_length           in pls_integer
        , i_key_value            in varchar2
        , i_key_prefix           in varchar2
        , o_check_value          out varchar2
        , i_check_length         in pls_integer
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenKCV"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_key_type             string
        , i_key_length           int
        , i_key_prefix           string
        , i_key_value            string
        , i_check_length         int
        , o_check_value          string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

    function validate_key_check_value (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_type             in varchar2
        , i_key_length           in pls_integer
        , i_key_value            in varchar2
        , i_key_prefix           in varchar2
        , i_check_value          in varchar2
        , i_check_length         in pls_integer
        , o_result               out pls_integer
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHValKCV"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_key_type             string
        , i_key_length           int
        , i_key_prefix           string
        , i_key_value            string
        , i_check_length         int
        , i_check_value          string
        , o_result               int
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
        , i_resp_mess_length     in pls_integer
        , i_atalla_variant_support in pls_integer
    )  return pls_integer as external library hsm_ctlhsm_lib
    name "LHImportKey"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_zmk_prefix          string
        , i_zmk                 string
        , i_key_type            string
        , i_source_key_prefix   string
        , i_source_key          string
        , i_dest_key_prefix     string
        , o_dest_key            string
        , io_dest_key_kcv       string
        , o_resp_message        string
        , i_resp_mess_length    int
        , i_atalla_variant_support int
    );

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHHashBlkData"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_hash_identifier      string
        , i_data_length          int
        , i_data                 string
        , i_secret_key           string
        , i_secret_key_length    int
        , o_hash_value           string
        , i_hash_value_length    int
        , o_resp_message         string
        , i_resp_mess_length     int
    );

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
        , i_sign_data_length     in pls_integer
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHSignStaticData"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_hash_identifier      string
        , i_data_auth_code       int
        , i_static_data          string
        , i_private_key_flag     int
        , i_private_key          string
        , i_hpan                 string
        , i_imk_dac_prefix       string
        , i_imk_dac_length       int
        , i_imk_dac              string
        , i_sign_data_length     int
        , o_sign_data            string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
        , i_idk_ac_length        in pls_integer
        , o_idk_ac_lmk           out varchar2
        , i_idk_smi_length       in pls_integer
        , o_idk_smi_lmk          out varchar2
        , i_idk_smc_length       in pls_integer
        , o_idk_smc_lmk          out varchar2
        , i_idk_idn_length       in pls_integer
        , o_idk_idn_lmk          out varchar2
        , i_idk_ac_kek_length    in pls_integer
        , o_idk_ac_kek           out varchar2
        , o_idk_ac_kek_kcv       out varchar2
        , i_idk_smi_kek_length   in pls_integer
        , o_idk_smi_kek          out varchar2
        , o_idk_smi_kek_kcv      out varchar2
        , i_idk_smc_kek_length   in pls_integer
        , o_idk_smc_kek          out varchar2
        , o_idk_smc_kek_kcv      out varchar2
        , i_idk_idn_kek_length   in pls_integer
        , o_idk_idn_kek          out varchar2
        , o_idk_idn_kek_kcv      out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHDeriveICC3DESKeys"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_mode_flag            int
        , i_kek_prefix           string
        , i_kek                  string
        , i_hpan                 string
        , i_imk_ac_prefix        string
        , i_imk_ac               string
        , i_imk_smi_prefix       string
        , i_imk_smi              string
        , i_imk_smc_prefix       string
        , i_imk_smc              string
        , i_imk_idn_prefix       string
        , i_imk_idn              string
        , i_idk_ac_length        int
        , o_idk_ac_lmk           string
        , i_idk_smi_length       int
        , o_idk_smi_lmk          string
        , i_idk_smc_length       int
        , o_idk_smc_lmk          string
        , i_idk_idn_length       int
        , o_idk_idn_lmk          string
        , i_idk_ac_kek_length    int
        , o_idk_ac_kek           string
        , o_idk_ac_kek_kcv       string
        , i_idk_smi_kek_length   int
        , o_idk_smi_kek          string
        , o_idk_smi_kek_kcv      string
        , i_idk_smc_kek_length   int
        , o_idk_smc_kek          string
        , o_idk_smc_kek_kcv      string
        , i_idk_idn_kek_length   int
        , o_idk_idn_kek          string
        , o_idk_idn_kek_kcv      string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
        , i_public_key_length    in pls_integer
        , o_public_key           out varchar2
        , o_public_mac           out varchar2
        , i_private_key_length   in pls_integer
        , o_private_key          out varchar2
        , i_private_exp_length   in pls_integer
        , o_private_exp          out varchar2
        , i_private_mod_length   in pls_integer
        , o_private_mod          out varchar2
        , o_certificate          out varchar2
        , o_remainder            out varchar2
        , i_private_comp_length  in pls_integer
        , o_private_p            out varchar2
        , o_private_q            out varchar2
        , o_private_dp           out varchar2
        , o_private_dq           out varchar2
        , o_private_u            out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenICCRSAKeyPair"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_mode_flag             int    -- u_int theModeFlag
        , i_modulus_len           int    -- u_int theKeyLength
        , i_output_format         string -- char *thePrivateKeyOutputFormat
        , i_kek_prefix            string -- char *theKEKlmkPrefix
        , i_kek                   string -- char *theKEKLml
        , i_encrypt_mode          string -- char *theEncryptMode
        , i_init_vector           int    -- u_int theInitialisationVector
        , i_key_data_len          int    -- u_short theLengthBytes
        , i_public_exponent       string -- char *thePublicExponent
        , i_auth_data             string -- char *theAuthenticationData
        , i_pan                   string -- char *thePAN
        , i_cert_expir_date       string -- char *theCertExpDate
        , i_cert_serial_number    int    -- int theCertSerialNumber,
        , i_private_key           string -- char *theIssPrivateKey
        , i_cert_data             string -- char *theCertificateData
        , i_public_key_length     int    -- u_int thePublicKeyLength
        , o_public_key            string -- char *thePublicKey
        , o_public_mac            string -- char *theMAC
        , i_private_key_length    int    -- u_int thePrivateKeyLength
        , o_private_key           string -- char *thePrivateKey
        , i_private_exp_length    int    -- u_int theExponentKEKLength
        , o_private_exp           string -- char *theExponentKEK
        , i_private_mod_length    int    -- u_int theModulusKEKLength
        , o_private_mod           string -- char *theModulusKEK
        , o_certificate           string -- char *theCertificate
        , o_remainder             string -- char *theRemainder
        , i_private_comp_length   int    -- u_int thePrivKeyComponentLength
        , o_private_p             string -- char *thePkek
        , o_private_q             string -- char *theQkek
        , o_private_dp            string -- char *theD1kek
        , o_private_dq            string -- char *theD2kek
        , o_private_u             string -- char *theQmodPkek
        , o_resp_mess             string  -- char *theRespMessage
        , i_resp_mess_length      int     -- u_int theRespMessageSize
    );
    
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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHConstrICCPKData"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_icc_public_key       string   --char *thePKModulus,
        , i_icc_public_exponent  string   --char *thePKExponent,
        , i_auth_data            string   --char *thePKAuthenticationData,
        , i_icc_public_mac       string   --char *thePKMAC,
        , i_pan                  string   --char *thePAN
        , i_cert_expir_date      string   --char *theCertExpDate,
        , i_cert_serial_number   int      --u_int theCertSerialNumber,
        , i_iss_private_key      string   --char *theIssPrivateKey,
        , i_cert_data            string   --char *theCertificateData,
        , o_certificate          string   --char *theCertificate,
        , o_remainder            string   --char *theRemainder,
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
        , i_user_data            in varchar2
        , i_auth_data            in varchar2
        , o_public_key           out varchar2
        , i_public_key_length    in pls_integer
        , o_private_key          out varchar2
        , i_private_key_length   in pls_integer
        , o_public_key_mac       out varchar2
        , o_cert_data            out varchar2
        , i_cert_data_length     in pls_integer
        , o_cert_hash            out varchar2
        , i_cert_hash_length     in pls_integer
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenVisaRSAKeyPair"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_modulus_length       int
        , i_exponent             string
        , i_user_data            string
        , i_sign_algorithm       int
        , i_service_id           string
        , i_subject_id           string
        , i_expir_date           string
        , i_tracking_number      int
        , i_auth_data            string
        , o_public_key_mac       string
        , i_public_key_length    int
        , o_public_key           string
        , i_private_key_length   int
        , o_private_key          string
        , i_cert_data_length     int
        , o_cert_data            string
        , i_cert_hash_length     int
        , o_cert_hash            string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );


    function generate_rsa_keypair_mc (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_key_index            in pls_integer
        , i_modulus_length       in pls_integer
        , i_exponent             in varchar2
        , i_expir_date           in varchar2
        , i_subject_id           in varchar2
        , i_serial_number        in pls_integer
        , i_authentication_data  in varchar2
        , o_public_key           out varchar2
        , i_public_key_length    in pls_integer
        , o_private_key          out varchar2
        , i_private_key_length   in pls_integer
        , o_public_key_mac       out varchar2
        , o_cert_data            out varchar2
        , i_cert_data_length     in pls_integer
        , o_cert_hash            out varchar2
        , i_cert_hash_length     in pls_integer
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenMCRSAKeyPair"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_modulus_length       int
        , i_subject_id           string
        , i_expir_date           string
        , i_serial_number        int
        , i_key_index            int
        , i_authentication_data  string
        , i_exponent             string
        , o_public_key_mac       string
        , i_public_key_length    int
        , o_public_key           string
        , i_private_key_length   int
        , o_private_key          string
        , i_cert_data_length     int
        , o_cert_data            string
        , i_cert_hash_length     int
        , o_cert_hash            string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

    function validate_ca_pk_cert_visa (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_cert_data              in varchar2
        , i_auth_data              in varchar2
        , i_ca_exponent_length     in pls_integer
        , o_ca_exponent            out varchar2
        , i_ca_public_key_length   in pls_integer
        , o_ca_public_key          out varchar2
        , o_ca_public_key_mac      out varchar2
        , o_cert_expir_date        out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHCheckVisaCAPKCert"
    parameters (
        i_hsm_ip                   string
        , i_hsm_port               int
        , i_cert_data              string -- char *theSSCAPublicKeyCertificate,
        , i_auth_data              string -- char *theAuthenticationData,
        , i_ca_public_key_length   int    -- u_int theCAPKModLengthOut
        , o_ca_public_key          string -- char *theCAPKModOut,
        , i_ca_exponent_length     int    -- u_int theCAPKExpLengthOut
        , o_ca_exponent            string -- char *theCAPKExpOut,
        , o_ca_public_key_mac      string -- char *theMAC,
        , o_cert_expir_date        string -- char *theCertExpDate,
        , o_resp_mess              string
        , i_resp_mess_length       int
    );

    function validate_ca_pk_cert_mc (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_cert_data              in varchar2
        , io_cert_hash             in out varchar2
        , i_cert_hash_length       in pls_integer := 2048
        , i_auth_data              in varchar2
        , o_cert_expir_date        out varchar2
        , o_cert_serial_number     out varchar2
        , i_ca_exponent_length     in pls_integer
        , o_ca_exponent            out varchar2
        , i_ca_public_key_length   in pls_integer
        , o_ca_public_key          out varchar2
        , o_ca_public_key_mac      out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHCheckMCCAPKCert"
    parameters (
        i_hsm_ip                   string
        , i_hsm_port               int
        , i_cert_data              string -- char *theCertificate,
        , i_auth_data              string -- char *theAuthenticationData, // User data for Safenet
        , i_cert_hash_length       int
        , io_cert_hash             string -- char *theHashValue,
        , i_ca_public_key_length   int    -- u_int theCAPKModLengthOut
        , o_ca_public_key          string -- char *theCAPKModOut,
        , i_ca_exponent_length     int    -- u_int theCAPKExpLengthOut
        , o_ca_exponent            string -- char *theCAPKExpOut,
        , o_ca_public_key_mac      string -- char *theMAC,
        , o_cert_expir_date        string -- char *theCertExpirationDate,
        , o_cert_serial_number     string -- u_int *theCertSerialNumber,
        , o_resp_mess              string
        , i_resp_mess_length       int
    );

    function validate_iss_pk_cert_visa (
        i_hsm_ip                    in varchar2
        , i_hsm_port                in pls_integer
        , i_ca_public_key           in varchar2
        , i_ca_public_key_mac       in varchar2
        , i_ca_exponent             in varchar2
        , i_ca_auth_data            in varchar2
        , i_iss_public_key          in varchar2
        , i_iss_private_key         in varchar2
        , i_iss_auth_data           in varchar2
        , i_iss_cert_data           in varchar2
        , i_signature               in varchar2
        , o_iss_public_key          out varchar2
        , i_iss_public_key_length   in pls_integer
        , io_iss_public_key_mac     in out varchar2
        , o_iss_cert_hash           out varchar2
        , i_iss_cert_hash_length    in pls_integer
        , o_resp_mess               out varchar2
        , i_resp_mess_length        in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHCheckVisaIssPKCert"
    parameters (
        i_hsm_ip                    string
        , i_hsm_port                int
        , i_ca_public_key_mac       string -- char *theCAMAC
        , i_ca_public_key           string -- char *theCAPKModulus
        , i_ca_exponent             string -- char *theCAPKExponent
        , i_ca_auth_data            string -- char *theCAAuthenticationData
        , i_iss_public_key          string -- char *theIssPKModulus
        , i_iss_private_key         string -- char *theIssPrivateKey
        , i_iss_cert_data           string -- char *theIssCertificate
        , i_iss_auth_data           string -- char *theIssAuthenticationData
        , i_signature               string -- char *theDetachedSignature
        , io_iss_public_key_mac     string -- char *theIssMAC,
        , i_iss_public_key_length   int    -- u_int theIssPubKeyLength
        , o_iss_public_key          string -- char *theIssPublicKey,
        , i_iss_cert_hash_length    int    -- u_int theHashLength
        , o_iss_cert_hash           string -- char *theHashValue,
        , o_resp_mess               string
        , i_resp_mess_length        int
    );

    function validate_iss_pk_cert_mc (
        i_hsm_ip                    in varchar2
        , i_hsm_port                in pls_integer
        , i_ca_public_key           in varchar2
        , i_ca_public_key_mac       in varchar2
        , i_ca_exponent             in varchar2
        , i_ca_auth_data            in varchar2
        , i_iss_public_key          in varchar2
        , i_iss_private_key         in varchar2
        , i_iss_exponent            in varchar2
        , i_iss_auth_data           in varchar2
        , i_iss_cert_data           in varchar2
        , o_expir_date              out varchar2
        , o_serial_number           out pls_integer
        , o_iss_public_key_mac      out varchar2
        , o_iss_cert_hash           out varchar2
        , i_iss_cert_hash_length    in pls_integer
        , o_resp_mess               out varchar2
        , i_resp_mess_length        in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHCheckMCIssPKCert"
    parameters (
        i_hsm_ip                    string
        , i_hsm_port                int
        , i_ca_public_key_mac       string -- char *theCAMAC,
        , i_ca_public_key           string -- char *theCAPK,
        , i_ca_exponent             string -- char *theCAPKExponent,
        , i_ca_auth_data            string -- char *theCAAuthenticationData,
        , i_iss_public_key          string -- char *theIssPKModulus,
        , i_iss_exponent            string -- char *theIssPKExponent,
        , i_iss_private_key         string -- char *theIssPrivateKey,
        , i_iss_cert_data           string -- char *theIssPKCertificate,
        , i_iss_auth_data           string -- char *theIssAuthenticationData,
        , o_iss_public_key_mac      string -- char *o_theIssMAC,
        , i_iss_cert_hash_length    int    -- u_int theHashLength
        , o_iss_cert_hash           string -- char *o_theHashValue,
        , o_expir_date              string -- char *o_theCertExpirationDate,
        , o_serial_number           int    -- u_int *o_theCertSerialNumber,
        , o_resp_mess               string
        , i_resp_mess_length        int
    );
    
    function import_key_under_kek (
        i_hsm_ip                 in varchar2
        , i_hsm_port             in pls_integer
        , i_kek_prefix           in varchar2
        , i_kek_value            in varchar2
        , i_user_key_type        in varchar2
        , i_user_key_value       in varchar2
        , i_decrypt_mode         in varchar2
        , i_init_vector          in varchar2
        , o_key_value            out varchar2
        , o_resp_mess            out varchar2
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHImportKeyKEK"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        
        , i_kek_prefix           string -- char *theKEKPrefix
        , i_kek_value            string -- char *theKEK
        , i_user_key_type        string -- char *theUserKeyType
        , i_user_key_value       string -- char *theUserKey
        , i_decrypt_mode         string -- char *theEncMode
        , i_init_vector          string -- char *theIV
        , o_key_value            string -- char *theDecryptedKey
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHTrnsKeySchm"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_key_type             string -- char *theKeyType
        , i_key_prefix           string -- char *theKeyPrefix
        , i_key_value            string -- char *theKey
        , i_new_key_scheme       string -- char *theNewScheme
        , o_new_key_prefix       string -- char *theNewKeyPrefix
        , o_new_key_value        string -- char *theNewKey
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
        , i_resp_mess_length     in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenMAC"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_key_type             string -- char *theMACKeyType
        , i_key_value            string -- char *theMACKey
        , i_key_prefix           string -- char *theMACKeyPrefix
        , i_message_data         string -- char *theData
        , i_message_length       int    -- int theDataSize
        , o_mac                  string -- char *theMAC
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenAAVUsingCVC2"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_key                  string
        , i_key_prefix           string
        , i_pan                  string
        , i_merchant_name        string
        , i_control_byte         int
        , i_id_acs               int
        , i_auth_method          int
        , i_bin_key_id           int
        , i_tsn                  int
        , o_aav                  string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenAAVUsingHash"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_pan                  string
        , i_merchant_name        string
        , i_control_byte         int
        , i_id_acs               int
        , i_auth_method          int
        , i_bin_key_id           int
        , i_tsn                  int
        , i_key                  string
        , o_aav                  string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenAAV"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_aav_method           string
        , i_lmk_id               int
        , i_key                  string
        , i_key_prefix           string
        , i_pan                  string
        , i_merchant_name        string
        , i_control_byte         int
        , i_id_acs               int
        , i_auth_method          int
        , i_bin_key_id           int
        , i_tsn                  int
        , o_aav                  string
        , i_aav_length           int
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

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
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenCAVV"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_key                  string
        , i_key_prefix           string
        , i_auth_res_code        string
        , i_sec_factor_auth_code string
        , i_key_indicator        string
        , i_pan                  string
        , i_unpredictable_number int
        , i_atn                  string
        , o_cavv                 string
        , i_cavv_length          int
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

    function generate_hmac_secret_key (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , o_secret_key             out varchar2
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer := 200
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenSecretKeyHMAC"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , o_secret_key           string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

    function generate_rsa_keypair (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_modulus_length         in pls_integer
        , i_exponent_length        in pls_integer
        , i_exponent               in varchar2
        , o_public_key             out varchar2
        , i_public_key_length      in pls_integer
        , o_private_key            out varchar2
        , i_private_key_length     in pls_integer
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenGenRSAKeypair"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_modulus_length       int
        , i_public_key_length    int
        , o_public_key           string
        , i_exponent_length      int
        , i_exponent             string
        , i_private_key_length   int
        , o_private_key          string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );
    
    function generate_rsa_signature (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_data                   in varchar2
        , i_data_length            in pls_integer
        , i_private_key            in varchar2
        , i_private_key_length     in pls_integer
        , o_sign_data              out varchar2
        , i_sign_data_length       in pls_integer
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHGenGenRSASignature"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_data_length          int
        , i_data                 string
        , i_private_key_length   int
        , i_private_key          string
        , i_sign_data_length     int
        , o_sign_data            string
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

    function perform_diagnostics (
        i_hsm_ip                   in varchar2
        , i_hsm_port               in pls_integer
        , i_lmk_id                 in pls_integer
        , i_lmk_value              in varchar2
        , i_lmk_value_length       in pls_integer
        , o_resp_check             out varchar2
        , i_resp_check_length      in pls_integer
        , o_resp_mess              out varchar2
        , i_resp_mess_length       in pls_integer
    ) return pls_integer as external library hsm_ctlhsm_lib
    name "LHPerformDiagnostics"
    parameters (
        i_hsm_ip                 string
        , i_hsm_port             int
        , i_lmk_id               int
        , i_lmk_value            string
        , i_lmk_value_length     int
        , o_resp_check           string
        , i_resp_check_length    int
        , o_resp_mess            string
        , i_resp_mess_length     int
    );

end;
/
