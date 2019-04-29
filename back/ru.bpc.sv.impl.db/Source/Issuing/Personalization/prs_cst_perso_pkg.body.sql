create or replace package body prs_cst_perso_pkg is
/*********************************************************
*  Custom API for personalization <br />
*  Created by Kopachev D.(kopachev@bpcbt.com) at 30.04.2014 <br />
*  Last changed by $Author: necheukhin $ <br />
*  $LastChangedDate:: 2014-04-01 16:31:23 +0400#$ <br />
*  Revision: $LastChangedRevision: 41277 $ <br />
*  Module: cst_api_perso_pkg <br />
*  @headcom
**********************************************************/

    /*procedure set_mod_params (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , o_param_tab           out com_api_type_pkg.t_param_tab
    ) is
    begin
        o_param_tab.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'PERSO_PRIORITY'
            , i_value    => i_perso_rec.perso_priority
            , io_params  => o_param_tab
        );
    end;

    function get_param_num (
        i_name              in com_api_type_pkg.t_name
        , i_params          in rul_api_type_pkg.t_param_tab
    ) return number is
        l_name              com_api_type_pkg.t_name := upper(i_name);
    begin
        for i in 1 .. i_params.count loop
             if i_params(i).param_name = l_name then
                 return to_number(i_params(i).param_value);
             end if;
        end loop;
        return null;
    end;
    
    procedure get_text_template_values (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , o_params              out nocopy rul_api_type_pkg.t_param_tab
    ) is
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_record_number         pls_integer;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get custom template values...'
        );
        
        l_record_number := prs_api_file_pkg.get_record_number (
            i_perso_rec      => i_perso_rec
            , i_format_id    => i_format_id
            , i_entity_type  => i_entity_type
            , i_file_type    => cst_api_const_pkg.ENTITY_TYPE_EMB_TEXT
        );

        prs_api_template_pkg.set_template_param (
            i_format_id        => i_format_id
            , i_perso_rec      => i_perso_rec
            , i_perso_method   => i_perso_method
            , i_perso_data     => i_perso_data
            , i_entity_type    => i_entity_type
            , i_record_number  => l_record_number
            , o_param_tab      => l_param_tab
        );

        -- custom set params
        -- ..
        
        -- get params array
        o_params := rul_api_name_pkg.get_params_name (
            i_format_id    => i_format_id
            , i_param_tab  => l_param_tab
        );
    end;
    
    procedure get_emb_template_values (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , o_params              out nocopy rul_api_type_pkg.t_param_tab
    ) is
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_record_number         binary_integer;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get custom template values...'
        );
        
        l_record_number := prs_api_file_pkg.get_record_number (
            i_perso_rec      => i_perso_rec
            , i_format_id    => i_format_id
            , i_entity_type  => i_entity_type
            , i_file_type    => cst_api_const_pkg.FILE_TYPE_EMB_EMBOSS
        );
        
        prs_api_template_pkg.set_template_param (
            i_format_id        => i_format_id
            , i_perso_rec      => i_perso_rec
            , i_perso_method   => i_perso_method
            , i_perso_data     => i_perso_data
            , i_entity_type    => i_entity_type
            , i_record_number  => l_record_number
            , o_param_tab      => l_param_tab
        );

        -- custom set params
        -- ..
        
        -- get params array
        o_params := rul_api_name_pkg.get_params_name (
            i_format_id    => i_format_id
            , i_param_tab  => l_param_tab
        );
    end;
    
    procedure get_chip_template_values (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , o_params              out nocopy rul_api_type_pkg.t_param_tab
    ) is
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_record_number         pls_integer;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get custom emv template values...'
        );

        -- format translate pin block
        prs_api_command_pkg.translate_pinblock (
            i_perso_rec          => i_perso_rec
            , i_perso_key        => io_perso_data.perso_key
            , i_hsm_device_id    => io_perso_data.hsm_device_id
            , i_pinblock_format  => prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
            , o_pin_block        => io_perso_data.tr_pin_block
        );
        
        l_record_number := prs_api_file_pkg.get_record_number (
            i_perso_rec      => i_perso_rec
            , i_format_id    => i_format_id
            , i_entity_type  => i_entity_type
            , i_file_type    => cst_api_const_pkg.FILE_TYPE_EMB_EMBOSS
        );
        
        prs_api_template_pkg.set_template_param (
            i_format_id        => i_format_id
            , i_perso_rec      => i_perso_rec
            , i_perso_method   => i_perso_method
            , i_perso_data     => io_perso_data
            , i_entity_type    => cst_api_const_pkg.ENTITY_TYPE_CHIP
            , i_record_number  => l_record_number
            , o_param_tab      => l_param_tab
        );
        
        -- custom set params
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_EMBOSSING_DATA
            , i_value    => 'EMBOSSING_DATA'
            , io_params  => l_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CHIP_DATA
            , i_value    => 'CHIP_DATA'
            , io_params  => l_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => cst_api_const_pkg.PARAM_EMV_SCHEME_ID
            , i_value    => to_number(null)
            , io_params  => l_param_tab
        );
        
        -- get params array
        o_params := rul_api_name_pkg.get_params_name (
            i_format_id    => i_format_id
            , i_param_tab  => l_param_tab
        );

        trc_log_pkg.debug (
            i_text  => 'Get custom emv template values - ok'
        );
    end;

    procedure put_char_records (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
    ) is
        l_session_file_id       com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text  => 'Put custom char record...'
        );

        l_session_file_id := prs_api_file_pkg.register_session_file (
            i_perso_rec      => i_perso_rec
            , i_format_id    => i_format_id
            , i_entity_type  => i_entity_type
            , i_file_type    => i_file_type
        );

        case i_entity_type
            when cst_api_const_pkg.ENTITY_TYPE_EMB_TEXT then
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
            i_text  => 'Put custom char record - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Put custom char record error: [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure put_raw_records (
        i_raw_data              in raw
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
    ) is
        l_session_file_id       com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text  => 'Put custom raw record...'
        );

        l_session_file_id := prs_api_file_pkg.register_session_file (
            i_perso_rec      => i_perso_rec
            , i_format_id    => i_format_id
            , i_entity_type  => i_entity_type
            , i_file_type    => i_file_type
        );

        case i_entity_type
            when cst_api_const_pkg.ENTITY_TYPE_EMBOSSING then
                prc_api_file_pkg.put_file (
                    i_sess_file_id    => l_session_file_id
                    , i_blob_content  => i_raw_data
                    , i_add_to        => com_api_type_pkg.TRUE
                );

        else
            com_api_error_pkg.raise_error (
                i_error        => 'CANT_REGISTER_FILE_FOR_ENTITY_TYPE'
                , i_env_param1 => i_entity_type
            );

        end case;

        trc_log_pkg.debug (
            i_text  => 'Put custom raw record - ok'
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
            l_file_data := l_file_data ||
            case i_params(i).param_name
            when prs_api_const_pkg.PARAM_END_OF_RECORD then
                null
            else
                i_params(i).param_value
            end;
        end loop;

        put_char_records (
            i_raw_data         => l_file_data
            , i_perso_rec      => i_perso_rec
            , i_format_id      => i_format_id
            , i_entity_type    => cst_api_const_pkg.ENTITY_TYPE_EMB_TEXT
            , i_file_type      => cst_api_const_pkg.FILE_TYPE_EMB_TEXT
        );

        trc_log_pkg.debug (
            i_text         => 'Format text record - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Format text record error: [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure format_emb_data (
        i_params                in rul_api_type_pkg.t_param_tab
        , io_perso_data         in out prs_api_type_pkg.t_perso_data_rec
    ) is
        l_raw_data              raw(32767);
    begin
        trc_log_pkg.debug (
            i_text  => 'Format custom embossing data...'
        );
        
        for i in 1 .. i_params.count loop
            l_raw_data := l_raw_data || 
            case i_params(i).param_name
            when prs_api_const_pkg.PARAM_END_OF_RECORD then
                null
            else
                utl_raw.cast_to_raw (
                   prs_api_util_pkg.convert_data (i_params(i).param_value, io_perso_data.charset)
                )
            end;
        end loop;
        
        io_perso_data.cust_embossing_data := l_raw_data;

        trc_log_pkg.debug (
            i_text  => 'Format custom embossing data - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Format custom embossing data error: [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;
    
    procedure format_chip_data (
        i_params                in rul_api_type_pkg.t_param_tab
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out prs_api_type_pkg.t_perso_data_rec
    ) is
        l_appl_params           com_api_type_pkg.t_param_tab;
        l_appl_scheme_id        com_api_type_pkg.t_tiny_id;
        l_appl_data             emv_api_type_pkg.t_appl_data_tab;
        l_raw_data              raw(32767);
        l_chip_data             raw(32767);
    begin
        trc_log_pkg.debug (
            i_text  => 'Format custom chip embossing data...'
        );
        
        l_appl_scheme_id := get_param_num (
            i_name      => cst_api_const_pkg.PARAM_EMV_SCHEME_ID
            , i_params  => i_params
        );
        if l_appl_scheme_id is null then
            com_api_error_pkg.raise_error (
                i_error         => 'EMV_TEMPLATE_NOT_SPECIFIED'
            );
        end if;
        
        -- parameters
        set_mod_params (
            i_perso_rec    => i_perso_rec
            , o_param_tab  => l_appl_params
        );
        
        emv_api_application_pkg.process_application (
            i_appl_scheme_id  => l_appl_scheme_id
            , i_perso_rec     => i_perso_rec
            , i_perso_method  => i_perso_method
            , io_perso_data   => io_perso_data
            , io_appl_data    => l_appl_data
            , i_params        => l_appl_params
        );
        
        -- set pix only chip cards
        if i_perso_method.id not in (5007,5008,5009,5010,5011,5013,5014,5015,5016,5020,5021) then
            for i in 1 .. l_appl_data.count loop
                l_appl_data(i).pix := '0';
            end loop;
        end if;
        
        emv_api_application_pkg.format_chip_data (
            i_card_number  => i_perso_rec.card_number
            , i_appl_data  => l_appl_data
            , o_chip_data  => l_chip_data
        );
            
        for i in 1 .. i_params.count loop
            l_raw_data := l_raw_data || 
            case i_params(i).param_name
            when cst_api_const_pkg.PARAM_EMV_SCHEME_ID then
                null
            when prs_api_const_pkg.PARAM_CHIP_DATA then
                l_chip_data
            when prs_api_const_pkg.PARAM_EMBOSSING_DATA then
                io_perso_data.cust_embossing_data
            else
                utl_raw.cast_to_raw (
                   prs_api_util_pkg.convert_data (i_params(i).param_value, io_perso_data.charset)
                )
            end;
        end loop;

        put_raw_records (
            i_raw_data         => l_raw_data
            , i_perso_rec      => i_perso_rec
            , i_format_id      => i_format_id
            , i_entity_type    => cst_api_const_pkg.ENTITY_TYPE_EMBOSSING
            , i_file_type      => cst_api_const_pkg.FILE_TYPE_EMB_EMBOSS
        );
        
        trc_log_pkg.debug (
            i_text  => 'Format custom chip embossing data - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Format custom chip embossing data error: [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;*/

    function need_record_number (
        i_entity_type           in com_api_type_pkg.t_dict_value
    ) return boolean is
    begin
        return i_entity_type in (
            prs_api_const_pkg.ENTITY_TYPE_EMBOSSING
            , prs_api_const_pkg.ENTITY_TYPE_CHIP
            , prs_api_const_pkg.ENTITY_TYPE_P3CHIP
        );
    end;

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

        /*case i_template_rec.entity_type
            when cst_api_const_pkg.ENTITY_TYPE_EMB_TEXT then
                trc_log_pkg.debug (
                    i_text  => 'TEXT template setup ...'
                );
                if i_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                    get_text_template_values (
                        i_format_id       => i_template_rec.format_id
                        , i_perso_rec     => i_perso_rec
                        , i_perso_method  => i_perso_method
                        , i_perso_data    => io_perso_data
                        , i_entity_type   => i_template_rec.entity_type
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
                
            when cst_api_const_pkg.ENTITY_TYPE_EMBOSSING then
                trc_log_pkg.debug (
                    i_text  => 'EMBOSSING template setup ...'
                );
                if i_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                    get_emb_template_values (
                        i_format_id       => i_template_rec.format_id
                        , i_perso_rec     => i_perso_rec
                        , i_perso_method  => i_perso_method
                        , i_perso_data    => io_perso_data
                        , i_entity_type   => i_template_rec.entity_type
                        , o_params        => l_params
                    );
                            
                    format_emb_data (
                        i_params         => l_params
                        , io_perso_data  => io_perso_data
                    );
                else
                    trc_log_pkg.debug (
                        i_text  => 'Generation type doesn''t request card generation ...'
                    );
                end if;
                
            when cst_api_const_pkg.ENTITY_TYPE_CHIP then
                trc_log_pkg.debug (
                    i_text  => 'CHIP template setup ...'
                );
                if i_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                    get_chip_template_values (
                        i_format_id       => i_template_rec.format_id
                        , i_perso_rec     => i_perso_rec
                        , i_perso_method  => i_perso_method
                        , io_perso_data   => io_perso_data
                        , i_entity_type   => i_template_rec.entity_type
                        , o_params        => l_params
                    );
                            
                    format_chip_data (
                        i_params          => l_params
                        , i_perso_rec     => i_perso_rec
                        , i_format_id     => i_template_rec.format_id
                        , i_perso_method  => i_perso_method
                        , io_perso_data   => io_perso_data
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
