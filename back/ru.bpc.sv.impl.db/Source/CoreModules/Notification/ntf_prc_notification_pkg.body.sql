create or replace package body ntf_prc_notification_pkg as

procedure stat_log_end (
    i_processed_total           in       com_api_type_pkg.t_count
  , i_excepted_total            in       com_api_type_pkg.t_count
  , i_rejected_total            in       com_api_type_pkg.t_count
  , i_result_code               in       com_api_type_pkg.t_dict_value
) is

begin
  
    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => i_processed_total + i_excepted_total + i_rejected_total
    );
    
    prc_api_stat_pkg.log_end(
        i_processed_total => i_processed_total
      , i_excepted_total  => i_excepted_total   
      , i_rejected_total  => i_rejected_total
      , i_result_code     => i_result_code
    );
    
end stat_log_end;

procedure make_notification (
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_ignore_missing_service    in      com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
) is
    BULK_LIMIT                  number := 400;

    l_sysdate                   date;
    l_thread_number             com_api_type_pkg.t_tiny_id;
    l_estimated_count           com_api_type_pkg.t_count := 0;
    l_excepted_count            com_api_type_pkg.t_count := 0;
    l_processed_count           com_api_type_pkg.t_count := 0;
    l_final_processed_count     com_api_type_pkg.t_count := 0;

    l_ok_event_id               com_api_type_pkg.t_number_tab;
    l_event_id                  com_api_type_pkg.t_number_tab;
    l_event_type                com_api_type_pkg.t_dict_tab;
    l_entity_type               com_api_type_pkg.t_dict_tab;
    l_object_id                 com_api_type_pkg.t_number_tab;
    l_eff_date                  com_api_type_pkg.t_date_tab;
    l_inst_id                   com_api_type_pkg.t_number_tab;

    cursor l_events_count is
        select count(*)
          from evt_event_object_vw o
             , evt_event_vw e
             , evt_subscriber_vw s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'NTF_PRC_NOTIFICATION_PKG.MAKE_NOTIFICATION'
           and o.eff_date         <= l_sysdate
           and (o.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and o.split_hash       in (select split_hash from com_split_map where thread_number = l_thread_number or l_thread_number = -1)
           and e.id                = o.event_id
           and e.event_type        = s.event_type
           and o.procedure_name    = s.procedure_name;

    cursor l_events is
        select o.id
             , e.event_type
             , o.entity_type
             , o.object_id
             , o.eff_date
             , o.inst_id
          from evt_event_object_vw o
             , evt_event_vw e
             , evt_subscriber_vw s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'NTF_PRC_NOTIFICATION_PKG.MAKE_NOTIFICATION'
           and o.eff_date         <= l_sysdate
           and (o.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and o.split_hash       in (select split_hash from com_split_map where thread_number = l_thread_number or l_thread_number = -1)
           and e.id                = o.event_id
           and e.event_type        = s.event_type
           and o.procedure_name    = s.procedure_name
      order by o.eff_date, s.priority;
begin
    savepoint process_make_notification;

    l_thread_number := get_thread_number;
    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text         => 'Process make notification. inst_id [#1] sysdate [#2]'
        , i_env_param1 => i_inst_id
        , i_env_param2 => to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss')
    );

    open l_events_count;
    fetch l_events_count into l_estimated_count;
    close l_events_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        open l_events;
        loop
            fetch l_events
            bulk collect into
            l_event_id
            , l_event_type
            , l_entity_type
            , l_object_id
            , l_eff_date
            , l_inst_id
            limit BULK_LIMIT;

            for i in 1..l_event_id.count loop
                begin
                    savepoint sp_make_notification;

                    trc_log_pkg.debug (
                        i_text          => 'Event type [#1] object id [#2]'
                        , i_env_param1  => l_event_type(i)
                        , i_env_param2  => l_object_id(i)
                    );

                    -- create notifucation
                    ntf_api_notification_pkg.make_notification (
                        i_inst_id                => l_inst_id(i)
                      , i_event_type             => l_event_type(i)
                      , i_entity_type            => l_entity_type(i)
                      , i_object_id              => l_object_id(i)
                      , i_eff_date               => l_eff_date(i)
                      , i_ignore_missing_service => i_ignore_missing_service
                      , io_processed_count => l_final_processed_count
                    );

                    -- register ok upload
                    l_ok_event_id(l_ok_event_id.count + 1) := l_event_id(i);

                exception
                    when com_api_error_pkg.e_application_error then
                        l_excepted_count := l_excepted_count + 1;
                        rollback to sp_make_notification;
                    when com_api_error_pkg.e_fatal_error then
                        raise;
                    when others then
                        com_api_error_pkg.raise_fatal_error(
                            i_error         => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => sqlerrm
                        );
                end;
            end loop;

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab  => l_ok_event_id
            );

            -- clear ok
            l_ok_event_id.delete;

            l_processed_count := l_processed_count + l_event_id.count;

            prc_api_stat_pkg.log_current (
                  i_current_count  => l_processed_count
                , i_excepted_count => l_excepted_count
            );

            exit when l_events%notfound;
        end loop;
        close l_events;
    end if;

    trc_log_pkg.debug (
        i_text      => 'Process make notification finished ...'
    );

    stat_log_end(
        i_processed_total => l_final_processed_count
      , i_excepted_total  => l_excepted_count
      , i_rejected_total  => 0
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to savepoint process_make_notification;

        if l_events%isopen then
            close l_events;
        end if;

        if l_events_count%isopen then
            close l_events_count;
        end if;

        stat_log_end(
            i_processed_total => l_final_processed_count
          , i_excepted_total  => l_excepted_count
          , i_rejected_total  => 0
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
          
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end;

procedure make_user_notification (
    i_inst_id                   in      com_api_type_pkg.t_inst_id
) is
    BULK_LIMIT                  number := 400;

    l_sysdate                   date := com_api_sttl_day_pkg.get_sysdate;
    l_thread_number             com_api_type_pkg.t_tiny_id := get_thread_number;
    l_estimated_count           com_api_type_pkg.t_count := 0;
    l_excepted_count            com_api_type_pkg.t_count := 0;
    l_processed_count           com_api_type_pkg.t_count := 0;
    l_final_processed_count     com_api_type_pkg.t_count := 0;

    l_ok_event_id               com_api_type_pkg.t_number_tab;
    l_event_id                  com_api_type_pkg.t_number_tab;
    l_event_type                com_api_type_pkg.t_dict_tab;
    l_entity_type               com_api_type_pkg.t_dict_tab;
    l_object_id                 com_api_type_pkg.t_number_tab;
    l_eff_date                  com_api_type_pkg.t_date_tab;

    cursor l_events_count is
        select count(*)
          from evt_event_object_vw o
             , evt_event_vw e
             , evt_subscriber_vw s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'NTF_PRC_NOTIFICATION_PKG.MAKE_USER_NOTIFICATION'
           and (o.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and o.split_hash       in (select split_hash from com_split_map where thread_number = l_thread_number or l_thread_number = -1)
           and e.id                = o.event_id
           and e.event_type        = s.event_type
           and o.procedure_name    = s.procedure_name;

    cursor l_events is
        select o.id
             , e.event_type
             , o.entity_type
             , o.object_id
             , o.eff_date
          from evt_event_object_vw o
             , evt_event_vw e
             , evt_subscriber_vw s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'NTF_PRC_NOTIFICATION_PKG.MAKE_USER_NOTIFICATION'
           and (o.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and o.split_hash       in (select split_hash from com_split_map where thread_number = l_thread_number or l_thread_number = -1)
           and e.id                = o.event_id
           and e.event_type        = s.event_type
           and o.procedure_name    = s.procedure_name
      order by o.eff_date, s.priority;
begin
    savepoint process_make_notification;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text         => 'Process make user notification. inst_id [#1] sysdate [#2]'
        , i_env_param1 => i_inst_id
        , i_env_param2 => l_sysdate
    );

    open l_events_count;
    fetch l_events_count into l_estimated_count;
    close l_events_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    if l_estimated_count > 0 then
        open l_events;
        loop
            fetch l_events
            bulk collect into
            l_event_id
            , l_event_type
            , l_entity_type
            , l_object_id
            , l_eff_date
            limit BULK_LIMIT;

            for i in 1..l_event_id.count loop
                begin
                    trc_log_pkg.debug (
                        i_text          => 'Event type [#1] object id [#2]'
                        , i_env_param1  => l_event_type(i)
                        , i_env_param2  => l_object_id(i)
                    );

                    -- create notifucation
                    ntf_api_notification_pkg.make_user_notification (
                        i_inst_id        => i_inst_id
                        , i_event_type   => l_event_type(i)
                        , i_entity_type  => l_entity_type(i)
                        , i_object_id    => l_object_id(i)
                        , i_eff_date     => l_eff_date(i)
                        , io_processed_count => l_final_processed_count                        
                    );

                    -- register ok upload
                    l_ok_event_id(l_ok_event_id.count + 1) := l_event_id(i);

                exception
                    when com_api_error_pkg.e_application_error then
                        l_excepted_count := l_excepted_count + 1;
                    when com_api_error_pkg.e_fatal_error then
                        raise;
                    when others then
                        com_api_error_pkg.raise_fatal_error(
                            i_error         => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => sqlerrm
                        );
                end;
            end loop;

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab  => l_ok_event_id
            );

            -- clear ok
            l_ok_event_id.delete;

            l_processed_count := l_processed_count + l_event_id.count;

            prc_api_stat_pkg.log_current (
                  i_current_count  => l_processed_count
                , i_excepted_count => l_excepted_count
            );

            exit when l_events%notfound;
        end loop;
        close l_events;
    end if;

    trc_log_pkg.debug (
        i_text      => 'Process make user notification finished ...'
    );

    stat_log_end(
        i_processed_total => l_final_processed_count
      , i_excepted_total  => l_excepted_count
      , i_rejected_total  => 0
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );    
exception
    when others then
        rollback to savepoint process_make_notification;

        if l_events%isopen then
            close l_events;
        end if;

        if l_events_count%isopen then
            close l_events_count;
        end if;

        stat_log_end(
            i_processed_total => l_final_processed_count
          , i_excepted_total  => l_excepted_count
          , i_rejected_total  => 0
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );        

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end;

procedure upload_notification(
    i_channel_id                in      com_api_type_pkg.t_tiny_id   default null
)
is
    BULK_LIMIT                  number := 100;
    l_message_cur               sys_refcursor;

    l_rowid                     com_api_type_pkg.t_rowid_tab;
    l_ok_rowid                  com_api_type_pkg.t_rowid_tab;
    l_channel_id                com_api_type_pkg.t_number_tab;
        
    l_text                      com_api_type_pkg.t_clob_tab;
    l_delivery_address          com_api_type_pkg.t_varchar2_tab;
    l_delivery_date             com_api_type_pkg.t_date_tab;
    l_lang                      com_api_type_pkg.t_dict_tab;
    l_urgency_level             com_api_type_pkg.t_number_tab;
    l_entity_type               com_api_type_pkg.t_dict_tab;
    l_object_id                 com_api_type_pkg.t_long_tab;
        
    l_estimated_count           com_api_type_pkg.t_count := 0;
    l_processed_count           com_api_type_pkg.t_count := 0;

    l_old_channel_id            com_api_type_pkg.t_tiny_id := -1;
    l_header_writed             boolean := false;

    l_line                      com_api_type_pkg.t_raw_data;
    l_file_source               clob;

    l_session_file_id           com_api_type_pkg.t_long_id;

    l_where_placeholder         constant varchar2(100) := '##WHERE##';

    l_cursor_stmt               varchar2(4000) :=
       'select
            n.rowid
            , n.channel_id
            , n.text
            , n.delivery_address
            , n.delivery_date
            , n.lang
            , n.urgency_level
            , n.entity_type
            , n.object_id
        from
            ntf_message n
        ' || l_where_placeholder || '
        order by
            n.channel_id
        for update of
            n.is_delivered ';
        
    l_count_stmt                varchar2(4000) :=
        'select count(*)
         from
             ntf_message n
         ' || l_where_placeholder;
        
    l_where                     varchar2(2000) :=
    'where
         n.is_delivered = :is_delivered
         and n.delivery_date <= :delivery_date
         and n.channel_id = nvl(:p_channel_id, n.channel_id)';

    procedure flush_file is
    begin
        prc_api_file_pkg.put_file (
            i_sess_file_id  => l_session_file_id
            , i_clob_content  => l_file_source
        );
    end;

    procedure register_session_file is
    begin
        prc_api_file_pkg.open_file (
            o_sess_file_id => l_session_file_id
        );
    end;

    procedure put_header is
    begin
        l_line := com_api_const_pkg.XML_HEADER || chr(10) ||
                  '<notifications>' || chr(10) ||
                  '<file_id>' || l_session_file_id || '</file_id>' || chr(10) ||
                  '<file_type>' || ntf_api_const_pkg.FILE_TYPE_NOTIFICATIONS || '</file_type>' || chr(10) ||
                  '<channel_type>' || i_channel_id || '</channel_type>' || chr(10);
        dbms_lob.write(l_file_source, length(l_line), 1, l_line);
    end;

    procedure put_trailer is
    begin
        l_line := '</notifications>';
        dbms_lob.writeappend(l_file_source, length(l_line), l_line);
    end;

    procedure put_body(
        i_delivery_address in com_api_type_pkg.t_full_desc
      , i_text             in clob
      , i_lang             in com_api_type_pkg.t_dict_value
      , i_delivery_date    in date
      , i_urgency_level    in com_api_type_pkg.t_tiny_id
      , i_entity_type      in com_api_type_pkg.t_dict_value
      , i_object_id        in com_api_type_pkg.t_long_id
    ) is
    begin
        l_line := '<notification>' ||  chr(10);
        l_line := l_line || '  <delivery_address>' || i_delivery_address || '</delivery_address>' || chr(10);
        l_line := l_line || '  <text>' || i_text || '</text>' || chr(10);
        l_line := l_line || '  <lang>' || i_lang || '</lang>' || chr(10);
        l_line := l_line || '  <delivery_date>' || to_char(i_delivery_date, 'dd.mm.yyyy') || '</delivery_date>' || chr(10);
        l_line := l_line || '  <urgency_level>' || i_urgency_level || '</urgency_level>' || chr(10);
        l_line := l_line || '  <entity_type>' || i_entity_type || '</entity_type>' || chr(10);
        l_line := l_line || '  <object_id>' || i_object_id || '</object_id>' || chr(10);
        l_line := l_line || '</notification>' || chr(10);
        dbms_lob.writeappend(l_file_source, length(l_line), l_line);
    end;
        
begin
    savepoint process_start_upload_message;
        
    prc_api_stat_pkg.log_start;
        
    trc_log_pkg.debug(
        i_text       => 'Process unloading messages started, i_channel_id = [#1]'
      , i_env_param1 => i_channel_id
    );
        
    l_count_stmt := replace(l_count_stmt, l_where_placeholder, l_where);
        
    execute immediate l_count_stmt 
       into l_estimated_count 
      using com_api_type_pkg.FALSE
          , com_api_sttl_day_pkg.get_sysdate
          , i_channel_id;
        
    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );
        
    if l_estimated_count = 0 then
        trc_log_pkg.debug(
            i_text => 'No messages to export'
        );
    else
        dbms_lob.createtemporary(l_file_source, true);

        l_cursor_stmt := replace(l_cursor_stmt, l_where_placeholder, l_where);
            
        trc_log_pkg.debug(
            i_text => l_cursor_stmt
        );
            
        -- set paremeters and open cursor
        open l_message_cur 
         for l_cursor_stmt 
        using com_api_type_pkg.FALSE
              , com_api_sttl_day_pkg.get_sysdate
              , i_channel_id;
        --
        loop
            fetch l_message_cur
            bulk collect into
                l_rowid
              , l_channel_id
              , l_text
              , l_delivery_address
              , l_delivery_date
              , l_lang
              , l_urgency_level
              , l_entity_type
              , l_object_id
            limit BULK_LIMIT;

            for i in 1 .. l_rowid.count loop
                if l_channel_id(i) <> l_old_channel_id and l_header_writed then
                    put_trailer;
                    flush_file;
                    prc_api_file_pkg.close_file(
                        i_sess_file_id  => l_session_file_id
                      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                    );

                    l_header_writed := false;
                end if;
                    
                --every new channel messages puts in new file
                if l_channel_id(i) <> l_old_channel_id then
                    register_session_file;
                        
                    --l_channel_type_name := get_text(
                    --    i_table_name    => 'ntf_channel' 
                    --    , i_column_name => 'name'
                    --    , i_object_id   => i_channel_id
                    --    , i_lang        => com_ui_user_env_pkg.get_user_lang
                    --);
                        
                    put_header;

                    l_old_channel_id := l_channel_id(i);

                    l_header_writed := true;
                end if;

                if l_entity_type(i) = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
                    select ici.card_uid
                      into l_object_id(i)
                      from iss_card_instance ici
                     where ici.id = l_object_id(i);

                end if;

                put_body(
                    i_delivery_address  => l_delivery_address(i)
                  , i_text              => l_text(i)
                  , i_delivery_date     => l_delivery_date(i)
                  , i_lang              => l_lang(i)
                  , i_urgency_level     => l_urgency_level(i)
                  , i_entity_type       => l_entity_type(i)
                  , i_object_id         => l_object_id(i)
                );

                -- register ok upload
                l_ok_rowid(l_ok_rowid.count + 1) := l_rowid(i);
            end loop;

            l_processed_count := l_processed_count + l_ok_rowid.count;

            -- set delivered status
            forall i in 1 .. l_ok_rowid.count
                update
                    ntf_message n
                set
                    n.is_delivered = com_api_type_pkg.TRUE
                where
                    rowid = l_ok_rowid(i);

            -- clear ok uploaded
            l_ok_rowid.delete;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => 0
            );

            exit when l_message_cur%notfound;
        end loop;
        close l_message_cur;

        if l_header_writed then
            put_trailer;
            flush_file;
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

        end if;

        dbms_lob.freetemporary(l_file_source);
    end if;

    trc_log_pkg.debug(
        i_text      => 'Process unloading finished ...'
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total    => 0
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to savepoint process_start_upload_message;

        if l_message_cur%isopen then
            close l_message_cur;
        end if;

        if dbms_lob.isopen(l_file_source) = 1 then
            dbms_lob.freetemporary(l_file_source);
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
        raise;
end upload_notification;

procedure send_message(
    i_inst_id                   in      com_api_type_pkg.t_inst_id   default null
  , i_product_id                in      com_api_type_pkg.t_short_id  default null
  , i_bin_range_start           in      com_api_type_pkg.t_short_id  default null
  , i_bin_range_end             in      com_api_type_pkg.t_short_id  default null
  , i_delivery_time             in      date                         default null
  , i_message_text              in      com_api_type_pkg.t_text      default null
) is

    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_bin_range_start               com_api_type_pkg.t_bin;
    l_bin_range_end                 com_api_type_pkg.t_bin;
    l_delivery_time                 date;

    l_customers_id_tab              num_tab_tpt := num_tab_tpt();

    l_nls_date_format_original      com_api_type_pkg.t_name;
    l_nls_date_format_is_changed    com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

    l_sysdate                       date := com_api_sttl_day_pkg.get_sysdate;

    l_excepted_count                com_api_type_pkg.t_count := 0;
    l_processed_count               com_api_type_pkg.t_count := 0;
    l_final_processed_count         com_api_type_pkg.t_count := 0;
    l_estimated_count               com_api_type_pkg.t_count := 0;

    type t_customers_rec            is record (customer_id com_api_type_pkg.t_long_id, inst_id com_api_type_pkg.t_inst_id);   
    type t_customers_tab            is table of t_customers_rec;
    l_customers_tab                 t_customers_tab;
    procedure send_notifica_for_customer_tab(
        i_customers_id         in    com_api_type_pkg.t_long_id
      , i_sysdate              in    date
      , i_inst_id              in    com_api_type_pkg.t_inst_id
      , i_delivery_time        in    date
    ) is

    begin

       

            if prd_api_service_pkg.get_active_service_id(
                   i_entity_type       => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                 , i_object_id         => i_customers_id
                 , i_attr_name         => null
                 , i_eff_date          => i_sysdate
                 , i_mask_error        => com_api_type_pkg.TRUE
                 , i_inst_id           => i_inst_id
                 , i_service_type_id   => ntf_api_const_pkg.NOTIFICATION_CUSTOMER_SERVICE
               ) is not null then

                l_processed_count := l_processed_count + 1;

                begin

                    ntf_api_notification_pkg.make_notification(
                        i_inst_id          => i_inst_id
                      , i_event_type       => ntf_api_const_pkg.EVNT_SEND_PROMOTION_MESSAGE
                      , i_entity_type      => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id        => i_customers_id
                      , i_eff_date         => i_sysdate
                      , i_delivery_time    => i_delivery_time
                      , io_processed_count => l_final_processed_count
                    );

                exception
                    when com_api_error_pkg.e_application_error then

                        l_excepted_count := l_excepted_count + 1;

                end;

            else

                l_excepted_count := l_excepted_count + 1;

            end if;

        

        prc_api_stat_pkg.log_current(
            i_current_count     => l_processed_count
          , i_excepted_count    => 0
        );

    end send_notifica_for_customer_tab;

begin

    prc_api_stat_pkg.log_start;

    l_inst_id       := i_inst_id;
    l_product_id    := i_product_id;

    evt_api_shared_data_pkg.set_param(
        i_name  => 'I_MESSAGE_TEXT'
      , i_value => i_message_text
    );

    select value
      into l_nls_date_format_original
      from nls_session_parameters 
     where parameter = 'NLS_DATE_FORMAT';

    if lower(l_nls_date_format_original) <> com_api_const_pkg.DATE_FORMAT and i_delivery_time is not null then

        execute immediate 'alter session set NLS_DATE_FORMAT = ''' || com_api_const_pkg.DATE_FORMAT || '''';
        l_nls_date_format_is_changed    := com_api_type_pkg.TRUE;

        l_delivery_time                 := to_date(i_delivery_time, com_api_const_pkg.DATE_FORMAT);

        execute immediate 'alter session set NLS_DATE_FORMAT = ''' || l_nls_date_format_original || '''' ;
        l_nls_date_format_is_changed    := com_api_type_pkg.FALSE;

    elsif lower(l_nls_date_format_original) = com_api_const_pkg.DATE_FORMAT and l_delivery_time is not null then

        l_delivery_time                 := to_date(i_delivery_time, com_api_const_pkg.DATE_FORMAT);

    end if;

    l_bin_range_start    := i_bin_range_start;
    l_bin_range_end      := i_bin_range_end;
    
    if l_bin_range_start <= nvl(l_bin_range_end, l_bin_range_start) then

        l_bin_range_end      := nvl(l_bin_range_end, l_bin_range_start);

    else

        trc_log_pkg.debug(i_text => 'Reverse Range params.');

        l_bin_range_start    := nvl(l_bin_range_end, l_bin_range_start);
        l_bin_range_end      := nvl(l_bin_range_start, l_bin_range_end);
        
    end if;   

    trc_log_pkg.debug(
        i_text    => 'Params: l_inst_id [#1]; 
                              l_product_id [#2]; 
                              l_bin_range_start [#3];
                              l_bin_range_end [#4]; 
                              l_delivery_time [#5]; 
                              l_message_text [#6].'
      , i_env_param1 => l_inst_id
      , i_env_param2 => l_product_id
      , i_env_param3 => l_bin_range_start       
      , i_env_param4 => l_bin_range_end
      , i_env_param5 => to_char(l_delivery_time, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param6 => i_message_text
    );

    if l_product_id is not null then

        trc_log_pkg.debug(i_text => 'Processing by Product...');

        select distinct cust.id
          bulk collect
          into l_customers_id_tab
          from prd_contract       co
             , prd_customer       cust
             , prd_product        prod
             , com_contact_object cob
             , com_contact_data   cd
         where cust.id = co.customer_id
           and prod.id = co.product_id
           and prod.id = l_product_id
           and cob.object_id = cust.id
           and cob.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and cob.contact_type = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
           and cd.contact_id = cob.contact_id
           and cd.commun_method in(com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL)
           and l_sysdate between nvl(cd.start_date, l_sysdate - 1) and nvl(cd.end_date, l_sysdate + 1);

        l_estimated_count := l_customers_id_tab.count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        if l_customers_id_tab.count > 0 then
            
            if i_inst_id is null then

                select inst_id
                  into l_inst_id
                  from prd_product
                 where id = l_product_id;

                trc_log_pkg.debug(i_text => 'Parameter inst_id is NULL. Set to [' || l_inst_id || ']');

            end if;
            for ind in l_customers_id_tab.first .. l_customers_id_tab.last loop
      	        send_notifica_for_customer_tab(
                    i_customers_id     => l_customers_id_tab(ind)
                  , i_sysdate          => l_sysdate
                  , i_inst_id          => l_inst_id
                  , i_delivery_time    => l_delivery_time
                );
            end loop;

        end if;

    elsif l_bin_range_start is not null then

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
        );

        trc_log_pkg.debug(i_text => 'Processing by BIN range...');

       select distinct c.customer_id, nvl(i_inst_id, bn.inst_id) inst_id
          bulk collect 
          into l_customers_tab
          from iss_card_number    cn
             , iss_card           c
             , iss_card_instance  ci
             , iss_bin            bn
             , com_contact_object co
             , com_contact        cn
             , com_contact_data   cd
         where bn.bin between l_bin_range_start and l_bin_range_end
           and c.id = cn.card_id
           and c.id = ci.card_id 
           and ci.bin_id = bn.id 
           and co.object_id     = c.customer_id
           and co.entity_type   = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and co.contact_type  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
           and cn.id            = co.contact_id
           and cd.contact_id    = cn.id
           and cd.commun_method in(com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL) 
           and l_sysdate between nvl(cd.start_date, l_sysdate - 1) and nvl(cd.end_date, l_sysdate + 1);

           l_estimated_count := l_customers_tab.count;
           
           prc_api_stat_pkg.log_estimation(
                            i_estimated_count => l_estimated_count
                        );
           if l_estimated_count > 0 then
               for ind in l_customers_tab.first ..  l_customers_tab.last loop
                   send_notifica_for_customer_tab(
                       i_customers_id     => l_customers_tab(ind).customer_id
                     , i_sysdate          => l_sysdate
                     , i_inst_id          => l_customers_tab(ind).inst_id
                     , i_delivery_time    => l_delivery_time
                 );
               end loop;              
           end if;                  

    else

        trc_log_pkg.debug(i_text => 'Input params are not supported. Fill in PRODUCT_ID, BIN_RANGE_START, BIN_RANGE_END or {BIN_RANGE_START, BIN_RANGE_END} fields.');         

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

    end if;

    stat_log_end(
        i_processed_total => l_final_processed_count
      , i_excepted_total  => l_excepted_count
      , i_rejected_total  => 0
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
exception
    when others then

        stat_log_end(
            i_processed_total => l_final_processed_count
          , i_excepted_total  => l_excepted_count
          , i_rejected_total  => 0
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );        

        if l_nls_date_format_is_changed = com_api_type_pkg.TRUE then

            execute immediate 'alter session set NLS_DATE_FORMAT = ''' || l_nls_date_format_original || '''' ;

        end if;

        raise;

end send_message;
    
end;
/
