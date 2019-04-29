create or replace package iss_ui_product_card_type_pkg is
/*********************************************************
*  Issuer UI - card types <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 09.08.2010 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate:: 2010-12-09 11:25:36 +0300#$ <br />
*  Revision: $LastChangedRevision: 7044 $ <br />
*  Module: ISS_UI_PRODUCT_PKG <br />
*  @headcom
**********************************************************/
    procedure add_product_card_type (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_seq_number_low          in com_api_type_pkg.t_tiny_id
        , i_seq_number_high         in com_api_type_pkg.t_tiny_id
        , i_bin_id                  in com_api_type_pkg.t_short_id
        , i_index_range_id          in com_api_type_pkg.t_short_id
        , i_number_format_id        in com_api_type_pkg.t_tiny_id
        , i_emv_appl_scheme_id      in com_api_type_pkg.t_tiny_id
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
        , i_status                  in com_api_type_pkg.t_dict_value
        , i_perso_priority          in com_api_type_pkg.t_dict_value
        , i_reiss_command           in com_api_type_pkg.t_dict_value
        , i_reiss_start_date_rule   in com_api_type_pkg.t_dict_value
        , i_reiss_expir_date_rule   in com_api_type_pkg.t_dict_value
        , i_reiss_card_type_id      in com_api_type_pkg.t_tiny_id
        , i_reiss_contract_id       in com_api_type_pkg.t_medium_id
        , i_blank_type_id           in com_api_type_pkg.t_tiny_id
        , i_state                   in com_api_type_pkg.t_dict_value
        , i_perso_method_id         in com_api_type_pkg.t_tiny_id
        , i_service_id              in com_api_type_pkg.t_short_id := null
        , i_reiss_product_id        in com_api_type_pkg.t_short_id := null
        , i_reiss_bin_id            in com_api_type_pkg.t_short_id := null
        , i_uid_format_id           in com_api_type_pkg.t_tiny_id  := null
    );

    procedure modify_product_card_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_seq_number_low          in com_api_type_pkg.t_tiny_id
        , i_seq_number_high         in com_api_type_pkg.t_tiny_id
        , i_bin_id                  in com_api_type_pkg.t_short_id
        , i_index_range_id          in com_api_type_pkg.t_short_id
        , i_number_format_id        in com_api_type_pkg.t_tiny_id
        , i_emv_appl_scheme_id      in com_api_type_pkg.t_tiny_id
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
        , i_status                  in com_api_type_pkg.t_dict_value
        , i_perso_priority          in com_api_type_pkg.t_dict_value
        , i_reiss_command           in com_api_type_pkg.t_dict_value
        , i_reiss_start_date_rule   in com_api_type_pkg.t_dict_value
        , i_reiss_expir_date_rule   in com_api_type_pkg.t_dict_value
        , i_reiss_card_type_id      in com_api_type_pkg.t_tiny_id
        , i_reiss_contract_id       in com_api_type_pkg.t_medium_id
        , i_blank_type_id           in com_api_type_pkg.t_tiny_id
        , i_state                   in com_api_type_pkg.t_dict_value
        , i_perso_method_id         in com_api_type_pkg.t_tiny_id
        , i_service_id              in com_api_type_pkg.t_short_id := null
        , i_reiss_product_id        in com_api_type_pkg.t_short_id := null
        , i_reiss_bin_id            in com_api_type_pkg.t_short_id := null
        , i_uid_format_id           in com_api_type_pkg.t_tiny_id  := null
    );

    procedure remove_product_card_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );


    procedure check_pan_length (
        i_bin_id                    in com_api_type_pkg.t_short_id
        , i_number_format_id        in com_api_type_pkg.t_tiny_id
    );

    procedure check_intersects (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_seq_number_low          in com_api_type_pkg.t_tiny_id
        , i_seq_number_high         in com_api_type_pkg.t_tiny_id
        , o_warning_msg             out com_api_type_pkg.t_text
    );
end;
/
