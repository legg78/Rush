create or replace package body cst_ibbl_prc_statement_pkg as

FLEXIBLE_FIELD_NAME  constant  com_api_type_pkg.t_name := 'CST_IBBL_PREPAID_STATEMENT';
BULK_LIMIT           constant integer := 1000;

type t_account_rec    is record (
    account_id      com_api_type_pkg.t_account_id
  , account_number  com_api_type_pkg.t_account_number
  , inst_id         com_api_type_pkg.t_inst_id
);
type t_account_tab    is varray(1000) of t_account_rec;
l_account_tab         t_account_tab;

procedure create_prepaid_card_statements(
    i_report_id  in     com_api_type_pkg.t_short_id
  , i_lang       in     com_api_type_pkg.t_dict_value   default null
)is
    l_lang              com_api_type_pkg.t_dict_value;
    l_template_id       com_api_type_pkg.t_short_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_estimated_count   com_api_type_pkg.t_short_id := 0;
    l_processed_count   com_api_type_pkg.t_short_id := 0;
    l_excepted_count    com_api_type_pkg.t_short_id := 0;
    l_count             com_api_type_pkg.t_short_id := 0;
    l_sess_file_id      com_api_type_pkg.t_long_id;
    l_data_source       clob;
    l_source_type       com_api_type_pkg.t_dict_value;
    l_cur               sys_refcursor;
    l_report            clob;
    
    l_format_id         com_api_type_pkg.t_inst_id;
    l_name_params       com_api_type_pkg.t_param_tab;
    l_file_name         com_api_type_pkg.t_name; 
    l_is_deterministic  com_api_type_pkg.t_boolean;
    l_container_id      com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_save_path         com_api_type_pkg.t_full_desc; 
    l_document_type     com_api_type_pkg.t_dict_value;
    l_document_id       com_api_type_pkg.t_long_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
    l_eff_date          date := com_api_sttl_day_pkg.get_sysdate();
    l_datasource        clob;

    cursor cur_accounts is
    select a.id
         , a.account_number
         , a.inst_id
      from com_flexible_data fd
         , com_flexible_field ff
         , acc_account a
     where ff.id          = fd.field_id
       and ff.name        = FLEXIBLE_FIELD_NAME
       and ff.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
       and a.id           = fd.object_id
       and fd.field_value = '1';
       
begin
    savepoint read_events_start;

    trc_log_pkg.debug('create_prepaid_card_statements Start');
    trc_log_pkg.debug('i_lang='||i_lang || ' l_container_id=' || l_container_id);
    l_lang := nvl(i_lang, get_user_lang);

    prc_api_stat_pkg.log_start;

    begin
        select source_type
             , data_source
             , is_deterministic
             , document_type
          into l_source_type
             , l_data_source
             , l_is_deterministic
             , l_document_type
          from rpt_report
         where id = i_report_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'REPORT_NOT_FOUND'
              , i_env_param1 => i_report_id
            );
    end;
    trc_log_pkg.debug('Report source_type = '||l_source_type);

    select max(id)
         , count(1)
      into l_template_id
         , l_count
      from rpt_template
     where report_id = i_report_id
       and lang = l_lang;

    if l_count = 0 then
        begin
            select id
              into l_template_id
              from rpt_template
             where report_id = i_report_id
               and rownum = 1;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'REPORT_TEMPLATE_NOT_FOUND'
                  , i_env_param1 => i_report_id
                );
        end;
    end if;
    trc_log_pkg.debug('Report template = '||l_template_id);

    select count(1)
      into l_estimated_count
      from com_flexible_data fd
         , com_flexible_field ff
     where ff.id          = fd.field_id
       and ff.name        = FLEXIBLE_FIELD_NAME
       and ff.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and fd.field_value = '1';

    trc_log_pkg.debug('l_estimated_count = '||l_estimated_count);

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    begin 
        select a.name_format_id
          into l_format_id
          from prc_file_attribute a
         where a.container_id  = l_container_id;
    exception
        when no_data_found then
            null;
    end;
    
    if l_format_id is null then
        l_format_id := rpt_prc_run_pkg.get_format_name(
            i_report_id => i_report_id
        );
    end if;
    
    trc_log_pkg.debug('l_format_id = ' || l_format_id);

    open cur_accounts;
    trc_log_pkg.debug(
        i_text          => 'cursor opened'
    );

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching '||BULK_LIMIT||' accounts'
        );

        fetch cur_accounts bulk collect into l_account_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 accounts fetched'
          , i_env_param1    => l_account_tab.count
        );

        for i in 1 .. l_account_tab.count loop
            savepoint run_report_start;

            begin                                
                -- set file name params
                rul_api_param_pkg.set_param(
                    i_name    => 'EFF_DATE'
                  , i_value   => l_eff_date
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'REPORT_ID'
                  , i_value   => i_report_id  
                  , io_params => l_name_params
                );
                
                rul_api_param_pkg.set_param(
                    i_name    => 'ENTITY_TYPE'
                  , i_value   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'ACCOUNT_NUMBER'
                  , i_value   => l_account_tab(i).account_number
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'LANG'
                  , i_value   => l_lang
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'INST_ID'
                  , i_value   => l_account_tab(i).inst_id
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param (
                    i_name    => 'END_DATE'
                  , i_value   => l_eff_date
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'SYS_DATE'
                  , i_value   => l_eff_date
                  , io_params => l_name_params
                );
           
                rul_api_param_pkg.set_param (
                    i_name    => 'REPORT_DATE'
                  , i_value   => l_eff_date
                  , io_params => l_name_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'TIMESTAMP'
                  , i_value   => l_eff_date
                  , io_params => l_name_params
                );

                -- generate file name
                l_file_name := rul_api_name_pkg.get_name (
                    i_format_id  => l_format_id
                  , i_param_tab  => l_name_params
                );
                trc_log_pkg.debug('Generated l_file_name - '|| l_file_name);

                -- set report params
                trc_log_pkg.debug(
                   i_text          => 'Set report params.'
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_ENTITY_TYPE'
                  , i_value   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_OBJECT_ID'
                  , i_value   => l_account_tab(i).account_id
                  , io_params => l_params
                );

/*                rul_api_param_pkg.set_param(
                    i_name    => 'I_SPLIT_HASH'
                  , i_value   => l_event_tab(i).split_hash
                  , io_params => l_params
                );
  */
                rul_api_param_pkg.set_param(
                    i_name    => 'I_EFF_DATE'
                  , i_value   => l_eff_date
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_INST_ID'
                  , i_value   => l_account_tab(i).inst_id
                  , io_params => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name    => 'I_ACCOUNT_NUMBER'
                  , i_value   => l_account_tab(i).account_number
                  , io_params => l_params
                );

                rpt_api_run_pkg.process_report(
                    i_report_id     => i_report_id
                  , i_template_id   => l_template_id
                  , i_parameters    => l_params
                  , i_source_type   => l_source_type
                  , io_data_source  => l_data_source
                  , o_resultset     => l_cur
                  , o_xml           => l_report
                );

                trc_log_pkg.debug('process_report ok, length(datasource)='|| nvl(length(l_datasource), 0));
                  
                if instr(l_report, '<details><detail><rn></rn>') = 0   then
                    prc_api_file_pkg.open_file(
                        o_sess_file_id => l_sess_file_id
                      , i_file_name    => l_file_name
                      , i_object_id    => l_account_tab(i).account_id
                      , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
                    );
                    trc_log_pkg.debug('Open file = '||l_sess_file_id);

                    prc_api_file_pkg.put_file(
                        i_sess_file_id  => l_sess_file_id
                      , i_clob_content  => l_report
                      , i_add_to        => com_api_type_pkg.FALSE
                    );
                    trc_log_pkg.debug('put_file ok');
        
                    prc_api_file_pkg.close_file(
                        i_sess_file_id => l_sess_file_id
                      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                    );
                    trc_log_pkg.debug('Close file = ' || l_sess_file_id);
                                
                    --generate document
                    if l_is_deterministic = com_api_type_pkg.TRUE then
                    
                        select directory_path                         
                          into l_save_path 
                          from prc_file_attribute a
                             , prc_directory d 
                         where a.container_id = l_container_id
                           and a.location_id = d.id;   
                        
                        l_document_id := null;
                        l_seqnum      := null;
                          
                        rpt_api_document_pkg.add_document(
                            io_document_id          => l_document_id
                          , o_seqnum                => l_seqnum
                          , i_content_type          => rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM
                          , i_document_type         => nvl(l_document_type, rpt_api_const_pkg.DOCUMENT_TYPE_REPORT)
                          , i_entity_type           => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id             => l_account_tab(i).account_id
                          , i_report_id             => i_report_id
                          , i_template_id           => l_template_id
                          , i_file_name             => l_file_name
                          , i_mime_type             => rpt_api_const_pkg.MIME_TYPE_PDF
                          , i_save_path             => l_save_path
                          , i_document_date         => l_eff_date   
                          , i_document_number       => null --??
                          , i_inst_id               => l_account_tab(i).inst_id
                          , i_xml                   => l_report
                        ) ;                    
        
                        trc_log_pkg.debug('registered document id=[' || l_document_id || '], seqnum=['||l_seqnum||']');
                        
                    end if;
                end if;
            
                trc_log_pkg.debug('process account ' || l_account_tab(i).account_number || ' - ok');

            exception
                when others then
                    rollback to savepoint run_report_start;

                    l_excepted_count := l_excepted_count + 1;

                    if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                        raise;
                    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                        trc_log_pkg.error(
                            i_text          => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => sqlerrm
                        );
                    end if;
            end;

            l_processed_count := l_processed_count + 1;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );

        end loop;

        exit when cur_accounts%notfound;
    end loop;
    close cur_accounts;

    prc_api_stat_pkg.log_end(
        i_result_code => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.debug('create_prepaid_card_statements End');

exception
    when others then
        rollback to savepoint read_events_start;
                
        if cur_accounts%isopen then
            close   cur_accounts;
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

end cst_ibbl_prc_statement_pkg;
/
