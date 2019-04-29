create or replace package body fcl_prc_flush_limit_pkg as

procedure process is
    cursor cu_limits_count is
        select count(*)
          from fcl_limit_buffer;

    cursor cu_limit_buffer is
        select id
             , limit_type
             , entity_type
             , object_id
             , count_value
             , sum_value
          from fcl_limit_buffer;

    l_buffer_id_tab         com_api_type_pkg.t_number_tab;
    l_limit_type_tab        com_api_type_pkg.t_dict_tab;
    l_entity_type_tab       com_api_type_pkg.t_dict_tab;
    l_object_id_tab         com_api_type_pkg.t_number_tab;
    l_count_value_tab       com_api_type_pkg.t_number_tab;
    l_sum_value_tab         com_api_type_pkg.t_number_tab;
    
    l_record_count          pls_integer;
    
begin
    prc_api_stat_pkg.log_start;
    
    open cu_limits_count;
    fetch cu_limits_count into l_record_count;
    close cu_limits_count;
    
    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count 
    );
    
    if l_record_count > 0 then

        open cu_limit_buffer;
        
        loop
            fetch cu_limit_buffer bulk collect into
                l_buffer_id_tab
              , l_limit_type_tab
              , l_entity_type_tab
              , l_object_id_tab
              , l_count_value_tab
              , l_sum_value_tab
            limit 1000;
            
            forall i in 1..l_buffer_id_tab.count
                update fcl_limit_counter
                   set count_value = nvl(count_value, 0) + nvl(l_count_value_tab(i), 1)
                     , sum_value   = nvl(sum_value, 0) + nvl(l_sum_value_tab(i), 0)
                 where limit_type  = l_limit_type_tab(i)
                   and entity_type = l_entity_type_tab(i)
                   and object_id   = l_object_id_tab(i);
            
            forall i in 1..l_buffer_id_tab.count
                delete from fcl_limit_buffer where id = l_buffer_id_tab(i);
            
            prc_api_stat_pkg.increase_current (
                i_current_count       => l_buffer_id_tab.count
              , i_excepted_count      => 0
            );
            
            exit when cu_limit_buffer%notfound;
        end loop;
        
    end if;
    
    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cu_limit_buffer%isopen then
            close cu_limit_buffer;
        end if;

        if cu_limits_count%isopen then
            close cu_limits_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;


end;

end;
/