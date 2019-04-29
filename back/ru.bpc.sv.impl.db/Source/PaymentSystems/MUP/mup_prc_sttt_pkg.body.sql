create or replace package body mup_prc_sttt_pkg is

    procedure enum_fpd_for_process (
        io_fpd_cur               in out sys_refcursor
      , i_network_id             in com_api_type_pkg.t_tiny_id
    ) is
    begin
        open io_fpd_cur for
            select id
                 , network_id
                 , inst_id
                 , file_id
                 , status
                 , mti
                 , de024
                 , de025
                 , de026
                 , de049
                 , de050
                 , de071
                 , de093
                 , de100
                 , p0148
                 , p0165
                 , p0300
                 , p0302
                 , p0369
                 , p0370_1
                 , p0370_2
                 , p0372_1
                 , p0372_2
                 , p0374
                 , p0375
                 , p0378
                 , p0380_1
                 , p0380_2
                 , p0381_1
                 , p0381_2
                 , p0384_1
                 , p0384_2
                 , p0390_1
                 , p0390_2
                 , p0391_1
                 , p0391_2
                 , p0392
                 , p0393
                 , p0394_1
                 , p0394_2
                 , p0395_1
                 , p0395_2
                 , p0396_1
                 , p0396_2
                 , p0400
                 , p0401
                 , p0402
                 , p2358_1
                 , p2358_2
                 , p2358_3
                 , p2358_4
                 , p2358_5
                 , p2358_6
                 , p2359_1
                 , p2359_2
                 , p2359_3
                 , p2359_4
                 , p2359_5
                 , p2359_6
                 , 0
              from mup_fpd
             where decode(status, 'CLMS0040', network_id, null) = i_network_id
               and de025 != '6862'
        --    for update
        union
            select min(id)
                 , min(network_id)
                 , min(inst_id)
                 , file_id
                 , min(status)
                 , min(mti)
                 , min(de024)
                 , de025
                 , min(de026)
                 , de049
                 , de050
                 , min(de071)
                 , de093
                 , min(de100)
                 , min(p0148)
                 , p0165
                 , min(p0300)
                 , min(p0302)
                 , min(p0369)
                 , min(p0370_1)
                 , min(p0370_2)
                 , p0372_1
                 , p0372_2
                 , p0374
                 , min(p0375)
                 , p0378
                 , min(p0380_1)
                 , sum(p0380_2)
                 , min(p0381_1)
                 , sum(p0381_2)
                 , min(p0384_1)
                 , min(p0384_2)
                 , min(p0390_1)
                 , sum(p0390_2)
                 , min(p0391_1)
                 , sum(p0391_2)
                 , min(p0392)
                 , min(p0393)
                 , min(p0394_1)
                 , sum(p0394_2)
                 , p0395_1
                 , sum(p0395_2)
                 , min(p0396_1)
                 , min(p0396_2)
                 , sum(p0400)
                 , sum(p0401)
                 , min(p0402)
                 , min(p2358_1)
                 , min(p2358_2)
                 , min(p2358_3)
                 , min(p2358_4)
                 , min(p2358_5)
                 , p2358_6
                 , min(p2359_1)
                 , min(p2359_2)
                 , min(p2359_3)
                 , min(p2359_4)
                 , min(p2359_5)
                 , min(p2359_6)
                 , 1
              from mup_fpd
             where decode(status, 'CLMS0040', network_id, null) = i_network_id
               and de025 = '6862'
             group by de050, de025, de049, de093, p0165, p0372_1, p0372_2, p0374, p0378, p0395_1, p2358_6, file_id
             ;

    end enum_fpd_for_process;

    procedure enum_fsum_for_process (
        io_fsum_cur              in out sys_refcursor
      , i_network_id             in com_api_type_pkg.t_tiny_id
    ) is
    begin
        open io_fsum_cur for
            select
                t.id
                , t.network_id
                , t.inst_id
                , t.file_id
                , t.status
                , t.mti
                , t.de024
                , t.de025
                , t.de049
                , t.de071
                , t.de093
                , t.de100
                , t.p0148
                , t.p0300
                , t.p0380_1
                , t.p0380_2
                , t.p0381_1
                , t.p0381_2
                , t.p0384_1
                , t.p0384_2
                , t.p0400
                , t.p0401
                , t.p0402
                , 0
            from
                mup_fsum t
                , mup_file f
            where
                t.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                and t.network_id = i_network_id
                and t.file_id = f.id
                and de025 != '6862'
        union
            select
                min(t.id)
                , min(t.network_id)
                , min(t.inst_id)
                , t.file_id
                , min(t.status)
                , min(t.mti)
                , min(t.de024)
                , t.de025
                , t.de049
                , min(t.de071)
                , t.de093
                , min(t.de100)
                , min(t.p0148)
                , min(t.p0300)
                , min(t.p0380_1)
                , sum(t.p0380_2)
                , min(t.p0381_1)
                , sum(t.p0381_2)
                , min(t.p0384_1)
                , min(t.p0384_2)
                , sum(t.p0400)
                , sum(t.p0401)
                , min(t.p0402)
                , 1
            from
                mup_fsum t
                , mup_file f
            where
                t.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                and t.network_id = i_network_id
                and t.file_id = f.id
                and de025 = '6862'
              group by de025, de049, de093, file_id                
        ;                        
            --for update;
            
    end enum_fsum_for_process;

    procedure open_fpd_fin_cursor(
        i_fpd_rec                in     mup_api_type_pkg.t_fpd_rec
      , o_cursor                    out sys_refcursor
      , i_network_id             in     com_api_type_pkg.t_tiny_id
      , io_original_file_id_tab  in out com_api_type_pkg.t_number_tab
    ) is
        DUMMY_CHAR         constant com_api_type_pkg.t_name      := '*';
        l_file_id                   com_api_type_pkg.t_short_id;
        l_is_incoming               com_api_type_pkg.t_boolean;
        l_fpd_file_p105             mup_api_type_pkg.t_p0105;
    begin
        if i_fpd_rec.de025     = mup_api_const_pkg.FPD_REASON_NOTIFICATION    then
            l_is_incoming     := com_api_type_pkg.TRUE;
        elsif i_fpd_rec.de025  = mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT then
            l_is_incoming     := com_api_type_pkg.FALSE;
        end if;

        if i_fpd_rec.de049 is null then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_MANDATORY_RECONCIL_CATEGORY_EMPTY'
                , i_env_param1  => 'DE049'
            );
        elsif i_fpd_rec.de050 is null then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_MANDATORY_RECONCIL_CATEGORY_EMPTY'
                , i_env_param1  => 'DE050'
            );
        elsif i_fpd_rec.p0300 is null then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_MANDATORY_RECONCIL_CATEGORY_EMPTY'
                , i_env_param1  => 'P0300'
            );
        end if;

        if i_fpd_rec.p0375 is not null
           and l_is_incoming = com_api_type_pkg.FALSE
           and (
               i_fpd_rec.p0374 in (
                   mup_api_const_pkg.PROC_CODE_P2P_CREDIT -- '26'
                 , mup_api_const_pkg.PROC_CODE_CASH_IN    -- '27'
                 , mup_api_const_pkg.PROC_CODE_PAYMENT    -- '28'
               )
               or
               (
                   i_fpd_rec.p0372_1     = mup_api_const_pkg.MSG_TYPE_PRESENTMENT
                   and i_fpd_rec.p0372_2 = mup_api_const_pkg.FUNC_CODE_ADJUSTMENT
               )
           )
        then
            l_file_id := null;
        else
            begin
                select p0105
                  into l_fpd_file_p105
                  from mup_file f
                 where id = i_fpd_rec.file_id;
            exception
                when others then
                    com_api_error_pkg.raise_error(
                        i_error         => 'MUP_CANNOT_FIND_ORIGINAL_FILE'
                        , i_env_param1  => i_fpd_rec.p0300
                    );
            end;

            begin
                -- for fpd with several cycle files use p0105 from fpd file
                select f.id
                  into l_file_id
                  from mup_file f
                 where f.p0105       = decode(i_fpd_rec.de025
                                            , mup_api_const_pkg.FPD_REASON_NOTIFICATION,    decode(substr(l_fpd_file_p105, 21, 2), '99', l_fpd_file_p105, i_fpd_rec.p0300)
                                            , mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT, i_fpd_rec.p0300
                                       )
                   and f.network_id  = i_fpd_rec.network_id
                   and f.is_incoming = l_is_incoming;

                if l_is_incoming = com_api_const_pkg.FALSE then
                    io_original_file_id_tab(io_original_file_id_tab.count + 1) := l_file_id;
                end if;

            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error         => 'MUP_CANNOT_FIND_ORIGINAL_FILE'
                        , i_env_param1  => i_fpd_rec.p0300
                    );

                when too_many_rows then
                    com_api_error_pkg.raise_error(
                        i_error         => 'MUP_TOO_MANY_ORIGINAL_FILES'
                        , i_env_param1  => i_fpd_rec.p0300
                    );
            end;
        end if;

        if i_fpd_rec.p0375 is not null then
            -- Main case when used the good index with the "p0375" field
            open o_cursor for
                select f.rowid
                     , f.id
                     , f.impact
                     , f.is_incoming
                     , f.mti
                     , (
                           select iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                             from mup_card c
                            where c.id = f.id
                       ) as de002
                     , f.de004
                     , f.de005
                     , f.p0146_net
                 from mup_fin f
                where f.p0375          = i_fpd_rec.p0375
                  and (f.file_id+0     = l_file_id       or l_file_id is null)  -- disable index for the "file_id, network_id" fields
                  and f.network_id     = i_network_id
                  and f.is_incoming    = l_is_incoming
                  and f.is_rejected    = com_api_type_pkg.FALSE
                  and f.is_fpd_matched = com_api_type_pkg.FALSE
                  and f.de049          = i_fpd_rec.de049
                  and f.de003_1        = i_fpd_rec.p0374
                  and (l_is_incoming   = com_api_type_pkg.TRUE and f.de093 = i_fpd_rec.de093 or l_is_incoming = com_api_type_pkg.FALSE)
                  and (
                          l_is_incoming = com_api_type_pkg.FALSE
                          or (
                                     f.p2158_2 = i_fpd_rec.p2358_2
                                 and f.p2158_5 = i_fpd_rec.p2358_5
                                 and f.p2158_6 = i_fpd_rec.p2358_6
                             )
                      )
                  and (i_fpd_rec.p0165   is null or substr(f.p0165, 1, 1) = substr(i_fpd_rec.p0165, 1, 1))
                  and (i_fpd_rec.p0372_1 is null or f.mti     = i_fpd_rec.p0372_1)
                  and (i_fpd_rec.p0372_2 is null or f.de024   = i_fpd_rec.p0372_2)
                  and (f.p2159_5         is null or f.p2159_5 = substr(i_fpd_rec.p0300, 21, 2))
                  and (
                          (
                              i_fpd_rec.p0378  = mup_api_const_pkg.REVERSAL_PDS_ORIGINAL 
                              and (f.p0025_1  is null or f.p0025_1 = mup_api_const_pkg.REVERSAL_PDS_CANCEL)
                          )
                      or 
                          (
                              i_fpd_rec.p0378  = mup_api_const_pkg.REVERSAL_PDS_REVERSAL
                              and f.p0025_1    = mup_api_const_pkg.REVERSAL_PDS_REVERSAL
                          )
                      )
                  and (
                          nvl(i_fpd_rec.de025, DUMMY_CHAR) != mup_api_const_pkg.FPD_REASON_NOTIFICATION
                          or f.de050 = i_fpd_rec.de050
                      )
                  for update;

        else
            -- Alternate case when used the index with the "file_id, network_id" fields
            open o_cursor for
                select f.rowid
                     , f.id
                     , f.impact
                     , f.is_incoming
                     , f.mti
                     , (
                           select iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                             from mup_card c
                            where c.id = f.id
                       ) as de002
                     , f.de004
                     , f.de005
                     , f.p0146_net
                 from mup_fin f
                where f.file_id        = l_file_id
                  and f.network_id     = i_network_id
                  and f.is_incoming    = l_is_incoming
                  and f.is_rejected    = com_api_type_pkg.FALSE
                  and f.is_fpd_matched = com_api_type_pkg.FALSE
                  and f.de049          = i_fpd_rec.de049
                  and f.de003_1        = i_fpd_rec.p0374
                  and (l_is_incoming   = com_api_type_pkg.TRUE and f.de093 = i_fpd_rec.de093 or l_is_incoming = com_api_type_pkg.FALSE)
                  and (
                          l_is_incoming = com_api_type_pkg.FALSE
                          or (
                                     f.p2158_2 = i_fpd_rec.p2358_2
                                 and f.p2158_5 = i_fpd_rec.p2358_5
                                 and f.p2158_6 = i_fpd_rec.p2358_6
                             )
                      )
                  and (i_fpd_rec.p0165   is null or substr(f.p0165, 1, 1) = substr(i_fpd_rec.p0165, 1, 1))
                  and (i_fpd_rec.p0372_1 is null or f.mti     = i_fpd_rec.p0372_1)
                  and (i_fpd_rec.p0372_2 is null or f.de024   = i_fpd_rec.p0372_2)
                  and (f.p2159_5         is null or f.p2159_5 = substr(i_fpd_rec.p0300, 21, 2))
                  and (
                          (
                              i_fpd_rec.p0378  = mup_api_const_pkg.REVERSAL_PDS_ORIGINAL 
                              and (f.p0025_1  is null or f.p0025_1 = mup_api_const_pkg.REVERSAL_PDS_CANCEL)
                          )
                      or 
                          (
                              i_fpd_rec.p0378  = mup_api_const_pkg.REVERSAL_PDS_REVERSAL
                              and f.p0025_1    = mup_api_const_pkg.REVERSAL_PDS_REVERSAL
                          )
                      )
                  and (
                          nvl(i_fpd_rec.de025, DUMMY_CHAR) != mup_api_const_pkg.FPD_REASON_NOTIFICATION
                          or f.de050 = i_fpd_rec.de050
                      )
                  for update;

        end if;

    end open_fpd_fin_cursor;

    procedure open_perf_fpd_fin_cursor (
        i_fpd_id                 in com_api_type_pkg.t_long_id
      , o_cursor                out sys_refcursor
    ) is
    begin
        open o_cursor for
            select f.rowid
                 , f.id
                 , f.impact
                 , f.is_incoming
                 , f.mti
                 , (
                       select iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                         from mup_card c
                        where c.id = f.id
                   ) as de002
                 , f.de004
                 , f.de005
                 , f.p0146_net
              from mup_fin f
             where f.fpd_id = i_fpd_id;

    end open_perf_fpd_fin_cursor;

    procedure build_fsum_fin_where (
        i_fsum_rec         in     mup_api_type_pkg.t_fsum_rec
      , o_statement           out com_api_type_pkg.t_text
      , l_fin_tab_alias    in     com_api_type_pkg.t_short_desc
    ) is
        l_file_id                 com_api_type_pkg.t_short_id;
        l_is_incoming             com_api_type_pkg.t_boolean;
        l_where_stmt              com_api_type_pkg.t_text;
        l_fsum_file_p105           mup_api_type_pkg.t_p0105;        
    begin
        l_where_stmt := l_fin_tab_alias || 'is_rejected=' || com_api_type_pkg.FALSE;

        if i_fsum_rec.de025 = mup_api_const_pkg.FPD_REASON_NOTIFICATION then
            l_is_incoming := com_api_type_pkg.TRUE;
            l_where_stmt := l_where_stmt || ' and ' || l_fin_tab_alias || 'de093=' || i_fsum_rec.de093;
        elsif i_fsum_rec.de025 = mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT then
            l_is_incoming := com_api_type_pkg.FALSE;
            l_where_stmt := l_where_stmt || ' and ' || l_fin_tab_alias || 'de094=' || i_fsum_rec.de093;
        end if;

        begin
            select p0105 into l_fsum_file_p105
              from mup_file f
             where id = i_fsum_rec.file_id;
           exception
            when others then
                com_api_error_pkg.raise_error(
                    i_error       => 'MUP_CANNOT_FIND_ORIGINAL_FILE'
                  , i_env_param1  => i_fsum_rec.p0300
                );
        end;

        begin
              -- for fsum with several cycle files use p0105 from fsum file
            select f.id
              into l_file_id
              from mup_file f  
             where f.p0105       = decode(i_fsum_rec.de025, '6862', decode(substr(l_fsum_file_p105, 21, 2), '99', l_fsum_file_p105, i_fsum_rec.p0300), '6861', i_fsum_rec.p0300)
               and f.network_id  = i_fsum_rec.network_id
               and f.is_incoming = l_is_incoming;

            l_where_stmt := l_where_stmt || ' and '  || l_fin_tab_alias || 'file_id=' || l_file_id;
            l_where_stmt := l_where_stmt || ' and '  || l_fin_tab_alias || 'is_incoming=' || l_is_incoming;
            l_where_stmt := l_where_stmt || ' and (' || l_fin_tab_alias || 'p2159_5 =' || substr(i_fsum_rec.p0300, 21, 2) 
                                         || ' or '   || l_fin_tab_alias || 'p2159_5 is null )';                   
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'MUP_CANNOT_FIND_ORIGINAL_FILE'
                  , i_env_param1  => i_fsum_rec.p0300
                );

            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error       => 'MUP_TOO_MANY_ORIGINAL_FILES'
                  , i_env_param1  => i_fsum_rec.p0300
                );
        end;

        l_where_stmt := l_where_stmt || ' and ' || l_fin_tab_alias || 'de049=' || i_fsum_rec.de049;
        
        o_statement := l_where_stmt;

    end build_fsum_fin_where;

    procedure init_total (
        io_total_rec            out nocopy mup_api_type_pkg.t_reconcile_total_rec
    ) is
    begin
        io_total_rec.amount_transaction := 0;
        io_total_rec.amount_reconciliation := 0;
        io_total_rec.count_transaction := 0;
        io_total_rec.count_vs_fee := 0;
        io_total_rec.rate := null;
        io_total_rec.sttl_amount := 0;
        io_total_rec.max_sttl_amount := null;
        io_total_rec.max_sttl_amount_id := null;
        io_total_rec.amount_delta := 0;
    end init_total;

    procedure process_summary (
        i_network_id             in com_api_type_pkg.t_tiny_id
    ) is
        BULK_LIMIT         constant number := 400;
        
        l_statement                 com_api_type_pkg.t_text;

        l_fsum_cur                  sys_refcursor;
        l_fin_cur                   sys_refcursor;
        
        l_total_count               com_api_type_pkg.t_long_id := 0;
        l_excepted_count            com_api_type_pkg.t_long_id := 0;
        l_incoming_count            com_api_type_pkg.t_long_id := 0;
        l_outgoing_count            com_api_type_pkg.t_long_id := 0;
        l_estimated_count           com_api_type_pkg.t_long_id := 0;
        l_skiped_count              com_api_type_pkg.t_long_id := 0;
        
        l_fsum_tab                  mup_api_type_pkg.t_fsum_tab;
        
        l_debits                    mup_api_type_pkg.t_reconcile_total_rec;
        l_credits                   mup_api_type_pkg.t_reconcile_total_rec;
        
        l_fpd_fee_found             com_api_type_pkg.t_boolean;
        l_fee_amt                   com_api_type_pkg.t_medium_id;
        l_trn_amt                   com_api_type_pkg.t_medium_id;
        
        l_ok_id                     com_api_type_pkg.t_number_tab;
        l_error_id                  com_api_type_pkg.t_number_tab;
        l_skip_id                   com_api_type_pkg.t_number_tab;
        
        l_rowid                     com_api_type_pkg.t_rowid_tab;
        l_id                        com_api_type_pkg.t_number_tab;
        l_fpd_id                    com_api_type_pkg.t_number_tab;
        l_amt_fee                   com_api_type_pkg.t_number_tab;
        l_amt_trn                   com_api_type_pkg.t_number_tab;
        l_impact                    com_api_type_pkg.t_tiny_tab;
        l_is_incoming               com_api_type_pkg.t_boolean_tab;
        l_mti                       com_api_type_pkg.t_name_tab;
        l_de002                     com_api_type_pkg.t_name_tab;
        l_de004                     com_api_type_pkg.t_number_tab;
        l_de005                     com_api_type_pkg.t_number_tab;
        l_p0146                     com_api_type_pkg.t_number_tab;
        
        l_msg_prefix                com_api_type_pkg.t_text;

        SEL_FLD_STMT       constant com_api_type_pkg.t_text :=
            'f.rowid, f.id, f.impact, f.is_incoming, f.mti, ' ||
            'iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as de002, ' ||
            'f.de004, f.de005, f.p0146_net';

        procedure build_fsum_fin_statement (
            i_fsum_rec              in mup_api_type_pkg.t_fsum_rec
            , o_statement           out com_api_type_pkg.t_text
        ) is
            l_where_stmt            com_api_type_pkg.t_text;
            l_sel_stmt              com_api_type_pkg.t_text;
        begin
            l_sel_stmt := 
                'select ' 
                  ||    SEL_FLD_STMT 
                  || ', p.id fpd_id'
                  || ', nvl(decode(p.p0395_1, '''||mup_api_const_pkg.CREDIT||''', p.p0395_2,'''||mup_api_const_pkg.DEBIT||''', -p.p0395_2, 0), 0) amt_fee'
                  || ', nvl(p.p0394_2,0) amt_trn'
                  || ' from mup_fin f, mup_fpd p, mup_card c';
            
            build_fsum_fin_where (
                i_fsum_rec        => i_fsum_rec
                , o_statement     => l_where_stmt
                , l_fin_tab_alias => 'f.'
            );

            l_where_stmt := l_where_stmt || ' and f.is_fsum_matched = ' || com_api_type_pkg.FALSE;
            l_where_stmt := l_where_stmt || ' and f.network_id = ' || i_network_id;
            l_where_stmt := l_where_stmt || ' and p.id(+) = f.fpd_id and p.p0402(+) = 1';

            o_statement := l_sel_stmt || ' where f.id = c.id(+) and ' || l_where_stmt || ' for update of f.fsum_id';
        end;
        
        procedure register_ok_summary (
            i_id                    in com_api_type_pkg.t_long_id   
        ) is
        begin
            l_ok_id(l_ok_id.count + 1) := i_id;
        end;
        
        procedure register_error_summary (
            i_id                    in com_api_type_pkg.t_long_id
        ) is
        begin
            l_error_id(l_error_id.count + 1) := i_id;
        end;
   
        procedure register_skip_summary (
            i_id                    in com_api_type_pkg.t_long_id
        ) is
        begin
            l_skip_id(l_skip_id.count + 1) := i_id;
        end;
   
        procedure mark_ok_summary is
        begin
            forall i in 1 .. l_ok_id.count
                update mup_fsum
                   set status = net_api_const_pkg.CLEARING_MSG_STATUS_MATCHED
                 where id = l_ok_id(i);

            forall i in 1 .. l_ok_id.count
                update mup_fin
                   set is_fsum_matched = com_api_type_pkg.TRUE
                 where fsum_id = l_ok_id(i);

            l_ok_id.delete;
        end;
        
        procedure mark_error_summary is
        begin
            forall i in 1 .. l_error_id.count
                update mup_fsum
                   set status = net_api_const_pkg.CLEARING_MSG_STATUS_MATCH_ERR
                 where id = l_error_id(i);
        
            l_error_id.delete;
        end;
        
        procedure mark_skip_summary is
        begin
            forall i in 1 .. l_skip_id.count
                update mup_fsum
                   set status = net_api_const_pkg.CLEARING_MSG_STATUS_MATCH_SKIP
                 where id = l_skip_id(i);

            l_skip_id.delete;
        end;
        
        procedure check_ok_summary is
        begin
            if l_ok_id.count >= BULK_LIMIT then
                mark_ok_summary;
            end if;
        end;
         
        procedure check_error_summary is
        begin
            if l_error_id.count >= BULK_LIMIT then
                mark_error_summary;
            end if;
        end;
        
        procedure check_skip_summary is
        begin
            if l_skip_id.count >= BULK_LIMIT then
                mark_skip_summary;
            end if;
        end;
        
        procedure register_ok_grouped (
            i_id                    in com_api_type_pkg.t_long_id   
        ) is
        begin  
            for rec in(
                select s.id 
                  from mup_fsum s
                     , mup_file f
                     , (select de025
                             , de049
                             , de093
                         from mup_fpd   
                        where id = i_id
                      ) f2
                 where s.de025 = f2.de025    
                   and s.de049 = f2.de049 
                   and s.de093 = f2.de093  
                   and s.file_id = f.id
                   and s.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                   and s.network_id = i_network_id
                   and s.de025 = '6862' 
            )    
            loop
                l_ok_id(l_ok_id.count + 1) := rec.id;
            end loop;        
        end;
        
        procedure register_error_grouped (
            i_id                    in com_api_type_pkg.t_long_id
        ) is
        begin
            for rec in(
                select s.id 
                  from mup_fsum s
                     , mup_file f
                     , (select de025
                             , de049
                             , de093
                         from mup_fpd   
                        where id = i_id
                      ) f2
                 where s.de025 = f2.de025    
                   and s.de049 = f2.de049 
                   and s.de093 = f2.de093  
                   and s.file_id = f.id
                   and s.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                   and s.network_id = i_network_id
                   and s.de025 = '6862' 
            )    
            loop
                l_error_id(l_error_id.count + 1) := rec.id;
            end loop;        
        end;
        
    begin
        trc_log_pkg.debug (
            i_text      => 'Settlement process started'
        );
        savepoint starting_mup_file_summary;
        
        -- estimate messages
        select sum(cnt)
          into l_estimated_count
          from (    
             select count(1) cnt
               from mup_fsum t
                  , mup_file f
              where t.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                and t.network_id = i_network_id
                and t.file_id = f.id
                and de025 != '6862'
            union all
              select 1 cnt
                from mup_fsum t
                   , mup_file f
               where t.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                 and t.network_id = i_network_id
                 and t.file_id = f.id
                 and de025 = '6862'
               group by de025, de049, de093, file_id
         );
                 
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );
        
        enum_fsum_for_process (
            io_fsum_cur     => l_fsum_cur
            , i_network_id  => i_network_id
        );
        loop
            fetch l_fsum_cur bulk collect into l_fsum_tab limit BULK_LIMIT;
            for i in 1 .. l_fsum_tab.count loop
                l_msg_prefix := 'id = ' || l_fsum_tab(i).id;
                begin
                    savepoint processing_next_fsum;
                            
                    if l_fsum_tab(i).p0300 like '112%' and l_fsum_tab(i).de025 = mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT then
                        trc_log_pkg.debug (
                            i_text         => '[#1] Reconciliation skipped, P0300 = '||l_fsum_tab(i).p0300
                            , i_env_param1 => l_msg_prefix
                        );
                    
                        register_skip_summary (
                            i_id          => l_fsum_tab(i).id
                        );

                        l_skiped_count := l_skiped_count + 1;
                    else
                            
                        if l_fsum_tab(i).de025 in (mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT, mup_api_const_pkg.FPD_REASON_NOTIFICATION) then
                            null;
                        else
                            com_api_error_pkg.raise_error(
                                i_error           => 'MUP_UNKNOWN_REASON'
                                , i_env_param1    => l_fsum_tab(i).de025
                            );
                        end if;
                            
                        build_fsum_fin_statement (
                            i_fsum_rec      => l_fsum_tab(i)
                            , o_statement   => l_statement
                        );

                        trc_log_pkg.debug (
                            i_text         => '[#1] Statement build for fin records retriving.'
                            , i_env_param1 => l_msg_prefix
                        );

                        trc_log_pkg.debug (
                            i_text      => l_statement
                        );
                        
                        init_total (
                            io_total_rec  => l_debits
                        );
                        init_total (
                            io_total_rec  => l_credits
                        );                    

                        open l_fin_cur for l_statement;
                        loop
                            fetch l_fin_cur
                            bulk collect into
                            l_rowid
                            , l_id
                            , l_impact
                            , l_is_incoming
                            , l_mti
                            , l_de002
                            , l_de004
                            , l_de005
                            , l_p0146
                            , l_fpd_id
                            , l_amt_fee
                            , l_amt_trn
                            limit BULK_LIMIT;

                            for k in 1 .. l_rowid.count loop
                                l_fpd_fee_found := com_api_type_pkg.FALSE;
                                l_fee_amt := 0;
                                l_trn_amt := 0;

                                if l_is_incoming(k) = com_api_type_pkg.TRUE then
                                    l_fee_amt := nvl(l_p0146(k), 0);
                                elsif l_fpd_id(k) is not null then
                                    l_fpd_fee_found := com_api_type_pkg.TRUE;
                                    l_fee_amt := l_amt_fee(k);
                                    l_trn_amt := l_amt_trn(k);
                                end if;

                                if l_impact(k) = com_api_type_pkg.CREDIT then
                                    l_credits.amount_transaction := l_credits.amount_transaction + nvl(l_de004(k), 0);
                                    l_credits.count_transaction := l_credits.count_transaction + 1;

                                    if
                                    (   l_is_incoming(k) = com_api_type_pkg.TRUE and
                                        (nvl(l_de005(k), 0) + l_fee_amt) <= 0
                                    ) then
                                        l_debits.count_vs_fee := l_debits.count_vs_fee + 1;

                                    elsif
                                    (   l_is_incoming(k) = com_api_type_pkg.FALSE and
                                        l_fpd_fee_found = com_api_type_pkg.TRUE and
                                        (nvl(l_trn_amt, 0) + l_fee_amt) <= 0
                                    ) then
                                        l_debits.count_vs_fee := l_debits.count_vs_fee + 1;

                                    else
                                        l_credits.count_vs_fee := l_credits.count_vs_fee + 1;
                                    end if;

                                elsif l_impact(k) = com_api_type_pkg.DEBIT then
                                    l_debits.amount_transaction := l_debits.amount_transaction + nvl(l_de004(k), 0);
                                    l_debits.count_transaction := l_debits.count_transaction + 1;

                                    if
                                    (   l_is_incoming(k) = com_api_type_pkg.TRUE and
                                        ((-nvl(l_de005(k), 0)) + l_fee_amt) > 0
                                    ) then
                                        l_credits.count_vs_fee := l_credits.count_vs_fee + 1;

                                    elsif
                                    (   l_is_incoming(k) = com_api_type_pkg.FALSE and
                                        l_fpd_fee_found = com_api_type_pkg.TRUE and
                                        ((-nvl(l_trn_amt, 0)) + l_fee_amt) > 0
                                    ) then
                                        l_credits.count_vs_fee := l_credits.count_vs_fee + 1;

                                    else
                                        l_debits.count_vs_fee := l_debits.count_vs_fee + 1;
                                    end if;
                                end if;
                            end loop;
                                
                            -- set financial position detail message identifier
                            forall k in 1 .. l_rowid.count
                                update
                                    mup_fin f
                                set
                                    f.fsum_id = l_fsum_tab(i).id
                                where
                                    f.rowid = l_rowid(k);

                            exit when l_fin_cur%notfound;
                        end loop;
                        close l_fin_cur;
                        
                        trc_log_pkg.debug (
                            i_text         => 'File summary totals:' || chr(10) || '#1#2#3#4'
                            , i_env_param1 => 'fpd.p0400=' || l_fsum_tab(i).p0400 || ' debits.count=' || l_debits.count_transaction || ' debits.count_vs_fee=' || l_debits.count_vs_fee || chr(10)
                            , i_env_param2 => 'fpd.p0401=' || l_fsum_tab(i).p0401 || ' credits.count=' || l_credits.count_transaction || ' credits.count_vs_fee=' || l_credits.count_vs_fee || chr(10)
                            , i_env_param3 => 'fpd.p0380=' || l_fsum_tab(i).p0380_2 || ' debits.amount_transaction=' || l_debits.amount_transaction || chr(10)
                            , i_env_param4 => 'fpd.p0381=' || l_fsum_tab(i).p0381_2 || ' credits.amount_transaction=' || l_credits.amount_transaction
                        );

                        if
                        (   (   l_fsum_tab(i).p0400 = l_debits.count_transaction and
                                l_fsum_tab(i).p0401 = l_credits.count_transaction
                            ) or
                            (   l_fsum_tab(i).p0400 = l_debits.count_vs_fee and
                                l_fsum_tab(i).p0401 = l_credits.count_vs_fee
                            )
                        ) then
                            null;
                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MUP_TOTALS_COUNT_NOT_EQUAL'
                            );
                        end if;

                        if l_fsum_tab(i).p0380_2 = l_debits.amount_transaction and l_fsum_tab(i).p0381_2 = l_credits.amount_transaction then
                            null;
                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MUP_TOTALS_NOT_EQUAL'
                            );
                        end if;

                        trc_log_pkg.debug (
                            i_text         => '[#1] Totals OK'
                            , i_env_param1 => l_msg_prefix
                        );
                        
                        register_ok_summary (
                            i_id          => l_fsum_tab(i).id
                        );

                        if l_fsum_tab(i).is_grouped = get_true then     
                            register_ok_grouped (
                                i_id     => l_fsum_tab(i).id
                            );
                        end if;    

                        if l_fsum_tab(i).de025 = mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT then
                            l_outgoing_count := l_outgoing_count + 1;
                        else
                            l_incoming_count := l_incoming_count + 1;
                        end if;
                    end if;
                exception
                    when others then
                        rollback to savepoint processing_next_fsum;
                        if l_fin_cur%isopen then
                            close l_fin_cur;
                        end if;
                              
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            register_error_summary (
                                i_id         => l_fsum_tab(i).id
                            );
                                      
                            if l_fsum_tab(i).is_grouped = get_true then     
                                register_error_grouped (
                                    i_id     => l_fsum_tab(i).id
                                );
                            end if;    
                            
                            l_excepted_count := l_excepted_count + 1;
                        else
                            raise;
                        end if;
                end;

                check_ok_summary;
                check_error_summary;
                check_skip_summary;
            end loop;
            
            l_total_count := l_total_count + l_fsum_tab.count;
            
            prc_api_stat_pkg.log_current (
                i_current_count    => l_total_count
                , i_excepted_count => l_excepted_count
            );
            
            exit when l_fsum_cur%notfound;
        end loop;
        close l_fsum_cur;
        
        mark_ok_summary;
        mark_error_summary;
        mark_skip_summary;
        
        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_total_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );      
        
        trc_log_pkg.debug (
            i_text      => 'File summary records processed:'
        );
        trc_log_pkg.debug (
            i_text         => ' Incoming OK:#1 Outgoing OK:#2 Summary TOTAL:#3 Summary OK:#4 Summary FAILED:#5 Summary SKIPED: #6'
            , i_env_param1 => l_incoming_count || chr(10) 
            , i_env_param2 => l_outgoing_count || chr(10)
            , i_env_param3 => l_total_count || chr(10) 
            , i_env_param4 => (l_outgoing_count + l_incoming_count) || chr(10)
            , i_env_param5 => l_excepted_count
            , i_env_param6 => l_skiped_count
        );
        
    exception
        when others then
            rollback to savepoint starting_mup_file_summary;
            if l_fin_cur%isopen then
                close l_fin_cur;
            end if;
            if l_fsum_cur%isopen then
                close l_fsum_cur;
            end if;

            prc_api_stat_pkg.log_end(
                i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
            end if;  
              
            raise;
    end process_summary;
    
    procedure process_settlement (
        i_network_id   in     com_api_type_pkg.t_tiny_id
      , i_inst_id      in     com_api_type_pkg.t_inst_id
    ) is
        BULK_LIMIT         constant number := 400;
        l_standard_id               com_api_type_pkg.t_tiny_id;
        l_host_id                   com_api_type_pkg.t_tiny_id;
        l_reconciliation_mode       mup_api_type_pkg.t_pds_body;
        l_standard_version          com_api_type_pkg.t_tiny_id;

        l_param_tab                 com_api_type_pkg.t_param_tab;

        l_total_count               com_api_type_pkg.t_long_id := 0;
        l_excepted_count            com_api_type_pkg.t_long_id := 0;
        l_incoming_count            com_api_type_pkg.t_long_id := 0;
        l_outgoing_count            com_api_type_pkg.t_long_id := 0;
        l_estimated_count           com_api_type_pkg.t_long_id := 0;

        l_fpd_cur                   sys_refcursor;
        l_fin_cur                   sys_refcursor;
        
        l_fpd_tab                   mup_api_type_pkg.t_fpd_tab;
        
        l_fpd_fee_found             com_api_type_pkg.t_boolean;
        l_fee_amt                   com_api_type_pkg.t_medium_id;
        l_trn_amt                   com_api_type_pkg.t_medium_id;
        
        l_debits                    mup_api_type_pkg.t_reconcile_total_rec;
        l_credits                   mup_api_type_pkg.t_reconcile_total_rec;
        
        l_ok_id                     com_api_type_pkg.t_number_tab;
        l_error_id                  com_api_type_pkg.t_number_tab;
        l_ok_grouped_id             num_tab_tpt := num_tab_tpt();
        l_error_grouped_id          num_tab_tpt := num_tab_tpt();

        l_rowid                     com_api_type_pkg.t_rowid_tab;
        l_id                        com_api_type_pkg.t_number_tab;
        l_impact                    com_api_type_pkg.t_tiny_tab;
        l_is_incoming               com_api_type_pkg.t_boolean_tab;
        l_mti                       com_api_type_pkg.t_name_tab;
        l_de002                     com_api_type_pkg.t_name_tab;
        l_de004                     com_api_type_pkg.t_number_tab;
        l_de005                     com_api_type_pkg.t_number_tab;
        l_p0146                     com_api_type_pkg.t_number_tab;

        l_sttl_amount               com_api_type_pkg.t_number_tab;
        l_sttl_currency             com_api_type_pkg.t_curr_code_tab;
        
        l_msg_prefix                com_api_type_pkg.t_text;

        l_original_file_id_tab      com_api_type_pkg.t_number_tab;

        procedure mark_ok_settled is
        begin
            forall i in 1 .. l_ok_id.count
                update mup_fpd
                   set status = net_api_const_pkg.CLEARING_MSG_STATUS_MATCHED
                 where id = l_ok_id(i);
                    
            forall i in 1 .. l_ok_id.count
                update mup_fin
                   set is_fpd_matched = com_api_type_pkg.TRUE
                 where fpd_id = l_ok_id(i);
                    
            l_ok_id.delete;
        end;

        procedure mark_error_settled is
        begin
            forall i in 1 .. l_error_id.count
                update mup_fpd
                   set status = net_api_const_pkg.CLEARING_MSG_STATUS_MATCH_ERR
                 where id = l_error_id(i);
        
            l_error_id.delete;
        end;

        procedure mark_settled is
            l_grouped_id    com_api_type_pkg.t_long_tab;
            l_is_error_id   com_api_type_pkg.t_boolean_tab;
            l_mark_id       com_param_map_tpt := com_param_map_tpt();
            l_count         com_api_type_pkg.t_count := 0;
        begin  
            for i in 1 .. l_ok_grouped_id.count loop
                l_mark_id.extend;
                l_count := l_count + 1;
                l_mark_id(l_count) := com_param_map_tpr(to_char(com_api_type_pkg.FALSE), null, l_ok_grouped_id(i),    null, null);
            end loop;        

            for i in 1 .. l_error_grouped_id.count loop
                l_mark_id.extend;
                l_count := l_count + 1;
                l_mark_id(l_count) := com_param_map_tpr(to_char(com_api_type_pkg.TRUE),  null, l_error_grouped_id(i), null, null);
            end loop;        

            select/*+ ordered use_nl(t,f2) use_hash(f1) index(f2 MUP_FPD_PK) index(f1 MUP_FPD_CLMS0040_NDX) */ f1.id 
                 , to_number(t.name) as is_error_id
              bulk collect into l_grouped_id
                              , l_is_error_id
              from table(cast(l_mark_id as com_param_map_tpt)) t
                 , mup_fpd f2
                 , mup_fpd f1
             where f2.id      = t.number_value
               and f1.de025   = f2.de025    
               and f1.de049   = f2.de049 
               and f1.de050   = f2.de050  
               and f1.de093   = f2.de093  
               and f1.p0165   = f2.p0165  
               and f1.p0372_1 = f2.p0372_1
               and f1.p0372_2 = f2.p0372_2 
               and f1.p0374   = f2.p0374    
               and f1.p0378   = f2.p0378    
               and f1.p0395_1 = f2.p0395_1  
               and f1.p2358_6 = f2.p2358_6  
               and decode(f1.status, 'CLMS0040', f1.network_id, null) = i_network_id
               and f1.de025   = '6862';

            for i in 1 .. l_grouped_id.count loop
                if l_is_error_id(i) = com_api_type_pkg.TRUE then
                    l_error_id(l_error_id.count + 1) := l_grouped_id(i);
                else
                    l_ok_id(l_ok_id.count + 1)       := l_grouped_id(i);
                end if;
            end loop;        

            mark_ok_settled;
            mark_error_settled;

        end mark_settled;
    
    begin
        trc_log_pkg.debug (
            i_text      => 'Settlement process started'
        );
        
        savepoint starting_mup_settlement;
        
        -- get network communication standard
        l_standard_id      := net_api_network_pkg.get_offline_standard(i_network_id => i_network_id);
        l_host_id          := net_api_network_pkg.get_default_host    (i_network_id => i_network_id);
        l_standard_version := cmn_api_standard_pkg.get_current_version(i_network_id => i_network_id);

        l_reconciliation_mode := nvl(cmn_api_standard_pkg.get_varchar_value(
                i_inst_id     => i_inst_id
              , i_standard_id => l_standard_id
              , i_object_id   => l_host_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name  => mup_api_const_pkg.RECONCILIATION_MODE
              , i_param_tab   => l_param_tab
            ), mup_api_const_pkg.RECONCILIATION_MODE_FULL
        );
       
        -- estimate messages
         select sum(cnt)
           into l_estimated_count 
           from (
                    select count(1) cnt
                      from mup_fpd
                     where decode(status, 'CLMS0040', network_id, null) = i_network_id
                       and de025 != '6862'
                     union all       
                    select 1 cnt
                      from mup_fpd
                     where decode(status, 'CLMS0040', network_id, null) = i_network_id
                       and de025  = '6862'
                     group by de050, de025, de049 , de093, p0165, p0372_1, p0372_2, p0374, p0378, p0395_1, p2358_6, file_id   
                );
                      
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );
        
        if l_reconciliation_mode = mup_api_const_pkg.RECONCILIATION_MODE_NONE then
            
            trc_log_pkg.debug (
                i_text      => 'Don''t perform any reconciliation'
            );            

            update mup_fpd d
               set d.status = decode (
                       d.de025
                     , mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT, net_api_const_pkg.CLEARING_MSG_STATUS_MATCH_SKIP
                     , mup_api_const_pkg.FPD_REASON_NOTIFICATION,    net_api_const_pkg.CLEARING_MSG_STATUS_MATCH_SKIP
                     , net_api_const_pkg.CLEARING_MSG_STATUS_MATCH_ERR
                   )
             where decode(d.status, 'CLMS0040', d.network_id, null) = i_network_id
         returning count(*)
                 , count( case when d.de025 = mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT then 1 end )
                 , count( case when d.de025 = mup_api_const_pkg.FPD_REASON_NOTIFICATION    then 1 end )
                 , count( case when d.de025 not in (mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT, mup_api_const_pkg.FPD_REASON_NOTIFICATION) then 1 end )
              into l_total_count
                 , l_outgoing_count
                 , l_incoming_count
                 , l_excepted_count
            ;
            
        else
          
            enum_fpd_for_process (
                io_fpd_cur    => l_fpd_cur
              , i_network_id  => i_network_id
            );
            loop
                fetch l_fpd_cur
                  bulk collect into l_fpd_tab
                  limit BULK_LIMIT;

                for i in 1 .. l_fpd_tab.count loop
                
                    l_msg_prefix := 'id = ' || l_fpd_tab(i).id;

                    begin
                        savepoint processing_next_fpd;
                        
                        if l_fpd_tab(i).de025 in (mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT, mup_api_const_pkg.FPD_REASON_NOTIFICATION) then
                            null;
                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MUP_UNKNOWN_REASON'
                              , i_env_param1    => l_fpd_tab(i).de025
                            );
                        end if;

                        open_fpd_fin_cursor(
                            i_fpd_rec                => l_fpd_tab(i)
                          , o_cursor                 => l_fin_cur
                          , i_network_id             => i_network_id
                          , io_original_file_id_tab  => l_original_file_id_tab
                        );

                        trc_log_pkg.debug (
                            i_text       => '[#1] Statement build for fin records retriving.'
                          , i_env_param1 => l_msg_prefix
                        );

                        init_total (
                            io_total_rec  => l_debits
                        );
                        init_total (
                            io_total_rec  => l_credits
                        );

                        loop
                            fetch l_fin_cur
                              bulk collect into l_rowid
                                              , l_id
                                              , l_impact
                                              , l_is_incoming
                                              , l_mti
                                              , l_de002
                                              , l_de004
                                              , l_de005
                                              , l_p0146
                              limit BULK_LIMIT;

                            trc_log_pkg.debug (
                                i_text       => '[#1] l_rowid.count.'
                              , i_env_param1 => l_rowid.count
                            );
                            
                            for k in 1 .. l_rowid.count loop
                                l_fpd_fee_found := com_api_type_pkg.FALSE;
                                l_fee_amt := 0;
                                l_trn_amt := 0;

                                if l_is_incoming(k) = com_api_type_pkg.TRUE then
                                    l_fee_amt := nvl(l_p0146(k), 0);
                                elsif l_fpd_tab(i).p0402 = 1 then
                                    l_fee_amt := nvl( 
                                          case l_fpd_tab(i).p0395_1
                                              -- credit to destination
                                              when mup_api_const_pkg.CREDIT then
                                                  l_fpd_tab(i).p0395_2
                                              -- debit to destination
                                              when mup_api_const_pkg.DEBIT then
                                                  -l_fpd_tab(i).p0395_2
                                              else
                                                  0
                                          end
                                      , 0
                                    );
                                    l_trn_amt := nvl(l_fpd_tab(i).p0394_2, 0);
                                    l_fpd_fee_found := com_api_type_pkg.TRUE;
                                end if;

                                if l_impact(k) = com_api_type_pkg.CREDIT then
                                    l_credits.amount_transaction    := l_credits.amount_transaction + nvl(l_de004(k), 0);
                                    l_credits.amount_reconciliation := l_credits.amount_reconciliation + nvl(l_de005(k), 0);
                                    l_credits.count_transaction     := l_credits.count_transaction + 1;

                                    if
                                    (   l_is_incoming(k) = com_api_type_pkg.TRUE and
                                        (nvl(l_de005(k), 0) + l_fee_amt) <= 0
                                    ) then
                                        l_debits.count_vs_fee := l_debits.count_vs_fee + 1;

                                    elsif
                                    (   l_is_incoming(k) = com_api_type_pkg.FALSE and
                                        l_fpd_fee_found = com_api_type_pkg.TRUE and
                                        (nvl(l_trn_amt, 0) + l_fee_amt) <= 0
                                    ) then
                                        l_debits.count_vs_fee := l_debits.count_vs_fee + 1;

                                    else
                                        l_credits.count_vs_fee := l_credits.count_vs_fee + 1;
                                    end if;

                                elsif l_impact(k) = com_api_type_pkg.DEBIT then
                                    l_debits.amount_transaction := l_debits.amount_transaction + nvl(l_de004(k), 0);
                                    l_debits.amount_reconciliation := l_debits.amount_reconciliation + nvl(l_de005(k), 0);
                                    l_debits.count_transaction := l_debits.count_transaction + 1;

                                    if
                                    (   l_is_incoming(k) = com_api_type_pkg.TRUE and
                                        ((-nvl(l_de005(k), 0)) + l_fee_amt) > 0
                                    ) then
                                        l_credits.count_vs_fee := l_credits.count_vs_fee + 1;

                                    elsif
                                    (   l_is_incoming(k) = com_api_type_pkg.FALSE and
                                        l_fpd_fee_found = com_api_type_pkg.TRUE and
                                        ((-nvl(l_trn_amt, 0)) + l_fee_amt) > 0
                                    ) then
                                        l_credits.count_vs_fee := l_credits.count_vs_fee + 1;

                                    else
                                        l_debits.count_vs_fee := l_debits.count_vs_fee + 1;
                                    end if;
                                end if;
                            end loop;
                                
                            -- set financial position detail message identifier
                            forall k in 1 .. l_rowid.count
                                update mup_fin f
                                   set f.fpd_id = l_fpd_tab(i).id
                                 where f.rowid = l_rowid(k);

                            exit when l_fin_cur%notfound;
                        end loop;
                        close l_fin_cur;
                        
                        trc_log_pkg.debug (
                            i_text         => 'Reconciliation totals:' || chr(10) || '#1#2#3#4'
                            , i_env_param1 => 'fpd.p0400=' || l_fpd_tab(i).p0400 || ' debits.count=' || l_debits.count_transaction || ' debits.count_vs_fee=' || l_debits.count_vs_fee || chr(10)
                            , i_env_param2 => 'fpd.p0401=' || l_fpd_tab(i).p0401 || ' credits.count=' || l_credits.count_transaction || ' credits.count_vs_fee=' || l_credits.count_vs_fee || chr(10)
                            , i_env_param3 => 'fpd.p0380=' || l_fpd_tab(i).p0380_2 || ' debits.amount_transaction=' || l_debits.amount_transaction || chr(10)
                            , i_env_param4 => 'fpd.p0381=' || l_fpd_tab(i).p0381_2 || ' credits.amount_transaction=' || l_credits.amount_transaction
                        );

                        if
                        (   (   l_fpd_tab(i).p0400 = l_debits.count_transaction and
                                l_fpd_tab(i).p0401 = l_credits.count_transaction
                            ) or
                            (   l_fpd_tab(i).p0400 = l_debits.count_vs_fee and
                                l_fpd_tab(i).p0401 = l_credits.count_vs_fee
                            )
                        ) then
                            null;
                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MUP_TOTALS_COUNT_NOT_EQUAL'
                            );
                        end if;

                        if l_fpd_tab(i).p0380_2 = l_debits.amount_transaction and l_fpd_tab(i).p0381_2 = l_credits.amount_transaction then
                            null;
                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MUP_TOTALS_NOT_EQUAL'
                            );
                        end if;

                        trc_log_pkg.debug (
                            i_text         => '[#1] Totals OK, performing reconciliation'
                            , i_env_param1 => l_msg_prefix
                        );

                        open_perf_fpd_fin_cursor (
                            i_fpd_id       => l_fpd_tab(i).id
                          , o_cursor       => l_fin_cur
                        );

                        loop
                            fetch l_fin_cur
                              bulk collect into l_rowid
                                              , l_id
                                              , l_impact
                                              , l_is_incoming
                                              , l_mti
                                              , l_de002
                                              , l_de004
                                              , l_de005
                                              , l_p0146
                              limit BULK_LIMIT;

                            l_sttl_currency.delete;
                            l_sttl_amount.delete;
                            
                            for k in 1 .. l_rowid.count loop
                                l_sttl_currency(k) := l_fpd_tab(i).de050;
                                l_sttl_amount(k) := null;

                                if l_impact(k) = com_api_type_pkg.CREDIT then
                                    if l_credits.count_transaction > 1 then
                                        if l_credits.amount_reconciliation > 0 then
                                            if l_credits.rate is null then
                                                l_credits.rate := l_fpd_tab(i).p0391_2 / l_credits.amount_reconciliation;
                                            end if;
                                            l_sttl_amount(k) := l_de005(k) * l_credits.rate;
                                        elsif l_credits.amount_transaction > 0 then
                                            if l_credits.rate is null then
                                                l_credits.rate := l_fpd_tab(i).p0391_2 / l_credits.amount_transaction;
                                            end if;
                                            l_sttl_amount(k) := l_de004(k) * l_credits.rate;
                                        else
                                            l_sttl_amount(k) := 0;
                                        end if;
                                    else
                                        l_sttl_amount(k) := l_fpd_tab(i).p0391_2;
                                    end if;

                                    l_credits.sttl_amount := l_credits.sttl_amount + l_sttl_amount(k);

                                    if l_sttl_amount(k) < l_credits.max_sttl_amount then
                                        null;
                                    else -- max_amount is null or max_amount < pay_amount
                                        l_credits.max_sttl_amount := l_sttl_amount(k);
                                        l_credits.max_sttl_amount_id := l_fpd_tab(i).id;
                                    end if;

                                elsif l_impact(k) = com_api_type_pkg.DEBIT then
                                    if l_debits.count_transaction > 1 then
                                        if l_debits.amount_reconciliation > 0 then
                                            if l_debits.rate is null then
                                                l_debits.rate := l_fpd_tab(i).p0390_2 / l_debits.amount_reconciliation;
                                            end if;
                                            l_sttl_amount(k) := l_de005(k) * l_debits.rate;
                                        elsif l_debits.amount_transaction > 0 then
                                            if l_debits.rate is null then
                                                l_debits.rate := l_fpd_tab(i).p0390_2 / l_debits.amount_transaction;
                                            end if;
                                            l_sttl_amount(k) := l_de004(k) * l_debits.rate;
                                        else
                                            l_sttl_amount(k) := 0;
                                        end if;
                                    else
                                        l_sttl_amount(k) := l_fpd_tab(i).p0390_2;
                                    end if;
                   
                                    l_debits.sttl_amount := l_debits.sttl_amount + l_sttl_amount(k);

                                    if l_sttl_amount(k) < l_debits.max_sttl_amount then
                                        null;
                                    else -- max_amount is null or max_amount < pay_amount
                                        l_debits.max_sttl_amount := l_sttl_amount(k);
                                        l_debits.max_sttl_amount_id := l_fpd_tab(i).id;
                                    end if;
                                end if;
                            end loop;

                            opr_api_clearing_pkg.mark_settled (
                                i_id_tab           => l_id
                                , i_sttl_amount    => l_sttl_amount
                                , i_sttl_currency  => l_sttl_currency
                            );
                            exit when l_fin_cur%notfound;
                        end loop;
                        close l_fin_cur;

                        trc_log_pkg.debug (
                            i_text         => '[#1] Reconciliation finished' || chr(10) || 'credits.sttl_amount[#2] l_fpd_tab.p0391[#3]' || chr(10) || 'debits.sttl_amount[#4] l_fpd_tab.p0392[#5]'
                            , i_env_param1 => l_msg_prefix
                            , i_env_param2 => l_credits.sttl_amount
                            , i_env_param3 => l_fpd_tab(i).p0391_2
                            , i_env_param4 => l_debits.sttl_amount
                            , i_env_param5 => l_fpd_tab(i).p0390_2
                        );
                        
                        l_ok_id(l_ok_id.count + 1) := l_fpd_tab(i).id;
                        
                        if l_fpd_tab(i).is_grouped = get_true then
                            l_ok_grouped_id.extend;
                            l_ok_grouped_id(l_ok_grouped_id.count) := l_fpd_tab(i).id;
                        end if;

                        if l_fpd_tab(i).de025 = mup_api_const_pkg.FPD_REASON_ACKNOWLEDGEMENT then
                            l_outgoing_count := l_outgoing_count + 1;
                        elsif l_fpd_tab(i).de025 = mup_api_const_pkg.FPD_REASON_NOTIFICATION then
                            l_incoming_count := l_incoming_count + 1;
                        end if;
                        
                    exception
                        when others then
                            rollback to savepoint processing_next_fpd;
                            if l_fin_cur%isopen then
                                close l_fin_cur;
                            end if;
                            
                            if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                                l_error_id(l_error_id.count + 1) := l_fpd_tab(i).id;
                                    
                                if l_fpd_tab(i).is_grouped = get_true then    
                                    l_error_grouped_id.extend;
                                    l_error_grouped_id(l_error_grouped_id.count) := l_fpd_tab(i).id;
                                end if;
                                
                                l_excepted_count := l_excepted_count + 1;
                            else
                                raise;
                            end if;
                    end;
                    
                    if l_ok_id.count + l_error_id.count >= BULK_LIMIT then
                        mark_settled;
                    end if;
                end loop;
                
                l_total_count := l_total_count + l_fpd_tab.count;
                
                prc_api_stat_pkg.log_current (
                    i_current_count    => l_total_count
                    , i_excepted_count => l_excepted_count
                );
                
                exit when l_fpd_cur%notfound;                
            end loop;
            close l_fpd_cur;

            mark_settled;
        end if;

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_total_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );      
        
        trc_log_pkg.debug (
            i_text      => 'FPD records processed:'
        );
        trc_log_pkg.debug (
            i_text         => ' Incoming OK:#1 Outgoing OK:#2 Summary TOTAL:#3 Summary OK:#4 Summary FAILED:#5'
            , i_env_param1 => l_incoming_count || chr(10) 
            , i_env_param2 => l_outgoing_count || chr(10)
            , i_env_param3 => l_total_count || chr(10) 
            , i_env_param4 => (l_outgoing_count + l_incoming_count) || chr(10)
            , i_env_param5 => l_excepted_count                           
        );

    exception
        when others then
            rollback to savepoint starting_mup_settlement;
            if l_fin_cur%isopen then
                close l_fin_cur;
            end if;
            if l_fpd_cur%isopen then
                close l_fpd_cur;
            end if;

            prc_api_stat_pkg.log_end(
                i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
            end if;    
            
            raise;
    end process_settlement;

end mup_prc_sttt_pkg; 
/
