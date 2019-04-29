create or replace package body cst_sat_prc_incoming_pkg as
/*********************************************************
*  SAT custom incoming proceses <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 08.06.2018 <br />
*  Module: CST_SAT_PRC_INCOMING_PKG <br />
*  @headcom
**********************************************************/
g_count_separators  binary_integer;

procedure process_record(
    i_rec                  in com_api_type_pkg.t_text
  , i_separate_char        in com_api_type_pkg.t_byte_char
  , i_row_number           in com_api_type_pkg.t_count
  , i_incom_sess_file_id   in com_api_type_pkg.t_long_id
  , o_processed           out com_api_type_pkg.t_sign
  , o_excepted            out com_api_type_pkg.t_sign
)
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_record: ';
    
    l_card_reissue_rec   cst_sat_api_type_pkg.t_card_reissue_fields_rec;
    
    l_pos_begin          com_api_type_pkg.t_tiny_id;
    l_length             com_api_type_pkg.t_tiny_id;
    l_count_fields       binary_integer := g_count_separators + 1;
    
    l_seq_number         com_api_type_pkg.t_tiny_id;
    l_card_number        com_api_type_pkg.t_card_number;
    
    l_card_reissue_frozen com_api_type_pkg.t_sign;
begin
    
    for i in 1 .. l_count_fields
    loop
        l_pos_begin := case
                           when i = 1 
                               then 0
                           else instr(i_rec, i_separate_char, 1, i-1)
                       end + 1;
        l_length    := case
                           when i <= g_count_separators
                               then instr(i_rec, i_separate_char, 1, i) - l_pos_begin
                           else length(i_rec) - l_pos_begin + 1
                       end;
        case i
            when 1 then  l_card_reissue_rec.inst_id             := to_number(substr(i_rec, l_pos_begin, l_length));
            when 2 then  l_card_reissue_rec.agent_id            := to_number(substr(i_rec, l_pos_begin, l_length));
            when 3 then  l_card_reissue_rec.customer_number     := substr(i_rec, l_pos_begin, l_length);
            when 4 then  l_card_reissue_rec.product_id          := to_number(substr(i_rec, l_pos_begin, l_length));
            when 5 then  l_card_reissue_rec.card_id             := to_number(substr(i_rec, l_pos_begin, l_length));
            when 6 then  l_card_reissue_rec.card_number         := substr(i_rec, l_pos_begin, l_length);
            when 7 then  l_card_reissue_rec.card_type_id        := to_number(substr(i_rec, l_pos_begin, l_length));
            when 8 then  l_card_reissue_rec.start_date          := to_date(substr(i_rec, l_pos_begin, l_length), cst_sat_api_const_pkg.INTERNAL_DATE_FORMAT);
            when 9 then  l_card_reissue_rec.expir_date          := to_date(substr(i_rec, l_pos_begin, l_length), cst_sat_api_const_pkg.INTERNAL_DATE_FORMAT);
            when 10 then l_card_reissue_rec.pin_request         := substr(i_rec, l_pos_begin, l_length);
            when 11 then l_card_reissue_rec.embossing_request   := substr(i_rec, l_pos_begin, l_length);
            when 12 then l_card_reissue_rec.pin_mailer_request  := substr(i_rec, l_pos_begin, l_length);
            when 13 then l_card_reissue_rec.card_reissue_frozen := to_number(substr(i_rec, l_pos_begin, l_length));
            when 14 then l_card_reissue_rec.inherit_pin_offset  := to_number(substr(i_rec, l_pos_begin, l_length));
        end case;
        
    end loop;
    
    l_card_reissue_frozen := 
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name  => cst_sat_api_const_pkg.FLEX_CARD_FROZEN_REISSUE
          , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id   => l_card_reissue_rec.card_id
        );
        
    if l_card_reissue_frozen <> l_card_reissue_rec.card_reissue_frozen then
        com_api_flexible_data_pkg.set_flexible_value(
            i_field_name  => cst_sat_api_const_pkg.FLEX_CARD_FROZEN_REISSUE
          , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id   => l_card_reissue_rec.card_id
          , i_field_value => l_card_reissue_rec.card_reissue_frozen
        );
    end if;
        
    if l_card_reissue_rec.card_reissue_frozen = com_api_const_pkg.FALSE then
        
        if l_card_reissue_rec.inherit_pin_offset = com_api_const_pkg.TRUE then
            l_card_reissue_rec.pin_request        := iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE;
            l_card_reissue_rec.pin_mailer_request := iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT;
        end if;
        
        l_card_reissue_rec.embossing_request := iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS;
        
        iss_api_card_pkg.reissue(
            i_card_number        => l_card_reissue_rec.card_number
          , io_seq_number        => l_seq_number
          , io_card_number       => l_card_number
          , i_agent_id           => l_card_reissue_rec.agent_id
          , i_card_type_id       => l_card_reissue_rec.card_type_id
          , i_start_date         => l_card_reissue_rec.start_date
          , io_expir_date        => l_card_reissue_rec.expir_date
          , i_pin_request        => l_card_reissue_rec.pin_request
          , i_pin_mailer_request => l_card_reissue_rec.pin_mailer_request
          , i_embossing_request  => l_card_reissue_rec.embossing_request
          , i_inherit_pin_offset => l_card_reissue_rec.inherit_pin_offset
        );
    end if;
    o_excepted  := 0;
    o_processed := 1;
    
exception
    when others then
        o_excepted  := 1;
        o_processed := 0;
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'Error - ' || sqlerrm || ' - on sess_file_id [#3] row_number [#1] for rec[#2]'
              , i_env_param1 => i_row_number
              , i_env_param2 => i_rec
              , i_env_param3 => i_incom_sess_file_id
            );
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_record;

procedure process_reissue_card_list(
    i_separate_char     in  com_api_type_pkg.t_byte_char
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_reissue_card_list: ';
    
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_excepted_count              com_api_type_pkg.t_long_id := 0;
    l_rec                         com_api_type_pkg.t_text;
    l_separate_char               com_api_type_pkg.t_byte_char := nvl(i_separate_char, cst_sat_api_const_pkg.SEPARATE_CHAR_DEFAULT);
    l_processed                   com_api_type_pkg.t_sign;
    l_excepted                    com_api_type_pkg.t_sign;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count_all_files;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );

    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) 
    loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id 
                   || '], record_count [' || p.record_count 
                   || '], file_name [' || p.file_name || ']'
        );
        
        begin
            
            for r in (
                select record_number
                     , raw_data
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            loop
                l_record_number := r.record_number;
                l_rec := r.raw_data;
                if r.rn = 1
                    and r.raw_data = 
                            replace(
                                cst_sat_api_const_pkg.CARD_TO_REISSUE_FILE_HEADER
                              , cst_sat_api_const_pkg.SEPARATE_CHAR_DEFAULT
                              , l_separate_char
                            )
                then
                    l_processed_count := l_processed_count + 1;
                elsif r.rn > 1 then
                    
                    process_record(
                        i_rec                => r.raw_data
                      , i_separate_char      => l_separate_char
                      , i_row_number         => r.rn
                      , i_incom_sess_file_id => p.session_file_id
                      , o_processed          => l_processed
                      , o_excepted           => l_excepted
                    );
                    
                    l_processed_count := l_processed_count + l_processed;
                    l_excepted_count  := l_excepted_count + l_excepted;
                    
                    if mod(r.rn, 100) = 0 then
                        prc_api_stat_pkg.log_current(
                            i_current_count  => l_record_count + r.rn
                          , i_excepted_count => 0
                        );
                    end if;
                    
                    if r.rn_desc = 1 then
                        l_record_count := l_record_count + r.cnt;
                        prc_api_stat_pkg.log_current(
                            i_current_count  => l_record_count
                          , i_excepted_count => 0
                        );
                    end if;
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'ERROR_ON_READING_FILE'
                      , i_env_param1 => l_record_number
                      , i_env_param2 => p.file_name
                    );
                end if;
            end loop;
            
            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then

                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => 0
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => l_excepted_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_record_number [#1] l_rec [#2]' 
              , i_env_param1 => l_record_number
              , i_env_param2 => l_rec
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_reissue_card_list;

begin
    g_count_separators := length(cst_sat_api_const_pkg.CARD_TO_REISSUE_FILE_HEADER)
                        - length(
                              replace(
                                  cst_sat_api_const_pkg.CARD_TO_REISSUE_FILE_HEADER
                                , cst_sat_api_const_pkg.SEPARATE_CHAR_DEFAULT
                                , ''
                              )
                          );
end cst_sat_prc_incoming_pkg;
/
