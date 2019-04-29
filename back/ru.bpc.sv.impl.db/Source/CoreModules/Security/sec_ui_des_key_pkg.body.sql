create or replace package body sec_ui_des_key_pkg as
/************************************************************
* User interface for 3DES crypto keys <br />
* Created by Kopachev D.(kopachev@bpcbt.com) at 01.04.2010 <br />
* Last changed by $Author: kopachev $ <br />
* $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
* Revision: $LastChangedRevision: 13428 $ <br />
* Module: sec_ui_des_key_pkg <br />
* @headcom
************************************************************/

    function get_standard_id (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_tiny_id is
    begin
        trc_log_pkg.debug (
            i_text          => 'Get standard for entity_type [#1] object_id [#2]'
            , i_env_param1  => i_entity_type
            , i_env_param2  => i_object_id
        );
        
        -- get standard for entity
        case i_entity_type
            when iss_api_const_pkg.ENTITY_TYPE_ISS_BIN then
                return null;
        
            when net_api_const_pkg.ENTITY_TYPE_HOST then
                for r in (
                    select
                        s.standard_id standard_id
                    from
                        net_member_vw m
                        , cmn_standard_object s
                    where
                        m.id = i_object_id
                        and m.id = s.object_id(+)
                        and s.entity_type(+) = net_api_const_pkg.ENTITY_TYPE_HOST
                        and s.standard_type(+) = cmn_api_const_pkg.STANDART_TYPE_NETW_COMM
                        and rownum < 2
                ) loop
                    return r.standard_id;
                end loop;
                
            when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                for r in (
                    select
                        s.standard_id
                    from
                        acq_terminal_vw t
                        , cmn_standard_object s
                    where
                        t.id = i_object_id
                        and t.device_id = s.object_id(+)
                        and s.entity_type(+) = cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE
                        and s.standard_type(+) = cmn_api_const_pkg.STANDART_TYPE_TERM_COMM
                        and rownum < 2
                ) loop
                    return r.standard_id;
                end loop;

        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_entity_type
            );
        end case;
        
        return null;
    end;

    function get_standart_key_type (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_key_type          in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value is
        l_standard_id         com_api_type_pkg.t_tiny_id;
    begin
        trc_log_pkg.debug (
            i_text          => 'Get key type [#1] for entity_type [#2] object_id [#3]'
            , i_env_param1  => i_key_type
            , i_env_param2  => i_entity_type
            , i_env_param3  => i_object_id
        );
        
        -- get standard for entity
        if i_entity_type in (iss_api_const_pkg.ENTITY_TYPE_ISS_BIN) then
            return i_key_type;
        else
            l_standard_id := get_standard_id (
                i_object_id      => i_object_id
                , i_entity_type  => i_entity_type
            );
        end if;
        
        trc_log_pkg.debug (
            i_text          => 'Found standard [#1]'
            , i_env_param1  => l_standard_id
        );
        
        -- get standart key type for standard
        return cmn_ui_key_type_pkg.get_standard_key_type (
            i_standard_id  => l_standard_id
            , i_key_type   => i_key_type
        );
    end;

    function get_key_type (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_standard_key_type in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value is
        l_standard_id         com_api_type_pkg.t_tiny_id;
    begin
        trc_log_pkg.debug (
            i_text          => 'Get system key type for standart key type [#1] for entity_type [#2] object_id [#3]'
            , i_env_param1  => i_standard_key_type
            , i_env_param2  => i_entity_type
            , i_env_param3  => i_object_id
        );

        -- get standard for entity
        if i_entity_type in (iss_api_const_pkg.ENTITY_TYPE_ISS_BIN) then
            return i_standard_key_type;
        else
            l_standard_id := get_standard_id (
                i_object_id      => i_object_id
                , i_entity_type  => i_entity_type
            );
        end if;
        
        trc_log_pkg.debug (
            i_text          => 'Found standard [#1]'
            , i_env_param1  => l_standard_id
        );

        -- get system key type for standard
        return cmn_ui_key_type_pkg.get_key_type (
            i_standard_id          => l_standard_id
            , i_standard_key_type  => i_standard_key_type
        );
    end;

    procedure add_des_session_key (
        i_id                  in com_api_type_pkg.t_medium_id
    ) is
    begin
        for rec in (
            select
                id
                , seqnum
                , object_id
                , entity_type
                , lmk_id
                , key_type
                , key_index
                , key_length
                , key_value
                , key_prefix
                , check_value
            from
                sec_des_key_vw
            where
                id = i_id
                and key_type in (sec_api_const_pkg.SECURITY_DES_KEY_TMKP
                                , sec_api_const_pkg.SECURITY_DES_KEY_TMKA)
        ) loop
            merge into sec_des_key dst
            using (
                select
                    rec.object_id object_id
                    , rec.entity_type entity_type
                    , rec.lmk_id lmk_id
                    , decode( rec.key_type, sec_api_const_pkg.SECURITY_DES_KEY_TMKP
                            , sec_api_const_pkg.SECURITY_DES_KEY_TPK
                            , sec_api_const_pkg.SECURITY_DES_KEY_TAK
                    ) key_type
                    , rec.key_index key_index
                    , rec.key_length key_length
                    , rec.key_value key_value
                    , rec.key_prefix key_prefix
                    , rec.check_value check_value
                from
                    dual
            ) src
            on (
                src.object_id = dst.object_id
                and src.entity_type = dst.entity_type
                and src.key_type = dst.key_type
                and src.key_index = dst.key_index
                and src.lmk_id = dst.lmk_id
            )
            when matched then
                update
                set
                    dst.key_prefix  = src.key_prefix
                    , dst.key_length  = src.key_length
                    , dst.check_value = decode(src.key_type, sec_api_const_pkg.SECURITY_DES_KEY_TPK, src.check_value, '')
                    , dst.key_value = decode(src.key_type, sec_api_const_pkg.SECURITY_DES_KEY_TPK, src.key_value, '')
                    , dst.standard_key_type = sec_ui_des_key_pkg.get_standart_key_type (
                        i_object_id      => src.object_id
                        , i_entity_type  => src.entity_type
                        , i_key_type     => src.key_type
                    )
            when not matched then
                insert (
                    dst.id
                    , dst.seqnum
                    , dst.object_id
                    , dst.entity_type
                    , dst.lmk_id
                    , dst.key_type
                    , dst.key_index
                    , dst.key_length
                    , dst.key_value
                    , dst.key_prefix
                    , dst.check_value
                    , dst.generate_date
                    , dst.generate_user_id
                    , dst.standard_key_type
                ) values (
                    sec_des_key_seq.nextval
                    , 1
                    , src.object_id
                    , src.entity_type
                    , src.lmk_id
                    , src.key_type
                    , src.key_index
                    , src.key_length
                    , decode(src.key_type, sec_api_const_pkg.SECURITY_DES_KEY_TPK, src.key_value, '')
                    , src.key_prefix
                    , decode(src.key_type, sec_api_const_pkg.SECURITY_DES_KEY_TPK, src.check_value, '')
                    , get_sysdate
                    , get_user_id
                    , sec_ui_des_key_pkg.get_standart_key_type (
                        i_object_id      => src.object_id
                        , i_entity_type  => src.entity_type
                        , i_key_type     => src.key_type
                    )
                );
        end loop;
    end;
        
    procedure add_des_key (
        o_des_key_id          out com_api_type_pkg.t_medium_id
        , o_seqnum            out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_check_value       in sec_api_type_pkg.t_check_value := null
        , i_check_kcv         in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    ) is
        l_check_value         sec_api_type_pkg.t_check_value;
        l_key_type            com_api_type_pkg.t_dict_value;
        l_key_index           com_api_type_pkg.t_tiny_id;
        l_key_length          com_api_type_pkg.t_tiny_id;
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
        l_result              com_api_type_pkg.t_boolean;

    begin
        -- get hsm device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        l_check_value := i_check_value;
                
        -- replace key
        l_key_type := get_key_type (
            i_object_id            => i_object_id
            , i_entity_type        => i_entity_type
            , i_standard_key_type  => i_standard_key_type
        );

        l_key_index := nvl(i_key_index, 1);
        l_key_length := nvl(i_key_length, nvl(length(i_key_value), 0));

        -- generate key check value
        if l_check_value is null and hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            sec_api_des_key_pkg.generate_key_check_value (
                i_key_type         => l_key_type
                , i_hsm_device_id  => i_hsm_device_id
                , i_key_length     => l_key_length
                , i_key_value      => nvl(i_key_value, '')
                , i_key_prefix     => nvl(i_key_prefix, '')
                , o_check_value    => l_check_value
            );
        elsif i_check_kcv = com_api_type_pkg.TRUE then
            -- validate key check value
            l_result := sec_api_des_key_pkg.validate_key_check_value (
                i_key_type         => l_key_type
                , i_hsm_device_id  => i_hsm_device_id
                , i_key_length     => l_key_length
                , i_key_value      => nvl(i_key_value, '')
                , i_key_prefix     => nvl(i_key_prefix, '')
                , i_check_value    => l_check_value
            );
            if l_result = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error (
                    i_error         => 'KCV_NOT_VALID'
                    , i_env_param1  => l_check_value
                    , i_env_param2  => i_standard_key_type
                );
            end if;
        end if;

        o_des_key_id := sec_des_key_seq.nextval;
        o_seqnum := 1;
                
        -- insert key
        begin
            insert into sec_des_key_vw (
                id
                , seqnum
                , object_id
                , entity_type
                , lmk_id
                , key_type
                , key_index
                , key_length
                , key_value
                , key_prefix
                , check_value
                , standard_key_type
                , generate_date
                , generate_user_id
            ) values (
                o_des_key_id
                , o_seqnum
                , i_object_id
                , i_entity_type
                , l_hsm_device.lmk_id
                , l_key_type
                , l_key_index
                , l_key_length
                , i_key_value
                , upper(i_key_prefix)
                , l_check_value
                , i_standard_key_type
                , get_sysdate
                , get_user_id
            );
        exception
            when dup_val_on_index then
                com_api_error_pkg.raise_error (
                    i_error         => 'DUPLICATE_SEC_DES_KEY'
                    , i_env_param1  => i_standard_key_type
                    , i_env_param2  => l_key_index
                );
        end;
                
        -- add additional key
        add_des_session_key (
            i_id  => o_des_key_id
        );
    end;

    procedure modify_des_key (
        i_des_key_id          in com_api_type_pkg.t_medium_id
        , io_seqnum           in out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id := 1
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_check_value       in sec_api_type_pkg.t_check_value := null
        , i_check_kcv         in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    ) is
        l_check_value         sec_api_type_pkg.t_check_value;
        l_key_type            com_api_type_pkg.t_dict_value;
        l_key_index           com_api_type_pkg.t_tiny_id;
        l_key_length          com_api_type_pkg.t_tiny_id;
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
        l_result              com_api_type_pkg.t_boolean;
    begin
        -- get hsm device record
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
            
        l_check_value := i_check_value;
            
        -- replace key
        l_key_type := get_key_type (
            i_object_id            => i_object_id
            , i_entity_type        => i_entity_type
            , i_standard_key_type  => i_standard_key_type
        );

        l_key_index := nvl(i_key_index, 1);
        l_key_length := nvl(i_key_length, nvl(length(i_key_value), 0));

        -- generate kcv
        if l_check_value is null and hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            sec_api_des_key_pkg.generate_key_check_value (
                i_key_type         => l_key_type
                , i_hsm_device_id  => i_hsm_device_id
                , i_key_length     => l_key_length
                , i_key_value      => nvl(i_key_value, '')
                , i_key_prefix     => nvl(i_key_prefix, '')
                , o_check_value    => l_check_value
            );
        elsif i_check_kcv = com_api_type_pkg.TRUE then 
            -- validate key check value
            l_result := sec_api_des_key_pkg.validate_key_check_value (
                i_key_type         => l_key_type
                , i_hsm_device_id  => i_hsm_device_id
                , i_key_length     => l_key_length
                , i_key_value      => nvl(i_key_value, '')
                , i_key_prefix     => nvl(i_key_prefix, '')
                , i_check_value    => l_check_value
            );
            if l_result = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error (
                    i_error         => 'KCV_NOT_VALID'
                    , i_env_param1  => l_check_value
                    , i_env_param2  => i_standard_key_type
                );
            end if;
        end if;
                
        -- update key
        begin
            update
                sec_des_key_vw
            set
                seqnum = io_seqnum
                , key_prefix  = upper(i_key_prefix)
                , key_length  = i_key_length
                , check_value = l_check_value
                , key_value = i_key_value
                , key_index = l_key_index
                , lmk_id = l_hsm_device.lmk_id
            where
                id = i_des_key_id;
        exception
            when dup_val_on_index then
                com_api_error_pkg.raise_error (
                    i_error         => 'DUPLICATE_SEC_DES_KEY'
                    , i_env_param1  => i_standard_key_type
                    , i_env_param2  => l_key_index
                );        
        end;
                         
        io_seqnum := io_seqnum + 1;
                
        -- add additional key
        add_des_session_key (
            i_id  => i_des_key_id
        );
    end;

    procedure remove_des_key (
        i_des_key_id          in com_api_type_pkg.t_medium_id
        , i_seqnum            in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            sec_des_key_vw
        set
            seqnum = i_seqnum
        where
            id = i_des_key_id;

        delete from
            sec_des_key_vw
        where
            id = i_des_key_id;
    end;
        
    procedure generate_des_key (
        io_id                 in out com_api_type_pkg.t_medium_id
        , io_seqnum           in out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , i_key_comp_num      in com_api_type_pkg.t_tiny_id
        , i_format_id         in com_api_type_pkg.t_tiny_id
    ) is
        l_result              com_api_type_pkg.t_tiny_id;
        l_rul_params          rul_api_type_pkg.t_param_tab;
        l_params              com_api_type_pkg.t_param_tab;
        l_print_data          prs_api_type_pkg.t_print_data_tab;
        l_print_format        com_api_type_pkg.t_text;
        l_print_text          com_api_type_pkg.t_text;
        l_key_type            com_api_type_pkg.t_dict_value;
        l_key_length          com_api_type_pkg.t_tiny_id;
        l_key_value           sec_api_type_pkg.t_key_value;
        l_check_value         sec_api_type_pkg.t_check_value;
        l_key_prefix          sec_api_type_pkg.t_key_prefix;
        l_key_comp_num        com_api_type_pkg.t_tiny_id;
        l_resp_message        com_api_type_pkg.t_name;
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
        l_object_number       com_api_type_pkg.t_param_value;
    begin
        trc_log_pkg.debug (
            i_text          => 'Request to generate key [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_key_comp_num
            , i_env_param2  => i_standard_key_type
            , i_env_param3  => i_key_prefix
            , i_env_param4  => i_key_length
            , i_env_param5  => i_key_index
            , i_env_param6  => i_format_id
        );
            
        prs_api_const_pkg.init_printer_encoding;

        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );
            
        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            l_key_comp_num := nvl(i_key_comp_num, 0);
            
            -- replace key
            l_key_type := get_key_type (
                i_object_id            => i_object_id
                , i_entity_type        => i_entity_type
                , i_standard_key_type  => i_standard_key_type
            );
            
            l_key_prefix := nvl(i_key_prefix, '');
            l_key_length := nvl(i_key_length, nvl(length(l_key_value), 0));

            trc_log_pkg.debug (
                i_text          => 'Key generation step [#1]'
                , i_env_param1  => 10 
            );

            -- format print data
            if l_key_comp_num > 0 then

                trc_log_pkg.debug (
                    i_text          => 'Format print data'
                );
                
                -- get standard for entity
                case i_entity_type
                    when iss_api_const_pkg.ENTITY_TYPE_ISS_BIN then
                        for r in (
                            select
                                b.bin
                            from
                                iss_bin_vw b
                            where
                                b.id = i_object_id
                        ) loop
                            l_object_number := r.bin;
                        end loop;

                    when net_api_const_pkg.ENTITY_TYPE_HOST then
                        for r in (
                            select
                                get_text (
                                    i_table_name    => 'net_member'
                                    , i_column_name => 'description'
                                    , i_object_id   => m.id
                                    , i_lang        => get_user_lang
                                ) description
                            from
                                net_member_vw m
                            where
                                m.id = i_object_id
                        ) loop
                            l_object_number := r.description;
                        end loop;

                    when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                        for r in (
                            select
                                t.terminal_number
                            from
                                acq_terminal_vw t
                            where
                                t.id = i_object_id
                        ) loop
                            l_object_number := r.terminal_number;
                        end loop;

                else
                    com_api_error_pkg.raise_error (
                        i_error         => 'UNKNOWN_ENTITY_TYPE'
                        , i_env_param1  => i_entity_type
                    );
                end case;

                rul_api_param_pkg.set_param (
                    i_name      => sec_api_const_pkg.PARAM_OBJECT_NUMBER
                    , i_value   => l_object_number
                    , io_params => l_params
                );
                rul_api_param_pkg.set_param (
                    i_name      => sec_api_const_pkg.PARAM_COMPONENT_KEY
                    , i_value   => ''
                    , io_params => l_params
                );
                rul_api_param_pkg.set_param (
                    i_name      => sec_api_const_pkg.PARAM_COMPONENT_NUM
                    , i_value   => 'CN'
                    , io_params => l_params
                );

                rul_api_param_pkg.set_param (
                    i_name      => sec_api_const_pkg.PARAM_KEY_TYPE
                    , i_value   => l_key_type
                    , io_params => l_params
                );

                trc_log_pkg.debug (
                    i_text          => 'Get rules parameters for format [#1]'
                    , i_env_param1  => i_format_id
                );

                l_rul_params := rul_api_name_pkg.get_params_name (
                    i_format_id   => i_format_id
                    , i_param_tab => l_params
                );

                trc_log_pkg.debug (
                    i_text  => 'Format print data array'
                );

                -- format print data array
                l_print_data := prs_api_print_pkg.format_print_data (
                    i_params => l_rul_params
                );
                    
                trc_log_pkg.debug (
                    i_text  => 'Load print format'
                );

                -- load print format
                l_print_format := prs_api_print_pkg.generate_print_format (
                    i_print_data  => l_print_data
                );

                trc_log_pkg.debug (
                    i_text  => 'Format print text'
                );

                -- format print text
                l_print_text := prs_api_print_pkg.format_print_text (
                    i_print_data => l_print_data
                );
                
                l_print_format := nvl(l_print_format, '');
                l_print_text := nvl(l_print_text,'');
                
                trc_log_pkg.debug (
                    i_text          => 'Going to generate key and print component using hsm [#1][#2][#3][#4][#5][#6]'
                    , i_env_param1  => i_hsm_device_id
                    , i_env_param2  => l_key_type
                    , i_env_param3  => l_key_prefix
                    , i_env_param4  => l_key_length
                    , i_env_param5  => l_print_format
                    , i_env_param6  => l_print_text
                );
                
                -- generate key and print component
                l_result := hsm_api_hsm_pkg.generate_des_key (
                    i_hsm_ip           => l_hsm_device.address
                    , i_hsm_port       => l_hsm_device.port
                    , i_key_type       => l_key_type
                    , i_key_length     => l_key_length
                    , o_key_value      => l_key_value
                    , io_key_prefix    => l_key_prefix
                    , o_check_value    => l_check_value
                    , i_component_num  => l_key_comp_num
                    , i_print_format   => l_print_format
                    , i_print_data     => l_print_text
                    , i_print_encoding => nvl(prs_api_const_pkg.G_PRINTER_ENCODING, '')
                    , o_resp_mess      => l_resp_message
                );
                
            else
                trc_log_pkg.debug (
                    i_text          => 'Going to generate key using hsm [#1][#2][#3][#4]'
                    , i_env_param1  => i_hsm_device_id
                    , i_env_param2  => l_key_type
                    , i_env_param3  => l_key_prefix
                    , i_env_param4  => l_key_length
                );
                
                -- generate key
                l_result := hsm_api_hsm_pkg.generate_des_key (
                    i_hsm_ip           => l_hsm_device.address
                    , i_hsm_port       => l_hsm_device.port
                    , i_key_type       => l_key_type
                    , i_key_length     => l_key_length
                    , o_key_value      => l_key_value
                    , io_key_prefix    => l_key_prefix
                    , o_check_value    => l_check_value
                    , o_resp_mess      => l_resp_message
                );

            end if;

            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'KEY_GENERATION_FAILED'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => i_standard_key_type
              , i_env_param3     => l_resp_message
            );

            trc_log_pkg.debug (
                i_text          => 'Going to save key [#1][#2][#3][#4]'
                , i_env_param1  => l_key_value
                , i_env_param2  => l_key_prefix 
                , i_env_param3  => l_check_value 
                , i_env_param4  => l_resp_message 
            );

            -- save key
            if io_id is null then
                add_des_key (
                    o_des_key_id           => io_id
                    , o_seqnum             => io_seqnum
                    , i_object_id          => i_object_id
                    , i_entity_type        => i_entity_type
                    , i_hsm_device_id      => i_hsm_device_id
                    , i_standard_key_type  => i_standard_key_type
                    , i_key_index          => i_key_index
                    , i_key_length         => l_key_length
                    , i_key_value          => l_key_value
                    , i_key_prefix         => l_key_prefix
                    , i_check_value        => l_check_value
                    , i_check_kcv          => com_api_type_pkg.FALSE
                );
                    
                trc_log_pkg.debug (
                    i_text  => 'Key added'
                );
            else
                modify_des_key (
                    i_des_key_id           => io_id
                    , io_seqnum            => io_seqnum
                    , i_object_id          => i_object_id
                    , i_entity_type        => i_entity_type
                    , i_hsm_device_id      => i_hsm_device_id
                    , i_standard_key_type  => i_standard_key_type
                    , i_key_index          => i_key_index
                    , i_key_prefix         => l_key_prefix
                    , i_key_length         => l_key_length
                    , i_key_value          => l_key_value
                    , i_check_value        => l_check_value
                    , i_check_kcv          => com_api_type_pkg.FALSE
                );

                trc_log_pkg.debug (
                    i_text  => 'Key modified'
                );
            end if;
        end if;
    end;
        
    procedure translate_des_key (
        io_id                 in out com_api_type_pkg.t_medium_id
        , io_seqnum           in out com_api_type_pkg.t_seqnum
        , i_object_id         in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_source_key_prefix in sec_api_type_pkg.t_key_prefix
        , i_source_key        in sec_api_type_pkg.t_key_value
        , i_key_enc_key       in com_api_type_pkg.t_dict_value
        , io_dest_check_value in out sec_api_type_pkg.t_check_value
        , i_dest_key_prefix   in sec_api_type_pkg.t_key_prefix
    ) is
        l_result              com_api_type_pkg.t_tiny_id;
        l_key_enc_key         com_api_type_pkg.t_dict_value;
        l_key_type            com_api_type_pkg.t_dict_value;
        l_key_value           sec_api_type_pkg.t_key_value;
        l_resp_message        com_api_type_pkg.t_name;
        l_zmk_key             sec_api_type_pkg.t_des_key_rec;
        l_hsm_device          hsm_api_type_pkg.t_hsm_device_rec;
        l_standard_id         com_api_type_pkg.t_tiny_id;
        l_param_tab           com_api_type_pkg.t_param_tab;
        l_atalla_variant_support com_api_type_pkg.t_long_id;
    begin
        io_dest_check_value := nvl(io_dest_check_value, '');
                
        trc_log_pkg.debug (
            i_text          => 'Request to translate key [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => io_dest_check_value
            , i_env_param2  => i_entity_type 
            , i_env_param3  => i_standard_key_type 
            , i_env_param4  => i_source_key_prefix
            , i_env_param5  => i_source_key 
            , i_env_param6  => i_dest_key_prefix
        );
            
        -- get hsm
        l_hsm_device := hsm_api_device_pkg.get_hsm_device (
            i_hsm_device_id  => i_hsm_device_id
        );

        if hsm_api_device_pkg.g_use_hsm = com_api_type_pkg.TRUE then
            -- replace key
            l_key_type := get_key_type (
                i_object_id            => i_object_id
                , i_entity_type        => i_entity_type
                , i_standard_key_type  => i_standard_key_type
            );
            -- replace key
            l_key_enc_key := get_key_type (
                i_object_id            => i_object_id
                , i_entity_type        => i_entity_type
                , i_standard_key_type  => i_key_enc_key
            );
                
            -- getting zone master key
            l_zmk_key := sec_api_des_key_pkg.get_key (
                i_object_id      => i_object_id
                , i_entity_type  => i_entity_type
                , i_key_type     => l_key_enc_key
            );
              
            l_standard_id := hsm_api_device_pkg.get_hsm_standard (
                i_hsm_device_id  => i_hsm_device_id
            );
             
            begin    
                cmn_api_standard_pkg.get_param_value(
                    i_inst_id        => null
                  , i_standard_id    => l_standard_id
                  , i_entity_type    => hsm_api_const_pkg.ENTITY_TYPE_HSM
                  , i_object_id      => i_hsm_device_id
                  , i_param_name     => 'ATALLA_VARIANT_SUPPORT'
                  , i_param_tab      => l_param_tab
                  , o_param_value    => l_atalla_variant_support
                );
            
            exception
                when others then
                   l_atalla_variant_support := 0;     
            end;

            -- translate key
            l_result := hsm_api_hsm_pkg.translate_key_from_zmk_to_lmk ( 
                i_hsm_ip                   => l_hsm_device.address
                , i_hsm_port               => l_hsm_device.port
                , i_zmk_prefix             => l_zmk_key.key_prefix
                , i_zmk                    => l_zmk_key.key_value
                , i_key_type               => l_key_type
                , i_source_key_prefix      => i_source_key_prefix
                , i_source_key             => i_source_key
                , i_dest_key_prefix        => nvl(i_dest_key_prefix, i_source_key_prefix)
                , o_dest_key               => l_key_value
                , io_dest_key_kcv          => io_dest_check_value
                , o_resp_message           => l_resp_message
                , i_atalla_variant_support => l_atalla_variant_support
            );
            -- if an error occurs then we should process it and raise some application error 
            hsm_api_device_pkg.process_error(
                i_hsm_devices_id => i_hsm_device_id
              , i_result_code    => l_result
              , i_error          => 'KEY_TRANSLATION_FAILED'
              , i_env_param1     => i_hsm_device_id
              , i_env_param2     => i_standard_key_type
              , i_env_param3     => l_resp_message
            );

            -- save key
            if io_id is null then
                add_des_key (
                    o_des_key_id           => io_id
                    , o_seqnum             => io_seqnum
                    , i_object_id          => i_object_id
                    , i_entity_type        => i_entity_type
                    , i_hsm_device_id      => i_hsm_device_id
                    , i_standard_key_type  => i_standard_key_type
                    , i_key_index          => i_key_index
                    , i_key_length         => i_key_length
                    , i_key_value          => l_key_value
                    , i_key_prefix         => nvl(i_dest_key_prefix, i_source_key_prefix)
                );
            else
                modify_des_key (
                    i_des_key_id           => io_id
                    , io_seqnum            => io_seqnum
                    , i_object_id          => i_object_id
                    , i_entity_type        => i_entity_type
                    , i_hsm_device_id      => i_hsm_device_id
                    , i_standard_key_type  => i_standard_key_type
                    , i_key_prefix         => nvl(i_dest_key_prefix, i_source_key_prefix)
                    , i_key_length         => i_key_length
                    , i_key_value          => l_key_value
                );
            end if;
        end if;
    end;

    procedure generate_key_check_value (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix
        , o_check_value       out sec_api_type_pkg.t_check_value
    ) is
        l_key_type            com_api_type_pkg.t_dict_value;
    begin
        -- replace key
        l_key_type := get_key_type (
            i_object_id            => i_object_id
            , i_entity_type        => i_entity_type
            , i_standard_key_type  => i_standard_key_type
        );
            
        sec_api_des_key_pkg.generate_key_check_value (
            i_key_type         => l_key_type
            , i_hsm_device_id  => i_hsm_device_id
            , i_key_length     => i_key_length
            , i_key_value      => i_key_value
            , i_key_prefix     => i_key_prefix
            , o_check_value    => o_check_value
        );
    end;

    function validate_key_check_value (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_length        in com_api_type_pkg.t_tiny_id
        , i_key_value         in sec_api_type_pkg.t_key_value
        , i_key_prefix        in sec_api_type_pkg.t_key_prefix 
        , i_check_value       in sec_api_type_pkg.t_check_value
    ) return com_api_type_pkg.t_boolean is
        l_key_type            com_api_type_pkg.t_dict_value;
        l_result              com_api_type_pkg.t_boolean;
    begin
        -- replace key
        l_key_type := get_key_type (
            i_object_id            => i_object_id
            , i_entity_type        => i_entity_type
            , i_standard_key_type  => i_standard_key_type
        );
            
        l_result := sec_api_des_key_pkg.validate_key_check_value (
            i_key_type         => l_key_type
            , i_hsm_device_id  => i_hsm_device_id
            , i_key_length     => i_key_length
            , i_key_value      => i_key_value
            , i_key_prefix     => i_key_prefix
            , i_check_value    => i_check_value
        );
        
        return l_result;
    end;

    function get_des_key (
        i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type       in com_api_type_pkg.t_dict_value
        , i_hsm_device_id     in com_api_type_pkg.t_tiny_id
        , i_standard_key_type in com_api_type_pkg.t_dict_value
        , i_key_index         in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_medium_id is
        l_key_type            com_api_type_pkg.t_dict_value;
        l_result              sec_api_type_pkg.t_des_key_rec;
    begin
        -- replace key
        l_key_type := get_key_type (
            i_object_id            => i_object_id
            , i_entity_type        => i_entity_type
            , i_standard_key_type  => i_standard_key_type
        );
        
        l_result := sec_api_des_key_pkg.get_key (
            i_object_id        => i_object_id
            , i_entity_type    => i_entity_type
            , i_hsm_device_id  => i_hsm_device_id
            , i_key_type       => l_key_type
            , i_key_index      => i_key_index
            , i_mask_error     => com_api_type_pkg.TRUE
        );
            
        return l_result.id;
    end;

end;
/
