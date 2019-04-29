create or replace package body cst_bmed_card_export_pkg is
/************************************************************
 * API for process files <br />
 * Created by Kolodkina Y.(kolodkina@bpcbt.com)  at 09.08.2016 <br />
 * Last changed by $Author: kolodkina $ <br />
 * $LastChangedDate:: 2016-09-06 12:00:00 +0300#$ <br />
 * Revision: $LastChangedRevision: 1 $ <br />
 * Module: CST_BMED_CARD_EXPORT_PKG <br />
 * @headcom
 ***********************************************************/

procedure export_barcodes(
    i_service_id            in     com_api_type_pkg.t_short_id
) is
    PROCESS_PROC_NAME      constant com_api_type_pkg.t_name := 'CST_BMED_CARD_EXPORT_PKG.EXPORT_BARCODES';
    DEFAULT_BULK_LIMIT     constant com_api_type_pkg.t_count := 2000;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_current_count        pls_integer := 0;
    l_new_barcode_file     com_api_type_pkg.t_raw_tab;
    l_old_barcode_file     com_api_type_pkg.t_raw_tab;
    l_last_barcode         com_api_type_pkg.t_name;

    l_container_id         com_api_type_pkg.t_long_id    := prc_api_session_pkg.get_container_id;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_event_type_tab       com_api_type_pkg.t_dict_tab;
    l_state_tab            com_api_type_pkg.t_dict_tab;
    l_barcode_tab          com_api_type_pkg.t_name_tab;
    l_card_id_tab          com_api_type_pkg.t_number_tab;
    l_instance_id_tab      com_api_type_pkg.t_number_tab;

    l_new_record_count     com_api_type_pkg.t_long_id := 0;
    l_new_record_number    com_api_type_pkg.t_integer_tab;
    l_old_record_count     com_api_type_pkg.t_long_id := 0;
    l_old_record_number    com_api_type_pkg.t_integer_tab;

    l_sysdate              date;
    l_new_session_file_id  com_api_type_pkg.t_long_id;
    l_old_session_file_id  com_api_type_pkg.t_long_id;
    l_enable_event_type    com_api_type_pkg.t_dict_value;
    l_disable_event_type   com_api_type_pkg.t_dict_value;
    l_service_id           com_api_type_pkg.t_short_id;
    l_barcode_new_instance com_api_type_pkg.t_name;

    cursor evt_object_cur is
        select event_object_id
             , event_type
             , state
             , card_uid
             , card_id
             , instance_id
          from (
            select a.id  as event_object_id
                 , e.event_type
                 , i.state
                 , i.card_uid
                 , i.card_id
                 , i.id instance_id
              from evt_event_object a
                 , evt_event e
                 , iss_card_instance i
             where decode(a.status, 'EVST0001', a.procedure_name, null) = PROCESS_PROC_NAME
               and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
               and a.eff_date   <= l_sysdate
               and a.split_hash in (select split_hash from com_api_split_map_vw)
               and e.id          = a.event_id
               and a.object_id   = i.card_id
               and a.split_hash  = i.split_hash
             union all
            select a.id  as event_object_id
                 , e.event_type
                 , i.state
                 , i.card_uid
                 , i.card_id
                 , i.id instance_id
              from evt_event_object a
                 , evt_event e
                 , iss_card_instance i
             where decode(a.status, 'EVST0001', a.procedure_name, null) = PROCESS_PROC_NAME
               and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE --'ENTTCINS'
               and a.eff_date   <= l_sysdate
               and a.split_hash in (select split_hash from com_api_split_map_vw)
               and e.id          = a.event_id
               and a.object_id   = i.id
               and a.split_hash  = i.split_hash
            )
            order by card_uid asc
                , event_object_id desc
        ;

    procedure save_estimation is
    begin
        l_estimated_count := l_estimated_count + l_current_count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );
        trc_log_pkg.debug('Estimated count of barcodes is [' || l_estimated_count || ']');
    end save_estimation;

    procedure register_session_file (
        i_service_id            in     com_api_type_pkg.t_short_id
        , i_file_type           in     com_api_type_pkg.t_dict_value
        , o_session_file_id     out    com_api_type_pkg.t_long_id
    ) is
    begin
        l_params.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'SERVICE_ID'
            , i_value    => i_service_id
            , io_params  => l_params
        );
        prc_api_file_pkg.open_file (
            o_sess_file_id  => o_session_file_id
            , i_file_type   => i_file_type
            , io_params     => l_params
        );
    end;

begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    trc_log_pkg.debug(
        i_text       => PROCESS_PROC_NAME || ': service_id [#1], l_container_id [#2], l_sysdate [#3]'
      , i_env_param1 => i_service_id
      , i_env_param2 => l_container_id
      , i_env_param3 => l_sysdate
    );

    prc_api_stat_pkg.log_start;

    -- get events of service
    begin
        select t.enable_event_type
             , t.disable_event_type
          into l_enable_event_type
             , l_disable_event_type
          from prd_service s
             , prd_service_type t
         where s.id = i_service_id
           and t.id = s.service_type_id;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'SERVICE_NOT_FOUND'
              , i_env_param1 => i_service_id
            );
    end;

    trc_log_pkg.debug(
        i_text       => 'l_enable_event_type [#1], l_disable_event_type [#2]'
      , i_env_param1 => l_enable_event_type
      , i_env_param2 => l_disable_event_type
    );

    open evt_object_cur;

    loop
        fetch evt_object_cur
         bulk collect into
              l_event_tab
            , l_event_type_tab
            , l_state_tab
            , l_barcode_tab -- card_uid
            , l_card_id_tab
            , l_instance_id_tab
        limit DEFAULT_BULK_LIMIT;

        trc_log_pkg.debug('Fetched [' || evt_object_cur%rowcount || '] records');

        l_current_count := l_event_tab.count;

        save_estimation;

        l_new_record_number.delete;
        l_new_barcode_file.delete;
        l_old_record_number.delete;
        l_old_barcode_file.delete;

        for i in 1..l_event_tab.count loop
            -- split barcodes into files
            if l_last_barcode is null or l_last_barcode != l_barcode_tab(i) then -- skip double barcode
                trc_log_pkg.debug('Processing: event_object_id [' || l_event_tab(i)
                                  || '], instance_id [' || l_instance_id_tab(i)
                                  || '], state [' || l_state_tab(i)
                                  || '], event_type [' || l_event_type_tab(i) || ']');

                if l_event_type_tab(i) = l_enable_event_type then

                    l_new_barcode_file(i) := l_barcode_tab(i);
                    l_new_record_count    := l_new_record_count + 1;
                    l_new_record_number(i):= l_new_record_count;

                    l_last_barcode        := l_barcode_tab(i);

                elsif l_event_type_tab(i) = l_disable_event_type then

                    l_old_barcode_file(i) := l_barcode_tab(i);
                    l_old_record_count    := l_old_record_count + 1;
                    l_old_record_number(i):= l_old_record_count;

                    l_last_barcode        := l_barcode_tab(i);

                elsif l_state_tab(i) = iss_api_const_pkg.CARD_STATE_CLOSED then

                    -- search active service for card
                    select min(service_id)
                      into l_service_id
                      from prd_service_object o
                     where o.object_id   = l_card_id_tab(i)
                       and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and o.status      = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE --'SROS0020'
                       and o.end_date   is null
                       and o.service_id  = i_service_id;

                    trc_log_pkg.debug('closed instance, l_service_id [' || l_service_id || ']');

                    if l_service_id is not null then
                        -- search new instance
                        select min(card_uid)
                          into l_barcode_new_instance
                          from iss_card_instance i
                         where i.preceding_card_instance_id = l_instance_id_tab(i)
                           and i.state != iss_api_const_pkg.CARD_STATE_CLOSED;

                        trc_log_pkg.debug('l_barcode_new_instance [' || l_barcode_new_instance || ']');

                        if l_barcode_new_instance is not null then
                            l_old_barcode_file(i) := l_barcode_tab(i);
                            l_old_record_count    := l_old_record_count + 1;
                            l_old_record_number(i):= l_old_record_count;

                            l_new_barcode_file(i) := l_barcode_new_instance;
                            l_new_record_count    := l_new_record_count + 1;
                            l_new_record_number(i):= l_new_record_count;

                            l_last_barcode        := l_barcode_tab(i);
                        end if;
                    end if;

                else
                    trc_log_pkg.debug('Skip event_object_id [' || l_event_tab(i)
                                      || '], instance_id [' || l_instance_id_tab(i)
                                      || '], card_id [' || l_card_id_tab(i) || ']');
                end if;
            end if;
        end loop;

        -- open files if needed
        if l_new_barcode_file.count > 0 then
            if l_new_session_file_id is null then
                register_session_file (
                    i_service_id          => i_service_id
                    , i_file_type         => 'FLTPNBRC'
                    , o_session_file_id   => l_new_session_file_id
                );
                trc_log_pkg.debug('File with new barcodes was registered [' || l_new_session_file_id || ']');
            end if;

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_new_session_file_id
              , i_raw_tab       => l_new_barcode_file
              , i_num_tab       => l_new_record_number
            );
        end if;

        if l_old_barcode_file.count > 0 then
            if l_old_session_file_id is null then
                register_session_file (
                    i_service_id          => i_service_id
                    , i_file_type         => 'FLTPOBRC'
                    , o_session_file_id   => l_old_session_file_id
                );
                trc_log_pkg.debug('File with old barcodes was registered, [' || l_old_session_file_id || ']');
            end if;

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_old_session_file_id
              , i_raw_tab       => l_old_barcode_file
              , i_num_tab       => l_old_record_number
            );
        end if;

        evt_api_event_pkg.process_event_object (
            i_event_object_id_tab => l_event_tab
        );

        prc_api_stat_pkg.increase_current (
            i_current_count     => l_event_tab.count
          , i_excepted_count    => 0
        );

        exit when evt_object_cur%notfound;
    end loop;

    if l_new_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id      => l_new_session_file_id
          , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    if l_old_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id      => l_old_session_file_id
          , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    close evt_object_cur;

    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_estimated_count
    );

    trc_log_pkg.debug(PROCESS_PROC_NAME || ': END');

exception
    when others then

        if evt_object_cur%isopen then
            close evt_object_cur;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_new_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_new_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if l_old_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_old_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end;

end;
/
