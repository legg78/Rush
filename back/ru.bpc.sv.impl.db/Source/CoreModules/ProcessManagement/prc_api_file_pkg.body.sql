create or replace package body prc_api_file_pkg is
/************************************************************
 * API for process files <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.11.2009 <br />
 * Module: prc_api_file_pkg <br />
 * @headcom
 ***********************************************************/

g_sess_file_id          com_api_type_pkg.t_long_id;
g_sess_file_rec_count   prc_api_type_pkg.t_sess_file_rec_count_tab;
g_row_count             com_api_type_pkg.t_long_id := 0;
g_file_count            com_api_type_pkg.t_long_id := 0;
g_file_password         com_api_type_pkg.t_dict_value;

function get_event_type(
    i_status        in      com_api_type_pkg.t_dict_value
  , i_file_purpose  in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value
is
    l_event_type com_api_type_pkg.t_dict_value;
begin
    l_event_type := case
                        when i_file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
                             and i_status in (prc_api_const_pkg.FILE_STATUS_ACCEPTED)
                            then prc_api_const_pkg.EVENT_TYPE_FILE_PROCESSED
                        when i_file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
                             and i_status in (prc_api_const_pkg.FILE_STATUS_REJECTED)
                            then prc_api_const_pkg.EVENT_TYPE_FILE_FAIL_PROCESS
                        when i_file_purpose = prc_api_const_pkg.FILE_PURPOSE_OUT
                             and i_status in (prc_api_const_pkg.FILE_STATUS_ACCEPTED)
                            then prc_api_const_pkg.EVENT_TYPE_FILE_GENERATED
                        when i_file_purpose = prc_api_const_pkg.FILE_PURPOSE_OUT
                             and i_status in (prc_api_const_pkg.FILE_STATUS_REJECTED)
                            then prc_api_const_pkg.EVENT_TYPE_FILE_FAIL_GENERATE
                    end;
                    
    if l_event_type is null then
        com_api_error_pkg.raise_error(
            i_error      => 'EVENT_TYPE_NOT_FOUND_FOR_FILE_SETS'
          , i_env_param1 => i_file_purpose
          , i_env_param2 => i_status
        );
    end if;
    
    return l_event_type;
end get_event_type;

function get_default_file_name_params(
    i_file_type     in      com_api_type_pkg.t_dict_value default null
  , i_file_purpose  in      com_api_type_pkg.t_dict_value default null
  , io_params       in out nocopy com_api_type_pkg.t_param_tab
) return rul_api_type_pkg.t_param_tab is
    l_container_id          com_api_type_pkg.t_short_id;
    l_session_id            com_api_type_pkg.t_long_id;
    l_process_id            com_api_type_pkg.t_short_id;
    l_file_attr_id          com_api_type_pkg.t_short_id;
    l_file_purpose          com_api_type_pkg.t_dict_value;
    l_name_format_id        com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_file_inst_id          com_api_type_pkg.t_inst_id;
    l_original_file_name    com_api_type_pkg.t_name;
    l_file_name             rul_api_type_pkg.t_param_tab;
begin
    l_container_id := prc_api_session_pkg.get_container_id;
    l_session_id   := prc_api_session_pkg.get_session_id;
    l_process_id   := prc_api_session_pkg.get_process_id;
--    trc_log_pkg.info('container_id='||l_container_id ||', session_id='||l_session_id||', process_id='||l_process_id);
    -- check session
    if l_session_id is null then
        com_api_error_pkg.raise_error (
            i_error  => 'SESSION_NOT_FOUND'
        );
    end if;

    begin
        select a.id
             , f.file_purpose
             , a.name_format_id
             , a.inst_id
          into l_file_attr_id
             , l_file_purpose
             , l_name_format_id
             , l_file_inst_id
          from prc_file_attribute a
             , prc_file f
         where a.container_id  = l_container_id
           and f.process_id    = l_process_id
           and f.id            = a.file_id
           and (f.file_type    = i_file_type    or i_file_type is null)
           and (f.file_purpose = i_file_purpose or i_file_purpose is null) ;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'FILE_ATTRIBUTE_NOT_FOUND'
                , i_env_param1  => i_file_type
                , i_env_param2  => prc_api_session_pkg.get_process_id
            );
        when too_many_rows then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_MANY_FILES_FOUND'
              , i_env_param1 => i_file_type
              , i_env_param2 => i_file_purpose
              , i_env_param3 => l_session_id
              , i_env_param4 => l_process_id
            );
    end;
    -- name patterns
    l_inst_id := rul_api_param_pkg.get_param_num (
        i_name          => 'INST_ID'
        , io_params     => io_params
        , i_mask_error  => com_api_type_pkg.TRUE
    );

    rul_api_param_pkg.set_param (
        i_name     => 'INST_ID'
      , i_value    => nvl(l_inst_id, l_file_inst_id)
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'SYS_DATE'
      , i_value    => com_api_sttl_day_pkg.get_sysdate
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'FILE_PURPOSE'
      , i_value    => l_file_purpose
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'PROCESS_ID'
      , i_value    => prc_api_session_pkg.get_process_id
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'SESSION_ID'
      , i_value    => get_session_id
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'FILE_TYPE'
      , i_value    => i_file_type
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'THREAD_NUMBER'
      , i_value    => get_thread_number
      , io_params  => io_params
    );

    select min(s.file_name)
      into l_original_file_name
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
     where s.session_id   = get_session_id
       and a.file_id      = f.id
       and s.file_attr_id = a.id
       and (s.file_type = i_file_type or i_file_type is null)
       and (f.file_purpose = i_file_purpose or i_file_purpose is null);

    rul_api_param_pkg.set_param (
        i_name     => 'ORIGINAL_FILE_NAME'
      , i_value    => l_original_file_name
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param (
        i_name     => 'TIMESTAMP'
      , i_value    => to_char(systimestamp, 'ffff')
      , io_params  => io_params
    );

    rul_api_param_pkg.set_param (
        i_name     => 'FILE_ATTR_ID'
      , i_value    => l_file_attr_id
      , io_params  => io_params
    );

    l_file_name := rul_api_name_pkg.get_params_name (
        i_format_id    => l_name_format_id
        , i_param_tab  => io_params
    );

    return l_file_name;
end;

function get_default_file_name(
    i_file_type     in      com_api_type_pkg.t_dict_value default null
  , i_file_purpose  in      com_api_type_pkg.t_dict_value default null
  , io_params       in out nocopy com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_name is
    l_file_name             com_api_type_pkg.t_name;
    l_params                rul_api_type_pkg.t_param_tab;
begin
    l_params := get_default_file_name_params(
        i_file_type     => i_file_type
      , i_file_purpose  => i_file_purpose
      , io_params       => io_params
    );

    for i in 1 .. l_params.count loop
        l_file_name := l_file_name || l_params(i).param_value;
    end loop;

    return l_file_name;
end;

procedure set_session_file_id (
    i_sess_file_id          in      com_api_type_pkg.t_long_id
) is
begin
    g_sess_file_id := i_sess_file_id;
end;

function get_session_file_id return com_api_type_pkg.t_long_id is
begin
    return g_sess_file_id;
end;

procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_file_type             in      com_api_type_pkg.t_dict_value   default null
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , i_no_session_id         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.false
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_report_id             com_api_type_pkg.t_short_id;
    l_report_template_id    com_api_type_pkg.t_short_id;
begin
    open_file (
        o_sess_file_id          => o_sess_file_id
      , i_file_name             => i_file_name
      , i_file_type             => i_file_type
      , i_file_purpose          => i_file_purpose
      , io_params               => l_params
      , o_report_id             => l_report_id
      , o_report_template_id    => l_report_template_id
      , i_no_session_id         => i_no_session_id
      , i_object_id             => i_object_id
      , i_entity_type           => i_entity_type
    );
end;

procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_file_type             in      com_api_type_pkg.t_dict_value   default null
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , io_params               in out  com_api_type_pkg.t_param_tab
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
) is
    l_report_id             com_api_type_pkg.t_short_id;
    l_report_template_id    com_api_type_pkg.t_short_id;
begin
    open_file (
        o_sess_file_id          => o_sess_file_id
      , i_file_name             => i_file_name
      , i_file_type             => i_file_type
      , i_file_purpose          => i_file_purpose
      , io_params               => io_params
      , o_report_id             => l_report_id
      , o_report_template_id    => l_report_template_id
      , i_object_id             => i_object_id
      , i_entity_type           => i_entity_type
    );
end;

procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , io_params               in out  com_api_type_pkg.t_param_tab
  , o_report_id                out  com_api_type_pkg.t_short_id
  , o_report_template_id       out  com_api_type_pkg.t_short_id
  , i_no_session_id         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.false
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
) is
    l_file_name                     com_api_type_pkg.t_name := i_file_name;
begin
    open_file (
        o_sess_file_id       => o_sess_file_id
      , io_file_name         => l_file_name
      , i_file_type          => i_file_type
      , i_file_purpose       => i_file_purpose
      , io_params            => io_params
      , o_report_id          => o_report_id
      , o_report_template_id => o_report_template_id
      , i_no_session_id      => i_no_session_id
      , i_object_id          => i_object_id
      , i_entity_type        => i_entity_type
    );
end open_file;

procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , io_file_name            in out  com_api_type_pkg.t_name
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , i_no_session_id         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.false
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
) is
    l_report_id                     com_api_type_pkg.t_short_id     := null;
    l_report_template_id            com_api_type_pkg.t_short_id     := null;
    l_params                        com_api_type_pkg.t_param_tab;
begin
    open_file (
        o_sess_file_id       => o_sess_file_id
      , io_file_name         => io_file_name
      , i_file_type          => i_file_type
      , i_file_purpose       => i_file_purpose
      , io_params            => l_params
      , o_report_id          => l_report_id
      , o_report_template_id => l_report_template_id
      , i_no_session_id      => i_no_session_id
      , i_object_id          => i_object_id
      , i_entity_type        => i_entity_type
    );
end open_file;

procedure open_file (
    o_sess_file_id             out  com_api_type_pkg.t_long_id
  , io_file_name            in out  com_api_type_pkg.t_name
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value   default null
  , io_params               in out  com_api_type_pkg.t_param_tab
  , o_report_id                out  com_api_type_pkg.t_short_id
  , o_report_template_id       out  com_api_type_pkg.t_short_id
  , i_no_session_id         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.false
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_entity_type           in      com_api_type_pkg.t_dict_value   default null
) is
    l_file_attr_id          com_api_type_pkg.t_short_id;
    l_file_purpose          com_api_type_pkg.t_dict_value;
    l_name_format_id        com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_file_name             com_api_type_pkg.t_name;
    l_container_id          com_api_type_pkg.t_short_id;
    l_session_id            com_api_type_pkg.t_long_id;
    l_process_id            com_api_type_pkg.t_short_id;
    l_container_process_id  com_api_type_pkg.t_short_id;
    l_original_file_name    com_api_type_pkg.t_name;
    l_file_inst_id          com_api_type_pkg.t_inst_id;
    l_count                 com_api_type_pkg.t_count := 0;
    l_is_file_name_unique   com_api_type_pkg.t_boolean;
    l_queue_identifier      com_api_type_pkg.t_name;
    l_location_id           com_api_type_pkg.t_tiny_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_file_number           com_api_type_pkg.t_long_id;
begin

    l_container_id := prc_api_session_pkg.get_container_id;
    if i_no_session_id  = com_api_const_pkg.false then
        l_session_id := prc_api_session_pkg.get_session_id;
    end if;
    l_process_id := prc_api_session_pkg.get_process_id;
    --trc_log_pkg.info('container_id='||l_container_id ||', session_id='||l_session_id||', process_id='||l_process_id);
    -- check session
    if l_session_id is null and i_no_session_id = com_api_const_pkg.false  then
        com_api_error_pkg.raise_error (
            i_error  => 'SESSION_NOT_FOUND'
        );
    end if;

    begin
        select a.id
             , f.file_purpose
             , a.name_format_id
             , a.inst_id
             , a.report_id
             , a.report_template_id
             , nvl(a.is_file_name_unique, com_api_const_pkg.TRUE)
             , a.queue_identifier
             , a.location_id
             , f.file_type             
          into l_file_attr_id
             , l_file_purpose
             , l_name_format_id
             , l_file_inst_id
             , o_report_id
             , o_report_template_id
             , l_is_file_name_unique
             , l_queue_identifier
             , l_location_id
             , l_file_type
          from prc_file_attribute a
             , prc_file f
         where a.container_id  = l_container_id
           and f.id            = a.file_id
           and (f.file_type    = i_file_type    or i_file_type is null)
           and (f.file_purpose = i_file_purpose or i_file_purpose is null) ;
    exception
        when too_many_rows then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_MANY_FILES_FOUND'
              , i_env_param1 => i_file_type
              , i_env_param2 => i_file_purpose
              , i_env_param3 => l_session_id
              , i_env_param4 => l_process_id
            );
    end;

    -- format file name
    if l_location_id is not null then

        if io_file_name is null then
            if l_name_format_id is null then
                select container_process_id
                  into l_container_process_id
                  from prc_container
                 where id = l_container_id;

                com_api_error_pkg.raise_error(
                    i_error         => 'FILE_NAME_ALGORITHM_IS_REQUIRED'
                  , i_env_param1    => l_container_process_id
                );
            end if;

            -- name patterns
            l_inst_id := rul_api_param_pkg.get_param_num (
                i_name          => 'INST_ID'
                , io_params     => io_params
                , i_mask_error  => com_api_type_pkg.TRUE
            );

            rul_api_param_pkg.set_param (
                i_name       => 'INST_ID'
                , i_value    => nvl(l_inst_id, l_file_inst_id)
                , io_params  => io_params
            );
            rul_api_param_pkg.set_param (
                i_name       => 'SYS_DATE'
                , i_value    => com_api_sttl_day_pkg.get_sysdate
                , io_params  => io_params
            );
            rul_api_param_pkg.set_param (
                i_name       => 'FILE_PURPOSE'
                , i_value    => l_file_purpose
                , io_params  => io_params
            );
            rul_api_param_pkg.set_param (
                i_name       => 'PROCESS_ID'
                , i_value    => prc_api_session_pkg.get_process_id
                , io_params  => io_params
            );
            rul_api_param_pkg.set_param (
                i_name       => 'SESSION_ID'
                , i_value    => l_session_id
                , io_params  => io_params
            );
            rul_api_param_pkg.set_param (
                i_name       => 'FILE_TYPE'
                , i_value    => nvl(i_file_type, l_file_type)
                , io_params  => io_params
            );
            rul_api_param_pkg.set_param (
                i_name     => 'THREAD_NUMBER'
              , i_value    => get_thread_number
              , io_params  => io_params
            );
            rul_api_param_pkg.set_param (
                i_name     => 'FILE_ATTR_ID'
              , i_value    => l_file_attr_id
              , io_params  => io_params
            );

            g_file_count := nvl(g_file_count, 0) + 1;

            l_file_number := rul_api_param_pkg.get_param_num (
                i_name          => 'FILE_NUMBER'
                , io_params     => io_params
                , i_mask_error  => com_api_type_pkg.TRUE
            );
            rul_api_param_pkg.set_param (
                i_name       => 'FILE_NUMBER'
                , i_value    => nvl(l_file_number, g_file_count)
                , io_params  => io_params
            );

            l_original_file_name :=
                rul_api_param_pkg.get_param_char (
                    i_name            => 'ORIGINAL_FILE_NAME'
                  , io_params         => io_params
                  , i_mask_error      => com_api_type_pkg.TRUE
                  , i_error_value     => null
                );

            if l_original_file_name is null then

                select min(s.file_name)
                  into l_original_file_name
                  from prc_session_file s
                     , prc_file_attribute a
                     , prc_file f
                 where s.session_id   = l_session_id
                   and a.file_id      = f.id
                   and s.file_attr_id = a.id
                   and (s.file_type = i_file_type or i_file_type is null)
                   and (f.file_purpose = i_file_purpose or i_file_purpose is null);

                rul_api_param_pkg.set_param (
                    i_name     => 'ORIGINAL_FILE_NAME'
                  , i_value    => l_original_file_name
                  , io_params  => io_params
                );

            end if;

            rul_api_param_pkg.set_param (
                i_name       => 'TIMESTAMP'
                , i_value    => to_char(systimestamp, 'ffff')
                , io_params  => io_params
            );

            l_file_name := rul_api_name_pkg.get_name (
                i_format_id    => l_name_format_id
                , i_param_tab  => io_params
            );

        else
            l_file_name := io_file_name;
        end if;

        trc_log_pkg.info('Set filename = ' || l_file_name);

        select count(1)
          into l_count
          from prc_session_file
         where session_id = l_session_id
           and upper(file_name) = upper(l_file_name);

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error         => 'FILE_NAME_DUPLICATED_IN_SESSION'
              , i_env_param1    => l_file_name
            );
        end if;


        if l_is_file_name_unique = com_api_const_pkg.TRUE then
            select count(1)
              into l_count
              from prc_session_file
             where decode(status, 'FLSTACPT', upper(file_name), null) = upper(l_file_name);

            if l_count > 0 then
                com_api_error_pkg.raise_error(
                    i_error         => 'FILE_NAME_ALREADY_EXIST'
                  , i_env_param1    => l_file_name
                );
            end if;
        end if;

    else
        l_file_name := io_file_name;
    end if;

    if l_file_name is null
        and l_location_id is null
        and l_queue_identifier is null
    then
        com_api_error_pkg.raise_error (i_error => 'FILE_NAME_AND_FILE_LOCATION_ARE_NULL');
    end if;

    -- insert
    o_sess_file_id :=
        com_api_id_pkg.get_id(
            i_seq  => prc_session_file_seq.nextval
          , i_date => to_date(substr(to_char(l_session_id), 1, 6), 'yymmdd')
        );

    insert into prc_session_file (
        id
        , session_id
        , file_attr_id
        , file_name
        , record_count
        , status
        , file_contents
        , file_bcontents
        , file_date
        , file_type
        , thread_number
        , object_id
        , entity_type
    ) values (
        o_sess_file_id
        , l_session_id
        , l_file_attr_id
        , l_file_name
        , 0
        , null
        , empty_clob()
        , empty_blob()
        , get_sysdate()
        , nvl(i_file_type, l_file_type)
        , get_thread_number
        , i_object_id
        , i_entity_type
    );

    set_session_file_id (
        i_sess_file_id => o_sess_file_id
    );

    io_file_name := l_file_name;

    g_sess_file_rec_count(nvl(g_sess_file_rec_count.last, 0) + 1).session_file_id := o_sess_file_id;
    g_sess_file_rec_count(nvl(g_sess_file_rec_count.last, 0)).record_count        := 0;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error         => 'FILE_ATTRIBUTE_NOT_FOUND'
            , i_env_param1  => i_file_type
            , i_env_param2  => prc_api_session_pkg.get_process_id
        );
end;

procedure set_file_name(
    i_file_name             in      com_api_type_pkg.t_name
  , i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value default null
) is
    l_sess_file_id          com_api_type_pkg.t_long_id;
begin
    -- check session
    if get_session_id is null then
        com_api_error_pkg.raise_error (
            i_error  => 'SESSION_NOT_FOUND'
        );
    end if;

    select min(s.id)
      into l_sess_file_id
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
     where s.session_id = get_session_id
       and a.file_id = f.id
       and s.file_attr_id = a.id
       and (s.file_type = i_file_type or i_file_type is null)
       and (f.file_purpose = i_file_purpose or i_file_purpose is null)
       and (s.id = i_sess_file_id or i_sess_file_id is null);

    update prc_session_file a
       set a.file_name = nvl(i_file_name, a.file_name)
     where a.id        = l_sess_file_id;
end;

procedure close_file(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_record_count          in      com_api_type_pkg.t_medium_id   default null
) is
    l_cleanup_data         com_api_type_pkg.t_boolean;
    l_file_purpose         com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_param_tab            com_api_type_pkg.t_param_tab;
    l_event_type           com_api_type_pkg.t_dict_value;
begin
    update prc_session_file a
       set a.record_count = nvl(i_record_count, g_row_count)
         , a.status       = i_status
     where a.id           = i_sess_file_id;

    if g_sess_file_rec_count.first is not null then
        for l_index in g_sess_file_rec_count.first..g_sess_file_rec_count.last loop
            if g_sess_file_rec_count.exists(l_index) then
                if g_sess_file_rec_count(l_index).session_file_id = i_sess_file_id then
                    g_sess_file_rec_count.delete(l_index);
                    exit;
                end if;
            end if;
        end loop;
    end if;

    begin
        select nvl(a.is_cleanup_data, 0)
             , fl.file_purpose
             , a.inst_id
          into l_cleanup_data
             , l_file_purpose
             , l_inst_id
          from prc_file_attribute a
             , prc_session_file f
             , prc_file fl
         where f.id = i_sess_file_id
           and f.file_attr_id = a.id
           and fl.id = a.file_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'SESSION_FILE_NOT_FOUND'
                , i_env_param1  => i_sess_file_id
            );
    end;

    if l_cleanup_data = com_api_const_pkg.TRUE then

        delete from prc_file_raw_data
         where session_file_id  = i_sess_file_id;

        update prc_session_file a
           set a.file_contents  = null
             , a.file_bcontents = null
         where a.id             = i_sess_file_id;
    end if;

    g_row_count := 0;
    
    l_event_type := get_event_type(
        i_status       => i_status
      , i_file_purpose => l_file_purpose
    );
    
    evt_api_event_pkg.register_event(
        i_event_type  => l_event_type
      , i_eff_date    => com_api_sttl_day_pkg.get_sysdate
      , i_entity_type => prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE
      , i_object_id   => i_sess_file_id
      , i_inst_id     => l_inst_id
      , i_split_hash  => com_api_hash_pkg.get_split_hash(
                             i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION,
                             i_object_id   => l_inst_id
                         )
      , i_param_tab   => l_param_tab
    );

    set_session_file_id (
        i_sess_file_id => null
    );

end;

procedure remove_file(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value default null
) is
    l_sess_file_id          com_api_type_pkg.t_long_id;
begin
    -- check session
    if get_session_id is null then
        com_api_error_pkg.raise_error (
            i_error  => 'SESSION_NOT_FOUND'
        );
    end if;

    select min(s.id)
      into l_sess_file_id
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
     where s.session_id = get_session_id
       and a.file_id = f.id
       and s.file_attr_id = a.id
       and (s.file_type = i_file_type or i_file_type is null)
       and (f.file_purpose = i_file_purpose or i_file_purpose is null)
       and (s.id = i_sess_file_id or i_sess_file_id is null);

    delete from prc_session_file_vw s
     where s.id = l_sess_file_id;
end;

procedure put_line(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_raw_data              in      com_api_type_pkg.t_raw_data
) is
    l_index_gl              com_api_type_pkg.t_short_id;
begin

    for l_index in g_sess_file_rec_count.first..g_sess_file_rec_count.last loop
        if g_sess_file_rec_count.exists(l_index) then
            if g_sess_file_rec_count(l_index).session_file_id = i_sess_file_id then
                g_sess_file_rec_count(l_index).record_count := g_sess_file_rec_count(l_index).record_count + 1;
                l_index_gl := l_index;
                exit;
            end if;
        end if;
    end loop;

    insert into prc_file_raw_data (
        session_file_id
      , record_number
      , raw_data
    ) values (
        i_sess_file_id
      , g_sess_file_rec_count(l_index_gl).record_count
      , i_raw_data
    );
    g_row_count := g_row_count + 1;
end;

procedure put_bulk (
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_raw_tab               in      com_api_type_pkg.t_raw_tab
  , i_num_tab               in      com_api_type_pkg.t_integer_tab
) is
begin
    -- Note that compared with a nested table [see put_bulk_web()] for elements
    -- of associative array <i_raw_tab> data type overflow is impossible.
    forall rec in indices of i_raw_tab
        insert into prc_file_raw_data(
            session_file_id
          , record_number
          , raw_data
        ) values (
            i_sess_file_id
          , i_num_tab(rec)
          , i_raw_tab(rec)
        );

    g_row_count := g_row_count + i_raw_tab.count;
end;

procedure put_bulk_web(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_raw_tab               in      raw_data_tpt
  , i_num_tab               in      num_tab_tpt
) is
    l_index                         pls_integer;
    l_length                        pls_integer;
    --l_raw_tab                       raw_data_tpt := raw_data_tpt();
begin
    -- Nested table i_raw_tab may contain multi-byte strings, so their lengths
    -- may be <= 4000 chars, but > 4000 bytes. In this case a collection is
    -- passed as incoming parameter correctly, but exception ORA-01461 is raise.
    -- The reason is that maximum capacity of a table's column of varchar2 data
    -- type is exactly 4000 bytes regardless multi-byte settings (and even when
    -- column is declared as varchar2(4000 char)).
    l_index := i_raw_tab.first();
    --l_raw_tab := i_raw_tab;
    while l_index is not null loop
        l_length := lengthb(i_raw_tab(l_index).raw_data);
        if l_length > 4000 then
            trc_log_pkg.debug(
                i_text       => lower($$PLSQL_UNIT) || '.put_bulk_web() FAILED '
                             || 'with i_raw_tab.count() = [#1], i_raw_tab(#2) = ['
                             || substrb(i_raw_tab(l_index).raw_data, 1, 3800) || '...]'
              , i_env_param1 => i_raw_tab.count()
              , i_env_param2 => l_index
            );
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_LONG_STRING_FOR_FILE_RAW_DATA'
              , i_env_param1 => i_sess_file_id
              , i_env_param2 => i_num_tab(l_index)
              , i_env_param3 => l_length
            );
            --l_raw_tab(l_index).raw_data := substrb(l_raw_tab(l_index).raw_data, 1, 4000);
        end if;
        l_index := i_raw_tab.next(l_index);
    end loop;

    forall rec in indices of i_raw_tab
        insert into prc_file_raw_data(
            session_file_id
          , record_number
          , raw_data
        ) values (
            i_sess_file_id
          , i_num_tab(rec)
          , i_raw_tab(rec).raw_data
        );

    g_row_count := g_row_count + i_raw_tab.count;
end;

procedure put_bulk_all (
    i_sess_file_tab             in       com_api_type_pkg.t_number_tab
  , i_raw_tab                   in       com_api_type_pkg.t_raw_tab
  , i_num_tab                   in       com_api_type_pkg.t_integer_tab
) is
begin
    -- Note that compared with a nested table [see put_bulk_web()] for elements
    -- of associative array <i_raw_tab> data type overflow is impossible.
    forall rec in indices of i_raw_tab
        insert into prc_file_raw_data(
            session_file_id
          , record_number
          , raw_data
        )
        values (
            i_sess_file_tab(rec)
          , i_num_tab(rec)
          , i_raw_tab(rec)
        );

    g_row_count := g_row_count + i_raw_tab.count;
end;

function get_line (
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_rec_num               in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_raw_data is
    l_raw_data              com_api_type_pkg.t_raw_data;
begin

    select a.raw_data
      into l_raw_data
      from prc_file_raw_data a
     where a.session_file_id = i_sess_file_id
       and a.record_number   = i_rec_num;

    return l_raw_data;

exception
    when no_data_found then
        return null;
end;

/*
 * Put whole file source like CLOB.
 * @param i_sess_file_id  - Session file identifier
 * @param i_clob_content  - File contents
 * @param i_add_to        - Append or rewrite contents
*/
procedure put_file (
    i_sess_file_id          in com_api_type_pkg.t_long_id
  , i_clob_content          in clob
  , i_add_to                in com_api_type_pkg.t_boolean
) is
    l_dest_lob              clob := empty_clob();
    l_file_nature           com_api_type_pkg.t_dict_value;
    l_file_purpose          com_api_type_pkg.t_dict_value;
    l_file_type             com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text          => 'prc_api_file_pkg.put_file (clob): i_sess_file_id [#1], i_add_to [#2]'
      , i_env_param1    => i_sess_file_id
      , i_env_param2    => i_add_to
    );

    if i_add_to = com_api_type_pkg.TRUE then
        select file_contents
          into l_dest_lob
          from prc_session_file
         where id = i_sess_file_id
         for update nowait;

        dbms_lob.append(l_dest_lob, i_clob_content);
    else
        select f.file_nature
             , f.file_purpose
             , f.file_type
          into l_file_nature
             , l_file_purpose
             , l_file_type
          from prc_file_attribute fa
             , prc_file f
             , prc_session_file sf
         where sf.file_attr_id = fa.id
           and fa.file_id = f.id
           and sf.id = i_sess_file_id;

        if l_file_nature = prc_api_const_pkg.FILE_NATURE_XML and l_file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN then
            trc_log_pkg.debug(
                i_text          => 'xml file'
            );

            begin
                update prc_session_file
                   set file_xml_contents = xmltype(i_clob_content)
                 where id = i_sess_file_id;

            exception
                when others then
                    update prc_session_file
                       set file_contents = i_clob_content
                     where id = i_sess_file_id;

                    trc_log_pkg.error(
                        i_text          => sqlerrm
                    );
                    raise;
            end;

        else
            update prc_session_file
               set file_contents = i_clob_content
             where id = i_sess_file_id;

        end if;

    end if;

end;

procedure put_file (
    i_sess_file_id          in com_api_type_pkg.t_long_id
  , i_blob_content          in blob
  , i_add_to                in com_api_type_pkg.t_boolean
) is
    l_dest_lob              blob := empty_blob();
begin
    if i_add_to = com_api_type_pkg.TRUE then
        select file_bcontents
          into l_dest_lob
          from prc_session_file
         where id = i_sess_file_id
         for update nowait;

        dbms_lob.append(l_dest_lob, i_blob_content);
    else
        update prc_session_file
           set file_bcontents = i_blob_content
         where id = i_sess_file_id;
    end if;
end;

function split_clob(
    i_clob                  in      clob
  , i_delim                 in      varchar2 := chr(10)
) return t_varchar2_tab pipelined is
    l_begin                 com_api_type_pkg.t_long_id := 1;
    l_end                   com_api_type_pkg.t_long_id := 1;
begin
    while l_end > 0
    loop
        l_end := dbms_lob.instr(i_clob, i_delim, l_begin);

        if l_end > 0 then
            pipe row(dbms_lob.substr(i_clob, l_end - l_begin, l_begin));
            l_begin := l_end + 1;
        else
            pipe row(dbms_lob.substr(i_clob, dbms_lob.getlength(i_clob) + 1 - l_begin, l_begin));
        end if;
    end loop;
end;

function get_file_purpose_in return com_api_type_pkg.t_dict_value is
begin
    return prc_api_const_pkg.FILE_PURPOSE_IN;
end;

function get_file_purpose_out return com_api_type_pkg.t_dict_value is
begin
    return prc_api_const_pkg.FILE_PURPOSE_OUT;
end;

function get_record_number (
  i_sess_file_id          in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_medium_id
is
begin
    for i in g_sess_file_rec_count.first..g_sess_file_rec_count.last loop
        if g_sess_file_rec_count.exists(i) then
            if g_sess_file_rec_count(i).session_file_id = i_sess_file_id or i_sess_file_id is null then
                return g_sess_file_rec_count(i).record_count;
            end if;
        end if;
    end loop;

    return 0;
end;

function get_next_file(
    i_file_type             in     com_api_type_pkg.t_dict_value
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_file_purpose          in     com_api_type_pkg.t_dict_value   default null
  , i_file_attr             in     com_api_type_pkg.t_short_id     default null  
) return com_api_type_pkg.t_long_id is
    l_count            com_api_type_pkg.t_count := 0;
    l_inst_id          com_api_type_pkg.t_inst_id;
begin
    l_inst_id := i_inst_id;
    
    prc_cst_file_pkg.get_next_file(
        i_file_type     => i_file_type
      , io_inst_id      => l_inst_id
      , i_file_purpose  => i_file_purpose
    );
    
    select count(a.id) + 1
      into l_count
      from prc_session_file a
         , prc_session b
         , prc_file f
     where a.session_id = b.id
       and trunc(a.file_date) = trunc(get_sysdate())
       and (a.file_type = i_file_type or i_file_type is null)
       and b.process_id = f.process_id
       and (b.inst_id in (l_inst_id, prc_api_session_pkg.get_inst_id) or l_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and (f.file_purpose = i_file_purpose or i_file_purpose is null)
       and (a.file_attr_id = i_file_attr or i_file_attr is null);     

    return l_count;

end get_next_file;

procedure mark_ready_file (
     i_file_type             in      com_api_type_pkg.t_dict_value   default null
) is
begin
    update prc_session_file
       set session_id = get_session_id
     where session_id is null
       and file_type = i_file_type;
end;

procedure generate_response_file is
    pragma autonomous_transaction;

    l_original_file_id      com_api_type_pkg.t_long_id;
    l_file_name             com_api_type_pkg.t_name;
    l_start_date            date;
    l_end_date              date;
    l_param_inst_id         com_api_type_pkg.t_inst_id;
    l_count                 com_api_type_pkg.t_inst_id;
    l_file_type             com_api_type_pkg.t_dict_value;
begin

    trc_log_pkg.info (
        i_text  => 'generate_response_file start'
    );

    select count(1)
      into l_count
      from prc_file f
         , prc_file_attribute a
     where f.file_type = prc_api_const_pkg.ENTITY_TYPE_RESPONSE
       and a.file_id = f.id
       and a.container_id = prc_api_session_pkg.get_container_id;

    trc_log_pkg.debug (
        i_text  => 'l_count = ' || l_count
    );

    -- need generate resp file
    if l_count > 0 then

        -- get file properties
        select min(f.id) original_file_id
             , min(f.file_name) file_name
             , min(l.file_type)
          into l_original_file_id
             , l_file_name
             , l_file_type
          from prc_session_file f
             , prc_file_attribute a
             , prc_file l
         where f.session_id   = get_session_id
           and f.file_attr_id = a.id
           and l.id           = a.file_id;

        trc_log_pkg.debug (
            i_text  => 'l_original_file_id = ' || l_original_file_id || ', l_file_name = ' || l_file_name
        );

        prc_api_file_pkg.generate_response_file (
            i_file_type             => l_file_type
          , i_original_file_id      => l_original_file_id
          , i_original_file_name    => l_file_name
          , i_start_date            => l_start_date
          , i_end_date              => l_end_date
          , i_inst_id               => l_param_inst_id
          , i_error_code            => com_api_error_pkg.get_last_error
        );
    end if;

    trc_log_pkg.info (
        i_text  => 'generate_response_file end'
    );
    commit;
exception 
    when others then
        trc_log_pkg.error(
            i_text => 'generate_response_file FAILED:' || com_api_error_pkg.get_last_error
        );
        commit;
end generate_response_file;

procedure generate_response_file (
    i_file_type             in      com_api_type_pkg.t_dict_value
  , i_original_file_id      in      com_api_type_pkg.t_long_id      default null
  , i_original_file_name    in      com_api_type_pkg.t_name         default null
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id      default null
  , i_error_code            in      com_api_type_pkg.t_name         default null
)is
    l_file                  clob;
    l_xml                   xmltype;
    l_file_params           com_api_type_pkg.t_param_tab;
    l_sess_file_id          com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.info (
        i_text  => 'generate_response_file start'
    );

    select xmlconcat(
              xmlelement("response_file",
                    xmlelement("file_type",          i_file_type),
                    xmlelement("original_file_id",   i_original_file_id),
                    xmlelement("original_file_name", i_original_file_name),
                    xmlelement("proc_date",          to_char(get_sysdate, com_api_const_pkg.XML_DATETIME_FORMAT)),
                    xmlelement("error_code",         i_error_code)
               )
           )
      into l_xml
      from dual;

    rul_api_param_pkg.set_param(
        i_name      => 'ORIGINAL_FILE_NAME'
      , i_value     => i_original_file_name
      , io_params   => l_file_params
    );

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_sess_file_id
      , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
      , i_file_type     => prc_api_const_pkg.ENTITY_TYPE_RESPONSE
      , io_params       => l_file_params
    );

    l_file := com_api_const_pkg.XML_HEADER || l_xml.getclobval();

    prc_api_file_pkg.put_file(
        i_sess_file_id  => l_sess_file_id
      , i_clob_content  => l_file
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_sess_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug (
        i_text  => 'l_xml ' || l_file
    );

    trc_log_pkg.info (
        i_text  => 'generate_response_file end'
    );

end;

/*
 * Save session file.
 *
 * @param i_file_name     - File name for outgoing files
 * @param i_file_type     - File type
 * @param i_file_purpose  - File data direction
 * @param io_params       - Params for naming format
 * @param i_clob_content  - File contents
 * @param i_add_to        - Append or rewrite contents
 * @param i_status        - File status
 * @param i_record_count  - Record count
 */
procedure save_file (
    i_file_name             in      com_api_type_pkg.t_name        default null
  , i_file_type             in      com_api_type_pkg.t_dict_value
  , i_file_purpose          in      com_api_type_pkg.t_dict_value  default null
  , io_params               in out  com_api_type_pkg.t_param_tab
  , o_report_id                out  com_api_type_pkg.t_short_id
  , o_report_template_id       out  com_api_type_pkg.t_short_id
  , i_no_session_id         in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_clob_content          in      clob
  , i_add_to                in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_record_count          in      com_api_type_pkg.t_medium_id   default null
) is
    l_session_file_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text =>'save_file start, i_file_name [#1] i_file_type [#2] i_file_purpose [#3] i_no_session_id [#4] i_add_to [#5]'
      , i_env_param1 => i_file_name
      , i_env_param2 => i_file_type      
      , i_env_param3 => i_file_purpose
      , i_env_param4 => i_no_session_id
      , i_env_param5 => i_add_to
    );

    open_file (
        o_sess_file_id        => l_session_file_id
      , i_file_name           => i_file_name
      , i_file_type           => i_file_type
      , i_file_purpose        => i_file_purpose
      , io_params             => io_params
      , o_report_id           => o_report_id
      , o_report_template_id  => o_report_template_id
      , i_no_session_id       => i_no_session_id
    );

    put_file (
        i_sess_file_id        => l_session_file_id
      , i_clob_content        => i_clob_content
      , i_add_to              => i_add_to
    );

    trc_log_pkg.debug(
        i_text =>'save_file, i_status [#1] i_record_count [#2]'
      , i_env_param1 => i_status
      , i_env_param2 => i_record_count      
    );

    close_file(
        i_sess_file_id        => l_session_file_id
      , i_status              => i_status
      , i_record_count        => i_record_count
    );

    trc_log_pkg.debug(
        i_text =>'save_file finish, o_report_id [#1] o_report_template_id [#2]'
      , i_env_param1 => o_report_id
      , i_env_param2 => o_report_template_id      
    );
exception 
    when others then
        if l_session_file_id is not null then
            close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        raise;
end;

procedure change_file_status(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value
) is
begin
    change_session_file(
        i_sess_file_id => i_sess_file_id
      , i_status       => i_status
    );
end;

procedure change_session_file(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value  default null
  , i_record_count          in      com_api_type_pkg.t_medium_id   default null
  , i_check_record_count    in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
) is
    l_old_record_count              com_api_type_pkg.t_long_id;
    l_new_record_count              com_api_type_pkg.t_long_id;
begin
    -- File Savers fills the column "record_count" only for text files (not XML files).
    -- Therefore, need fill "record_count" in process which load XML file in single thread and column "record_count" is not filled yet.
    if i_check_record_count = com_api_type_pkg.TRUE then
        select nvl(max(a.record_count), 0)
          into l_old_record_count
          from prc_session_file a
         where a.id = i_sess_file_id;

        if l_old_record_count = 0 then
            l_new_record_count := i_record_count;
        end if;
    else
        l_new_record_count := i_record_count;
    end if;

    if l_new_record_count is not null
       or i_status        is not null
    then
        update prc_session_file a
           set a.status       = nvl(i_status,           a.status)
             , a.record_count = nvl(l_new_record_count, a.record_count)
         where a.id = i_sess_file_id;
   end if;
end;

procedure generate_file_password(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
  , o_file_password         out     com_api_type_pkg.t_dict_value
) is
    l_entity_type   com_api_type_pkg.t_dict_value;
    l_object_id     com_api_type_pkg.t_long_id;
    l_inst_id       com_api_type_pkg.t_inst_id;
begin
    
    select object_id
         , entity_type
      into l_object_id
         , l_entity_type  
      from prc_session_file
     where id = i_sess_file_id;         
    
    g_file_password := sec_api_passwd_pkg.generate_otp(
        i_passwd_type    => sec_api_const_pkg.PASSWORD_TYPE_ALPHANUM
      , i_length         => 8
    );
       
    l_inst_id := 
        ost_api_institution_pkg.get_object_inst_id(
            i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
        );
        
    ntf_api_notification_pkg.make_notification (
        i_inst_id            => l_inst_id
      , i_event_type         => prc_api_const_pkg.EVENT_SEND_FILE_PASSWORD
      , i_entity_type        => prc_api_const_pkg.ENTITY_TYPE_FILE
      , i_object_id          => i_sess_file_id
      , i_eff_date           => com_api_sttl_day_pkg.get_sysdate
      , i_src_entity_type    => l_entity_type
      , i_src_object_id      => l_object_id
    );
    
    o_file_password := g_file_password;
    
    unset_file_password;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error      => 'SESSION_FILE_NOT_FOUND'
          , i_env_param1 => i_sess_file_id
        );
end;

function get_file_password return com_api_type_pkg.t_dict_value is
begin
    return g_file_password;
end;

procedure unset_file_password is
begin
    g_file_password := null;
end;

procedure change_file_names_in_thread(
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_total_file_count      in      com_api_type_pkg.t_medium_id
) is
begin
    update prc_session_file
       set file_name     = replace(file_name, prc_api_const_pkg.NAME_PART_FILE_COUNT, i_total_file_count)
     where session_id    = i_session_id
       and thread_number = i_thread_number;

end change_file_names_in_thread;

function get_session_file_id(
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_file_type             in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_long_tab
is
    l_id_tab                        com_api_type_pkg.t_long_tab;
begin
    select s.id
      bulk collect
      into l_id_tab
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
     where s.session_id    = i_session_id
       and s.file_attr_id  = a.id
       and f.id            = a.file_id
       and (f.file_type = i_file_type or i_file_type is null);

    return l_id_tab;
end get_session_file_id;


function get_xml_content(
    i_sess_file_id          in      com_api_type_pkg.t_long_id
) return xmltype
is
    l_file_xml                      xmltype;
begin
    begin
        select s.file_xml_contents
          into l_file_xml
          from prc_session_file s
         where s.id = i_sess_file_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'SESSION_FILE_NOT_FOUND'
              , i_env_param1  => i_sess_file_id
            );
    end;

    return l_file_xml;
end get_xml_content;

end;
/
