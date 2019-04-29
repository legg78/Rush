create or replace package body acc_prc_entry_buffer_pkg is
/**********************************************************
 * Package contains the processes for entry buffer.
 * 
 * Created by Truschelev O.(truschelev@bpcbt.com) at 01.11.2018
 *
 * Module: ACC_PRC_ENTRY_BUFFER_PKG
 **********************************************************/

    -- Defragment blocks for table "acc_entry_buffer" and its indexes
    procedure defragment_acc_entry_buffer
    is
        l_estimated_count       com_api_type_pkg.t_long_id    := 0;
        l_processed_count       com_api_type_pkg.t_long_id    := 0;
        l_excepted_count        com_api_type_pkg.t_long_id    := 0;
        l_rejected_count        com_api_type_pkg.t_long_id    := 0;
        l_record_count          com_api_type_pkg.t_long_id;
    begin
        prc_api_stat_pkg.log_start;

        l_estimated_count := 1;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_estimated_count
        );

        select count(*)
          into l_record_count
          from acc_entry_buffer
         where rownum = 1;

        trc_log_pkg.debug(
            i_text        => 'acc_entry_buffer: check record count [#1]'
          , i_env_param1  => l_record_count
        );

        if l_record_count = 0 then
            begin
                lock table acc_entry_buffer in exclusive mode;

                trc_log_pkg.debug(
                    i_text        => 'acc_entry_buffer: table is locked'
                );

                select count(*)
                  into l_record_count
                  from acc_entry_buffer
                 where rownum = 1;

                trc_log_pkg.debug(
                    i_text        => 'acc_entry_buffer: re-check record count [#1]'
                  , i_env_param1  => l_record_count
                );

                if l_record_count = 0 then
                    execute immediate 'truncate table acc_entry_buffer';

                    l_processed_count := 1;

                    trc_log_pkg.debug(
                        i_text        => 'acc_entry_buffer: table is truncated'
                    );
                else
                    trc_log_pkg.info(
                        i_text        => 'ACC_ENTRY_BUFFER_IS_NOT_EMPTY'
                    );
                end if;

            exception when com_api_error_pkg.e_resource_busy then
                trc_log_pkg.info(
                    i_text        => 'ACC_ENTRY_BUFFER_IS_LOCKED'
                );
            end;
        else
            trc_log_pkg.info(
                i_text        => 'ACC_ENTRY_BUFFER_IS_NOT_EMPTY'
            );
        end if;

        -- Unlock table in any case
        commit;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    exception
        when others then
           trc_log_pkg.debug(
                i_text        => 'Process [#1] is finished with errors: [#2]'
              , i_env_param1  => 'RUN_GATHER_STATS'
              , i_env_param2  => sqlcode
            );

            l_excepted_count := 1;

            -- Unlock table in any case
            commit;

            prc_api_stat_pkg.log_end(
                i_excepted_total   => l_excepted_count
              , i_processed_total  => l_processed_count
              , i_rejected_total   => l_rejected_count
              , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => sqlerrm
                );
            end if;

            raise;

    end defragment_acc_entry_buffer;

end acc_prc_entry_buffer_pkg;
/
