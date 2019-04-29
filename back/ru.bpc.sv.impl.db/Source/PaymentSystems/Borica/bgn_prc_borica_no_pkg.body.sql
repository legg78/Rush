create or replace package body bgn_prc_borica_no_pkg as

    NO_MARKER_VISA              constant    com_api_type_pkg.t_dict_value := 'I. ';
    NO_MARKER_DOMESTIC          constant    com_api_type_pkg.t_dict_value := 'II. ';
    NO_MARKER_MASTERCARD        constant    com_api_type_pkg.t_dict_value := 'III. ';
    
    NO_MARKER_TOTAL             constant    com_api_type_pkg.t_dict_value := 'TTT  ';
    
    NO_HEADER_START             constant    com_api_type_pkg.t_short_id   := 3;
    NO_HEADER_END               constant    com_api_type_pkg.t_short_id   := 8;

type no_fin_rec is record (
    id                  com_api_type_pkg.t_long_id
  , file_id             com_api_type_pkg.t_long_id  
  , code                com_api_type_pkg.t_dict_value
  , card_marker         com_api_type_pkg.t_dict_value                     
  , product_name        com_api_type_pkg.t_name  
  , oper_name           com_api_type_pkg.t_name
  , seq_number          com_api_type_pkg.t_tiny_id
  , ird                 com_api_type_pkg.t_name   
  , debit_count         com_api_type_pkg.t_medium_id
  , debit_trans         com_api_type_pkg.t_money  
  , debit_tax           com_api_type_pkg.t_money
  , debit_total         com_api_type_pkg.t_money
  , credit_count        com_api_type_pkg.t_medium_id
  , credit_trans        com_api_type_pkg.t_money  
  , credit_tax          com_api_type_pkg.t_money
  , credit_total        com_api_type_pkg.t_money
  , is_incoming         com_api_type_pkg.t_boolean
  , status              com_api_type_pkg.t_dict_value
  , match_id            com_api_type_pkg.t_long_id
);

type no_file_rec is record  (
    id                  com_api_type_pkg.t_long_id
  , bank_name           com_api_type_pkg.t_name 
  , sttl_acc_number     com_api_type_pkg.t_account_number
  , sttl_date           date
  , sttl_ref            com_api_type_pkg.t_name 
  , swift_msg_number    com_api_type_pkg.t_name 
  , sttl_currency       com_api_type_pkg.t_curr_code
  , ttt_debit_count     com_api_type_pkg.t_medium_id
  , ttt_debit_trans     com_api_type_pkg.t_money
  , ttt_debit_tax       com_api_type_pkg.t_money
  , ttt_debit_total     com_api_type_pkg.t_money
  , ttt_credit_count    com_api_type_pkg.t_medium_id
  , ttt_credit_trans    com_api_type_pkg.t_money
  , ttt_credit_tax      com_api_type_pkg.t_money
  , ttt_credit_total    com_api_type_pkg.t_money
  , total_amount        com_api_type_pkg.t_money
  , is_incoming         com_api_type_pkg.t_boolean
);

type t_no_fin_tab   is table of no_fin_rec index by binary_integer;
    
    g_session_file_id                       com_api_type_pkg.t_long_id;
    g_record_number                         com_api_type_pkg.t_short_id;
    
    g_curr_group                            com_api_type_pkg.t_name;
    g_is_prev_significant                   com_api_type_pkg.t_boolean;
    g_finish                                com_api_type_pkg.t_boolean;
    
    g_file_rec                              no_file_rec;
    g_fin_rec                               no_fin_rec;

procedure get_summs(
    i_data_string           in  com_api_type_pkg.t_name
  , o_debit_count           out com_api_type_pkg.t_medium_id
  , o_debit_trans           out com_api_type_pkg.t_money  
  , o_debit_tax             out com_api_type_pkg.t_money
  , o_debit_total           out com_api_type_pkg.t_money
  , o_credit_count          out com_api_type_pkg.t_medium_id
  , o_credit_trans          out com_api_type_pkg.t_money  
  , o_credit_tax            out com_api_type_pkg.t_money
  , o_credit_total          out com_api_type_pkg.t_money
) is 
begin
    o_debit_count   := trim(substr(i_data_string, 73, 10));
    o_debit_trans   := replace(trim(substr(i_data_string, 87, 12)), '.');
    o_debit_tax     := replace(trim(substr(i_data_string, 103, 12)), '.');
    o_debit_total   := replace(trim(substr(i_data_string, 119, 15)), '.');
    
    o_credit_count  := trim(substr(i_data_string, 142, 10));
    o_credit_trans  := replace(trim(substr(i_data_string, 156, 12)), '.');
    o_credit_tax    := replace(trim(substr(i_data_string, 172, 12)), '.');
    o_credit_total  := replace(trim(substr(i_data_string, 188, 15)), '.');
    
end;

function is_delimiter(
    i_data_string           in  com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean is
    l_res           com_api_type_pkg.t_boolean;
begin
    if substr(i_data_string, 73, 10) in (
        '----------'
      , '=========='  
    ) then
        l_res   := com_api_const_pkg.TRUE;
        
    else
        l_res   := com_api_const_pkg.FALSE;
    
    end if;    
        
    return l_res;
    
end;

procedure process_file_header(
    io_data             in out nocopy   com_api_type_pkg.t_raw_data
) is
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_borica_no_pkg.process_file_header'
    );
    
    case g_record_number
    when 3 then
        g_file_rec.bank_name        := substr(io_data, 34, 169);
    when 4 then
        g_file_rec.sttl_acc_number  := substr(io_data, 34, 22);    
    when 5 then
        g_file_rec.sttl_date        := to_date(substr(io_data, 34, 10), 'dd/mm/yyyy');
    when 6 then
        g_file_rec.sttl_ref         := substr(io_data, 34, 16);
    when 7 then
        g_file_rec.swift_msg_number := substr(io_data, 34, 10);
    when 8 then
        begin
            select code
              into g_file_rec.sttl_currency
              from com_currency
             where name = upper(substr(io_data, 34, 3));
             
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'CURRENCY_NOT_DEFINED'
                );      
        end;
    else
        null;    
    end case;
    
    g_file_rec.is_incoming  := com_api_const_pkg.TRUE;
     
end;

procedure process_file_trailer(
    io_data             in out nocopy   com_api_type_pkg.t_raw_data
) is
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_borica_no_pkg.process_file_trailer'
    );
    
    get_summs(
        i_data_string   => io_data
      , o_debit_count   => g_file_rec.ttt_debit_count
      , o_debit_trans   => g_file_rec.ttt_debit_trans  
      , o_debit_tax     => g_file_rec.ttt_debit_tax
      , o_debit_total   => g_file_rec.ttt_debit_total
      , o_credit_count  => g_file_rec.ttt_credit_count
      , o_credit_trans  => g_file_rec.ttt_credit_trans  
      , o_credit_tax    => g_file_rec.ttt_credit_tax
      , o_credit_total  => g_file_rec.ttt_credit_total
    );
    
    g_finish    := com_api_const_pkg.TRUE;
end;

procedure put_file_rec(
    i_file_rec          in no_file_rec
) is 
    l_id            com_api_type_pkg.t_long_id;
begin
    l_id    := nvl(i_file_rec.id, g_session_file_id);
    insert into bgn_no_file (
        id              
      , bank_name       
      , sttl_acc_number 
      , sttl_date       
      , sttl_ref        
      , swift_msg_number
      , sttl_currency   
      , ttt_debit_count 
      , ttt_debit_trans 
      , ttt_debit_tax   
      , ttt_debit_total 
      , ttt_credit_count
      , ttt_credit_trans
      , ttt_credit_tax  
      , ttt_credit_total
      , total_amount    
      , is_incoming
    ) values (
        l_id              
      , i_file_rec.bank_name       
      , i_file_rec.sttl_acc_number 
      , i_file_rec.sttl_date       
      , i_file_rec.sttl_ref        
      , i_file_rec.swift_msg_number
      , i_file_rec.sttl_currency   
      , i_file_rec.ttt_debit_count 
      , i_file_rec.ttt_debit_trans 
      , i_file_rec.ttt_debit_tax   
      , i_file_rec.ttt_debit_total 
      , i_file_rec.ttt_credit_count
      , i_file_rec.ttt_credit_trans
      , i_file_rec.ttt_credit_tax  
      , i_file_rec.ttt_credit_total
      , i_file_rec.total_amount   
      , i_file_rec.is_incoming 
    );
    
end;

procedure put_fin_rec(
    i_fin_rec       in no_fin_rec
) is
    l_id            com_api_type_pkg.t_long_id;
    l_file_id       com_api_type_pkg.t_long_id;
begin
    l_id        := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);
    l_file_id   := nvl(i_fin_rec.file_id, g_session_file_id);
    insert into bgn_no_fin (
        id          
      , file_id     
      , code        
      , card_marker 
      , product_name
      , oper_name   
      , seq_number  
      , ird         
      , debit_count 
      , debit_trans 
      , debit_tax   
      , debit_total 
      , credit_count
      , credit_trans
      , credit_tax  
      , credit_total
      , is_incoming
      , status
      , match_id
    ) values (
        l_id          
      , l_file_id     
      , i_fin_rec.code        
      , i_fin_rec.card_marker 
      , i_fin_rec.product_name
      , i_fin_rec.oper_name   
      , i_fin_rec.seq_number  
      , i_fin_rec.ird         
      , i_fin_rec.debit_count 
      , i_fin_rec.debit_trans 
      , i_fin_rec.debit_tax   
      , i_fin_rec.debit_total 
      , i_fin_rec.credit_count
      , i_fin_rec.credit_trans
      , i_fin_rec.credit_tax  
      , i_fin_rec.credit_total
      , i_fin_rec.is_incoming
      , i_fin_rec.status
      , i_fin_rec.match_id
    );
    
end;

procedure process_string(
    io_data             in out nocopy   com_api_type_pkg.t_raw_data
) is 
    l_first_5               com_api_type_pkg.t_name;
    
    REGEXP_DIGITS           constant    com_api_type_pkg.t_name := '\d\.((\d\.\s)|(\d{2}\.)|\s{3})$';
    REGEXP_TOTALS           constant    com_api_type_pkg.t_name := '\DT(\d|T)\s.';
    
    procedure reset_fin is
    begin
        g_fin_rec               := null;
        g_fin_rec.is_incoming   := com_api_const_pkg.TRUE;
        g_fin_rec.status        := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    end;
    
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_borica_no_pkg.process_string'
    );
    
    if g_record_number between NO_HEADER_START and NO_HEADER_END then
        process_file_header (
            io_data     => io_data
        );
        
    else
        l_first_5 := substr(io_data, 1, 5);

        if regexp_like(l_first_5, REGEXP_TOTALS) and length(io_data) = 202 then
            reset_fin;
            get_summs(
                i_data_string   => io_data
              , o_debit_count   => g_fin_rec.debit_count
              , o_debit_trans   => g_fin_rec.debit_trans  
              , o_debit_tax     => g_fin_rec.debit_tax
              , o_debit_total   => g_fin_rec.debit_total
              , o_credit_count  => g_fin_rec.credit_count
              , o_credit_trans  => g_fin_rec.credit_trans  
              , o_credit_tax    => g_fin_rec.credit_tax
              , o_credit_total  => g_fin_rec.credit_total
            );
            
            g_fin_rec.card_marker   := g_curr_group;
            g_fin_rec.code          := trim(l_first_5);
            g_fin_rec.oper_name     := trim(substr(io_data, 6, 65));
            g_fin_rec.seq_number    := 0;
            
            put_fin_rec(
                i_fin_rec          => g_fin_rec
            );
            
        end if;
        
        if g_curr_group is null then
            if substr(io_data, 1, 3) = NO_MARKER_VISA then
                g_curr_group := NO_MARKER_VISA;
                g_is_prev_significant := com_api_const_pkg.FALSE;
                
            end if;
            
        elsif g_curr_group = NO_MARKER_VISA then
            g_fin_rec.card_marker   := g_curr_group;
             
            if substr(io_data, 1, 4) = NO_MARKER_DOMESTIC then
                g_curr_group := NO_MARKER_DOMESTIC;
                g_is_prev_significant := com_api_const_pkg.FALSE;
            
            else
                if regexp_like(l_first_5, REGEXP_DIGITS) and length(io_data) = 202 then
                    get_summs(
                        i_data_string   => io_data
                      , o_debit_count   => g_fin_rec.debit_count
                      , o_debit_trans   => g_fin_rec.debit_trans  
                      , o_debit_tax     => g_fin_rec.debit_tax
                      , o_debit_total   => g_fin_rec.debit_total
                      , o_credit_count  => g_fin_rec.credit_count
                      , o_credit_trans  => g_fin_rec.credit_trans  
                      , o_credit_tax    => g_fin_rec.credit_tax
                      , o_credit_total  => g_fin_rec.credit_total
                    );
                    g_is_prev_significant   := com_api_const_pkg.TRUE;
                    
                    g_fin_rec.code          := trim(l_first_5);
                    g_fin_rec.seq_number    := 1;
                    g_fin_rec.oper_name     := trim(substr(io_data, 6, 67));
                    
                    put_fin_rec(
                        i_fin_rec          => g_fin_rec
                    );
                    
                elsif l_first_5 = '     ' 
                  and length(io_data) = 202
                  and g_is_prev_significant = com_api_const_pkg.TRUE
                  and is_delimiter(io_data) = com_api_const_pkg.FALSE
                  then
                    get_summs(
                        i_data_string   => io_data
                      , o_debit_count   => g_fin_rec.debit_count
                      , o_debit_trans   => g_fin_rec.debit_trans  
                      , o_debit_tax     => g_fin_rec.debit_tax
                      , o_debit_total   => g_fin_rec.debit_total
                      , o_credit_count  => g_fin_rec.credit_count
                      , o_credit_trans  => g_fin_rec.credit_trans  
                      , o_credit_tax    => g_fin_rec.credit_tax
                      , o_credit_total  => g_fin_rec.credit_total
                    );
                    g_fin_rec.seq_number    := g_fin_rec.seq_number + 1;
                    g_fin_rec.oper_name     := trim(substr(io_data, 6, 67));
                    put_fin_rec(
                        i_fin_rec          => g_fin_rec
                    );
  
                else 
                    g_is_prev_significant   := com_api_const_pkg.FALSE;
                     
                end if;
                    
            end if;
               
        elsif g_curr_group = NO_MARKER_DOMESTIC then
            g_fin_rec.card_marker   := g_curr_group;
             
            if substr(io_data, 1, 5) = NO_MARKER_MASTERCARD then
                g_curr_group := NO_MARKER_MASTERCARD;
                g_is_prev_significant := com_api_const_pkg.FALSE;
            
            else
                if regexp_like(l_first_5, REGEXP_DIGITS) and length(io_data) = 202 then
                    get_summs(
                        i_data_string   => io_data
                      , o_debit_count   => g_fin_rec.debit_count
                      , o_debit_trans   => g_fin_rec.debit_trans  
                      , o_debit_tax     => g_fin_rec.debit_tax
                      , o_debit_total   => g_fin_rec.debit_total
                      , o_credit_count  => g_fin_rec.credit_count
                      , o_credit_trans  => g_fin_rec.credit_trans  
                      , o_credit_tax    => g_fin_rec.credit_tax
                      , o_credit_total  => g_fin_rec.credit_total
                    );
                    g_is_prev_significant   := com_api_const_pkg.TRUE;
                    g_fin_rec.code          := trim(l_first_5);
                    g_fin_rec.seq_number    := 1;
                    g_fin_rec.oper_name     := trim(substr(io_data, 6, 67));
                    
                    put_fin_rec(
                        i_fin_rec          => g_fin_rec
                    );
                    
                elsif l_first_5 = '     ' 
                  and length(io_data) = 202
                  and g_is_prev_significant = com_api_const_pkg.TRUE
                  and is_delimiter(io_data) = com_api_const_pkg.FALSE
                  then
                    get_summs(
                        i_data_string   => io_data
                      , o_debit_count   => g_fin_rec.debit_count
                      , o_debit_trans   => g_fin_rec.debit_trans  
                      , o_debit_tax     => g_fin_rec.debit_tax
                      , o_debit_total   => g_fin_rec.debit_total
                      , o_credit_count  => g_fin_rec.credit_count
                      , o_credit_trans  => g_fin_rec.credit_trans  
                      , o_credit_tax    => g_fin_rec.credit_tax
                      , o_credit_total  => g_fin_rec.credit_total
                    );
                    g_fin_rec.seq_number   := g_fin_rec.seq_number + 1;
                    g_fin_rec.oper_name    := trim(substr(io_data, 6, 67));
                    
                    put_fin_rec(
                        i_fin_rec          => g_fin_rec
                    );
                     
                else 
                    g_is_prev_significant   := com_api_const_pkg.FALSE;
                    reset_fin;
                        
                end if;
                    
            end if;
            
        elsif g_curr_group = NO_MARKER_MASTERCARD then 
            g_fin_rec.card_marker   := g_curr_group;
            
            if substr(io_data, 1, 5) = NO_MARKER_TOTAL then
                g_curr_group            := NO_MARKER_TOTAL;
                g_is_prev_significant   := com_api_const_pkg.FALSE;
                
                process_file_trailer(
                    io_data         => io_data 
                );
                
                g_file_rec.is_incoming  := com_api_const_pkg.TRUE;
                
                put_file_rec(
                    i_file_rec      => g_file_rec
                );
            
            else
                if   regexp_like(l_first_5, REGEXP_DIGITS) 
                 and length(io_data) < 202 
                 and g_is_prev_significant = com_api_const_pkg.FALSE 
                 then
                    g_is_prev_significant   := com_api_const_pkg.TRUE;
                    g_fin_rec.code := trim(l_first_5);
                 
                elsif l_first_5 = '     '
                  and g_is_prev_significant = com_api_const_pkg.TRUE
                  and length(io_data) = 202
                  and is_delimiter(io_data) = com_api_const_pkg.FALSE
                  then    
                    g_fin_rec.product_name  := trim(substr(io_data, 6, 34));
                    g_fin_rec.oper_name     := trim(substr(io_data, 40, 23));
                    g_fin_rec.ird           := trim(substr(io_data, 63, 10));
                    get_summs(
                        i_data_string   => io_data
                      , o_debit_count   => g_fin_rec.debit_count
                      , o_debit_trans   => g_fin_rec.debit_trans  
                      , o_debit_tax     => g_fin_rec.debit_tax
                      , o_debit_total   => g_fin_rec.debit_total
                      , o_credit_count  => g_fin_rec.credit_count
                      , o_credit_trans  => g_fin_rec.credit_trans  
                      , o_credit_tax    => g_fin_rec.credit_tax
                      , o_credit_total  => g_fin_rec.credit_total
                    );
                    put_fin_rec(
                        i_fin_rec          => g_fin_rec
                    );
                    
                else
                    g_is_prev_significant   := com_api_const_pkg.FALSE;
                    reset_fin;
                    
                end if; 
                    
            end if;    
        
        elsif g_curr_group = NO_MARKER_TOTAL and length(trim(io_data)) > 0 then
            g_file_rec.total_amount     := replace(trim(substr(io_data, 40, 15)), '.');
            
            if length(trim(substr(io_data, 24, 6))) = 5 then
                --debit
                g_file_rec.total_amount := -g_file_rec.total_amount;
            end if;
                 
        end if;
            
    end if;
        
end;

procedure process
is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    
    cursor cur_no_records is
        select raw_data
             , record_number
          from prc_file_raw_data rd
         where rd.session_file_id = g_session_file_id
         order by record_number;
         
    l_string_tab            com_api_type_pkg.t_desc_tab;
    l_record_number_tab     com_api_type_pkg.t_short_tab;
    l_string_limit          com_api_type_pkg.t_short_id := 450; 
           
begin
    savepoint read_no_start;
    
    trc_log_pkg.info(
        i_text          => 'Read NO file'
    );
    
    select count(1)
      into l_estimated_count
      from prc_file_raw_data rd
         , prc_session_file sf
         , prc_file_attribute a
         , prc_file f
     where sf.session_id = get_session_id
       and rd.session_file_id = sf.id
       and sf.file_attr_id = a.id
       and f.id = a.file_id
       and f.file_type = bgn_api_const_pkg.FILE_TYPE_BORICA_NO;  
  
    prc_api_stat_pkg.log_start;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    
    for no_file in (
        select s.id
             , s.file_name 
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = bgn_api_const_pkg.FILE_TYPE_BORICA_NO    
    ) loop
        trc_log_pkg.info(
            i_text          => 'Start process file [#1]'
          , i_env_param1    => no_file.file_name  
        );
        
        g_session_file_id       := no_file.id;
        g_curr_group            := null;
        g_is_prev_significant   := com_api_const_pkg.FALSE;
        g_finish                := com_api_const_pkg.FALSE;
        g_file_rec              := null;
        
        open cur_no_records;
        loop
            fetch cur_no_records bulk collect into l_string_tab, l_record_number_tab limit l_string_limit;
            trc_log_pkg.info(
                i_text          => '#1 records fetched'
              , i_env_param1    => l_string_tab.count
            );
            
            for i in 1 .. l_string_tab.count loop
                savepoint process_string_start;
                
                begin
                    l_processed_count := l_processed_count + 1;
                    
                    g_record_number := l_record_number_tab(i);
                    process_string(
                        io_data     => l_string_tab(i)
                    );
    
                exception
                    when others then
                        rollback to savepoint process_string_start;
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;

                        else
                            close   cur_no_records;
                            raise;

                        end if;    
                end;
                
                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current (
                        i_current_count     => l_processed_count
                      , i_excepted_count    => l_excepted_count
                    );
                end if;
                
                exit when g_finish = com_api_type_pkg.TRUE;
                
            end loop;
            
            exit when cur_no_records%notfound or g_finish = com_api_type_pkg.TRUE;
        end loop;

        close cur_no_records;
    end loop;
    
    l_processed_count   := l_estimated_count;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS  
    );
    
exception
     when others then
        rollback to savepoint read_no_start;
        if cur_no_records%isopen then
            close   cur_no_records;

        end if;

        prc_api_stat_pkg.log_end (
            i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count 
          , i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
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
    
end process;

function make_export_string(
    i_fin_rec           in no_fin_rec
) return com_api_type_pkg.t_raw_data is
    l_res           com_api_type_pkg.t_raw_data;
    l_file_name     com_api_type_pkg.t_name;
begin
    select file_name
      into l_file_name
      from prc_session_file f
         , bgn_no_fin n
     where f.id = n.file_id
       and n.id = i_fin_rec.match_id;
     
    l_res   := com_api_type_pkg.pad_char(i_fin_rec.code, 3, 3)
            || '   '
            || com_api_type_pkg.pad_char(i_fin_rec.oper_name, 65, 65)
            || com_api_type_pkg.pad_char(l_file_name, 8, 8)
            || com_api_type_pkg.pad_number(
                i_fin_rec.debit_trans
                , 15, 15
               )
            || com_api_type_pkg.pad_number(
                i_fin_rec.debit_tax
                , 15, 15
               )   
            || com_api_type_pkg.pad_number(
                i_fin_rec.credit_trans
                , 15, 15
               )
            || com_api_type_pkg.pad_number(
                i_fin_rec.credit_tax
                , 15, 15
               );
               
    return l_res;
    
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'BGN_SESSION_FILE_INCOMING_NO_NOT_FOUND'
          , i_env_param1    => i_fin_rec.file_id
        );
end;

procedure process_export(
    i_inst_id       com_api_type_pkg.t_inst_id
)
is
    l_fin_tab                   t_no_fin_tab;
    
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    
    BULK_LIMIT      constant    com_api_type_pkg.t_tiny_id  := 400;
    
    l_session_file_id           com_api_type_pkg.t_long_id; 
    
    l_params                    com_api_type_pkg.t_param_tab;
    l_rec_raw                   com_api_type_pkg.t_raw_tab;
    l_rec_num                   com_api_type_pkg.t_integer_tab;
    
    cursor cur_no_fin is
        select  id          
              , file_id     
              , code        
              , card_marker 
              , product_name
              , oper_name   
              , seq_number  
              , ird         
              , debit_count 
              , debit_trans 
              , debit_tax   
              , debit_total 
              , credit_count
              , credit_trans
              , credit_tax  
              , credit_total
              , is_incoming 
              , status  
              , match_id
           from bgn_no_fin rd
          where status = net_api_const_pkg.CLEARING_MSG_STATUS_READY 
            and is_incoming = com_api_const_pkg.FALSE;
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_borica_no_pkg.process_export'
    );
    savepoint no_export_start;
    
    prc_api_stat_pkg.log_start;
    
    select count(1)
      into l_estimated_count
      from bgn_no_fin
     where status = net_api_const_pkg.CLEARING_MSG_STATUS_READY 
       and is_incoming = com_api_const_pkg.FALSE;
       
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    
    if l_estimated_count > 0 then
        l_params    := evt_api_shared_data_pkg.g_params;
        
        rul_api_param_pkg.set_param(
            i_name      => 'INST_ID'
          , i_value     => i_inst_id
          , io_params   => l_params
        );
        
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
          , io_params       => l_params
          , i_file_type     => bgn_api_const_pkg.FILE_TYPE_BORICA_NI
        );
        
        open cur_no_fin;
        
        loop
            fetch cur_no_fin 
            bulk collect into l_fin_tab     
              limit BULK_LIMIT;
              
           
            for i in 1 .. l_fin_tab.count loop
                l_rec_num(l_rec_num.count + 1)  := l_processed_count + 1;
                l_rec_raw(l_rec_raw.count + 1)  := make_export_string(i_fin_rec => l_fin_tab(i));
                
                l_processed_count   := l_processed_count + 1;             
            end loop;
            
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
              , i_excepted_count    => 0
            );
            
            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_session_file_id
              , i_raw_tab       => l_rec_raw
              , i_num_tab       => l_rec_num
            );
            
            forall i in 1 .. l_fin_tab.count
                update bgn_no_fin
                   set status   = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED 
                     , file_id  = l_session_file_id
                 where id = l_fin_tab(i).id;    

            l_rec_raw.delete;
            l_rec_num.delete;
            
            exit when cur_no_fin%notfound;
            
        end loop;
        
        close cur_no_fin;
        
        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

    end if;
    
    prc_api_stat_pkg.log_end (
        i_processed_total  => l_processed_count
        , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_borica_no_pkg.process_export finished'
    );   

exception
    when others then
        rollback to no_export_start;
        
        if cur_no_fin%isopen then
            close cur_no_fin;
        end if;
        
        trc_log_pkg.error(sqlerrm);
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

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

procedure process_answer
is
    REGEXP_TOTALS           constant    com_api_type_pkg.t_name := '\DT.';
    l_fin_tab                   t_no_fin_tab;
    
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    
    BULK_LIMIT      constant    com_api_type_pkg.t_tiny_id  := 400;
    
    cursor cur_no_totals is
        select  opr_api_create_pkg.get_id         
              , file_id     
              , code        
              , card_marker 
              , product_name
              , oper_name   
              , seq_number  
              , ird         
              , debit_count 
              , debit_trans 
              , debit_tax   
              , debit_total 
              , credit_count
              , credit_trans
              , credit_tax  
              , credit_total
              , is_incoming 
              , status
              , id  
           from bgn_no_fin rd
          where status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
            and is_incoming = com_api_const_pkg.TRUE
            and regexp_like(code, REGEXP_TOTALS)
          for update;
          
    
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_borica_no_pkg.process_answer'
    );
    
    savepoint no_answer_start;
    
    prc_api_stat_pkg.log_start;
    
    select count(1)
      into l_estimated_count
      from bgn_no_fin rd
     where status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
       and is_incoming = com_api_const_pkg.TRUE
       and regexp_like(code, REGEXP_TOTALS);
       
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    
    if l_estimated_count > 0 then
        open cur_no_totals;
        loop
            fetch cur_no_totals bulk collect into l_fin_tab limit BULK_LIMIT;

            forall i in 1 .. l_fin_tab.count
                insert into bgn_no_fin
                    values (l_fin_tab(i).id        
                          , null     
                          , l_fin_tab(i).code        
                          , l_fin_tab(i).card_marker 
                          , l_fin_tab(i).product_name
                          , l_fin_tab(i).oper_name   
                          , l_fin_tab(i).seq_number  
                          , l_fin_tab(i).ird         
                          , l_fin_tab(i).debit_count 
                          , l_fin_tab(i).debit_trans 
                          , l_fin_tab(i).debit_tax   
                          , l_fin_tab(i).debit_total 
                          , l_fin_tab(i).credit_count
                          , l_fin_tab(i).credit_trans
                          , l_fin_tab(i).credit_tax  
                          , l_fin_tab(i).credit_total
                          , com_api_const_pkg.FALSE 
                          , net_api_const_pkg.CLEARING_MSG_STATUS_READY
                          , l_fin_tab(i).match_id  
                         );
                         
            forall i in 1 .. l_fin_tab.count
                update bgn_no_fin 
                   set status = net_api_const_pkg.CLEARING_MSG_STATUS_MATCHED
                     , match_id = l_fin_tab(i).id
                  where id = l_fin_tab(i).match_id;  
            
            l_processed_count := l_processed_count + l_fin_tab.count;
            
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );
            
            exit when cur_no_totals%notfound;
        end loop;    
        
        close cur_no_totals;
    end if;
    
    prc_api_stat_pkg.log_end (
        i_processed_total  => l_processed_count
        , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
exception
    when others then
        rollback to no_answer_start;
        
        if cur_no_totals%isopen then
            close cur_no_totals;
        end if;
        
        trc_log_pkg.error(sqlerrm);
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
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

end bgn_prc_borica_no_pkg;
/
 