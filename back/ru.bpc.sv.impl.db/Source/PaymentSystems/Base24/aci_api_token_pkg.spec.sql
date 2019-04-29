create or replace package aci_api_token_pkg is
/************************************************************
 * Base24 token API <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 18.03.2014 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_api_token_pkg <br />
 * @headcom
 ************************************************************/

    procedure collect_tokens (
        i_id                     in com_api_type_pkg.t_long_id
        , o_token_tab            out aci_api_type_pkg.t_token_tab
    );
    
    procedure create_tokens (
        i_id                      in com_api_type_pkg.t_long_id
        , i_raw_data              in com_api_type_pkg.t_raw_data
        , o_token_tab             out aci_api_type_pkg.t_token_tab
    );
    
    function format_emv_data (
        i_token_tab               in aci_api_type_pkg.t_token_tab
    ) return com_api_type_pkg.t_text;
    
    procedure get_c_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , io_crdh_presence        in out com_api_type_pkg.t_dict_value
        , io_card_presence        in out com_api_type_pkg.t_dict_value
        , io_cvv2_presence        in out com_api_type_pkg.t_dict_value
        , io_ucaf_indicator       in out com_api_type_pkg.t_dict_value
        , io_cat_level            in out com_api_type_pkg.t_dict_value
        , io_card_data_input_cap  in out com_api_type_pkg.t_dict_value
        , io_ecommerce_indicator  in out com_api_type_pkg.t_dict_value
    );
    
    procedure get_b4_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , i_pin_present           in com_api_type_pkg.t_boolean
        , i_cat_level             in com_api_type_pkg.t_dict_value
        , i_iss_inst_id           in com_api_type_pkg.t_dict_value
        , io_pos_entry_mode       in out com_api_type_pkg.t_country_code
        , o_crdh_auth_method      out com_api_type_pkg.t_dict_value
        , o_crdh_auth_entity      out com_api_type_pkg.t_dict_value
        , o_card_seq_number       out com_api_type_pkg.t_tiny_id
    );
    
    procedure get_be_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_oper_amount           out com_api_type_pkg.t_money
        , o_oper_currency         out com_api_type_pkg.t_curr_code
        , o_oper_cashback_amount  out com_api_type_pkg.t_money
    );
    
    procedure get_b1_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_pos_entry_mode        out com_api_type_pkg.t_curr_code
        , o_cvr                   out com_api_type_pkg.t_name
        , o_ecom_sec_lvl_ind      out com_api_type_pkg.t_curr_code
        , o_trace                 out com_api_type_pkg.t_auth_code
        , o_interface             out com_api_type_pkg.t_name
        , io_resp_code            in out com_api_type_pkg.t_byte_char
    );
    
    procedure get_17_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_srv_indicator         out com_api_type_pkg.t_byte_char
        , o_transaction_id        out com_api_type_pkg.t_auth_long_id
        , o_validation_code       out com_api_type_pkg.t_mcc
    );
    
    procedure get_20_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_network_refnum        out com_api_type_pkg.t_rrn
    );

    procedure get_ch_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , io_cvv2_result          in out com_api_type_pkg.t_dict_value
    );

    procedure get_06_params (
        i_token_tab               in aci_api_type_pkg.t_token_tab
        , o_pin_offset            out com_api_type_pkg.t_tiny_id
    );

end;
/
 