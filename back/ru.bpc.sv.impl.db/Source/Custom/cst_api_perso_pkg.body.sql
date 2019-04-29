create or replace package body cst_api_perso_pkg is
/*********************************************************
*  Custom API for personalization <br />
*  Created by Kopachev D.(kopachev@bpcbt.com) at 30.04.2014 <br />
*  Last changed by $Author: necheukhin $ <br />
*  $LastChangedDate:: 2014-04-01 16:31:23 +0400#$ <br />
*  Revision: $LastChangedRevision: 41277 $ <br />
*  Module: cst_api_perso_pkg <br />
*  @headcom
**********************************************************/
      
    /*procedure get_template_values (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , o_params              out nocopy rul_api_type_pkg.t_param_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text  => 'Get custom template values...'
        );
        
        prs_api_template_pkg.get_template_values (
            i_format_id       => i_format_id
            , i_perso_rec     => i_perso_rec
            , i_perso_method  => i_perso_method
            , i_perso_data    => i_perso_data
            , i_entity_type   => i_entity_type
            , o_params        => o_params
        );
        
        -- custom set params
    end;
    
    procedure put_records (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
    ) is
        l_session_file_id       com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text  => 'Put custom record...'
        );

        l_session_file_id := prs_api_file_pkg.register_session_file (
            i_perso_rec      => i_perso_rec
            , i_format_id    => i_format_id
            , i_entity_type  => i_entity_type
            , i_file_type    => i_file_type
        );

        case i_entity_type
            when cst_api_const_pkg.ENTITY_TYPE_TEXT then
                prc_api_file_pkg.put_line (
                    i_sess_file_id  => l_session_file_id
                    , i_raw_data    => i_raw_data
                );

        else
            com_api_error_pkg.raise_error (
                i_error        => 'CANT_REGISTER_FILE_FOR_ENTITY_TYPE'
                , i_env_param1 => i_entity_type
            );

        end case;

        trc_log_pkg.debug (
            i_text  => 'Put custom record - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Put custom record error: [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure format_text_record (
        i_params                in rul_api_type_pkg.t_param_tab
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
    ) is
        l_file_data             com_api_type_pkg.t_raw_data;
    begin
        trc_log_pkg.debug (
            i_text         => 'Format text record...'
        );

        for i in 1 .. i_params.count loop
            l_file_data := l_file_data || case i_params(i).param_name
                                          when prs_api_const_pkg.PARAM_END_OF_RECORD then
                                              null
                                          else
                                              i_params(i).param_value
                                          end;
        end loop;

        put_records (
            i_raw_data         => l_file_data
            , i_perso_rec      => i_perso_rec
            , i_format_id      => i_format_id
            , i_entity_type    => cst_api_const_pkg.ENTITY_TYPE_TEXT
            , i_file_type      => cst_api_const_pkg.FILE_TYPE_TEXT
        );

        trc_log_pkg.debug (
            i_text         => 'Format text record - ok'
        );
    end;*/
    
    procedure setup_templates (
        i_template_rec          in prs_api_type_pkg.t_template_rec
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
    ) is
        l_params                  rul_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug (
            i_text  => 'Setup custom templates...'
        );
        
        -- custom template processing
        /*case i_template_rec.entity_type
            when '' then
                trc_log_pkg.debug (
                    i_text  => 'TEXT template setup ...'
                );
                if i_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                    get_template_values (
                        i_format_id       => i_template_rec.format_id
                        , i_perso_rec     => i_perso_rec
                        , i_perso_method  => i_perso_method
                        , i_perso_data    => io_perso_data
                        , i_entity_type   => cst_api_const_pkg.ENTITY_TYPE_TEXT
                        , o_params        => l_params
                    );

                    format_text_record (
                        i_params       => l_params
                        , i_perso_rec  => i_perso_rec
                        , i_format_id  => i_template_rec.format_id
                    );

                else
                    trc_log_pkg.debug (
                        i_text  => 'Generation type doesn''t request card generation ...'
                    );
                end if;
            else
                null;
        end case;*/
        
        trc_log_pkg.debug (
            i_text  => 'Setup custom templates - ok'
        );
    end;

end;
/
drop package cst_api_perso_pkg
/
