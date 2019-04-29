create or replace package body app_ui_application_pkg as
/*********************************************************
*  Application - user interface <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 09.09.2009 <br />
*  Module: APP_UI_APPLICATION_PKG <br />
*  @headcom
**********************************************************/

procedure document_save(
    i_appl_data_id           in     com_api_type_pkg.t_long_id
  , i_doc_source             in     clob
  , i_sign_source            in     clob
  , i_supervisor_sign_source in     clob
  , o_save_path                 out com_api_type_pkg.t_full_desc
) is
    l_doc               app_api_type_pkg.t_document_rec;
    l_run_hash          com_api_type_pkg.t_name;
    l_root_data_id      com_api_type_pkg.t_long_id;
    l_appl_id           com_api_type_pkg.t_long_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_object_id         com_api_type_pkg.t_long_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug('document_save: i_appl_data_id='||i_appl_data_id);

    select to_number(element_value, get_number_format)
         , appl_id
      into l_doc.id
         , l_appl_id
      from app_data
     where id = i_appl_data_id;

    app_api_application_pkg.get_appl_data(
        i_appl_id       => l_appl_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'APPLICATION'
      , i_parent_id         => null
      , o_appl_data_id      => l_root_data_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'INSTITUTION_ID'
      , i_parent_id         => l_root_data_id
      , o_element_value     => l_doc.inst_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'DOCUMENT_TYPE'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.document_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'FILE_NAME'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.file_name
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'MIME_TYPE'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.mime_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'DOCUMENT_OBJECT'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.document_object
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'DOCUMENT_NUMBER'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.document_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'DOCUMENT_DATE'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.document_date
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'DOCUMENT_NAME'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.document_name
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'USER_EDS'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.user_eds
    );

    app_api_application_pkg.get_element_value(
        i_element_name      => 'USER_NAME'
      , i_parent_id         => i_appl_data_id
      , o_element_value     => l_doc.user_name
    );

    begin
        select min(id)
          into l_doc.user_id
          from acm_user_vw
         where name = l_doc.user_name;
    exception
        when no_data_found then
           com_api_error_pkg.raise_error(
               i_error      => 'USER_DOES_NOT_EXIST'
             , i_env_param1 => l_doc.user_name
           );
    end;

    if l_doc.document_type = rpt_api_const_pkg.DOCUMENT_TYPE_IMAGE then
        l_doc.save_path :=
            set_ui_value_pkg.get_inst_param_v(
                i_param_name  => 'REPORTS_SAVE_PATH'
              , i_inst_id     => l_doc.inst_id
            );

        if substr(l_doc.save_path, -1) != '/' then
            l_doc.save_path := l_doc.save_path || '/';
        end if;

        l_run_hash := l_doc.id||to_char(get_sysdate, 'yyyymmddhh24miss');
        l_run_hash := rawtohex(dbms_crypto.hash(utl_raw.cast_to_raw(l_run_hash), dbms_crypto.HASH_MD5));

        l_doc.save_path := l_doc.save_path || l_run_hash;

        o_save_path := l_doc.save_path;
    end if;

    begin
        select e.entity_type
             , to_number(d.element_value, com_api_const_pkg.NUMBER_FORMAT)
          into l_entity_type
             , l_object_id
          from app_element_all_vw e
             , app_data d
         where d.id         = l_doc.document_object
           and d.element_id = e.id
           and e.entity_type is not null
           and d.element_value is not null;
    exception
        when no_data_found then
            l_entity_type := app_api_const_pkg.ENTITY_TYPE_APPLICATION;
            l_object_id   := l_appl_id;
        when com_api_error_pkg.E_VALUE_ERROR or com_api_error_pkg.E_INVALID_NUMBER then
            trc_log_pkg.debug('Incorrect number: document_object='||l_doc.document_object);
    end;

    rpt_api_document_pkg.add_document(
        io_document_id      => l_doc.id
      , o_seqnum            => l_seqnum
      , i_content_type      => rpt_api_const_pkg.CONTENT_TYPE_CUST_ORDER
      , i_document_type     => l_doc.document_type
      , i_entity_type       => l_entity_type
      , i_object_id         => l_object_id
      , i_report_id         => null
      , i_template_id       => null
      , i_file_name         => l_doc.file_name
      , i_mime_type         => l_doc.mime_type
      , i_save_path         => l_doc.save_path
      , i_document_date     => l_doc.document_date
      , i_document_number   => l_doc.document_number
      , i_inst_id           => l_doc.inst_id
      , i_xml               => i_doc_source
    );

    if dbms_lob.getlength(i_sign_source) > 0 then
        rpt_api_document_pkg.add_document(
            io_document_id          => l_doc.id
          , o_seqnum                => l_seqnum
          , i_content_type          => rpt_api_const_pkg.CONTENT_TYPE_CUST_SIGN
          , i_document_type         => l_doc.document_type
          , i_entity_type           => l_entity_type
          , i_object_id             => l_object_id
          , i_report_id             => null
          , i_template_id           => null
          , i_file_name             => l_doc.file_name
          , i_mime_type             => l_doc.mime_type
          , i_save_path             => l_doc.save_path
          , i_document_date         => l_doc.document_date
          , i_document_number       => l_doc.document_number
          , i_inst_id               => l_doc.inst_id
          , i_xml                   => i_sign_source
        );
    end if;

    if dbms_lob.getlength(i_supervisor_sign_source) > 0 then
        rpt_api_document_pkg.add_document(
            io_document_id          => l_doc.id
          , o_seqnum                => l_seqnum
          , i_content_type          => rpt_api_const_pkg.CONTENT_TYPE_SUPERV_SIGN
          , i_document_type         => l_doc.document_type
          , i_entity_type           => l_entity_type
          , i_object_id             => l_object_id
          , i_report_id             => null
          , i_template_id           => null
          , i_file_name             => l_doc.file_name
          , i_mime_type             => l_doc.mime_type
          , i_save_path             => l_doc.save_path
          , i_document_date         => l_doc.document_date
          , i_document_number       => l_doc.document_number
          , i_inst_id               => l_doc.inst_id
          , i_xml                   => i_supervisor_sign_source
        );
    end if;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => l_entity_type
      , i_object_type   => null
      , i_object_id     => l_doc.id
      , i_inst_id       => l_doc.inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => l_entity_type
      , i_object_id    => l_doc.id
    );

    update app_data
       set element_value = to_char(l_doc.id, get_number_format)
         , is_auto       = com_api_const_pkg.TRUE
     where id            = i_appl_data_id;

    trc_log_pkg.debug('document_save: updated '||sql%rowcount||' rows');
end document_save;

procedure document_save(
    i_appl_id           in     com_api_type_pkg.t_long_id
  , i_document_type     in     com_api_type_pkg.t_dict_value
  , i_file_name         in     com_api_type_pkg.t_full_desc
  , o_save_path            out com_api_type_pkg.t_full_desc
  , o_file_name            out com_api_type_pkg.t_full_desc
  , i_add_history       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
) is
    l_seqnum                   com_api_type_pkg.t_tiny_id;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_appl_type                com_api_type_pkg.t_dict_value;
    l_document_id              com_api_type_pkg.t_long_id;
    l_document_date            date;
    l_add_history              com_api_type_pkg.t_boolean := nvl(i_add_history, com_api_type_pkg.FALSE);
    l_old_appl_status          com_api_type_pkg.t_dict_value;
    l_old_reject_code          com_api_type_pkg.t_dict_value;
begin
    select appl_type
         , inst_id
         , appl_status
         , reject_code
      into l_appl_type
         , l_inst_id
         , l_old_appl_status
         , l_old_reject_code
      from app_application
     where id = i_appl_id;

    if l_appl_type = app_api_const_pkg.APPL_TYPE_DISPUTE then
        -- Add document without saving path to get document ID
        l_document_date := com_api_sttl_day_pkg.get_sysdate();

        rpt_api_document_pkg.add_document(
            io_document_id    => l_document_id
          , o_seqnum          => l_seqnum
          , i_content_type    => rpt_api_const_pkg.CONTENT_TYPE_DSP_ATTCHT
          , i_document_type   => i_document_type
          , i_entity_type     => nvl(i_entity_type, app_api_const_pkg.ENTITY_TYPE_APPLICATION)
          , i_object_id       => nvl(i_object_id, i_appl_id)
          , i_report_id       => null
          , i_template_id     => null
          , i_file_name       => i_file_name
          , i_mime_type       => null
          , i_save_path       => null
          , i_document_date   => l_document_date
          , i_document_number => null
          , i_inst_id         => l_inst_id
          , i_xml             => null
        );

        o_save_path :=
            set_ui_value_pkg.get_inst_param_v(
                i_param_name  => 'PATH_TO_DISPUTE_ATTACHMENTS'
              , i_inst_id     => l_inst_id
            );

        if substr(o_save_path, -1) != '/' then
            o_save_path := o_save_path || '/';
        end if;

        o_file_name := l_document_id || to_char(l_document_date, 'yyyymmddhh24miss');
        o_file_name := rawtohex(dbms_crypto.hash(utl_raw.cast_to_raw(o_file_name), dbms_crypto.HASH_MD5));

        o_save_path := o_save_path || o_file_name;

        -- Save actual saving path
        rpt_api_document_pkg.modify_document(
            i_document_id     => l_document_id
          , io_seqnum         => l_seqnum
          , i_content_type    => rpt_api_const_pkg.CONTENT_TYPE_DSP_ATTCHT
          , i_save_path       => o_save_path
        );

        if l_add_history = com_api_type_pkg.TRUE then
            app_api_history_pkg.add_history (
                i_appl_id         => i_appl_id
              , i_action          => app_api_const_pkg.APPL_ACTION_DATA_CHANGE
              , i_comments        => null
              , i_new_appl_status => l_old_appl_status
              , i_old_appl_status => l_old_appl_status
              , i_new_reject_code => l_old_reject_code
              , i_old_reject_code => l_old_reject_code
            );
        end if;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.document_save() FAILED:'
                         ||   ' i_appl_id ['       || i_appl_id
                         || '], i_document_type [#1], l_appl_type [#2]'
                         ||  ', i_file_name ['     || i_file_name
                         || '], l_inst_id ['       || l_inst_id
                         || '], l_seqnum ['        || l_seqnum
                         || '], l_document_id ['   || l_document_id
                         || '], l_document_date [' || to_char(l_document_date, com_api_const_pkg.LOG_DATE_FORMAT)
                         || '], o_save_path ['     || o_save_path
                         || '], o_file_name ['     || o_file_name
                         || ']'
          , i_env_param1 => i_document_type
          , i_env_param2 => l_appl_type
        );
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_type_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end document_save;

procedure documents_copy(
    i_appl_id_from      in     com_api_type_pkg.t_long_id
  , i_appl_id_to        in     com_api_type_pkg.t_long_id
  , i_add_history       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) is
    l_seqnum                   com_api_type_pkg.t_tiny_id;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_appl_type                com_api_type_pkg.t_dict_value;
    l_document_id              com_api_type_pkg.t_long_id;
    l_add_history              com_api_type_pkg.t_boolean := nvl(i_add_history, com_api_type_pkg.FALSE);
    l_old_appl_status          com_api_type_pkg.t_dict_value;
    l_old_reject_code          com_api_type_pkg.t_dict_value;
begin
    select appl_type
         , inst_id
         , appl_status
         , reject_code
      into l_appl_type
         , l_inst_id
         , l_old_appl_status
         , l_old_reject_code
      from app_application
     where id = i_appl_id_to;

    if l_appl_type = app_api_const_pkg.APPL_TYPE_DISPUTE then
        for rec in (
            select document_type
                 , file_name
                 , mime_type
                 , save_path
                 , document_date
                 , document_number
              from rpt_ui_document_content_vw
             where entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION
               and object_id   = i_appl_id_from
        ) loop
            rpt_api_document_pkg.add_document(
                io_document_id    => l_document_id
              , o_seqnum          => l_seqnum
              , i_content_type    => rpt_api_const_pkg.CONTENT_TYPE_DSP_ATTCHT
              , i_document_type   => rec.document_type
              , i_entity_type     => app_api_const_pkg.ENTITY_TYPE_APPLICATION
              , i_object_id       => i_appl_id_to
              , i_report_id       => null
              , i_template_id     => null
              , i_file_name       => rec.file_name
              , i_mime_type       => rec.mime_type
              , i_save_path       => rec.save_path
              , i_document_date   => rec.document_date
              , i_document_number => rec.document_number
              , i_inst_id         => l_inst_id
              , i_xml             => null
            );
            l_document_id := null;
        end loop;

        if l_add_history = com_api_type_pkg.TRUE then
            app_api_history_pkg.add_history (
                i_appl_id         => i_appl_id_to
              , i_action          => app_api_const_pkg.APPL_ACTION_DATA_CHANGE
              , i_comments        => null
              , i_new_appl_status => l_old_appl_status
              , i_old_appl_status => l_old_appl_status
              , i_new_reject_code => l_old_reject_code
              , i_old_reject_code => l_old_reject_code
            );
        end if;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT)     || '.documents_copy() FAILED:'
                         ||   ' i_appl_id_from ['   || i_appl_id_from
                         || '], i_appl_id_to '      || i_appl_id_to
                         || ']'
        );
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_type_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end documents_copy;

procedure document_save(
    i_appl_id_tab       in     num_tab_tpt
  , i_document_type     in     com_api_type_pkg.t_dict_value
  , i_file_name         in     com_api_type_pkg.t_full_desc
  , o_save_path            out com_api_type_pkg.t_full_desc
  , o_file_name            out com_api_type_pkg.t_full_desc
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id_tab     in     num_tab_tpt
) is
begin
    if i_appl_id_tab is not null then
        for i in 1 .. i_appl_id_tab.count loop
            document_save(
                i_appl_id       => i_appl_id_tab(i)
              , i_document_type => i_document_type
              , i_file_name     => i_file_name
              , o_save_path     => o_save_path
              , o_file_name     => o_file_name
              , i_add_history   => com_api_type_pkg.TRUE
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id_tab(i)
            );
        end loop;
    end if;
end document_save;

procedure check_seqnum(
    i_appl_id           in     com_api_type_pkg.t_long_id
  , i_seqnum            in     com_api_type_pkg.t_tiny_id
) is
    l_seqnum                   com_api_type_pkg.t_tiny_id;
begin
    select seqnum
      into l_seqnum
      from app_application_vw
     where id = i_appl_id;

    if l_seqnum > i_seqnum then
        com_api_error_pkg.raise_error(
            i_error => 'INCONSISTENT_DATA'
        );
    end if;
end;

-- Internal method
procedure add_application(
    io_appl_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_appl_number       in      com_api_type_pkg.t_name
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_appl_status       in      com_api_type_pkg.t_dict_value       default null
  , i_session_file_id   in      com_api_type_pkg.t_long_id          default null
  , i_file_rec_num      in      com_api_type_pkg.t_tiny_id          default null
  , i_customer_type     in      com_api_type_pkg.t_dict_value       default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_reject_code       in      com_api_type_pkg.t_dict_value       default null
  , i_user_id           in      com_api_type_pkg.t_short_id         default null
  , i_is_visible        in      com_api_type_pkg.t_boolean          default null
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_execution_mode    in      com_api_type_pkg.t_dict_value       default null
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name        := lower($$PLSQL_UNIT) || '.add_application: ';
    l_audit_activated           com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE;
    l_entity_type               com_api_type_pkg.t_dict_value  := app_api_const_pkg.ENTITY_TYPE_APPLICATION;
    l_trail_id                  com_api_type_pkg.t_long_id;
    l_action_type               com_api_type_pkg.t_dict_value;
    l_template_appl_id          com_api_type_pkg.t_long_id;
    l_appl_data_id              com_api_type_pkg.t_long_id;
    l_parent_id                 com_api_type_pkg.t_long_id;
    l_changed_count             pls_integer := 0;
    l_count                     pls_integer := 0;
    l_element_name              com_api_type_pkg.t_name;
    l_appl_data_templ           app_data_tpt := app_data_tpt(app_data_tpr(null, null, null, null, null, null, null, null));
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_appl_status               com_api_type_pkg.t_dict_value;
    l_sysdate                   date := com_api_sttl_day_pkg.get_sysdate;

    procedure save_appl_element_n(
        i_element_name      in      com_api_type_pkg.t_name
      , i_element_value     in      number
    ) is
    begin
        if i_element_value is null then return; end if;

        select appl_data_id
          into l_appl_data_id
          from table(cast(l_appl_data_templ as app_data_tpt))
         where element_id = app_api_element_pkg.get_element_id(i_element_name)
           and parent_id  = l_parent_id;

        for i in 1..l_appl_data_templ.count loop
            if l_appl_data_templ(i).appl_data_id = l_appl_data_id then
                l_appl_data_templ(i).element_value_n := i_element_value;
                exit;
            end if;
        end loop;
    exception
        when no_data_found then
            l_appl_data_templ.extend;
            l_appl_data_templ(l_appl_data_templ.count) :=
                app_data_tpr(
                    get_next_appl_data_id (
                        i_appl_id => io_appl_id
                    )
                  , app_api_element_pkg.get_element_id(i_element_name)
                  , l_parent_id
                  , 1
                  , null
                  , null
                  , i_element_value
                  , null
                );
    end;

    procedure save_appl_element_v(
        i_element_name      in      com_api_type_pkg.t_name
      , i_element_value     in      com_api_type_pkg.t_name
    ) is
    begin
        if i_element_value is null then return; end if;

        select appl_data_id
          into l_appl_data_id
          from table(cast(l_appl_data_templ as app_data_tpt))
         where element_id = app_api_element_pkg.get_element_id(i_element_name)
           and parent_id  = l_parent_id;

        for i in 1..l_appl_data_templ.count loop
            if l_appl_data_templ(i).appl_data_id = l_appl_data_id then
                l_appl_data_templ(i).element_value_v := i_element_value;
                exit;
            end if;
        end loop;
    exception
        when no_data_found then
            l_appl_data_templ.extend;
            l_appl_data_templ(l_appl_data_templ.count) :=
                app_data_tpr(
                    get_next_appl_data_id (
                        i_appl_id => io_appl_id
                    )
                  , app_api_element_pkg.get_element_id(i_element_name)
                  , l_parent_id
                  , 1
                  , i_element_value
                  , null
                  , null
                  , null
                );
    end;

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with io_appl_id [' || io_appl_id
                     || '], i_appl_type [#1], i_appl_status [#2], i_appl_number [' || i_appl_number
                     || '], i_flow_id [' || i_flow_id || '], i_inst_id [' || i_inst_id
                     || '], i_session_file_id [' || i_session_file_id
                     || '], i_reject_code [#3], i_user_id [' || i_user_id || ']'
      , i_env_param1 => i_appl_type
      , i_env_param2 => i_appl_status
      , i_env_param3 => i_reject_code
    );
    
    if i_appl_type is null then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_APPLICATION_TYPE'
          , i_env_param1    => i_appl_type
        );
    end if;
    
    o_seqnum      := 1;
    l_appl_status := nvl(i_appl_status, app_api_const_pkg.APPL_STATUS_INITIAL);

    if i_flow_id is not null then
        begin
            select template_appl_id
              into l_template_appl_id
              from app_flow_vw
             where id = i_flow_id;

            trc_log_pkg.debug('l_template_appl_id [' || l_template_appl_id || ']');
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'APPLICATION_FLOW_NOT_FOUND'
                  , i_env_param1    => i_appl_type
                  , i_env_param2    => i_flow_id
                );
        end;
    end if;

    if io_appl_id is null then
        io_appl_id := com_api_id_pkg.get_id(app_application_seq.nextval, l_sysdate);
        trc_log_pkg.debug('new io_appl_id [' || io_appl_id || ']');
    end if;

    l_split_hash := coalesce(i_split_hash, com_api_hash_pkg.get_split_hash(i_value => io_appl_id));

    if i_appl_number is not null then
        select count(1)
          into l_count
          from app_application a
         where inst_id     = i_inst_id
           and appl_number = i_appl_number;

        if l_count > 0 then
            l_appl_status := app_api_const_pkg.APPL_STATUS_PROC_DUPLICATED;

            trc_log_pkg.debug(
                i_text       => 'EXTERNAL_APPL_NUMBER_IS_NOT_UNIQUE: i_appl_number [#1], i_inst_id [#2]'
              , i_env_param1 => i_appl_number
              , i_env_param2 => i_inst_id
            );
        end if;
    end if;

    if l_template_appl_id is not null then
        -- get template elements
        select
            app_data_tpr(
                id
              , element_id
              , parent_id
              , serial_number
              , element_value -- element %CARD_NUMBER can't be in an application template
              , null
              , null
              , null
            )
          bulk collect into l_appl_data_templ
          from app_data_vw
         where appl_id = l_template_appl_id;

        -- replace template elements identifiers with new values
        for i in 1..l_appl_data_templ.count loop
            l_appl_data_id := get_next_appl_data_id (
                i_appl_id => io_appl_id
            );

            for j in 1..l_appl_data_templ.count loop
                if l_appl_data_templ(j).parent_id = l_appl_data_templ(i).appl_data_id then
                    l_appl_data_templ(j).parent_id := l_appl_data_id;
                end if;
            end loop;

            l_appl_data_templ(i).appl_data_id := l_appl_data_id;
        end loop;
    end if;

    if i_session_file_id is null then
        begin
            select appl_data_id
              into l_parent_id
              from table(cast(l_appl_data_templ as app_data_tpt))
             where element_id = app_api_element_pkg.get_element_id('APPLICATION')
               and parent_id is null;
        exception
            when no_data_found then
                l_appl_data_templ.delete;
                l_appl_data_templ.extend;
                l_appl_data_templ(l_appl_data_templ.count) :=
                    app_data_tpr(
                        get_next_appl_data_id (
                            i_appl_id => io_appl_id
                        )
                      , app_api_element_pkg.get_element_id('APPLICATION')
                      , null
                      , 1
                      , null
                      , null
                      , null
                      , null
                    );
                l_parent_id := l_appl_data_templ(1).appl_data_id;
        end;

        save_appl_element_n('APPLICATION_ID', io_appl_id);

        save_appl_element_n('INSTITUTION_ID', i_inst_id);

        if i_appl_type = app_api_const_pkg.APPL_TYPE_INSTITUTION and i_agent_id is null then
            null;
        else
            save_appl_element_n(
                'AGENT_ID'
              , nvl(i_agent_id
                  , acm_ui_user_pkg.get_default_agent(
                        i_user_id => get_user_id
                      , i_inst_id => i_inst_id
                    )
                )
            );
        end if;

        save_appl_element_n('APPLICATION_FLOW_ID', i_flow_id);

        save_appl_element_v('APPLICATION_STATUS', l_appl_status);

        save_appl_element_v('APPLICATION_TYPE', i_appl_type);

        save_appl_element_v('OPERATOR_ID', nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), user));

        save_appl_element_v('CUSTOMER_TYPE', i_customer_type);

        save_appl_element_n('APPL_PRIORITIZED', i_appl_prioritized);
    end if;

    insert into app_application_vw(
        id
      , seqnum
      , split_hash
      , appl_type
      , appl_number
      , flow_id
      , appl_status
      , reject_code
      , inst_id
      , agent_id
      , session_file_id
      , file_rec_num
      , is_template
      , user_id
      , is_visible
      , appl_prioritized
      , execution_mode
    ) values (
        io_appl_id
      , o_seqnum
      , l_split_hash
      , i_appl_type
      , i_appl_number
      , i_flow_id
      , l_appl_status
      , i_reject_code
      , i_inst_id
      , case 
            when i_appl_type = app_api_const_pkg.APPL_TYPE_INSTITUTION and i_agent_id is null then
                null
            else coalesce(i_agent_id, ost_ui_institution_pkg.get_default_agent(i_inst_id))
        end
      , i_session_file_id
      , i_file_rec_num
      , com_api_const_pkg.FALSE
      , i_user_id
      , i_is_visible
      , nvl(i_appl_prioritized, com_api_const_pkg.FALSE)
      , i_execution_mode
    );

    begin
        select is_active
          into l_audit_activated
          from adt_entity
         where entity_type = l_entity_type;
    exception
        when no_data_found then
            l_audit_activated := com_api_type_pkg.FALSE;
    end;

    l_action_type := 'INSERT';

    if l_audit_activated = com_api_type_pkg.TRUE then
        l_trail_id := adt_api_trail_pkg.get_trail_id;
    end if;

    if i_session_file_id is null then
        for i in (
            select appl_data_id
                 , element_id
                 , parent_id
                 , serial_number
                 , coalesce(
                       element_value_v
                     , to_char(element_value_d, com_api_const_pkg.DATE_FORMAT)
                     , to_char(element_value_n, com_api_const_pkg.NUMBER_FORMAT)
                   ) as element_value
                 , 0
                 , lang
              from table(cast(l_appl_data_templ as app_data_tpt))
        ) loop
            --trc_log_pkg.debug('insert element_id [' || i.element_id || '] with value [' || i.element_value || '], i.appl_data_id [' || i.appl_data_id || '], i.serial_number [' || i.serial_number || ']');
            insert into app_data(
                id
              , appl_id
              , split_hash
              , element_id
              , parent_id
              , serial_number
              , element_value -- element %CARD_NUMBER can't be in an application template
              , is_auto
              , lang
            ) values (
                i.appl_data_id
              , io_appl_id
              , l_split_hash
              , i.element_id
              , i.parent_id
              , i.serial_number
              , i.element_value
              , com_api_type_pkg.FALSE
              , i.lang
            );

            if l_audit_activated = com_api_type_pkg.TRUE then
                select name
                  into l_element_name
                  from app_element_all_vw
                 where id = i.element_id;

                adt_api_trail_pkg.check_value(
                    i_trail_id       => l_trail_id
                  , i_column_name    => upper(l_element_name)
                  , i_old_value      => null
                  , i_new_value      => i.element_value
                  , io_changed_count => l_changed_count
                );
            end if;
        end loop;
    end if;

    if l_changed_count > 0 then
        adt_api_trail_pkg.put_audit_trail(
            i_trail_id          => l_trail_id
          , i_entity_type       => l_entity_type
          , i_object_id         => nvl(null, io_appl_id)
          , i_action_type       => l_action_type
        );
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END'); 
end add_application;

procedure modify_application(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_tiny_id
  , i_appl_status       in      com_api_type_pkg.t_dict_value
  , i_resp_sess_file_id in      com_api_type_pkg.t_long_id          default null
  , i_comments          in      com_api_type_pkg.t_full_desc        default null
  , i_change_action     in      com_api_type_pkg.t_name             default null
  , i_reject_code       in      com_api_type_pkg.t_dict_value       default null
  , i_event_type        in      com_api_type_pkg.t_dict_value       default null
  , i_user_id           in      com_api_type_pkg.t_short_id         default null
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_skip_oper_process in      com_api_type_pkg.t_boolean          default null
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_application: ';
    l_audit_activated           com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE;
    l_trail_id                  com_api_type_pkg.t_long_id;
    l_action_type               com_api_type_pkg.t_dict_value;
    l_changed_count             pls_integer := 0;
    l_resp_sess_file_id         com_api_type_pkg.t_long_id;
    l_appl_data_id              com_api_type_pkg.t_long_id;
    l_appl_status_id            com_api_type_pkg.t_long_id;
    l_appl_skip_proc_id         com_api_type_pkg.t_long_id;
    l_appl_type                 com_api_type_pkg.t_dict_value;
    l_event_type                com_api_type_pkg.t_dict_value;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_flow_id                   com_api_type_pkg.t_tiny_id;
    l_user_id                   com_api_type_pkg.t_short_id;

    l_old_appl_status           com_api_type_pkg.t_dict_value;
    l_old_reject_code           com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_appl_id [' || i_appl_id
                     || '], io_seqnum [' || io_seqnum || '], i_appl_status [#1'
                     || '], i_resp_sess_file_id [' || i_resp_sess_file_id
                     || '], i_change_action[' || i_change_action
                     || '], i_event_type [' || i_event_type
                     || '], i_user_id [' ||i_user_id
                     || '], i_reject_code [' || i_reject_code || ']'
      , i_env_param1 => i_appl_status
    );
    check_seqnum(
        i_appl_id => i_appl_id
      , i_seqnum  => io_seqnum
    );

    begin
        select is_active
          into l_audit_activated
          from adt_entity
         where entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION;
    exception
        when no_data_found then
            l_audit_activated := com_api_type_pkg.FALSE;
    end;

    l_action_type := 'UPDATE';

    select appl_status
         , reject_code
         , appl_type
         , resp_session_file_id
         , inst_id
         , split_hash
         , flow_id
      into l_old_appl_status
         , l_old_reject_code
         , l_appl_type
         , l_resp_sess_file_id
         , l_inst_id
         , l_split_hash
         , l_flow_id
      from app_application_vw
     where id = i_appl_id;

    io_seqnum := io_seqnum + 1;
    
    if i_user_id is not null then
        l_user_id := i_user_id;
    else
        app_api_dispute_pkg.determine_user(
            i_flow_id     => l_flow_id
          , i_appl_status => i_appl_status
          , i_reject_code => i_reject_code
          , o_user_id     => l_user_id
        );
    end if;

    update app_application_vw
       set appl_status          = i_appl_status
         , seqnum               = io_seqnum
         , resp_session_file_id = nvl(i_resp_sess_file_id, resp_session_file_id)
         , reject_code          = i_reject_code
         , user_id              = decode(l_user_id, acm_api_const_pkg.UNDEFINED_USER_ID, null, nvl(l_user_id, user_id))
         , appl_prioritized     = nvl(i_appl_prioritized, appl_prioritized)
         , agent_id             = nvl(i_agent_id, agent_id)
     where id                   = i_appl_id;

    app_api_application_pkg.get_appl_data(
        i_appl_id       => i_appl_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'APPLICATION'
      , i_parent_id         => null
      , o_appl_data_id      => l_appl_data_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'APPLICATION_STATUS'
      , i_parent_id         => l_appl_data_id
      , o_appl_data_id      => l_appl_status_id
    );
    trc_log_pkg.debug('l_appl_status_id='||l_appl_status_id);

    update app_data
       set element_value = i_appl_status
     where id            = l_appl_status_id;

    if l_appl_type = app_api_const_pkg.APPL_TYPE_FIN_REQUEST and i_skip_oper_process is not null then

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'SKIP_OPER_PROCESS'
          , i_parent_id         => l_appl_data_id
          , o_appl_data_id      => l_appl_skip_proc_id
        );

        update app_data
           set element_value = to_char(i_skip_oper_process, com_api_const_pkg.NUMBER_FORMAT)
         where id            = l_appl_skip_proc_id;

    end if;

    if l_appl_type = app_api_const_pkg.APPL_TYPE_DISPUTE then
        
        -- Register event if event type is defined for current change of application status
        l_event_type :=
            evt_api_status_pkg.get_event_type(
                i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_initial_status => l_old_appl_status
              , i_result_status  => i_appl_status
              , i_inst_id        => l_inst_id
              , i_raise_error    => com_api_type_pkg.FALSE
            );
                
        if l_event_type is not null then

            evt_api_event_pkg.register_event(
                i_event_type   => l_event_type
              , i_eff_date     => com_api_sttl_day_pkg.get_sysdate
              , i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
              , i_object_id    => i_appl_id
              , i_inst_id      => l_inst_id
              , i_split_hash   => l_split_hash
            );
            
        end if;
        
    end if;

    if l_audit_activated = com_api_type_pkg.TRUE then
        l_trail_id := adt_api_trail_pkg.get_trail_id;
        adt_api_trail_pkg.check_value(
            i_trail_id       => l_trail_id
          , i_column_name    => 'APPL_STATUS'
          , i_old_value      => l_old_appl_status
          , i_new_value      => i_appl_status
          , io_changed_count => l_changed_count
        );
        adt_api_trail_pkg.check_value(
            i_trail_id       => l_trail_id
          , i_column_name    => 'RESP_FILE_ID'
          , i_old_value      => l_resp_sess_file_id
          , i_new_value      => i_resp_sess_file_id
          , io_changed_count => l_changed_count
        );
    end if;

    if l_changed_count > 0 then
        adt_api_trail_pkg.put_audit_trail(
            i_trail_id       => l_trail_id
          , i_entity_type    => app_api_const_pkg.ENTITY_TYPE_APPLICATION
          , i_object_id      => nvl(null, i_appl_id)
          , i_action_type    => l_action_type
        );
    end if;

    app_api_history_pkg.add_history (
        i_appl_id         => i_appl_id
      , i_action          => nvl(i_change_action, nvl(i_event_type, app_api_const_pkg.EVENT_APPL_CHANGED))
      , i_comments        => i_comments
      , i_new_appl_status => i_appl_status
      , i_old_appl_status => l_old_appl_status
      , i_new_reject_code => i_reject_code
      , i_old_reject_code => l_old_reject_code
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end modify_application;

procedure modify_application(
    i_appl_id                   in      com_api_type_pkg.t_long_id
  , io_seqnum                   in out  com_api_type_pkg.t_tiny_id
  , i_reason_code               in      com_api_type_pkg.t_dict_value
  , i_resp_sess_file_id         in      com_api_type_pkg.t_long_id               default null
  , i_comments                  in      com_api_type_pkg.t_full_desc             default null
  , i_change_action             in      com_api_type_pkg.t_name                  default null
  , i_event_type                in      com_api_type_pkg.t_dict_value            default null
  , i_user_id                   in      com_api_type_pkg.t_short_id              default null
  , i_raise_error               in      com_api_type_pkg.t_boolean               default com_api_const_pkg.FALSE
  , i_appl_prioritized          in      com_api_type_pkg.t_boolean               default null
  , i_skip_oper_process         in      com_api_type_pkg.t_boolean               default null
) is 
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_application(reason): ';
    l_app_tab                   app_api_type_pkg.t_application_rec;
    l_stage_id                  com_api_type_pkg.t_long_id;
    l_new_appl_status           com_api_type_pkg.t_dict_value;
    l_new_reject_code           com_api_type_pkg.t_dict_value;
    
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_appl_id ['  || i_appl_id
                     || '], io_seqnum ['                        || io_seqnum                      
                     || '], i_resp_sess_file_id ['              || i_resp_sess_file_id
                     || '], i_reason_code ['                    || i_reason_code
                     || '], i_change_action ['                  || i_change_action
                     || '], i_event_type ['                     || i_event_type
                     || '], i_user_id ['                        || i_user_id
    );
    
    l_app_tab := app_api_application_pkg.get_application(
        i_appl_id     => i_appl_id
      , i_raise_error => com_api_const_pkg.TRUE
    );      
    
    for tab in (
        select id           
          from app_flow_stage
         where flow_id = l_app_tab.flow_id 
           and appl_status = l_app_tab.appl_status
           and nvl(reject_code, 'DUMMY') = nvl(l_app_tab.reject_code, 'DUMMY'))
    loop
        l_stage_id := tab.id;
    end loop;             
                             
    if l_stage_id is null then
        com_api_error_pkg.raise_error (
            i_error       => 'APPLICATION_STAGE_NOT_FOUND'
          , i_env_param1  => l_app_tab.flow_id 
          , i_env_param2  => l_app_tab.appl_status
          , i_env_param3  => l_app_tab.reject_code
          , i_mask_error  => com_api_type_pkg.boolean_not(i_raise_error)
        );        
    end if;    
    
    for tab in (select appl_status
                     , reject_code 
                  from app_flow_stage
                 where id in (select transition_stage_id 
                                from app_flow_transition
                               where stage_id = l_stage_id
                                 and nvl(reason_code, 'DUMMY') = nvl(i_reason_code, 'DUMMY')))
    loop   
        if l_new_appl_status is not null then
            com_api_error_pkg.raise_error (
                i_error       => 'SEVERAL_POSSIBLE_TRANSITION'
              , i_env_param1  => l_stage_id 
              , i_env_param2  => i_reason_code
              , i_mask_error  => com_api_type_pkg.boolean_not(i_raise_error)                                     
            );
        end if;
        l_new_appl_status := tab.appl_status;
        l_new_reject_code := tab.reject_code;
    end loop;                                       

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' l_new_appl_status=' || l_new_appl_status || ' l_new_reject_code=' || l_new_reject_code 
                                   || ' l_stage_id=' || l_stage_id || ' l_app_tab.flow_id=' || l_app_tab.flow_id || ' l_app_tab.appl_status=' || l_app_tab.appl_status
    );
    
    if l_new_appl_status is null then
        com_api_error_pkg.raise_error (
            i_error       => 'APPLICATION_TRANSITION_NOT_FOUND'
          , i_env_param1  => l_stage_id 
          , i_env_param2  => i_reason_code
          , i_mask_error  => com_api_type_pkg.boolean_not(i_raise_error)
        ); 
    end if;
    
    modify_application(
        i_appl_id           => i_appl_id
      , io_seqnum           => io_seqnum
      , i_appl_status       => l_new_appl_status
      , i_resp_sess_file_id => i_resp_sess_file_id
      , i_comments          => i_comments
      , i_change_action     => i_change_action
      , i_reject_code       => l_new_reject_code
      , i_event_type        => i_event_type
      , i_user_id           => i_user_id
      , i_appl_prioritized  => i_appl_prioritized
      , i_skip_oper_process => i_skip_oper_process
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when com_api_error_pkg.e_application_error then
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED'); 
        if i_raise_error = com_api_const_pkg.TRUE then
            raise; 
        end if;
    when others then
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED ' || sqlerrm);
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        else
            raise;
        end if;
end;

/*
 * Check if PRODUCT_ID exists, if not then try to find it by PRODUCT_NUMBER and add to the application
 */
procedure check_product_id(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
    l_parent_id                 com_api_type_pkg.t_long_id;
    l_product_id                com_api_type_pkg.t_short_id;
    l_product_number            com_api_type_pkg.t_name;
    l_contract_number           com_api_type_pkg.t_name;
begin
    begin
        select parent_id
             , max(case when upper(name) = 'PRODUCT_ID'
                        then to_number(element_value, com_api_const_pkg.NUMBER_FORMAT)
                        else null
                   end) as product_id
             , max(case when upper(name) = 'PRODUCT_NUMBER'
                        then element_value
                        else null
                   end) as product_number
          into l_parent_id
             , l_product_id
             , l_product_number
          from app_data_vw
         where name    in ('PRODUCT_ID', 'PRODUCT_NUMBER')
           and appl_id  = i_appl_id
         group by parent_id;
    exception
        when no_data_found then
            select parent_id
                 , max(case when upper(name) = 'CONTRACT_NUMBER'
                            then element_value
                            else null
                       end) as contract_number
              into l_parent_id
                 , l_contract_number
              from app_data_vw
             where name    in ('CONTRACT_NUMBER')
               and appl_id  = i_appl_id
             group by parent_id;
    end;

    if l_product_id is null then
        if l_product_number is not null then
            -- Try to find product by PRODUCT_NUMBER
            l_product_id := prd_api_product_pkg.get_product_id(
                                i_product_number  => l_product_number
                              , i_inst_id         => i_inst_id
                            );
        else
            l_product_id := prd_api_product_pkg.get_product_id(
                                i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
                              , i_object_id       => prd_api_contract_pkg.get_contract(
                                                         i_contract_id           => null
                                                       , i_contract_number       => l_contract_number
                                                       , i_inst_id               => i_inst_id
                                                       , i_raise_error           => com_api_type_pkg.TRUE
                                                     ).id
                            );
        end if;

        if l_product_id is null then
            raise no_data_found;
        end if;

        trc_log_pkg.debug(
            i_text => 'insert into appl_data [check_product_id]: element_name=PRODUCT_ID'
                   || ', element_value=' || l_product_id
                   || ', element_id='    || app_api_const_pkg.ELEMENT_PRODUCT_ID
                   || ', parent_id='     || l_parent_id
        );

        insert into app_data(
            id
          , split_hash
          , appl_id
          , element_id
          , parent_id
          , serial_number
          , element_value
          , is_auto
          , lang
        ) values (
            get_next_appl_data_id(i_appl_id)
          , i_split_hash
          , i_appl_id
          , app_api_const_pkg.ELEMENT_PRODUCT_ID
          , l_parent_id
          , 1
          , to_char(l_product_id, com_api_const_pkg.NUMBER_FORMAT)
          , com_api_type_pkg.FALSE
          , null
        );
    end if;
exception
    when no_data_found then
        trc_log_pkg.error(
            i_text       => 'PRODUCT_NOT_FOUND'
          , i_env_param1 => l_product_number
        );
end check_product_id;

/*
 * Check if AGENT_ID exists, if not then try to find it by AGENT_NUMBER and add to the application
 */
procedure check_agent_id(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
    l_parent_id                 com_api_type_pkg.t_long_id;
    l_agent_id                  com_api_type_pkg.t_agent_id;
    l_agent_number              com_api_type_pkg.t_name;
begin
    select parent_id
         , max(case when upper(name) = 'AGENT_ID'
                    then to_number(element_value, com_api_const_pkg.NUMBER_FORMAT)
                    else null
               end) as agent_id
         , max(case when upper(name) = 'AGENT_NUMBER'
                    then element_value
                    else null
               end) as agent_number
      into l_parent_id
         , l_agent_id
         , l_agent_number
      from app_data_vw
     where name    in ('AGENT_ID', 'AGENT_NUMBER')
       and appl_id  = i_appl_id
     group by parent_id;

    if l_agent_id is null then
        -- Try to find agent by AGENT_NUMBER
        l_agent_id := ost_api_agent_pkg.get_agent_id(
                          i_agent_id      => null
                        , i_agent_number  => l_agent_number
                        , i_inst_id       => i_inst_id
                        , i_mask_error    => com_api_type_pkg.TRUE
                      );

        if l_agent_id is null then
            raise no_data_found;
        end if;

        trc_log_pkg.debug(
            i_text => 'insert into appl_data [check_agent_id]: element_name=AGENT_ID'
                   || ', element_value=' || l_agent_id
                   || ', element_id='    || app_api_const_pkg.ELEMENT_AGENT_ID
                   || ', parent_id='     || l_parent_id
        );

        insert into app_data(
            id
          , split_hash
          , appl_id
          , element_id
          , parent_id
          , serial_number
          , element_value
          , is_auto
          , lang
        ) values (
            get_next_appl_data_id(i_appl_id)
          , i_split_hash
          , i_appl_id
          , app_api_const_pkg.ELEMENT_AGENT_ID
          , l_parent_id
          , 1
          , to_char(l_agent_id, com_api_const_pkg.NUMBER_FORMAT)
          , com_api_type_pkg.FALSE
          , null
        );
    end if;
exception
    when no_data_found then
        trc_log_pkg.error(
            i_text       => 'AGENT_NOT_FOUND'
          , i_env_param1 => l_agent_number
        );
end check_agent_id;

procedure check_card_count(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_appl_data         in      app_data_tpt
) is
    l_appl_data_id        com_api_type_pkg.t_long_id;
    l_card_count          com_api_type_pkg.t_long_id;
    l_batch_card_count    com_api_type_pkg.t_long_id;

    l_application_count   com_api_type_pkg.t_long_id;
    l_non_last_card_count com_api_type_pkg.t_long_id;
    l_last_card_count     com_api_type_pkg.t_long_id;

    l_application_rec     app_api_type_pkg.t_application_rec;
    l_error_index         pls_integer;
    l_new_appl_id_tab     com_api_type_pkg.t_long_tab;
    l_new_appl_data_tab   app_data_tpt;

    type t_cached_id_tab  is table of com_api_type_pkg.t_long_id index by com_api_type_pkg.t_name;
    l_cached_data_id_tab  t_cached_id_tab;

    type t_application_tab is table of app_api_type_pkg.t_application_rec index by binary_integer;
    l_application_tab     t_application_tab;
    l_element_count       com_api_type_pkg.t_count := 0;
    l_big_element_count   com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug('check_card_count Start');
    -- check for there are no several CARD_COUNT elements with at least one has got value greater than 9999
    for i in 1 .. i_appl_data.count loop
        if i_appl_data(i).element_id = app_api_const_pkg.ELEMENT_CARD_COUNT then
            l_element_count := l_element_count + 1;
            if i_appl_data(i).element_value_n > app_api_const_pkg.MAX_SEQ_NUMBER then
                l_big_element_count := l_big_element_count + 1;
            end if;
        end if;
    end loop;

    if l_element_count = 0
    or (l_element_count > 0 and l_big_element_count = 0)
    then
        -- Tag "card_count" is not found in application or each tag "card_count" has got small value.
        return;
    elsif l_element_count = 1 and l_big_element_count = 1 then
        -- one "card_count" tag with value greater than 9999 - continue, split it into many applications        
        null;
    elsif l_element_count > 1 and  l_big_element_count >= 1
    then
        -- many "card_count" tag with at least one is greater than 9999
        com_api_error_pkg.raise_error(
            i_error        => 'CARD_COUNT_TOO_BIG'
        );
    else
        -- Something strange is happening
        com_api_error_pkg.raise_error(
            i_error        => 'CARD_COUNT_TOO_BIG'
        );
    end if;

    -- get unique values of tags "card_count" and "batch_card_count"
    for i in 1 .. i_appl_data.count loop
        if i_appl_data(i).element_id = app_api_const_pkg.ELEMENT_CARD_COUNT then
            if l_card_count is null then
                l_card_count   := i_appl_data(i).element_value_n;
                l_appl_data_id := i_appl_data(i).appl_data_id;
            else
                com_api_error_pkg.raise_error(
                    i_error       => 'APPLICATION_TAG_IS_NOT_UNIQUE'
                  , i_env_param1  => i_appl_id
                  , i_env_param2  => i_appl_data(i).element_id
                );
            end if;
        elsif i_appl_data(i).element_id = app_api_const_pkg.ELEMENT_BATCH_CARD_COUNT then
            if l_batch_card_count is null then
                l_batch_card_count := i_appl_data(i).element_value_n;
            else
                com_api_error_pkg.raise_error(
                    i_error       => 'APPLICATION_TAG_IS_NOT_UNIQUE'
                  , i_env_param1  => i_appl_id
                  , i_env_param2  => i_appl_data(i).element_id
                );
            end if;
        end if;
    end loop;

    if l_card_count    is null
       or l_card_count <= app_api_const_pkg.MAX_SEQ_NUMBER
    then
        -- Tag "card_count" is not found in application or tag "card_count" has got small value.
        return;
    end if;

    app_api_application_pkg.calculate_new_card_count(
        i_card_count           => l_card_count
      , i_batch_card_count     => l_batch_card_count
      , o_application_count    => l_application_count
      , o_non_last_card_count  => l_non_last_card_count
      , o_last_card_count      => l_last_card_count
    );

    trc_log_pkg.debug(
        i_text       => 'check_card_count: card_count [#1], batch_card_count [#2], application_count [#3], non_last_card_count [#4], last_card_count [#5]'
      , i_env_param1 => l_card_count
      , i_env_param2 => l_batch_card_count
      , i_env_param3 => l_application_count
      , i_env_param4 => l_non_last_card_count
      , i_env_param5 => l_last_card_count
    );

    -- get first application
    select id
         , appl_type
         , appl_number
         , appl_status
         , flow_id
         , reject_code
         , agent_id
         , inst_id
         , null --file_id
         , file_rec_num
         , null --resp_file_id
         , product_id
         , split_hash
         , seqnum
         , user_id
         , is_visible
         , appl_prioritized
         , execution_mode
      into l_application_rec
      from app_application
     where id = i_appl_id;

    -- create non-first applications
    for i in 2 .. l_application_count loop
        l_new_appl_id_tab(i) := com_api_id_pkg.get_id(
                                    i_seq       => app_application_seq.nextval
                                  , i_object_id => i_appl_id
                                );
    end loop;

    begin
        forall i in 2 .. l_application_count
            insert into app_application (
                id
              , appl_type
              , appl_number
              , appl_status
              , flow_id
              , reject_code
              , agent_id
              , inst_id
              , session_file_id
              , file_rec_num
              , resp_session_file_id
              , product_id
              , split_hash
              , user_id
              , is_visible
              , seqnum
              , is_template
              , appl_prioritized
            ) values (
                l_new_appl_id_tab(i)
              , l_application_rec.appl_type
              , l_application_rec.appl_number
              , l_application_rec.appl_status
              , l_application_rec.flow_id
              , l_application_rec.reject_code
              , l_application_rec.agent_id
              , l_application_rec.inst_id
              , l_application_rec.file_id
              , l_application_rec.file_rec_num
              , l_application_rec.resp_file_id
              , l_application_rec.product_id
              , l_application_rec.split_hash
              , l_application_rec.user_id
              , l_application_rec.is_visible
              , 1
              , com_api_type_pkg.FALSE
              , l_application_rec.appl_prioritized
            );
    exception
        when others then
            l_error_index := sql%bulk_exceptions(1).error_index;
            trc_log_pkg.debug(
                i_text       => 'inserting in APP_APPLICATION failed: iteration [#1], error code [#2], appl_id [#3]'
              , i_env_param1 => l_error_index
              , i_env_param2 => sqlerrm(-sql%bulk_exceptions(1).error_code)
              , i_env_param3 => l_application_tab(l_error_index).id
            );
            raise;
    end;

    -- update card_count for first application and insert data for non-first applications
    for i in 1 .. l_application_count loop
        if i = 1 then                       -- first application
            update app_data
               set element_value = to_char(l_non_last_card_count, com_api_const_pkg.NUMBER_FORMAT)
             where id = l_appl_data_id;

            trc_log_pkg.debug(
                i_text       => 'check_card_count: modify appl_id [#1]'
              , i_env_param1 => i_appl_id
            );

        else                                -- other applications
            trc_log_pkg.debug(
                i_text       => 'check_card_count: add appl_id [#1]'
              , i_env_param1 => l_new_appl_id_tab(i)
            );

            l_cached_data_id_tab.delete;

            l_new_appl_data_tab := i_appl_data;

            -- assign new "app_data.id"
            for j in 1 .. l_new_appl_data_tab.count loop
                l_new_appl_data_tab(j).appl_data_id := get_next_appl_data_id(
                                                           i_appl_id => i_appl_id
                                                       );
                l_cached_data_id_tab(i_appl_data(j).appl_data_id) := l_new_appl_data_tab(j).appl_data_id;

                if i_appl_data(j).element_id = app_api_const_pkg.ELEMENT_CARD_COUNT then
                    if i = l_application_count then
                        l_new_appl_data_tab(j).element_value_n := l_last_card_count;
                    else
                        l_new_appl_data_tab(j).element_value_n := l_non_last_card_count;
                    end if;
                end if;
            end loop;

            -- assign new "app_data.parent_id"
            for j in 1 .. l_new_appl_data_tab.count loop
                if i_appl_data(j).parent_id is not null then
                    l_new_appl_data_tab(j).parent_id := l_cached_data_id_tab(i_appl_data(j).parent_id);
                end if;
            end loop;

            begin
                forall j in 1 .. l_new_appl_data_tab.count
                    insert into app_data (
                        id
                      , appl_id
                      , element_id
                      , parent_id
                      , serial_number
                      , element_value
                      , is_auto
                      , lang
                      , split_hash                     
                    ) values (
                        l_new_appl_data_tab(j).appl_data_id
                      , l_new_appl_id_tab(i)
                      , l_new_appl_data_tab(j).element_id
                      , l_new_appl_data_tab(j).parent_id
                      , l_new_appl_data_tab(j).serial_number
                      , coalesce(
                            to_char(l_new_appl_data_tab(j).element_value_n, com_api_const_pkg.NUMBER_FORMAT)
                          , to_char(l_new_appl_data_tab(j).element_value_d, com_api_const_pkg.DATE_FORMAT)
                          , case
                                when (select e.name from app_element_all_vw e where e.id = l_new_appl_data_tab(j).element_id) like '%CARD_NUMBER'
                                then iss_api_token_pkg.encode_card_number(i_card_number => l_new_appl_data_tab(j).element_value_v)
                                else l_new_appl_data_tab(j).element_value_v
                            end
                        )
                      , com_api_type_pkg.FALSE
                      , l_new_appl_data_tab(j).lang
                      , l_application_rec.split_hash                     
                    );

            exception
                when others then
                    l_error_index := sql%bulk_exceptions(1).error_index;
                    trc_log_pkg.debug(
                        i_text       => 'inserting in APP_DATA failed: iteration [#1], error code [#2], {id [#3], parent_id [#4]}'
                      , i_env_param1 => l_error_index
                      , i_env_param2 => sqlerrm(-sql%bulk_exceptions(1).error_code)
                      , i_env_param3 => l_new_appl_data_tab(l_error_index).appl_data_id
                      , i_env_param4 => l_new_appl_data_tab(l_error_index).parent_id
                    );
                    raise;
            end;
        end if;
    end loop;

    trc_log_pkg.debug('check_card_count Finish');
end check_card_count;

procedure modify_application_data(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_appl_data         in      app_data_tpt
  , i_is_new            in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
) is
    l_is_new                    com_api_type_pkg.t_boolean     := nvl(i_is_new, com_api_type_pkg.FALSE);
    l_audit_activated           com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE;
    l_entity_type               com_api_type_pkg.t_dict_value  := app_api_const_pkg.ENTITY_TYPE_APPLICATION;
    l_trail_id                  com_api_type_pkg.t_long_id;
    l_action_type               com_api_type_pkg.t_dict_value;
    l_changed_count             com_api_type_pkg.t_count       := 0;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_appl_type                 com_api_type_pkg.t_dict_value;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_appl_number               com_api_type_pkg.t_name;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_count                     com_api_type_pkg.t_long_id;
    l_sysdate                   date := com_api_sttl_day_pkg.get_sysdate();

    l_masked_element_value      com_api_type_pkg.t_full_desc; -- element's value with masked secret data (where applicable)
    l_new_element_value         com_api_type_pkg.t_full_desc;
    l_old_appl_status           com_api_type_pkg.t_dict_value;
    l_old_reject_code           com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug('app_ui_application_pkg.modify_application_data, i_appl_id ['||i_appl_id||']');

    l_split_hash := com_api_hash_pkg.get_split_hash(
                        i_entity_type => app_api_const_pkg.ENTITY_TYPE_APPLICATION
                      , i_object_id   => i_appl_id
                    );

    begin
        select is_active
          into l_audit_activated
          from adt_entity
         where entity_type = l_entity_type;
    exception
        when no_data_found then
            l_audit_activated := com_api_type_pkg.FALSE;
    end;

    l_action_type := 'UPDATE';

    if l_audit_activated = com_api_type_pkg.TRUE then
        l_trail_id := adt_api_trail_pkg.get_trail_id;
    end if;

    for i in (
        select a.appl_data_id
             , a.element_id
             , a.parent_id
             , a.serial_number
             , coalesce(
                   a.element_value_v
                 , to_char(a.element_value_d, com_api_const_pkg.DATE_FORMAT)
                 , to_char(a.element_value_n, com_api_const_pkg.NUMBER_FORMAT)
               ) as new_element_value
             , 0
             , a.lang
             , b.element_value old_element_value
             , nvl2(b.id, com_api_const_pkg.TRUE, com_api_const_pkg.FALSE) as element_exist
             , e.name as element_name
          from table(cast(i_appl_data as app_data_tpt)) a
             , app_data b
             , app_element_all_vw e
         where a.appl_data_id = b.id(+)
           and e.id           = a.element_id
    ) loop
        -- Masking values of application's element with secret data
        if i.element_name like '%CARD_NUMBER' then
            l_new_element_value := iss_api_token_pkg.encode_card_number(i_card_number => i.new_element_value);
            l_masked_element_value := iss_api_card_pkg.get_card_mask(i_card_number => i.new_element_value);
        else
            l_new_element_value := i.new_element_value;
            l_masked_element_value :=
                case when i.element_name like '%CVV%' or i.element_name like '%CVC%'
                     then '********'
                     else i.new_element_value
                end;
        end if;

        if i.element_exist = com_api_const_pkg.TRUE then
            if i.serial_number is not null and (i.new_element_value != i.old_element_value or i.old_element_value is null) then
                trc_log_pkg.debug('update app_data: id=' || i.appl_data_id || ', value=' || l_masked_element_value || ', lang=' || i.lang);
                update app_data
                   set element_value = l_new_element_value
                     , lang = i.lang
                 where id = i.appl_data_id;
            elsif i.serial_number is null then
                trc_log_pkg.debug('delete from app_data: id=' ||i.appl_data_id);
                delete from app_data
                 where id in (select id from app_data connect by prior id = parent_id start with id = i.appl_data_id);
            end if;

        else
            if i.serial_number is not null then
                trc_log_pkg.debug('insert into appl_data: element_name=' || i.element_name ||
                                  ', element_value='|| l_masked_element_value ||
                                  ', element_id=' || i.element_id || ', parent_id=' || i.parent_id ||
                                  ', id=' || i.appl_data_id);

                insert into app_data(
                    id
                  , split_hash
                  , appl_id
                  , element_id
                  , parent_id
                  , serial_number
                  , element_value
                  , is_auto
                  , lang
                ) values (
                    i.appl_data_id
                  , l_split_hash
                  , i_appl_id
                  , i.element_id
                  , i.parent_id
                  , i.serial_number
                  , l_new_element_value
                  , com_api_type_pkg.FALSE
                  , i.lang
                );
            end if;
        end if;

        if l_audit_activated = com_api_type_pkg.TRUE and i.serial_number is not null then
            adt_api_trail_pkg.check_value(
                i_trail_id       => l_trail_id
              , i_column_name    => i.element_name
              , i_old_value      => i.old_element_value
              , i_new_value      => i.new_element_value
              , io_changed_count => l_changed_count
            );
        end if;
    end loop;

    if l_changed_count > 0 then
        adt_api_trail_pkg.put_audit_trail(
            i_trail_id          => l_trail_id
          , i_entity_type       => l_entity_type
          , i_object_id         => nvl(null, i_appl_id)
          , i_action_type       => l_action_type
        );
    end if;

    -- Check application number
    select appl_number
         , appl_status
         , reject_code
         , appl_type
         , inst_id
      into l_appl_number
         , l_old_appl_status
         , l_old_reject_code
         , l_appl_type
         , l_inst_id
      from app_application
     where id = i_appl_id;

    -- Check existance of mandatory elements product_id and agent_id (add if missing)
    -- if they are defined in structure of the application type.
    if  app_api_structure_pkg.element_exists(
            i_appl_type  => l_appl_type
          , i_element_id => app_api_const_pkg.ELEMENT_PRODUCT_ID
        ) = com_api_const_pkg.TRUE
    then
        check_product_id(
            i_appl_id     => i_appl_id
          , i_inst_id     => l_inst_id
          , i_split_hash  => l_split_hash
        );
    end if;

    if  app_api_structure_pkg.element_exists(
            i_appl_type         => l_appl_type
          , i_element_id        => app_api_const_pkg.ELEMENT_AGENT_ID
          , i_parent_element_id => app_api_const_pkg.ELEMENT_APPLICATION
        ) = com_api_const_pkg.TRUE
    then
        check_agent_id(
            i_appl_id     => i_appl_id
          , i_inst_id     => l_inst_id
          , i_split_hash  => l_split_hash
        );
    end if;

    if l_old_appl_status = app_api_const_pkg.APPL_STATUS_PROC_DUPLICATED then
        app_api_error_pkg.add_error_element(
            i_appl_id       => i_appl_id
          , i_error_code    => 'EXTERNAL_APPL_NUMBER_IS_NOT_UNIQUE'
          , i_error_message => 'Unable to create application because external application number ['||l_appl_number||'] with institution ['||to_char(l_inst_id)||'] already exists'
          , i_error_details => 'APPL_NUMBER = ['||l_appl_number||'], INST_ID = ['||to_char(l_inst_id)||']'
          , i_error_element => 'APPLICATION'
        );
        evt_api_event_pkg.register_event_autonomous(
            i_event_type    => app_api_const_pkg.EVENT_APPL_PROCESS_FAILED
          , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
          , i_param_tab     => l_param_tab
          , i_entity_type   => app_api_const_pkg.ENTITY_TYPE_APPLICATION
          , i_object_id     => i_appl_id
          , i_inst_id       => l_inst_id
          , i_split_hash    => com_api_hash_pkg.get_split_hash(
                                   i_entity_type => app_api_const_pkg.ENTITY_TYPE_APPLICATION
                                 , i_object_id   => i_appl_id
                               )
        );
    end if;

    select count(1)
      into l_count
      from app_history
     where appl_id = i_appl_id;

    trc_log_pkg.debug('count of app_history is '||l_count);

    if l_count <= 1 then 
        evt_api_event_pkg.register_event(
            i_event_type  => app_api_const_pkg.EVENT_APPL_CREATED
          , i_eff_date    => l_sysdate
          , i_entity_type => app_api_const_pkg.ENTITY_TYPE_APPLICATION
          , i_object_id   => i_appl_id
          , i_inst_id     => l_inst_id
          , i_split_hash  => l_split_hash
          , i_param_tab   => l_param_tab
          , i_status      => evt_api_const_pkg.EVENT_STATUS_READY
        );
    end if;    

    app_api_history_pkg.add_history (
        i_appl_id         => i_appl_id
      , i_action          => app_api_const_pkg.APPL_ACTION_DATA_CHANGE
      , i_comments        => null
      , i_new_appl_status => l_old_appl_status
      , i_old_appl_status => l_old_appl_status
      , i_new_reject_code => l_old_reject_code
      , i_old_reject_code => l_old_reject_code
    );

    if l_is_new = com_api_type_pkg.TRUE then
        check_card_count(
            i_appl_id   => i_appl_id
          , i_appl_data => i_appl_data
        );
    end if;

end modify_application_data;

procedure remove_application(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_tiny_id
) is
begin
    trc_log_pkg.debug('remove_application, seqnum='||i_seqnum);

    check_seqnum(
        i_appl_id => i_appl_id
      , i_seqnum  => i_seqnum
    );

    -- check relations
    for rec in (select a.template_appl_id from app_flow a where a.template_appl_id = i_appl_id)
    loop
        com_api_error_pkg.raise_error(
            i_error => 'SYSTEM_APPL_CAN_NOT_BE_REMOVED'
          , i_env_param1 => i_appl_id
        );
    end loop;

    delete from app_data_vw where appl_id = i_appl_id;

    update app_application_vw
       set seqnum = i_seqnum
     where id     = i_appl_id;

    delete from app_application_vw where id = i_appl_id;

    app_api_history_pkg.remove_history (
        i_id  => i_appl_id
    );

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'APPLICATION_NOT_FOUND'
          , i_env_param1 => i_appl_id
        );
    when com_api_error_pkg.e_resource_busy then
        com_api_error_pkg.raise_error(
            i_error      => 'APPLICATION_IN_PROCESS'
          , i_env_param1 => i_appl_id
        );
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end remove_application;

function get_next_appl_id return com_api_type_pkg.t_long_id is
begin
    return com_api_id_pkg.get_id(app_application_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
end;

function get_next_appl_data_id (
    i_appl_id           in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id is
begin
    return com_api_id_pkg.get_id(app_data_seq.nextval, to_date(substr(to_char(i_appl_id), 1, 6), 'yymmdd'));
end;

procedure process_application(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_forced_processing in      com_api_type_pkg.t_boolean          default null
) is
    l_appl_status               com_api_type_pkg.t_dict_value;
begin
    app_api_application_pkg.set_appl_id(
        i_appl_id     => i_appl_id
    );
    app_process_pkg.processing(
        i_appl_id           => i_appl_id
      , i_forced_processing => i_forced_processing
      , o_appl_status       => l_appl_status
    );
end;

function get_xml (
    i_appl_id  in     com_api_type_pkg.t_long_id
) return clob is
begin
    return app_api_application_pkg.get_xml(
               i_appl_id  => i_appl_id
           );
end;

function get_xml_with_id (
    i_appl_id  in     com_api_type_pkg.t_long_id
) return clob is
begin
    return app_api_application_pkg.get_xml_with_id(
               i_appl_id  => i_appl_id
           );
end;

procedure main_handler(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , o_result               out  com_api_type_pkg.t_dict_value
) is
    l_appl_data_id  com_api_type_pkg.t_long_id;
    l_appl_type     com_api_type_pkg.t_dict_value;
    l_appl_status   com_api_type_pkg.t_dict_value;
    l_inst_id       com_api_type_pkg.t_inst_id;
begin
    savepoint sp_before_app_process;

    trc_log_pkg.set_object(
        i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id    => i_appl_id
    );

    app_api_error_pkg.g_app_errors.delete();

    com_api_sttl_day_pkg.set_sysdate;

    begin
        select appl_type
             , appl_status
             , inst_id
          into l_appl_type
             , l_appl_status
             , l_inst_id
          from app_application_vw
         where id = i_appl_id
           for update nowait;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'APPLICATION_NOT_FOUND'
              , i_env_param1    => i_appl_id
            );
        when com_api_error_pkg.e_resource_busy then
            com_api_error_pkg.raise_error(
                i_error         => 'APPLICATION_IN_PROCESS'
              , i_env_param1    => i_appl_id
            );
    end;

    app_api_application_pkg.set_appl_id(i_appl_id);

    app_api_application_pkg.get_appl_data(
        i_appl_id        => i_appl_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_appl_data_id
    );

    trc_log_pkg.debug('Application errors count: '||app_api_error_pkg.g_app_errors.count);
    begin
        if l_appl_type = app_api_const_pkg.APPL_TYPE_ACQUIRING then
            aap_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_ISSUING then
            iap_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_PAYMENT_ORDERS then
            pmo_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT then
            acm_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_INSTITUTION then
            ost_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_CAMPAIGN then
            cpn_api_application_pkg.process_application( 
                i_appl_id    => i_appl_id
            );

        else
            app_api_error_pkg.raise_error(
                i_error         => 'UNKNOWN_APPLICATION_TYPE'
              , i_env_param1    => l_appl_type
              , i_element_name  => 'APPLICATION'
              , i_appl_data_id  => l_appl_data_id
            );
        end if;
    exception
        when com_api_error_pkg.e_stop_appl_processing then
            trc_log_pkg.debug('e_stop_appl_processing exception was handled');
    end;

    trc_log_pkg.debug('Application errors count: '||app_api_error_pkg.g_app_errors.count);
    if app_api_error_pkg.g_app_errors.count > 0 then
        o_result := app_api_const_pkg.FLOW_STAGE_PROCESS_FAIL;
        -- we rollback changes, maded by app process package such as new contracts etc
        begin
            rollback to sp_before_app_process;
        exception
            when com_api_error_pkg.e_savepoint_never_established then
                rollback;
        end;

        app_api_error_pkg.add_errors_to_app_data;

    else
        o_result := app_api_const_pkg.FLOW_STAGE_PROCESS_SUCCESS;
    end if;

    com_api_sttl_day_pkg.unset_sysdate;

exception
    when others then
        com_api_sttl_day_pkg.unset_sysdate;

        begin
            rollback to sp_before_app_process;
        exception
            when com_api_error_pkg.e_savepoint_never_established then
                rollback;
        end;

        app_api_error_pkg.intercept_error (
            i_appl_data_id    => l_appl_data_id
            , i_element_name  => 'APPLICATION'
        );

        app_api_error_pkg.add_errors_to_app_data;

        o_result := app_api_const_pkg.FLOW_STAGE_PROCESS_FAIL;
end main_handler;

-- Migrate
-- Internal method
procedure add_application_migrate(
    io_appl_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_appl_number       in      com_api_type_pkg.t_name
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_appl_status       in      com_api_type_pkg.t_dict_value       default null
  , i_session_file_id   in      com_api_type_pkg.t_long_id          default null
  , i_file_rec_num      in      com_api_type_pkg.t_tiny_id          default null
  , i_customer_type     in      com_api_type_pkg.t_dict_value       default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_execution_mode    in      com_api_type_pkg.t_dict_value       default null
) is
    l_template_appl_id          com_api_type_pkg.t_long_id;
    l_appl_data_id              com_api_type_pkg.t_long_id;
    l_parent_id                 com_api_type_pkg.t_long_id;
    l_count                     pls_integer := 0;
    l_appl_data_templ           app_data_tpt := app_data_tpt(app_data_tpr(null, null, null, null, null, null, null, null));
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_sysdate                   date := com_api_sttl_day_pkg.get_sysdate;

    procedure save_appl_element_n(
        i_element_name      in      com_api_type_pkg.t_name
      , i_element_value     in      number
    ) is
    begin
        if i_element_value is null then return; end if;

        select appl_data_id
          into l_appl_data_id
          from table(cast(l_appl_data_templ as app_data_tpt))
         where element_id = app_api_element_pkg.get_element_id(i_element_name)
           and parent_id  = l_parent_id;

        for i in 1..l_appl_data_templ.count loop
            if l_appl_data_templ(i).appl_data_id = l_appl_data_id then
                l_appl_data_templ(i).element_value_n := i_element_value;
                exit;
            end if;
        end loop;
    exception
        when no_data_found then
            l_appl_data_templ.extend;
            l_appl_data_templ(l_appl_data_templ.count) :=
                app_data_tpr(
                    get_next_appl_data_id (
                        i_appl_id => io_appl_id
                    )
                  , app_api_element_pkg.get_element_id(i_element_name)
                  , l_parent_id
                  , 1
                  , null
                  , null
                  , i_element_value
                  , null
                );
    end;

    procedure save_appl_element_v(
        i_element_name      in      com_api_type_pkg.t_name
      , i_element_value     in      com_api_type_pkg.t_name
    ) is
    begin
        if i_element_value is null then return; end if;

        select appl_data_id
          into l_appl_data_id
          from table(cast(l_appl_data_templ as app_data_tpt))
         where element_id = app_api_element_pkg.get_element_id(i_element_name)
           and parent_id  = l_parent_id;

        for i in 1..l_appl_data_templ.count loop
            if l_appl_data_templ(i).appl_data_id = l_appl_data_id then
                l_appl_data_templ(i).element_value_v := i_element_value;
                exit;
            end if;
        end loop;
    exception
        when no_data_found then
            l_appl_data_templ.extend;
            l_appl_data_templ(l_appl_data_templ.count) :=
                app_data_tpr(
                    get_next_appl_data_id (
                        i_appl_id => io_appl_id
                    )
                  , app_api_element_pkg.get_element_id(i_element_name)
                  , l_parent_id
                  , 1
                  , i_element_value
                  , null
                  , null
                  , null
                );
    end;

begin
    o_seqnum := 1;

    if i_flow_id is not null then
        begin
            select template_appl_id
              into l_template_appl_id
              from app_flow_vw
             where id = i_flow_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'APPLICATION_FLOW_NOT_FOUND'
                  , i_env_param1    => i_appl_type
                  , i_env_param2    => i_flow_id
                );
        end;
    end if;

    if io_appl_id is null then
        io_appl_id := com_api_id_pkg.get_id(app_application_seq.nextval, l_sysdate);
    end if;

    l_split_hash := coalesce(i_split_hash, com_api_hash_pkg.get_split_hash(i_value => io_appl_id));

    if i_appl_number is not null then
        select count(1)
          into l_count
          from app_application a
         where inst_id     = i_inst_id
           and appl_number = i_appl_number;

        if l_count > 0 then
            com_api_error_pkg.raise_error (
                i_error       =>  'EXTERNAL_APPL_NUMBER_IS_NOT_UNIQUE'
              , i_env_param1  => i_appl_number
              , i_env_param2  => i_inst_id
            );
        end if;
    end if;

    if l_template_appl_id is not null then
        -- get template elements
        select
            app_data_tpr(
                id
              , element_id
              , parent_id
              , serial_number
              , element_value -- element %CARD_NUMBER can't be in an application template
              , null
              , null
              , null
            )
          bulk collect into l_appl_data_templ
          from app_data_vw
         where appl_id = l_template_appl_id;

        -- replace template elements identifiers with new values
        for i in 1..l_appl_data_templ.count loop
            l_appl_data_id := get_next_appl_data_id (
                i_appl_id => io_appl_id
            );

            for j in 1..l_appl_data_templ.count loop
                if l_appl_data_templ(j).parent_id = l_appl_data_templ(i).appl_data_id then
                    l_appl_data_templ(j).parent_id := l_appl_data_id;
                end if;
            end loop;

            l_appl_data_templ(i).appl_data_id := l_appl_data_id;
        end loop;
    end if;

    if i_session_file_id is null then
        begin
            select appl_data_id
              into l_parent_id
              from table(cast(l_appl_data_templ as app_data_tpt))
             where element_id = app_api_element_pkg.get_element_id('APPLICATION')
               and parent_id is null;
        exception
            when no_data_found then
                l_appl_data_templ.delete;
                l_appl_data_templ.extend;
                l_appl_data_templ(l_appl_data_templ.count) :=
                    app_data_tpr(
                        get_next_appl_data_id (
                            i_appl_id => io_appl_id
                        )
                      , app_api_element_pkg.get_element_id('APPLICATION')
                      , null
                      , 1
                      , null
                      , null
                      , null
                      , null
                    );
                l_parent_id := l_appl_data_templ(1).appl_data_id;
        end;

        save_appl_element_n('APPLICATION_ID', io_appl_id);

        save_appl_element_n('INSTITUTION_ID', i_inst_id);

        save_appl_element_n(
            'AGENT_ID'
          , nvl(
                i_agent_id
              , acm_ui_user_pkg.get_default_agent(
                    i_user_id => get_user_id
                  , i_inst_id => i_inst_id
                )
            )
        );

        save_appl_element_n('APPLICATION_FLOW_ID', i_flow_id);

        save_appl_element_v('APPLICATION_STATUS', nvl(i_appl_status, app_api_const_pkg.APPL_STATUS_INITIAL));

        save_appl_element_v('APPLICATION_TYPE', i_appl_type);

        save_appl_element_v('OPERATOR_ID', nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), user));

        save_appl_element_v('CUSTOMER_TYPE', i_customer_type);
    end if;

    insert into app_application_vw(
        id
      , seqnum
      , split_hash
      , appl_type
      , appl_number
      , flow_id
      , appl_status
      , reject_code
      , inst_id
      , agent_id
      , session_file_id
      , file_rec_num
      , is_template
      , appl_prioritized
      , execution_mode
    ) values (
        io_appl_id
      , o_seqnum
      , l_split_hash
      , i_appl_type
      , i_appl_number
      , i_flow_id
      , nvl(i_appl_status, app_api_const_pkg.APPL_STATUS_INITIAL)
      , null
      , i_inst_id
      , nvl(i_agent_id, ost_ui_institution_pkg.get_default_agent(i_inst_id))
      , i_session_file_id
      , i_file_rec_num
      , 0
      , nvl(i_appl_prioritized, com_api_const_pkg.FALSE)
      , i_execution_mode
    );

    evt_api_event_pkg.register_event(
        i_event_type  => app_api_const_pkg.EVENT_APPL_CREATED
      , i_eff_date    => l_sysdate
      , i_entity_type => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id   => io_appl_id
      , i_inst_id     => i_inst_id
      , i_split_hash  => l_split_hash
      , i_param_tab   => l_param_tab
      , i_status      => evt_api_const_pkg.EVENT_STATUS_READY
    );

end add_application_migrate;

-- Internal method
procedure modify_data_migrate(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_appl_data         in      app_data_tpt
  , i_is_new            in      com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
) is
    l_is_new                    com_api_type_pkg.t_boolean  := nvl(i_is_new, com_api_type_pkg.FALSE);
    l_split_hash                com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(
                        i_entity_type => app_api_const_pkg.ENTITY_TYPE_APPLICATION
                      , i_object_id   => i_appl_id
                    );

    insert /* +append */ into app_data(
        id
      , split_hash
      , appl_id
      , element_id
      , parent_id
      , serial_number
      , element_value
      , is_auto
      , lang
    )
    select
        a.appl_data_id
      , l_split_hash
      , i_appl_id
      , a.element_id
      , a.parent_id
      , a.serial_number
      , coalesce(
            to_char(a.element_value_d, com_api_const_pkg.DATE_FORMAT)
          , to_char(a.element_value_n, com_api_const_pkg.NUMBER_FORMAT)
          , case
                when e.name like '%CARD_NUMBER'
                then iss_api_token_pkg.encode_card_number(i_card_number => a.element_value_v)
                else a.element_value_v
            end
        ) as new_element_value
      , com_api_type_pkg.FALSE
      , a.lang
    from table(cast(i_appl_data as app_data_tpt)) a join app_element_all_vw e on e.id = a.element_id;

    if l_is_new = com_api_type_pkg.TRUE then
        check_card_count(
            i_appl_id   => i_appl_id
          , i_appl_data => i_appl_data
        );
    end if;

end modify_data_migrate;

procedure get_application(
    i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_appl_number       in      com_api_type_pkg.t_name
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_appl_status       in      com_api_type_pkg.t_dict_value       default null
  , i_customer_type     in      com_api_type_pkg.t_dict_value       default null
  , i_parent_id         in      com_api_type_pkg.t_long_id          default null
  , o_ref_cursor        out     sys_refcursor
) is
    l_template_appl_id          com_api_type_pkg.t_long_id;
    l_appl_data_id              com_api_type_pkg.t_long_id;
    l_parent_id                 com_api_type_pkg.t_long_id;
    l_count                     pls_integer := 0;
    l_appl_data_templ           app_data_tpt := app_data_tpt(app_data_tpr(null, null, null, null, null, null, null, null));
    l_appl_id                   com_api_type_pkg.t_long_id;

    procedure save_appl_element_n(
        i_element_name      in      com_api_type_pkg.t_name
      , i_element_value     in      number
    ) is
    begin
        if i_element_value is null then return; end if;

        select appl_data_id
          into l_appl_data_id
          from table(cast(l_appl_data_templ as app_data_tpt))
         where element_id = app_api_element_pkg.get_element_id(i_element_name)
           and parent_id  = l_parent_id;

        for i in 1..l_appl_data_templ.count loop
            if l_appl_data_templ(i).appl_data_id = l_appl_data_id then
                l_appl_data_templ(i).element_value_n := i_element_value;
                exit;
            end if;
        end loop;
    exception
        when no_data_found then
            l_appl_data_templ.extend;
            l_appl_data_templ(l_appl_data_templ.count) :=
                app_data_tpr(
                    get_next_appl_data_id (
                        i_appl_id => l_parent_id
                    )
                  , app_api_element_pkg.get_element_id(i_element_name)
                  , l_parent_id
                  , 1
                  , null
                  , null
                  , i_element_value
                  , null
                );
    end;

    procedure save_appl_element_v(
        i_element_name      in      com_api_type_pkg.t_name
      , i_element_value     in      com_api_type_pkg.t_name
    ) is
    begin
        if i_element_value is null then return; end if;

        select appl_data_id
          into l_appl_data_id
          from table(cast(l_appl_data_templ as app_data_tpt))
         where element_id = app_api_element_pkg.get_element_id(i_element_name)
           and parent_id  = l_parent_id;

        for i in 1..l_appl_data_templ.count loop
            if l_appl_data_templ(i).appl_data_id = l_appl_data_id then
                l_appl_data_templ(i).element_value_v := i_element_value;
                exit;
            end if;
        end loop;
    exception
        when no_data_found then
            l_appl_data_templ.extend;
            l_appl_data_templ(l_appl_data_templ.count) :=
                app_data_tpr(
                    get_next_appl_data_id (
                        i_appl_id => l_parent_id
                    )
                  , app_api_element_pkg.get_element_id(i_element_name)
                  , l_parent_id
                  , 1
                  , i_element_value
                  , null
                  , null
                  , null
                );
    end;

begin
    trc_log_pkg.debug('get_application start. i_parent_id='||i_parent_id);
    l_parent_id := i_parent_id;
    l_appl_data_templ.delete;

    if i_flow_id is not null then
        begin
            select template_appl_id
              into l_template_appl_id
              from app_flow_vw
             where id = i_flow_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'APPLICATION_FLOW_NOT_FOUND'
                  , i_env_param1    => i_appl_type
                  , i_env_param2    => i_flow_id
                );
        end;
    end if;

    if i_parent_id is null then
        l_appl_id := com_api_id_pkg.get_id(app_application_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
    end if;

    if l_template_appl_id is not null then
        -- get template elements
        select
            app_data_tpr(
                id
              , element_id
              , parent_id
              , serial_number
              , element_value -- element %CARD_NUMBER can't be in an application template
              , null
              , null
              , null
            )
          bulk collect into l_appl_data_templ
          from app_data_vw
         where appl_id = l_template_appl_id;

        -- replace template elements identifiers with new values
        for i in 1..l_appl_data_templ.count loop
            l_appl_data_id := get_next_appl_data_id (
                i_appl_id => l_appl_id
            );

            for j in 1..l_appl_data_templ.count loop
                if l_appl_data_templ(j).parent_id = l_appl_data_templ(i).appl_data_id then
                    l_appl_data_templ(j).parent_id := l_appl_data_id;
                end if;
            end loop;

            l_appl_data_templ(i).appl_data_id := l_appl_data_id;
        end loop;
    end if;
    trc_log_pkg.debug('l_template_appl_id='||l_template_appl_id);
    trc_log_pkg.debug('l_appl_id='||l_appl_id);

    if i_parent_id is null then
        --get header
        begin
            select appl_data_id
              into l_parent_id
              from table(cast(l_appl_data_templ as app_data_tpt))
             where element_id = app_api_element_pkg.get_element_id('APPLICATION')
               and parent_id is null;

        exception
            when no_data_found then
                l_appl_data_templ.delete;
                l_appl_data_templ.extend;
                l_appl_data_templ(l_appl_data_templ.count) :=
                    app_data_tpr(
                        get_next_appl_data_id(i_appl_id => l_appl_id)
                      , app_api_element_pkg.get_element_id('APPLICATION')
                      , null
                      , 1
                      , null
                      , null
                      , null
                      , null
                    );
             l_parent_id := l_appl_data_templ(1).appl_data_id;
        end;
        trc_log_pkg.debug('l_parent_id='||l_parent_id);

    else
        trc_log_pkg.debug('l_parent_id='||l_parent_id);
        if i_appl_number is not null then
            select count(1)
              into l_count
              from app_application a
             where inst_id     = i_inst_id
               and appl_number = i_appl_number;

            if l_count > 0 then
                com_api_error_pkg.raise_error (
                    i_error       => 'EXTERNAL_APPL_NUMBER_IS_NOT_UNIQUE'
                  , i_env_param1  => i_appl_number
                  , i_env_param2  => i_inst_id
                );
            end if;
        end if;

        save_appl_element_n('APPLICATION_NUMBER', i_appl_number);
        save_appl_element_n('APPLICATION_ID', l_appl_id);
        save_appl_element_n('INSTITUTION_ID', i_inst_id);
        if i_appl_type in (app_api_const_pkg.APPL_TYPE_INSTITUTION, app_api_const_pkg.APPL_TYPE_QUESTIONARY) and i_agent_id is null then
            null;
        else
            save_appl_element_n('AGENT_ID'
                              , nvl(i_agent_id
                                  , acm_ui_user_pkg.get_default_agent(
                                        i_user_id => get_user_id
                                      , i_inst_id => i_inst_id
                                    )
                                ));
        end if;
        save_appl_element_n('APPLICATION_FLOW_ID', i_flow_id);
        save_appl_element_v('APPLICATION_STATUS', nvl(i_appl_status, app_api_const_pkg.APPL_STATUS_INITIAL));
        save_appl_element_v('APPLICATION_TYPE', i_appl_type);
        save_appl_element_v('OPERATOR_ID', nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), user));
        save_appl_element_v('CUSTOMER_TYPE', i_customer_type);
    end if;

    open o_ref_cursor for
        select x.data_id
             , x.element_id
             , x.parent_data_id
             , x.serial_number
             , x.element_value
             , com_api_type_pkg.FALSE as is_auto
             , x.lang
             , e.element_type
             , e.name
             , e.data_type
             , e.min_length
             , e.max_length
             , e.min_value
             , e.max_value
             , e.lov_id
             , e.default_value
             , get_number_value(e.data_type, x.element_value) as element_number_value
             , get_char_value  (e.data_type, x.element_value) as element_char_value
             , get_date_value  (e.data_type, x.element_value) as element_date_value
             , get_lov_value   (e.data_type, x.element_value, e.lov_id) as element_lov_value
          from (
                select s.appl_data_id data_id
                     , s.element_id
                     , s.parent_id parent_data_id
                     , s.serial_number
                     , coalesce(
                           element_value_v
                         , to_char(element_value_d, com_api_const_pkg.DATE_FORMAT)
                         , to_char(element_value_n, com_api_const_pkg.NUMBER_FORMAT)
                       ) as element_value
                     , s.lang
                  from table(cast(l_appl_data_templ as app_data_tpt)) s
                 where (s.parent_id = i_parent_id or i_parent_id is null)
                ) x
              , app_element e
          where e.id = x.element_id;
end get_application;

--
-- It searches an entity by its type and ID/number, and returns its data.
--
-- You can use next query for your testing of this pipelined method:
--
-- Customer:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTCUST', i_object_id => (select id from prd_customer where rownum=1), i_object_number => null, i_inst_id => 1001) as com_param_map_tpt))
--
-- Contract:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTCNTR', i_object_id => (select id from prd_contract where rownum=1), i_object_number => null, i_inst_id => 1001) as com_param_map_tpt))
--
-- Account:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTACCT', i_object_id => (select id from acc_account where rownum=1), i_object_number => null, i_inst_id => 1001) as com_param_map_tpt))
--
-- Card:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTCARD', i_object_id => (select id from iss_card where rownum=1), i_object_number => null, i_inst_id => 1001) as com_param_map_tpt))
--
-- Merchant:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTMRCH', i_object_id => (select id from acq_merchant where rownum=1), i_object_number => null, i_inst_id => 1001) as com_param_map_tpt))
--
-- Terminal:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTTRMN', i_object_id => (select id from acq_terminal where rownum=1), i_object_number => null, i_inst_id => 1001) as com_param_map_tpt))
--
-- Unsupported entity:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTXXXX', i_object_id => 1, i_object_number => null, i_inst_id => 1001) as com_param_map_tpt))
--
function get_entity_data(
    i_entity_type            in     com_api_type_pkg.t_dict_value
  , i_object_id              in     com_api_type_pkg.t_medium_id
  , i_object_number          in     com_api_type_pkg.t_name
  , i_inst_id                in     com_api_type_pkg.t_medium_id
) return com_param_map_tpt pipelined
is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_entity_data[1st]: ';
    l_param_map_tab          com_param_map_tpt       := com_param_map_tpt();
    l_name_tab               com_api_type_pkg.t_name_tab;
    l_value_tab              com_api_type_pkg.t_desc_tab;
    l_lang                   com_api_type_pkg.t_dict_value;
begin
    -- Select a single record for specified entity and unpivot it for saving into outgoing collection
    case
    when i_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then

        select 'CUSTOMER_ID',             to_char(id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'CUSTOMER_NUMBER',         customer_number
             , 'ENTITY_TYPE',             entity_type
             , 'OBJECT_ID',               to_char(object_id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'CUSTOMER_CATEGORY',       category
             , 'CUSTOMER_RELATION',       relation
             , 'RESIDENT',                to_char(resident, com_api_const_pkg.XML_NUMBER_FORMAT)  -- boolean
             , 'NATIONALITY',             nationality
             , 'CREDIT_RATING',           credit_rating
             , 'MONEY_LAUNDRY_RISK',      money_laundry_risk
             , 'MONEY_LAUNDRY_REASON',    money_laundry_reason
             , 'CUSTOMER_STATUS',         status
             , 'CUSTOMER_EXT_TYPE',       ext_entity_type
             , 'CUSTOMER_EXT_ID',         to_char(ext_object_id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'REG_DATE',                to_char(reg_date, com_api_const_pkg.DATE_FORMAT)
             , 'EMPLOYMENT_STATUS',       employment_status
             , 'EMPLOYMENT_PERIOD',       employment_period
             , 'RESIDENCE_TYPE',          residence_type
             , 'MARITAL_STATUS',          marital_status
             , 'MARITAL_STATUS_DATE',     to_char(marital_status_date, com_api_const_pkg.DATE_FORMAT)
             , 'INCOME_RANGE',            income_range
             , 'NUMBER_OF_CHILDREN',      number_of_children
          into l_name_tab( 1),  l_value_tab( 1)
             , l_name_tab( 2),  l_value_tab( 2)
             , l_name_tab( 3),  l_value_tab( 3)
             , l_name_tab( 4),  l_value_tab( 4)
             , l_name_tab( 5),  l_value_tab( 5)
             , l_name_tab( 6),  l_value_tab( 6)
             , l_name_tab( 7),  l_value_tab( 7)
             , l_name_tab( 8),  l_value_tab( 8)
             , l_name_tab( 9),  l_value_tab( 9)
             , l_name_tab(10),  l_value_tab(10)
             , l_name_tab(11),  l_value_tab(11)
             , l_name_tab(12),  l_value_tab(12)
             , l_name_tab(13),  l_value_tab(13)
             , l_name_tab(14),  l_value_tab(14)
             , l_name_tab(15),  l_value_tab(15)
             , l_name_tab(16),  l_value_tab(16)
             , l_name_tab(17),  l_value_tab(17)
             , l_name_tab(18),  l_value_tab(18)
             , l_name_tab(19),  l_value_tab(19)
             , l_name_tab(20),  l_value_tab(20)
             , l_name_tab(21),  l_value_tab(21)
             , l_name_tab(22),  l_value_tab(22)
          from prd_customer
         where inst_id = i_inst_id
           and (id = i_object_id
            or reverse(customer_number) = reverse(i_object_number));

        for cur in (select name
                         , field_value
                      from com_flexible_field   ff
                         , com_flexible_data    fd
                         , prd_customer         c
                     where ff.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                       and fd.object_id = c.id
                       and ff.id = fd.field_id
                       and (c.id = i_object_id
                            or reverse(customer_number) = reverse(i_object_number)
                           )
                   )
        loop
            l_name_tab(l_name_tab.count + 1)    := cur.name;
            l_value_tab(l_value_tab.count + 1)  := cur.field_value;
        end loop;

    when i_entity_type = com_api_const_pkg.ENTITY_TYPE_CONTRACT then

        select 'CONTRACT_ID',             to_char(c.id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'PRODUCT_ID',              to_char(c.product_id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'PRODUCT_NUMBER',          p.product_number
             , 'START_DATE',              to_char(c.start_date, com_api_const_pkg.DATE_FORMAT)
             , 'END_DATE',                to_char(c.end_date, com_api_const_pkg.DATE_FORMAT)
             , 'CONTRACT_NUMBER',         c.contract_number
             , 'CONTRACT_TYPE',           c.contract_type
          into l_name_tab( 1),  l_value_tab( 1)
             , l_name_tab( 2),  l_value_tab( 2)
             , l_name_tab( 3),  l_value_tab( 3)
             , l_name_tab( 4),  l_value_tab( 4)
             , l_name_tab( 5),  l_value_tab( 5)
             , l_name_tab( 6),  l_value_tab( 6)
             , l_name_tab( 7),  l_value_tab( 7)
          from prd_contract c
          join prd_product  p    on p.id = c.product_id
         where c.inst_id = i_inst_id
           and (c.id = i_object_id
            or reverse(c.contract_number) = reverse(i_object_number));

    when i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

        select 'ACCOUNT_ID',              to_char(a.id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'ACCOUNT_TYPE',            account_type
             , 'ACCOUNT_NUMBER',          account_number
             , 'CURRENCY',                currency
             , 'ACCOUNT_STATUS',          status
          into l_name_tab( 1),  l_value_tab( 1)
             , l_name_tab( 2),  l_value_tab( 2)
             , l_name_tab( 3),  l_value_tab( 3)
             , l_name_tab( 4),  l_value_tab( 4)
             , l_name_tab( 5),  l_value_tab( 5)
          from acc_account a
         where inst_id = i_inst_id
           and (id = i_object_id
            or reverse(account_number) = reverse(i_object_number));

        for cur in (select name
                         , field_value
                      from com_flexible_field   ff
                         , com_flexible_data    fd
                         , acc_account          a
                     where ff.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and fd.object_id = a.id
                       and ff.id = fd.field_id
                       and (a.id = i_object_id
                            or reverse(account_number) = reverse(i_object_number)
                           )
                   )
        loop
            l_name_tab(l_name_tab.count + 1)    := cur.name;
            l_value_tab(l_value_tab.count + 1)  := cur.field_value;
        end loop;

    when i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then

        select 'CARD_ID',                 ci.card_uid
             , 'CARD_OBJ_ID',             to_char(c.id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'CARD_TYPE',               to_char(c.card_type_id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'CATEGORY',                c.category
             , 'CARD_NUMBER',             iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number)
             , 'CARD_BLANK_TYPE',         to_char(ci.blank_type_id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'CARD_DELIVERY_CHANNEL',   ci.delivery_channel as card_delivery_channel
             , 'CARDHOLDER_NAME',         ci.cardholder_name
             , 'CARD_ISS_DATE',           to_char(ci.iss_date, com_api_const_pkg.DATE_FORMAT)
             , 'CARD_STATE',              ci.state as card_state
             , 'CARD_STATUS',             ci.status as card_status
             , 'EMBOSSING_REQUEST',       null
             , 'EXPIRATION_DATE',         to_char(ci.expir_date, com_api_const_pkg.DATE_FORMAT)
             , 'PERSO_PRIORITY',          ci.perso_priority
             , 'PIN_MAILER_REQUEST',      ci.pin_mailer_request
             , 'PIN_REQUEST',             ci.pin_request
             , 'REISSUE_REASON',          null
             , 'SEQUENTIAL_NUMBER',       to_char(ci.seq_number, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'CARD_DELIVERY_STATUS',    ci.delivery_status as card_delivery_status
          into l_name_tab( 1),  l_value_tab( 1)
             , l_name_tab( 2),  l_value_tab( 2)
             , l_name_tab( 3),  l_value_tab( 3)
             , l_name_tab( 4),  l_value_tab( 4)
             , l_name_tab( 5),  l_value_tab( 5)
             , l_name_tab( 6),  l_value_tab( 6)
             , l_name_tab( 7),  l_value_tab( 7)
             , l_name_tab( 8),  l_value_tab( 8)
             , l_name_tab( 9),  l_value_tab( 9)
             , l_name_tab(10),  l_value_tab(10)
             , l_name_tab(11),  l_value_tab(11)
             , l_name_tab(12),  l_value_tab(12)
             , l_name_tab(13),  l_value_tab(13)
             , l_name_tab(14),  l_value_tab(14)
             , l_name_tab(15),  l_value_tab(15)
             , l_name_tab(16),  l_value_tab(16)
             , l_name_tab(17),  l_value_tab(17)
             , l_name_tab(18),  l_value_tab(18)
             , l_name_tab(19),  l_value_tab(19)
          from iss_card c
          join iss_card_number   cn    on cn.card_id = c.id
          join iss_card_instance ci    on ci.card_id = c.id
         where c.inst_id = i_inst_id
           and ((c.id = i_object_id
                or
                reverse(cn.card_number) = reverse(iss_api_token_pkg.encode_card_number(
                                                      i_card_number => i_object_number
                                                  ))
               )
           and ci.id = (select distinct first_value(ci0.id) over (order by ci0.seq_number desc)
                          from iss_card_instance ci0
                         where ci0.card_id = c.id));

        for cur in (select name
                         , field_value
                      from com_flexible_field   ff
                         , com_flexible_data    fd
                         , iss_card             c
                         , iss_card_number      cn
                     where ff.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and fd.object_id = c.id
                       and ff.id = fd.field_id
                       and cn.card_id = c.id
                       and (c.id = i_object_id
                            or
                            reverse(cn.card_number) = reverse(iss_api_token_pkg.encode_card_number(
                                                                  i_card_number => i_object_number
                                                              ))
                           )
                   )
        loop
            l_name_tab(l_name_tab.count + 1)    := cur.name;
            l_value_tab(l_value_tab.count + 1)  := cur.field_value;
        end loop;

    when i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        l_lang := com_ui_user_env_pkg.get_user_lang;

        select 'MERCHANT_ID',             to_char(m.id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'MERCHANT_NUMBER',         merchant_number
             , 'MERCHANT_NAME',           merchant_name
             , 'MERCHANT_LABEL',          get_text('acq_merchant', 'label', m.id, l_lang)
             , 'MERCHANT_TYPE',           merchant_type
             , 'MCC',                     mcc
             , 'MERCHANT_STATUS',         status
             , 'MERCHANT_DESC',           get_text('acq_merchant', 'description', m.id, l_lang)
          into l_name_tab( 1),  l_value_tab( 1)
             , l_name_tab( 2),  l_value_tab( 2)
             , l_name_tab( 3),  l_value_tab( 3)
             , l_name_tab( 4),  l_value_tab( 4)
             , l_name_tab( 5),  l_value_tab( 5)
             , l_name_tab( 6),  l_value_tab( 6)
             , l_name_tab( 7),  l_value_tab( 7)
             , l_name_tab( 8),  l_value_tab( 8)
          from acq_merchant m
         where m.inst_id = i_inst_id
           and (m.id = i_object_id
            or reverse(m.merchant_number) = reverse(i_object_number));

    when i_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then

        select 'TERMINAL_ID',             to_char(t.id, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'TERMINAL_NUMBER',         t.terminal_number
             , 'TERMINAL_TYPE',           t.terminal_type
             , 'STANDARD_ID',             to_char(s.standard_id,            com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'VERSION_ID',              to_char(v.version_id,             com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'MCC',                     t.mcc
             , 'TERMINAL_TEMPLATE',       null    -- ???
             , 'PLASTIC_NUMBER',          t.plastic_number
             , 'CARD_DATA_INPUT_CAP',     t.card_data_input_cap
             , 'CRDH_AUTH_CAP',           t.crdh_auth_cap
             , 'CARD_CAPTURE_CAP',        t.card_capture_cap
             , 'TERM_OPERATING_ENV',      t.term_operating_env
             , 'CRDH_DATA_PRESENT',       t.crdh_data_present
             , 'CARD_DATA_PRESENT',       t.card_data_present
             , 'CARD_DATA_INPUT_MODE',    t.card_data_input_mode
             , 'CRDH_AUTH_METHOD',        t.crdh_auth_method
             , 'CRDH_AUTH_ENTITY',        t.crdh_auth_entity
             , 'CARD_DATA_OUTPUT_CAP',    t.card_data_output_cap
             , 'TERM_DATA_OUTPUT_CAP',    t.term_data_output_cap
             , 'PIN_CAPTURE_CAP',         t.pin_capture_cap
             , 'CAT_LEVEL',               t.cat_level
             , 'TERMINAL_STATUS',         t.status as terminal_status
             , 'DEVICE_ID',               to_char(t.device_id,              com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'GMT_OFFSET',              to_char(t.gmt_offset,             com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'IS_MAC',                  to_char(t.is_mac,                 com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'CASH_DISPENSER_PRESENT',  to_char(t.cash_dispenser_present, com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'PAYMENT_POSSIBILITY',     to_char(t.payment_possibility,    com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'USE_CARD_POSSIBILITY',    to_char(t.use_card_possibility,   com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'CASH_IN_PRESENT',         to_char(t.cash_in_present,        com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'AVAILABLE_NETWORK',       to_char(t.available_network,      com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'AVAILABLE_OPERATION',     to_char(t.available_operation,    com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'AVAILABLE_CURRENCY',      to_char(t.available_currency,     com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'TERMINAL_QUANTITY',       null    -- ???
             , 'MCC_TEMPLATE_ID',         to_char(t.mcc_template_id,        com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'INSTALMENT_SUPPORT',      to_char(p.instalment_support,     com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'TERMINAL_PROFILE',        to_char(t.terminal_profile,       com_api_const_pkg.XML_NUMBER_FORMAT)
             , 'PIN_BLOCK_FORMAT',        t.pin_block_format
          into l_name_tab( 1),  l_value_tab( 1)
             , l_name_tab( 2),  l_value_tab( 2)
             , l_name_tab( 3),  l_value_tab( 3)
             , l_name_tab( 4),  l_value_tab( 4)
             , l_name_tab( 5),  l_value_tab( 5)
             , l_name_tab( 6),  l_value_tab( 6)
             , l_name_tab( 7),  l_value_tab( 7)
             , l_name_tab( 8),  l_value_tab( 8)
             , l_name_tab( 9),  l_value_tab( 9)
             , l_name_tab(10),  l_value_tab(10)
             , l_name_tab(11),  l_value_tab(11)
             , l_name_tab(12),  l_value_tab(12)
             , l_name_tab(13),  l_value_tab(13)
             , l_name_tab(14),  l_value_tab(14)
             , l_name_tab(15),  l_value_tab(15)
             , l_name_tab(16),  l_value_tab(16)
             , l_name_tab(17),  l_value_tab(17)
             , l_name_tab(18),  l_value_tab(18)
             , l_name_tab(19),  l_value_tab(19)
             , l_name_tab(20),  l_value_tab(20)
             , l_name_tab(21),  l_value_tab(21)
             , l_name_tab(22),  l_value_tab(22)
             , l_name_tab(23),  l_value_tab(23)
             , l_name_tab(24),  l_value_tab(24)
             , l_name_tab(25),  l_value_tab(25)
             , l_name_tab(26),  l_value_tab(26)
             , l_name_tab(27),  l_value_tab(27)
             , l_name_tab(28),  l_value_tab(28)
             , l_name_tab(29),  l_value_tab(29)
             , l_name_tab(30),  l_value_tab(30)
             , l_name_tab(31),  l_value_tab(31)
             , l_name_tab(32),  l_value_tab(32)
             , l_name_tab(33),  l_value_tab(33)
             , l_name_tab(34),  l_value_tab(34)
             , l_name_tab(35),  l_value_tab(35)
             , l_name_tab(36),  l_value_tab(36)
             , l_name_tab(37),  l_value_tab(37)
          from acq_terminal t
             , cmn_standard_object s
             , cmn_standard_version_obj v
             , pos_terminal p
         where t.inst_id = i_inst_id
           and ((
                   t.id = i_object_id
                   or reverse(terminal_number) = reverse(i_object_number)
                )
           and s.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and s.object_id(+)   = t.id
           and v.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and v.object_id(+)   = t.id
           and p.id(+)          = t.id);

    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'getting data for entity type [#1] is not implemented; '
                                       || 'i_object_id [' || i_object_id
                                       || '], i_object_number [' || i_object_number || ']'
          , i_env_param1 => i_entity_type
        );
    end case;

    for i in 1 .. l_name_tab.count loop
        l_param_map_tab.extend;
        l_param_map_tab(i) := com_param_map_tpr(l_name_tab(i), l_value_tab(i), null, null, null);
        pipe row(l_param_map_tab(i));
    end loop;
    return;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with [#2]; entity type [#1'
                         || '], object ID [' || i_object_id
                         || '], object number [' || i_object_number || ']'
          , i_env_param1 => i_entity_type
          , i_env_param2 => sqlerrm
        );
        raise;
end get_entity_data;

--
-- It searches an entity by its parent entity, and returns its data.
-- If there are some entities for specified parent entity then input parameter <i_object_type>
-- should be used to get only one entity. Otherwise, only one entity (its data) will be return
-- randomly.
--
-- You can use next query for your testing of this pipelined method:
--
-- Get company by company id:
-- select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTCOMP', i_object_type => null, i_parent_entity_type => 'ENTTCUST', i_parent_object_id => 1, i_inst_id => 1001) as com_param_map_tpt))
--
-- Get contacts by customer id:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTCNTC', i_object_type => 'CNTTPRMC', i_parent_entity_type => 'ENTTCUST', i_parent_object_id => 22, i_inst_id => 1001) as com_param_map_tpt))
--
-- Get contacts by customer number:
--   select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTCNTC', i_object_type => 'CNTTPRMC', i_parent_entity_type => 'ENTTCUST', i_parent_object_id => null, i_inst_id => 1001, i_parent_object_number => '0000000000000000000022') as com_param_map_tpt))
--
-- Get contacts by cardholder number:
--  select name, char_value from table(cast(app_ui_application_pkg.get_entity_data(i_entity_type => 'ENTTCNTC', i_object_type => 'CNTTPRMC', i_parent_entity_type => 'ENTTCRDH', i_parent_object_id => null, i_inst_id => 1001, i_parent_object_number => '0000000000000000000022') as com_param_map_tpt))
--
function get_entity_data(
    i_entity_type            in     com_api_type_pkg.t_dict_value
  , i_object_type            in     com_api_type_pkg.t_dict_value
  , i_parent_entity_type     in     com_api_type_pkg.t_dict_value
  , i_parent_object_id       in     com_api_type_pkg.t_medium_id
  , i_inst_id                in     com_api_type_pkg.t_medium_id
  , i_parent_object_number   in     com_api_type_pkg.t_name         default null
  , i_seqnum                 in     com_api_type_pkg.t_tiny_id      default null
) return com_param_map_tpt pipelined
is
    LOG_PREFIX      constant com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.get_entity_data[2nd]: ';
    l_param_map_tab          com_param_map_tpt             := com_param_map_tpt();
    l_seqnum                 com_api_type_pkg.t_tiny_id    := nvl(i_seqnum, 1);
    l_name_tab               com_api_type_pkg.t_name_tab;
    l_value_tab              com_api_type_pkg.t_desc_tab;
    l_lang                   com_api_type_pkg.t_dict_value;
    l_person_id              com_api_type_pkg.t_medium_id;
    l_cardholder_id          com_api_type_pkg.t_medium_id;
    l_parent_object_id       com_api_type_pkg.t_medium_id;
    l_parent_object_number   com_api_type_pkg.t_name;
    l_sysdate                date;
begin
    l_lang := com_ui_user_env_pkg.get_user_lang;

    if i_parent_entity_type in (
           com_api_const_pkg.ENTITY_TYPE_CUSTOMER
         , iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
       )
    then
        l_parent_object_number := upper(i_parent_object_number);
    else
        l_parent_object_number := i_parent_object_number;
    end if;

    l_parent_object_id := i_parent_object_id;
    if l_parent_object_id is null and l_parent_object_number is not null then
        case
        when i_parent_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
        then
            select id
              into l_parent_object_id
              from prd_customer
             where inst_id = i_inst_id
               and reverse(customer_number) = reverse(l_parent_object_number);

        when i_parent_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
        then
            select card_id
              into l_parent_object_id
              from iss_card_number
             where reverse(card_number) = reverse(iss_api_token_pkg.encode_card_number(
                                                       i_card_number => l_parent_object_number
                                                  ));

        when i_parent_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
        then
            select id
              into l_parent_object_id
              from acq_merchant
             where inst_id = i_inst_id
               and reverse(merchant_number) = reverse(l_parent_object_number);

        when i_parent_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
        then
            select id
              into l_parent_object_id
              from acq_terminal
             where inst_id = i_inst_id
               and reverse(terminal_number) = reverse(l_parent_object_number);

        when i_parent_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
        then
            select id
              into l_parent_object_id
              from iss_cardholder
             where inst_id = i_inst_id
               and reverse(cardholder_number) = reverse(l_parent_object_number);

        else
            -- i_parent_entity_type = com_api_const_pkg.ENTITY_TYPE_CONTACT
            -- i_parent_entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
            -- i_parent_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'object has not object number: '
                             || 'i_entity_type [#1], i_object_type [#2], i_parent_entity_type [#3], '
                             || 'i_parent_object_id [#4], i_parent_object_number [#5]'
              , i_env_param1 => i_entity_type
              , i_env_param2 => i_object_type
              , i_env_param3 => i_parent_entity_type
              , i_env_param4 => i_parent_object_id
              , i_env_param5 => i_parent_object_number
            );
        end case;
    end if;

    if l_parent_object_id is not null then
        -- Select a single record for specified entity and unpivot it for saving into outgoing collection
        case
        when i_entity_type = com_api_const_pkg.ENTITY_TYPE_CONTACT
         and i_parent_entity_type in (com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                                    , acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    , iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER)
        then
            select 'CONTACT_ID',              to_char(id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'CONTACT_TYPE',            contact_type
                 , 'PREFERRED_LANG',          preferred_lang
                 , 'JOB_TITLE',               job_title
                 , 'PERSON_ID',               to_char(person_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'COMMUN_ADDRESS',          commun_address
                 , 'COMMUN_METHOD',           commun_method
                 , 'START_DATE',              to_char(start_date, com_api_const_pkg.DATE_FORMAT)
                 , 'END_DATE',                to_char(end_date, com_api_const_pkg.DATE_FORMAT)
              into l_name_tab( 1),  l_value_tab( 1)
                 , l_name_tab( 2),  l_value_tab( 2)
                 , l_name_tab( 3),  l_value_tab( 3)
                 , l_name_tab( 4),  l_value_tab( 4)
                 , l_name_tab( 5),  l_value_tab( 5)
                 , l_name_tab( 6),  l_value_tab( 6)
                 , l_name_tab( 7),  l_value_tab( 7)
                 , l_name_tab( 8),  l_value_tab( 8)
                 , l_name_tab( 9),  l_value_tab( 9)
              from (select c.id
                         , co.contact_type
                         , c.preferred_lang
                         , c.job_title
                         , c.person_id
                         , cd.commun_address
                         , cd.commun_method
                         , cd.start_date
                         , cd.end_date
                         , row_number() over (order by c.id) rn
                      from com_contact        c
                      join com_contact_object co    on co.contact_id = c.id
                      left join com_contact_data cd on cd.contact_id = c.id
                     where co.entity_type   = i_parent_entity_type
                       and co.object_id     = l_parent_object_id
                       and (co.contact_type = i_object_type or i_object_type is null)
                   )
             where rn = l_seqnum;

        when i_entity_type = com_api_const_pkg.ENTITY_TYPE_ADDRESS
         and i_parent_entity_type in (com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                    , iss_api_const_pkg.ENTITY_TYPE_CARD
                                    , acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    , acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                    , iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER)
        then
            select 'ADDRESS_TYPE',            address_type
                 , 'ADDRESS_ID',              to_char(id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'LANG',                    lang
                 , 'COUNTRY',                 country
                 , 'REGION',                  region
                 , 'CITY',                    city
                 , 'STREET',                  street
                 , 'HOUSE',                   house
                 , 'APARTMENT',               apartment
                 , 'POSTAL_CODE',             postal_code
                 , 'REGION_CODE',             region_code
                 , 'LATITUDE',                to_char(latitude, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'LONGITUDE',               to_char(longitude, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'PLACE_CODE',              place_code
              into l_name_tab( 1),  l_value_tab( 1)
                 , l_name_tab( 2),  l_value_tab( 2)
                 , l_name_tab( 3),  l_value_tab( 3)
                 , l_name_tab( 4),  l_value_tab( 4)
                 , l_name_tab( 5),  l_value_tab( 5)
                 , l_name_tab( 6),  l_value_tab( 6)
                 , l_name_tab( 7),  l_value_tab( 7)
                 , l_name_tab( 8),  l_value_tab( 8)
                 , l_name_tab( 9),  l_value_tab( 9)
                 , l_name_tab(10),  l_value_tab(10)
                 , l_name_tab(11),  l_value_tab(11)
                 , l_name_tab(12),  l_value_tab(12)
                 , l_name_tab(13),  l_value_tab(13)
                 , l_name_tab(14),  l_value_tab(14)
              from (
                  select ao.address_type
                       , a.*
                       , row_number() over (
                             order by
                                 case a.lang
                                     when l_lang                             then 1
                                     when com_api_const_pkg.DEFAULT_LANGUAGE then 2
                                                                             else 3
                                 end
                         ) as rn
                    from com_address a
                    join com_address_object ao    on a.id = ao.address_id
                   where ao.entity_type   = i_parent_entity_type
                     and ao.object_id     = l_parent_object_id
                     and (ao.address_type = i_object_type or i_object_type is null)
                   )
             where rn = l_seqnum;

        when i_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON then
            case
                when i_parent_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                    select c.object_id
                      into l_person_id
                      from prd_customer c
                     where c.id           = l_parent_object_id
                       and c.entity_type  = com_api_const_pkg.ENTITY_TYPE_PERSON;

                when i_parent_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER then
                    select c.person_id
                      into l_person_id
                      from iss_cardholder c
                     where c.id           = l_parent_object_id;

                when i_parent_entity_type = com_api_const_pkg.ENTITY_TYPE_CONTACT then
                    select co.object_id
                      into l_person_id
                      from com_contact_object co
                     where co.contact_id  = l_parent_object_id
                       and co.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON;

                else
                    null;
            end case;

            if l_person_id is not null then

                select 'PERSON_ID',               to_char(id, com_api_const_pkg.XML_NUMBER_FORMAT)
                     , 'LANG',                    lang
                     , 'PERSON_TITLE',            title
                     , 'FIRST_NAME',              first_name
                     , 'SECOND_NAME',             second_name
                     , 'SURNAME',                 surname
                     , 'SUFFIX',                  suffix
                     , 'GENDER',                  gender
                     , 'BIRTHDAY',                to_char(birthday, com_api_const_pkg.DATE_FORMAT)
                     , 'PLACE_OF_BIRTH',          place_of_birth
                     , 'ID_TYPE',                 id_type
                     , 'ID_SERIES',               id_series
                     , 'ID_NUMBER',               id_number
                     , 'ID_ISSUER',               id_issuer
                     , 'ID_ISSUE_DATE',           to_char(id_issue_date, com_api_const_pkg.DATE_FORMAT)
                     , 'ID_EXPIRE_DATE',          to_char(id_expire_date, com_api_const_pkg.DATE_FORMAT)
                     , 'ID_DESC',                 description
                  into l_name_tab( 1),  l_value_tab( 1)
                     , l_name_tab( 2),  l_value_tab( 2)
                     , l_name_tab( 3),  l_value_tab( 3)
                     , l_name_tab( 4),  l_value_tab( 4)
                     , l_name_tab( 5),  l_value_tab( 5)
                     , l_name_tab( 6),  l_value_tab( 6)
                     , l_name_tab( 7),  l_value_tab( 7)
                     , l_name_tab( 8),  l_value_tab( 8)
                     , l_name_tab( 9),  l_value_tab( 9)
                     , l_name_tab(10),  l_value_tab(10)
                     , l_name_tab(11),  l_value_tab(11)
                     , l_name_tab(12),  l_value_tab(12)
                     , l_name_tab(13),  l_value_tab(13)
                     , l_name_tab(14),  l_value_tab(14)
                     , l_name_tab(15),  l_value_tab(15)
                     , l_name_tab(16),  l_value_tab(16)
                     , l_name_tab(17),  l_value_tab(17)
                  from (select p.*
                             , o.id_type
                             , o.id_series
                             , o.id_number
                             , o.id_issuer
                             , o.id_issue_date
                             , o.id_expire_date
                             , o.description
                             , row_number() over (
                                   order by
                                       case p.lang
                                           when l_lang                             then 1
                                           when com_api_const_pkg.DEFAULT_LANGUAGE then 2
                                                                                   else 3
                                       end
                               ) as rn
                          from com_person p
                          left join com_ui_id_object_vw o on o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                                         and o.object_id = p.id
                         where p.id = l_person_id
                        )
                  where rn = 1;

                for cur in (select name
                                 , field_value
                              from com_flexible_field   ff
                                 , com_flexible_data    fd
                             where ff.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                               and fd.object_id = l_person_id
                               and ff.id = fd.field_id
                           )
                loop
                    l_name_tab(l_name_tab.count + 1)    := cur.name;
                    l_value_tab(l_value_tab.count + 1)  := cur.field_value;
                end loop;

            end if;

        when i_entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
         and i_parent_entity_type in (com_api_const_pkg.ENTITY_TYPE_CUSTOMER)
        then
            select 'COMPANY_ID',              to_char(c.id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'EMBOSSED_NAME',           c.embossed_name
                 , 'INCORP_FORM',             c.incorp_form
                 , 'COMPANY_NAME',            com_api_i18n_pkg.get_text(
                                                  i_table_name  => 'COM_COMPANY'
                                                , i_column_name => 'LABEL'
                                                , i_object_id   => c.id
                                              )
              into l_name_tab( 1),  l_value_tab( 1)
                 , l_name_tab( 2),  l_value_tab( 2)
                 , l_name_tab( 3),  l_value_tab( 3)
                 , l_name_tab( 4),  l_value_tab( 4)
              from prd_customer ct
              join com_company  c   on c.id = ct.object_id
             where ct.id          = l_parent_object_id
               and ct.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY;

        when i_entity_type = rpt_api_const_pkg.ENTITY_TYPE_DOCUMENT
         and i_parent_entity_type in (com_api_const_pkg.ENTITY_TYPE_COMPANY
                                    , com_api_const_pkg.ENTITY_TYPE_PERSON)
        then
            select 'ID',                      to_char(i.id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'ID_TYPE',                 i.id_type
                 , 'ID_SERIES',               i.id_series
                 , 'ID_NUMBER',               i.id_number
                 , 'ID_ISSUER',               i.id_issuer
                 , 'ID_ISSUE_DATE',           to_char(i.id_issue_date,  com_api_const_pkg.DATE_FORMAT)
                 , 'ID_EXPIRE_DATE',          to_char(i.id_expire_date, com_api_const_pkg.DATE_FORMAT)
                 , 'ID_DESC',                 com_api_i18n_pkg.get_text(
                                                  i_table_name  => 'COM_ID_OBJECT'
                                                , i_column_name => 'DESCRIPTION'
                                                , i_object_id   => i.id
                                              )
              into l_name_tab( 1),  l_value_tab( 1)
                 , l_name_tab( 2),  l_value_tab( 2)
                 , l_name_tab( 3),  l_value_tab( 3)
                 , l_name_tab( 4),  l_value_tab( 4)
                 , l_name_tab( 5),  l_value_tab( 5)
                 , l_name_tab( 6),  l_value_tab( 6)
                 , l_name_tab( 7),  l_value_tab( 7)
                 , l_name_tab( 8),  l_value_tab( 8)
                  from com_id_object i
                 where i.entity_type  = i_parent_entity_type
                   and i.object_id    = l_parent_object_id
                   and (i.id_type = i_object_type or i_object_type is null)
                   and rownum         = 1;  -- for the case when <i_object_type> is not specified

        when i_entity_type        = com_api_const_pkg.ENTITY_TYPE_CONTACT
         and i_parent_entity_type = com_api_const_pkg.ENTITY_TYPE_CONTACT
        then
            l_sysdate := com_api_sttl_day_pkg.get_sysdate;

            select 'COMMUN_ADDRESS',          first_value(commun_address)     over (order by d.end_date desc nulls first)
                 , 'START_DATE',              to_char(first_value(start_date) over (order by d.end_date desc nulls first),  com_api_const_pkg.DATE_FORMAT)
                 , 'END_DATE',                to_char(first_value(end_date)   over (order by d.end_date desc nulls first),  com_api_const_pkg.DATE_FORMAT)
              into l_name_tab( 1),  l_value_tab( 1)
                 , l_name_tab( 2),  l_value_tab( 2)
                 , l_name_tab( 3),  l_value_tab( 3)
              from com_contact_data d
             where d.contact_id    = l_parent_object_id
               and d.commun_method = i_object_type
               and nvl(d.end_date, l_sysdate) >= l_sysdate
               and d.start_date = (
                       select max(start_date)
                         from com_contact_data b 
                        where b.contact_id = d.contact_id 
                          and b.start_date <= l_sysdate
                          and b.commun_method = d.commun_method
                          and nvl(b.end_date, l_sysdate) >= l_sysdate
                   );

        when i_entity_type        = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
         and i_parent_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
        then
            
            select cardholder_id
              into l_cardholder_id
              from iss_card
             where id = l_parent_object_id;
            
            select 'CARDHOLDER_ID',     to_char(c.id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'PERSON_ID',         to_char(c.person_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'CARDHOLDER_NUMBER', c.cardholder_number
                 , 'CARDHOLDER_NAME',   c.cardholder_name
                 , 'SECRET_QUESTION',   q.question
                 , 'SECRET_ANSWER',     w.word 
              into l_name_tab( 1),  l_value_tab( 1)
                 , l_name_tab( 2),  l_value_tab( 2)
                 , l_name_tab( 3),  l_value_tab( 3)
                 , l_name_tab( 4),  l_value_tab( 4)
                 , l_name_tab( 5),  l_value_tab( 5)
                 , l_name_tab( 6),  l_value_tab( 6)
              from iss_cardholder   c
                 , sec_question     q
                 , sec_word         w
             where c.id                 = l_cardholder_id
               and q.id                 = w.question_id(+)
               and q.entity_type(+)     = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
               and q.object_id(+)       = c.id;

            for cur in (select name
                             , field_value
                          from com_flexible_field   ff
                             , com_flexible_data    fd
                         where ff.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                           and fd.object_id = l_cardholder_id
                           and ff.id = fd.field_id
                       )
            loop
                l_name_tab(l_name_tab.count + 1)    := cur.name;
                l_value_tab(l_value_tab.count + 1)  := cur.field_value;
            end loop;

        when i_entity_type        = ntf_api_const_pkg.ENTITY_TYPE_NOTIFICATION
         and i_parent_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
        then

            select 'NOTIFICATION_EVENT',    event_type
                 , 'DELIVERY_CHANNEL',      to_char(channel_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'DELIVERY_ADDRESS',      delivery_address
                 , 'IS_ACTIVE',             to_char(is_active, com_api_const_pkg.XML_NUMBER_FORMAT)
              into l_name_tab( 1),  l_value_tab( 1)
                 , l_name_tab( 2),  l_value_tab( 2)
                 , l_name_tab( 3),  l_value_tab( 3)
                 , l_name_tab( 4),  l_value_tab( 4)
              from (select event_type
                         , channel_id
                         , delivery_address
                         , is_active
                         , row_number() over (order by id) rn
                      from ntf_custom_event
                     where entity_type = i_parent_entity_type
                       and object_id = l_parent_object_id
                   )
             where rn = l_seqnum;

        when i_entity_type        = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
         and i_parent_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
        then

            select 'CARDHOLDER_ID',     to_char(id, com_api_const_pkg.XML_NUMBER_FORMAT)
                 , 'PERSON_ID',         to_char(person_id, com_api_const_pkg.XML_NUMBER_FORMAT)
              into l_name_tab( 1),  l_value_tab( 1)
                 , l_name_tab( 2),  l_value_tab( 2)
              from (select c.id
                         , c.person_id
                         , row_number() over (order by c.id) rn
                      from iss_cardholder c
                     where c.person_id = l_parent_object_id
                   )
             where rn = l_seqnum;

        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'getting entity data is not implemented: '
                             || 'i_entity_type [#1], i_object_type [#2], i_parent_entity_type [#3], '
                             || 'i_parent_object_id [#4], i_parent_object_number [#5]'
              , i_env_param1 => i_entity_type
              , i_env_param2 => i_object_type
              , i_env_param3 => i_parent_entity_type
              , i_env_param4 => i_parent_object_id
              , i_env_param5 => i_parent_object_number
            );
        end case;
    end if;

    for i in 1 .. l_name_tab.count loop
        l_param_map_tab.extend;
        l_param_map_tab(i) := com_param_map_tpr(l_name_tab(i), l_value_tab(i), null, null, null);
        pipe row(l_param_map_tab(i));
    end loop;
    return;

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with [#6]; i_entity_type [#1], i_object_type [#2]'
                                       || ', i_parent_entity_type [#3], i_parent_object_id [#4], i_parent_object_number [#5]'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_type
          , i_env_param3 => i_parent_entity_type
          , i_env_param4 => i_parent_object_id
          , i_env_param5 => i_parent_object_number
          , i_env_param6 => sqlerrm
        );
        raise;
end get_entity_data;

-- Common method which add new application with its "app_data" records.
procedure add_application(
    i_context_mode      in      com_api_type_pkg.t_dict_value
  , io_appl_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_appl_number       in      com_api_type_pkg.t_name
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_appl_status       in      com_api_type_pkg.t_dict_value       default null
  , i_session_file_id   in      com_api_type_pkg.t_long_id          default null
  , i_file_rec_num      in      com_api_type_pkg.t_tiny_id          default null
  , i_customer_type     in      com_api_type_pkg.t_dict_value       default null
  , i_reject_code       in      com_api_type_pkg.t_dict_value       default null
  , i_user_id           in      com_api_type_pkg.t_short_id         default null
  , i_is_visible        in      com_api_type_pkg.t_boolean          default null
  , i_appl_prioritized  in      com_api_type_pkg.t_boolean          default null
  , i_customer_number   in      com_api_type_pkg.t_name             default null
  , i_appl_data         in      app_data_tpt
  , i_is_new            in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) is
    l_is_customer_agent         com_api_type_pkg.t_boolean;
    l_customer_number           com_api_type_pkg.t_name       := i_customer_number;
    l_contract_type             com_api_type_pkg.t_dict_value;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_execution_mode            com_api_type_pkg.t_dict_value;
begin

    -- Get "split_hash" and "execution_mode"
    if l_customer_number is null then
        for r in (
            select
                a.appl_data_id
              , a.element_id
              , a.parent_id
              , a.serial_number
              , a.element_value_v
              , com_api_type_pkg.FALSE
              , a.lang
            from table(cast(i_appl_data as app_data_tpt)) a
           where a.element_id in (app_api_const_pkg.ELEMENT_CUSTOMER_NUMBER
                                , app_api_const_pkg.ELEMENT_CONTRACT_TYPE)
        ) loop
            if r.element_id        = app_api_const_pkg.ELEMENT_CUSTOMER_NUMBER then
                l_customer_number := r.element_value_v;
            elsif r.element_id     = app_api_const_pkg.ELEMENT_CONTRACT_TYPE   then
                l_contract_type   := r.element_value_v;
            end if;
        end loop;
    end if;

    l_is_customer_agent := iss_api_card_pkg.is_customer_agent(
                               i_agent_id           => i_agent_id
                             , i_appl_contract_type => l_contract_type
                           );

    if i_appl_type != app_api_const_pkg.APPL_TYPE_ISSUING
       or (
           i_appl_type             = app_api_const_pkg.APPL_TYPE_ISSUING
           and l_is_customer_agent = com_api_const_pkg.TRUE
       )
    then
        l_execution_mode := prc_api_const_pkg.EXECUTION_MODE_PRE_PROCESS;

    elsif i_appl_type           = app_api_const_pkg.APPL_TYPE_ISSUING
       and l_customer_number   is not null
       and l_is_customer_agent  = com_api_const_pkg.FALSE
    then
        l_split_hash     := com_api_hash_pkg.get_split_hash(i_value => l_customer_number);
        l_execution_mode := prc_api_const_pkg.EXECUTION_MODE_PARALLEL;

    elsif i_appl_type           = app_api_const_pkg.APPL_TYPE_ISSUING
       and l_customer_number   is null
       and l_is_customer_agent  = com_api_const_pkg.FALSE
    then
        l_execution_mode := prc_api_const_pkg.EXECUTION_MODE_POST_PROCESS;

    end if;

    -- Add application using context mode
    if i_context_mode = app_api_const_pkg.APPL_CONTEXT_MIGRATING then
        add_application_migrate(
            io_appl_id          => io_appl_id
          , o_seqnum            => o_seqnum
          , i_appl_type         => i_appl_type
          , i_appl_number       => i_appl_number
          , i_flow_id           => i_flow_id
          , i_inst_id           => i_inst_id
          , i_agent_id          => i_agent_id
          , i_appl_status       => i_appl_status
          , i_session_file_id   => i_session_file_id
          , i_file_rec_num      => i_file_rec_num
          , i_customer_type     => i_customer_type
          , i_split_hash        => l_split_hash
          , i_appl_prioritized  => i_appl_prioritized
          , i_execution_mode    => l_execution_mode
        );

        modify_data_migrate(
            i_appl_id           => io_appl_id
          , i_appl_data         => i_appl_data
          , i_is_new            => i_is_new
        );
    else
        add_application(
            io_appl_id          => io_appl_id
          , o_seqnum            => o_seqnum
          , i_appl_type         => i_appl_type
          , i_appl_number       => i_appl_number
          , i_flow_id           => i_flow_id
          , i_inst_id           => i_inst_id
          , i_agent_id          => i_agent_id
          , i_appl_status       => i_appl_status
          , i_session_file_id   => i_session_file_id
          , i_file_rec_num      => i_file_rec_num
          , i_customer_type     => i_customer_type
          , i_split_hash        => l_split_hash
          , i_reject_code       => i_reject_code
          , i_user_id           => i_user_id
          , i_is_visible        => i_is_visible
          , i_appl_prioritized  => i_appl_prioritized
          , i_execution_mode    => l_execution_mode
        );

        modify_application_data(
            i_appl_id           => io_appl_id
          , i_appl_data         => i_appl_data
          , i_is_new            => i_is_new
        );
    end if;

end add_application;

end app_ui_application_pkg;
/
