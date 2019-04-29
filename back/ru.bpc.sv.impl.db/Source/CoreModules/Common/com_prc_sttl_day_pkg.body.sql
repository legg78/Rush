create or replace package body com_prc_sttl_day_pkg as
/********************************************************* 
 *  Process for settlement days <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.07.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: com_prc_sttl_day_pkg   <br /> 
 *  @headcom 
 **********************************************************/ 
    procedure switch_sttl_day (
        i_sttl_date                 in date default null
        , i_inst_id                 in com_api_type_pkg.t_inst_id default null
        , i_alg_day                 in com_api_type_pkg.t_dict_value
    ) is
        l_param_tab                 com_api_type_pkg.t_param_tab;
        l_id                        com_api_type_pkg.t_short_id;
        l_sttl_date_old             date;
        l_sttl_date_new             date;
        l_sttl_day                  com_api_type_pkg.t_tiny_id;
        l_com_sttl_day              com_api_type_pkg.t_boolean;
        l_inst_id                   com_api_type_pkg.t_inst_id;
    begin
        savepoint switching_settlement_day;
        
        prc_api_stat_pkg.log_start;
        
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => 1
        );

        l_com_sttl_day := nvl( set_ui_value_pkg.get_system_param_n( i_param_name => 'COMMON_SETTLEMENT_DAY' ), com_api_type_pkg.TRUE );
        l_inst_id := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);

        if l_com_sttl_day = com_api_type_pkg.TRUE and l_inst_id != ost_api_const_pkg.DEFAULT_INST then
            com_api_error_pkg.raise_error (
                i_error         => 'STTL_DAY_CREATE_ONLY_DEFAULT_INST'
                , i_env_param1  => l_com_sttl_day
                , i_env_param2  => l_inst_id
                , i_env_param3  => 'COMMON_SETTLEMENT_DAY'
            );
        elsif l_com_sttl_day = com_api_type_pkg.FALSE and l_inst_id = ost_api_const_pkg.DEFAULT_INST then
            com_api_error_pkg.raise_error (
                i_error         => 'STTL_DAY_CREATE_EXCEPT_DEFAULT_INST'
                , i_env_param1  => l_com_sttl_day
                , i_env_param2  => l_inst_id
                , i_env_param3  => 'COMMON_SETTLEMENT_DAY'
            );
        end if;

        -- set new sttl date
        l_sttl_date_new := com_api_sttl_day_pkg.get_next_sttl_date (
            i_sttl_date  => i_sttl_date
            , i_inst_id  => l_inst_id
            , i_alg_day  => i_alg_day
        );

        -- close sttl day if exists
        begin
            update
                com_settlement_day
            set
                is_open = com_api_const_pkg.FALSE
            where
                decode(is_open, 1, inst_id) = l_inst_id
            returning
                id
                , sttl_day + 1
                , sttl_date
            into
                l_id
                , l_sttl_day
                , l_sttl_date_old;

            if sql%rowcount = 0 then
                raise no_data_found;
            elsif sql%rowcount > 1 then
                raise too_many_rows;
            end if;

            if l_sttl_date_new < l_sttl_date_old then
                com_api_error_pkg.raise_error (
                    i_error  => 'OPENED_DATE_LESS_CLOSED_DATE'
                    , i_env_param1  => to_char(l_sttl_date_new, com_api_const_pkg.DATE_FORMAT)
                    , i_env_param2  => l_inst_id
                );
            end if;

            -- clear parameters
            l_param_tab.delete;

            rul_api_param_pkg.set_param (
                io_params  => l_param_tab
                , i_name   => 'OPENED_STTL_DATE'
                , i_value  => l_sttl_date_new
            );
            rul_api_param_pkg.set_param (
                io_params  => l_param_tab
                , i_name   => 'CLOSED_STTL_DATE'
                , i_value  => l_sttl_date_old
            );
          
            -- register event close sttl day
            evt_api_event_pkg.register_event (
                i_event_type     => com_api_const_pkg.EVENT_TYPE_STTL_DAY_CLOSE
                , i_eff_date     => nvl(l_sttl_date_new, get_sysdate)
                , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_STTL_DATE
                , i_object_id    => l_id
                , i_inst_id      => l_inst_id
                , i_split_hash   => com_api_const_pkg.DEFAULT_SPLIT_HASH
                , i_param_tab    => l_param_tab
            );

        exception
            when no_data_found then
                l_sttl_day := 1;

            when too_many_rows then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'FEW_OPEN_STTL_DAYS_FOUND'
                    , i_env_param1  => l_inst_id
                );
        end;

        -- create sttl day
        l_id := com_settlement_day_seq.nextval;
        
        insert into com_settlement_day_vw (
            id
            , inst_id
            , sttl_day
            , sttl_date
            , open_timestamp
            , is_open
            , seqnum
        ) values (
            l_id
            , l_inst_id
            , l_sttl_day
            , l_sttl_date_new
            , systimestamp
            , com_api_const_pkg.TRUE
            , 1
        );

        -- clear parameters
        l_param_tab.delete;

        rul_api_param_pkg.set_param (
            io_params  => l_param_tab
            , i_name   => 'OPENED_STTL_DATE'
            , i_value  => l_sttl_date_new
        );
        rul_api_param_pkg.set_param (
            io_params  => l_param_tab
            , i_name   => 'CLOSED_STTL_DATE'
            , i_value  => l_sttl_date_old
        );
      
        -- register event open sttl day
        evt_api_event_pkg.register_event (
            i_event_type     => com_api_const_pkg.EVENT_TYPE_STTL_DAY_OPEN
            , i_eff_date     => nvl(l_sttl_date_new, get_sysdate)
            , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_STTL_DATE
            , i_object_id    => l_id
            , i_inst_id      => l_inst_id
            , i_split_hash   => com_api_const_pkg.DEFAULT_SPLIT_HASH
            , i_param_tab    => l_param_tab
        );
        
        prc_api_stat_pkg.log_end (
            i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
            , i_processed_total  => 1
        );

    exception
        when others then
            rollback to savepoint switching_settlement_day;
            
            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            
            raise;
    end;

end;
/
