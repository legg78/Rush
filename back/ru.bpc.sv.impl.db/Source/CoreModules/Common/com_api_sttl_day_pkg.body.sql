create or replace package body com_api_sttl_day_pkg as
/************************************************************
 * API for settlement days <br />
 * Created by Filimonov A.(filimonov@bpcbt.com)  at 30.07.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: com_api_sttl_day_pkg <br />
 * @headcom
 ***********************************************************/

    g_sysdate   date;
    g_sttl_days com_api_type_pkg.t_sttl_day_tab;

    function get_sysdate return date is
    begin
        return nvl(g_sysdate, sysdate);
    end;

    procedure set_sysdate (
        i_sysdate           in date
    ) is
    begin
        g_sysdate := nvl(i_sysdate, sysdate);
    end;

    procedure unset_sysdate is
    begin
        g_sysdate := null;
    end;   

    function get_next_sttl_date (
        i_sttl_date                 in date default null
        , i_inst_id                 in com_api_type_pkg.t_inst_id default null
        , i_alg_day                 in com_api_type_pkg.t_dict_value
    ) return date is
        l_sttl_date_new             date;
        l_sttl_date_cur             date;
    begin
        -- set new sttl date
        case nvl(i_alg_day, com_api_const_pkg.DATE_CALC_ALG_EQUAL_PASSED)
            when com_api_const_pkg.DATE_CALC_ALG_EQUAL_PASSED then
                l_sttl_date_new := trunc(nvl(i_sttl_date, get_sysdate));

            when com_api_const_pkg.DATE_CALC_ALG_LESS_PASSED then
                l_sttl_date_new := trunc(nvl(i_sttl_date, get_sysdate))-1;
                if com_api_holiday_pkg.is_holiday(l_sttl_date_new, nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)) = com_api_type_pkg.TRUE then
                    l_sttl_date_new := com_api_holiday_pkg.get_prev_working_day (
                        i_day        => l_sttl_date_new
                        , i_inst_id  => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                    );
                end if;

            when com_api_const_pkg.DATE_CALC_ALG_GREAT_PASSED then
                l_sttl_date_new := trunc(nvl(i_sttl_date, get_sysdate))+1;
                if com_api_holiday_pkg.is_holiday(l_sttl_date_new, nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)) = com_api_type_pkg.TRUE then
                    l_sttl_date_new := com_api_holiday_pkg.get_next_working_day (
                        i_day        => l_sttl_date_new
                        , i_inst_id  => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                    );
                end if;
                
            when com_api_const_pkg.DATE_CALC_ALG_NEXT_PASSED then
                l_sttl_date_cur := com_api_sttl_day_pkg.get_open_sttl_date(
                                       i_inst_id  => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                                   );
                l_sttl_date_new := l_sttl_date_cur + 1;

        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ALG_CALC_STTL_DAY'
                , i_env_param1  => i_alg_day
            );
        end case;
        
        return l_sttl_date_new;
    end;
      

    procedure set_sttl_day (
        i_sttl_date           in date default null
        , i_inst_id           in com_api_type_pkg.t_inst_id default null
        , o_sttl_day          out com_api_type_pkg.t_tiny_id
    )is
    begin
        savepoint switching_settlement_day;
        
        begin
            savepoint closing_current_day;
        
            update
                com_settlement_day
            set
                is_open = com_api_const_pkg.FALSE
            where
                decode(is_open, 1, inst_id) = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)  -- 1 = com_api_const_pkg.TRUE
            returning
                sttl_day + 1
            into
                o_sttl_day;
                
            if sql%rowcount = 0 then
                raise no_data_found;
            elsif sql%rowcount > 1 then
                raise too_many_rows;
            end if;
                
        exception
            when no_data_found then
                o_sttl_day := 1;
                
                /*com_api_error_pkg.raise_fatal_error (
                    i_error         => 'OPEN_STTL_DAY_NOT_FOUND'
                    , i_env_param1  => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                );*/
                
            when too_many_rows then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'FEW_OPEN_STTL_DAYS_FOUND'
                    , i_env_param1  => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                );
        end; 
    
        insert into com_settlement_day(
            id
            , inst_id
            , sttl_day
            , sttl_date
            , open_timestamp
            , is_open
            , seqnum
        ) values (
            com_settlement_day_seq.nextval
            , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
            , o_sttl_day
            , nvl(i_sttl_date, get_sysdate)
            , systimestamp
            , com_api_const_pkg.TRUE
            , 1
        );
    exception
        when others then
            rollback to savepoint switching_settlement_day;
            raise;
    end;

    procedure switch_sttl_day (
        i_sttl_date           in date default null
        , i_inst_id           in com_api_type_pkg.t_inst_id default null
        , i_alg_day           in com_api_type_pkg.t_dict_value default null
        , o_sttl_day          out com_api_type_pkg.t_tiny_id
    ) is
        l_sttl_date_new       date;
    begin
        -- set new sttl date
        l_sttl_date_new := com_api_sttl_day_pkg.get_next_sttl_date (
            i_sttl_date  => i_sttl_date
            , i_inst_id  => i_inst_id
            , i_alg_day  => i_alg_day
        );
        
        set_sttl_day (
            i_sttl_date   => l_sttl_date_new
            , i_inst_id   => i_inst_id
            , o_sttl_day  => o_sttl_day
        );
    end;

    procedure cache_sttl_days is
    begin
        free_cache_sttl_days;
        
        for rec in (
            select
                inst_id
                , sttl_day
                , sttl_date
            from
                com_settlement_day
            where
                decode(is_open, 1, inst_id) is not null -- 1 = com_api_type_pkg.TRUE
        ) loop
            g_sttl_days(rec.inst_id).sttl_day := rec.sttl_day;
            g_sttl_days(rec.inst_id).sttl_date := rec.sttl_date;
        end loop;
    end;
    
    procedure free_cache_sttl_days is
    begin
        g_sttl_days.delete;
    end;

    function read_open_sttl_day (
        i_inst_id               in com_api_type_pkg.t_inst_id
    ) return com_api_type_pkg.t_sttl_day_rec is
        l_result                com_api_type_pkg.t_sttl_day_rec;
    begin
        select 
            sttl_day
            , sttl_date
        into 
            l_result 
        from 
            com_settlement_day 
        where 
            decode(is_open, 1, inst_id) = i_inst_id;  -- 1 = com_api_const_pkg.TRUE
     
        return l_result;
    exception
        when no_data_found then
            if i_inst_id is null or i_inst_id != ost_api_const_pkg.DEFAULT_INST then
                    return read_open_sttl_day(ost_api_const_pkg.DEFAULT_INST);
                else
                    com_api_error_pkg.raise_fatal_error (
                        i_error         => 'OPEN_STTL_DAY_NOT_FOUND'
                        , i_env_param1  => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                    );
            end if;
        when too_many_rows then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'FEW_OPEN_STTL_DAYS_FOUND'
                , i_env_param1  => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
            );
    end;

    function get_open_sttl_day (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_force_read          in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_tiny_id is
    begin
        if i_force_read = com_api_const_pkg.FALSE and g_sttl_days.exists(i_inst_id) then
            return g_sttl_days(i_inst_id).sttl_day;
        elsif i_force_read = com_api_const_pkg.FALSE and g_sttl_days.exists(ost_api_const_pkg.DEFAULT_INST) then
            return g_sttl_days(ost_api_const_pkg.DEFAULT_INST).sttl_day;
        else
            return read_open_sttl_day(i_inst_id).sttl_day;  
        end if;
    end;

    function get_open_sttl_date (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_force_read          in com_api_type_pkg.t_boolean
    ) return date is
    begin
        if i_force_read = com_api_const_pkg.FALSE and g_sttl_days.exists(i_inst_id) then
            return g_sttl_days(i_inst_id).sttl_date;
        elsif i_force_read = com_api_const_pkg.FALSE and g_sttl_days.exists(ost_api_const_pkg.DEFAULT_INST) then
            return g_sttl_days(ost_api_const_pkg.DEFAULT_INST).sttl_date;
        else
            return read_open_sttl_day(i_inst_id).sttl_date;  
        end if;
    end;

    --
    -- This function returns date which is used in next "select" condition for performance purpose:
    --     and acc_entry.id(+) > l_from_id
    -- where:
    --     l_from_id := com_api_id_pkg.get_from_id(com_api_sttl_day_pkg.get_sttl_day_open_date(i_date, i_inst_id));
    --
    -- It need when we calculate the balance amount on begin of settlement day (i_sttl_date).
    --
    function get_sttl_day_open_date (
        i_sttl_date             in date
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) return date is
        l_common_sttl_day       com_api_type_pkg.t_boolean;
        l_result                date;
    begin
        l_common_sttl_day   := set_ui_value_pkg.get_system_param_n('COMMON_SETTLEMENT_DAY');

        if l_common_sttl_day = com_api_type_pkg.TRUE then

            select max(least(sttl_date, open_timestamp))
              into l_result
              from com_settlement_day
             where inst_id    = ost_api_const_pkg.DEFAULT_INST
               and sttl_date <= i_sttl_date;

        else
            select max(least(sttl_date, open_timestamp))
              into l_result
              from com_settlement_day
             where inst_id    = i_inst_id
               and sttl_date <= i_sttl_date;
          
        end if;

        return l_result;
    end;

    function get_calc_date( 
        i_inst_id               in com_api_type_pkg.t_inst_id     default null
      , i_date_type             in com_api_type_pkg.t_dict_value  default null
    ) return date is   
        l_inst_id               com_api_type_pkg.t_inst_id;
        l_date_type             com_api_type_pkg.t_dict_value;
    begin
        l_inst_id := nvl(i_inst_id, com_ui_user_env_pkg.get_user_inst);

        if i_date_type is null then
            l_date_type := set_ui_value_pkg.get_inst_param_v(i_param_name => 'DEFAULT_DATE_TYPE', i_inst_id => l_inst_id);   
        else
            l_date_type := i_date_type;
        end if;
        
        case l_date_type
            when fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE then
                return get_sysdate;
            when fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE then
                return com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => l_inst_id);
            else    
                return get_sysdate;
        end case; 
    end;

    function map_date_type_dict_to_dict(
        i_date_type        in  com_api_type_pkg.t_dict_value
      , i_dict_map         in  com_api_type_pkg.t_dict_value
      , i_mask_error       in  com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_dict_value is
        LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.map_date_type_dict_to_dict: ';
        l_date_type        com_api_type_pkg.t_dict_value;
    begin
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Started with params - date_type_value [#1] dict_map [#2]'
          , i_env_param1 => i_date_type
          , i_env_param2 => i_dict_map
        );
        
        l_date_type := case
                           when i_dict_map = com_api_const_pkg.DATE_PURPOSE_DICTIONARY_TYPE
                               then case 
                                        when i_date_type = fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE
                                            then com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                        when i_date_type = fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE
                                            then com_api_const_pkg.DATE_PURPOSE_BANK
                                        else null
                                    end
                           when i_dict_map = fcl_api_const_pkg.DATE_TYPE_DICTIONARY_TYPE
                               then case 
                                        when i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                            then fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE
                                        when i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                                            then fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE
                                        else null
                                    end
                           else null
                       end
        ;
        
        if l_date_type is null then
            com_api_error_pkg.raise_error(
                i_error      => 'CODE_NOT_CORRESPOND_TO_DICT'
              , i_env_param1 => i_date_type
              , i_env_param2 => i_dict_map
            );
        end if;
        
        return l_date_type;
        
    exception
        when others then
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Finished failed with params - date_type_value [#1] dict_map [#2]'
              , i_env_param1 => i_date_type
              , i_env_param2 => i_dict_map
            );
            
            if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
               
                if i_mask_error = com_api_const_pkg.TRUE then
                
                    return null;
                    
                else
                    
                    raise;
                    
                end if;
                
            elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
                
                raise;

            else
                
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
                
            end if;
            
    end map_date_type_dict_to_dict;
       
end;
/
