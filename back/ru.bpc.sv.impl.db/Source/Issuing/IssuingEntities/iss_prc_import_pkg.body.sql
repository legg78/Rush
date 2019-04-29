create or replace package body iss_prc_import_pkg as

BULK_LIMIT             constant pls_integer := 400;

cursor g_cur_files(
    i_file_type          in com_api_type_pkg.t_dict_value
) is
    select s.file_xml_contents as xml_content
         , s.file_name
         , s.id
      from prc_session_file s
         , prc_file_attribute_vw a
         , prc_file_vw f
     where s.session_id = get_session_id
       and s.file_attr_id = a.id
       and f.id = a.file_id
       and f.file_type = i_file_type;
        
procedure import_cards_status(
    i_unload_file           in      com_api_type_pkg.t_boolean default null
  , i_masking_card          in      com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    l_statuses                  sys_refcursor;
            
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
            
    l_card_id                   com_api_type_pkg.t_number_tab;
    l_card_number               com_api_type_pkg.t_card_number_tab;
    l_seq_number                com_api_type_pkg.t_number_tab;
    l_change_date               com_api_type_pkg.t_date_tab;
    l_status                    com_api_type_pkg.t_dict_tab;
    l_state                     com_api_type_pkg.t_dict_tab;
    l_initiator                 com_api_type_pkg.t_dict_tab;
    l_change_id                 com_api_type_pkg.t_varchar2_tab;
    l_expir_date                com_api_type_pkg.t_date_tab;
            
    l_result_status             com_api_type_pkg.t_dict_value;
    l_result_state              com_api_type_pkg.t_dict_value;
    l_card_instance_id          com_api_type_pkg.t_medium_id;            
    l_params                    com_api_type_pkg.t_param_tab;
    
    l_sess_file_id              com_api_type_pkg.t_long_id;
    
    l_file                      clob;
    l_response_content          xmltype;
    l_file_params               com_api_type_pkg.t_param_tab;
    
    procedure enum_statuses (
        o_statuses           in out sys_refcursor
      , i_content            in     xmltype
    ) is
    begin
        open o_statuses for
            with card_status as (
                select card_number 
                     , card_id
                     , to_date(expir_date, com_api_const_pkg.XML_DATETIME_FORMAT) expir_date
                     , seq_number
                     , to_date(change_date, com_api_const_pkg.XML_DATETIME_FORMAT) change_date
                     , status
                     , state
                     , nvl(initiator, evt_api_const_pkg.INITIATOR_SYSTEM) initiator
                     , change_id 
                  from xmltable(
                      xmlnamespaces(default 'http://sv.bpc.in/SVXP')
                    , '/card_statuses/card_status'
                      passing (select i_content xml_content from dual)
                      columns 
                          card_number varchar2(19) path 'card_number'
                          , card_id number(12) path 'card_id'
                          , expir_date varchar2(100) path 'expiration_date'
                          , seq_number integer path 'seq_number'
                          , change_date varchar2(100) path 'change_date'
                          , status varchar2(8) path 'status'
                          , state varchar2(8) path 'state'
                          , initiator varchar2(8) path 'initiator'
                          , change_id varchar2(200) path 'change_id'
                  )
            )
            select n.card_id
                 , c.card_number
                 , c.expir_date
                 , c.seq_number
                 , c.change_date
                 , c.status
                 , c.state
                 , c.initiator
                 , c.change_id
             from card_status c
                , iss_card_number n
            where reverse(c.card_number) = reverse(iss_api_token_pkg.decode_card_number(i_card_number => n.card_number(+)))
              -- Using operator <like> to prevent full scan of <iss_card_number> with token API call for every record 
              and reverse(n.card_number(+)) like reverse('%' || substr(c.card_number, -iss_api_const_pkg.LENGTH_OF_PLAIN_PAN_ENDING))
              and c.card_number is not null
            union all
            select c.card_id
                 , n.card_number
                 , c.expir_date
                 , c.seq_number
                 , c.change_date
                 , c.status
                 , c.state
                 , c.initiator
                 , c.change_id
             from card_status c
                , iss_card_number n
            where n.card_id(+) = c.card_id
              and c.card_number is null;
    end;
    
begin
    savepoint read_statuses_start;
            
    trc_log_pkg.debug (
        i_text          => 'Read cards statuses'
    );
            
    prc_api_stat_pkg.log_start;
            
    -- get files
    for r in g_cur_files(iss_api_const_pkg.FILE_TYPE_CARDS_STATUSES) loop
        trc_log_pkg.debug (
            i_text       => 'processing file [#1] [#2]'
          , i_env_param1 => r.id
          , i_env_param2 => r.file_name  
        );
                
        enum_statuses (
            o_statuses => l_statuses
          , i_content  => r.xml_content
        );
        loop
            fetch l_statuses
            bulk collect into
                l_card_id
              , l_card_number
              , l_expir_date
              , l_seq_number
              , l_change_date
              , l_status
              , l_state
              , l_initiator
              , l_change_id
            limit BULK_LIMIT;
                    
            for i in 1 .. l_card_id.count loop
                begin
                    savepoint parse_start;
                            
                    if l_card_id(i) is null and l_card_number(i) is not null then
                        com_api_error_pkg.raise_error(
                            i_error       => 'CARD_NOT_FOUND'
                          , i_env_param1  => iss_api_card_pkg.get_card_mask(l_card_number(i))
                        );
                    end if;
                            
                    if l_card_id(i) is not null and l_card_number(i) is null then
                        com_api_error_pkg.raise_error(
                            i_error       => 'CARD_NOT_FOUND'
                          , i_env_param1  => l_card_id(i)
                        );
                    end if;
                            
                    l_card_instance_id := 
                        iss_api_card_instance_pkg.get_card_instance_id (
                            i_card_id     => l_card_id(i)
                          , i_seq_number  => l_seq_number(i)
                          , i_expir_date  => l_expir_date(i)
                        );

                    if l_card_instance_id is null then
                        com_api_error_pkg.raise_error (
                            i_error       => 'CARD_INSTANCE_NOT_FOUND'
                          , i_env_param1  => iss_api_card_pkg.get_card_mask(l_card_number(i))
                          , i_env_param2  => l_seq_number(i)
                        );
                    end if;
                            
                    evt_api_status_pkg.change_status (
                        i_initiator       => l_initiator(i)
                      , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      , i_object_id       => l_card_instance_id
                      , i_new_status      => l_state(i)
                      , i_reason          => null
                      , o_status          => l_result_state
                      , i_eff_date        => l_change_date(i)
                      , i_raise_error     => com_api_const_pkg.TRUE
                      , i_register_event  => com_api_const_pkg.TRUE
                      , i_params          => l_params
                    ); 
                        
                    evt_api_status_pkg.change_status (
                        i_initiator       => l_initiator(i)
                      , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      , i_object_id       => l_card_instance_id
                      , i_new_status      => l_status(i)
                      , i_reason          => null
                      , o_status          => l_result_status
                      , i_eff_date        => l_change_date(i)
                      , i_raise_error     => com_api_const_pkg.TRUE
                      , i_register_event  => com_api_const_pkg.TRUE
                      , i_params          => l_params
                    );
                        
                    trc_log_pkg.debug (
                        i_text        => 'Income state [#1] res_status [#2] income status [#3] res_status [#4]'
                      , i_env_param1  => l_state(i)
                      , i_env_param2  => l_result_state
                      , i_env_param3  => l_status(i)
                      , i_env_param4  => l_result_status
                    );
                    if nvl(i_unload_file, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                        select xmlconcat(
                                   l_response_content
                                 , xmlelement("card_status",
                                       xmlforest(
                                           case i_masking_card 
                                               when com_api_const_pkg.TRUE then
                                                   iss_api_card_pkg.get_card_mask(l_card_number(i))
                                               else
                                                   l_card_number(i)
                                           end                 as "card_number"
                                         , l_card_id(i)        as "card_id"
                                         , to_char(l_expir_date(i), com_api_const_pkg.XML_DATE_FORMAT)
                                                               as "expiration_date"
                                         , l_seq_number(i)     as "seq_number"
                                         , to_char(l_change_date(i), com_api_const_pkg.XML_DATETIME_FORMAT)
                                                               as "change_date"
                                         , l_status(i)         as "status"
                                         , l_state(i)          as "state"
                                         , l_initiator(i)      as "initiator"
                                         , l_change_id(i)      as "change_id"
                                         , prc_api_const_pkg.INCOM_FILE_REC_SUCCESS as "result_code"
                                       )
                                   )
                               )
                          into l_response_content
                          from dual;
                    end if;
                            
                    l_processed_count := l_processed_count + 1;
                exception
                    when others then
                        rollback to savepoint parse_start;
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            if nvl(i_unload_file, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                                select xmlconcat(
                                           l_response_content
                                         , xmlelement("card_status",
                                               xmlforest(
                                                 case i_masking_card 
                                                     when com_api_const_pkg.TRUE then
                                                         iss_api_card_pkg.get_card_mask(l_card_number(i))
                                                     else
                                                         l_card_number(i)
                                                 end                   as "card_number"
                                                 , l_card_id(i)        as "card_id"
                                                 , to_char(l_expir_date(i), com_api_const_pkg.XML_DATE_FORMAT)
                                                                       as "expiration_date"
                                                 , l_seq_number(i)     as "seq_number"
                                                 , to_char(l_change_date(i), com_api_const_pkg.XML_DATETIME_FORMAT)
                                                                       as "change_date"
                                                 , l_status(i)         as "status"
                                                 , l_state(i)          as "state"
                                                 , l_initiator(i)      as "initiator"
                                                 , l_change_id(i)      as "change_id"
                                                 , prc_api_const_pkg.INCOM_FILE_REC_ERROR as "result_code"
                                                 , com_api_error_pkg.get_last_error as "error_code"
                                               )
                                           )
                                       )
                                  into l_response_content
                                  from dual;
                            end if;
                                    
                            l_excepted_count := l_excepted_count + 1;
                        else
                            raise;
                        end if;
                end;
            end loop;
                    
            prc_api_stat_pkg.log_current (
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
            exit when l_statuses%notfound;
        end loop;

        close l_statuses;            

        if nvl(i_unload_file, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
        
            rul_api_param_pkg.set_param(
                i_name      => 'ORIGINAL_FILE_NAME'
              , i_value     => r.file_name
              , io_params   => l_file_params
            );
        
            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_sess_file_id
              , i_file_type     => prc_api_const_pkg.FILE_TYPE_CARD_RESPONSE  
              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params       => l_file_params
            );
            
            l_file := com_api_const_pkg.XML_HEADER
                        || '<card_statuses>'
                        || l_response_content.getclobval()
                        || '</card_statuses>';


            prc_api_file_pkg.put_file(
                i_sess_file_id  => l_sess_file_id
              , i_clob_content  => l_file
            );

            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
            
            l_file := null;
            l_response_content := null;
        
        end if;
                
    end loop;
                
    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_processed_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text  => 'Read cards statuses finished...'
    );

exception
    when others then
        rollback to savepoint read_statuses_start;
                
        if l_statuses%isopen then
            close l_statuses;
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
end import_cards_status;

procedure import_card_black_list(
    i_downloading_type  in   com_api_type_pkg.t_dict_value
) is
    cursor cur_black_list is
       select x.card_number
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/card_black_list')
                   , '/card_black_list/card' passing s.file_xml_contents
                   columns 
                      card_number                       varchar2(30)  path 'card_number'
              ) x
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = iss_api_const_pkg.FILE_TYPE_CARD_BLACK_LIST;

    cursor cur_black_list_count is
        select nvl(sum(card_count), 0) card_count
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/card_black_list')
                   , '/card_black_list' passing s.file_xml_contents
                columns 
                      card_count                        number        path 'fn:count(card)'
              ) x
         where s.session_id = get_session_id 
         and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = iss_api_const_pkg.FILE_TYPE_CARD_BLACK_LIST;

    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_card_tab              com_api_type_pkg.t_card_number_tab;                        
    l_card_number           com_api_type_pkg.t_card_number;
    l_card_id               com_api_type_pkg.t_medium_id;
    l_count                 com_api_type_pkg.t_short_id;
begin
    savepoint read_cards_start;
    
    trc_log_pkg.info(
        i_text          => 'Read cards'
    );
    
    prc_api_stat_pkg.log_start;
    
    if i_downloading_type = iss_api_const_pkg.DOWNLOADING_TYPE_CLEANING then
        delete from iss_black_list;
    end if;
    
    open cur_black_list_count;
    fetch cur_black_list_count into l_estimated_count;
    close cur_black_list_count;
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    
    open    cur_black_list;        
    trc_log_pkg.debug(
        i_text          => 'cursor opened'
    );
        
    loop
        trc_log_pkg.info(
            i_text          => 'start fetching 1000 cards'
        );
        
        fetch cur_black_list bulk collect into l_card_tab limit 1000;
        
        trc_log_pkg.info(
            i_text          => '#1 cards fetched'
          , i_env_param1    => l_card_tab.count
        );
        
        for i in 1 .. l_card_tab.count loop
            savepoint register_cards_start;
        
            begin
                l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => l_card_tab(i));
                       
                -- check if card already exists in iss_black_list
                select count(1)
                  into l_count
                  from iss_black_list 
                 where card_number = l_card_number;
                    
                if l_count = 0 then
                    l_card_id := iss_api_card_pkg.get_card_id(i_card_number => l_card_tab(i));   
                    
                    insert into iss_black_list(
                        id
                        , card_number
                    )
                    values(
                        l_card_id
                        , l_card_number
                     );    
                else
                    trc_log_pkg.debug(
                        i_text => 'Card with number ' || iss_api_card_pkg.get_card_mask(l_card_tab(i)) 
                               || ' already exists in black_list'
                    );                 
                end if;  
                                             
                l_processed_count := l_processed_count + 1;  
                    
            exception
                when others then
                    rollback to savepoint register_cards_start;
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;     
                              
                    else
                        close   cur_black_list;
                        raise;
                           
                    end if;    
            end;   
                
            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;
            
        end loop;
        
        exit when cur_black_list%notfound;
        
    end loop;
    
    close cur_black_list;
    
    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.info (
        i_text  => 'Read cards finished'
    );

exception
    when others then
        rollback to savepoint read_cards_start;
        if cur_black_list%isopen then 
            close cur_black_list;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
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
end import_card_black_list;

/*
* Load cards' security data in according with svxp_card_secure.xsd specification
*/
procedure import_cards_security_data(
    i_card_state        in     com_api_type_pkg.t_dict_value default null
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.import_cards_security_data: ';
        
    cursor l_cur_cards_count is
        select count(f.id) as files_count
             , nvl(sum(nvl(x.cards_count, 0)), 0) as cards_count
          from prc_session_file s
          join prc_file_attribute a on a.id = s.file_attr_id
          join prc_file f on f.id = a.file_id
          cross join xmltable(
                 xmlnamespaces(default 'http://bpc.ru/sv/SVXP/cardSecure')
               , '/cards'
                 passing s.file_xml_contents
                 columns 
                     cards_count             number        path 'fn:count(card)'
               ) x 
         where s.session_id = get_session_id 
           and f.file_type = iss_api_const_pkg.FILE_TYPE_CARDS_SECURE_FILE;          

    cursor l_cur_cards(
        i_xml_content        in xmltype
    ) is
       select x.card_id
            , x.card_mask
            , x.card_number
            , to_date(x.expiration_date, com_api_const_pkg.XML_DATE_FORMAT) as expiration_date                       
            , x.card_sequental_number
            , x.card_instance_id
            , x.state
            , x.pvv
            , x.pin_offset
            , x.pin_block
            , x.key_index
            , x.PIN_block_format
         from xmltable(
             xmlnamespaces(default 'http://bpc.ru/sv/SVXP/cardSecure')
           , '/cards/card'
             passing i_xml_content
             columns
                 card_id                number(12)    path 'card_id'
               , card_mask              varchar2(24)  path 'card_mask'
               , card_number            varchar2(24)  path 'card_number'
               , expiration_date        varchar2(16)  path 'expiration_date'                       
               , card_sequental_number  number(4)     path 'card_sequental_number'
               , card_instance_id       number(12)    path 'card_instance_id'
               , state                  varchar2(8)   path 'state'
               , pvv                    number(4)     path 'card_security/PVV'
               , pin_offset             varchar2(12)  path 'card_security/PIN_offset'
               , pin_block              varchar2(16)  path 'card_security/PIN_block'
               , key_index              number(4)     path 'card_security/key_index'
               , pin_block_format       varchar2(8)   path 'card_security/PIN_block_format'
         ) x;

    type t_cards_tab            is table of l_cur_cards%rowtype index by pls_integer;
         
    l_cards_tab                 t_cards_tab;
    l_ok_id                     com_api_type_pkg.t_medium_tab;
    l_pvv                       com_api_type_pkg.t_tiny_tab;
    l_pin_offset                com_api_type_pkg.t_cmid_tab;
    l_pvk_index                 com_api_type_pkg.t_tiny_tab;
    l_pin_block                 com_api_type_pkg.t_varchar2_tab;
    l_pin_block_format          com_api_type_pkg.t_dict_tab;
    
    l_files_count               com_api_type_pkg.t_count := 0;
    l_estimated_count           com_api_type_pkg.t_count := 0;
    l_excepted_count            com_api_type_pkg.t_count := 0;
    l_processed_count           com_api_type_pkg.t_count := 0;
    l_params                    com_api_type_pkg.t_param_tab;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    
    procedure register_sensitive_data (
        i_id                    in com_api_type_pkg.t_medium_id
        , i_pvv                 in com_api_type_pkg.t_tiny_id
        , i_pin_offset          in com_api_type_pkg.t_cmid
        , i_pvk_index           in com_api_type_pkg.t_tiny_id
        , i_pin_block           in com_api_type_pkg.t_pin_block
        , i_pin_block_format    in com_api_type_pkg.t_curr_code
    ) is
        i                       binary_integer;
    begin
        i := l_ok_id.count + 1;
            
        -- card instance
        l_ok_id(i)            := i_id;
        l_pvv(i)              := i_pvv;
        l_pin_offset(i)       := i_pin_offset;
        l_pvk_index(i)        := nvl(i_pvk_index, iss_api_const_pkg.DEFAULT_PIN_KEY_INDEX_VALUE);
        l_pin_block(i)        := i_pin_block;
        l_pin_block_format(i) := nvl(i_pin_block_format, prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI);
    end;

    procedure update_sensitive_data is
    begin
        iss_api_card_instance_pkg.update_sensitive_data (
            i_id                  => l_ok_id
            , i_pvk_index         => l_pvk_index
            , i_pvv               => l_pvv
            , i_pin_offset        => l_pin_offset
            , i_pin_block         => l_pin_block
            , i_pin_block_format  => l_pin_block_format
        );
        
        l_ok_id.delete;
        l_pvv.delete;
        l_pin_offset.delete;
        l_pvk_index.delete;
        l_pin_block.delete;
        l_pin_block_format.delete;
    end;
        
begin
    savepoint import_cards_security_data;

    trc_log_pkg.debug(i_text => LOG_PREFIX || 'starting');
    prc_api_stat_pkg.log_start;

    -- Logging information about files' count and estimated total cards' count  
    open l_cur_cards_count;
    fetch l_cur_cards_count into l_files_count, l_estimated_count;
    close l_cur_cards_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '[#1] files are ready for processing, estimated total cards'' count is [#2]'
      , i_env_param1 => l_files_count
      , i_env_param2 => l_estimated_count
    );
        
    -- Processing files one by one
    for r in g_cur_files(iss_api_const_pkg.FILE_TYPE_CARDS_SECURE_FILE) loop
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'processing file with id [#1] and name [#2]'
          , i_env_param1 => r.id
          , i_env_param2 => r.file_name  
        );
        
        open l_cur_cards(i_xml_content => r.xml_content);

        loop
            fetch l_cur_cards bulk collect into l_cards_tab limit BULK_LIMIT;

            for i in l_cards_tab.first .. l_cards_tab.last loop
                savepoint before_processing_a_card;

                begin
                    -- Try to look for current card's instance
                    if l_cards_tab(i).card_instance_id is not null then
                        declare
                            l_card_instance_id    com_api_type_pkg.t_medium_id;
                        begin
                            select ci.id
                                 , inst_id
                                 , split_hash
                              into l_card_instance_id
                                 , l_inst_id
                                 , l_split_hash
                              from iss_card_instance ci
                             where ci.id = l_cards_tab(i).card_instance_id;
                        exception 
                            when no_data_found then
                                com_api_error_pkg.raise_error(i_error => 'CARD_INSTANCE_NOT_FOUND');
                        end;
                    else
                        l_cards_tab(i).card_instance_id := 
                            iss_api_card_instance_pkg.get_card_instance_id(
                                i_card_id     => l_cards_tab(i).card_id
                              , i_card_number => l_cards_tab(i).card_number
                              , i_seq_number  => l_cards_tab(i).card_sequental_number
                              , i_expir_date  => l_cards_tab(i).expiration_date
                              , i_raise_error => com_api_const_pkg.TRUE -- raise an exception if an instance isn't found
                            );
                        select inst_id
                             , split_hash
                          into l_inst_id
                             , l_split_hash 
                          from iss_card_instance
                         where id = l_cards_tab(i).card_instance_id;
                    end if;
                    
                    -- Data of XML file (tag <state>) should be used primarily for updating card instance state  
                    iss_api_card_instance_pkg.change_card_state(
                        i_id          => l_cards_tab(i).card_instance_id
                      , i_card_state  => nvl(l_cards_tab(i).state, i_card_state)
                      , i_raise_error => com_api_type_pkg.TRUE
                    );
                    
                    register_sensitive_data(
                        i_id                => l_cards_tab(i).card_instance_id
                      , i_pvv               => l_cards_tab(i).pvv
                      , i_pin_offset        => l_cards_tab(i).pin_offset
                      , i_pvk_index         => l_cards_tab(i).key_index
                      , i_pin_block         => l_cards_tab(i).pin_block
                      , i_pin_block_format  => l_cards_tab(i).pin_block_format 
                    );
                    
                    evt_api_event_pkg.register_event(
                        i_event_type    => iss_api_const_pkg.EVENT_TYPE_UPD_SENSITIVE_DATA
                      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
                      , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                      , i_object_id     => l_cards_tab(i).card_instance_id
                      , i_inst_id       => l_inst_id
                      , i_split_hash    => l_split_hash
                      , i_param_tab     => l_params
                    );
                exception
                    when others then
                        rollback to savepoint before_processing_a_card;

                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            raise;
                        end if;
                end;
                
                l_processed_count := l_processed_count + 1;

                if l_ok_id.count >= BULK_LIMIT then
                    update_sensitive_data;
                end if;
            end loop;
            
            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => l_excepted_count
            );

            exit when l_cur_cards%notfound;
        end loop;
        
        update_sensitive_data;
            
        close l_cur_cards;                
    end loop; -- g_cur_files

    prc_api_stat_pkg.log_end(
        i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total => l_processed_count
      , i_excepted_total  => l_excepted_count
    );
exception
    when others then
        rollback to savepoint import_cards_security_data;
        
        if l_cur_cards%isopen then
            close l_cur_cards;
        end if;
        
        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE 
           or 
           com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE 
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end import_cards_security_data;

end;
/
