create or replace package body prs_api_print_pkg is
/************************************************************
 * API for print PIN Mailer <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_print_pkg <br />
 * @headcom
 ************************************************************/

    function format_print_data (
        i_params                in rul_api_type_pkg.t_param_tab
        , i_pin_length          in com_api_type_pkg.t_tiny_id
    ) return prs_api_type_pkg.t_print_data_tab is
    
        l_print_data              prs_api_type_pkg.t_print_data_tab;
        l_x                       pls_integer;
        l_y                       pls_integer;
        l_next_x                  pls_integer;
        
        function get_property_num (
            i_name                  in com_api_type_pkg.t_name
            , i_property            in com_api_type_pkg.t_param_tab
        ) return number is
        begin
            return to_number(i_property(i_name));
        exception
            when others then
                return 0;
        end;
        
    begin
        trc_log_pkg.debug (
            i_text => 'Format print data...'
        );
      
        for i in 1 .. i_params.count loop
            l_x := get_property_num (
                i_name        => 'X'
                , i_property  => i_params(i).property
            );
            l_y := get_property_num (
                i_name        => 'Y'
                , i_property  => i_params(i).property
            );

            if l_print_data.exists(l_y) then
                if l_print_data(l_y).exists(l_x) then
                    com_api_error_pkg.raise_error (
                        i_error         => 'PARAMETER_POSITION_ALREADY_OCCUPIED'
                        , i_env_param1  => l_y
                        , i_env_param2  => l_x
                    );
                end if;
            end if;

            if i_params(i).param_name in (prs_api_const_pkg.PARAM_PIN_BLOCK, sec_api_const_pkg.PARAM_COMPONENT_KEY) then
                l_print_data(l_y)(l_x).text := lpad('X', i_pin_length, 'X');
                l_print_data(l_y)(l_x).is_pin_block := com_api_type_pkg.TRUE;
            else
                l_print_data(l_y)(l_x).text := nvl(i_params(i).param_value, ' '); -- printer_encoding ????
                l_print_data(l_y)(l_x).is_pin_block := com_api_type_pkg.FALSE;                                 
            end if;
            
        end loop;
        
        -- check print overlapping
        l_y := l_print_data.first;
        while l_y is not null loop
            if l_print_data(l_y).count > 1 then
                l_x := l_print_data(l_y).first;
                while l_x < l_print_data(l_y).last loop
                    l_next_x := l_print_data(l_y).next(l_x);
                    if ( l_x + length( l_print_data(l_y)(l_x).text ) - 1 ) >= l_next_x then
                        com_api_error_pkg.raise_error (
                            i_error         => 'TEXT_IN_PINMAIL_OVERLAPPING'
                            , i_env_param1  => l_y
                            , i_env_param2  => l_x
                            , i_env_param3  => l_next_x
                        );
                    end if;
                    l_x := l_next_x;
                end loop;
            end if;
            l_y := l_print_data.next(l_y);
        end loop;
        
        trc_log_pkg.debug (
            i_text => 'Format print data ok'
        );
        
        return l_print_data;
    end;

    function format_print_text (
        i_print_data            in prs_api_type_pkg.t_print_data_tab
    ) return com_api_type_pkg.t_text is
        l_print_text            com_api_type_pkg.t_text;
        l_x                     pls_integer;
        l_y                     pls_integer;
    begin
        trc_log_pkg.debug (
            i_text      => 'Format print text...'
        );
        
        l_y := i_print_data.first;
        while l_y is not null loop
            l_x := i_print_data(l_y).first;
            while l_x is not null loop
                if i_print_data(l_y)(l_x).is_pin_block = com_api_type_pkg.FALSE then
                    if instr(i_print_data(l_y)(l_x).text, prs_api_const_pkg.delimiter) = 0 then
                        l_print_text := l_print_text || i_print_data(l_y)(l_x).text || prs_api_const_pkg.delimiter;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'SYMBOL_NOT_ALLOWED_IN_PRINT_FIELD'
                            , i_env_param1  => prs_api_const_pkg.delimiter
                            , i_env_param2  => l_y
                            , i_env_param3  => l_x
                        );
                    end if;
                end if;
                l_x := i_print_data(l_y).next(l_x);
            end loop;
            l_y := i_print_data.next(l_y);
        end loop;
        l_print_text := rtrim(l_print_text, prs_api_const_pkg.delimiter);
     
        trc_log_pkg.debug (
            i_text      => 'Format print text ok'
        );
        
        return l_print_text;
    end;

    function generate_print_format (
        i_print_data            in prs_api_type_pkg.t_print_data_tab
    ) return com_api_type_pkg.t_text is
        l_field_descriptor      com_api_type_pkg.t_module_code;
        l_format_text           com_api_type_pkg.t_text;
        l_field_count           pls_integer;
        l_x                     pls_integer;
        l_y                     pls_integer;
        l_y_prev                pls_integer;
    begin
        trc_log_pkg.debug (
            i_text => 'Load print format...'
        );
              
        l_field_count := 0;
        l_y_prev := 0;
        l_y := i_print_data.first;
        while l_y is not null loop
            l_format_text := l_format_text || lpad( '>L', (l_y-l_y_prev)*2, '>L');
            
            l_x := i_print_data(l_y).first;
            while l_x is not null loop
                --PIN mailer format can contain no more than 16 data fields excluding PIN
                if l_field_count > 15 then
                    com_api_error_pkg.raise_error(
                        i_error => 'PRINT_FORMAT_CANT_CONTAIN_MORE_FIELD'
                    );
                end if;
                if i_print_data(l_y)(l_x).is_pin_block = com_api_type_pkg.TRUE then
                    l_field_descriptor := '^P';
                else
                    l_field_descriptor := '^' || to_char(l_field_count, 'FMXX');
                    l_field_count := l_field_count+1;
                end if;
                l_format_text := l_format_text
                                 -- column definition
                                 || '>' || to_char(l_x, 'FM009')
                                 -- field descriptor
                                 || l_field_descriptor;
                l_x := i_print_data(l_y).next(l_x);
            end loop;
            
            l_y_prev := l_y;
            l_y := i_print_data.next(l_y);
        end loop;
        l_format_text := l_format_text || '>F';

        trc_log_pkg.debug (
            i_text  => 'Load print format ok'
        );
        
        return l_format_text;
    end;
    
    procedure print_pin_mailer (
        i_print_data            in prs_api_type_pkg.t_print_data_tab
        , i_card_number         in com_api_type_pkg.t_card_number
        , i_pin_block           in com_api_type_pkg.t_pin_block
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_perso_key           in prs_api_type_pkg.t_perso_key_rec
    ) is
        l_result                com_api_type_pkg.t_tiny_id;
        l_print_format          com_api_type_pkg.t_text;
        l_print_text            com_api_type_pkg.t_text;
        l_pin_check_value       com_api_type_pkg.t_text;
        l_resp_message          com_api_type_pkg.t_name;
        l_hsm_device            hsm_api_type_pkg.t_hsm_device_rec;
    begin
        trc_log_pkg.debug (
            i_text  => 'Print PIN Mailer...'
        );
            
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- generate print format
            l_print_format := generate_print_format (
                i_print_data  => i_print_data
            );

            -- format print text
            l_print_text := format_print_text (
                i_print_data  => i_print_data
            );

            -- send command
            l_result := hsm_api_hsm_pkg.print_pin_mailer (
                i_hsm_ip             => l_hsm_device.address
                , i_hsm_port         => l_hsm_device.port
                , i_document_type    => 'C'
                , i_ppk              => nvl(i_perso_key.des_key.ppk.key_value, '')
                , i_ppk_prefix       => nvl(i_perso_key.des_key.ppk.key_prefix, '')
                , i_hpan             => i_card_number
                , i_pin_block        => i_pin_block
                , i_print_format     => l_print_format
                , i_print_data       => l_print_text
                , i_print_encoding   => nvl(prs_api_const_pkg.g_printer_encoding, '')
                , o_pin_check_value  => l_pin_check_value
                , o_resp_mess        => l_resp_message
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'ERROR_PRINT_PINMAILER'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => l_resp_message
            );

            trc_log_pkg.debug (
                i_text  => 'Print PIN Mailer ok'
            );
        end if;
    end;

end;
/
