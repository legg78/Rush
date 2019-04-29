create or replace package body cst_bsm_outgoing_pkg is

BULK_LIMIT                  constant integer                    := 400;
EVENT_TYPES_FOR_NEW_CARDS   constant com_api_type_pkg.t_long_id := -50000034;

procedure export_caf(
    i_inst_id            in com_api_type_pkg.t_inst_id
  , i_environment_code   in com_api_type_pkg.t_dict_value
  , i_issuer_code        in com_api_type_pkg.t_dict_value
  , i_full_export        in com_api_type_pkg.t_boolean
) is
    l_card_cur              cst_bsm_type_pkg.t_event_card_cur;
    l_card_tab              cst_bsm_type_pkg.t_event_card_tab;
    l_event_object_id       com_api_type_pkg.t_number_tab;
    l_current_count         com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_rec_raw               com_api_type_pkg.t_raw_tab;
    l_rec_num               com_api_type_pkg.t_integer_tab;
    l_sysdate               date;
    l_is_first_row          com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE;

    cursor l_events is
        select v.id
          from evt_event_object v
             , evt_event e
         where decode(v.status, 'EVST0001', v.procedure_name, null) = 'CST_BSM_OUTGOING_PKG.EXPORT_CAF'
           and v.inst_id = i_inst_id
           and v.eff_date <= l_sysdate
           and v.event_id = e.id;

    procedure open_file is
        l_params              com_api_type_pkg.t_param_tab;
    begin
        rul_api_param_pkg.set_param (
            i_name     => 'INST_ID'
          , i_value    => i_inst_id
          , io_params  => l_params
        );
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
          , i_file_type     => cst_bsm_const_pkg.FILE_TYPE_CARD_ACC_H2H_BASE24
          , io_params       => l_params
        );
    end;

    procedure close_file (
        i_status              in com_api_type_pkg.t_dict_value
    ) is
    begin
        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => i_status
        );
    end;

    procedure put_file is
    begin
        prc_api_file_pkg.put_bulk (
            i_sess_file_id  => l_session_file_id
          , i_raw_tab       => l_rec_raw
          , i_num_tab       => l_rec_num
        );
        l_rec_raw.delete;
        l_rec_num.delete;
    end;
begin
    prc_api_stat_pkg.log_start;

    savepoint sp_cards_export;

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    open l_card_cur for
        with ev as (
            select distinct v.object_id
                 , v.entity_type
                 , case
                       when e.event_type in (select element_value from com_array_element where array_id = EVENT_TYPES_FOR_NEW_CARDS)
                       then 'A'
                       else 'C'
                   end as evt_type
              from evt_event_object v
                 , evt_event e
             where i_full_export = com_api_type_pkg.FALSE
               and decode(v.status, 'EVST0001', v.procedure_name, null) = 'CST_BSM_OUTGOING_PKG.EXPORT_CAF'
               and v.inst_id     = i_inst_id
               and v.event_id    = e.id
               and v.eff_date   <= l_sysdate
        )
        , xx as (
            select max(i.id) keep (dense_rank first order by i.seq_number desc) as object_id
                 , v.evt_type
              from ev v
                 , iss_card_instance i
             where v.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and i.card_id     = v.object_id
             group by i.card_id
                    , v.evt_type
            union
            select max(i2.id) keep (dense_rank first order by i2.seq_number desc) as object_id
                 , v.evt_type
              from ev v
                 , iss_card_instance i1
                 , iss_card_instance i2
             where v.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
               and i1.id         = v.object_id
               and i2.card_id    = i1.card_id
             group by i2.card_id
                    , v.evt_type
            union
            select max(i.id) keep (dense_rank first order by i.seq_number desc) as object_id
                 , v.evt_type
              from ev v
                 , prd_contract t
                 , iss_card c
                 , iss_card_instance i
             where v.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
               and t.product_id  = v.object_id
               and t.id          = c.contract_id
               and i.card_id     = c.id
             group by i.card_id
                    , v.evt_type
            union
            select max(i.id) keep (dense_rank first order by i.seq_number desc) as object_id
                 , v.evt_type
              from ev v
                 , acc_account_object a
                 , iss_card c
                 , iss_card_instance i
             where v.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and a.account_id  = v.object_id
               and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and c.id          = a.object_id
               and i.card_id     = c.id
             group by i.card_id
                    , v.evt_type
            union
            select max(i.id) keep(dense_rank last order by i.seq_number) as object_id
                 , 'C' as evt_type
              from iss_card_instance i
                 , iss_card c
             where c.id          = i.card_id
               and c.inst_id     = i_inst_id
               and i_full_export = com_api_type_pkg.TRUE
             group by i.card_id
                    , 'C'
        )
        select oc.id as card_id
             , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
             , ci.status     as card_status
             , oc.category   as card_category
             , ci.reg_date   as card_reg_date
             , ci.expir_date as card_expir_date
             , xx.evt_type   as event_type
             , (
                   select count(1)
                     from acc_account_object
                    where object_id   = oc.id
                      and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               ) as account_count
             , count(oc.id) over() cnt
          from xx
             , iss_card_instance ci
             , iss_card oc
             , iss_card_number cn
         where ci.id      = xx.object_id
           and oc.id      = ci.card_id
           and cn.card_id = oc.id;

    loop
        fetch l_card_cur bulk collect into l_card_tab limit BULK_LIMIT;

        l_rec_raw.delete;
        l_rec_num.delete;

        for i in 1..l_card_tab.count loop

            if l_is_first_row = com_api_type_pkg.TRUE then
                l_processed_count := l_processed_count + 1;

                prc_api_stat_pkg.log_estimation (
                    i_estimated_count  => l_card_tab(i).count
                );

                open_file;

                -- put header line 1
                l_rec_raw(l_rec_raw.count + 1) :=
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)                   -- Record number
                    || 'FH1CF'                                                             -- Record Type
                    || com_api_type_pkg.pad_char(i_issuer_code, 4, 4)                      -- Issuer code
                    || to_char(get_sysdate, 'YYYYMMDDHH24MI')                              -- System date and time
                    || com_api_type_pkg.pad_char(i_environment_code, 4, 4)                 -- Environment
                    || '50  '
                    || to_char(get_sysdate, 'yymmdd')                                      -- System date
                    || '        '
                    || com_api_type_pkg.pad_char(to_char(get_sysdate, 'hh24miss'), 12, 12) -- System time
                    || com_api_type_pkg.pad_char(' ', 53, 53)
                    || '0 0    '
                    || com_api_type_pkg.pad_char(' ', 26, 26)
                    ;

                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                    l_processed_count := l_processed_count + 1;

                    -- put header line 2
                    l_rec_raw(l_rec_raw.count + 1) :=
                        com_api_type_pkg.pad_number(l_processed_count, 9, 9)  -- Record number
                        || 'BH'                                               -- Record Type
                        || com_api_type_pkg.pad_char(i_issuer_code, 4, 4)     -- Issuer code
                        || com_api_type_pkg.pad_char(' ', 29, 29)
                        ;

                l_rec_num(l_rec_num.count + 1) := l_processed_count;
                l_is_first_row := com_api_type_pkg.FALSE;
            end if;

            l_processed_count := l_processed_count + 1;

            savepoint sp_body_record;

            begin
                -- put body
                l_rec_raw(l_rec_raw.count + 1) :=
                    '0148'                                                          -- LGTH:           Segment length
                    || com_api_type_pkg.pad_number(l_processed_count, 9, 9)         -- CNT:            Record number
                    || com_api_type_pkg.pad_char(l_card_tab(i).card_number, 19, 19) -- PRIKEY.PAN:     PAN
                    || '000'                                                        -- PRIKEY.MBR^NUM:
                    || com_api_type_pkg.pad_char(l_card_tab(i).event_type, 1, 1)    -- REC^TYP:        "A" = (Add), "C" = (Change), "D" = (Delete)
                    || case                                                         -- CRD^TYP:        Primary card flag
                           when l_card_tab(i).card_category = iss_api_const_pkg.CARD_CATEGORY_PRIMARY
                           then 'P '
                           else '  '
                       end
                    || com_api_type_pkg.pad_char(i_issuer_code, 4, 4)               -- FIID:           Issuer code
                    || case                                                         -- CRD^STAT:       Card status
                           when l_card_tab(i).card_status in (iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED
                                                            , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE)  -- "0" = (Issued but not active--no transactions allowed)
                           then '0'
                           when l_card_tab(i).card_status = iss_api_const_pkg.CARD_STATUS_VALID_CARD            -- "1" = (Open--transactions allowed)
                           then '1'
                           when l_card_tab(i).card_status = iss_api_const_pkg.CARD_STATUS_LOST_CARD             -- "2" = (Lost--no transactions allowed)
                           then '2'
                           when l_card_tab(i).card_status = iss_api_const_pkg.CARD_STATUS_STOLEN_CARD           -- "3" = (Stolen--no transaction allowed)
                           then '3'
                           when l_card_tab(i).card_status = iss_api_const_pkg.CARD_STATUS_INVALID_CARD          -- "9" = (Closed--no transactions allowed)
                           then '9'
                           else '4'                                                                             -- "4" = (Restricted--no withdrawals allowed)
                       end
                    || '0000            '                                           -- PIN^OFST:
                    || com_api_type_pkg.pad_number(0, 72, 72)                       -- TTL^WDL^LMT, OFFL^WDL^LMT, TTL^CCA^LMT, OFFL^CCA^LMT, AGGR^LMT, OFFL^AGGR^LMT
                    || to_char(l_card_tab(i).card_reg_date, 'YYMMDD')               -- FIRST^USED^DAT: Use card first
                    || to_char(get_sysdate, 'YYMMDD')                               -- LAST^RESET^DAT: Use card last
                    || to_char(l_card_tab(i).card_expir_date, 'yymm')               -- EXP^DAT:        Expiry date
                    || '000840999' 
                    || com_api_type_pkg.pad_number(0, 76, 76)
                    || '0124'
                    || com_api_type_pkg.pad_number(0, 84, 84)
                    || '0999'
                    || com_api_type_pkg.pad_number(0, 31, 31)
                    || ' '
                    || com_api_type_pkg.pad_number(l_card_tab(i).account_count * 34 + 6, 4, 4) -- Length
                    || com_api_type_pkg.pad_number(l_card_tab(i).account_count, 2, 2)          -- Account count
                    ;

                for acct in (
                    select case a.account_type
                                when acc_api_const_pkg.ACCOUNT_TYPE_SAVING then '11' -- Saving
                                when 'ACTP5017'                            then '11' -- Saving
                                when acc_api_const_pkg.ACCOUNT_TYPE_CREDIT then '31' -- Credit
                                else '01'                                            -- Checking
                           end account_type
                         , a.account_number
                         , c.code
                         , c.name
                      from acc_account_object o
                         , acc_account a
                         , com_currency c
                     where o.object_id   = l_card_tab(i).card_id
                       and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and a.id          = o.account_id
                       and c.code        = a.currency
                ) loop
                    l_rec_raw(l_rec_raw.count) := l_rec_raw(l_rec_raw.count)
                                               || acct.account_type                                      -- ACCT.TYP:  Account type
                                               || com_api_type_pkg.pad_char(acct.account_number, 19, 19) -- ACCT.NUM:  Account number
                                               || case l_card_tab(i).account_count                       -- ACCT.STAT: Primary flag
                                                      when 1
                                                      then '3'
                                                      else '1'
                                                  end
                                               || com_api_type_pkg.pad_char(acct.code, 3, 3)
                                               || com_api_type_pkg.pad_char(acct.name, 3, 3)
                                               || '      ';
                end loop;

                l_rec_num(l_rec_num.count + 1) := l_processed_count;

            exception
                when others then
                    rollback to savepoint sp_body_record;

                    trc_log_pkg.error(
                        i_text          => 'Export card record with error: #1'
                      , i_env_param1    => l_card_tab(i).card_id
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;
                    else
                        raise;
                    end if;
            end;

            -- put footer line 1
            if l_processed_count = (l_card_tab(i).count + 2) then
                l_processed_count := l_processed_count + 1;

                l_rec_raw(l_rec_raw.count + 1) :=
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)       -- Record number
                    || 'BT'                                                    -- Record Type
                    || com_api_type_pkg.pad_number(0, 18, 18)
                    || com_api_type_pkg.pad_number(l_card_tab(i).count, 9, 9)  -- Body count
                    ;

                l_rec_num(l_rec_num.count + 1) := l_processed_count;
                l_processed_count := l_processed_count + 1;

                -- put footer line 2
                l_rec_raw(l_rec_raw.count + 1) :=
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)       -- Record number
                    || 'FT'                                                    -- Record Type
                    || com_api_type_pkg.pad_number(l_card_tab(i).count, 9, 9)  -- Body count
                    || '0   '
                    ;

                l_rec_num(l_rec_num.count + 1) := l_processed_count;
            end if;
        end loop;

        l_current_count := l_current_count + l_card_tab.count;

        -- put file record
        put_file;

        prc_api_stat_pkg.log_current (
            i_current_count   => l_current_count
          , i_excepted_count  => l_excepted_count
        );

        exit when l_card_cur%notfound;
    end loop;
    close l_card_cur;

    -- process event object
    if i_full_export = com_api_type_pkg.FALSE then
        open l_events;
        loop
            fetch l_events
            bulk collect into
            l_event_object_id
            limit BULK_LIMIT;

            evt_api_event_pkg.process_event_object (
                i_event_object_id_tab => l_event_object_id
            );

            exit when l_events%notfound;
        end loop;
        close l_events;
    end if;

    -- close file
    if l_current_count != 0 then
        close_file (
            i_status  => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    else
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_current_count
        );
    end if;

    prc_api_stat_pkg.log_end (
        i_processed_total  => l_current_count
      , i_excepted_total   => l_excepted_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_cards_export;

        if l_events%isopen then
            close l_events;
        end if;
        if l_card_cur%isopen then
            close l_card_cur;
        end if;

        if l_session_file_id is not null then
            close_file (
                i_status  => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;

        raise;
end export_caf;

procedure get_priority_criteria(
    i_application_id          in     com_api_type_pkg.t_long_id
  , o_ref_cursor                 out com_api_type_pkg.t_ref_cur) is
    l_nls_numeric_characters         com_api_type_pkg.t_name := com_ui_user_env_pkg.get_nls_numeric_characters;
begin
    open o_ref_cursor for
        select case field_name
                   when 'TOTAL_CUSTOMER_BALANCE' then 'Total customer balance'
                   when 'PRIORITY_FLAG'          then 'Priority flag'
                   when 'PRODUCT_COUNT'          then 'Product count'
                   when 'REISSUE_COMMAND'        then 'Reissue command'
                   when 'CARD_COUNT'             then 'Card count'
                   when 'PRIORITY_APPL_COUNT'    then 'Priority application count'
                   else 'NONAME'
               end as field_name
             , field_value
          from (select to_char(total_customer_balance, 'FM999G999G999G999G999G990D0099')                                  as total_customer_balance
                     , case when priority_flag > 0 then 'True' else 'False' end                                           as priority_flag
                     , to_char(product_count)                                                                             as product_count
                     , reissue_command || ' - ' || com_api_dictionary_pkg.get_article_text(i_article  => reissue_command) as reissue_command
                     , to_char(card_count)                                                                                as card_count
                     , to_char(priority_appl_count)                                                                       as priority_appl_count
                  from cst_bsm_priority_criteria
                 where application_id = i_application_id
               )
       unpivot include nulls (field_value for field_name in (total_customer_balance, priority_flag, product_count, reissue_command, card_count, priority_appl_count));

end get_priority_criteria;

procedure get_priority_products(
    i_application_id          in     com_api_type_pkg.t_long_id
  , o_ref_cursor                 out com_api_type_pkg.t_ref_cur) is
    l_customer_number                com_api_type_pkg.t_name;
begin
    select min(d.element_value)
      into l_customer_number
      from app_data d
     where d.appl_id    = i_application_id
       and d.element_id = app_api_const_pkg.ELEMENT_CUSTOMER_NUMBER;

    open o_ref_cursor for
        select p.product_number
             , p.product_description
          from cst_bsm_priority_prod_details  p
         where exists (select null
                         from cst_bsm_priority_acc_details  a
                        where a.customer_number = l_customer_number
                          and a.product_number  = p.product_number);

end get_priority_products;

end cst_bsm_outgoing_pkg;
/
