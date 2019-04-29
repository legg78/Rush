create or replace package body itf_api_naming_pkg as
/**********************************************************
 * ITF for name pool<br/>
 * Created by Gogolev I. (i.gogolev@bpcbt.com) at 21.03.2017<br/>
 * Last changed by $Author: $<br/>
 * $LastChangedDate: 21.03.2017 $<br/>
 * Revision: $LastChangedRevision: $<br/>
 * Module: ITF_API_NAMING_PKG
 * @headcom
 **********************************************************/
procedure import_pool_value(
    i_index_range_id   in     com_api_type_pkg.t_short_id
  , i_value            in     com_api_type_pkg.t_large_id
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.import_pool_value: ';
    l_partition_key    com_api_type_pkg.t_short_id;
    
begin
    
    l_partition_key := rul_ui_name_pool_pkg.get_partition_key(i_index_range_id => i_index_range_id);
    
    insert into rul_name_index_pool(
        id
      , index_range_id
      , value
      , is_used
      , partition_key
    ) values(
        rul_name_index_pool_seq.nextval
      , i_index_range_id
      , i_value
      , com_api_const_pkg.FALSE
      , l_partition_key
    );
    
exception
    when dup_val_on_index then
        
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' record with index_range_id [#1] and value [#2] already exist'
          , i_env_param1 => i_index_range_id
          , i_env_param2 => i_value
        );
        
end import_pool_value;

procedure import_pool_values(
    i_index_range_id   in     com_api_type_pkg.t_short_id
  , i_values_tab       in     com_api_type_pkg.t_large_tab
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.import_pool_value: ';
    l_partition_key    com_api_type_pkg.t_short_id;
    
    l_values_tab       num_tab_tpt;
    
    l_count            com_api_type_pkg.t_long_id := 0;
    
begin
    
    if i_values_tab.count > 0 then
        
        for i in i_values_tab.first .. i_values_tab.last
        loop
            
            if not l_values_tab.exists(1) then
                l_values_tab := num_tab_tpt(i_values_tab(i));
            else
                l_values_tab.extend;
                l_values_tab(l_values_tab.last) := i_values_tab(i);
            end if;
            
        end loop;
    
        l_partition_key := rul_ui_name_pool_pkg.get_partition_key(i_index_range_id => i_index_range_id);
        
        insert into rul_name_index_pool(
            id
          , index_range_id
          , value
          , is_used
          , partition_key
        )
        (select rul_name_index_pool_seq.nextval
              , d.index_range_id
              , d.value
              , com_api_const_pkg.FALSE
              , l_partition_key
           from (
                 select distinct
                        i_index_range_id as index_range_id
                      , column_value as value
                   from table(l_values_tab)
                 minus
                 select index_range_id
                      , value
                   from rul_name_index_pool
                  where index_range_id = i_index_range_id
           ) d
        );
        
        l_count := sql%rowcount;
        
    end if;
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' added l_count [#1] record with index_range_id [#2] from all_count [#3]'
      , i_env_param1 => l_count
      , i_env_param2 => i_index_range_id
      , i_env_param3 => i_values_tab.count
    );
        
end import_pool_values;
 
end itf_api_naming_pkg;
/
