create or replace package body acc_api_entry_pkg is
/*********************************************************
*  API for entries <br />
*  Created by Khougaev A.(khougaev@bpcbt.com)  at 19.03.2010 <br />
*  Module: acc_api_entry_pkg <br />
*  @headcom
**********************************************************/

ENTITY_TYPE_INSTITUTION         com_api_type_pkg.t_dict_value := ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;
ENTITY_TYPE_AGENT               com_api_type_pkg.t_dict_value := ost_api_const_pkg.ENTITY_TYPE_AGENT;
ENTITY_TYPE_CUSTOMER            com_api_type_pkg.t_dict_value := prd_api_const_pkg.ENTITY_TYPE_CUSTOMER;
--ENTITY_TYPE_CONTRACT            com_api_type_pkg.t_dict_value := prd_api_const_pkg.ENTITY_TYPE_CONTRACT;

BULK_LIMIT                      binary_integer := 50;

type t_entry_template_rec is record (
    transaction_type            com_api_type_pkg.t_dict_value
  , transaction_num             com_api_type_pkg.t_tiny_id
  , negative_allowed            com_api_type_pkg.t_boolean
  , account_name                com_api_type_pkg.t_oracle_name
  , amount_name                 com_api_type_pkg.t_oracle_name
  , date_name                   com_api_type_pkg.t_oracle_name
  , posting_method              com_api_type_pkg.t_dict_value
  , balance_type                com_api_type_pkg.t_dict_value
  , balance_impact              com_api_type_pkg.t_sign
  , entry_id                    com_api_type_pkg.t_long_id
  , macros_id                   com_api_type_pkg.t_long_id
  , bunch_id                    com_api_type_pkg.t_long_id
  , bunch_type_id               com_api_type_pkg.t_tiny_id
  , transaction_id              com_api_type_pkg.t_long_id
  , account_id                  com_api_type_pkg.t_account_id
  , amount                      com_api_type_pkg.t_money
  , currency                    com_api_type_pkg.t_curr_code
  , account_type                com_api_type_pkg.t_dict_value
  , posting_date                date
  , dest_entity_type            com_api_type_pkg.t_dict_value
  , dest_account_type           com_api_type_pkg.t_dict_value
  , macros_type                 com_api_type_pkg.t_tiny_id
  , ref_entry_id                com_api_type_pkg.t_long_id
  , status                      com_api_type_pkg.t_dict_value
  , mod_id                      com_api_type_pkg.t_tiny_id
  , rounding_method             com_api_type_pkg.t_dict_value  -- Utilitarian field to pass the rounding error in posting entries procedure from posting macros procedure
);
type t_entry_template_cur is ref cursor return t_entry_template_rec;
type t_entry_template_tab is table of t_entry_template_rec index by binary_integer;

g_immediate_entries t_entry_template_tab;
g_bulk_entries      t_entry_template_tab;
g_buffered_entries  t_entry_template_tab;
g_pending_entries   t_entry_template_tab;

g_macros_id                     com_api_type_pkg.t_number_tab;
g_entity_type                   com_api_type_pkg.t_name_tab;
g_object_id                     com_api_type_pkg.t_number_tab;
g_macros_type                   com_api_type_pkg.t_tiny_tab;
g_account                       com_api_type_pkg.t_number_tab;
g_amount                        com_api_type_pkg.t_number_tab;
g_currency                      com_api_type_pkg.t_name_tab;
g_amount_purpose                com_api_type_pkg.t_name_tab;
g_fee_id                        com_api_type_pkg.t_number_tab;
g_fee_tier_id                   com_api_type_pkg.t_number_tab;
g_fee_mod_id                    com_api_type_pkg.t_number_tab;
g_details_data                  com_api_type_pkg.t_desc_tab;
g_status                        com_api_type_pkg.t_name_tab;
g_conversion_rate               com_api_type_pkg.t_number_tab;
g_rate_type                     com_api_type_pkg.t_name_tab;

g_bunch_id                      com_api_type_pkg.t_number_tab;
g_bunch_macros_id               com_api_type_pkg.t_number_tab;
g_bunch_type                    com_api_type_pkg.t_tiny_tab;
g_bunch_details_data            com_api_type_pkg.t_number_tab;

procedure post_entries (
    i_entry_id               in     com_api_type_pkg.t_number_tab
  , i_macros_id              in     com_api_type_pkg.t_number_tab
  , i_bunch_id               in     com_api_type_pkg.t_number_tab
  , i_transaction_id         in     com_api_type_pkg.t_number_tab
  , i_transaction_type       in     com_api_type_pkg.t_name_tab
  , i_account_id             in     com_api_type_pkg.t_number_tab
  , i_amount                 in     com_api_type_pkg.t_number_tab
  , i_currency               in     com_api_type_pkg.t_name_tab
  , i_account_type           in     com_api_type_pkg.t_name_tab
  , i_balance_type           in     com_api_type_pkg.t_name_tab
  , i_balance_impact         in     com_api_type_pkg.t_number_tab
  , i_original_account_id    in     com_api_type_pkg.t_number_tab
  , i_transf_entity          in     com_api_type_pkg.t_name_tab
  , i_transf_type            in     com_api_type_pkg.t_name_tab
  , i_macros_type            in     com_api_type_pkg.t_number_tab
  , i_status                 in     com_api_type_pkg.t_name_tab
  , i_ref_entry_id           in     com_api_type_pkg.t_number_tab
  , o_processed_entries         out com_api_type_pkg.t_integer_tab
  , o_excepted_entries          out com_api_type_pkg.t_integer_tab
  , i_save_exceptions        in     com_api_type_pkg.t_boolean
  , i_rounding_method        in     com_api_type_pkg.t_dict_tab
) is
    l_balance                       com_api_type_pkg.t_number_tab;
    l_balance_succ                  com_api_type_pkg.t_number_tab;
    l_split_hash                    com_api_type_pkg.t_number_tab;
    l_split_hash_succ               com_api_type_pkg.t_number_tab;
    l_rounding_balance              com_api_type_pkg.t_number_tab;
    l_rounding_balance_succ         com_api_type_pkg.t_number_tab;
    l_posting_order                 com_api_type_pkg.t_number_tab;
    l_posting_order_succ            com_api_type_pkg.t_number_tab;
    l_row_succ_count                com_api_type_pkg.t_count := 0;

    l_sttl_day                      com_api_type_pkg.t_number_tab;
    l_sttl_date                     com_api_type_pkg.t_date_tab;
    l_posting_date                  com_api_type_pkg.t_date_tab;

    l_inst_id                       com_api_type_pkg.t_inst_id_tab;
    l_inst_id_succ                  com_api_type_pkg.t_inst_id_tab;
    l_tran_type_succ                com_api_type_pkg.t_dict_tab;
    l_entry_id_succ                 com_api_type_pkg.t_number_tab;
    l_balance_id                    com_api_type_pkg.t_number_tab;
    l_active_balance_id             com_api_type_pkg.t_number_tab;
    l_balance_status                com_api_type_pkg.t_dict_tab;
    l_status                        com_api_type_pkg.t_dict_value;
    l_params                        com_api_type_pkg.t_param_tab;
    l_bulk_result                   com_api_type_pkg.t_number_tab;
    l_rounding_error                com_api_type_pkg.t_number_tab;
begin
    if i_entry_id.count > 0 then
        trc_log_pkg.debug (
            i_text          => 'Posting [#1] entries on balance ...'
            , i_env_param1  => i_entry_id.count
        );

        forall i in 1 .. i_entry_id.count
            update
                acc_balance b
            set
                b.entry_count           = b.entry_count + 1
                , b.balance             = b.balance + i_balance_impact(i) * round(i_amount(i))
                , b.rounding_balance    = b.rounding_balance + i_balance_impact(i) * (i_amount(i) - round(i_amount(i)))
                , b.open_date           = case b.status when acc_api_const_pkg.BALANCE_STATUS_INACTIVE then get_sysdate else b.open_date end
                , b.open_sttl_date      = case b.status when acc_api_const_pkg.BALANCE_STATUS_INACTIVE then com_api_sttl_day_pkg.get_open_sttl_date(b.inst_id) else b.open_sttl_date end
            where
                b.account_id = i_account_id(i) and
                b.balance_type = i_balance_type(i) and
                b.currency = i_currency(i)
            returning
                b.entry_count
                , b.balance
                , b.rounding_balance
                , b.split_hash
                , b.inst_id
                , b.status
                , b.id
            bulk collect into
                l_posting_order_succ
                , l_balance_succ
                , l_rounding_balance_succ
                , l_split_hash_succ
                , l_inst_id_succ
                , l_balance_status
                , l_balance_id;

        for i in 1 .. i_entry_id.count loop
            l_bulk_result(i) := sql%bulk_rowcount(i);
        end loop;

        l_balance.delete;
        l_rounding_balance.delete;
        l_posting_order.delete;

        trc_log_pkg.debug (
            i_text          => 'Collecting results ...'
            , i_env_param1  => i_entry_id.count
        );

        for i in 1 .. i_entry_id.count loop
            trc_log_pkg.debug (
                i_text          => 'Entry [#1] result [#2]'
              , i_env_param1    => i_entry_id(i)
              , i_env_param2    => l_bulk_result(i)
            );
        end loop;

        for i in 1 .. i_entry_id.count loop
            trc_log_pkg.debug (
                i_text          => 'Processing results for entry [#1] result [#2]'
                , i_env_param1  => i_entry_id(i)
                , i_env_param2  => l_bulk_result(i)
            );
        
            if l_bulk_result(i) > 0 then
                -- the  "returning bulk collect into" return only successfult updates results
                -- so we are going to build result arrays to allow match incoming arrays with result arrays 
                o_processed_entries(o_processed_entries.count + 1) := i;
                l_row_succ_count                                   := l_row_succ_count + 1;
                l_balance(l_balance.count + 1)                     := l_balance_succ(l_row_succ_count);
                l_rounding_balance(l_rounding_balance.count + 1)   := l_rounding_balance_succ(l_row_succ_count);
                l_posting_order(l_posting_order.count + 1)         := l_posting_order_succ(l_row_succ_count);
                l_split_hash(l_split_hash.count + 1)               := l_split_hash_succ(l_row_succ_count);
                l_entry_id_succ(l_entry_id_succ.count + 1)         := i_entry_id(i);
                l_tran_type_succ(l_tran_type_succ.count + 1)       := i_transaction_type(i);

                l_sttl_day(l_sttl_day.count + 1)                   := com_api_sttl_day_pkg.get_open_sttl_day(l_inst_id_succ(l_row_succ_count));
                l_sttl_date(l_sttl_date.count + 1)                 := com_api_sttl_day_pkg.get_open_sttl_date(l_inst_id_succ(l_row_succ_count));
                l_posting_date(l_posting_date.count + 1)           := com_api_sttl_day_pkg.get_sysdate;
                l_inst_id(l_inst_id.count + 1)                     := l_inst_id_succ(l_row_succ_count);
                l_rounding_error(l_rounding_error.count + 1)       := case i_rounding_method(i)
                                                                          when acc_api_const_pkg.ROUNDING_METHOD_DEFAULT      then i_amount(i)
                                                                          when acc_api_const_pkg.ROUNDING_METHOD_TWO_DECIMALS then round(i_amount(i), 2)
                                                                                                                              else i_amount(i)
                                                                      end - round(i_amount(i));

                -- check for dublicated balances to prevent call change status procedure twice
                if l_balance_status(l_row_succ_count) = acc_api_const_pkg.BALANCE_STATUS_INACTIVE then
                    for r in 1..l_active_balance_id.count loop
                        if l_active_balance_id(r) = l_balance_id(l_row_succ_count) then
                            l_balance_status(l_row_succ_count) := acc_api_const_pkg.BALANCE_STATUS_ACTIVE;
                            exit;
                        end if;
                    end loop;
                end if;

                if l_balance_status(l_row_succ_count) = acc_api_const_pkg.BALANCE_STATUS_INACTIVE then
                    trc_log_pkg.debug (
                        i_text          => 'Going to activate balance [#1]'
                        , i_env_param1  => l_balance_id(l_row_succ_count)
                    );

                    rul_api_param_pkg.set_param (
                        io_params   => l_params
                      , i_name      => 'BALANCE_TYPE'
                      , i_value     => i_balance_type(i)
                    );
                    rul_api_param_pkg.set_param (
                        io_params   => l_params
                      , i_name      => 'CURRENCY'
                      , i_value     => i_currency(i)
                    );

                    evt_api_status_pkg.change_status(
                        i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                      , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_BALANCE
                      , i_object_id      => l_balance_id(l_row_succ_count)
                      , i_new_status     => acc_api_const_pkg.BALANCE_STATUS_ACTIVE
                      , i_eff_date       => get_sysdate
                      , i_reason         => null
                      , o_status         => l_status
                      , i_raise_error    => com_api_const_pkg.TRUE
                      , i_register_event => com_api_const_pkg.TRUE
                      , i_params         => l_params
                    );

                    l_active_balance_id(l_active_balance_id.count + 1) := l_balance_id(l_row_succ_count);
                end if;

            else
                o_excepted_entries(o_excepted_entries.count + 1) := i;
                l_balance(l_balance.count + 1)                   := null;
                l_rounding_balance(l_rounding_balance.count + 1) := null;
                l_posting_order(l_posting_order.count + 1)       := null;
                l_inst_id(l_inst_id.count + 1)                   := null;
                l_split_hash(l_split_hash.count + 1)             := null;
                l_sttl_day(l_sttl_day.count + 1)                 := null;
                l_sttl_date(l_sttl_date.count + 1)               := null;
                l_posting_date(l_posting_date.count + 1)         := null;
                l_rounding_error(l_rounding_error.count + 1)     := null;
            end if;
        end loop;

        trc_log_pkg.debug (
            i_text          => 'Processed [#1] Excepted [#2]'
            , i_env_param1  => o_processed_entries.count
            , i_env_param2  => o_excepted_entries.count
        );

        if o_processed_entries.count > 0 then
            trc_log_pkg.debug (
                i_text        => 'Saving [#1] successfull entries ...'
              , i_env_param1  => o_processed_entries.count
            );

            forall i in values of o_processed_entries
                insert into acc_entry (
                    id
                  , split_hash
                  , macros_id
                  , bunch_id
                  , transaction_id
                  , transaction_type
                  , account_id
                  , amount
                  , currency
                  , balance_type
                  , balance_impact
                  , balance
                  , rounding_balance
                  , posting_date
                  , posting_order
                  , sttl_day
                  , sttl_date
                  , ref_entry_id
                  , status
                  , rounding_error
                ) values (
                    i_entry_id(i)
                  , l_split_hash(i)
                  , i_macros_id(i)
                  , i_bunch_id(i)
                  , i_transaction_id(i)
                  , i_transaction_type(i)
                  , i_account_id(i)
                  , round(i_amount(i))
                  , i_currency(i)
                  , i_balance_type(i)
                  , i_balance_impact(i)
                  , l_balance(i)
                  , l_rounding_balance(i)
                  , l_posting_date(i)
                  , l_posting_order(i)
                  , l_sttl_day(i)
                  , l_sttl_date(i)
                  , i_ref_entry_id(i)
                  , nvl(i_status(i), acc_api_const_pkg.ENTRY_STATUS_POSTED)
                  , l_rounding_error(i)
                );

            -- register event
            for i in 1 .. o_processed_entries.count loop
                l_params.delete;

                rul_api_param_pkg.set_param (
                    io_params  => l_params
                  , i_name     => 'ACCOUNT_TYPE'
                  , i_value    => i_account_type(o_processed_entries(i))
                );
                rul_api_param_pkg.set_param (
                    io_params  => l_params
                  , i_name     => 'BALANCE_TYPE'
                  , i_value    => i_balance_type(o_processed_entries(i))
                );
                rul_api_param_pkg.set_param (
                    io_params  => l_params
                  , i_name     => 'MACROS_TYPE'
                  , i_value    => i_macros_type(o_processed_entries(i))
                );
                rul_api_param_pkg.set_param (
                    io_params  => l_params
                  , i_name     => 'TRANSACTION_TYPE'
                  , i_value    => i_transaction_type(o_processed_entries(i))
                );
                rul_api_param_pkg.set_param (
                    io_params  => l_params
                  , i_name     => 'BALANCE_IMPACT'
                  , i_value    => i_balance_impact(o_processed_entries(i))
                );

                evt_api_event_pkg.register_event(
                    i_event_type        => acc_api_const_pkg.EVENT_ENTRY_POSTING
                  , i_eff_date          => l_posting_date(i)
                  , i_param_tab         => l_params
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ENTRY
                  , i_object_id         => i_entry_id(o_processed_entries(i))
                  , i_inst_id           => l_inst_id(o_processed_entries(i))
                  , i_split_hash        => l_split_hash(o_processed_entries(i))
                );
            end loop;
        end if;

        if o_excepted_entries.count > 0 then
            trc_log_pkg.debug (
                i_text        => 'Processing [#1] excepted entries ...'
              , i_env_param1  => o_excepted_entries.count
            );

            if i_save_exceptions = com_api_type_pkg.TRUE then
                forall i in values of o_excepted_entries
                    insert into acc_entry_buffer ( -- acc_entry_exception
                        id
                      , split_hash
                      , macros_id
                      , bunch_id
                      , transaction_id
                      , transaction_type
                      , account_id
                      , amount
                      , currency
                      , account_type
                      , balance_type
                      , balance_impact
                      , dest_entity_type
                      , dest_account_type
                      , reason
                      , status
                    ) select
                        i_entry_id(i)
                      , a.split_hash
                      , i_macros_id(i)
                      , i_bunch_id(i)
                      , i_transaction_id(i)
                      , i_transaction_type(i)
                      , a.id
                      , i_amount(i)
                      , i_currency(i)
                      , i_account_type(i)
                      , i_balance_type(i)
                      , i_balance_impact(i)
                      , i_transf_entity(i)
                      , i_transf_type(i)
                      , acc_api_const_pkg.ENTRY_EXCEPTION_NO_BALANCE
                      , acc_api_const_pkg.ENTRY_SOURCE_EXCEPTION
                    from
                        acc_account a
                    where
                        a.id = i_original_account_id(i)
                    ;
            end if;

            for i in 1 .. o_excepted_entries.count loop
                trc_log_pkg.error (
                    i_text          => 'ERROR_POSTING_ENTRY_ON_BALANCE'
                    , i_env_param1  => i_entry_id(o_excepted_entries(i))
                    , i_env_param2  => i_original_account_id(o_excepted_entries(i))
                    , i_env_param3  => i_transf_entity(o_excepted_entries(i)) || ':' || i_transf_type(o_excepted_entries(i))
                    , i_env_param4  => i_account_id(o_excepted_entries(i))
                    , i_env_param5  => i_balance_type(o_excepted_entries(i)) || ':' || i_balance_impact(o_excepted_entries(i))
                    , i_env_param6  => i_amount(o_excepted_entries(i)) || ':' || i_currency(o_excepted_entries(i))
                    , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ENTRY
                    , i_object_id   => i_entry_id(o_excepted_entries(i))
                );
            end loop;
        end if;
    end if;
end post_entries;

procedure flush_immediate_entries (
    entries       in out nocopy t_entry_template_tab
) is
    l_entry_id                  com_api_type_pkg.t_number_tab;
    l_macros_id                 com_api_type_pkg.t_number_tab;
    l_bunch_id                  com_api_type_pkg.t_number_tab;
    l_transaction_id            com_api_type_pkg.t_number_tab;
    l_transaction_type          com_api_type_pkg.t_name_tab;
    l_account_id                com_api_type_pkg.t_number_tab;
    l_original_account_id       com_api_type_pkg.t_number_tab;
    l_amount                    com_api_type_pkg.t_number_tab;
    l_currency                  com_api_type_pkg.t_name_tab;
    l_account_type              com_api_type_pkg.t_name_tab;
    l_balance_type              com_api_type_pkg.t_name_tab;
    l_balance_impact            com_api_type_pkg.t_number_tab;
    l_posting_date              com_api_type_pkg.t_date_tab;
    l_transf_entity             com_api_type_pkg.t_name_tab;
    l_transf_type               com_api_type_pkg.t_name_tab;
    l_macros_type               com_api_type_pkg.t_number_tab;
    l_processed_entries         com_api_type_pkg.t_integer_tab;
    l_excepted_entries          com_api_type_pkg.t_integer_tab;
    l_ref_id                    com_api_type_pkg.t_number_tab;
    l_status                    com_api_type_pkg.t_name_tab;
    l_rounding_method           com_api_type_pkg.t_dict_tab;
begin
    trc_log_pkg.debug (
        i_text      => 'Flushing immediate entries ...'
    );

    if entries.count > 0 then
        for i in 1 .. entries.count loop
            l_entry_id(i)               := entries(i).entry_id;
            l_macros_id(i)              := entries(i).macros_id;
            l_bunch_id(i)               := entries(i).bunch_id;
            l_transaction_id(i)         := entries(i).transaction_id;
            l_transaction_type(i)       := entries(i).transaction_type;
            l_original_account_id(i)    := entries(i).account_id;
            l_amount(i)                 := entries(i).amount;
            l_currency(i)               := entries(i).currency;
            l_account_type(i)           := entries(i).account_type;
            l_balance_type(i)           := entries(i).balance_type;
            l_balance_impact(i)         := entries(i).balance_impact;
            l_posting_date(i)           := entries(i).posting_date;
            l_transf_entity(i)          := entries(i).dest_entity_type;
            l_transf_type(i)            := entries(i).dest_account_type;
            l_macros_type(i)            := entries(i).macros_type;
            l_status(i)                 := entries(i).status;
            l_ref_id(i)                 := entries(i).ref_entry_id;
            l_rounding_method(i)        := entries(i).rounding_method;

            if l_transf_entity(i) is null then
                l_account_id(i)             := l_original_account_id(i);
            
            elsif l_transf_entity(i) = ENTITY_TYPE_CUSTOMER then
                begin
                    select
                        a2.id
                    into
                        l_account_id(i)
                    from
                        acc_account a
                        , acc_account a2
                    where
                        a.id = l_original_account_id(i)
                        and a.customer_id = a2.customer_id
                        and a2.currency = l_currency(i)
                        and a2.account_type = l_transf_type(i)
                        and a2.status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE ;
                exception
                    when others then
                        com_api_error_pkg.raise_error (
                            i_error     => 'DESTINATION_ACCOUNT_NOT_FOUND'
                        );
                end;
            
            else
                begin
                    select
                        g.id
                    into
                        l_account_id(i)
                    from
                        acc_account a
                        , acc_gl_account_mvw g
                    where
                        a.id = l_original_account_id(i)
                        and g.entity_id = decode(l_transf_entity(i), ENTITY_TYPE_INSTITUTION, a.inst_id, ENTITY_TYPE_AGENT, a.agent_id)
                        and g.entity_type = l_transf_entity(i)
                        and g.account_type = l_transf_type(i)
                        and g.currency = l_currency(i);
                exception
                    when others then
                        com_api_error_pkg.raise_error (
                            i_error     => 'DESTINATION_ACCOUNT_NOT_FOUND'
                        );
                end;
            end if;
        end loop;

        entries.delete;

        post_entries (
            i_entry_id               => l_entry_id
            , i_macros_id            => l_macros_id
            , i_bunch_id             => l_bunch_id
            , i_transaction_id       => l_transaction_id
            , i_transaction_type     => l_transaction_type
            , i_account_id           => l_account_id
            , i_amount               => l_amount
            , i_currency             => l_currency
            , i_account_type         => l_account_type
            , i_balance_type         => l_balance_type
            , i_balance_impact       => l_balance_impact
            , i_original_account_id  => l_account_id
            , i_transf_entity        => l_transf_entity
            , i_transf_type          => l_transf_type
            , i_macros_type          => l_macros_type
            , i_status               => l_status
            , i_ref_entry_id         => l_ref_id
            , o_processed_entries    => l_processed_entries
            , o_excepted_entries     => l_excepted_entries
            , i_save_exceptions      => com_api_type_pkg.FALSE
            , i_rounding_method      => l_rounding_method
        );

        if l_excepted_entries.count > 0 then
            com_api_error_pkg.raise_error (
                i_error         => 'ERROR_POSTING_IMMEDIATE_ENTRIES'
            );
        end if;
    end if;
end flush_immediate_entries;

procedure flush_pending_entries (
    entries       in out nocopy t_entry_template_tab
) is
    l_bunch_id                  com_api_type_pkg.t_number_tab;
    l_entry_id                  com_api_type_pkg.t_number_tab;
    l_macros_id                 com_api_type_pkg.t_number_tab;
    l_transaction_id            com_api_type_pkg.t_number_tab;
    l_transaction_type          com_api_type_pkg.t_name_tab;
    l_account_id                com_api_type_pkg.t_number_tab;
    l_amount                    com_api_type_pkg.t_number_tab;
    l_currency                  com_api_type_pkg.t_name_tab;
    l_account_type              com_api_type_pkg.t_name_tab;
    l_balance_type              com_api_type_pkg.t_name_tab;
    l_balance_impact            com_api_type_pkg.t_number_tab;
    l_posting_date              com_api_type_pkg.t_date_tab;
    l_transf_entity             com_api_type_pkg.t_name_tab;
    l_transf_type               com_api_type_pkg.t_name_tab;
begin
    if entries.count > 0 then
        for i in 1 .. entries.count loop
            l_entry_id(i)        := entries(i).entry_id;
            l_macros_id(i)       := entries(i).macros_id;
            l_bunch_id(i)        := entries(i).bunch_id;
            l_transaction_id(i)  := entries(i).transaction_id;
            l_transaction_type(i):= entries(i).transaction_type;
            l_account_id(i)      := entries(i).account_id;
            l_amount(i)          := entries(i).amount;
            l_currency(i)        := entries(i).currency;
            l_account_type(i)    := entries(i).account_type;
            l_balance_type(i)    := entries(i).balance_type;
            l_balance_impact(i)  := entries(i).balance_impact;
            l_posting_date(i)    := entries(i).posting_date;
            l_transf_entity(i)   := entries(i).dest_entity_type;
            l_transf_type(i)     := entries(i).dest_account_type;
        end loop;

        forall i in 1 .. entries.count
            insert into acc_entry_buffer (
                id
                , split_hash
                , macros_id
                , bunch_id
                , transaction_id
                , transaction_type
                , account_id
                , amount
                , currency
                , account_type
                , balance_type
                , balance_impact
                , posting_date
                , dest_entity_type
                , dest_account_type
                , status
            ) select
                l_entry_id(i)
                , a.split_hash
                , l_macros_id(i)
                , l_bunch_id(i)
                , l_transaction_id(i)
                , l_transaction_type(i)
                , l_account_id(i)
                , l_amount(i)
                , l_currency(i)
                , l_account_type(i)
                , l_balance_type(i)
                , l_balance_impact(i)
                , l_posting_date(i)
                , l_transf_entity(i)
                , l_transf_type(i)
                , acc_api_const_pkg.ENTRY_SOURCE_PENDING
            from
                acc_account a
            where
                a.id = l_account_id(i)
            ;

        entries.delete;
    end if;
end flush_pending_entries;

procedure save_into_entry_buffer (
    i_entry_id             in     com_api_type_pkg.t_number_tab
  , i_macros_id            in     com_api_type_pkg.t_number_tab
  , i_bunch_id             in     com_api_type_pkg.t_number_tab
  , i_transaction_id       in     com_api_type_pkg.t_number_tab
  , i_transaction_type     in     com_api_type_pkg.t_name_tab
  , i_account_id           in     com_api_type_pkg.t_number_tab
  , i_amount               in     com_api_type_pkg.t_number_tab
  , i_currency             in     com_api_type_pkg.t_name_tab
  , i_account_type         in     com_api_type_pkg.t_name_tab
  , i_balance_type         in     com_api_type_pkg.t_name_tab
  , i_balance_impact       in     com_api_type_pkg.t_number_tab
  , i_transf_entity        in     com_api_type_pkg.t_name_tab
  , i_transf_type          in     com_api_type_pkg.t_name_tab
  , i_posting_method       in     com_api_type_pkg.t_name_tab
  , i_posting_date         in     com_api_type_pkg.t_date_tab
  , i_save_exceptions      in     boolean
  , o_exceptions              out com_api_type_pkg.t_integer_tab
  , o_success                 out com_api_type_pkg.t_integer_tab
) is
    l_exact_account               com_api_type_pkg.t_integer_tab;
    l_transform_cust_account      com_api_type_pkg.t_integer_tab;
    l_transform_gl_account        com_api_type_pkg.t_integer_tab;
    l_status                      com_api_type_pkg.t_name_tab;
begin
    trc_log_pkg.debug (
        i_text          => 'Request to save [#1] entries into buffer'
        , i_env_param1  => i_entry_id.count
    );

    if i_entry_id.count > 0 then
        for i in 1 .. i_transf_entity.count loop
            if i_transf_entity(i) is not null then
                if i_transf_entity(i) = ENTITY_TYPE_CUSTOMER then
                    l_transform_cust_account(l_transform_cust_account.count + 1) := i;
                else
                    l_transform_gl_account(l_transform_gl_account.count + 1) := i;
                end if;
            else
                l_exact_account(l_exact_account.count + 1) := i;
                o_success(o_success.count + 1) := i;
            end if;
            
            if i_posting_method(i) = acc_api_const_pkg.POSTING_METHOD_RESERV then
                l_status(i) := acc_api_const_pkg.ENTRY_SOURCE_RESERV;
            else
                l_status(i) := acc_api_const_pkg.ENTRY_SOURCE_BUFFER;
            end if;
        end loop;

        trc_log_pkg.debug (
            i_text          => 'Request to save [#1] entries into buffer of transform customer account'
            , i_env_param1  => l_transform_cust_account.count
        );
        trc_log_pkg.debug (
            i_text          => 'Request to save [#1] entries into buffer of transform gl account'
            , i_env_param1  => l_transform_gl_account.count
        );
        trc_log_pkg.debug (
            i_text          => 'Request to save [#1] entries into buffer of exact account'
            , i_env_param1  => l_exact_account.count
        );

        if l_transform_cust_account.count > 0 then
            forall i in values of l_transform_cust_account
                insert into acc_entry_buffer (
                    id
                    , split_hash
                    , macros_id
                    , bunch_id
                    , transaction_id
                    , transaction_type
                    , account_id
                    , amount
                    , currency
                    , account_type
                    , balance_type
                    , balance_impact
                    , dest_entity_type
                    , dest_account_type
                    , dest_account_id
                    , status
                    , posting_date
                ) select
                    i_entry_id(i)
                    , a2.split_hash
                    , i_macros_id(i)
                    , i_bunch_id(i)
                    , i_transaction_id(i)
                    , i_transaction_type(i)
                    , i_account_id(i)
                    , i_amount(i)
                    , i_currency(i)
                    , i_account_type(i)
                    , i_balance_type(i)
                    , i_balance_impact(i)
                    , i_transf_entity(i)
                    , i_transf_type(i)
                    , a2.id
                    , l_status(i) --acc_api_const_pkg.ENTRY_SOURCE_BUFFER
                    , i_posting_date(i)
                from
                    acc_account a
                    , acc_account a2
                where
                    a.id = i_account_id(i)
                    and a.customer_id = a2.customer_id
                    and a2.currency = i_currency(i)
                    and a2.account_type = i_transf_type(i)
                    and a2.status = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
                ;
        end if;
        
        for i in 1 .. l_transform_cust_account.count loop
            if sql%bulk_rowcount(l_transform_cust_account(i)) > 0 then
                o_success(o_success.count + 1) := l_transform_cust_account(i);
            else
                o_exceptions(o_exceptions.count + 1) := l_transform_cust_account(i);
            end if;
        end loop;
        
        if l_transform_gl_account.count > 0 then
            forall i in values of l_transform_gl_account
                insert into acc_entry_buffer (
                    id
                    , split_hash
                    , macros_id
                    , bunch_id
                    , transaction_id
                    , transaction_type
                    , account_id
                    , amount
                    , currency
                    , account_type
                    , balance_type
                    , balance_impact
                    , dest_entity_type
                    , dest_account_type
                    , dest_account_id
                    , status
                    , posting_date
                ) select
                    i_entry_id(i)
                    , g.split_hash
                    , i_macros_id(i)
                    , i_bunch_id(i)
                    , i_transaction_id(i)
                    , i_transaction_type(i)
                    , i_account_id(i)
                    , i_amount(i)
                    , i_currency(i)
                    , i_account_type(i)
                    , i_balance_type(i)
                    , i_balance_impact(i)
                    , i_transf_entity(i)
                    , i_transf_type(i)
                    , g.id
                    , l_status(i) --acc_api_const_pkg.ENTRY_SOURCE_BUFFER
                    , i_posting_date(i)
                from
                    acc_account a
                    , acc_gl_account_mvw g
                where
                    a.id = i_account_id(i)
                    and g.entity_id = decode(i_transf_entity(i), ENTITY_TYPE_INSTITUTION, a.inst_id, ENTITY_TYPE_AGENT, a.agent_id)
                    and g.entity_type = i_transf_entity(i)
                    and g.account_type = i_transf_type(i)
                    and g.currency = i_currency(i)
                ;
        end if;

        for i in 1 .. l_transform_gl_account.count loop
            if sql%bulk_rowcount(l_transform_gl_account(i)) > 0 then
                o_success(o_success.count + 1) := l_transform_gl_account(i);
            else
                o_exceptions(o_exceptions.count + 1) := l_transform_gl_account(i);
            end if;
        end loop;

        if o_exceptions.count > 0 then
            if i_save_exceptions then
                forall i in values of o_exceptions
                    insert into acc_entry_buffer (
                        id
                        , split_hash
                        , macros_id
                        , bunch_id
                        , transaction_id
                        , transaction_type
                        , account_id
                        , amount
                        , currency
                        , account_type
                        , balance_type
                        , balance_impact
                        , dest_entity_type
                        , dest_account_type
                        , reason
                        , status
                    ) select
                        i_entry_id(i)
                        , a.split_hash
                        , i_macros_id(i)
                        , i_bunch_id(i)
                        , i_transaction_id(i)
                        , i_transaction_type(i)
                        , i_account_id(i)
                        , i_amount(i)
                        , i_currency(i)
                        , i_account_type(i)
                        , i_balance_type(i)
                        , i_balance_impact(i)
                        , i_transf_entity(i)
                        , i_transf_type(i)
                        , acc_api_const_pkg.ENTRY_EXCEPTION_NO_ACCOUNT
                        , acc_api_const_pkg.ENTRY_SOURCE_EXCEPTION
                    from
                        acc_account a
                    where
                        a.id = i_account_id(i);
            end if;

            for i in 1 .. o_exceptions.count loop
                trc_log_pkg.error (
                    i_text          => 'ERROR_POSTING_ENTRY_INTO_BUFFER'
                    , i_env_param1  => i_entry_id(o_exceptions(i))
                    , i_env_param2  => i_account_id(o_exceptions(i))
                    , i_env_param3  => i_transf_entity(o_exceptions(i))
                    , i_env_param4  => i_transf_type(o_exceptions(i))
                    , i_env_param5  => i_currency(o_exceptions(i))
                    , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ENTRY
                    , i_object_id   => i_entry_id(o_exceptions(i))
                );
            end loop;
        end if;

        if l_exact_account.count > 0 then
            forall i in values of l_exact_account
                insert into acc_entry_buffer (
                    id
                    , split_hash
                    , macros_id
                    , bunch_id
                    , transaction_id
                    , transaction_type
                    , account_id
                    , amount
                    , currency
                    , account_type
                    , balance_type
                    , balance_impact
                    , dest_entity_type
                    , dest_account_type
                    , dest_account_id
                    , status
                    , posting_date
                ) select
                    i_entry_id(i)
                    , a.split_hash
                    , i_macros_id(i)
                    , i_bunch_id(i)
                    , i_transaction_id(i)
                    , i_transaction_type(i)
                    , i_account_id(i)
                    , i_amount(i)
                    , i_currency(i)
                    , i_account_type(i)
                    , i_balance_type(i)
                    , i_balance_impact(i)
                    , i_transf_entity(i)
                    , i_transf_type(i)
                    , i_account_id(i)
                    , l_status(i) --acc_api_const_pkg.ENTRY_SOURCE_BUFFER
                    , i_posting_date(i)
                from
                    acc_account a
                where
                    a.id = i_account_id(i);
        end if;
    end if;
end save_into_entry_buffer;

procedure flush_buffered_entries (
   entries        in out nocopy t_entry_template_tab
) is
    l_entry_id                  com_api_type_pkg.t_number_tab;
    l_macros_id                 com_api_type_pkg.t_number_tab;
    l_bunch_id                  com_api_type_pkg.t_number_tab;
    l_transaction_id            com_api_type_pkg.t_number_tab;
    l_transaction_type          com_api_type_pkg.t_name_tab;
    l_account_id                com_api_type_pkg.t_number_tab;
    l_amount                    com_api_type_pkg.t_number_tab;
    l_currency                  com_api_type_pkg.t_name_tab;
    l_account_type              com_api_type_pkg.t_name_tab;
    l_balance_type              com_api_type_pkg.t_name_tab;
    l_balance_impact            com_api_type_pkg.t_number_tab;
    l_transf_entity             com_api_type_pkg.t_name_tab;
    l_transf_type               com_api_type_pkg.t_name_tab;
    l_posting_method            com_api_type_pkg.t_name_tab;
    l_posting_date              com_api_type_pkg.t_date_tab;

    l_exceptions                com_api_type_pkg.t_integer_tab;
    l_success                   com_api_type_pkg.t_integer_tab;
begin
    trc_log_pkg.debug (
        i_text          => 'Flushing [#1] entries to buffer'
        , i_env_param1  => entries.count
    );

    if entries.count > 0 then
        for i in 1 .. entries.count loop
            l_entry_id(i)           := entries(i).entry_id;
            l_macros_id(i)          := entries(i).macros_id;
            l_bunch_id(i)           := entries(i).bunch_id;
            l_transaction_id(i)     := entries(i).transaction_id;
            l_transaction_type(i)   := entries(i).transaction_type;
            l_account_id(i)         := entries(i).account_id;
            l_amount(i)             := entries(i).amount;
            l_currency(i)           := entries(i).currency;
            l_account_type(i)       := entries(i).account_type;
            l_balance_type(i)       := entries(i).balance_type;
            l_balance_impact(i)     := entries(i).balance_impact;
            l_transf_entity(i)      := entries(i).dest_entity_type;
            l_transf_type(i)        := entries(i).dest_account_type;
            l_posting_method(i)     := entries(i).posting_method;  
            l_posting_date(i)       := entries(i).posting_date;  
        end loop;

        save_into_entry_buffer (
            i_entry_id              => l_entry_id
            , i_macros_id           => l_macros_id
            , i_bunch_id            => l_bunch_id
            , i_transaction_id      => l_transaction_id
            , i_transaction_type    => l_transaction_type
            , i_account_id          => l_account_id
            , i_amount              => l_amount
            , i_currency            => l_currency
            , i_account_type        => l_account_type
            , i_balance_type        => l_balance_type
            , i_balance_impact      => l_balance_impact
            , i_transf_entity       => l_transf_entity
            , i_transf_type         => l_transf_type
            , i_posting_method      => l_posting_method
            , i_posting_date        => l_posting_date
            , i_save_exceptions     => true
            , o_exceptions          => l_exceptions
            , o_success             => l_success
        );

        entries.delete;
    end if;
end flush_buffered_entries;

procedure flush_bulk_entries (
   entries        in out nocopy t_entry_template_tab
) is
    l_entry_id                  com_api_type_pkg.t_number_tab;
    l_macros_id                 com_api_type_pkg.t_number_tab;
    l_bunch_id                  com_api_type_pkg.t_number_tab;
    l_transaction_id            com_api_type_pkg.t_number_tab;
    l_transaction_type          com_api_type_pkg.t_name_tab;
    l_account_id                com_api_type_pkg.t_number_tab;
    l_amount                    com_api_type_pkg.t_number_tab;
    l_currency                  com_api_type_pkg.t_name_tab;
    l_account_type              com_api_type_pkg.t_name_tab;
    l_balance_type              com_api_type_pkg.t_name_tab;
    l_balance_impact            com_api_type_pkg.t_number_tab;
    l_transf_entity             com_api_type_pkg.t_name_tab;
    l_transf_type               com_api_type_pkg.t_name_tab;
    l_macros_type               com_api_type_pkg.t_number_tab;
    l_processed_entries         com_api_type_pkg.t_integer_tab;
    l_excepted_entries          com_api_type_pkg.t_integer_tab;
    l_ref_id                    com_api_type_pkg.t_number_tab;
    l_status                    com_api_type_pkg.t_name_tab;
    l_rounding_method           com_api_type_pkg.t_dict_tab;
begin
    if entries.count > 0 then
        for i in 1 .. entries.count loop
            l_entry_id(i)            := entries(i).entry_id;
            l_macros_id(i)           := entries(i).macros_id;
            l_bunch_id(i)            := entries(i).bunch_id;
            l_transaction_id(i)      := entries(i).transaction_id;
            l_transaction_type(i)    := entries(i).transaction_type;
            l_account_id(i)          := entries(i).account_id;
            l_amount(i)              := entries(i).amount;
            l_currency(i)            := entries(i).currency;
            l_account_type(i)        := entries(i).account_type;
            l_balance_type(i)        := entries(i).balance_type;
            l_balance_impact(i)      := entries(i).balance_impact;
            l_transf_entity(i)       := entries(i).dest_entity_type;
            l_transf_type(i)         := entries(i).dest_account_type;
            l_macros_type(i)         := entries(i).macros_type;
            l_status(i)              := entries(i).status;
            l_ref_id(i)              := entries(i).ref_entry_id;
            l_rounding_method(i)     := entries(i).rounding_method;
        end loop;

        entries.delete;

        post_entries (
            i_entry_id               => l_entry_id
            , i_macros_id            => l_macros_id
            , i_bunch_id             => l_bunch_id
            , i_transaction_id       => l_transaction_id
            , i_transaction_type     => l_transaction_type
            , i_account_id           => l_account_id
            , i_amount               => l_amount
            , i_currency             => l_currency
            , i_account_type         => l_account_type
            , i_balance_type         => l_balance_type
            , i_balance_impact       => l_balance_impact
            , i_original_account_id  => l_account_id
            , i_transf_entity        => l_transf_entity
            , i_transf_type          => l_transf_type
            , i_macros_type          => l_macros_type
            , i_status               => l_status
            , i_ref_entry_id         => l_ref_id
            , o_processed_entries    => l_processed_entries
            , o_excepted_entries     => l_excepted_entries
            , i_save_exceptions      => com_api_type_pkg.FALSE
            , i_rounding_method      => l_rounding_method
        );

        if l_excepted_entries.count > 0 then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'ERROR_POSTING_BULK_ENTRIES'
            );
        end if;
    end if;
end flush_bulk_entries;

procedure flush_entries is
begin
    if g_immediate_entries.count > 0 then
        flush_immediate_entries(
            entries     => g_immediate_entries
        );
    end if;

    if g_bulk_entries.count > 0 then
        flush_bulk_entries(
            entries     => g_bulk_entries
        );
    end if;

    if g_buffered_entries.count > 0 then
        flush_buffered_entries(
            entries     => g_buffered_entries
        );
    end if;

    if g_pending_entries.count > 0 then
        flush_pending_entries(
            entries     => g_pending_entries
        );
    end if;
end flush_entries;

procedure cancel_entries is
begin
    g_immediate_entries.delete;
    g_bulk_entries.delete;
    g_buffered_entries.delete;
    g_pending_entries.delete;
end;

procedure put_bunch_entries (
    i_template_cur       in     t_entry_template_cur
  , i_amount_tab         in     com_api_type_pkg.t_amount_by_name_tab
  , i_account_tab        in     acc_api_type_pkg.t_account_by_name_tab
  , i_date_tab           in     com_api_type_pkg.t_date_by_name_tab
  , i_macros_id          in     com_api_type_pkg.t_long_id
  , o_bunch_id              out com_api_type_pkg.t_long_id
  , o_bunch_type_id         out com_api_type_pkg.t_tiny_id
  , o_entry_count           out number
  , o_transaction_tab    in out nocopy acc_api_type_pkg.t_transaction_tab
  , i_param_tab          in     com_api_type_pkg.t_param_tab    
) is
    l_template_credit_tab       t_entry_template_tab;
    l_template_debit_tab        t_entry_template_tab;
    l_template_buffer_tab       t_entry_template_tab;
    l_template_tab              t_entry_template_tab;
    l_transaction_num           com_api_type_pkg.t_tiny_id;
    l_transaction_id            com_api_type_pkg.t_long_id;
    l_entry_count               binary_integer             := 0;
    l_transaction_count         binary_integer;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    
begin
    o_entry_count := 0;
    o_transaction_tab.delete;

    trc_log_pkg.debug (
        i_text      => 'Opening template cursor  ...'
    );

    if i_template_cur%isopen then
        
        fetch i_template_cur bulk collect into l_template_buffer_tab;
        close i_template_cur;
        
        for r in 1 .. l_template_buffer_tab.count loop
            
            if l_template_buffer_tab.exists(r) then
            
                if l_template_buffer_tab(r).balance_impact = com_api_const_pkg.CREDIT 
                   and 
                   not l_template_credit_tab.exists(l_template_buffer_tab(r).transaction_num) 
                   and
                   rul_api_mod_pkg.check_condition(
                       i_mod_id => l_template_buffer_tab(r).mod_id
                     , i_params => i_param_tab
                    ) = com_api_const_pkg.TRUE
                then
                
                    l_template_credit_tab(l_template_buffer_tab(r).transaction_num) := l_template_buffer_tab(r);
                    l_template_tab(l_template_tab.count + 1) := l_template_buffer_tab(r);
                    
                elsif l_template_buffer_tab(r).balance_impact = com_api_const_pkg.DEBIT 
                   and 
                   not l_template_debit_tab.exists(l_template_buffer_tab(r).transaction_num) 
                   and
                   rul_api_mod_pkg.check_condition(
                       i_mod_id => l_template_buffer_tab(r).mod_id
                     , i_params => i_param_tab
                    ) = com_api_const_pkg.TRUE
                then
                
                    l_template_debit_tab(l_template_buffer_tab(r).transaction_num) := l_template_buffer_tab(r);
                    l_template_tab(l_template_tab.count + 1) := l_template_buffer_tab(r);
                    
                end if;                
            
            end if;
        end loop;

    else
        return;
    end if;

    l_entry_count := l_template_tab.count;

    if l_entry_count > 0 then
        o_bunch_type_id := l_template_tab(1).bunch_type_id;
        o_bunch_id      := com_api_id_pkg.get_id(i_seq => acc_bunch_seq.nextval);
    else
        return;
    end if;

    trc_log_pkg.debug (
        i_text      => 'Filling entries  ...'
    );

    for i in 1 .. l_entry_count loop
        l_template_tab(i).entry_id        := com_api_id_pkg.get_id(i_seq => acc_entry_seq.nextval);
        l_template_tab(i).macros_id       := i_macros_id;
        l_template_tab(i).bunch_id        := o_bunch_id;
        l_template_tab(i).rounding_method := i_param_tab('ROUNDING_METHOD');

        if l_transaction_num = l_template_tab(i).transaction_num then
            null;
        else
            l_transaction_num := l_template_tab(i).transaction_num;
            l_transaction_id  := l_template_tab(i).entry_id;
        end if;
        l_template_tab(i).transaction_id := l_transaction_id;

        begin
            l_template_tab(i).account_id   := i_account_tab(l_template_tab(i).account_name).account_id;
            l_template_tab(i).account_type := i_account_tab(l_template_tab(i).account_name).account_type;
            l_split_hash                   := i_account_tab(l_template_tab(i).account_name).split_hash;                
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'ENTRY_PARAMETER_NOT_FOUND'
                  , i_env_param1  => 'ACCOUNT'
                  , i_env_param2  => l_template_tab(i).account_name
                );
        end;

        begin
            l_template_tab(i).amount   := i_amount_tab(l_template_tab(i).amount_name).amount;
            l_template_tab(i).currency := i_amount_tab(l_template_tab(i).amount_name).currency;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'ENTRY_PARAMETER_NOT_FOUND'
                  , i_env_param1  => 'AMOUNT'
                  , i_env_param2  => l_template_tab(i).amount_name
                );
        end;

        if l_template_tab(i).date_name is not null then
            begin
                l_template_tab(i).posting_date := i_date_tab(l_template_tab(i).date_name);
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error (
                        i_error       => 'ENTRY_PARAMETER_NOT_FOUND'
                      , i_env_param1  => 'DATE'
                      , i_env_param2  => l_template_tab(i).date_name
                    );
            end;
        end if;

        if l_template_tab(i).amount < 0 then
            if l_template_tab(i).negative_allowed = com_api_type_pkg.TRUE then
                l_template_tab(i).balance_impact := com_api_type_pkg.invert_sign(l_template_tab(i).balance_impact);
                l_template_tab(i).amount         := abs(l_template_tab(i).amount);
            else
                com_api_error_pkg.raise_error (
                    i_error         => 'NEGATIVE_AMOUNT_NOT_ALLOWED'
                    , i_env_param1  => l_template_tab(i).amount_name
                    , i_env_param2  => l_template_tab(i).amount
                );
            end if;
        end if;

        if l_template_tab(i).amount != 0 then
            trc_log_pkg.debug (
                i_text      => 'Posting method = ' || l_template_tab(i).posting_method || ' posting_date = ' || l_template_tab(i).posting_date 
            );

            if l_template_tab(i).posting_method = acc_api_const_pkg.POSTING_METHOD_IMMEDIATE then
                if com_api_hash_pkg.check_current_thread_number(i_split_hash => l_split_hash) = com_api_const_pkg.TRUE then
                    g_immediate_entries(g_immediate_entries.count + 1) := l_template_tab(i);
                    trc_log_pkg.debug (
                        i_text      => 'Immediate entry registered'
                    );
                else
                    g_buffered_entries(g_buffered_entries.count + 1) := l_template_tab(i);
                    trc_log_pkg.debug (
                        i_text      => 'Buffered entry registered'
                    );
                end if;

            elsif l_template_tab(i).posting_method = acc_api_const_pkg.POSTING_METHOD_BULK then
                if l_template_tab(i).posting_date is null then
                    g_bulk_entries(g_bulk_entries.count + 1) := l_template_tab(i);
                    trc_log_pkg.debug (
                        i_text      => 'Bulk entry registered'
                    );
                else
                    g_pending_entries(g_pending_entries.count + 1) := l_template_tab(i);
                    trc_log_pkg.debug (
                        i_text      => 'Pending entry registered'
                    );
                end if;

            elsif l_template_tab(i).posting_method = acc_api_const_pkg.POSTING_METHOD_RESERV then
                if l_template_tab(i).posting_date is null then
                    g_bulk_entries(g_bulk_entries.count + 1) := l_template_tab(i);
                    trc_log_pkg.debug (
                        i_text      => 'Bulk entry registered'
                    );
                else
                    g_buffered_entries(g_buffered_entries.count + 1) := l_template_tab(i);
                    trc_log_pkg.debug (
                        i_text      => 'Buffered entry registered'
                    );
                end if;

            else
                if l_template_tab(i).posting_date is null then
                    if com_api_hash_pkg.check_current_thread_number(i_split_hash => l_split_hash) = com_api_const_pkg.TRUE then
                        g_immediate_entries(g_immediate_entries.count + 1) := l_template_tab(i);
                        trc_log_pkg.debug (
                            i_text      => 'Immediate entry registered'
                        );
                    else
                        g_buffered_entries(g_buffered_entries.count + 1) := l_template_tab(i);
                        trc_log_pkg.debug (
                            i_text      => 'Buffered entry registered'
                        );
                    end if;
                else
                    g_pending_entries(g_pending_entries.count + 1) := l_template_tab(i);
                    trc_log_pkg.debug (
                        i_text      => 'Pending entry registered'
                    );
                end if;
            end if;

            trc_log_pkg.debug (
                i_text      => 'Collecting transaction ...'
            );

            if o_transaction_tab.count > 0 and o_transaction_tab(o_transaction_tab.last).transaction_id = l_template_tab(i).transaction_id then
                null;
            else
                l_transaction_count := o_transaction_tab.count + 1;
                o_transaction_tab(l_transaction_count).transaction_id   := l_template_tab(i).transaction_id;
                o_transaction_tab(l_transaction_count).transaction_type := l_template_tab(i).transaction_type;
                o_transaction_tab(l_transaction_count).macros_id        := l_template_tab(i).macros_id;
                o_transaction_tab(l_transaction_count).bunch_id         := l_template_tab(i).bunch_id;
                o_transaction_tab(l_transaction_count).split_hash       := l_split_hash;
                o_transaction_tab(l_transaction_count).posting_date     := get_sysdate;
                o_transaction_tab(l_transaction_count).inst_id          := i_account_tab(l_template_tab(i).account_name).inst_id;
                o_transaction_tab(l_transaction_count).balance_type     := l_template_tab(i).balance_type;
            end if;

            o_entry_count := o_entry_count + 1;
        end if;
    end loop;

    if g_immediate_entries.count > 0 then
        flush_immediate_entries(
            entries     => g_immediate_entries
        );
    end if;

    if g_bulk_entries.count > BULK_LIMIT then
        flush_bulk_entries(
            entries     => g_bulk_entries
        );
    end if;

    if g_buffered_entries.count > BULK_LIMIT then
        flush_buffered_entries(
            entries     => g_buffered_entries
        );
    end if;

    if g_pending_entries.count > BULK_LIMIT then
        flush_pending_entries(
            entries     => g_pending_entries
        );
    end if;

exception
    when others then
        if i_template_cur%isopen then
            close i_template_cur;
        end if;

        raise;
end put_bunch_entries;

procedure clear_macros_data is
begin
    g_macros_id.delete;
    g_entity_type.delete;
    g_object_id.delete;
    g_macros_type.delete;
    g_account.delete;
    g_amount.delete;
    g_currency.delete;
    g_amount_purpose.delete;
    g_fee_id.delete;
    g_fee_tier_id.delete;
    g_fee_mod_id.delete;
    g_details_data.delete;
    g_status.delete;
    g_conversion_rate.delete;
    g_rate_type.delete;
end;

procedure clear_bunch_data is
begin
    g_bunch_id.delete;
    g_bunch_macros_id.delete;
    g_bunch_type.delete;
    g_bunch_details_data.delete;
end;

procedure flush_macros is
begin
    trc_log_pkg.debug (
        i_text          => 'going to flush [#1] macros'
        , i_env_param1  => g_macros_type.count
    );

    forall i in 1 .. g_macros_type.count
        insert into acc_macros (
            id
            , entity_type
            , object_id
            , macros_type_id
            , posting_date
            , account_id
            , amount
            , currency
            , amount_purpose
            , fee_id
            , fee_tier_id
            , fee_mod_id
            , details_data
            , status
            , conversion_rate
            , rate_type
            , cancel_indicator
        ) values (
            g_macros_id(i)
            , g_entity_type(i)
            , g_object_id(i)
            , g_macros_type(i)
            , com_api_sttl_day_pkg.get_sysdate
            , g_account(i)
            , g_amount(i)
            , g_currency(i)
            , g_amount_purpose(i)
            , g_fee_id(i)
            , g_fee_tier_id(i)
            , g_fee_mod_id(i)
            , g_details_data(i)
            , g_status(i)
            , g_conversion_rate(i)
            , g_rate_type(i)
            , com_api_const_pkg.INDICATOR_NOT_CANCELED
        );

    clear_macros_data;

    trc_log_pkg.debug('flush macros COMPLETED');
end flush_macros;

procedure flush_bunch is
begin
    trc_log_pkg.debug (
        i_text          => 'going to flush [#1] bunches'
        , i_env_param1  => g_bunch_type.count
    );

    forall i in 1 .. g_bunch_type.count
        insert into acc_bunch (
            id
            , bunch_type_id
            , macros_id
            , posting_date
            , details_data
        ) values (
            g_bunch_id(i)
            , g_bunch_type(i)
            , g_bunch_macros_id(i)
            , com_api_sttl_day_pkg.get_sysdate
            , g_bunch_details_data(i)
        );

    clear_bunch_data;
end flush_bunch;

procedure cancel_macros is
begin
    clear_macros_data;
end;

procedure cancel_bunch is
begin
    clear_bunch_data;
end;

function allocate_macros_id return com_api_type_pkg.t_long_id is
begin
    return com_api_id_pkg.get_id(i_seq => acc_macros_seq.nextval);
end;

procedure create_macros (
    i_macros_id              in com_api_type_pkg.t_long_id
  , i_entity_type            in com_api_type_pkg.t_dict_value
  , i_object_id              in com_api_type_pkg.t_long_id
  , i_macros_type_id         in com_api_type_pkg.t_tiny_id
  , i_account_id             in com_api_type_pkg.t_medium_id
  , i_amount                 in com_api_type_pkg.t_money
  , i_currency               in com_api_type_pkg.t_curr_code
  , i_amount_purpose         in com_api_type_pkg.t_dict_value
  , i_fee_id                 in com_api_type_pkg.t_short_id
  , i_fee_tier_id            in com_api_type_pkg.t_short_id
  , i_fee_mod_id             in com_api_type_pkg.t_tiny_id
  , i_details_data           in com_api_type_pkg.t_full_desc
  , i_status                 in com_api_type_pkg.t_dict_value := null
  , i_conversion_rate        in com_api_type_pkg.t_rate
  , i_rate_type              in com_api_type_pkg.t_dict_value
) is
    i                           com_api_type_pkg.t_count := 0;
begin
    i := g_macros_type.count + 1;

    trc_log_pkg.debug(
        i_text       => 'Create macros [' || i || ']: id [' || i_macros_id || '], entity [#1][' || i_object_id
                     || '], macros type [' || i_macros_type_id || ']'
      , i_env_param1 => i_entity_type
    );

    g_macros_id(i)          := i_macros_id;

    g_entity_type(i)        := i_entity_type;
    g_object_id(i)          := i_object_id;
    g_macros_type(i)        := i_macros_type_id;

    g_account(i)            := i_account_id;
    g_amount(i)             := round(i_amount);
    g_currency(i)           := i_currency;

    g_amount_purpose(i)     := i_amount_purpose;
    g_fee_id(i)             := i_fee_id;
    g_fee_tier_id(i)        := i_fee_tier_id;
    g_fee_mod_id(i)         := i_fee_mod_id;
    g_details_data(i)       := i_details_data;
    g_conversion_rate(i)    := i_conversion_rate;
    g_rate_type(i)          := i_rate_type;

    g_status(i)             := nvl(i_status, acc_api_const_pkg.MACROS_STATUS_POSTED);

    if i >= BULK_LIMIT then
        flush_macros;
    end if;
    
    trc_log_pkg.debug('Create macros [' || i || '] COMPLETED');
end create_macros;

procedure create_bunch (
    i_bunch_id               in com_api_type_pkg.t_long_id
  , i_bunch_type_id          in com_api_type_pkg.t_tiny_id
  , i_macros_id              in com_api_type_pkg.t_long_id
  , i_details_data           in com_api_type_pkg.t_full_desc
) is
    i                           binary_integer;
begin
    if i_bunch_id is not null then
        i := g_bunch_type.count + 1;

        g_bunch_id(i) := i_bunch_id;
        g_bunch_macros_id(i) := i_macros_id;
        g_bunch_type(i) := i_bunch_type_id;
        g_bunch_details_data(i) := i_details_data;

        if i >= BULK_LIMIT then
            flush_bunch;
        end if;
    end if;
end create_bunch;

procedure raise_transaction_registration(
    i_transaction_tab           in out nocopy acc_api_type_pkg.t_transaction_tab
) is
    l_params                    com_api_type_pkg.t_param_tab;
begin
    for i in 1 .. i_transaction_tab.count loop
        l_params('TRANSACTION_TYPE') := i_transaction_tab(i).transaction_type;
        l_params('MACROS_ID')        := i_transaction_tab(i).macros_id;
        l_params('BUNCH_ID')         := i_transaction_tab(i).bunch_id;
        l_params('BALANCE_TYPE')     := i_transaction_tab(i).balance_type;

        evt_api_event_pkg.register_event(
            i_event_type        => acc_api_const_pkg.EVENT_TRANSACTION_REGISTERED
          , i_eff_date          => i_transaction_tab(i).posting_date
          , i_param_tab         => l_params
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
          , i_object_id         => i_transaction_tab(i).transaction_id
          , i_inst_id           => i_transaction_tab(i).inst_id
          , i_split_hash        => i_transaction_tab(i).split_hash
        );
    end loop;
end;

procedure put_macros (
    o_macros_id             out com_api_type_pkg.t_long_id
  , o_bunch_id              out com_api_type_pkg.t_long_id
  , i_entity_type        in     com_api_type_pkg.t_dict_value
  , i_object_id          in     com_api_type_pkg.t_long_id
  , i_macros_type_id     in     com_api_type_pkg.t_tiny_id
  , i_amount_tab         in     com_api_type_pkg.t_amount_by_name_tab
  , i_account_tab        in     acc_api_type_pkg.t_account_by_name_tab
  , i_date_tab           in     com_api_type_pkg.t_date_by_name_tab
  , i_amount_name        in     com_api_type_pkg.t_oracle_name
  , i_account_name       in     com_api_type_pkg.t_oracle_name
  , i_amount_purpose     in     com_api_type_pkg.t_dict_value
  , i_fee_id             in     com_api_type_pkg.t_short_id
  , i_fee_tier_id        in     com_api_type_pkg.t_short_id
  , i_fee_mod_id         in     com_api_type_pkg.t_tiny_id
  , i_details_data       in     com_api_type_pkg.t_full_desc
  , i_param_tab          in     com_api_type_pkg.t_param_tab
) is
    l_bunch_type_id             com_api_type_pkg.t_inst_id;
    l_template_cur              t_entry_template_cur;
    l_account                   acc_api_type_pkg.t_account_rec;
    l_amount                    com_api_type_pkg.t_money;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_entry_count               number;
    l_macros_type               acc_macros_type%rowtype;
    l_transaction_tab           acc_api_type_pkg.t_transaction_tab;
    l_conversion_rate           com_api_type_pkg.t_rate;
    l_rate_type                 com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text          => 'Put macros [#1]'
        , i_env_param1  => i_macros_type_id
    );

    -- Choose bunch type for institute
    begin
        select b.macros_type_id
             , b.bunch_type_id
             , b.seqnum
             , t.status
          into l_macros_type
          from acc_macros_bunch_type b
             , acc_macros_type t
         where t.id             = i_macros_type_id
           and b.macros_type_id = t.id
           and b.inst_id        = i_account_tab(i_account_name).inst_id;

    exception
        when no_data_found then
            begin
                select id
                     , bunch_type_id
                     , seqnum
                     , status
                  into l_macros_type
                  from acc_macros_type t
                 where t.id = i_macros_type_id;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error (
                        i_error         => 'ACC_MACROS_TYPE_NOT_EXISTS'
                      , i_env_param1    => i_macros_type_id
                    );
            end;        
    end; 

    open l_template_cur for
        select s.transaction_type
             , s.transaction_num
             , s.negative_allowed
             , s.account_name
             , s.amount_name
             , s.date_name
             , s.posting_method
             , s.balance_type
             , s.balance_impact
             , null
             , null
             , null
             , l_macros_type.bunch_type_id
             , null
             , null
             , null
             , null
             , null
             , null
             , dest_entity_type
             , dest_account_type
             , l_macros_type.id  as macros_type
             , null
             , null
             , mod_id
             , null
          from acc_entry_tpl s
             , rul_mod r
         where s.bunch_type_id = l_macros_type.bunch_type_id
           and r.id(+)         = s.mod_id
         order by s.transaction_num
                , r.priority nulls last
                , s.balance_impact;

    o_macros_id := allocate_macros_id;

    trc_log_pkg.debug (
        i_text          => 'Entry templates cursor opened'
    );

    put_bunch_entries (
        i_template_cur          => l_template_cur
        , i_amount_tab          => i_amount_tab
        , i_account_tab         => i_account_tab
        , i_date_tab            => i_date_tab
        , i_macros_id           => o_macros_id
        , o_bunch_id            => o_bunch_id
        , o_bunch_type_id       => l_bunch_type_id
        , o_entry_count         => l_entry_count
        , o_transaction_tab     => l_transaction_tab
        , i_param_tab           => i_param_tab
    );

    trc_log_pkg.debug (
        i_text          => 'Transactions generated [#1]'
        , i_env_param1  => l_transaction_tab.count
    );

    if l_entry_count > 0 then
        create_bunch (
            i_bunch_id          => o_bunch_id
          , i_bunch_type_id     => l_bunch_type_id
          , i_macros_id         => o_macros_id
          , i_details_data      => null
        );

        rul_api_param_pkg.get_account (
            i_name              => i_account_name
          , o_account_rec       => l_account
          , io_account_tab      => i_account_tab
        );

        rul_api_param_pkg.get_amount (
            i_name              => i_amount_name
          , o_amount            => l_amount
          , o_currency          => l_currency
          , o_conversion_rate   => l_conversion_rate
          , o_rate_type         => l_rate_type
          , io_amount_tab       => i_amount_tab
        );

        create_macros(
            i_macros_id         => o_macros_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_macros_type_id    => i_macros_type_id
          , i_account_id        => l_account.account_id
          , i_amount            => l_amount
          , i_currency          => l_currency
          , i_amount_purpose    => i_amount_purpose
          , i_fee_id            => i_fee_id
          , i_fee_tier_id       => i_fee_tier_id
          , i_fee_mod_id        => i_fee_mod_id
          , i_details_data      => i_details_data
          , i_status            => l_macros_type.status
          , i_conversion_rate   => l_conversion_rate
          , i_rate_type         => l_rate_type
        );

        raise_transaction_registration (
            i_transaction_tab   => l_transaction_tab
        );
    else
        o_macros_id := null;
    end if;

    trc_log_pkg.debug('Put macros [' || i_macros_type_id || '] COMPLETED, o_macros_id [' || o_macros_id || ']');
exception
    when others then
        if l_template_cur%isopen then
            close l_template_cur;
        end if;

        raise;
end put_macros;

procedure put_macros(
    o_macros_id                   out com_api_type_pkg.t_long_id
  , o_bunch_id                    out com_api_type_pkg.t_long_id
  , i_entity_type              in     com_api_type_pkg.t_dict_value
  , i_object_id                in     com_api_type_pkg.t_long_id
  , i_macros_type_id           in     com_api_type_pkg.t_tiny_id
  , i_amount                   in     com_api_type_pkg.t_money
  , i_currency                 in     com_api_type_pkg.t_curr_code
  , i_account_type             in     com_api_type_pkg.t_dict_value    default null
  , i_account_id               in     com_api_type_pkg.t_account_id
  , i_posting_date             in     date                             default null
  , i_amount_name              in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_AMOUNT_NAME
  , i_account_name             in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_ACCOUNT_NAME
  , i_date_name                in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_DATE_NAME
  , i_amount_purpose           in     com_api_type_pkg.t_dict_value    default null
  , i_fee_id                   in     com_api_type_pkg.t_short_id      default null
  , i_fee_tier_id              in     com_api_type_pkg.t_short_id      default null
  , i_fee_mod_id               in     com_api_type_pkg.t_tiny_id       default null
  , i_details_data             in     com_api_type_pkg.t_full_desc     default null
  , i_conversion_rate          in     com_api_type_pkg.t_rate          default null
  , i_param_tab                in     com_api_type_pkg.t_param_tab
) is
    l_amount_tab                      com_api_type_pkg.t_amount_by_name_tab;
    l_account_tab                     acc_api_type_pkg.t_account_by_name_tab;
    l_date_tab                        com_api_type_pkg.t_date_by_name_tab;
begin
    -- Get required fields of the account <i_account_id>: inst_id, split_hash
    acc_api_account_pkg.get_account_info(
        i_account_id  => i_account_id
      , o_account_rec => l_account_tab(i_account_name)
      , i_mask_error  => com_api_type_pkg.FALSE
    );
    -- To guarantee old behavior, incoming <i_account_type> is used with highest priority
    if i_account_type is not null then
        l_account_tab(i_account_name).account_type := i_account_type;
    end if;

    l_amount_tab(i_amount_name).amount := i_amount;
    l_amount_tab(i_amount_name).currency := i_currency;
    l_amount_tab(i_amount_name).conversion_rate := i_conversion_rate;

    if i_posting_date is not null then
        l_date_tab(i_date_name) := i_posting_date;
    end if;

    put_macros (
        o_macros_id           => o_macros_id
      , o_bunch_id            => o_bunch_id
      , i_entity_type         => i_entity_type
      , i_object_id           => i_object_id
      , i_macros_type_id      => i_macros_type_id
      , i_amount_tab          => l_amount_tab
      , i_account_tab         => l_account_tab
      , i_date_tab            => l_date_tab
      , i_amount_name         => i_amount_name
      , i_account_name        => i_account_name
      , i_amount_purpose      => i_amount_purpose
      , i_fee_id              => i_fee_id
      , i_fee_tier_id         => i_fee_tier_id
      , i_fee_mod_id          => i_fee_mod_id
      , i_details_data        => i_details_data
      , i_param_tab           => i_param_tab
    );
end put_macros;

procedure put_bunch (
    o_bunch_id              out com_api_type_pkg.t_long_id
  , i_bunch_type_id      in     com_api_type_pkg.t_tiny_id
  , i_macros_id          in     com_api_type_pkg.t_long_id
  , i_amount_tab         in     com_api_type_pkg.t_amount_by_name_tab
  , i_account_tab        in     acc_api_type_pkg.t_account_by_name_tab
  , i_date_tab           in     com_api_type_pkg.t_date_by_name_tab
  , i_details_data       in     com_api_type_pkg.t_full_desc
  , i_macros_type_id     in     com_api_type_pkg.t_tiny_id
  , i_param_tab          in     com_api_type_pkg.t_param_tab
) is
    l_template_cur              t_entry_template_cur;
    l_bunch_type_id             com_api_type_pkg.t_tiny_id;
    l_entry_count               number;
    l_transaction_tab           acc_api_type_pkg.t_transaction_tab;
begin
    if i_macros_type_id is null then
        open l_template_cur for
            select s.transaction_type
                 , s.transaction_num
                 , s.negative_allowed
                 , s.account_name
                 , s.amount_name
                 , s.date_name
                 , s.posting_method
                 , s.balance_type
                 , s.balance_impact
                 , null
                 , null
                 , null
                 , s.bunch_type_id
                 , null
                 , null
                 , null
                 , null
                 , null
                 , null
                 , s.dest_entity_type
                 , s.dest_account_type
                 , m.macros_type_id    as macros_type
                 , null
                 , null
                 , mod_id
                 , null
              from acc_entry_tpl s
                 , acc_macros m
                 , rul_mod r
             where s.bunch_type_id = i_bunch_type_id
               and m.id            = i_macros_id
               and r.id(+)         = s.mod_id
             order by s.transaction_num
                    , r.priority nulls last
                    , s.balance_impact;

    else
        open l_template_cur for
            select s.transaction_type
                 , s.transaction_num
                 , s.negative_allowed
                 , s.account_name
                 , s.amount_name
                 , s.date_name
                 , s.posting_method
                 , s.balance_type
                 , s.balance_impact
                 , null
                 , null
                 , null
                 , s.bunch_type_id
                 , null
                 , null
                 , null
                 , null
                 , null
                 , null
                 , s.dest_entity_type
                 , s.dest_account_type
                 , i_macros_type_id    as macros_type
                 , null
                 , null
                 , mod_id
                 , null
              from acc_entry_tpl s
                 , rul_mod r
             where s.bunch_type_id = i_bunch_type_id
               and r.id(+)         = s.mod_id
             order by s.transaction_num
                    , r.priority nulls last
                    , s.balance_impact;
    end if;

    put_bunch_entries (
        i_template_cur          => l_template_cur
      , i_amount_tab            => i_amount_tab
      , i_account_tab           => i_account_tab
      , i_date_tab              => i_date_tab
      , i_macros_id             => i_macros_id
      , o_bunch_id              => o_bunch_id
      , o_bunch_type_id         => l_bunch_type_id
      , o_entry_count           => l_entry_count
      , o_transaction_tab       => l_transaction_tab
      , i_param_tab             => i_param_tab
    );

    if l_entry_count > 0 then
        create_bunch (
            i_bunch_id          => o_bunch_id
          , i_bunch_type_id     => i_bunch_type_id
          , i_macros_id         => i_macros_id
          , i_details_data      => i_details_data
        );

        raise_transaction_registration (
            i_transaction_tab   => l_transaction_tab
        );
    end if;
exception
    when others then
        if l_template_cur%isopen then
            close l_template_cur;
        end if;

        raise;
end put_bunch;

procedure put_bunch(
    o_bunch_id                    out com_api_type_pkg.t_long_id
  , i_bunch_type_id            in     com_api_type_pkg.t_tiny_id
  , i_macros_id                in     com_api_type_pkg.t_long_id
  , i_amount                   in     com_api_type_pkg.t_money
  , i_currency                 in     com_api_type_pkg.t_curr_code
  , i_account_type             in     com_api_type_pkg.t_dict_value    default null
  , i_account_id               in     com_api_type_pkg.t_account_id
  , i_posting_date             in     date                             default null
  , i_amount_name              in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_AMOUNT_NAME
  , i_account_name             in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_ACCOUNT_NAME
  , i_date_name                in     com_api_type_pkg.t_oracle_name   default acc_api_const_pkg.DEFAULT_DATE_NAME
  , i_details_data             in     com_api_type_pkg.t_full_desc     default null
  , i_macros_type_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_param_tab                in     com_api_type_pkg.t_param_tab
) is
    l_amount_tab                      com_api_type_pkg.t_amount_by_name_tab;
    l_account_tab                     acc_api_type_pkg.t_account_by_name_tab;
    l_date_tab                        com_api_type_pkg.t_date_by_name_tab;
begin
    -- Get required fields of the account <i_account_id>: inst_id, split_hash
    acc_api_account_pkg.get_account_info(
        i_account_id  => i_account_id
      , o_account_rec => l_account_tab(i_account_name)
      , i_mask_error  => com_api_type_pkg.FALSE
    );
    -- To guarantee old behavior, incoming <i_account_type> is used with highest priority
    if i_account_type is not null then
        l_account_tab(i_account_name).account_type := i_account_type;
    end if;

    l_amount_tab(i_amount_name).amount   := i_amount;
    l_amount_tab(i_amount_name).currency := i_currency;

    if i_posting_date is not null then
        l_date_tab(i_date_name) := i_posting_date;
    end if;

    put_bunch (
        o_bunch_id            => o_bunch_id
      , i_bunch_type_id       => i_bunch_type_id
      , i_amount_tab          => l_amount_tab
      , i_account_tab         => l_account_tab
      , i_date_tab            => l_date_tab
      , i_macros_id           => i_macros_id
      , i_details_data        => i_details_data
      , i_macros_type_id      => i_macros_type_id
      , i_param_tab           => i_param_tab
    );
end put_bunch;

procedure post_buffered_entries (
    entries              in     sys_refcursor
  , i_session_id         in     com_api_type_pkg.t_long_id
  , i_thread_number      in     com_api_type_pkg.t_tiny_id
  , o_total                 out number
  , o_exception             out number
) is
    l_rowid                     com_api_type_pkg.t_rowid_tab;
    l_entry_id                  com_api_type_pkg.t_number_tab;
    l_macros_id                 com_api_type_pkg.t_number_tab;
    l_bunch_id                  com_api_type_pkg.t_number_tab;
    l_transaction_id            com_api_type_pkg.t_number_tab;
    l_transaction_type          com_api_type_pkg.t_name_tab;
    l_account_id                com_api_type_pkg.t_number_tab;
    l_currency                  com_api_type_pkg.t_name_tab;
    l_account_type              com_api_type_pkg.t_name_tab;
    l_balance_type              com_api_type_pkg.t_name_tab;
    l_balance_impact            com_api_type_pkg.t_number_tab;
    l_amount                    com_api_type_pkg.t_number_tab;
    l_posting_method            com_api_type_pkg.t_dict_tab;

    l_original_account_id       com_api_type_pkg.t_number_tab;
    l_transf_entity             com_api_type_pkg.t_name_tab;
    l_transf_type               com_api_type_pkg.t_name_tab;
    l_macros_type               com_api_type_pkg.t_number_tab;

    l_ref_id                    com_api_type_pkg.t_number_tab;
    l_status                    com_api_type_pkg.t_name_tab;
    l_rounding_method           com_api_type_pkg.t_dict_tab;

    l_processed_entries         com_api_type_pkg.t_integer_tab;
    l_excepted_entries          com_api_type_pkg.t_integer_tab;

    total_in_count              number := 0;
    total_ok_count              number := 0;
    total_except_count          number := 0;
begin
    if entries%isopen then
        loop
            fetch entries
            bulk collect into
                l_rowid
              , l_entry_id
              , l_macros_id
              , l_bunch_id
              , l_transaction_id
              , l_transaction_type
              , l_account_id
              , l_amount
              , l_currency
              , l_account_type
              , l_balance_type
              , l_balance_impact
              , l_original_account_id
              , l_transf_entity
              , l_transf_type
              , l_posting_method
              , l_macros_type
              , l_ref_id
              , l_status
              , l_rounding_method
            limit BULK_LIMIT;

            total_in_count := total_in_count + l_rowid.count;

            forall i in 1 .. l_rowid.count
                delete from acc_entry_buffer
                 where rowid = l_rowid(i);

            post_entries (
                i_entry_id             => l_entry_id
              , i_macros_id            => l_macros_id
              , i_bunch_id             => l_bunch_id
              , i_transaction_id       => l_transaction_id
              , i_transaction_type     => l_transaction_type
              , i_account_id           => l_account_id
              , i_amount               => l_amount
              , i_currency             => l_currency
              , i_account_type         => l_account_type
              , i_balance_type         => l_balance_type
              , i_balance_impact       => l_balance_impact
              , i_original_account_id  => l_original_account_id
              , i_transf_entity        => l_transf_entity
              , i_transf_type          => l_transf_type
              , i_macros_type          => l_macros_type
              , i_ref_entry_id         => l_ref_id
              , i_status               => l_status
              , o_processed_entries    => l_processed_entries
              , o_excepted_entries     => l_excepted_entries
              , i_save_exceptions      => com_api_type_pkg.TRUE
              , i_rounding_method      => l_rounding_method
            );

            total_ok_count     := total_ok_count     + l_processed_entries.count;
            total_except_count := total_except_count + l_excepted_entries.count;

            prc_api_stat_pkg.log_current (
                i_current_count        => total_ok_count + total_except_count
                , i_excepted_count     => total_except_count
            );

            exit when entries%notfound;
        end loop;
    end if;

    o_total     := total_ok_count + total_except_count;
    o_exception := total_except_count;
end post_buffered_entries;

procedure process_buffered_entries is

    l_entries                   sys_refcursor;
    l_partition_placeholder     constant varchar2(100) := '##PARTITION_NAME##';
    l_cursor_stmt               varchar2(2000);
    l_partition_condition       varchar2(2000) := ' and b.split_hash in (select split_hash from com_split_map m where m.thread_number = :thread_number)';

    l_session_id                com_api_type_pkg.t_long_id := get_session_id;
    l_thread_number             com_api_type_pkg.t_tiny_id := get_thread_number;
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;

begin
    prc_api_stat_pkg.log_start;

    com_api_sttl_day_pkg.set_sysdate;
    com_api_sttl_day_pkg.cache_sttl_days;

    l_cursor_stmt :=
        'select count(*) from acc_entry_buffer b where b.status = :status';
    if l_thread_number > 0 then
        l_cursor_stmt := l_cursor_stmt || l_partition_condition;

        trc_log_pkg.debug (
            i_text      => l_cursor_stmt
        );

        execute immediate l_cursor_stmt into l_estimated_count using acc_api_const_pkg.ENTRY_SOURCE_BUFFER, l_thread_number;
    else
        trc_log_pkg.debug (
            i_text      => l_cursor_stmt
        );

        execute immediate l_cursor_stmt into l_estimated_count using acc_api_const_pkg.ENTRY_SOURCE_BUFFER;
    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    l_cursor_stmt :=
        'select
            b.rowid                 row_id
            , b.id
            , b.macros_id
            , b.bunch_id
            , b.transaction_id
            , b.transaction_type
            , b.dest_account_id account_id
            , b.amount
            , b.currency
            , b.account_type
            , b.balance_type
            , b.balance_impact
            , b.account_id original_account_id
            , b.dest_entity_type
            , b.dest_account_type
            , ''POSTBUFF''
            , m.macros_type_id macros_type
            , null
            , null
        from
            acc_entry_buffer b
            , acc_macros m
        where
            b.status = :status
            and m.id = b.macros_id'
            || l_partition_placeholder || '
        order by
            b.id
        for update'
    ;

    if l_thread_number > 0 then
        l_cursor_stmt := replace(l_cursor_stmt, l_partition_placeholder, l_partition_condition);

        trc_log_pkg.debug (
            i_text      => l_cursor_stmt
        );

        open l_entries for l_cursor_stmt using acc_api_const_pkg.ENTRY_SOURCE_BUFFER, l_thread_number;

    else
        l_partition_condition := null;
        l_cursor_stmt := replace(l_cursor_stmt, l_partition_placeholder, l_partition_condition);

        trc_log_pkg.debug (
            i_text      => l_cursor_stmt
        );

        open l_entries for l_cursor_stmt using acc_api_const_pkg.ENTRY_SOURCE_BUFFER;
    end if;

    post_buffered_entries (
        entries             => l_entries
      , i_session_id        => l_session_id
      , i_thread_number     => l_thread_number
      , o_total             => l_processed_count
      , o_exception         => l_excepted_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    com_api_sttl_day_pkg.free_cache_sttl_days;
exception
    when others then
        if l_entries%isopen then
            close l_entries;
        end if;

        com_api_sttl_day_pkg.free_cache_sttl_days;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end process_buffered_entries;

procedure move_to_entry_buffer(
    i_entries            in     sys_refcursor
  , i_entry_source       in     com_api_type_pkg.t_oracle_name
  , i_session_id         in     com_api_type_pkg.t_long_id
  , i_thread_number      in     com_api_type_pkg.t_tiny_id
  , o_total                 out number
  , o_exception             out number
) is
    l_rowid                     com_api_type_pkg.t_rowid_tab;
    l_entry_id                  com_api_type_pkg.t_number_tab;
    l_macros_id                 com_api_type_pkg.t_number_tab;
    l_bunch_id                  com_api_type_pkg.t_number_tab;
    l_transaction_id            com_api_type_pkg.t_number_tab;
    l_transaction_type          com_api_type_pkg.t_name_tab;
    l_account_id                com_api_type_pkg.t_number_tab;
    l_amount                    com_api_type_pkg.t_number_tab;
    l_currency                  com_api_type_pkg.t_name_tab;
    l_account_type              com_api_type_pkg.t_name_tab;
    l_balance_type              com_api_type_pkg.t_name_tab;
    l_balance_impact            com_api_type_pkg.t_number_tab;
    l_transf_entity             com_api_type_pkg.t_name_tab;
    l_transf_type               com_api_type_pkg.t_name_tab;
    l_posting_method            com_api_type_pkg.t_name_tab;
    l_posting_date              com_api_type_pkg.t_date_tab;

    l_exceptions                com_api_type_pkg.t_integer_tab;
    l_success                   com_api_type_pkg.t_integer_tab;
    total_ok_count              number := 0;
    total_except_count          number := 0;
begin
    if i_entries%isopen then
        loop
            fetch i_entries
            bulk collect into
                l_rowid
              , l_entry_id
              , l_macros_id
              , l_bunch_id
              , l_transaction_id
              , l_transaction_type
              , l_account_id
              , l_amount
              , l_currency
              , l_account_type
              , l_balance_type
              , l_balance_impact
              , l_transf_entity
              , l_transf_type
              , l_posting_method
              , l_posting_date
            limit BULK_LIMIT;

            forall i in 1 .. l_rowid.count
                delete from acc_entry_buffer
                 where rowid = l_rowid(i);

            save_into_entry_buffer (
                i_entry_id            => l_entry_id
              , i_macros_id           => l_macros_id
              , i_bunch_id            => l_bunch_id
              , i_transaction_id      => l_transaction_id
              , i_transaction_type    => l_transaction_type
              , i_account_id          => l_account_id
              , i_amount              => l_amount
              , i_currency            => l_currency
              , i_account_type        => l_account_type
              , i_balance_type        => l_balance_type
              , i_balance_impact      => l_balance_impact
              , i_transf_entity       => l_transf_entity
              , i_transf_type         => l_transf_type
              , i_posting_method      => l_posting_method
              , i_posting_date        => l_posting_date
              , i_save_exceptions     => true
              , o_exceptions          => l_exceptions
              , o_success             => l_success
            );

            total_ok_count     := total_ok_count     + l_success.count;
            total_except_count := total_except_count + l_exceptions.count;

            prc_api_stat_pkg.log_current (
                i_current_count       => total_ok_count + total_except_count
              , i_excepted_count      => total_except_count
            );

            exit when i_entries%notfound;
        end loop;
    end if;

    o_total     := total_ok_count + total_except_count;
    o_exception := total_except_count;
end move_to_entry_buffer;

procedure process_entries (
    i_entry_source           in com_api_type_pkg.t_oracle_name
) is
    l_entries                   sys_refcursor;

    l_date                      date := com_api_sttl_day_pkg.get_sysdate;

    l_partition_placeholder     constant varchar2(100) := '##PARTITION_NAME##';
    l_posting_date_placeholder  constant varchar2(100) := '##POSTING_DATE##';
    l_where_placeholder         constant varchar2(100) := '##WHERE##';

    l_where                     varchar2(100) := ' where b.status = :status';

    l_cursor_stmt               varchar2(2000) :=
        'select
            b.rowid                 row_id
            , b.id
            , b.macros_id
            , b.bunch_id
            , b.transaction_id
            , b.transaction_type
            , b.account_id
            , b.amount
            , b.currency
            , b.account_type
            , b.balance_type
            , b.balance_impact
            , b.dest_entity_type
            , b.dest_account_type
            , ''POSTBUFF''
            , to_date('''||to_char(l_date,'dd.mm.rrrr hh24:mi:ss')||''',''dd.mm.rrrr hh24:mi:ss'')
        from
            acc_entry_buffer b'
            || l_where_placeholder
            || l_posting_date_placeholder
            || l_partition_placeholder || '
        order by
            b.id
        for update'
    ;

    l_count_stmt               varchar2(2000) :=
        'select count(*)
        from
            acc_entry_buffer b'
            || l_where_placeholder
            || l_posting_date_placeholder
            || l_partition_placeholder
    ;

    l_posting_date_condition    varchar2(100) := ' and b.posting_date <= :posting_date';
    l_partition_condition       varchar2(100) := ' and b.split_hash in (select split_hash from com_split_map where thread_number = :thread_number)';

    l_session_id                com_api_type_pkg.t_long_id := get_session_id;
    l_thread_number             com_api_type_pkg.t_tiny_id := get_thread_number;
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;
begin
    prc_api_stat_pkg.log_start;

    com_api_sttl_day_pkg.set_sysdate;
    com_api_sttl_day_pkg.cache_sttl_days;

    if i_entry_source = acc_api_const_pkg.ENTRY_SOURCE_PENDING then
        l_posting_date_condition := l_posting_date_condition;

    elsif i_entry_source = acc_api_const_pkg.ENTRY_SOURCE_EXCEPTION then
        l_posting_date_condition := null;

    else
        return;
    end if;

    if l_thread_number > 0 then
        l_partition_condition := l_partition_condition;
    else
        l_partition_condition := null;
    end if;

    l_count_stmt := replace(l_count_stmt, l_where_placeholder, l_where);
    l_count_stmt := replace(l_count_stmt, l_partition_placeholder, l_partition_condition);
    l_count_stmt := replace(l_count_stmt, l_posting_date_placeholder, l_posting_date_condition);

    if l_thread_number > 0 then
        if l_posting_date_condition is not null then
            trc_log_pkg.debug (
                i_text          => 'Executing: [#1], using [#2][#3]'
                , i_env_param1  => l_count_stmt
                , i_env_param2  => l_date
                , i_env_param3  => l_thread_number
            );

            execute immediate l_count_stmt into l_estimated_count using i_entry_source, l_date, l_thread_number;

        else
            trc_log_pkg.debug (
                i_text          => 'Executing: [#1], using [#3]'
                , i_env_param1  => l_count_stmt
                , i_env_param2  => l_date
                , i_env_param3  => l_thread_number
            );

            execute immediate l_count_stmt into l_estimated_count using i_entry_source, l_thread_number;
        end if;
    else
        if l_posting_date_condition is not null then
            trc_log_pkg.debug (
                i_text          => 'Executing: [#1], using [#2]'
                , i_env_param1  => l_count_stmt
                , i_env_param2  => l_date
                , i_env_param3  => l_thread_number
            );

            execute immediate l_count_stmt into l_estimated_count using i_entry_source, l_date;

        else
            trc_log_pkg.debug (
                i_text          => 'Executing: [#1]'
                , i_env_param1  => l_count_stmt
                , i_env_param2  => l_date
                , i_env_param3  => l_thread_number
            );

            execute immediate l_count_stmt into l_estimated_count using i_entry_source;
        end if;
    end if;

    trc_log_pkg.debug (
        i_text          => 'Estimated count: [#1]'
        , i_env_param1  => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    l_cursor_stmt := replace(l_cursor_stmt, l_where_placeholder, l_where);
    l_cursor_stmt := replace(l_cursor_stmt, l_partition_placeholder, l_partition_condition);
    l_cursor_stmt := replace(l_cursor_stmt, l_posting_date_placeholder, l_posting_date_condition);

    if l_thread_number > 0 then
        if l_posting_date_condition is not null then
            open l_entries for l_cursor_stmt using i_entry_source, l_date, l_thread_number;
        else
            open l_entries for l_cursor_stmt using i_entry_source, l_thread_number;
        end if;
    else
        if l_posting_date_condition is not null then
            open l_entries for l_cursor_stmt using i_entry_source, l_date;
        else
            open l_entries for l_cursor_stmt using i_entry_source;
        end if;
    end if;

    move_to_entry_buffer (
        i_entries           => l_entries
        , i_entry_source    => i_entry_source
        , i_session_id      => l_session_id
        , i_thread_number   => l_thread_number
        , o_total           => l_processed_count
        , o_exception       => l_excepted_count
    );

    if l_entries%isopen then
        close l_entries;
    end if;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    com_api_sttl_day_pkg.free_cache_sttl_days;
exception
    when others then
        if l_entries%isopen then
            close l_entries;
        end if;

        com_api_sttl_day_pkg.free_cache_sttl_days;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end process_entries;

procedure process_pending_entries is
begin
    process_entries (
        i_entry_source     => acc_api_const_pkg.ENTRY_SOURCE_PENDING
    );
end;

procedure process_exception_entries is
begin
    process_entries (
        i_entry_source     => acc_api_const_pkg.ENTRY_SOURCE_EXCEPTION
    );
end;

procedure flush_job is
begin
    trc_log_pkg.debug (
        i_text          => 'going to flush accounting job'
    );

    flush_macros;
    flush_bunch;
    flush_entries;
end;

procedure cancel_job is
begin
    cancel_macros;
    cancel_bunch;
    cancel_entries;
end;

procedure cancel_processing (
    i_entity_type             in com_api_type_pkg.t_dict_value
  , i_object_id               in com_api_type_pkg.t_long_id
  , i_macros_status           in com_api_type_pkg.t_dict_value
  , i_macros_type             in com_api_type_pkg.t_tiny_id
  , i_entry_status            in com_api_type_pkg.t_dict_value
) is
begin
    for r_macros in (
        select m.id
             , m.status
          from acc_macros m
         where m.object_id        = i_object_id
           and m.entity_type      = i_entity_type
           and m.status           = nvl(i_macros_status, m.status)
           and m.macros_type_id   = nvl(i_macros_type,   m.macros_type_id)
           and m.cancel_indicator = com_api_const_pkg.INDICATOR_NOT_CANCELED
        for update nowait
    ) loop
        for r_bunch in (select * from acc_bunch where macros_id = r_macros.id for update nowait) loop
            revert_entries (
                i_transaction_id  => null
              , i_bunch_id        => r_bunch.id
              , i_entry_status    => i_entry_status
            );
        end loop;

        update acc_macros
           set cancel_indicator = com_api_const_pkg.INDICATOR_CANCELED
         where id = r_macros.id;
    end loop;
end;

procedure revert_entries (
    i_transaction_id         in com_api_type_pkg.t_long_id
  , i_bunch_id               in com_api_type_pkg.t_long_id    := null
  , i_entry_status           in com_api_type_pkg.t_dict_value := acc_api_const_pkg.ENTRY_STATUS_CANCELED
) is
    l_entry_id                  com_api_type_pkg.t_number_tab;
    l_macros_id                 com_api_type_pkg.t_number_tab;
    l_bunch_id                  com_api_type_pkg.t_number_tab;
    l_transaction_id            com_api_type_pkg.t_number_tab;
    l_transaction_type          com_api_type_pkg.t_name_tab;
    l_account_id                com_api_type_pkg.t_number_tab;
    l_amount                    com_api_type_pkg.t_number_tab;
    l_currency                  com_api_type_pkg.t_name_tab;
    l_account_type              com_api_type_pkg.t_name_tab;
    l_balance_type              com_api_type_pkg.t_name_tab;
    l_balance_impact            com_api_type_pkg.t_number_tab;
    l_original_account_id       com_api_type_pkg.t_number_tab;
    l_transf_entity             com_api_type_pkg.t_name_tab;
    l_transf_type               com_api_type_pkg.t_name_tab;
    l_macros_type               com_api_type_pkg.t_number_tab;
    l_processed_entries         com_api_type_pkg.t_integer_tab;
    l_excepted_entries          com_api_type_pkg.t_integer_tab;
    l_status                    com_api_type_pkg.t_name_tab;
    l_ref_id                    com_api_type_pkg.t_number_tab;
    l_split_hash                com_api_type_pkg.t_number_tab;
    l_inst_id                   com_api_type_pkg.t_number_tab;
    l_rounding_method           com_api_type_pkg.t_dict_tab;

    l_prev_transaction_id       com_api_type_pkg.t_long_id;
    l_transaction_tab           acc_api_type_pkg.t_transaction_tab;
    l_transaction_count         com_api_type_pkg.t_count := 0;
    l_acc_entry_buffer_count    com_api_type_pkg.t_count := 0;
    
    l_stmt                      com_api_type_pkg.t_text;
    l_transaction_placeholder   constant com_api_type_pkg.t_name := '##TRANSACTION##';
    l_bunch_placeholder         constant com_api_type_pkg.t_name := '##BUNCH##';
begin
    trc_log_pkg.debug (
        i_text          => 'going to revert entries trnasaction_id=[#1] bunch[#2]'
        , i_env_param1  => i_transaction_id
        , i_env_param2  => i_bunch_id
    );

    -- Check that entry buffer is not empty
    select count(1)
      into l_acc_entry_buffer_count
      from acc_entry_buffer
     where rownum = 1;

    if l_acc_entry_buffer_count > 0 then
        if i_bunch_id is not null then
            delete from acc_entry_buffer
             where bunch_id = i_bunch_id;
        else
            delete from acc_entry_buffer
             where transaction_id = i_transaction_id;
        end if;

        trc_log_pkg.debug (
            i_text        => 'deleted from buffer [#1]'
          , i_env_param1  => sql%rowcount
        );
    end if;

    l_stmt := '
select
    e.id
    , b.macros_id
    , b.id
    , e.transaction_id
    , e.transaction_type
    , e.account_id
    , e.amount
    , e.currency
    , a.account_type
    , e.balance_type
    , e.balance_impact
    , null
    , null
    , null
    , m.macros_type_id
    , e.id
    , '''||i_entry_status||''' status
    , e.split_hash
    , a.inst_id
    , e.rounding_method
from
    acc_bunch b
    , acc_entry e
    , acc_account a
    , acc_macros m
    , ( select
            :transaction_id  transaction_id
            , :i_bunch_id bunch_id
            , :status_posted status_posted
        from
            dual
    ) p
where 1=1 '
    || l_transaction_placeholder
    || l_bunch_placeholder ||'
    and b.id = e.bunch_id
    and e.account_id = a.id
    and b.macros_id = m.id
    and e.status = p.status_posted
order by
    e.transaction_id
    , e.id
for update of
    e.status
    ';
    
    if i_bunch_id is not null then
        l_stmt := replace(l_stmt, l_bunch_placeholder, ' and b.id = p.bunch_id');
    else
        l_stmt := replace(l_stmt, l_transaction_placeholder, ' and e.transaction_id = p.transaction_id ');
    end if;
    l_stmt := replace(l_stmt, l_transaction_placeholder, '');
    l_stmt := replace(l_stmt, l_bunch_placeholder, '');

    execute immediate l_stmt 
    bulk collect into
        l_entry_id
        , l_macros_id
        , l_bunch_id
        , l_transaction_id
        , l_transaction_type
        , l_account_id
        , l_amount
        , l_currency
        , l_account_type
        , l_balance_type
        , l_balance_impact
        , l_original_account_id
        , l_transf_entity
        , l_transf_type
        , l_macros_type
        , l_ref_id
        , l_status
        , l_split_hash
        , l_inst_id
        , l_rounding_method
    using i_transaction_id, i_bunch_id, acc_api_const_pkg.ENTRY_STATUS_POSTED;

    trc_log_pkg.debug (
        i_text          => '[#1] entries will be reverted'
        , i_env_param1  => l_entry_id.count
    );

    if l_entry_id.count = 0 then
        return;
    else
        for i in 1 .. l_entry_id.count loop
            l_balance_impact(i) := com_api_type_pkg.invert_sign(l_balance_impact(i));

            l_entry_id(i) := com_api_id_pkg.get_id(i_seq => acc_entry_seq.nextval);

            if l_transaction_id(i) = l_prev_transaction_id then
                l_transaction_id(i) := l_transaction_id(i-1);
            else
                l_prev_transaction_id := l_transaction_id(i);
                l_transaction_id(i) := l_entry_id(i);
                
                l_transaction_count := l_transaction_tab.count + 1;
                l_transaction_tab(l_transaction_count).transaction_id   := l_transaction_id(i);
                l_transaction_tab(l_transaction_count).transaction_type := l_transaction_type(i);
                l_transaction_tab(l_transaction_count).macros_id        := l_macros_id(i);
                l_transaction_tab(l_transaction_count).bunch_id         := l_bunch_id(i);
                l_transaction_tab(l_transaction_count).split_hash       := l_split_hash(i);
                l_transaction_tab(l_transaction_count).posting_date     := get_sysdate;
                l_transaction_tab(l_transaction_count).inst_id          := l_inst_id(i);
                l_transaction_tab(l_transaction_count).balance_type     := l_balance_type(i);
            end if;
        end loop;
    end if;

    post_entries (
        i_entry_id                => l_entry_id
      , i_macros_id               => l_macros_id
      , i_bunch_id                => l_bunch_id
      , i_transaction_id          => l_transaction_id
      , i_transaction_type        => l_transaction_type
      , i_account_id              => l_account_id
      , i_amount                  => l_amount
      , i_currency                => l_currency
      , i_account_type            => l_account_type
      , i_balance_type            => l_balance_type
      , i_balance_impact          => l_balance_impact
      , i_original_account_id     => l_original_account_id
      , i_transf_entity           => l_transf_entity
      , i_transf_type             => l_transf_type
      , i_macros_type             => l_macros_type
      , i_ref_entry_id            => l_ref_id
      , i_status                  => l_status
      , o_processed_entries       => l_processed_entries
      , o_excepted_entries        => l_excepted_entries
      , i_save_exceptions         => com_api_type_pkg.FALSE
      , i_rounding_method         => l_rounding_method
    );

    if l_excepted_entries.count > 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'ERROR_POSTING_IMMEDIATE_ENTRIES'
        );
    end if;
    
    forall i in 1 .. l_ref_id.count
        update acc_entry
           set status       = l_status(i)
             , ref_entry_id = l_entry_id(i)
         where id = l_ref_id(i);

    raise_transaction_registration (
        i_transaction_tab     => l_transaction_tab
    );
end revert_entries;

procedure partial_revert_entries (
    i_entity_type            in com_api_type_pkg.t_dict_value
  , i_object_id              in com_api_type_pkg.t_long_id
  , i_macros_status          in com_api_type_pkg.t_dict_value
  , i_macros_type            in com_api_type_pkg.t_tiny_id     := null
  , i_entry_status           in com_api_type_pkg.t_dict_value  := acc_api_const_pkg.ENTRY_STATUS_CANCELED
  , i_amount                 in com_api_type_pkg.t_amount_rec  := null
  , i_final_unhold           in com_api_type_pkg.t_boolean     := null
)
is
    l_final_unhold              com_api_type_pkg.t_boolean     := nvl(i_final_unhold, com_api_type_pkg.FALSE);
    l_bunch_id1                 com_api_type_pkg.t_long_id     := null;

    l_entry_id                  com_api_type_pkg.t_number_tab;
    l_macros_id                 com_api_type_pkg.t_number_tab;
    l_bunch_id                  com_api_type_pkg.t_number_tab;
    l_transaction_id            com_api_type_pkg.t_number_tab;
    l_transaction_type          com_api_type_pkg.t_name_tab;
    l_account_id                com_api_type_pkg.t_number_tab;
    l_amount                    com_api_type_pkg.t_number_tab;
    l_currency                  com_api_type_pkg.t_name_tab;
    l_account_type              com_api_type_pkg.t_name_tab;
    l_balance_type              com_api_type_pkg.t_name_tab;
    l_balance_impact            com_api_type_pkg.t_number_tab;
    l_original_account_id       com_api_type_pkg.t_number_tab;
    l_transf_entity             com_api_type_pkg.t_name_tab;
    l_transf_type               com_api_type_pkg.t_name_tab;
    l_macros_type               com_api_type_pkg.t_number_tab;
    l_processed_entries         com_api_type_pkg.t_integer_tab;
    l_excepted_entries          com_api_type_pkg.t_integer_tab;
    l_status                    com_api_type_pkg.t_name_tab;
    l_ref_id                    com_api_type_pkg.t_number_tab;
    l_split_hash                com_api_type_pkg.t_number_tab;
    l_inst_id                   com_api_type_pkg.t_number_tab;
    l_rounding_method           com_api_type_pkg.t_dict_tab;

    l_prev_transaction_id       com_api_type_pkg.t_long_id;
    l_transaction_tab           acc_api_type_pkg.t_transaction_tab;
    l_transaction_count         com_api_type_pkg.t_count := 0;
    l_acc_entry_buffer_count    com_api_type_pkg.t_count := 0;
    
    l_stmt                      com_api_type_pkg.t_text;
    l_transaction_placeholder   constant com_api_type_pkg.t_name := '##TRANSACTION##';
    l_bunch_placeholder         constant com_api_type_pkg.t_name := '##BUNCH##';
begin

    for r_macros in (
        select m.id
             , m.status
          from acc_macros m
         where m.object_id        = i_object_id
           and m.entity_type      = i_entity_type
           and m.status           = nvl(i_macros_status, m.status)
           and m.macros_type_id   = nvl(i_macros_type,   m.macros_type_id)
           and m.cancel_indicator = com_api_const_pkg.INDICATOR_NOT_CANCELED
         for update nowait
    ) loop
        for r_bunch in (select * from acc_bunch where macros_id = r_macros.id for update nowait) loop
            l_bunch_id1:= r_bunch.id;

            trc_log_pkg.debug (
                i_text        => 'going to partial revert entries bunch [#1]'
              , i_env_param1  => l_bunch_id1
            );

            -- Check that entry buffer is not empty
            select count(1)
              into l_acc_entry_buffer_count
              from acc_entry_buffer
             where rownum = 1;

            if l_acc_entry_buffer_count > 0 then
                delete from acc_entry_buffer
                 where bunch_id = l_bunch_id1;

                trc_log_pkg.debug (
                    i_text        => 'deleted from buffer [#1]'
                  , i_env_param1  => sql%rowcount
                );
            end if;

            l_stmt := '
select
    e.id
    , b.macros_id
    , b.id
    , e.transaction_id
    , e.transaction_type
    , e.account_id
    , e.amount
    , e.currency
    , a.account_type
    , e.balance_type
    , e.balance_impact
    , null
    , null
    , null
    , m.macros_type_id
    , e.id
    , '''||i_entry_status||''' status
    , e.split_hash
    , a.inst_id
    , e.rounding_method
from
    acc_bunch b
    , acc_entry e
    , acc_account a
    , acc_macros m
    , ( select
            null as  transaction_id
            , :i_bunch_id bunch_id
            , :status_posted status_posted
        from
            dual
    ) p
where 1=1 '
            || l_transaction_placeholder
            || l_bunch_placeholder ||'
    and b.id = e.bunch_id
    and e.account_id = a.id
    and b.macros_id = m.id
    and e.status = p.status_posted
order by
    e.transaction_id
    , e.id
for update of
    e.status
            ';
            
            l_stmt := replace(l_stmt, l_bunch_placeholder, ' and b.id = p.bunch_id');

            l_stmt := replace(l_stmt, l_transaction_placeholder, '');
            l_stmt := replace(l_stmt, l_bunch_placeholder, '');

            execute immediate l_stmt 
            bulk collect into
                l_entry_id
                , l_macros_id
                , l_bunch_id
                , l_transaction_id
                , l_transaction_type
                , l_account_id
                , l_amount
                , l_currency
                , l_account_type
                , l_balance_type
                , l_balance_impact
                , l_original_account_id
                , l_transf_entity
                , l_transf_type
                , l_macros_type
                , l_ref_id
                , l_status
                , l_split_hash
                , l_inst_id
                , l_rounding_method
            using l_bunch_id1, acc_api_const_pkg.ENTRY_STATUS_POSTED;

            trc_log_pkg.debug (
                i_text          => '[#1] entries will be reverted'
                , i_env_param1  => l_entry_id.count
            );

            if l_entry_id.count = 0 then
                return;
            else
                for i in 1 .. l_entry_id.count loop
                    l_balance_impact(i) := com_api_type_pkg.invert_sign(l_balance_impact(i));

                    l_entry_id(i) := com_api_id_pkg.get_id(i_seq => acc_entry_seq.nextval);
                    
                    if l_final_unhold = com_api_type_pkg.FALSE or i_amount.amount is not null  then
                        l_amount(i) := i_amount.amount; 
                    end if; 

                    if l_transaction_id(i) = l_prev_transaction_id then
                        l_transaction_id(i) := l_transaction_id(i-1);
                    else
                        l_prev_transaction_id := l_transaction_id(i);
                        l_transaction_id(i) := l_entry_id(i);
                        
                        l_transaction_count := l_transaction_tab.count + 1;
                        l_transaction_tab(l_transaction_count).transaction_id   := l_transaction_id(i);
                        l_transaction_tab(l_transaction_count).transaction_type := l_transaction_type(i);
                        l_transaction_tab(l_transaction_count).macros_id        := l_macros_id(i);
                        l_transaction_tab(l_transaction_count).bunch_id         := l_bunch_id(i);
                        l_transaction_tab(l_transaction_count).split_hash       := l_split_hash(i);
                        l_transaction_tab(l_transaction_count).posting_date     := get_sysdate;
                        l_transaction_tab(l_transaction_count).inst_id          := l_inst_id(i);
                        l_transaction_tab(l_transaction_count).balance_type     := l_balance_type(i);
                    end if;
                end loop;
            end if;

            post_entries (
                i_entry_id                  => l_entry_id
                , i_macros_id               => l_macros_id
                , i_bunch_id                => l_bunch_id
                , i_transaction_id          => l_transaction_id
                , i_transaction_type        => l_transaction_type
                , i_account_id              => l_account_id
                , i_amount                  => l_amount
                , i_currency                => l_currency
                , i_account_type            => l_account_type
                , i_balance_type            => l_balance_type
                , i_balance_impact          => l_balance_impact
                , i_original_account_id     => l_original_account_id
                , i_transf_entity           => l_transf_entity
                , i_transf_type             => l_transf_type
                , i_macros_type             => l_macros_type
                , i_ref_entry_id            => l_ref_id
                , i_status                  => l_status
                , o_processed_entries       => l_processed_entries
                , o_excepted_entries        => l_excepted_entries
                , i_save_exceptions         => com_api_type_pkg.FALSE
                , i_rounding_method         => l_rounding_method
            );

            if l_excepted_entries.count > 0 then
                com_api_error_pkg.raise_error (
                    i_error         => 'ERROR_POSTING_IMMEDIATE_ENTRIES'
                );
            end if;

            if l_final_unhold = com_api_type_pkg.TRUE then
                forall i in 1 .. l_ref_id.count
                    update acc_entry
                       set status       = l_status(i)
                         , ref_entry_id = l_entry_id(i)
                     where id = l_ref_id(i);
            end if;

            raise_transaction_registration (
                i_transaction_tab     => l_transaction_tab
            ); 
    
        end loop;

        if l_final_unhold = com_api_type_pkg.TRUE then
            update acc_macros
               set cancel_indicator = com_api_const_pkg.INDICATOR_CANCELED
             where id = r_macros.id;
        end if;
    end loop;     
end partial_revert_entries;

function get_hold_amount(
    i_object_id              in com_api_type_pkg.t_long_id
  , i_entity_type            in com_api_type_pkg.t_dict_value
) return  com_api_type_pkg.t_amount_rec
is
    l_return                    com_api_type_pkg.t_amount_rec;
begin
    select e.amount
         , e.currency
      into l_return.amount
         , l_return.currency
      from acc_macros m
         , acc_bunch b 
         , acc_entry e
     where m.object_id        = i_object_id
       and m.entity_type      = i_entity_type
       and m.cancel_indicator = com_api_const_pkg.INDICATOR_NOT_CANCELED
       and b.macros_id        = m.id
       and e.bunch_id         = b.id
       and e.status           = acc_api_const_pkg.ENTRY_STATUS_POSTED
       and m.amount_purpose not in (com_api_const_pkg.AMOUNT_PURPOSE_OPER_SURCHARGE
                                  , com_api_const_pkg.AMOUNT_PURPOSE_FEE_AMOUNT
                                  , com_api_const_pkg.AMOUNT_PURPOSE_FEE_EQUIVAL)
       and rownum <= 1;

    return l_return;
end get_hold_amount;

function get_unhold_amount(
    i_object_id              in com_api_type_pkg.t_long_id
  , i_entity_type            in com_api_type_pkg.t_dict_value
) return  com_api_type_pkg.t_amount_rec
is
    l_return                    com_api_type_pkg.t_amount_rec;
    l_curr_tab                  com_api_type_pkg.t_curr_code_tab;
    l_money_tab                 com_api_type_pkg.t_money_tab;
begin
    select e.amount
         , e.currency 
      bulk collect into l_money_tab
                      , l_curr_tab 
      from acc_macros m
         , acc_bunch b 
         , acc_entry e
     where m.object_id        = i_object_id
       and m.entity_type      = i_entity_type
       and m.cancel_indicator = com_api_const_pkg.INDICATOR_NOT_CANCELED
       and b.macros_id        = m.id
       and e.bunch_id         = b.id
       and e.status           = acc_api_const_pkg.ENTRY_STATUS_CANCELED
       and m.amount_purpose not in (com_api_const_pkg.AMOUNT_PURPOSE_OPER_SURCHARGE
                                  , com_api_const_pkg.AMOUNT_PURPOSE_FEE_AMOUNT
                                  , com_api_const_pkg.AMOUNT_PURPOSE_FEE_EQUIVAL);
    
    if l_money_tab.count > 0 then
        for i in l_money_tab.first..l_money_tab.last loop
            l_return.currency := l_curr_tab(i);
            l_return.amount   := nvl(l_return.amount,0) + l_money_tab(i);
        end loop;
    end if;
    
    return l_return;
end get_unhold_amount;

procedure set_is_settled(
    i_entry_id             in    com_api_type_pkg.t_long_id
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_id
) is
    l_eff_date                   date;
begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    update acc_entry
       set is_settled     = i_is_settled
         , sttl_flag_date = i_sttl_flag_date
     where id = i_entry_id;

    if i_is_settled = com_api_const_pkg.TRUE then
        evt_api_event_pkg.register_event(
            i_event_type         =>      acc_api_const_pkg.EVENT_ENTRY_IS_CLEARED
          , i_eff_date           =>      l_eff_date
          , i_entity_type        =>      acc_api_const_pkg.ENTITY_TYPE_ENTRY
          , i_object_id          =>      i_entry_id
          , i_inst_id            =>      i_inst_id
          , i_split_hash         =>      i_split_hash
          , i_status             =>      null
        );
    end if;
end set_is_settled;

procedure set_is_settled(
    i_entry_id_tab         in    com_api_type_pkg.t_long_tab
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id_tab
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_tab
) is
    l_eff_date                   date;
begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    if i_entry_id_tab.count > 0 then
        forall i in i_entry_id_tab.first..i_entry_id_tab.last
            update acc_entry
               set is_settled     = i_is_settled
                 , sttl_flag_date = i_sttl_flag_date
             where id = i_entry_id_tab(i);

        if i_is_settled = com_api_const_pkg.TRUE then
            for i in i_entry_id_tab.first..i_entry_id_tab.last
            loop
                evt_api_event_pkg.register_event(
                    i_event_type         =>      acc_api_const_pkg.EVENT_ENTRY_IS_CLEARED
                  , i_eff_date           =>      l_eff_date
                  , i_entity_type        =>      acc_api_const_pkg.ENTITY_TYPE_ENTRY
                  , i_object_id          =>      i_entry_id_tab(i)
                  , i_inst_id            =>      i_inst_id(i)
                  , i_split_hash         =>      i_split_hash(i)
                  , i_status             =>      null
                );
            end loop;
        end if;
    end if;
end set_is_settled;

procedure set_is_settled(
    i_operation_id_tab     in    num_tab_tpt
  , i_is_settled           in    com_api_type_pkg.t_boolean     := com_api_const_pkg.FALSE
  , i_inst_id              in    com_api_type_pkg.t_inst_id_tab
  , i_sttl_flag_date       in    date                           := null
  , i_split_hash           in    com_api_type_pkg.t_tiny_tab
) is
    l_eff_date                   date;
    l_acc_entry_tab              com_api_type_pkg.t_number_tab;
begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    if i_operation_id_tab.count > 0 then
        select ae.id
          bulk collect into l_acc_entry_tab
          from opr_operation oo
             , acc_macros    am
             , acc_entry     ae
         where oo.id          in (select column_value from table(cast(i_operation_id_tab as num_tab_tpt)))
           and oo.id           = am.object_id
           and am.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and am.id           = ae.macros_id;
    end if;

    if l_acc_entry_tab.count > 0 then
        forall i in l_acc_entry_tab.first..l_acc_entry_tab.last
            update acc_entry
               set is_settled     = i_is_settled
                 , sttl_flag_date = i_sttl_flag_date
             where id = l_acc_entry_tab(i);

        if i_is_settled = com_api_const_pkg.TRUE then
            for i in l_acc_entry_tab.first..l_acc_entry_tab.last
            loop
                evt_api_event_pkg.register_event(
                    i_event_type         =>      acc_api_const_pkg.EVENT_ENTRY_IS_CLEARED
                  , i_eff_date           =>      l_eff_date
                  , i_entity_type        =>      acc_api_const_pkg.ENTITY_TYPE_ENTRY
                  , i_object_id          =>      l_acc_entry_tab(i)
                  , i_inst_id            =>      i_inst_id(i)
                  , i_split_hash         =>      i_split_hash(i)
                  , i_status             =>      null
                );
            end loop;
        end if;
    end if;
end set_is_settled;

end acc_api_entry_pkg;
/
