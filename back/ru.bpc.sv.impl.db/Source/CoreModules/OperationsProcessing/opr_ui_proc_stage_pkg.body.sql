create or replace package body opr_ui_proc_stage_pkg is

    procedure add_proc_stage (
        o_id                       out com_api_type_pkg.t_short_id
        , i_msg_type            in     com_api_type_pkg.t_dict_value
        , i_sttl_type           in     com_api_type_pkg.t_dict_value
        , i_oper_type           in     com_api_type_pkg.t_dict_value
        , i_proc_stage          in     com_api_type_pkg.t_dict_value
        , i_exec_order          in     com_api_type_pkg.t_tiny_id
        , i_parent_stage        in     com_api_type_pkg.t_dict_value
        , i_split_method        in     com_api_type_pkg.t_dict_value
        , i_status              in     com_api_type_pkg.t_dict_value
        , i_lang                in     com_api_type_pkg.t_dict_value
        , i_name                in     com_api_type_pkg.t_name
        , i_description         in     com_api_type_pkg.t_full_desc
        , i_command             in     com_api_type_pkg.t_dict_value    default null
        , i_result_status       in     com_api_type_pkg.t_dict_value    default null
    ) is
        l_id                           com_api_type_pkg.t_short_id;
    begin
        for rec in (select id
                      from opr_proc_stage_vw
                     where msg_type = i_msg_type
                       and sttl_type = i_sttl_type
                       and oper_type = i_oper_type
                       and proc_stage = i_proc_stage
                       and (split_method = i_split_method or (split_method is null and i_split_method is null))
                       and (status = i_status or (status is null and i_status is null))
                       and (command = i_command or (command is null and i_command is null))
                       and (result_status = i_result_status or (result_status is null and i_result_status is null))
        ) loop
            com_api_error_pkg.raise_error(
                i_error      => 'OPR_STAGE_NOT_UNIQUE'
            );
        end loop;  
    
        begin
            select id
              into l_id
              from opr_proc_stage_vw
             where proc_stage = i_proc_stage
               and parent_stage = i_parent_stage;
            
            com_api_error_pkg.raise_error (
                i_error             => 'OPR_STAGE_ALREADY_EXIST'
              , i_env_param1        => i_proc_stage
              , i_env_param2        => i_parent_stage
            );
        exception
            when no_data_found then
                o_id := opr_proc_stage_seq.nextval;

                insert into opr_proc_stage_vw (
                    id
                    , msg_type
                    , sttl_type
                    , oper_type
                    , proc_stage
                    , exec_order
                    , parent_stage
                    , split_method
                    , status
                    , command
                    , result_status
                ) values (
                    o_id
                    , i_msg_type
                    , i_sttl_type
                    , i_oper_type
                    , i_proc_stage
                    , i_exec_order
                    , i_parent_stage
                    , i_split_method
                    , i_status
                    , i_command
                    , i_result_status
                );

                com_api_i18n_pkg.add_text (
                    i_table_name      => 'opr_proc_stage'
                    , i_column_name   => 'name'
                    , i_object_id     => o_id
                    , i_lang          => i_lang
                    , i_text          => i_name
                    , i_check_unique  => com_api_type_pkg.TRUE
                );

                com_api_i18n_pkg.add_text (
                    i_table_name     => 'opr_proc_stage'
                    , i_column_name  => 'description'
                    , i_object_id    => o_id
                    , i_lang         => i_lang
                    , i_text         => i_description
                );
        end;
    end;

    procedure modify_proc_stage (
        i_id                    in     com_api_type_pkg.t_short_id
        , i_msg_type            in     com_api_type_pkg.t_dict_value
        , i_sttl_type           in     com_api_type_pkg.t_dict_value
        , i_oper_type           in     com_api_type_pkg.t_dict_value
        , i_proc_stage          in     com_api_type_pkg.t_dict_value
        , i_exec_order          in     com_api_type_pkg.t_tiny_id
        , i_parent_stage        in     com_api_type_pkg.t_dict_value
        , i_split_method        in     com_api_type_pkg.t_dict_value
        , i_status              in     com_api_type_pkg.t_dict_value
        , i_lang                in     com_api_type_pkg.t_dict_value
        , i_name                in     com_api_type_pkg.t_name
        , i_description         in     com_api_type_pkg.t_full_desc
        , i_command             in     com_api_type_pkg.t_dict_value    default null
        , i_result_status       in     com_api_type_pkg.t_dict_value    default null
    ) is
        l_proc_stage                   com_api_type_pkg.t_dict_value;
        l_parent_stage                 com_api_type_pkg.t_dict_value;
    begin
        for rec in (select id
                      from opr_proc_stage_vw
                     where msg_type = i_msg_type
                       and sttl_type = i_sttl_type
                       and oper_type = i_oper_type
                       and proc_stage = i_proc_stage
                       and (split_method = i_split_method or (split_method is null and i_split_method is null))
                       and (status = i_status or (status is null and i_status is null))
                       and (command = i_command or (command is null and i_command is null))
                       and (result_status = i_result_status or (result_status is null and i_result_status is null))
        ) loop
            com_api_error_pkg.raise_error(
                i_error      => 'OPR_STAGE_NOT_UNIQUE'
            );
        end loop;  

        begin
            select proc_stage, parent_stage
              into l_proc_stage, l_parent_stage
              from opr_proc_stage_vw
             where proc_stage = nvl(i_proc_stage, proc_stage)
               and parent_stage = nvl(i_parent_stage, parent_stage)
               and id != i_id;

            com_api_error_pkg.raise_error (
                i_error         => 'OPR_STAGE_ALREADY_EXIST'
                , i_env_param1  => i_proc_stage
                , i_env_param2  => i_parent_stage
            );
        exception
            when no_data_found then
                update opr_proc_stage_vw
                   set msg_type = nvl(i_msg_type, msg_type)
                     , sttl_type = nvl(i_sttl_type, sttl_type)
                     , oper_type = nvl(i_oper_type, oper_type)
                     , proc_stage = nvl(i_proc_stage, proc_stage)
                     , exec_order = nvl(i_exec_order, exec_order)
                     , parent_stage = nvl(i_parent_stage, parent_stage)
                     , split_method = nvl(i_split_method, split_method)
                     , status = nvl(i_status, status)
                     , command = nvl(i_command, command)
                     , result_status = nvl(i_result_status, result_status)
                 where id = i_id;
                
                com_api_i18n_pkg.add_text (
                    i_table_name      => 'opr_proc_stage'
                    , i_column_name   => 'name'
                    , i_object_id     => i_id
                    , i_lang          => i_lang
                    , i_text          => i_name
                    , i_check_unique  => com_api_type_pkg.TRUE
                );

                com_api_i18n_pkg.add_text (
                    i_table_name     => 'opr_proc_stage'
                    , i_column_name  => 'description'
                    , i_object_id    => i_id
                    , i_lang         => i_lang
                    , i_text         => i_description
                );
        end;
    end;

    procedure remove_proc_stage (
        i_id                    in     com_api_type_pkg.t_short_id
    ) is
    begin
        delete from opr_proc_stage_vw
         where id = i_id;

        com_api_i18n_pkg.remove_text (
            i_table_name   => 'opr_proc_stage'
            , i_object_id  => i_id
        );
    end;

end;
/
