create or replace package body iss_prc_card_instance_pkg is
/**********************************************************
 * Processes for card instance processing
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 01.02.2017<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: ISS_PRC_CARD_INSTANCE_PKG
 * @headcom
 **********************************************************/

procedure process_expire_date(
    i_inst_id      in com_api_type_pkg.t_inst_id
) is
    BULK_LIMIT                  constant com_api_type_pkg.t_count := 1000;
    LOG_PREFIX                  constant com_api_type_pkg.t_name :=  lower($$PLSQL_UNIT) || '.process_expire_date: ';
    
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
    
    l_sysdate                   date;
    l_params                    com_api_type_pkg.t_param_tab;
    l_status                    com_api_type_pkg.t_dict_value;
    l_card_instance_id          com_api_type_pkg.t_number_tab;
    
    cursor cu_expir_data is
        select i.id
          from iss_card_instance i
         where i.expir_date <= l_sysdate
           and i.inst_id     = i_inst_id
           and i.state      != iss_api_const_pkg.CARD_STATE_CLOSED
           and i.split_hash in (select split_hash from com_api_split_map_vw);

    cursor cu_expir_count is
        select count(1)
          from iss_card_instance i
         where i.expir_date <= l_sysdate
           and i.inst_id     = i_inst_id
           and i.state      != iss_api_const_pkg.CARD_STATE_CLOSED
           and i.split_hash in (select split_hash from com_api_split_map_vw);

begin
    savepoint sp_process_expire_date;

    prc_api_stat_pkg.log_start;

    l_sysdate := get_sysdate;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'is started with params l_sysdate [#1], i_inst_id [#2]'
      , i_env_param1  => to_char(l_sysdate, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param2  => i_inst_id
    );

    open cu_expir_count;
    fetch cu_expir_count into l_estimated_count;
    close cu_expir_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
      , i_measure         => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
    );

    if l_estimated_count > 0 then

        open cu_expir_data;

        loop
            fetch cu_expir_data
              bulk collect into l_card_instance_id
              limit BULK_LIMIT;

            for i in 1 .. l_card_instance_id.count loop
                begin
                    savepoint sp_card_expire_date;

                    -- status
                    evt_api_status_pkg.change_status(
                        i_event_type     => iss_api_const_pkg.EVENT_TYPE_CARD_EXPIR_DEACT
                      , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                      , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      , i_object_id      => l_card_instance_id(i)
                      , i_reason         => null
                      , i_eff_date       => null
                      , i_inst_id        => i_inst_id
                      , i_params         => l_params
                      , i_register_event => com_api_const_pkg.TRUE
                    );
                    
                    -- state
                    evt_api_status_pkg.change_status(
                        i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                      , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      , i_object_id      => l_card_instance_id(i)
                      , i_inst_id        => i_inst_id
                      , i_new_status     => iss_api_const_pkg.CARD_STATE_CLOSED
                      , i_reason         => null
                      , o_status         => l_status
                      , i_eff_date       => null
                      , i_raise_error    => com_api_const_pkg.FALSE
                      , i_register_event => com_api_const_pkg.TRUE
                      , i_params         => l_params
                    );
                    
                exception
                    when com_api_error_pkg.e_application_error then
                        
                        l_excepted_count := l_excepted_count + 1;
                        
                        rollback to sp_card_expire_date;

                    when com_api_error_pkg.e_fatal_error then
                        
                        raise;

                    when others then
                        
                        rollback to sp_card_expire_date;

                        com_api_error_pkg.raise_fatal_error(
                            i_error         => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => sqlerrm
                        );
                        
                end;
                
            end loop;
            
            l_processed_count := l_processed_count + l_card_instance_id.count;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );

            exit when cu_expir_data%notfound;
            
        end loop;
        
        close cu_expir_data;
        
        evt_api_event_pkg.flush_events;

    end if;

    trc_log_pkg.debug (
        i_text      => LOG_PREFIX || 'finished success'
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      
    );
    
    exception
        when others then
            rollback to sp_process_expire_date;

            if cu_expir_count%isopen then
                close cu_expir_count;
            end if;

            if cu_expir_data%isopen then
                close cu_expir_data;
            end if;

            prc_api_stat_pkg.log_end(
                i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error      => 'UNHANDLED_EXCEPTION'
                  , i_env_param1 => sqlerrm
                );
            end if;
            raise;    
    
end process_expire_date;
    
end iss_prc_card_instance_pkg;
/
