create or replace package body cst_ibbl_prc_checkbook_pkg as

BULK_LIMIT             constant integer := 1000;
CHECKBOOK_FILE_HEADER  constant com_api_type_pkg.t_raw_data := 'acc_no;leaf_count;acc_title;col_br_code;trans_code;routing_no;alt_system_id;alt_system_ref_id;first_leaf_num;branch_code;';

procedure process_checkbook_issuance(
    i_lang       in     com_api_type_pkg.t_dict_value   default get_user_lang
) is
    l_lang                   com_api_type_pkg.t_dict_value;

    l_event_object_id_tab    com_api_type_pkg.t_long_tab;
    l_checkbook_id_tab       com_api_type_pkg.t_long_tab;
    l_checkbook_number_tab   com_api_type_pkg.t_account_number_tab;
    l_checkbook_status_tab   com_api_type_pkg.t_dict_tab;
    l_delivery_branch_number com_api_type_pkg.t_name_tab;
    l_leaflet_count_tab      com_api_type_pkg.t_short_tab;
    l_reg_date_tab           com_api_type_pkg.t_date_tab;
    l_spent_date_tab         com_api_type_pkg.t_date_tab;
    l_estimated_count_tab    com_api_type_pkg.t_long_tab;
    l_rn_tab                 com_api_type_pkg.t_long_tab;
    l_account_number_tab     com_api_type_pkg.t_account_number_tab;
    l_name_tab               com_api_type_pkg.t_name_tab;
    l_leaf_number_tab        com_api_type_pkg.t_name_tab;
    l_agent_number_tab       com_api_type_pkg.t_name_tab;
    cursor cu_event_objects is
    select eo.id
         , cb.id checkbook_id
         , cb.checkbook_number
         , cb.checkbook_status
         , cb.delivery_branch_number
         , cb.leaflet_count
         , cb.reg_date
         , cb.spent_date
         , count(1) over() cnt
         , row_number() over (order by eo.id) rn
         , a.account_number
         , com_ui_object_pkg.get_object_desc(i_entity_type => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER,
                                             i_object_id   => a.customer_id,
                                             i_lang        => l_lang) as customer_name
         , (select min(q.leaflet_number) from cst_ibbl_acc_checkbook_leaflet q where q.checkbook_id = cb.id) first_leaflet_number
         , ag.agent_number
      from evt_event_object eo
         , cst_ibbl_acc_checkbook cb
         , acc_account_link l
         , acc_account a
         , prd_customer c
         , ost_agent ag
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_IBBL_PRC_CHECKBOOK_PKG.PROCESS_CHECKBOOK_ISSUANCE'
       and eo.entity_type    = cst_ibbl_api_const_pkg.ENTITY_TYPE_CHECKBOOK
       and eo.eff_date      <= com_api_sttl_day_pkg.get_sysdate
       and eo.object_id      = cb.id
       and l.entity_type     = cst_ibbl_api_const_pkg.ENTITY_TYPE_CHECKBOOK
       and l.object_id       = cb.id
       and l.is_active       = com_api_const_pkg.TRUE
       and a.id              = l.account_id
       and c.id              = a.customer_id
       and ag.id             = a.agent_id
     order by eo.id;

    l_processed_count   com_api_type_pkg.t_short_id := 0;
    l_excepted_count    com_api_type_pkg.t_short_id := 0;
    l_sess_file_id      com_api_type_pkg.t_long_id;
    l_line              com_api_type_pkg.t_text;
begin
    l_lang := nvl(i_lang, get_user_lang);
    savepoint read_events_start;

    trc_log_pkg.debug('process_checkbook_issuance Start');

    prc_api_stat_pkg.log_start;
    open cu_event_objects;
    
    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching '||BULK_LIMIT||' events'
        );
        
        fetch cu_event_objects
         bulk collect into 
              l_event_object_id_tab
            , l_checkbook_id_tab
            , l_checkbook_number_tab
            , l_checkbook_status_tab
            , l_delivery_branch_number
            , l_leaflet_count_tab
            , l_reg_date_tab
            , l_spent_date_tab
            , l_estimated_count_tab
            , l_rn_tab
            , l_account_number_tab
            , l_name_tab
            , l_leaf_number_tab
            , l_agent_number_tab
        limit BULK_LIMIT;

        if l_rn_tab(1) = 1 then
            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count_tab(1)
            );
            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_sess_file_id
            );

            prc_api_file_pkg.put_line(
                i_sess_file_id => l_sess_file_id
              , i_raw_data     => CHECKBOOK_FILE_HEADER
            );
        end if;
    
        trc_log_pkg.debug(
            i_text          => '#1 checkbooks fetched'
          , i_env_param1    => l_checkbook_id_tab.count
        );
        for i in 1..l_event_object_id_tab.count loop
            l_line := l_account_number_tab(i) || ';'                   -- acc_no
                   || to_char(l_leaflet_count_tab(i), 'TM9')  || ';'   -- leaf_count
                   || l_name_tab(i)|| ';'                              -- acc_title
                   || '   ' || ';'                                     -- col_br_code 3 spaces
                   || '  '  || ';'                                     -- trans_code 2 spaces
                   || lpad(l_delivery_branch_number(i), 9, ' ') || ';' -- routing_no
                   || '   '  || ';'                                    -- alt_system_id. 3 spaces
                   || l_checkbook_number_tab(i) || ';'                 -- alt_system_ref_id
                   || lpad(l_leaf_number_tab(i), 7, ' ') || ';'        -- first_leaf_num
                   || lpad(l_agent_number_tab(i), 9, ' ')              -- branch_code
            ;
            prc_api_file_pkg.put_line(
                i_sess_file_id => l_sess_file_id
              , i_raw_data     => l_line
            );
        end loop;
        
        forall i in l_checkbook_id_tab.first .. l_checkbook_id_tab.last
            update cst_ibbl_acc_checkbook c
               set checkbook_status = cst_ibbl_api_const_pkg.CHECKBOOK_STATUS_ACTIVE
             where id               = l_checkbook_id_tab(i);
        
        l_processed_count := nvl(l_processed_count, 0) + l_event_object_id_tab.count;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );
 
        exit when cu_event_objects%notfound;
    end loop;
    
    if l_sess_file_id is not null then
        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;
    
    prc_api_stat_pkg.log_end(
        i_processed_total => l_processed_count
      , i_excepted_total  => l_excepted_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.debug('process_checkbook_issuance End');

exception
    when others then
        rollback to savepoint read_events_start;
                
        if cu_event_objects%isopen then
            close cu_event_objects;
        end if;
        
        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
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

end cst_ibbl_prc_checkbook_pkg;
/
