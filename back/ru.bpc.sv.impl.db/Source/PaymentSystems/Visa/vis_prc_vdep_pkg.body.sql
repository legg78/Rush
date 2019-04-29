create or replace package body vis_prc_vdep_pkg is

BULK_LIMIT             constant integer := 500;

-- BID - Represents the Business ID (BID) number for your organization, i.e. the issuer BID.
function get_bid (
    i_inst_id               in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_name is
begin
    return nvl(
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name   => 'VISA_BUSSINESS_ID'
          , i_entity_type  => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
          , i_object_id    => i_inst_id
        )
      , 'BID'
    );
end;

procedure upload_bulk (
    i_inst_id               in com_api_type_pkg.t_inst_id
  , i_rows                  in com_api_type_pkg.t_medium_id     default 15000
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'VIS_PRC_VDEP_PKG.UPLOAD_BULK';
    LOG_PREFIX              constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || ': ';
    e_rows_limit_error      exception;

    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_record_number         com_api_type_pkg.t_long_id := 0;
    l_groups_count          com_api_type_pkg.t_count   := 1;

    l_sysdate               date;

    l_token_cur             sys_refcursor;
    l_token_id              com_api_type_pkg.t_medium_tab;
    l_token_name            com_api_type_pkg.t_name_tab;
    l_token_status          com_api_type_pkg.t_dict_tab;
    l_event_type            com_api_type_pkg.t_dict_tab;
    l_grp                   com_api_type_pkg.t_number_tab;
    l_count                 com_api_type_pkg.t_number_tab;
    l_last_proc_group       com_api_type_pkg.t_medium_id  := null;

    l_sess_file_id          com_api_type_pkg.t_long_id;
    l_rec_raw               com_api_type_pkg.t_raw_tab;
    l_rec_num               com_api_type_pkg.t_integer_tab;

    l_evt_objects_tab       num_tab_tpt := num_tab_tpt();
    l_token_ids_tab         num_tab_tpt := num_tab_tpt();
    l_token_id_tab          num_tab_tpt := num_tab_tpt();

    procedure open_file is
        l_params                com_api_type_pkg.t_param_tab;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_sess_file_id
            , i_file_type   => vis_api_const_pkg.FILE_TYPE_VDEP_BULK_FILE
            , io_params     => l_params
        );
    end;

    procedure close_file (
        i_status                com_api_type_pkg.t_dict_value
    ) is
    begin
        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
                , i_status      => i_status
            );
                      
        end if;
    end;

    procedure put_file is
    begin
        if l_sess_file_id is not null then
            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_sess_file_id
                , i_raw_tab     => l_rec_raw
                , i_num_tab     => l_rec_num
            );
            l_rec_raw.delete;
            l_rec_num.delete;
        end if;
    end;

    procedure put_header is
    begin
        l_record_number := l_record_number + 1;
        l_rec_raw(l_rec_raw.count + 1) := 'Token,Action Type,Request reason';
        l_rec_num(l_rec_num.count + 1) := l_record_number;
    end;

    procedure put_record(
        i_token            in com_api_type_pkg.t_card_number
      , i_token_status     in com_api_type_pkg.t_dict_value
      , i_event_type       in com_api_type_pkg.t_dict_value
    ) is
    begin
        l_record_number := l_record_number + 1;
        l_rec_raw(l_rec_raw.count + 1) := i_token || case i_token_status
                                                         when iss_api_const_pkg.CARD_TOKEN_STATUS_DEACTIVATED then
                                                             ',Delete,Close card'
                                                         when iss_api_const_pkg.CARD_TOKEN_STATUS_SUSPEND then
                                                             ',Suspend,Suspend card token'
                                                         when iss_api_const_pkg.CARD_TOKEN_STATUS_ACTIVE then
                                                             case i_event_type
                                                                 when iss_api_const_pkg.EVENT_TYPE_TOKEN_RESUME then
                                                                     ',Resume,Resume card token after suspension'
                                                             end
                                                     end;
        l_rec_num(l_rec_num.count + 1) := l_record_number;
    end;
begin
    savepoint bulk_start_upload;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'starting uploading bulk Visa with inst_id [#1], rows per file [#2]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_rows
    );

    prc_api_stat_pkg.log_start;

    if i_rows > 15000 then
        trc_log_pkg.error(
            i_text       => 'Rows count limit violation [#1]. Value of parameter i_rows should be 15000 or less .'
          , i_env_param1 => i_rows
        );
        raise e_rows_limit_error;
    end if;

    l_sysdate := get_sysdate;

    -- Select IDs of all event objects need to proceed
    select eo.id evt_id
         , eo.object_id evt_obj_id
    bulk collect into
           l_evt_objects_tab
         , l_token_ids_tab
      from evt_event_object eo
         , evt_event e
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = DEFAULT_PROCEDURE_NAME
       and eo.split_hash in (select split_hash from com_api_split_map_vw)
       and e.id = eo.event_id
       and eo.eff_date <= l_sysdate
       and (eo.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and eo.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN;

    -- Remove duplicates of token ids
    l_token_id_tab := set(l_token_ids_tab);

    l_groups_count := nvl(ceil(l_token_id_tab.count / i_rows), 1);

    open l_token_cur for
    select ct.id as token_id
         , ct.token
         , ct.status
         , ct.event_type
         , count(ct.id) over() cnt
         , ntile(l_groups_count) over (order by id)
      from iss_card_token ct
     where ct.id in (select column_value from table(cast(l_token_id_tab as num_tab_tpt)))
     order by ct.id;
    loop
        fetch l_token_cur
        bulk collect into
            l_token_id
          , l_token_name
          , l_token_status
          , l_event_type
          , l_count
          , l_grp
        limit BULK_LIMIT;

        l_rec_raw.delete;
        l_rec_num.delete;

        for i in 1..l_token_id.count loop
            if l_grp(i) != l_last_proc_group then
                put_file;
                close_file(
                    i_status  => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );

                open_file;
                put_header;
                -- set group id, which is currently processed
                l_last_proc_group := l_grp(i);

            elsif l_last_proc_group is null then
                -- set estimated count
                prc_api_stat_pkg.log_estimation(
                    i_estimated_count => l_count(i)
                );

                open_file;
                put_header;
                -- set group id, which is currently processed
                l_last_proc_group := l_grp(i);

            end if;

            begin
                put_record(
                    i_token         => l_token_name(i)
                  , i_token_status  => l_token_status(i)
                  , i_event_type    => l_event_type(i)
                );
            exception
                when com_api_error_pkg.e_application_error then
                    trc_log_pkg.debug(
                        i_text       => LOG_PREFIX || ' exporting token_id [#1] FAILED'
                      , i_env_param1 => l_token_id(i)
                    );

                    l_excepted_count := l_excepted_count + 1;
            end;
        end loop;

        l_processed_count := l_processed_count + l_token_id.count;

        prc_api_stat_pkg.log_current(
            i_current_count   => l_processed_count
          , i_excepted_count  => l_excepted_count
        );

        put_file;

        exit when l_token_cur%notfound;
    end loop;
    close l_token_cur;

    close_file (
        i_status  => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    -- Mark processed event object
    evt_api_event_pkg.process_event_object (
        i_event_object_id_tab  => l_evt_objects_tab
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );
    prc_api_stat_pkg.log_end (
        i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'finish!'
    );
exception
    when others then
        rollback to savepoint bulk_start_upload;

        if l_token_cur%isopen then
            close l_token_cur;
        end if;

        if l_sess_file_id is not null then
            close_file(
                i_status  => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end;

end;
/
