create or replace package body cst_sat_prc_outgoing_pkg is
/*********************************************************
*  SAT custom outgoing proceses <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 07.06.2018 <br />
*  Module: CST_SAT_PRC_OUTGOING_PKG <br />
*  @headcom
**********************************************************/

BULK_LIMIT              constant integer := 400;

procedure get_list_cards_to_reissue(
    i_inst_id                       in  com_api_type_pkg.t_inst_id    default ost_api_const_pkg.DEFAULT_INST
  , i_product_id                    in  com_api_type_pkg.t_short_id   default null
  , i_expir_month                   in  date
  , i_array_card_status_excluded    in  com_api_type_pkg.t_medium_id  default cst_sat_api_const_pkg.ARRAY_ID_CSTS_REISSUE_EXCLUDE
  , i_separate_char                 in  com_api_type_pkg.t_byte_char
  , i_inherit_pin_offset            in  com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_list_cards_to_reissue: ';
    
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    
    l_ref_cursor            com_api_type_pkg.t_ref_cur;
    
    l_card_reiss_list_data  cst_sat_api_type_pkg.t_list_card_to_reiss_tab;
    l_current_month_finish  date;
    l_expir_month_finish    date;
    
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_raw_data_tab          com_api_type_pkg.t_raw_tab;
    l_rec_num_tab           com_api_type_pkg.t_integer_tab;
    l_rec_num               com_api_type_pkg.t_long_id := 0;
    
    l_array_card_status_excluded    com_api_type_pkg.t_medium_id := nvl(i_array_card_status_excluded, cst_sat_api_const_pkg.ARRAY_ID_CSTS_REISSUE_EXCLUDE);
    
    l_separate_char         com_api_type_pkg.t_byte_char := nvl(i_separate_char, cst_sat_api_const_pkg.SEPARATE_CHAR_DEFAULT);
    
    l_inherit_pin_offset    com_api_type_pkg.t_boolean := nvl(i_inherit_pin_offset, com_api_const_pkg.TRUE);
    
    l_cursor_count     com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column    com_api_type_pkg.t_text := 'select c.inst_id'
                                               ||      ', ci.agent_id'
                                               ||      ', cu.customer_number'
                                               ||      ', co.product_id'
                                               ||      ', c.id as card_id'
                                               ||      ', c.split_hash'
                                               ||      ', iss_api_token_pkg.decode_card_number('
                                               ||            'i_card_number => cn.card_number'
                                               ||          ', i_mask_error  => ' || com_api_const_pkg.TRUE
                                               ||        ') as card_number'
                                               ||      ', c.card_type_id'
                                               ||      ', ci.expir_date'
                                               ||      ', ci.pin_request'
                                               ||      ', ci.embossing_request'
                                               ||      ', ci.pin_mailer_request'
                                               ||      ', to_number('
                                               ||            'com_api_flexible_data_pkg.get_flexible_value('
                                               ||                'i_field_name  => ''' || cst_sat_api_const_pkg.FLEX_CARD_FROZEN_REISSUE || ''''
                                               ||              ', i_entity_type => ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || ''''
                                               ||              ', i_object_id   => c.id'
                                               ||            ')'
                                               ||          ', ''' || com_api_const_pkg.NUMBER_FORMAT || ''''
                                               ||        ') as card_reissue_frozen'
                                               ||      ', ' || l_inherit_pin_offset || ' as inherit_pin_offset '
    ;
    l_cursor_tbl       com_api_type_pkg.t_text := '  from ('
                                               ||         'select agent_id'
                                               ||              ', card_id'
                                               ||              ', id as card_instance_id'
                                               ||              ', expir_date'
                                               ||              ', status as card_status'
                                               ||              ', pin_request'
                                               ||              ', embossing_request'
                                               ||              ', pin_mailer_request'
                                               ||              ', row_number() over(partition by card_id order by seq_number desc) as rang '
                                               ||           'from iss_card_instance'
                                               ||        ') ci'
                                               ||      ', iss_card c'
                                               ||      ', iss_card_number cn'
                                               ||      ', prd_customer cu'
                                               ||      ', prd_contract co '
    ;
    l_cursor_where     com_api_type_pkg.t_text := 'where '
                                               ||       'ci.expir_date <= :expir_month '
                                               ||   'and ci.rang = 1 '
                                               ||   'and not exists(select 1 from com_array_element where array_id = :array_exclude_csts and element_value = ci.card_status) '
                                               ||   'and c.id = ci.card_id '
                                               ||   'and (' || ost_api_const_pkg.DEFAULT_INST || ' = :inst_id or c.inst_id = :inst_id) '
                                               ||   'and cn.card_id = c.id '
                                               ||   'and cu.id = c.customer_id '
                                               ||   'and co.id = c.contract_id '
                                               ||   'and (:product_id is null or co.product_id = :product_id) '
    ;
    l_cursor_order     com_api_type_pkg.t_full_desc := 
                                             'order by '
                                               ||  'ci.expir_date '
    ;
    l_cursor_str       com_api_type_pkg.t_sql_statement;
    
    procedure flush_file is
    begin
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'raw_tab.count='||l_raw_data_tab.count
        );
        prc_api_file_pkg.put_bulk(
            i_sess_file_id  => l_session_file_id
          , i_raw_tab       => l_raw_data_tab
          , i_num_tab       => l_rec_num_tab
        );
        l_raw_data_tab.delete;
        l_rec_num_tab.delete;
    end flush_file;

    procedure put_lines(
        i_data_tab      in  cst_sat_api_type_pkg.t_list_card_to_reiss_tab
    ) is
        l_line      com_api_type_pkg.t_raw_data;
        l_start_date    date;
        l_expir_date    date;
    begin
        if l_rec_num = 0 then
            l_line := cst_sat_api_const_pkg.CARD_TO_REISSUE_FILE_HEADER;
            l_rec_num                  := l_rec_num + 1;
            l_raw_data_tab(l_rec_num)  := l_line;
            l_rec_num_tab(l_rec_num)   := l_rec_num;
            l_processed_count          := 1;
        end if;
        
        for i in i_data_tab.first .. i_data_tab.last
        loop
            begin
                l_start_date := case
                                    when i_data_tab(i).expir_date <= l_current_month_finish
                                        then l_current_month_finish + com_api_const_pkg.ONE_SECOND
                                    when i_data_tab(i).expir_date > l_current_month_finish
                                        then i_data_tab(i).expir_date + 1
                                end;
                l_expir_date :=
                    fcl_api_cycle_pkg.calc_next_date(
                        i_cycle_type        => iss_api_const_pkg.CYCLE_EXPIRATION_DATE
                      , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                      , i_object_id         => i_data_tab(i).card_id
                      , i_split_hash        => i_data_tab(i).split_hash
                      , i_start_date        => l_start_date
                      , i_eff_date          => l_start_date
                      , i_inst_id           => i_data_tab(i).inst_id
                      , i_raise_error       => com_api_type_pkg.TRUE
                    );
                l_line := i_data_tab(i).inst_id
                       || l_separate_char || i_data_tab(i).agent_id
                       || l_separate_char || i_data_tab(i).customer_number
                       || l_separate_char || i_data_tab(i).product_id
                       || l_separate_char || i_data_tab(i).card_id
                       || l_separate_char || i_data_tab(i).card_number
                       || l_separate_char || i_data_tab(i).card_type_id
                       || l_separate_char || to_char(l_start_date, cst_sat_api_const_pkg.INTERNAL_DATE_FORMAT)
                       || l_separate_char || to_char(l_expir_date, cst_sat_api_const_pkg.INTERNAL_DATE_FORMAT)
                       || l_separate_char || i_data_tab(i).pin_request
                       || l_separate_char || i_data_tab(i).embossing_request
                       || l_separate_char || i_data_tab(i).pin_mailer_request
                       || l_separate_char || i_data_tab(i).card_reissue_frozen
                       || l_separate_char || i_data_tab(i).inherit_pin_offset
                ;
                l_rec_num                  := l_rec_num + 1;
                l_raw_data_tab(l_rec_num)  := l_line;
                l_rec_num_tab(l_rec_num)   := l_rec_num;
                trc_log_pkg.info(
                    i_text => LOG_PREFIX || 'line ' || l_rec_num || '=' || l_line
                );
            exception
                when others then
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                        trc_log_pkg.debug(
                            i_text       => LOG_PREFIX || 'Error - ' || sqlerrm || ' - on card identifier [#1]'
                          , i_env_param1 => i_data_tab(i).card_id
                        );
                        l_excepted_count := l_excepted_count + 1;
                    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                        raise;
                    else
                        com_api_error_pkg.raise_fatal_error(
                            i_error      => 'UNHANDLED_EXCEPTION'
                          , i_env_param1 => sqlerrm
                        );
                    end if;
            end;
        end loop;
        flush_file;
    end put_lines;

begin
    trc_log_pkg.debug(
        i_text         => LOG_PREFIX || 'start with params: institution [#1] product_id [#2] expiration month [#3] array card statuses excluded [#4] separate char [#5]'
      , i_env_param1   => i_inst_id
      , i_env_param2   => i_product_id
      , i_env_param3   => i_expir_month
      , i_env_param4   => l_array_card_status_excluded
      , i_env_param5   => l_separate_char
    );

    prc_api_stat_pkg.log_start;

    l_current_month_finish := last_day(trunc(com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_expir_month_finish   := last_day(trunc(i_expir_month)) + 1 - com_api_const_pkg.ONE_SECOND;
    
    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_sql_statement (1): ' || substr(l_cursor_str, 1, 3900)
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_sql_statement (2): ' || substr(l_cursor_str, 3901, 3900)
    );
    execute immediate l_cursor_str
                 into l_estimated_count
                using 
                   in l_expir_month_finish,
                   in l_array_card_status_excluded,
                   in i_inst_id,
                   in i_inst_id,
                   in i_product_id,
                   in i_product_id
    ;
    
    l_estimated_count :=
        case l_estimated_count
            when 0 
                then 0 
            else l_estimated_count + 1
        end;
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );
    
    if l_estimated_count > 0 then
        l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_where || l_cursor_order;
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_sql_statement (1): ' || substr(l_cursor_str, 1, 3900)
        );
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'l_sql_statement (2): ' || substr(l_cursor_str, 3901, 3900)
        );
         open l_ref_cursor 
          for l_cursor_str
        using l_expir_month_finish
            , l_array_card_status_excluded
            , i_inst_id
            , i_inst_id
            , i_product_id
            , i_product_id
        ;
        loop
            fetch l_ref_cursor bulk collect into l_card_reiss_list_data
                limit BULK_LIMIT;
                
            if l_session_file_id is null then
                prc_api_file_pkg.open_file(o_sess_file_id  => l_session_file_id);
                trc_log_pkg.debug('l_session_file_id=' || l_session_file_id);
            end if;

            put_lines(
                i_data_tab => l_card_reiss_list_data
            );

            l_processed_count := l_processed_count + l_card_reiss_list_data.count;
                
            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count - l_excepted_count
              , i_excepted_count => l_excepted_count
            );
            exit when l_ref_cursor%notfound;
        end loop;
        close l_ref_cursor;
    end if;
    
    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'FINISH'
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total  => l_excepted_count
      , i_processed_total => l_processed_count - l_excepted_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_excepted_total  => l_estimated_count - l_processed_count
          , i_processed_total => l_processed_count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED 
        );
        
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end get_list_cards_to_reissue;

end cst_sat_prc_outgoing_pkg;
/
