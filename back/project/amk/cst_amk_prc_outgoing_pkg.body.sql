create or replace package body cst_amk_prc_outgoing_pkg as

CRLF                     constant com_api_type_pkg.t_name := chr(13)||chr(10);
BULK_LIMIT               constant integer := 1000;
SEPARATE_CHAR_DEFAULT    constant com_api_type_pkg.t_byte_char := ';';


type t_event_id_tab is table of com_api_type_pkg.t_number_tab index by com_api_type_pkg.t_name;
type t_object_rec  is record(
    object_id    com_api_type_pkg.t_number_tab
  , event_id     t_event_id_tab
);
    
type t_entity_tab  is table of t_object_rec index by com_api_type_pkg.t_dict_value;

procedure add_objects_in_tab(
    i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_proc_name            in      com_api_type_pkg.t_name
  , i_sysdate              in      date
  , io_event_object_tab    in out  t_entity_tab
  , io_entity_tab          in out  com_api_type_pkg.t_dict_tab
) is
begin
    for rec in (select o.id as event_id
                     , o.entity_type
                     , o.object_id
                  from evt_event_object o
                     , evt_event e
                     , evt_subscriber s
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_proc_name
                   and o.eff_date      <= i_sysdate
                   and (o.inst_id       = i_inst_id
                        or i_inst_id    is null
                        or i_inst_id    = ost_api_const_pkg.DEFAULT_INST
                       )
                   and o.entity_type    = i_entity_type
                   and e.id             = o.event_id
                   and e.event_type     = s.event_type
                   and o.procedure_name = s.procedure_name
                 order by
                       o.id
    ) loop
        if io_event_object_tab.count = 0 then
            io_event_object_tab(rec.entity_type).object_id(1) := rec.object_id; 
            io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
            if io_entity_tab.exists(1) then
                io_entity_tab.delete;
            end if;
            io_entity_tab(1) := rec.entity_type;
        else
            if io_event_object_tab.exists(rec.entity_type) then
                if io_event_object_tab(rec.entity_type).event_id.exists(rec.object_id) then
                    io_event_object_tab(rec.entity_type).event_id(rec.object_id)(io_event_object_tab(rec.entity_type).event_id(rec.object_id).last + 1) := rec.event_id;
                else
                    io_event_object_tab(rec.entity_type).object_id(io_event_object_tab(rec.entity_type).object_id.last + 1) := rec.object_id;
                    io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
                end if;
            else
                io_event_object_tab(rec.entity_type).object_id(1)   := rec.object_id;
                io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
                io_entity_tab(io_entity_tab.last + 1) := rec.entity_type;
            end if;
        end if;
    end loop;
end add_objects_in_tab;

function check_add_result_line(
    i_entity_type              in  com_api_type_pkg.t_dict_value
  , i_transactions_data_rec    in  acc_api_type_pkg.t_transaction_external_rec
  , i_event_object_tab         in  t_entity_tab
) return com_api_type_pkg.t_boolean
is
begin
    
    return case
               when (i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                     and i_event_object_tab(i_entity_type).event_id.exists(i_transactions_data_rec.debt_entry_id)
                    )
                    or 
                    (i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY
                     and i_event_object_tab(i_entity_type).event_id.exists(i_transactions_data_rec.credit_entry_id)
                    )
                    or
                    (i_entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                     and i_event_object_tab(i_entity_type).event_id.exists(i_transactions_data_rec.transaction_id)
                    )
                   then com_api_const_pkg.TRUE
               else 
                   com_api_const_pkg.FALSE
           end;
end check_add_result_line;

procedure clear_check_data(
    i_entity_type              in     com_api_type_pkg.t_dict_value
  , i_index_element            in     com_api_type_pkg.t_long_id
  , io_event_object_tab        in out t_entity_tab
)
is
begin
    if io_event_object_tab(i_entity_type).event_id.exists(i_index_element) then
        io_event_object_tab(i_entity_type).event_id.delete(i_index_element);
    end if;
end clear_check_data;

procedure add_event_collection(
    i_index                    in     com_api_type_pkg.t_long_id
  , i_entity_tab               in     com_api_type_pkg.t_dict_tab
  , i_transactions_data_rec    in     acc_api_type_pkg.t_transaction_external_rec
  , io_event_object_tab        in out t_entity_tab
  , io_event_tab               in out com_api_type_pkg.t_number_tab
)
is
begin
    for i in i_index .. i_entity_tab.last
    loop
        if i_entity_tab(i) = acc_api_const_pkg.ENTITY_TYPE_ENTRY
            and io_event_object_tab(i_entity_tab(i)).event_id.exists(i_transactions_data_rec.debt_entry_id)
        then
            for n in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.debt_entry_id).last
            loop
                if io_event_tab.exists(1) then
                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.debt_entry_id)(n);
                else
                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.debt_entry_id)(n);
                end if;
            end loop;
            clear_check_data(
                i_entity_type        => i_entity_tab(i)
              , i_index_element      => i_transactions_data_rec.debt_entry_id
              , io_event_object_tab  => io_event_object_tab
            );
        end if;
        if i_entity_tab(i) = acc_api_const_pkg.ENTITY_TYPE_ENTRY
            and io_event_object_tab(i_entity_tab(i)).event_id.exists(i_transactions_data_rec.credit_entry_id)
        then
            for n in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.credit_entry_id).last
            loop
                if io_event_tab.exists(1) then
                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.credit_entry_id)(n);
                else
                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.credit_entry_id)(n);
                end if;
            end loop; 
            clear_check_data(
                i_entity_type        => i_entity_tab(i)
              , i_index_element      => i_transactions_data_rec.credit_entry_id
              , io_event_object_tab  => io_event_object_tab
            );
        end if;
        if i_entity_tab(i) = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
            and io_event_object_tab(i_entity_tab(i)).event_id.exists(i_transactions_data_rec.transaction_id)
        then
            for n in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.transaction_id).last
            loop
                if io_event_tab.exists(1) then
                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.transaction_id)(n);
                else
                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(i_transactions_data_rec.transaction_id)(n);
                end if;
            end loop; 
            clear_check_data(
                i_entity_type        => i_entity_tab(i)
              , i_index_element      => i_transactions_data_rec.transaction_id
              , io_event_object_tab  => io_event_object_tab
            );
        end if;
    end loop;
end add_event_collection;

procedure add_event_collection(
    i_index                    in     com_api_type_pkg.t_long_id
  , i_entity_tab               in     com_api_type_pkg.t_dict_tab
  , i_oper_id                  in     com_api_type_pkg.t_long_id
  , io_event_object_tab        in out t_entity_tab
  , io_event_tab               in out com_api_type_pkg.t_number_tab
)
is
begin
    for i in i_index .. i_entity_tab.last
    loop
        if i_entity_tab(i) = opr_api_const_pkg.ENTITY_TYPE_OPERATION
            and io_event_object_tab(i_entity_tab(i)).event_id.exists(i_oper_id)
        then
            for n in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(i_oper_id).last
            loop
                if io_event_tab.exists(1) then
                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(i_oper_id)(n);
                else
                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(i_oper_id)(n);
                end if;
            end loop; 
            clear_check_data(
                i_entity_type        => i_entity_tab(i)
              , i_index_element      => i_oper_id
              , io_event_object_tab  => io_event_object_tab
            );
        end if;
    end loop;
end add_event_collection;

procedure add_not_used_event_collection(
    i_entity_tab               in     com_api_type_pkg.t_dict_tab
  , io_event_object_tab        in out t_entity_tab
  , io_event_tab               in out com_api_type_pkg.t_number_tab
)
is
begin
    if i_entity_tab.exists(1) then
        for i in i_entity_tab.first .. i_entity_tab.last
        loop
            if io_event_object_tab.exists(i_entity_tab(i)) then
                if io_event_object_tab(i_entity_tab(i)).object_id.exists(1) then
                    for j in io_event_object_tab(i_entity_tab(i)).object_id.first .. io_event_object_tab(i_entity_tab(i)).object_id.last
                    loop
                        if io_event_object_tab(i_entity_tab(i)).event_id.exists(io_event_object_tab(i_entity_tab(i)).object_id(j))
                        then
                            for k in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j)).last
                            loop
                                if io_event_tab.exists(1) then
                                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j))(k);
                                else
                                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j))(k);
                                end if;
                            end loop;
                        end if;
                    end loop;
                end if;
            end if;
        end loop;
    end if;
end add_not_used_event_collection;

procedure process_fees_to_t24_export(
    i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_full_export              in  com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type                in  com_api_type_pkg.t_dict_value
  , i_start_date               in  date                                default null
  , i_end_date                 in  date                                default null
  , i_gl_accounts              in  com_api_type_pkg.t_boolean          default null
  , i_load_reversals           in  com_api_type_pkg.t_boolean          default null
  , i_array_balance_type_id    in  com_api_type_pkg.t_medium_id        default null
  , i_array_trans_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_separate_char            in  com_api_type_pkg.t_byte_char
) is
    PROC_NAME                  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROCESS_FEES_TO_T24_EXPORT';
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';

    l_event_object_tab         t_entity_tab;
    
    l_event_tab                com_api_type_pkg.t_number_tab;
    l_entity_tab               com_api_type_pkg.t_dict_tab;
    l_transactions_unloading   com_api_type_pkg.t_number_tab;

    l_param_tab                com_api_type_pkg.t_param_tab;
    
    l_transactions_data_tab    acc_api_type_pkg.t_transaction_external_tab;

    l_session_file_id          com_api_type_pkg.t_long_id;
    
    l_estimated_count          com_api_type_pkg.t_long_id    := 0;
    l_processed_count          com_api_type_pkg.t_long_id    := 0;
    l_excepted_count           com_api_type_pkg.t_long_id    := 0;
    l_rejected_count           com_api_type_pkg.t_long_id    := 0;
    
    l_ref_cursor               com_api_type_pkg.t_ref_cur;
    
    l_object_tab               com_api_type_pkg.t_object_tab;
    
    l_sysdate                  date;
    l_start_date               date;
    l_end_date                 date;
    l_type_of_date_range       com_api_type_pkg.t_dict_value;
    
    l_increment_count          com_api_type_pkg.t_long_id;
    
    l_request_count            com_api_type_pkg.t_short_id;
    
    l_full_export              com_api_type_pkg.t_boolean;
    
    l_shift_from               com_api_type_pkg.t_tiny_id        := 0;
    l_shift_to                 com_api_type_pkg.t_tiny_id        := 0;
    l_balance_type             com_api_type_pkg.t_dict_value;
    l_account_number           com_api_type_pkg.t_account_number;
    l_array_settl_type_id      com_api_type_pkg.t_medium_id;
    
    procedure put_record_to_file(
        i_transactions_data_rec    acc_api_type_pkg.t_transaction_external_rec
      , i_session_file_id          com_api_type_pkg.t_long_id
    ) is
        l_separate_char        com_api_type_pkg.t_byte_char := nvl(i_separate_char, SEPARATE_CHAR_DEFAULT);
        l_record               com_api_type_pkg.t_text;
    begin
        l_record := i_transactions_data_rec.debt_account_number || l_separate_char;
        l_record := l_record || i_transactions_data_rec.credit_account_number || l_separate_char;
        l_record := l_record || i_transactions_data_rec.credit_amount || l_separate_char;
        l_record := l_record || to_char(nvl(i_transactions_data_rec.macros_conversion_rate, 1), com_api_const_pkg.NUMBER_FORMAT) || l_separate_char;
        l_record := l_record || get_article_text(
                                    i_article => i_transactions_data_rec.oper_type
                                )
                             || ' '
                             || get_article_text(
                                    i_article => i_transactions_data_rec.oper_reason
                                )
        ;
        prc_api_file_pkg.put_line(
            i_raw_data      => l_record
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => l_record || CRLF
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end put_record_to_file;
    
begin
    prc_api_stat_pkg.log_start;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] date_type [#2] start_date [#3] end_date [#4] separate_char [#5] gl_accounts [#6'
               || '], full_export [' || i_full_export
               || '], shift_from [' || l_shift_from
               || '], shift_to [' || l_shift_to
               || '], balance_type [' || l_balance_type
               || '], account_number [' || l_account_number
               || '], load_reversals [' || i_load_reversals
               || '], array_balance_type_id [' || i_array_balance_type_id
               || '], array_trans_type_id [' || i_array_trans_type_id
               || '], array_settl_type_id [' || l_array_settl_type_id
               || ']'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_date_type
      , i_env_param3 => i_start_date
      , i_env_param4 => i_end_date
      , i_env_param5 => i_separate_char
      , i_env_param6 => i_gl_accounts
    );
    
    l_type_of_date_range := com_api_sttl_day_pkg.map_date_type_dict_to_dict(
                                i_date_type    => i_date_type
                              , i_dict_map     => fcl_api_const_pkg.DATE_TYPE_DICTIONARY_TYPE
                            )
    ;
    
    l_full_export        := coalesce(i_full_export, com_api_type_pkg.FALSE);
    
    l_sysdate    := com_api_sttl_day_pkg.get_calc_date(
                        i_inst_id   => i_inst_id
                      , i_date_type => l_type_of_date_range
                    )
    ;
    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD') + nvl(l_shift_from, 0);
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND + nvl(l_shift_to, 0);
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Calculate date period - type_of_date_range [#1]  sysdate [#2] start_date [#3] end_date [#4]' 
      , i_env_param1 => l_type_of_date_range
      , i_env_param2 => l_sysdate
      , i_env_param3 => l_start_date
      , i_env_param4 => l_end_date
    );
    
    if l_full_export = com_api_const_pkg.TRUE then
        acc_api_external_pkg.get_transactions_data(
            i_inst_id                  => i_inst_id
          , i_date_type                => i_date_type
          , i_start_date               => l_start_date
          , i_end_date                 => l_end_date
          , i_balance_type             => l_balance_type
          , i_account_number           => l_account_number
          , i_fees                     => com_api_const_pkg.TRUE
          , i_gl_accounts              => i_gl_accounts
          , i_load_reversals           => i_load_reversals
          , i_object_tab               => l_object_tab
          , i_array_balance_type_id    => i_array_balance_type_id
          , i_array_trans_type_id      => i_array_trans_type_id
          , i_array_settl_type_id      => l_array_settl_type_id
          , i_mask_error               => com_api_const_pkg.TRUE
          , o_row_count                => l_estimated_count
          , o_ref_cursor               => l_ref_cursor
        );
    
        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_estimated_count
        );
        
        if l_estimated_count > 0 then
            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_session_file_id
              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params       => l_param_tab
            );
            
            loop
                fetch l_ref_cursor bulk collect into l_transactions_data_tab
                limit BULK_LIMIT;
                
                for i in 1..l_transactions_data_tab.count loop
                    put_record_to_file(
                        i_transactions_data_rec => l_transactions_data_tab(i)
                      , i_session_file_id       => l_session_file_id
                    );
                    l_processed_count := l_processed_count + 1;
                end loop;
                exit when l_ref_cursor%notfound;
            end loop;
            close l_ref_cursor;
        end if;
        
    elsif l_full_export = com_api_const_pkg.FALSE then
        add_objects_in_tab(
            i_inst_id              => i_inst_id
          , i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ENTRY
          , i_proc_name            => PROC_NAME
          , i_sysdate              => l_sysdate
          , io_event_object_tab    => l_event_object_tab
          , io_entity_tab          => l_entity_tab
        );
        add_objects_in_tab(
            i_inst_id              => i_inst_id
          , i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
          , i_proc_name            => PROC_NAME
          , i_sysdate              => l_sysdate
          , io_event_object_tab    => l_event_object_tab
          , io_entity_tab          => l_entity_tab
        );
        if l_event_object_tab.count = 0 then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'The requested data [#1] was not found'
              , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
            );
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
        else
            for i in l_entity_tab.first .. l_entity_tab.last loop
                trc_log_pkg.debug(
                    i_text        => LOG_PREFIX || 'Incremental unload: count [#1] events  for entity [#2]'
                  , i_env_param1  => l_event_object_tab(l_entity_tab(i)).object_id.count
                  , i_env_param2  => l_entity_tab(i)
                );
            end loop;
            
            for i in l_entity_tab.first .. l_entity_tab.last loop
                l_request_count := ceil(l_event_object_tab(l_entity_tab(i)).object_id.count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := l_entity_tab(i);
                    l_object_tab(1).entity_type := l_entity_tab(i);
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_event_object_tab(l_entity_tab(i)).object_id.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_event_object_tab(l_entity_tab(i)).object_id(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_event_object_tab(l_entity_tab(i)).object_id(l);
                        end if;
                    end loop;
                    
                    acc_api_external_pkg.get_transactions_data(
                        i_inst_id                  => i_inst_id
                      , i_date_type                => i_date_type
                      , i_start_date               => l_start_date
                      , i_end_date                 => l_end_date
                      , i_balance_type             => l_balance_type
                      , i_account_number           => l_account_number
                      , i_fees                     => com_api_const_pkg.TRUE
                      , i_gl_accounts              => i_gl_accounts
                      , i_load_reversals           => i_load_reversals
                      , i_object_tab               => l_object_tab
                      , i_array_balance_type_id    => i_array_balance_type_id
                      , i_array_trans_type_id      => i_array_trans_type_id
                      , i_array_settl_type_id      => l_array_settl_type_id
                      , i_mask_error               => com_api_const_pkg.TRUE
                      , o_row_count                => l_increment_count
                      , o_ref_cursor               => l_ref_cursor
                    );
                    
                    if l_increment_count > 0 then
                        if l_session_file_id is null then
                            prc_api_file_pkg.open_file(
                                o_sess_file_id  => l_session_file_id
                              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
                              , io_params       => l_param_tab
                            );
                        end if;
                        loop
                            fetch l_ref_cursor bulk collect into l_transactions_data_tab
                            limit BULK_LIMIT;
                            
                            for m in 1..l_transactions_data_tab.count loop
                                if check_add_result_line(
                                       i_entity_type              => l_entity_tab(i)
                                     , i_transactions_data_rec    => l_transactions_data_tab(m)
                                     , i_event_object_tab         => l_event_object_tab
                                   ) = com_api_const_pkg.TRUE
                                then
                                    
                                    if l_transactions_unloading.exists(1) then
                                        l_transactions_unloading(l_transactions_unloading.last + 1) := l_transactions_data_tab(m).transaction_id;
                                    else
                                        l_transactions_unloading(1) := l_transactions_data_tab(m).transaction_id;
                                    end if;
                                    
                                    l_estimated_count := l_estimated_count + 1;
                                    
                                    add_event_collection(
                                        i_index                  => i
                                      , i_entity_tab             => l_entity_tab
                                      , i_transactions_data_rec  => l_transactions_data_tab(m)
                                      , io_event_object_tab      => l_event_object_tab
                                      , io_event_tab             => l_event_tab
                                    );
                                    
                                end if;
                            end loop;
                            exit when l_ref_cursor%notfound;
                        end loop;
                        close l_ref_cursor;
                    end if;
                end loop;
            end loop;
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
            if l_estimated_count > 0 then
                l_request_count := ceil(l_estimated_count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := acc_api_const_pkg.ENTITY_TYPE_TRANSACTION;
                    l_object_tab(1).entity_type := acc_api_const_pkg.ENTITY_TYPE_TRANSACTION;
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_transactions_unloading.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_transactions_unloading(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_transactions_unloading(l);
                        end if;
                    end loop;
                        
                    acc_api_external_pkg.get_transactions_data(
                        i_inst_id                  => i_inst_id
                      , i_date_type                => i_date_type
                      , i_start_date               => l_start_date
                      , i_end_date                 => l_end_date
                      , i_balance_type             => l_balance_type
                      , i_account_number           => l_account_number
                      , i_fees                     => com_api_const_pkg.TRUE
                      , i_gl_accounts              => i_gl_accounts
                      , i_load_reversals           => i_load_reversals
                      , i_object_tab               => l_object_tab
                      , i_array_balance_type_id    => i_array_balance_type_id
                      , i_array_trans_type_id      => i_array_trans_type_id
                      , i_array_settl_type_id      => l_array_settl_type_id
                      , i_mask_error               => com_api_const_pkg.TRUE
                      , o_row_count                => l_increment_count
                      , o_ref_cursor               => l_ref_cursor
                    );
                        
                    if l_increment_count > 0 then
                        if l_session_file_id is null then
                            prc_api_file_pkg.open_file(
                                o_sess_file_id  => l_session_file_id
                              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
                              , io_params       => l_param_tab
                            );
                        end if;
                        loop
                            fetch l_ref_cursor bulk collect into l_transactions_data_tab
                            limit BULK_LIMIT;
                                
                            for m in 1..l_transactions_data_tab.count loop
                                put_record_to_file(
                                    i_transactions_data_rec => l_transactions_data_tab(m)
                                  , i_session_file_id       => l_session_file_id
                                );
                                        
                                l_processed_count := l_processed_count + 1;
                            end loop;
                            exit when l_ref_cursor%notfound;
                        end loop;
                        close l_ref_cursor;
                    end if;
                end loop;
            end if;
        end if;
    end if;

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;
    add_not_used_event_collection(
        i_entity_tab               => l_entity_tab
      , io_event_object_tab        => l_event_object_tab
      , io_event_tab               => l_event_tab
    );
    if l_event_tab.exists(1) then
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );
    end if;
    
    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success'
    );
    
exception
    when others then
       trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'Finished with errors: [#1]'
          , i_env_param1  => sqlcode
        );
        
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        l_estimated_count := nvl(l_estimated_count, 0);
        l_excepted_count  := l_estimated_count - l_processed_count;
        
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
end process_fees_to_t24_export;

procedure process_trans_export_to_telco(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_full_export               in  com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type                 in  com_api_type_pkg.t_dict_value
  , i_start_date                in  date                                default null
  , i_end_date                  in  date                                default null
  , i_service_provider_id       in  com_api_type_pkg.t_short_id         default null
  , i_load_reversals            in  com_api_type_pkg.t_boolean          default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id        default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
) is
    PROC_NAME                  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROCESS_TRANS_EXPORT_TO_TELCO';
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';
        
    l_event_object_tab         t_entity_tab;
    
    l_event_tab                com_api_type_pkg.t_number_tab;
    l_entity_tab               com_api_type_pkg.t_dict_tab;
    l_transactions_unloading   com_api_type_pkg.t_number_tab;

    l_param_tab                com_api_type_pkg.t_param_tab;
    
    l_transactions_data_tab    acc_api_type_pkg.t_transaction_external_tab;

    l_session_file_id          com_api_type_pkg.t_long_id;
    
    l_estimated_count          com_api_type_pkg.t_long_id    := 0;
    l_processed_count          com_api_type_pkg.t_long_id    := 0;
    l_excepted_count           com_api_type_pkg.t_long_id    := 0;
    l_rejected_count           com_api_type_pkg.t_long_id    := 0;
    
    l_ref_cursor               com_api_type_pkg.t_ref_cur;
    
    l_object_tab               com_api_type_pkg.t_object_tab;
    l_sysdate                  date;
    l_start_date               date;
    l_end_date                 date;
    l_type_of_date_range       com_api_type_pkg.t_dict_value;
    
    l_increment_count          com_api_type_pkg.t_long_id;
    
    l_request_count            com_api_type_pkg.t_short_id;
    l_index                    com_api_type_pkg.t_short_id;
    
    l_full_export              com_api_type_pkg.t_boolean;
    
    l_shift_from               com_api_type_pkg.t_tiny_id        := 0;
    l_shift_to                 com_api_type_pkg.t_tiny_id        := 0;
    l_balance_type             com_api_type_pkg.t_dict_value;
    l_account_number           com_api_type_pkg.t_account_number;
    l_array_balance_type_id    com_api_type_pkg.t_medium_id;
    l_array_trans_type_id      com_api_type_pkg.t_medium_id;
    l_array_settl_type_id      com_api_type_pkg.t_medium_id;
    
    procedure put_record_to_file(
        i_transactions_data_rec    acc_api_type_pkg.t_transaction_external_rec
      , i_session_file_id          com_api_type_pkg.t_long_id
    ) is
        l_separate_char        com_api_type_pkg.t_byte_char := nvl(i_separate_char, SEPARATE_CHAR_DEFAULT);
        l_record               com_api_type_pkg.t_text;
    begin
        l_record := i_transactions_data_rec.debt_account_number || l_separate_char;
        l_record := l_record || i_transactions_data_rec.credit_account_number || l_separate_char;
        l_record := l_record || i_transactions_data_rec.credit_amount || l_separate_char;
        l_record := l_record || to_char(nvl(i_transactions_data_rec.macros_conversion_rate, 1), com_api_const_pkg.NUMBER_FORMAT) || l_separate_char;
        l_record := l_record || get_article_text(
                                    i_article => i_transactions_data_rec.oper_type
                                )
                             || ' '
                             || get_article_text(
                                    i_article => i_transactions_data_rec.oper_reason
                                )
                             || ' '
                             || to_char(
                                    i_transactions_data_rec.credit_posting_date
                                  , com_api_const_pkg.XML_DATE_FORMAT
                                )
        ;
        prc_api_file_pkg.put_line(
            i_raw_data      => l_record
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => l_record || CRLF
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end put_record_to_file;

begin
    prc_api_stat_pkg.log_start;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] date_type [#2] start_date [#3] end_date [#4] separate_char [#5] service_provider_id [#6' 
               || '], full_export [' || i_full_export
               || '], shift_from [' || l_shift_from
               || '], shift_to [' || l_shift_to
               || '], balance_type [' || l_balance_type
               || '], account_number [' || l_account_number
               || '], load_reversals [' || i_load_reversals
               || '], array_balance_type_id [' || l_array_balance_type_id
               || '], array_trans_type_id [' || l_array_trans_type_id
               || '], array_settl_type_id [' || l_array_settl_type_id
               || '], array_operations_type_id [' || i_array_operations_type_id
               || ']'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_date_type
      , i_env_param3 => i_start_date
      , i_env_param4 => i_end_date
      , i_env_param5 => i_separate_char
      , i_env_param6 => i_service_provider_id
    );
    l_type_of_date_range := com_api_sttl_day_pkg.map_date_type_dict_to_dict(
                                i_date_type    => i_date_type
                              , i_dict_map     => fcl_api_const_pkg.DATE_TYPE_DICTIONARY_TYPE
                            )
    ;
    
    l_full_export        := coalesce(i_full_export, com_api_type_pkg.FALSE);
    
    l_sysdate    := com_api_sttl_day_pkg.get_calc_date(
                        i_inst_id   => i_inst_id
                      , i_date_type => l_type_of_date_range
                    )
    ;
    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD') + nvl(l_shift_from, 0);
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND + nvl(l_shift_to, 0);
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Calculate date period - type_of_date_range [#1]  sysdate [#2] start_date [#3] end_date [#4]' 
      , i_env_param1 => l_type_of_date_range
      , i_env_param2 => l_sysdate
      , i_env_param3 => l_start_date
      , i_env_param4 => l_end_date
    );
    
    if l_full_export = com_api_const_pkg.TRUE then
        if i_service_provider_id is not null then
            l_object_tab(1).level_type  := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
            l_object_tab(1).entity_type := pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER;
            l_object_tab(1).object_id   := num_tab_tpt(i_service_provider_id);
        end if;
        
        acc_api_external_pkg.get_transactions_data(
            i_inst_id                   => i_inst_id
          , i_date_type                 => i_date_type
          , i_start_date                => l_start_date
          , i_end_date                  => l_end_date
          , i_balance_type              => l_balance_type
          , i_account_number            => l_account_number
          , i_load_reversals            => i_load_reversals
          , i_object_tab                => l_object_tab
          , i_array_balance_type_id     => l_array_balance_type_id
          , i_array_trans_type_id       => l_array_trans_type_id
          , i_array_settl_type_id       => l_array_settl_type_id
          , i_array_operations_type_id  => i_array_operations_type_id
          , i_mask_error                => com_api_const_pkg.TRUE
          , o_row_count                 => l_estimated_count
          , o_ref_cursor                => l_ref_cursor
        );
        
        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_estimated_count
        );
        
        if l_estimated_count > 0 then
            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_session_file_id
              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params       => l_param_tab
            );
            loop
                fetch l_ref_cursor bulk collect into l_transactions_data_tab
                limit BULK_LIMIT;
                for i in 1..l_transactions_data_tab.count loop
                    put_record_to_file(
                        i_transactions_data_rec => l_transactions_data_tab(i)
                      , i_session_file_id       => l_session_file_id
                    );
                    l_processed_count := l_processed_count + 1;
                end loop;
                exit when l_ref_cursor%notfound;
            end loop;
            close l_ref_cursor;
        end if;
    elsif l_full_export = com_api_const_pkg.FALSE then
        add_objects_in_tab(
            i_inst_id              => i_inst_id
          , i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ENTRY
          , i_proc_name            => PROC_NAME
          , i_sysdate              => l_sysdate
          , io_event_object_tab    => l_event_object_tab
          , io_entity_tab          => l_entity_tab
        );
        add_objects_in_tab(
            i_inst_id              => i_inst_id
          , i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
          , i_proc_name            => PROC_NAME
          , i_sysdate              => l_sysdate
          , io_event_object_tab    => l_event_object_tab
          , io_entity_tab          => l_entity_tab
        );
        if l_event_object_tab.count = 0 then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'The requested data [#1] was not found'
              , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
            );
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
        else
            for i in l_entity_tab.first .. l_entity_tab.last loop
                trc_log_pkg.debug(
                    i_text        => LOG_PREFIX || 'Incremental unload: count [#1] events  for entity [#2]'
                  , i_env_param1  => l_event_object_tab(l_entity_tab(i)).object_id.count
                  , i_env_param2  => l_entity_tab(i)
                );
            end loop;
            for i in l_entity_tab.first .. l_entity_tab.last loop
                l_request_count := ceil(l_event_object_tab(l_entity_tab(i)).object_id.count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := l_entity_tab(i);
                    l_object_tab(1).entity_type := l_entity_tab(i);
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_event_object_tab(l_entity_tab(i)).object_id.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_event_object_tab(l_entity_tab(i)).object_id(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_event_object_tab(l_entity_tab(i)).object_id(l);
                        end if;
                    end loop;
                    
                    if i_service_provider_id is not null then
                        l_index := l_object_tab.last+1;
                        l_object_tab(l_index).level_type  := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
                        l_object_tab(l_index).entity_type := pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER;
                        l_object_tab(l_index).object_id   := num_tab_tpt(i_service_provider_id);
                    end if;
                    acc_api_external_pkg.get_transactions_data(
                        i_inst_id                   => i_inst_id
                      , i_date_type                 => i_date_type
                      , i_start_date                => l_start_date
                      , i_end_date                  => l_end_date
                      , i_balance_type              => l_balance_type
                      , i_account_number            => l_account_number
                      , i_load_reversals            => i_load_reversals
                      , i_object_tab                => l_object_tab
                      , i_array_balance_type_id     => l_array_balance_type_id
                      , i_array_trans_type_id       => l_array_trans_type_id
                      , i_array_settl_type_id       => l_array_settl_type_id
                      , i_array_operations_type_id  => i_array_operations_type_id
                      , i_mask_error                => com_api_const_pkg.TRUE
                      , o_row_count                 => l_increment_count
                      , o_ref_cursor                => l_ref_cursor
                    );
                    if l_increment_count > 0 then
                        if l_session_file_id is null then
                            prc_api_file_pkg.open_file(
                                o_sess_file_id  => l_session_file_id
                              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
                              , io_params       => l_param_tab
                            );
                        end if;
                        loop
                            fetch l_ref_cursor bulk collect into l_transactions_data_tab
                            limit BULK_LIMIT;
                            
                            for m in 1..l_transactions_data_tab.count loop
                                if check_add_result_line(
                                       i_entity_type              => l_entity_tab(i)
                                     , i_transactions_data_rec    => l_transactions_data_tab(m)
                                     , i_event_object_tab         => l_event_object_tab
                                   ) = com_api_const_pkg.TRUE
                                then
                                    if l_transactions_unloading.exists(1) then
                                        l_transactions_unloading(l_transactions_unloading.last + 1) := l_transactions_data_tab(m).transaction_id;
                                    else
                                        l_transactions_unloading(1) := l_transactions_data_tab(m).transaction_id;
                                    end if;
                                    
                                    l_estimated_count := l_estimated_count + 1;
                                    
                                    add_event_collection(
                                        i_index                  => i
                                      , i_entity_tab             => l_entity_tab
                                      , i_transactions_data_rec  => l_transactions_data_tab(m)
                                      , io_event_object_tab      => l_event_object_tab
                                      , io_event_tab             => l_event_tab
                                    );
                                end if;
                            end loop;
                            exit when l_ref_cursor%notfound;
                        end loop;
                        
                        close l_ref_cursor;
                        
                    end if;
                end loop;
            end loop;
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
            if l_estimated_count > 0 then
                l_request_count := ceil(l_estimated_count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := acc_api_const_pkg.ENTITY_TYPE_TRANSACTION;
                    l_object_tab(1).entity_type := acc_api_const_pkg.ENTITY_TYPE_TRANSACTION;
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_transactions_unloading.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_transactions_unloading(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_transactions_unloading(l);
                        end if;
                    end loop;
                        
                    acc_api_external_pkg.get_transactions_data(
                        i_inst_id                   => i_inst_id
                      , i_date_type                 => i_date_type
                      , i_start_date                => l_start_date
                      , i_end_date                  => l_end_date
                      , i_balance_type              => l_balance_type
                      , i_account_number            => l_account_number
                      , i_load_reversals            => i_load_reversals
                      , i_object_tab                => l_object_tab
                      , i_array_balance_type_id     => l_array_balance_type_id
                      , i_array_trans_type_id       => l_array_trans_type_id
                      , i_array_settl_type_id       => l_array_settl_type_id
                      , i_array_operations_type_id  => i_array_operations_type_id
                      , i_mask_error                => com_api_const_pkg.TRUE
                      , o_row_count                 => l_increment_count
                      , o_ref_cursor                => l_ref_cursor
                    );
                        
                    if l_increment_count > 0 then
                        if l_session_file_id is null then
                            prc_api_file_pkg.open_file(
                                o_sess_file_id  => l_session_file_id
                              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
                              , io_params       => l_param_tab
                            );
                        end if;
                        loop
                            fetch l_ref_cursor bulk collect into l_transactions_data_tab
                            limit BULK_LIMIT;
                            for m in 1..l_transactions_data_tab.count loop
                                put_record_to_file(
                                    i_transactions_data_rec => l_transactions_data_tab(m)
                                  , i_session_file_id       => l_session_file_id
                                );
                                        
                                l_processed_count := l_processed_count + 1;
                            end loop;
                            exit when l_ref_cursor%notfound;
                        end loop;
                        close l_ref_cursor;
                    end if;
                end loop;
            end if;
        end if;
    end if;
    
    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;
    add_not_used_event_collection(
        i_entity_tab               => l_entity_tab
      , io_event_object_tab        => l_event_object_tab
      , io_event_tab               => l_event_tab
    );
    if l_event_tab.exists(1) then
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success'
    );
    
exception
    when others then
       trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'Finished with errors: [#1]'
          , i_env_param1  => sqlcode
        );
        
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        l_estimated_count := nvl(l_estimated_count, 0);
        l_excepted_count  := l_estimated_count - l_processed_count;
        
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        
end process_trans_export_to_telco;

procedure process_fees_to_t24_csv(
    i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_full_export              in  com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type                in  com_api_type_pkg.t_dict_value
  , i_start_date               in  date                                default null
  , i_end_date                 in  date                                default null
  , i_separate_char            in  com_api_type_pkg.t_byte_char        default ','
) is
    PROC_NAME             constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROCESS_FEES_TO_T24_CSV';
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';

    DEFAULT_BULK_LIMIT    constant com_api_type_pkg.t_count      := 2000;
    l_bulk_limit                   com_api_type_pkg.t_count      := DEFAULT_BULK_LIMIT;

    l_full_export                  com_api_type_pkg.t_boolean    := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_param_tab                    com_api_type_pkg.t_param_tab;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_estimated_count              com_api_type_pkg.t_long_id    := 0;
    l_processed_count              com_api_type_pkg.t_long_id    := 0;
    l_excepted_count               com_api_type_pkg.t_long_id    := 0;
    l_rejected_count               com_api_type_pkg.t_long_id    := 0;
    l_sysdate                      date;
    l_start_date                   date;
    l_end_date                     date;
    l_type_of_date_range           com_api_type_pkg.t_dict_value;
    l_record                       com_api_type_pkg.t_text;
    l_thread_number                com_api_type_pkg.t_tiny_id;

    cur_objects                    sys_refcursor;
    l_last_oper_id                 com_api_type_pkg.t_long_id;
    

    l_event_object_id_tab          com_api_type_pkg.t_number_tab;
    l_oper_id_tab                  com_api_type_pkg.t_long_tab;
    l_is_reversal_tab              com_api_type_pkg.t_boolean_tab;
    l_oper_date_tab                com_api_type_pkg.t_date_tab;
    l_debit_amount_tab             com_api_type_pkg.t_money_tab;
    l_debit_currency_tab           com_api_type_pkg.t_dict_tab;
    l_debit_account_id_tab         com_api_type_pkg.t_medium_tab;
    l_bunch_id_tab                 com_api_type_pkg.t_long_tab;
    l_credit_amount_tab            com_api_type_pkg.t_money_tab;
    l_credit_currency_tab          com_api_type_pkg.t_dict_tab;
    l_credit_conversion_rate_tab   com_api_type_pkg.t_number_tab;
    l_credit_account_id_tab        com_api_type_pkg.t_medium_tab;

    -- Function returns a reference for a cursor with operations being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor, inst_id='||i_inst_id||',  for all card instances those are processed...');

        if i_full_export = com_api_type_pkg.TRUE then
            -- Get all operations in period
            open o_cursor for
                select to_number(null)     as event_object_id
                     , o.id                as oper_id
                     , o.is_reversal       as is_reversal
                     , o.oper_date         as oper_date
                     , de.amount           as debit_amount
                     , de.currency         as debit_currency
                     , de.account_id       as debit_account_id
                     , de.bunch_id         as bunch_id
                     , ce.amount           as credit_amount
                     , ce.currency         as credit_currency
                     , cm.conversion_rate  as credit_conversion_rate
                     , ce.account_id       as credit_account_id
                  from opr_operation o
                     , acc_macros    dm
                     , acc_entry     de
                     , acc_macros    cm
                     , acc_entry     ce
                 where trunc(o.oper_date) between l_start_date and l_end_date
                   and o.status           = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                   -- Debit entry
                   and dm.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and dm.object_id       = o.id
                   and dm.macros_type_id in (
                                             select numeric_value
                                               from com_array_element
                                              where array_id = cst_amk_const_pkg.ARRAY_FEE_SHARING_MACROS_TYPES
                                            )
                   and de.macros_id       = dm.id
                   and de.split_hash     in (select split_hash from com_api_split_map_vw)
                   and de.balance_type    = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                   and de.balance_impact  = com_api_const_pkg.DEBIT
                   -- Credit entry
                   and cm.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and cm.object_id       = o.id
                   and cm.macros_type_id in (
                                             select numeric_value
                                               from com_array_element
                                              where array_id = cst_amk_const_pkg.ARRAY_FEE_SHARING_MACROS_TYPES
                                            )
                   and ce.macros_id       = cm.id
                   and ce.split_hash     in (select split_hash from com_api_split_map_vw)
                   and ce.balance_type    = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                   and ce.balance_impact  = com_api_const_pkg.CREDIT
                   and ce.bunch_id        = de.bunch_id
                 order by o.id;

        else
            -- Get operations by events
            open o_cursor for
                select /*+ ordered use_nl(sm, eo, o, dm, de, cm, ce) full(sm) index(eo evt_event_object_status) index(o opr_operation_pk)
                           index(dm acc_macros_object_ndx) index(de acc_entry_macros_ndx)
                           index(cm acc_macros_object_ndx) index(ce acc_entry_macros_ndx) */
                       eo.id               as event_object_id
                     , o.id                as oper_id
                     , o.is_reversal       as is_reversal
                     , o.oper_date         as oper_date
                     , de.amount           as debit_amount
                     , de.currency         as debit_currency
                     , de.account_id       as debit_account_id
                     , de.bunch_id         as bunch_id
                     , ce.amount           as credit_amount
                     , ce.currency         as credit_currency
                     , cm.conversion_rate  as credit_conversion_rate
                     , ce.account_id       as credit_account_id
                  from com_split_map    sm
                     , evt_event_object eo
                     , opr_operation o
                     , acc_macros    dm
                     , acc_entry     de
                     , acc_macros    cm
                     , acc_entry     ce
                 where l_thread_number in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_AMK_PRC_OUTGOING_PKG.PROCESS_FEES_TO_T24_CSV'
                   and decode(eo.status, 'EVST0001', eo.split_hash,     null) = sm.split_hash
                   and eo.eff_date              <= l_sysdate
                   and eo.entity_type            = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and (
                           eo.inst_id   = i_inst_id 
                           or i_inst_id = ost_api_const_pkg.DEFAULT_INST
                           or i_inst_id is null
                       )
                   and o.id               = eo.object_id
                   and o.status           = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                   -- Debit entry
                   and dm.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and dm.object_id       = o.id
                   and (
                           select/*+ index(el com_array_element_array_id_ndx) */ count(1)
                             from com_array_element el
                            where el.array_id      = cst_amk_const_pkg.ARRAY_FEE_SHARING_MACROS_TYPES
                              and el.numeric_value = dm.macros_type_id
                              and rownum           = 1
                       ) != 0
                   and de.macros_id       = dm.id
                   and de.balance_type    = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                   and de.balance_impact  = com_api_const_pkg.DEBIT
                   -- Credit entry
                   and cm.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and cm.object_id       = o.id
                   and (
                           select/*+ index(el com_array_element_array_id_ndx) */ count(1)
                             from com_array_element el
                            where el.array_id      = cst_amk_const_pkg.ARRAY_FEE_SHARING_MACROS_TYPES
                              and el.numeric_value = cm.macros_type_id
                              and rownum           = 1
                       ) != 0
                   and ce.macros_id       = cm.id
                   and ce.balance_type    = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                   and ce.balance_impact  = com_api_const_pkg.CREDIT
                   and ce.bunch_id        = de.bunch_id
                 order by o.id;

        end if;

        trc_log_pkg.debug('Cursor was opened...');
    end open_cur_objects;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - inst_id [#1], full export [#2], date_type [#3], start_date [#4], end_date [#5], separate_char [#6]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => l_full_export
      , i_env_param3 => i_date_type
      , i_env_param4 => to_char(i_start_date, 'dd-mon-yyyy hh24:mi:ss')
      , i_env_param5 => to_char(i_end_date, 'dd-mon-yyyy hh24:mi:ss')
      , i_env_param6 => i_separate_char
    );

    l_type_of_date_range :=
        com_api_sttl_day_pkg.map_date_type_dict_to_dict(
            i_date_type    => i_date_type
          , i_dict_map     => fcl_api_const_pkg.DATE_TYPE_DICTIONARY_TYPE
        );

    l_sysdate :=
        com_api_sttl_day_pkg.get_calc_date(
            i_inst_id   => i_inst_id
          , i_date_type => l_type_of_date_range
        );

    l_thread_number := get_thread_number;

    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Date period: type_of_date_range [#1], sysdate [#2], start_date [#3], end_date [#4]' 
      , i_env_param1 => l_type_of_date_range
      , i_env_param2 => to_char(l_sysdate, 'dd-mon-yyyy hh24:mi:ss')
      , i_env_param3 => to_char(l_start_date, 'dd-mon-yyyy hh24:mi:ss')
      , i_env_param4 => to_char(l_end_date, 'dd-mon-yyyy hh24:mi:ss')
    );

    open_cur_objects(
        o_cursor      => cur_objects
      , i_full_export => l_full_export
      , i_inst_id     => i_inst_id
    );

    loop
        fetch cur_objects
         bulk collect
         into l_event_object_id_tab
            , l_oper_id_tab
            , l_is_reversal_tab
            , l_oper_date_tab
            , l_debit_amount_tab
            , l_debit_currency_tab
            , l_debit_account_id_tab
            , l_bunch_id_tab
            , l_credit_amount_tab
            , l_credit_currency_tab
            , l_credit_conversion_rate_tab
            , l_credit_account_id_tab
        limit l_bulk_limit;

        for i in 1 .. l_oper_id_tab.count loop

            -- Cursor is sorted by "oper_id"
            if l_last_oper_id is null or l_oper_id_tab(i) != l_last_oper_id then

                l_last_oper_id := l_oper_id_tab(i);

                for rc in (
                    select (select a.agent_number
                              from acq_merchant m
                                 , prd_contract c
                                 , ost_agent a
                             where c.id = m.contract_id
                               and a.id = c.agent_id
                               and m.merchant_number = 
                                       (select oo1.merchant_number
                                          from opr_operation oo1
                                         where oo1.id = t.original_id
                                       )
                           ) as branch_id
                         , t.debit_credit
                         , t.pl_category
                         , t.account_number
                         , t.amount
                         , t.currency
                         , t.oper_id
                         , t.oper_date
                         , (select nvl(oo1.host_date, oo1.host_date)
                              from opr_operation oo1
                             where oo1.id = t.original_id
                           ) as host_date
                         , t.iso_oper_date
                         , (select nvl(substr(oo1.originator_refnum, -6), oo1.id)
                              from opr_operation oo1
                             where oo1.id = t.original_id
                           ) as orig_ref_num
                         , t.account_type
                      from (
                            select decode(src.account_type
                                         , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL, cst_amk_const_pkg.DEBIT
                                         , cst_amk_const_pkg.CREDIT
                                         ) as debit_credit
                                 , decode(src.account_type
                                         , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL, substr(src.account_number, 1, instr(src.account_number, '-')-1)
                                         , substr(trg.account_number, 1, instr(trg.account_number, '-')-1)
                                         ) as pl_category
                                 , decode(src.account_type
                                         , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL, trg.account_number
                                         , src.account_number
                                         ) as account_number
                                 , decode(src.account_type
                                         , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL, l_credit_amount_tab(i)
                                         , l_debit_amount_tab(i)
                                         ) as amount
                                 , decode(src.account_type
                                         , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL, l_credit_currency_tab(i)
                                         , l_debit_currency_tab(i)
                                         ) as currency
                                 , l_oper_id_tab(i) as oper_id
                                 , l_oper_date_tab(i) as oper_date
                                 , nvl(
                                        (select o.original_id
                                           from table(
                                                      cast(
                                                           dsp_ui_dispute_search_pkg.get_dispute_info(
                                                               i_oper_id  => l_oper_id_tab(i)
                                                             , i_match_id => null
                                                             , i_lang     => com_api_const_pkg.LANGUAGE_ENGLISH  -- 'LANGENG'
                                                           ) as dsp_ui_dispute_info_tpt
                                                      )
                                                ) o
                                          where o.oper_type = opr_api_const_pkg.OPERATION_TYPE_FEE_DEBIT  -- 'OPTP0029'
                                        )
                                      , l_oper_id_tab(i)
                                   ) as original_id
                                 , to_char(l_oper_date_tab(i), 'mmddhh24miss') as iso_oper_date
                                 , decode(l_is_reversal_tab(i)
                                         , 0
                                         , decode(trg.account_type
                                                 , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGENT,  cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGENT
                                                 , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGGR,   cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGGR
                                                 , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER
                                                 , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL,     decode(src.account_type
                                                                                                         , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER
                                                                                                         , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_OTHER
                                                                                                         )
                                                 , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_OTHER
                                                 )
                                         , decode(src.account_type
                                                  , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGENT,  cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGENT
                                                  , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGGR,   cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGGR
                                                  , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER
                                                  , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL,     decode(src.account_type
                                                                                                          , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER
                                                                                                          , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_OTHER
                                                                                                          )
                                                  , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_OTHER
                                                 )
                                         ) as account_type 
                              from (select l_debit_amount_tab(i)
                                         , l_debit_currency_tab(i)
                                         , l_oper_id_tab(i)
                                         , l_debit_account_id_tab(i)
                                         , l_bunch_id_tab(i)
                                         , aa.agent_id
                                         , aa.account_number
                                         , oa.agent_number
                                         , pc.contract_type
                                         , decode(pc.contract_type
                                                 , cst_amk_const_pkg.CONTRACT_TYPE_AGNT,  cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGENT
                                                 , cst_amk_const_pkg.CONTRACT_TYPE_PMAG,  cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGGR
                                                 , cst_amk_const_pkg.CONTRACT_TYPE_PMPR,  cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER
                                                 , null,                                  decode(aa.account_type
                                                                                                , cst_amk_const_pkg.ACCOUNT_TYPE_BILL, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL
                                                                                                , cst_amk_const_pkg.ACCOUNT_TYPE_AGTE, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL
                                                                                                , cst_amk_const_pkg.ACCOUNT_TYPE_EXPE, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL
                                                                                                , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_OTHER
                                                                                                )
                                                 , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_OTHER
                                                 ) as account_type
                                      from acc_account aa
                                         , ost_agent oa
                                         , prd_contract pc
                                     where aa.id = l_debit_account_id_tab(i)
                                       and oa.id(+) = aa.agent_id
                                       and pc.id(+) = aa.contract_id
                                   ) src
                                 , (select l_credit_amount_tab(i)
                                         , l_credit_currency_tab(i)
                                         , l_credit_conversion_rate_tab(i)
                                         , l_oper_id_tab(i)
                                         , l_credit_account_id_tab(i)
                                         , l_bunch_id_tab(i)
                                         , aa.agent_id
                                         , aa.account_number
                                         , oa.agent_number
                                         , pc.contract_type
                                         , decode(pc.contract_type
                                                 , cst_amk_const_pkg.CONTRACT_TYPE_AGNT,  cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGENT
                                                 , cst_amk_const_pkg.CONTRACT_TYPE_PMAG,  cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_AGGR
                                                 , cst_amk_const_pkg.CONTRACT_TYPE_PMPR,  cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_BILLER
                                                 , null,                                  decode(aa.account_type
                                                                                                , cst_amk_const_pkg.ACCOUNT_TYPE_BILL, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL
                                                                                                , cst_amk_const_pkg.ACCOUNT_TYPE_AGTE, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL
                                                                                                , cst_amk_const_pkg.ACCOUNT_TYPE_EXPE, cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_GL
                                                                                                , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_OTHER
                                                                                                )
                                                 , cst_amk_const_pkg.EXTERNAL_ACCOUNT_TYPE_OTHER
                                                 ) as account_type
                                      from acc_account aa 
                                         , ost_agent oa 
                                         , prd_contract pc
                                     where aa.id = l_credit_account_id_tab(i)
                                       and oa.id(+) = aa.agent_id
                                       and pc.id(+) = aa.contract_id
                                   ) trg
                           ) t
                ) loop

                    if l_session_file_id is null then
                        prc_api_file_pkg.open_file(
                            o_sess_file_id  => l_session_file_id
                          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
                          , io_params       => l_param_tab
                        );
                    end if;

                    l_record := rc.branch_id || i_separate_char;
                    l_record := l_record || rc.debit_credit || i_separate_char;
                    l_record := l_record || rc.pl_category || i_separate_char;
                    l_record := l_record || rc.account_number || i_separate_char;
                    l_record := l_record || rc.currency || i_separate_char;
                    l_record := l_record || to_char(rc.amount) || i_separate_char;
                    l_record := l_record || to_char(rc.oper_id) || i_separate_char;
                    l_record := l_record || to_char(rc.orig_ref_num) || i_separate_char;
                    l_record := l_record || to_char(rc.host_date, 'mmddhh24miss') || i_separate_char;
                    l_record := l_record || rc.account_type;
                    
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_record
                      , i_sess_file_id  => l_session_file_id
                    );
                    prc_api_file_pkg.put_file(
                        i_sess_file_id   => l_session_file_id
                      , i_clob_content   => l_record || CRLF
                      , i_add_to         => com_api_const_pkg.TRUE
                    );
                    
                    l_processed_count := l_processed_count + 1;
                end loop;
            end if;

        end loop;

        exit when cur_objects%notfound;
    end loop;

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    if l_full_export = com_api_type_pkg.FALSE then
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_object_id_tab
        );
    end if;

    l_estimated_count := l_processed_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished successfully'
    );

exception
  when others then
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Finished with errors: [#1]'
      , i_env_param1  => sqlcode
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end process_fees_to_t24_csv;

end cst_amk_prc_outgoing_pkg;
/
