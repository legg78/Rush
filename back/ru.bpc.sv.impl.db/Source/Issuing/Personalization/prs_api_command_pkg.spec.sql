create or replace package prs_api_command_pkg is
/************************************************************
 * API for crypto command <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 05.08.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_command_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Generate CVV value
 */
    procedure gen_cvv_value (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_service_code        in com_api_type_pkg.t_module_code
        , o_cvv                 out com_api_type_pkg.t_module_code
    );

/*
 * Generate CVV2 value
 */
    procedure gen_cvv2_value (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_exp_date_format     in com_api_type_pkg.t_dict_value
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_cvv                 out com_api_type_pkg.t_module_code
    );

/*
 * Generate iCVV value
 */
    procedure gen_icvv_value (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_cvv                 out com_api_type_pkg.t_module_code
    );

/*
 * Generate PVV value
 */
    procedure gen_pvv_value (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_pin_block           in com_api_type_pkg.t_pin_block
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_pvv                 out com_api_type_pkg.t_tiny_id
    );

/*
 * Derive IBM 3624 offset value
 */
    procedure derive_ibm_3624_offset (
        i_perso_rec              in prs_api_type_pkg.t_perso_rec
        , i_pin_block            in com_api_type_pkg.t_pin_block
        , i_pin_verify_method    in com_api_type_pkg.t_dict_value
        , i_perso_key            in prs_api_type_pkg.t_perso_key_rec
        , i_decimalisation_table in com_api_type_pkg.t_pin_block
        , i_pin_length           in com_api_type_pkg.t_tiny_id
        , i_hsm_device_id        in com_api_type_pkg.t_tiny_id
        , o_pin_offset           out com_api_type_pkg.t_cmid
    );

/*
 * Generate PIN Block value
 */
    procedure gen_pin_block (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_pin_block           out com_api_type_pkg.t_pin_block
    );

/*
 * Translate PIN Block
 */
    procedure translate_pinblock (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_pinblock_format     in com_api_type_pkg.t_dict_value
        , o_pin_block           out com_api_type_pkg.t_pin_block
    );

/*
 * Hashing block data
 */
    procedure hash_block_data (
        i_data                  in com_api_type_pkg.t_raw_data
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_hash                out com_api_type_pkg.t_raw_data
    );

/*
 * Sign static application data
 */
    procedure sign_static_appl_data (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_static_data         in com_api_type_pkg.t_lob2_tab
        , o_signed_data         out nocopy com_api_type_pkg.t_lob2_tab
    );

/*
 * Derive ICC 3DES keys
 */
    procedure derive_icc_3des_keys (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_result              out prs_api_type_pkg.t_icc_derived_keys_rec
    );

/*
 * Generate ICC RSA keys
 */
    procedure generate_icc_rsa_keys (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
        , i_static_data         in com_api_type_pkg.t_lob2_tab
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , o_result              out prs_api_type_pkg.t_icc_rsa_key_rec
    );

/*
 * Import key under KEK
 */
    procedure import_key_under_kek (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_kek                 in sec_api_type_pkg.t_des_key_rec
        , i_user_key            in sec_api_type_pkg.t_des_key_rec
        , o_new_key             out sec_api_type_pkg.t_des_key_rec
    );

/*
 * Translate key scheme
 */
    procedure translate_key_scheme (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_key                 in sec_api_type_pkg.t_des_key_rec
        , o_new_key             out sec_api_type_pkg.t_des_key_rec
    );

/*
 * Generate MAC
 */
    procedure generate_mac (
        i_hsm_device_id         in com_api_type_pkg.t_tiny_id
        , i_key                 in sec_api_type_pkg.t_des_key_rec                
        , i_message_data        in com_api_type_pkg.t_raw_data
        , i_convert_message     in com_api_type_pkg.t_boolean
        , o_mac                 out com_api_type_pkg.t_name
    );
    
end; 
/
