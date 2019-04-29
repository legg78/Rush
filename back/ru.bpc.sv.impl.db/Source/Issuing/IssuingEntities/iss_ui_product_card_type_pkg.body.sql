create or replace package body iss_ui_product_card_type_pkg is
/*********************************************************
*  Issuer UI - card types <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 09.08.2010 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate:: 2010-12-09 11:25:36 +0300#$ <br />
*  Revision: $LastChangedRevision: 7044 $ <br />
*  Module: ISS_UI_PRODUCT_PKG <br />
*  @headcom
**********************************************************/

    procedure check_intersects (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_seq_number_low          in com_api_type_pkg.t_tiny_id
        , i_seq_number_high         in com_api_type_pkg.t_tiny_id
        , o_warning_msg             out com_api_type_pkg.t_text
    ) is
        l_check_cnt                 com_api_type_pkg.t_count := 0;
    begin   
        select
            count(1)
        into
            l_check_cnt
        from
            iss_product_card_type_vw a
        where
            a.product_id = i_product_id
            and a.card_type_id = i_card_type_id
            and (a.id != i_id or i_id is null)
            and a.seq_number_low  <= i_seq_number_high
            and a.seq_number_high >= i_seq_number_low;
        
        trc_log_pkg.debug (
            i_text          => 'l_check_cnt ' || l_check_cnt
        );
                
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error         => 'INTERVALS_SEQ_NUMBERS_INTERSECTS'
              , i_env_param1    => i_card_type_id
              , i_env_param2    => i_seq_number_low
              , i_env_param3    => i_seq_number_high
            );       
        end if;
    end;

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
        , i_service_id              in com_api_type_pkg.t_short_id
        , i_reiss_product_id        in com_api_type_pkg.t_short_id := null
        , i_reiss_bin_id            in com_api_type_pkg.t_short_id := null
        , i_uid_format_id           in com_api_type_pkg.t_tiny_id  := null
    ) is
    l_warning_msg             com_api_type_pkg.t_text;
    
    begin
        check_intersects (
            i_id                 => o_id
            , i_product_id       => i_product_id
            , i_card_type_id     => i_card_type_id
            , i_seq_number_low   => i_seq_number_low
            , i_seq_number_high  => i_seq_number_high
            , o_warning_msg      => l_warning_msg
        );
             
        check_pan_length(
            i_bin_id             => i_bin_id
          , i_number_format_id   => i_number_format_id
        );

        o_id := iss_product_card_type_seq.nextval;
        o_seqnum := 1;

        insert into iss_product_card_type_vw (
            id
            , seqnum
            , product_id
            , card_type_id
            , seq_number_low
            , seq_number_high
            , bin_id
            , index_range_id
            , number_format_id
            , emv_appl_scheme_id
            , pin_request
            , pin_mailer_request
            , embossing_request
            , status
            , perso_priority
            , reiss_command
            , reiss_start_date_rule
            , reiss_expir_date_rule
            , reiss_card_type_id
            , reiss_contract_id
            , blank_type_id
            , state
            , perso_method_id
            , service_id
            , reiss_product_id 
            , reiss_bin_id   
            , uid_format_id
        ) values (
            o_id
            , o_seqnum
            , i_product_id
            , i_card_type_id
            , i_seq_number_low
            , i_seq_number_high
            , i_bin_id
            , i_index_range_id
            , i_number_format_id
            , i_emv_appl_scheme_id
            , i_pin_request
            , i_pin_mailer_request
            , i_embossing_request
            , i_status
            , i_perso_priority
            , i_reiss_command
            , i_reiss_start_date_rule
            , i_reiss_expir_date_rule
            , i_reiss_card_type_id
            , i_reiss_contract_id
            , i_blank_type_id
            , i_state
            , i_perso_method_id
            , i_service_id
            , i_reiss_product_id   
            , i_reiss_bin_id       
            , i_uid_format_id
        );
    end;

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
        , i_service_id              in com_api_type_pkg.t_short_id
        , i_reiss_product_id        in com_api_type_pkg.t_short_id := null
        , i_reiss_bin_id            in com_api_type_pkg.t_short_id := null
        , i_uid_format_id           in com_api_type_pkg.t_tiny_id  := null
    ) is
    l_warning_msg             com_api_type_pkg.t_text;

    begin
        check_intersects (
            i_id                 => i_id
            , i_product_id       => i_product_id
            , i_card_type_id     => i_card_type_id
            , i_seq_number_low   => i_seq_number_low
            , i_seq_number_high  => i_seq_number_high
            , o_warning_msg      => l_warning_msg
        );
    
        check_pan_length(
            i_bin_id             => i_bin_id
          , i_number_format_id   => i_number_format_id
        );

        update
            iss_product_card_type_vw
        set
            seqnum                = io_seqnum
          , product_id            = i_product_id
          , card_type_id          = i_card_type_id
          , seq_number_low        = i_seq_number_low
          , seq_number_high       = i_seq_number_high
          , bin_id                = i_bin_id
          , index_range_id        = i_index_range_id
          , number_format_id      = i_number_format_id
          , emv_appl_scheme_id    = i_emv_appl_scheme_id
          , pin_request           = i_pin_request
          , pin_mailer_request    = i_pin_mailer_request
          , embossing_request     = i_embossing_request
          , status                = i_status
          , perso_priority        = i_perso_priority
          , reiss_command         = i_reiss_command
          , reiss_start_date_rule = i_reiss_start_date_rule
          , reiss_expir_date_rule = i_reiss_expir_date_rule
          , reiss_card_type_id    = i_reiss_card_type_id
          , reiss_contract_id     = i_reiss_contract_id
          , blank_type_id         = i_blank_type_id
          , state                 = i_state
          , perso_method_id       = i_perso_method_id
          , service_id            = i_service_id
          , reiss_product_id      = i_reiss_product_id   
          , reiss_bin_id          = i_reiss_bin_id       
          , uid_format_id         = i_uid_format_id

        where
            id = i_id;

        io_seqnum := io_seqnum + 1;
    end;

    procedure remove_product_card_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt   number;
    begin
        -- check dependent
        select
            count(*)
        into
            l_check_cnt
        from
            iss_bin_vw a
        where
            a.card_type_id = i_id;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error         => 'ISSUING_CARD_TYPE_ALREADY_USED'
                , i_env_param1  => i_id
            );
        end if;

        update
            iss_product_card_type_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            iss_product_card_type_vw
        where
            id = i_id;
    end;


    procedure check_pan_length (
        i_bin_id                    in com_api_type_pkg.t_short_id
        , i_number_format_id        in com_api_type_pkg.t_tiny_id
    ) is
        l_bin_pan_length            com_api_type_pkg.t_tiny_id;
        l_format_pan_length         com_api_type_pkg.t_tiny_id;
    begin
        select min(pan_length)
          into l_bin_pan_length
          from iss_bin_vw
         where id = i_bin_id;

        select min(name_length)
          into l_format_pan_length
          from rul_name_format_vw
         where id = i_number_format_id;

        if nvl(l_bin_pan_length, 0) != nvl(l_format_pan_length, 0)
           and nvl(l_bin_pan_length, 0)>0 and nvl(l_format_pan_length, 0)>0
        then
            com_api_error_pkg.raise_error(
                i_error      => 'INCONSISTENT_PAN_LENGTH'
              , i_env_param1 => l_bin_pan_length
              , i_env_param2 => l_format_pan_length
            );
        end if;
    end;

end;
/
