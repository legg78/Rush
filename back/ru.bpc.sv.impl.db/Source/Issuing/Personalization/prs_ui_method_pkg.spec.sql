create or replace package prs_ui_method_pkg is
/************************************************************
 * User interface for personalization method <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_method_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Register method
 */
    procedure add (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_pvv_store_method        in com_api_type_pkg.t_dict_value
        , i_pin_store_method        in com_api_type_pkg.t_dict_value
        , i_pin_verify_method       in com_api_type_pkg.t_dict_value
        , i_cvv_required            in com_api_type_pkg.t_boolean
        , i_icvv_required           in com_api_type_pkg.t_boolean
        , i_pvk_index               in com_api_type_pkg.t_tiny_id
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_service_code            in com_api_type_pkg.t_module_code
        , i_dda_required            in com_api_type_pkg.t_boolean
        , i_imk_index               in com_api_type_pkg.t_tiny_id
        , i_private_key_component   in com_api_type_pkg.t_dict_value
        , i_private_key_format      in com_api_type_pkg.t_dict_value
        , i_module_length           in com_api_type_pkg.t_tiny_id
        , i_max_script              in com_api_type_pkg.t_tiny_id
        , i_decimalisation_table    in com_api_type_pkg.t_pin_block
        , i_exp_date_format         in com_api_type_pkg.t_dict_value := 'EXDFMMYY'
        , i_pin_length              in com_api_type_pkg.t_tiny_id := prs_api_const_pkg.PIN_LENGTH
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
        , i_cvv2_required           in com_api_type_pkg.t_boolean
    );

/*
 * Modify method
 */
    procedure modify (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_pvv_store_method        in com_api_type_pkg.t_dict_value
        , i_pin_store_method        in com_api_type_pkg.t_dict_value
        , i_pin_verify_method       in com_api_type_pkg.t_dict_value
        , i_cvv_required            in com_api_type_pkg.t_boolean
        , i_icvv_required           in com_api_type_pkg.t_boolean
        , i_pvk_index               in com_api_type_pkg.t_tiny_id
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_service_code            in com_api_type_pkg.t_module_code
        , i_dda_required            in com_api_type_pkg.t_boolean
        , i_imk_index               in com_api_type_pkg.t_tiny_id
        , i_private_key_component   in com_api_type_pkg.t_dict_value
        , i_private_key_format      in com_api_type_pkg.t_dict_value
        , i_module_length           in com_api_type_pkg.t_tiny_id
        , i_max_script              in com_api_type_pkg.t_tiny_id
        , i_decimalisation_table    in com_api_type_pkg.t_pin_block
        , i_exp_date_format         in com_api_type_pkg.t_dict_value := 'EXDFMMYY'
        , i_pin_length              in com_api_type_pkg.t_tiny_id := prs_api_const_pkg.PIN_LENGTH
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
        , i_cvv2_required           in com_api_type_pkg.t_boolean
    );

/*
 * Remove method
 */
    procedure remove (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end; 
/
