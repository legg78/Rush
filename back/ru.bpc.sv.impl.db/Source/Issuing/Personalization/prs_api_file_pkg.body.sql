create or replace package body prs_api_file_pkg is
/************************************************************
 * API for files files <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.10.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_file_pkg <br />
 * @headcom
 ************************************************************/

    g_session_files     prs_api_type_pkg.t_session_file_tab;
    g_record_counts     prs_api_type_pkg.t_session_file_tab;

    procedure clear_global_data is
    begin
        trc_log_pkg.debug (
            i_text         => 'Clear global data'
        );
        g_session_files.delete;
        g_record_counts.delete;
    end;

    procedure close_session_file is
    begin
        for i in 1 .. g_session_files.count loop
            prc_api_file_pkg.close_file (
                i_sess_file_id  => g_session_files(i).session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        end loop;

        clear_global_data;
    end;
    
    function get_file_purpose (
        i_entity_type           in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value is
        l_file_type             com_api_type_pkg.t_dict_value;
    begin
        case i_entity_type
            when prs_api_const_pkg.ENTITY_TYPE_EMBOSSING then
                l_file_type := prs_api_const_pkg.FILE_TYPE_CHIP_MAGSTRIPE;

            when prs_api_const_pkg.ENTITY_TYPE_CHIP then
                l_file_type := prs_api_const_pkg.FILE_TYPE_CHIP_EMB;

            when prs_api_const_pkg.ENTITY_TYPE_P3CHIP then
                l_file_type := prs_api_const_pkg.FILE_TYPE_CHIP_EMB;

        else
            com_api_error_pkg.raise_error (
                i_error        => 'CANT_REGISTER_FILE_FOR_ENTITY_TYPE'
                , i_env_param1 => i_entity_type
            );
        end case;
        
        return l_file_type;
    end;
    
    function set_file_params (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
    ) return com_api_type_pkg.t_param_tab is
        l_params                com_api_type_pkg.t_param_tab;
    begin
        l_params.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'BLANK_TYPE'
            , i_value    => prs_api_blank_type_pkg.get_blank_type_name(nvl(i_perso_rec.blank_type_id, 0))
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'CARD_TYPE_NAME'
            , i_value    => i_perso_rec.card_type_name
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'IS_RENEWAL'
            , i_value    => i_perso_rec.is_renewal
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'REISSUE_REASON'
            , i_value    => i_perso_rec.reissue_reason
            , io_params  => l_params
        );
        
        return l_params;
    end;

    function get_file_name (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_file_type           in com_api_type_pkg.t_dict_value := null
    ) return com_api_type_pkg.t_name is
        l_file_name             com_api_type_pkg.t_name;
        l_file_params           com_api_type_pkg.t_param_tab;
        l_params                rul_api_type_pkg.t_param_tab;
    begin
        l_file_params := set_file_params (
            i_perso_rec  => i_perso_rec
        );
        
        l_params := prc_api_file_pkg.get_default_file_name_params (
            i_file_type  => i_file_type
            , io_params  => l_file_params
        );

        for i in 1 .. l_params.count loop
            if l_params(i).param_name != 'INDEX' then
                l_file_name := l_file_name || l_params(i).param_value;
            end if;
        end loop;

        return l_file_name;
    end;
    
    function get_record_number (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_long_id is
        l_file_name             com_api_type_pkg.t_name;
        i                       binary_integer;
    begin
        if not prs_cst_perso_pkg.need_record_number(i_entity_type) then
            return null;
        end if;
        
        -- get file name
        l_file_name := get_file_name (
            i_perso_rec       => i_perso_rec
            , i_file_type  => i_file_type
        );
        
        -- find in cache
        for j in 1 .. g_record_counts.count loop
            if g_record_counts(j).file_name = nvl(l_file_name, '')
               and g_record_counts(j).format_id = i_format_id
               and g_record_counts(j).entity_type = i_entity_type
            then
                g_record_counts(j).record_number := g_record_counts(j).record_number + 1;
                return g_record_counts(j).record_number;
            end if;
        end loop;
        
        -- set cache
        i := g_record_counts.count+1;
        g_record_counts(i).entity_type := i_entity_type;
        g_record_counts(i).file_name := nvl(l_file_name, 0);
        g_record_counts(i).format_id := i_format_id;
        g_record_counts(i).record_number := 1;
        
        return 1;
    end;

    function register_session_file (
        i_perso_rec             in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_long_id is
        l_session_file_id       com_api_type_pkg.t_long_id;
        l_file_name             com_api_type_pkg.t_name;
        i                       binary_integer;
        l_params                com_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug (
            i_text         => 'Register session file'
        );

        -- get file name
        l_file_name := get_file_name (
            i_perso_rec       => i_perso_rec
            , i_file_type  => i_file_type
        );

        -- find in cache
        for j in 1 .. g_session_files.count loop
            if g_session_files(j).file_name = nvl(l_file_name, '')
               and g_session_files(j).format_id = i_format_id
               and g_session_files(j).entity_type = i_entity_type
            then
                trc_log_pkg.debug (
                    i_text         => 'File name[#1] format_id[#2] entity_type[#3] found in cache [#4]'
                    , i_env_param1 => nvl(l_file_name, '')
                    , i_env_param2 => i_format_id
                    , i_env_param3 => i_entity_type
                    , i_env_param4 => g_session_files(j).session_file_id
                );

                return g_session_files(j).session_file_id;
            end if;
        end loop;

        trc_log_pkg.debug (
            i_text         => 'Create file name[#1] format_id[#2] entity_type[#3]'
            , i_env_param1 => nvl(l_file_name, '')
            , i_env_param2 => i_format_id
            , i_env_param3 => i_entity_type
        );

        l_params := set_file_params (
            i_perso_rec    => i_perso_rec
        );

        -- open file
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
            , io_params     => l_params
            , i_file_type   => i_file_type
        );

        -- set cache
        i := g_session_files.count+1;
        g_session_files(i).entity_type := i_entity_type;
        g_session_files(i).file_name := nvl(l_file_name, 0);
        g_session_files(i).format_id := i_format_id;
        g_session_files(i).session_file_id := l_session_file_id;

        return l_session_file_id;
    end;

    procedure put_records (
        i_raw_data              in raw
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_format_id           in com_api_type_pkg.t_tiny_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
    ) is
        l_session_file_id       com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text  => 'Put embossing record...'
        );
        
        l_session_file_id := register_session_file (
            i_perso_rec      => i_perso_rec
            , i_format_id    => i_format_id
            , i_entity_type  => i_entity_type
            , i_file_type    => i_file_type
        );

        case i_entity_type
            when prs_api_const_pkg.ENTITY_TYPE_EMBOSSING then
                prc_api_file_pkg.put_file (
                    i_sess_file_id    => l_session_file_id
                    , i_blob_content  => i_raw_data
                    , i_add_to        => com_api_type_pkg.TRUE
                );

            when prs_api_const_pkg.ENTITY_TYPE_CHIP then
                prc_api_file_pkg.put_file (
                    i_sess_file_id    => l_session_file_id
                    , i_blob_content  => i_raw_data
                    , i_add_to        => com_api_type_pkg.TRUE
                );
            
            when prs_api_const_pkg.ENTITY_TYPE_P3CHIP then
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
            i_text  => 'Put embossing record - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Put embossing record error: [#1]'
                , i_env_param1  => sqlerrm
            );
            raise;
    end;

end;
/
