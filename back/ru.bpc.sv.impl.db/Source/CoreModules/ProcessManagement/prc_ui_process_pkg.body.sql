create or replace package body prc_ui_process_pkg as
/************************************************************
 * UI for processes <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 02.10.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: prc_ui_process_pkg <br />
 * @headcom
 ************************************************************/

procedure check_unique_order(
    i_container_id  in     com_api_type_pkg.t_short_id
  , i_exec_order    in     com_api_type_pkg.t_tiny_id
  , i_id            in     com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select 1
          from prc_container_vw
         where container_process_id = i_container_id
           and exec_order           = i_exec_order
           and id                  != nvl(i_id, 0)
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'EXEC_ORDER_ALREADY_EXIST'
          , i_env_param1 => i_exec_order
          , i_env_param2 => i_container_id
        );
    end loop;
end check_unique_order;

procedure check_unique_description(
    i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_object_id     in     com_api_type_pkg.t_long_id
  , i_text          in     com_api_type_pkg.t_text
) is
    l_count                com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text          => 'check_unique_description: i_inst_id [#1] i_object_id [#2] i_text [#3]'
      , i_env_param1    => i_inst_id  
      , i_env_param2    => i_object_id  
      , i_env_param3    => i_text  
    );

    if i_text is null then
        return;
    end if;

    select count(1)
      into l_count
      from com_i18n t
         , prc_container c
         , prc_process p
     where t.table_name  = 'PRC_CONTAINER'
       and t.column_name = 'DESCRIPTION'
       and t.text        = i_text
       and t.object_id  != nvl(i_object_id, 0)
       and c.id          = t.object_id
       and p.id          = c.container_process_id
       and p.inst_id     = i_inst_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'DESCRIPTION_IS_NOT_UNIQUE'
          , i_env_param1  => 'PRC_CONTAINER'
          , i_env_param2  => 'DESCRIPTION'
          , i_env_param3  => i_text
        );
    end if;
end check_unique_description;

procedure add_process(
    o_id                    out com_api_type_pkg.t_short_id
  , i_procedure_name      in    com_api_type_pkg.t_name
  , i_is_parallel         in    com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_is_external         in    com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_is_container        in    com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_inst_id             in    com_api_type_pkg.t_inst_id
  , i_proc_short_desc     in    com_api_type_pkg.t_short_desc
  , i_proc_full_desc      in    com_api_type_pkg.t_full_desc
  , i_lang                in    com_api_type_pkg.t_dict_value
  , i_interrupt_threads   in    com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_count               pls_integer;
begin
    trc_log_pkg.debug('add_process');
    o_id := prc_process_seq.nextval;

    if i_is_container = com_api_type_pkg.FALSE then

        select count(id)
          into l_count
          from prc_process_vw
         where procedure_name = upper(i_procedure_name)
           and is_container   = com_api_type_pkg.FALSE;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'PROCEDURE_NAME_ALREADY_USED'
              , i_env_param1 => upper(i_procedure_name)
            );
        end if;

    end if;

    insert into prc_process_vw (
        id
      , procedure_name
      , is_parallel
      , inst_id
      , is_external
      , is_container
      , interrupt_threads
    ) values (
        o_id
      , decode(i_is_external, com_api_type_pkg.TRUE, i_procedure_name, upper(i_procedure_name))
      , i_is_parallel
      , i_inst_id
      , i_is_external
      , i_is_container
      , i_interrupt_threads
    );

    for rec in (
        select a.id
          from prc_process_vw a
             , com_i18n b
         where a.id         = b.object_id
           and a.inst_id    in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
           and b.table_name = 'PRC_PROCESS'
           and b.text       = i_proc_short_desc
           and b.lang       = i_lang
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'PROCESS_NAME_ALREADY_USED'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_proc_short_desc
        );
    end loop;

    -- add/modify descriptions
    com_api_i18n_pkg.add_text(
        i_table_name     => 'prc_process'
        , i_column_name  => 'name'
        , i_object_id    => o_id
        , i_text         => i_proc_short_desc
        , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name     => 'prc_process'
        , i_column_name  => 'description'
        , i_object_id    => o_id
        , i_text         => i_proc_full_desc
        , i_lang         => i_lang
    );

end add_process;

procedure modify_process(
    i_id                  in com_api_type_pkg.t_short_id
  , i_procedure_name      in com_api_type_pkg.t_name
  , i_is_parallel         in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_is_external         in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_is_container        in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_proc_short_desc     in com_api_type_pkg.t_short_desc
  , i_proc_full_desc      in com_api_type_pkg.t_full_desc
  , i_lang                in com_api_type_pkg.t_dict_value
  , i_interrupt_threads   in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_count               pls_integer;
    l_procedure_name      com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text          => 'modify_process [#1]'
      , i_env_param1    => i_id
    );

    --check if in progress
    select count(1)
      into l_count
      from prc_session
     where process_id = i_id
       and result_code = prc_api_const_pkg.PROCESS_RESULT_IN_PROGRESS;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error         =>  'PROCESS_IS_IN_PROGRESS'
          , i_env_param1    =>  i_id
        );
    end if;

    for r in (
        select procedure_name
             , is_parallel
             , is_external
             , is_container
             , inst_id
          from prc_process_vw
         where id = i_id
    ) loop
        -- check if used
        for r2 in (
            select container_process_id
                 , com_api_i18n_pkg.get_text('prc_process', 'name', i_id, get_user_lang) process_name
                 , com_api_i18n_pkg.get_text('prc_process', 'name', container_process_id, get_user_lang) container_name
              from prc_container_vw
             where process_id = i_id
        ) loop
            if i_procedure_name  != r.procedure_name
               or i_is_parallel  != r.is_parallel
               or i_is_external  != r.is_external
               or i_is_container != r.is_container
            then
                com_api_error_pkg.raise_error(
                    i_error      => 'PROCESS_ALREADY_USED'
                  , i_env_param1 => i_id
                  , i_env_param2 => r2.container_process_id
                  , i_env_param3 => r2.process_name
                  , i_env_param4 => r2.container_name
                );
            end if;
        end loop;

        for rec in (
            select a.id
              from prc_process_vw a
                 , com_i18n_vw b
             where a.id         = b.object_id
               and a.inst_id    in (r.inst_id, ost_api_const_pkg.DEFAULT_INST)
               and b.table_name = 'PRC_PROCESS'
               and b.text       = i_proc_short_desc
               and b.lang       = i_lang
               and a.id        != i_id
        ) loop
            com_api_error_pkg.raise_error(
                i_error      => 'PROCESS_NAME_ALREADY_USED'
              , i_env_param1 => r.inst_id
              , i_env_param2 => i_proc_short_desc
            );
        end loop;

        trc_log_pkg.debug('i_procedure_name='||i_procedure_name||', i_is_parallel='||i_is_parallel||
                          ', i_is_container='||i_is_container||', i_is_external='||i_is_external);

        if i_is_container = com_api_type_pkg.FALSE then

            select count(id)
              into l_count
              from prc_process_vw
             where procedure_name = upper(i_procedure_name)
               and is_container   = com_api_type_pkg.FALSE
               and id             != i_id;

            if l_count > 0 then
                com_api_error_pkg.raise_error(
                    i_error      => 'PROCEDURE_NAME_ALREADY_USED'
                  , i_env_param1 => upper(i_procedure_name)
                );
            end if;
        end if;

        select procedure_name
          into l_procedure_name
          from prc_process_vw
         where id = i_id;

        update prc_process_vw
           set procedure_name = i_procedure_name
             , is_parallel    = i_is_parallel
             , is_external    = i_is_external
             , is_container   = i_is_container
             , interrupt_threads = i_interrupt_threads
         where id             = i_id;

        -- add/modify descriptions
        com_api_i18n_pkg.add_text(
            i_table_name     => 'prc_process'
            , i_column_name  => 'name'
            , i_object_id    => i_id
            , i_text         => i_proc_short_desc
            , i_lang         => i_lang
        );

        if i_proc_full_desc is null then
            com_api_i18n_pkg.remove_text(
                i_table_name   => 'prc_process'
              , i_column_name  => 'description'
              , i_object_id    => i_id
              , i_lang         => i_lang
            );
        else
            com_api_i18n_pkg.add_text(
                i_table_name   => 'prc_process'
              , i_column_name  => 'description'
              , i_object_id    => i_id
              , i_text         => i_proc_full_desc
              , i_lang         => i_lang
            );
        end if;

        -- update evt subscribers
        update evt_ui_subscriber_vw
           set procedure_name = i_procedure_name
        where  upper(procedure_name)  = upper(l_procedure_name);

    end loop;

/*exception
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
*/
end modify_process;

procedure check_process_using(
    i_id                  in com_api_type_pkg.t_short_id
) is
begin
    -- check if used
    for rec in (
        select container_process_id
             , com_api_i18n_pkg.get_text('prc_process', 'name', i_id, get_user_lang) process_name
             , com_api_i18n_pkg.get_text('prc_process', 'name', container_process_id, get_user_lang) container_name
         from prc_container_vw
        where process_id = i_id)
    loop
        com_api_error_pkg.raise_error(
            i_error      => 'PROCESS_ALREADY_USED'
          , i_env_param1 => i_id
          , i_env_param2 => rec.container_process_id
          , i_env_param3 => rec.process_name
          , i_env_param4 => rec.container_name
        );
    end loop;

    -- check if schedule
    for q in (
        select d.name as task_label
          from prc_ui_task_vw d
         where d.process_id = i_id
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'REMOVE_SCHEDULE_CONTAINER'
          , i_env_param1 => i_id
          , i_env_param2 => q.task_label
        );
    end loop;
end check_process_using;

procedure remove_process(
    i_id                  in com_api_type_pkg.t_short_id
) is
    l_count                  com_api_type_pkg.t_count := 0;
    
    l_container_id_tab       com_api_type_pkg.t_number_tab;
begin
    trc_log_pkg.debug(
        i_text          => 'remove_process [#1]'
      , i_env_param1    => i_id
    );
    check_process_using(i_id  => i_id);

    --check if in progress
    select count(1)
      into l_count
      from prc_session
     where process_id = i_id
       and result_code = prc_api_const_pkg.PROCESS_RESULT_IN_PROGRESS;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error         =>  'PROCESS_IS_IN_PROGRESS'
          , i_env_param1    =>  i_id
        );
    end if;

    -- remove from group
    delete prc_group_process_vw
     where process_id = i_id;

    -- remove process parameters
    delete prc_process_parameter_vw
     where process_id = i_id;

    -- remove process parameters value
    delete prc_parameter_value_vw
     where container_id in
       (select id
          from prc_container_vw
         where container_process_id = i_id
            or process_id           = i_id
       );

    -- remove process file attributes
    delete prc_file_attribute_vw
     where container_id in
       (select id
          from prc_container_vw
         where container_process_id = i_id
            or process_id           = i_id
       );

    -- remove containers
    delete prc_container_vw
     where container_process_id = i_id
        or process_id           = i_id
    returning id 
      bulk collect
      into l_container_id_tab;

    -- remove process
    com_api_i18n_pkg.remove_text(
        i_table_name   => 'prc_process'
      , i_object_id    => i_id
    );
    
    -- remove text records linked with container
    if l_container_id_tab.count > 0 then
        for i in l_container_id_tab.first .. l_container_id_tab.last
        loop
            com_api_i18n_pkg.remove_text(
                i_table_name   => 'prc_container'
              , i_object_id    => l_container_id_tab(i)
            );
        end loop;
    end if;
    
    delete prc_file_vw
     where process_id = i_id;

    delete prc_process_vw
     where id         = i_id;

    -- remove process from role
    delete acm_role_process_vw
     where object_id = i_id;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );

end remove_process;

procedure add_process_to_container(
    io_id                   in out com_api_type_pkg.t_short_id
  , i_container_process_id  in     com_api_type_pkg.t_short_id
  , i_process_id            in     com_api_type_pkg.t_short_id
  , i_exec_order            in     com_api_type_pkg.t_tiny_id
  , i_is_parallel           in     com_api_type_pkg.t_boolean
  , i_error_limit           in     com_api_type_pkg.t_tiny_id
  , i_track_threshold       in     com_api_type_pkg.t_long_id
  , i_force                 in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_parallel_degree       in     com_api_type_pkg.t_tiny_id     default null
  , i_proc_cont_desc        in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_stop_on_fatal         in     com_api_type_pkg.t_boolean     default null
  , i_trace_level           in     com_api_type_pkg.t_short_id    default null
  , i_debug_writing_mode    in     com_api_type_pkg.t_dict_value  default null
  , i_start_trace_size      in     com_api_type_pkg.t_short_id    default null
  , i_error_trace_size      in     com_api_type_pkg.t_short_id    default null
  , i_max_duration          in     com_api_type_pkg.t_short_id    default null
  , i_min_speed             in     com_api_type_pkg.t_long_id     default null
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_process_to_container: ';
    l_count                        com_api_type_pkg.t_count := 0;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_process_desc                 com_api_type_pkg.t_full_desc;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'io_id [' || io_id || '], i_container_process_id [' || i_container_process_id
                             || '], i_process_id [' || i_process_id || '], i_exec_order [' || i_exec_order || ']'
    );

    if i_process_id = i_container_process_id then
        com_api_error_pkg.raise_error(
            i_error      => 'CONTAINER_EQUAL_TO_PROCESS'
          , i_env_param1 => i_process_id
        );
    end if;

    declare
        l_id    com_api_type_pkg.t_short_id;
    begin
        select id
             , inst_id
          into l_id
             , l_inst_id
          from prc_process_vw
         where id           = i_container_process_id
           and is_container = com_api_type_pkg.TRUE;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'CONTAINER_NOT_FOUND'
              , i_env_param1 => i_container_process_id
            );
    end;

    -- Check if process in progress
    select count(1)
      into l_count
      from prc_session
     where process_id = i_container_process_id
       and result_code = prc_api_const_pkg.PROCESS_RESULT_IN_PROGRESS;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error         =>  'PROCESS_IS_IN_PROGRESS'
          , i_env_param1    =>  i_container_process_id
        );
    end if;

    l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());

    check_unique_description(
        i_inst_id       => l_inst_id
      , i_object_id     => io_id
      , i_text          => i_proc_cont_desc
    );

    if io_id is not null then -- update
        declare
            l_id    com_api_type_pkg.t_short_id;
        begin
            select id
              into l_id
              from prc_container_vw
             where id                   = io_id
               and container_process_id = i_container_process_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'CONTAINER_ELEMENT_DOES_NOT_EXIST'
                  , i_env_param1 => i_container_process_id
                  , i_env_param2 => io_id
                );
        end;

        check_unique_order(
            i_container_id => i_container_process_id
          , i_exec_order   => i_exec_order
          , i_id           => io_id
        );

        update prc_container_vw
           set process_id         = nvl(i_process_id,      process_id)
             , exec_order         = nvl(i_exec_order,      exec_order)
             , is_parallel        = nvl(i_is_parallel,     is_parallel)
             , error_limit        = nvl(i_error_limit,     error_limit)
             , track_threshold    = nvl(i_track_threshold, track_threshold)
             , stop_on_fatal      = nvl(i_stop_on_fatal,   stop_on_fatal)
             , parallel_degree    = i_parallel_degree
             , trace_level        = i_trace_level
             , debug_writing_mode = i_debug_writing_mode
             , start_trace_size   = i_start_trace_size
             , error_trace_size   = i_error_trace_size
             , max_duration       = i_max_duration
             , min_speed          = i_min_speed
         where id                 = io_id;

    else -- insert
        io_id := prc_container_seq.nextval;

        check_unique_order(
            i_container_id => i_container_process_id
          , i_exec_order   => i_exec_order
          , i_id           => io_id
        );

        insert into prc_container_vw(
            id
          , container_process_id
          , process_id
          , exec_order
          , is_parallel
          , error_limit
          , track_threshold
          , parallel_degree
          , stop_on_fatal
          , trace_level
          , debug_writing_mode
          , start_trace_size
          , error_trace_size
          , max_duration
          , min_speed
        ) values (
            io_id
          , i_container_process_id
          , i_process_id
          , i_exec_order
          , i_is_parallel
          , i_error_limit
          , i_track_threshold
          , i_parallel_degree
          , i_stop_on_fatal
          , i_trace_level
          , i_debug_writing_mode
          , i_start_trace_size
          , i_error_trace_size
          , i_max_duration
          , i_min_speed
        );

      add_file_attributes(
          i_container_id => io_id
        , i_process_id   => i_process_id
      );

        --prc_ui_parameter_pkg.sync_container_parameters(
        --    i_container_process_id  => i_container_process_id
        --  , i_process_id            => i_process_id
        --);
    end if;

    l_process_desc := com_api_i18n_pkg.get_text('prc_process', 'description', i_process_id, get_user_lang);
    if i_proc_cont_desc is not null then
        if l_process_desc is null or i_proc_cont_desc != l_process_desc then
            com_api_i18n_pkg.add_text(
                i_table_name   => 'prc_container'
              , i_column_name  => 'description'
              , i_object_id    => io_id
              , i_text         => i_proc_cont_desc
              , i_lang         => l_lang
              , i_check_unique => com_api_type_pkg.FALSE
            );
        end if;
    else
        com_api_i18n_pkg.remove_text(
            i_table_name   => 'prc_container'
          , i_column_name  => 'description'
          , i_object_id    => io_id
          , i_lang         => i_lang
        );
    end if;

    -- Check for cycle
    select count(1)
      into l_count
      from (select connect_by_iscycle c, c.*
              from prc_ui_container_process_vw c
           connect by nocycle prior c.process_id = c.container_process_id
                          and prior c.lang       = c.lang)
     where c = com_api_type_pkg.TRUE;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'PRC_CYCLIC_TREE_FOUND'
          , i_env_param1  => 'CONTAINER_PROCESS_ID'
          , i_env_param2  => 'PROCESS_ID'
        );
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end add_process_to_container;

procedure add_file_attributes(
    i_container_id          in     com_api_type_pkg.t_short_id
  , i_process_id            in     com_api_type_pkg.t_short_id
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_file_attributes: ';
    l_file_attribute_id            com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_container_id [' || i_container_id || '], i_process_id [' || i_process_id || ']'
    );
    for rec in (
        select nvl(fa.file_id, f.id) file_id
             , fa.characterset
             , fa.file_name_mask
             , fa.name_format_id
             , fa.upload_empty_file
             , fa.location_id
             , fa.xslt_source
             , fa.converter_class
             , fa.is_tar
             , fa.is_zip
             , nvl(fa.inst_id, p.inst_id) inst_id
             , fa.report_id
             , fa.report_template_id
             , fa.load_priority
             , fa.sign_transfer_type
             , fa.encrypt_plugin
             , fa.ignore_file_errors
             , fa.parallel_degree
             , fa.is_file_name_unique
             , fa.is_file_required
             , fa.queue_identifier
             , fa.time_out
             , fa.line_separator
             , fa.password_protect
             , fa.is_cleanup_data
          from (select nvl(c.id, i_process_id) process_id
                  from prc_container c
                     , (select i_process_id container_process_id from dual) d
                 where c.container_process_id(+) = d.container_process_id
               ) res
             , prc_file_attribute fa
             , prc_file f
             , prc_process p
         where res.process_id = fa.container_id(+)
           and res.process_id = f.process_id(+)
           and res.process_id = p.id(+)
    ) loop
        prc_ui_file_pkg.add_file_attribute(
            o_id => l_file_attribute_id
          , i_file_id => rec.file_id
          , i_container_id => i_container_id
          , i_characterset => nvl(rec.characterset, 'UTF-8')
          , i_file_name_mask => rec.file_name_mask
          , i_name_format_id => rec.name_format_id
          , i_upload_empty_file => nvl(rec.upload_empty_file, com_api_const_pkg.FALSE)
          , i_location_id => rec.location_id
          , i_xslt_source => rec.xslt_source
          , i_converter_class => rec.converter_class
          , i_is_tar => nvl(rec.is_tar, com_api_const_pkg.FALSE)
          , i_is_zip => nvl(rec.is_zip, com_api_const_pkg.FALSE)
          , i_inst_id => rec.inst_id
          , i_report_id => rec.report_id
          , i_report_template_id => rec.report_template_id
          , i_load_priority => rec.load_priority
          , i_sign_transfer_type => rec.sign_transfer_type
          , i_encrypt_plugin => rec.encrypt_plugin
          , i_ignore_file_errors => nvl(rec.ignore_file_errors, com_api_const_pkg.FALSE)
          , i_parallel_degree => rec.parallel_degree
          , i_is_file_name_unique => nvl(rec.is_file_name_unique, com_api_const_pkg.TRUE)
          , i_is_file_required => rec.is_file_required
          , i_queue_identifier => rec.queue_identifier
          , i_time_out => rec.time_out
          , i_line_separator => nvl(rec.line_separator, 'OS-defined')
          , i_password_protect => nvl(rec.password_protect, com_api_const_pkg.FALSE)
          , i_is_cleanup_data => nvl(rec.is_cleanup_data, com_api_const_pkg.FALSE)
        );
    end loop;
    trc_log_pkg.debug(LOG_PREFIX || 'END');
end add_file_attributes;

procedure remove_process_from_container(
    i_id    in                  com_api_type_pkg.t_short_id
) is
    l_count                     com_api_type_pkg.t_count := 0;
    l_container_process_id      com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text          => 'remove_process_from_container [#1]'
      , i_env_param1    => i_id
    );

    --check if in progress
    select count(1)
      into l_count
      from prc_session s
         , prc_container c
     where c.id = i_id
       and s.process_id = c.container_process_id
       and s.result_code = prc_api_const_pkg.PROCESS_RESULT_IN_PROGRESS;

    if l_count > 0 then
        select container_process_id
          into l_container_process_id
          from prc_container
         where id = i_id;

        com_api_error_pkg.raise_error(
            i_error         => 'PROCESS_IS_IN_PROGRESS'
          , i_env_param1    => i_id
        );

    end if;

    prc_ui_parameter_pkg.remove_container_parameters(
        i_container_id        => i_id
    );

    delete prc_container_vw
     where id = i_id;
    
    -- remove text record linked with container
    com_api_i18n_pkg.remove_text(
        i_table_name   => 'prc_container'
      , i_object_id    => i_id
    );

end remove_process_from_container;

end prc_ui_process_pkg;
/
