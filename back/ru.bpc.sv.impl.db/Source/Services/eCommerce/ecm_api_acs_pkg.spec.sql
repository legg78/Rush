create or replace package ecm_api_acs_pkg is
/************************************************************
 * API interface for 3D security <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 17.04.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: ecm_api_acs_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Generate AAV using CVC2 or HASH algorithm
 */
    procedure generate_aav (
        i_aav_method               in com_api_type_pkg.t_dict_value
        , i_card_number            in com_api_type_pkg.t_card_number
        , i_merchant_name          in com_api_type_pkg.t_name
        , i_control_byte           in com_api_type_pkg.t_long_id
        , i_id_acs                 in com_api_type_pkg.t_long_id
        , i_auth_method            in com_api_type_pkg.t_long_id
        , o_aav                    out sec_api_type_pkg.t_key_value
    );

/*
 * Generate CAVV
 */
    procedure generate_caav (
        i_auth_res_code            in com_api_type_pkg.t_name
        , i_sec_factor_auth_code   in com_api_type_pkg.t_name
        , i_key_indicator          in com_api_type_pkg.t_name
        , i_card_number            in com_api_type_pkg.t_card_number
        , i_unpredictable_number   in com_api_type_pkg.t_long_id
        , o_cavv                   out sec_api_type_pkg.t_key_value
    );

/*
 * Sign data acs rsa key
 */
    procedure sign_data (
        i_bin_id                   in com_api_type_pkg.t_short_id
        , i_data                   in com_api_type_pkg.t_text
        , o_signed_data            out com_api_type_pkg.t_text
        , o_certificate            out com_api_type_pkg.t_key
        , o_root_certificate       out com_api_type_pkg.t_key
        , o_intermediate_cert      out com_api_type_pkg.t_key
    );

/*
 * Sign data acs rsa key
 */    
    procedure sign_data (
        i_card_number              in com_api_type_pkg.t_card_number
        , i_data                   in com_api_type_pkg.t_text
        , o_signed_data            out com_api_type_pkg.t_text
        , o_certificate            out com_api_type_pkg.t_key
        , o_root_certificate       out com_api_type_pkg.t_key
        , o_intermediate_cert      out com_api_type_pkg.t_key
    );

/*
 * Getting acs public key value. Mask error when key not found.
 */    
    function get_acs_public_key (
        i_bin_id                   in com_api_type_pkg.t_short_id
    ) return com_api_type_pkg.t_key;

end;
/
