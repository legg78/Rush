create or replace package body acc_api_account_pkg is
/*********************************************************
*  Accounting API <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 06.08.2009 <br />
*  Module: ACC_API_ACCOUNT_PKG <br />
*  @headcom
**********************************************************/

--BULK_LIMIT              constant pls_integer := 400;

-- Global record for caching method get_account_info/get_account
g_account                        acc_api_type_pkg.t_account_rec;

procedure create_account (
    o_id                     out com_api_type_pkg.t_account_id
  , io_split_hash         in out com_api_type_pkg.t_tiny_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , io_account_number     in out com_api_type_pkg.t_account_number
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id
  , i_status              in     com_api_type_pkg.t_dict_value
  , i_contract_id         in     com_api_type_pkg.t_medium_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_customer_number     in     com_api_type_pkg.t_name
) is
    l_id_tab                     com_api_type_pkg.t_number_tab;
    l_split_hash_tab             com_api_type_pkg.t_number_tab;
    l_account_type_tab           com_api_type_pkg.t_dict_tab;
    l_account_num_tab            com_api_type_pkg.t_account_number_tab;
    l_currency_tab               com_api_type_pkg.t_curr_code_tab;
    l_inst_tab                   com_api_type_pkg.t_inst_id_tab;
    l_agent_tab                  com_api_type_pkg.t_agent_id_tab;
    l_status                     com_api_type_pkg.t_dict_tab;
    l_contract_id                com_api_type_pkg.t_number_tab;
    l_customer_id                com_api_type_pkg.t_number_tab;
    l_customer_number            com_api_type_pkg.t_name_tab;
begin
    l_split_hash_tab(1)     := io_split_hash;
    l_account_type_tab(1)   := i_account_type;
    l_account_num_tab(1)    := io_account_number;
    l_currency_tab(1)       := i_currency;
    l_inst_tab(1)           := i_inst_id;
    l_agent_tab(1)          := i_agent_id;
    l_status(1)             := i_status;
    l_contract_id(1)        := i_contract_id;
    l_customer_id(1)        := i_customer_id;
    l_customer_number(1)    := i_customer_number;

    create_accounts (
        io_id_tab             => l_id_tab
      , io_split_hash_tab     => l_split_hash_tab
      , i_account_type_tab    => l_account_type_tab
      , io_account_num_tab    => l_account_num_tab
      , i_currency_tab        => l_currency_tab
      , i_inst_tab            => l_inst_tab
      , i_agent_tab           => l_agent_tab
      , i_status              => l_status
      , i_contract_id         => l_contract_id
      , i_customer_id         => l_customer_id
      , i_customer_number     => l_customer_number
    );

    if l_id_tab.exists(1) then o_id := l_id_tab(1); end if;
    if l_account_num_tab.exists(1) then io_account_number := l_account_num_tab(1); end if;
    if l_split_hash_tab.exists(1) then io_split_hash := l_split_hash_tab(1); end if;
end;

procedure create_accounts(
    io_account_tab        in out nocopy acc_api_type_pkg.t_account_tab
) is
    l_id_tab                com_api_type_pkg.t_number_tab;
    l_split_hash_tab        com_api_type_pkg.t_number_tab;
    l_account_type_tab      com_api_type_pkg.t_dict_tab;
    l_account_num_tab       com_api_type_pkg.t_account_number_tab;
    l_currency_tab          com_api_type_pkg.t_curr_code_tab;
    l_inst_tab              com_api_type_pkg.t_inst_id_tab;
    l_agent_tab             com_api_type_pkg.t_agent_id_tab;
    l_status                com_api_type_pkg.t_dict_tab;
    l_contract_id           com_api_type_pkg.t_number_tab;
    l_customer_id           com_api_type_pkg.t_number_tab;
    l_customer_number       com_api_type_pkg.t_name_tab;
begin
    for i in 1 .. io_account_tab.count loop
        l_split_hash_tab(i)     := io_account_tab(i).split_hash;
        l_account_type_tab(i)   := io_account_tab(i).account_type;
        l_account_num_tab(i)    := io_account_tab(i).account_number;
        l_currency_tab(i)       := io_account_tab(i).currency;
        l_inst_tab(i)           := io_account_tab(i).inst_id;
        l_agent_tab(i)          := io_account_tab(i).agent_id;
        l_status(i)             := io_account_tab(i).status;
        l_contract_id(i)        := io_account_tab(i).contract_id;
        l_customer_id(i)        := io_account_tab(i).customer_id;
    end loop;

    create_accounts (
        io_id_tab               => l_id_tab
        , io_split_hash_tab     => l_split_hash_tab
        , i_account_type_tab    => l_account_type_tab
        , io_account_num_tab    => l_account_num_tab
        , i_currency_tab        => l_currency_tab
        , i_inst_tab            => l_inst_tab
        , i_agent_tab           => l_agent_tab
        , i_status              => l_status
        , i_contract_id         => l_contract_id
        , i_customer_id         => l_customer_id
        , i_customer_number     => l_customer_number
    );

    for i in 1 .. l_id_tab.count loop
        io_account_tab(i).account_id := l_id_tab(i);
        io_account_tab(i).account_number := l_account_num_tab(i);
        io_account_tab(i).split_hash := l_split_hash_tab(i);
    end loop;
end;

function load_account_type (
    i_account_type    in      com_api_type_pkg.t_dict_value
  , i_inst_id         in      com_api_type_pkg.t_inst_id
) return acc_account_type%rowtype is
    l_result        acc_account_type%rowtype;
begin
    select *
      into l_result
      from acc_account_type
     where inst_id      = i_inst_id
       and account_type = i_account_type;

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error       => 'INCONSISTENT_ACCOUNT_TYPE_FOR_INST'
          , i_env_param1  => i_account_type
          , i_env_param2  => i_inst_id
        );
end;

function check_account_number_unique (
    i_account_number   in      com_api_type_pkg.t_account_number
  , i_inst_id          in      com_api_type_pkg.t_inst_id
) return number is
    l_check_cnt        com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_check_cnt
      from acc_account a
     where a.account_number = i_account_number
       and a.inst_id        = i_inst_id
       and rownum           < 2;

    return l_check_cnt;
end;

function check_balance_number_unique (
    i_balance_number   in     com_api_type_pkg.t_account_number
  , i_inst_id          in     com_api_type_pkg.t_inst_id
) return number is
    l_check_cnt        com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_check_cnt
      from acc_balance a
     where a.balance_number = i_balance_number
       and a.inst_id        = i_inst_id
       and rownum           < 2;

    return l_check_cnt;
end;

procedure create_accounts(
    io_id_tab             in out nocopy com_api_type_pkg.t_number_tab
  , io_split_hash_tab     in out com_api_type_pkg.t_number_tab
  , i_account_type_tab    in     com_api_type_pkg.t_dict_tab
  , io_account_num_tab    in out com_api_type_pkg.t_account_number_tab
  , i_currency_tab        in     com_api_type_pkg.t_curr_code_tab
  , i_inst_tab            in     com_api_type_pkg.t_inst_id_tab
  , i_agent_tab           in     com_api_type_pkg.t_agent_id_tab
  , i_status              in     com_api_type_pkg.t_dict_tab
  , i_contract_id         in     com_api_type_pkg.t_number_tab
  , i_customer_id         in     com_api_type_pkg.t_number_tab
  , i_customer_number     in     com_api_type_pkg.t_name_tab
) is
    l_balance_id_tab             com_api_type_pkg.t_number_tab;
    l_balance_split_hash_tab     com_api_type_pkg.t_number_tab;
    l_balance_account_id_tab     com_api_type_pkg.t_number_tab;
    l_balance_currency_tab       com_api_type_pkg.t_curr_code_tab;
    l_balance_type_tab           com_api_type_pkg.t_dict_tab;
    l_balance_type_prefix_tab    com_api_type_pkg.t_name_tab;
    l_balance_status_tab         com_api_type_pkg.t_dict_tab;
    l_balance_inst_tab           com_api_type_pkg.t_inst_id_tab;
    l_balance_num_tab            com_api_type_pkg.t_account_number_tab;
    l_account_date_tab           com_api_type_pkg.t_date_tab;
    l_balance_date_tab           com_api_type_pkg.t_date_tab;
    l_scheme_id                  com_api_type_pkg.t_tiny_tab;
    l_account_type               acc_account_type%rowtype;
    l_params                     com_api_type_pkg.t_param_tab;
    l_ret_val                    com_api_type_pkg.t_sign;
    MAX_GEN_TRYING      constant com_api_type_pkg.t_count := 1000;
    gen_trying                   com_api_type_pkg.t_count := 0;
    k                            integer;
    l_balances_found             boolean;
    l_str                        com_api_type_pkg.t_full_desc;
    l_max_len                    number;
    l_object_key                 com_api_type_pkg.t_semaphore_name;
begin
    savepoint creating_accounts;

    trc_log_pkg.debug (
        i_text        => 'Going to create [#1] accounts'
      , i_env_param1  => i_account_type_tab.count
    );
    for i in 1 .. i_account_type_tab.count loop
        trc_log_pkg.debug (
            i_text        => 'Going to create account [#1]'
          , i_env_param1  => i
        );

        ost_api_institution_pkg.check_status(
            i_inst_id     => i_inst_tab(i)
          , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
        );

        l_account_type := load_account_type(
            i_inst_id         => i_inst_tab(i)
          , i_account_type    => i_account_type_tab(i)
        );

        io_id_tab(i) := acc_account_seq.nextval;

        l_params.delete;

        rul_api_param_pkg.set_param(
            i_name          => 'ACCOUNT_TYPE'
          , i_value         => i_account_type_tab(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'ACCOUNT_TYPE_PREFIX'
          , i_value         => l_account_type.number_prefix
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'INST_ID'
          , i_value         => i_inst_tab(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'AGENT_ID'
          , i_value         => i_agent_tab(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'CURRENCY'
          , i_value         => i_currency_tab(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'ACCOUNT_ID'
          , i_value         => to_char(io_id_tab(i))
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'CUSTOMER_ID'
          , i_value         => i_customer_id(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'CUSTOMER_NUMBER'
          , i_value         => i_customer_number(i)
          , io_params       => l_params
        );

        rul_api_shared_data_pkg.load_customer_params(
            i_customer_id   => i_customer_id(i)
          , io_params       => l_params
        );

        if (io_account_num_tab.exists(i) and io_account_num_tab(i) is not null) then

            trc_log_pkg.debug (
                i_text        => 'Account number [#1] specified'
              , i_env_param1  => io_account_num_tab(i)
            );

            if l_account_type.number_format_id is not null then
                if rul_api_name_pkg.check_name (
                    i_format_id   => l_account_type.number_format_id
                  , i_name        => io_account_num_tab(i)
                  , i_param_tab   => l_params
                  , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                ) = com_api_const_pkg.TRUE then

                    trc_log_pkg.debug (
                        i_text        => 'Account number [#1] checked OK'
                      , i_env_param1  => io_account_num_tab(i)
                    );

                else
                    com_api_error_pkg.raise_error (
                        i_error       => 'ENTITY_NAME_DONT_FIT_FORMAT'
                      , i_env_param1  => ost_ui_institution_pkg.get_inst_name(i_inst_tab(i))
                      , i_env_param2  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_env_param3  => io_account_num_tab(i)
                      , i_env_param4  => l_account_type.number_format_id
                    );
                end if;
            else
                trc_log_pkg.debug (
                    i_text        => 'Account number [#1] not checked because of format absence'
                  , i_env_param1  => io_account_num_tab(i)
                );
            end if;

            l_object_key := io_account_num_tab(i) || '.' || i_inst_tab(i);

            if com_api_lock_pkg.request_lock(
                   i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_key  => l_object_key
               ) = 0
            then
                if check_account_number_unique (
                       i_account_number  => io_account_num_tab(i)
                     , i_inst_id         => i_inst_tab(i)
                   ) != 0
                then
                    l_ret_val := com_api_lock_pkg.release_lock(
                                     i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                   , i_object_key  => l_object_key
                                 );

                    com_api_error_pkg.raise_error (
                        i_error       => 'ACCOUNT_NUMBER_NOT_UNIQUE'
                      , i_env_param1  => io_account_num_tab(i)
                      , i_env_param2  => ost_ui_institution_pkg.get_inst_name(i_inst_tab(i))
                    );

                else
                    trc_log_pkg.debug (
                        i_text        => 'Account number [#1] is unique'
                      , i_env_param1  => io_account_num_tab(i)
                    );
                end if;
            else
                com_api_error_pkg.raise_error (
                    i_error       => 'UNABLE_LOCK_OBJECT'
                  , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_env_param2  => io_account_num_tab(i)
                );
            end if;

        elsif l_account_type.number_format_id is not null then
            gen_trying := 0;

            trc_log_pkg.debug (
                i_text        => 'Account number not specified. Going to generate according to format [#1]'
              , i_env_param1  => l_account_type.number_format_id
            );

            if not io_account_num_tab.exists(i) then
                io_account_num_tab(i) := null;
            end if;

            loop
                rul_api_param_pkg.set_param(
                    i_name          => 'TRY_COUNT'
                  , i_value         => gen_trying
                  , io_params       => l_params
                );
                begin
                    l_str := rul_api_name_pkg.get_name (
                        i_format_id           => l_account_type.number_format_id
                      , i_param_tab           => l_params
                      , i_double_check_value  => io_account_num_tab(i)
                    );
                    io_account_num_tab(i) := l_str;
                exception
                    when value_error then
                        select data_length
                          into l_max_len
                          from user_tab_columns
                         where table_name = 'ACC_ACCOUNT'
                           and column_name = 'ACCOUNT_NUMBER';

                        com_api_error_pkg.raise_error(
                            i_error      => 'INVALID_ACCOUNT_NUMBER_FORMAT'
                          , i_env_param1 => l_account_type.number_format_id
                          , i_env_param2 => l_str
                          , i_env_param3 => length(l_str)
                          , i_env_param4 => l_max_len
                        );
                end;
                trc_log_pkg.debug (
                    i_text        => 'Account number generated [#1]'
                  , i_env_param1  => io_account_num_tab(i)
                );

                l_object_key := io_account_num_tab(i) || '.' || i_inst_tab(i);

                if com_api_lock_pkg.request_lock(
                       i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                     , i_object_key  => l_object_key
                   ) = 0
                then
                    if check_account_number_unique(
                           i_account_number  => io_account_num_tab(i)
                         , i_inst_id         => i_inst_tab(i)
                       ) = 0
                    then
                        trc_log_pkg.debug (
                            i_text        => 'Account number [#1] is unique'
                          , i_env_param1  => io_account_num_tab(i)
                        );
                        exit;
                    else
                        trc_log_pkg.debug (
                            i_text        => 'Account number [#1] NOT unique'
                          , i_env_param1  => io_account_num_tab(i)
                        );

                        l_ret_val  := com_api_lock_pkg.release_lock(
                                          i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                        , i_object_key  => l_object_key
                                      );
                        gen_trying := gen_trying + 1;
                    end if;

                else
                    gen_trying := gen_trying + 1;
                end if;

                if gen_trying > MAX_GEN_TRYING then
                    com_api_error_pkg.raise_error (
                        i_error       => 'UNABLE_GENERATE_ACCOUNT_NUMBER'
                      , i_env_param1  => MAX_GEN_TRYING
                      , i_env_param2  => i_inst_tab(i)
                      , i_env_param3  => i_account_type_tab(i)
                    );
                end if;
            end loop;

        else
            com_api_error_pkg.raise_error (
                i_error       => 'ENTITY_NAME_FORMAT_NOT_DEFINED'
              , i_env_param1  => ost_ui_institution_pkg.get_inst_name(i_inst_tab(i))
              , i_env_param2  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_env_param3  => i_account_type_tab(i)
            );
        end if;
    end loop;

    trc_log_pkg.debug (
        i_text          => 'Going to create balances'
    );

    for i in 1 .. io_account_num_tab.count loop
        trc_log_pkg.debug (
            i_text        => '[#2] Going to create balances for account [#1]'
          , i_env_param1  => io_account_num_tab(i)
          , i_env_param2  => i
        );

        if io_split_hash_tab.exists(i) and io_split_hash_tab(i) is not null then
            trc_log_pkg.debug (
                i_text        => 'Split specified as parameter [#1]'
              , i_env_param1  => io_split_hash_tab(i)
            );

        elsif i_customer_id.exists(i) and i_customer_id(i) is not null then
            io_split_hash_tab(i) := com_api_hash_pkg.get_split_hash (
                i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id       => i_customer_id(i)
            );
            trc_log_pkg.debug (
                i_text        => 'Split hash [#1] taken from customer [#2]'
              , i_env_param1  => io_split_hash_tab(i)
              , i_env_param2  => i_customer_id(i)
            );

        else
            io_split_hash_tab(i) := com_api_hash_pkg.get_split_hash(io_account_num_tab(i));
            trc_log_pkg.debug (
                i_text        => 'Split hash set to [#1] according to number [#2]'
              , i_env_param1  => io_split_hash_tab(i)
              , i_env_param2  => io_account_num_tab(i)
            );
        end if;

        l_account_date_tab(i) := com_api_sttl_day_pkg.get_sysdate;

        l_params.delete;

        rul_api_param_pkg.set_param(
            i_name          => 'ACCOUNT_NUMBER'
          , i_value         => io_account_num_tab(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'ACCOUNT_TYPE'
          , i_value         => i_account_type_tab(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'ACCOUNT_TYPE_PREFIX'
          , i_value         => l_account_type.number_prefix
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'INST_ID'
          , i_value         => i_inst_tab(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'AGENT_ID'
          , i_value         => i_agent_tab(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'ACCOUNT_ID'
          , i_value         => to_char(io_id_tab(i))
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'CUSTOMER_ID'
          , i_value         => i_customer_id(i)
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'CUSTOMER_NUMBER'
          , i_value         => i_customer_number(i)
          , io_params       => l_params
        );

        l_balances_found := false;

        for rec in (
            select acc_balance_seq.nextval            balance_id
                 , io_split_hash_tab(i)               balance_split_hash
                 , io_id_tab(i)                       balance_account_id
                 , balance_type                       balance_type
                 , nvl(currency, i_currency_tab(i))   balance_currency
                 , status                             balance_status
                 , inst_id                            balance_inst
                 , number_format_id
                 , number_prefix                      balance_type_prefix
              from acc_balance_type
             where account_type = i_account_type_tab(i)
               and inst_id      = i_inst_tab(i)
        ) loop
            l_balances_found             := true;
            k                            := l_balance_id_tab.count + 1;
            l_balance_id_tab(k)          := rec.balance_id;
            l_balance_split_hash_tab(k)  := rec.balance_split_hash;
            l_balance_account_id_tab(k)  := rec.balance_account_id;
            l_balance_type_tab(k)        := rec.balance_type;
            l_balance_type_prefix_tab(k) := rec.balance_type_prefix;
            l_balance_currency_tab(k)    := rec.balance_currency;
            l_balance_status_tab(k)      := rec.balance_status;
            l_balance_inst_tab(k)        := rec.balance_inst;
            l_balance_date_tab(k)        := com_api_sttl_day_pkg.get_sysdate;
            l_balance_num_tab(k)         := null;

            if rec.number_format_id is not null then

                rul_api_param_pkg.set_param(
                    i_name          => 'BALANCE_ID'
                  , i_value         => l_balance_id_tab(k)
                  , io_params       => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name          => 'CURRENCY'
                  , i_value         => l_balance_currency_tab(k)
                  , io_params       => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name          => 'BALANCE_TYPE'
                  , i_value         => l_balance_type_tab(k)
                  , io_params       => l_params
                );

                rul_api_param_pkg.set_param(
                    i_name          => 'BALANCE_TYPE_PREFIX'
                  , i_value         => l_balance_type_prefix_tab(k)
                  , io_params       => l_params
                );

                gen_trying := 0;

                loop
                    rul_api_param_pkg.set_param(
                        i_name          => 'TRY_COUNT'
                      , i_value         => gen_trying
                      , io_params       => l_params
                    );

                    l_balance_num_tab(k) := rul_api_name_pkg.get_name (
                        i_format_id           => rec.number_format_id
                      , i_param_tab           => l_params
                      , i_double_check_value  => l_balance_num_tab(k)
                    );

                    if com_api_lock_pkg.request_lock(
                           i_entity_type => acc_api_const_pkg.ENTITY_TYPE_BALANCE
                         , i_object_key  => l_balance_num_tab(k)
                       ) = 0
                    then
                        if check_balance_number_unique (
                               i_balance_number  => l_balance_num_tab(k)
                             , i_inst_id         => l_balance_inst_tab(k)
                           ) = 0
                        then
                            exit;
                        else
                            l_ret_val  := com_api_lock_pkg.release_lock(
                                                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_BALANCE
                                              , i_object_key  => l_balance_num_tab(k)
                                            );
                            gen_trying := gen_trying + 1;
                        end if;
                    else
                        gen_trying := gen_trying + 1;
                    end if;

                    if gen_trying > MAX_GEN_TRYING then
                        com_api_error_pkg.raise_error (
                            i_error       => 'UNABLE_GENERATE_BALANCE_NUMBER'
                          , i_env_param1  => MAX_GEN_TRYING
                          , i_env_param2  => l_balance_inst_tab(k)
                          , i_env_param3  => i_account_type_tab(i)
                          , i_env_param4  => l_balance_type_tab(k)
                        );
                    end if;
                end loop;
            else
                l_balance_num_tab(k) := null;
            end if;
        end loop;

        if not l_balances_found then
            com_api_error_pkg.raise_error (
                i_error       => 'ACCOUNT_TYPE_WITHOUT_BALANCES'
              , i_env_param1  => i_account_type_tab(i)
              , i_env_param2  => i_inst_tab(i)
            );
        end if;
    end loop;

    trc_log_pkg.debug (
        i_text          => 'Going to insert accounts'
    );

    for i in 1..io_account_num_tab.count loop
        select
            min(a.scheme_id)
        into
            l_scheme_id(i)
        from
            acc_product_account_type a
          , prd_contract b
        where
            a.product_id = b.product_id
            and b.id = i_contract_id(i)
            and a.account_type = i_account_type_tab(i)
            and a.currency = i_currency_tab(i);
    end loop;

    forall i in 1 .. io_account_num_tab.count
        insert into acc_account (
            id
          , split_hash
          , account_type
          , account_number
          , currency
          , inst_id
          , agent_id
          , status
          , contract_id
          , customer_id
          , scheme_id
        ) values (
            io_id_tab(i)
          , io_split_hash_tab(i)
          , i_account_type_tab(i)
          , io_account_num_tab(i)
          , i_currency_tab(i)
          , i_inst_tab(i)
          , i_agent_tab(i)
          , i_status(i)
          , i_contract_id(i)
          , i_customer_id(i)
          , l_scheme_id(i)
        );

    trc_log_pkg.debug (
        i_text        => '[#1] Accounts saved'
      , i_env_param1  => io_account_num_tab.count
    );

    trc_log_pkg.debug (
        i_text        => 'Going to insert balances'
      , i_env_param1  => io_account_num_tab.count
    );

    forall i in 1 .. l_balance_id_tab.count
        insert into acc_balance (
            id
          , split_hash
          , account_id
          , balance_type
          , balance_number
          , balance
          , rounding_balance
          , currency
          , entry_count
          , status
          , inst_id
          , open_date
          , open_sttl_date
        ) values (
            l_balance_id_tab(i)
          , l_balance_split_hash_tab(i)
          , l_balance_account_id_tab(i)
          , l_balance_type_tab(i)
          , l_balance_num_tab(i)
          , 0
          , 0
          , l_balance_currency_tab(i)
          , 0
          , l_balance_status_tab(i)
          , l_balance_inst_tab(i)
          , case l_balance_status_tab(i)
                when acc_api_const_pkg.BALANCE_STATUS_ACTIVE then get_sysdate
                when acc_api_const_pkg.BALANCE_STATUS_FIRST_USAGE then get_sysdate
                else null
            end
          , case l_balance_status_tab(i)
                when acc_api_const_pkg.BALANCE_STATUS_ACTIVE then com_api_sttl_day_pkg.get_open_sttl_date(l_balance_inst_tab(i))
                when acc_api_const_pkg.BALANCE_STATUS_FIRST_USAGE then com_api_sttl_day_pkg.get_open_sttl_date(l_balance_inst_tab(i))
                else null
            end
        );

    trc_log_pkg.debug (
        i_text        => '[#1] Balances saved'
      , i_env_param1  => l_balance_id_tab.count
    );

    for i in 1 .. io_id_tab.count loop
        l_params.delete;

        rul_api_param_pkg.set_param (
            io_params    => l_params
          , i_name       => 'ACCOUNT_TYPE'
          , i_value      => i_account_type_tab(i)
        );
        rul_api_param_pkg.set_param (
            io_params    => l_params
          , i_name       => 'CURRENCY'
          , i_value      => i_currency_tab(i)
        );
        rul_api_param_pkg.set_param (
            io_params    => l_params
          , i_name       => 'CONTRACT_ID'
          , i_value      => i_contract_id(i)
        );

        evt_api_event_pkg.register_event(
            i_event_type        => acc_api_const_pkg.EVENT_ACCOUNT_CREATION
          , i_eff_date          => l_account_date_tab(i)
          , i_param_tab         => l_params
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => io_id_tab(i)
          , i_inst_id           => i_inst_tab(i)
          , i_split_hash        => io_split_hash_tab(i)
        );
    end loop;

    for i in 1 .. l_balance_id_tab.count loop
        l_params.delete;

        rul_api_param_pkg.set_param (
            io_params   => l_params
          , i_name      => 'BALANCE_TYPE'
          , i_value     => l_balance_type_tab(i)
        );
        rul_api_param_pkg.set_param (
            io_params   => l_params
          , i_name      => 'CURRENCY'
          , i_value     => l_balance_currency_tab(i)
        );

        evt_api_event_pkg.register_event(
            i_event_type        => acc_api_const_pkg.EVENT_BALANCE_CREATION
          , i_eff_date          => l_balance_date_tab(i)
          , i_param_tab         => l_params
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_BALANCE
          , i_object_id         => l_balance_id_tab(i)
          , i_inst_id           => l_balance_inst_tab(i)
          , i_split_hash        => l_balance_split_hash_tab(i)
        );

        if l_balance_status_tab(i) = acc_api_const_pkg.BALANCE_STATUS_ACTIVE then
            evt_api_event_pkg.register_event(
                i_event_type  => acc_api_const_pkg.EVENT_BALANCE_ACCOUNT_CREATION
              , i_eff_date    => get_sysdate
              , i_param_tab   => l_params
              , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_BALANCE
              , i_object_id   => l_balance_id_tab(i)
              , i_inst_id     => l_balance_inst_tab(i)
              , i_split_hash  => l_balance_split_hash_tab(i)
            );
        end if;

    end loop;

    for i in 1 .. io_id_tab.count loop
        evt_api_status_pkg.add_status_log (
            i_event_type  => acc_api_const_pkg.EVENT_ACCOUNT_CREATION
          , i_initiator   => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => io_id_tab(i)
          , i_reason      => acc_api_const_pkg.EVENT_ACCOUNT_CREATION
          , i_status      => i_status(i)
          , i_eff_date    => get_sysdate
        );
    end loop;
exception
    when others then
        io_id_tab.delete;
        rollback to savepoint creating_accounts;
        raise;
end create_accounts;

procedure remove_account(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id             default null
) is
    l_count                      pls_integer;
    l_account_rec                acc_api_type_pkg.t_account_rec;
    l_inst_id                    com_api_type_pkg.t_inst_id;
begin
    select count(1)
      into l_count
      from acc_entry
     where account_id = i_account_id
       and split_hash = i_split_hash
       and rownum     = 1;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error         => 'ACCOUNT_HAS_FUNDS_TRANS'
        );
    end if;

    select count(1)
      into l_count
      from acc_balance b
     where b.account_id = i_account_id
       and b.balance   != 0;

    if l_count > 0 then
        get_account_info(
            i_account_id            => i_account_id
          , o_account_rec           => l_account_rec
        );

        com_api_error_pkg.raise_error(
            i_error      => 'ACC_ACCOUNT_HAS_NONEMPTY_BALANCE'
          , i_env_param1 => l_account_rec.account_type
          , i_env_param2 => l_account_rec.currency
        );
    end if;

    select inst_id
      into l_inst_id
      from acc_account a
     where a.id = i_account_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    if i_split_hash is not null then
        delete from acc_account_vw where id         = i_account_id and split_hash = i_split_hash;
        delete from acc_balance    where account_id = i_account_id and split_hash = i_split_hash;
    else
        delete from acc_account_vw where id         = i_account_id;
        delete from acc_balance    where account_id = i_account_id;
    end if;

    clear_cache();

    delete from acc_account_object where account_id = i_account_id;
end;

procedure assert_account_type (
    i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_object_id     in     com_api_type_pkg.t_long_id
  , i_account_type  in     com_api_type_pkg.t_dict_value
  , i_inst_id       in     com_api_type_pkg.t_inst_id
) is
    l_check_ok      com_api_type_pkg.t_boolean;
begin
    select com_api_type_pkg.TRUE
      into l_check_ok
      from acc_account_type_entity
     where account_type = i_account_type
       and entity_type  = i_entity_type
       and inst_id      = i_inst_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error             => 'ENTITY_TYPE_INCONSISTENT_ACCOUNT_TYPE'
          , i_env_param1        => i_entity_type
          , i_env_param2        => i_account_type
        );
end;

procedure add_account_object(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_usage_order         in     com_api_type_pkg.t_tiny_id             default null
  , i_is_pos_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_default      in     com_api_type_pkg.t_boolean             default null
  , i_is_atm_currency     in     com_api_type_pkg.t_boolean             default null
  , i_is_pos_currency     in     com_api_type_pkg.t_boolean             default null
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number  default null
  , o_account_object_id      out com_api_type_pkg.t_long_id
) is
    l_count                      com_api_type_pkg.t_long_id;
    l_account_type               com_api_type_pkg.t_dict_value;
    l_inst_id                    com_api_type_pkg.t_inst_id;
    l_split_hash                 com_api_type_pkg.t_tiny_id;
    l_params                     com_api_type_pkg.t_param_tab;
    l_currency                   com_api_type_pkg.t_curr_code;
begin
    begin
        select account_type
             , inst_id
             , split_hash
             , currency
          into l_account_type
             , l_inst_id
             , l_split_hash
             , l_currency
          from acc_account
         where id = i_account_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error           => 'ACCOUNT_NOT_FOUND'
              , i_env_param1      => i_account_id
            );
    end;

    if i_entity_type != com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        assert_account_type(
            i_account_type        => l_account_type
          , i_entity_type         => i_entity_type
          , i_object_id           => i_object_id
          , i_inst_id             => l_inst_id
        );
    end if;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    if i_usage_order is null then
        select count(1) + 1
          into l_count
          from acc_account a
             , acc_account_object b
         where b.entity_type  = i_entity_type
           and b.object_id    = i_object_id
           and b.account_id   = a.id
           and a.account_type = l_account_type;

    else
       l_count := i_usage_order;
    end if;

    begin
        insert into acc_account_object(
            id
          , account_id
          , entity_type
          , object_id
          , usage_order
          , split_hash
          , is_pos_default
          , is_atm_default
          , is_atm_currency
          , is_pos_currency
          , account_seq_number
        ) values (
            acc_account_object_seq.nextval
          , i_account_id
          , i_entity_type
          , i_object_id
          , l_count
          , l_split_hash
          , i_is_pos_default
          , i_is_atm_default
          , i_is_atm_currency
          , i_is_pos_currency
          , i_account_seq_number
        )
        returning id into o_account_object_id;
    exception
        when dup_val_on_index then
            trc_log_pkg.debug('Object was already attached to account');
            --update default accounts
            if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
                update acc_account_object
                   set is_pos_default = nvl(i_is_pos_default, 0)
                     , is_atm_default = nvl(i_is_atm_default, 0)
                 where account_id  = i_account_id
                   and entity_type = i_entity_type
                   and object_id   = i_object_id;
            end if;
    end;

    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        evt_api_shared_data_pkg.set_param (
            i_name  => 'CURRENCY'
          , i_value => l_currency
        );

        evt_api_shared_data_pkg.set_param (
            i_name  => 'ACCOUNT_TYPE'
          , i_value => l_account_type
        );

        evt_api_shared_data_pkg.set_param (
            i_name  => 'ACCOUNT_ID'
          , i_value => i_account_id
        );
        l_params('ACCOUNT_ID') := i_account_id;

        evt_api_event_pkg.register_event(
            i_event_type          => iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD
          , i_eff_date            => get_sysdate
          , i_entity_type         => i_entity_type
          , i_object_id           => i_object_id
          , i_inst_id             => l_inst_id
          , i_split_hash          => l_split_hash
          , i_param_tab           => l_params
        );
    end if;
end add_account_object;

/*
 * Procedure checks incoming account sequential number and returns it if it is not used for incoming entity object;
 * otherwise, it either raises an error or ignores incoming value and returns next correct value.
 */
procedure get_seq_number(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number
  , i_mask_error          in     com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
  , o_account_seq_number     out acc_api_type_pkg.t_account_seq_number
) is
    l_account_seq_number         acc_api_type_pkg.t_account_seq_number;
    l_is_seq_number_used         com_api_type_pkg.t_boolean;
begin
    select max(a.account_seq_number)
      into l_account_seq_number
      from (
          select ao.account_seq_number
            from acc_account_object ao
           where ao.entity_type = i_entity_type
             and ao.object_id   = i_object_id
           union all
          select u.account_seq_number
            from acc_unlink_account u
           where u.entity_type  = i_entity_type
             and u.object_id    = i_object_id
      ) a;

    l_account_seq_number := nvl(l_account_seq_number, 0) + 1;  -- next available sequential number
    l_is_seq_number_used := nvl(
                                case
                                    when nvl(l_account_seq_number, 0) = i_account_seq_number
                                    then com_api_const_pkg.TRUE
                                    else com_api_const_pkg.FALSE
                                end
                              , com_api_const_pkg.FALSE
                            );

    if l_is_seq_number_used = com_api_const_pkg.FALSE then
        o_account_seq_number := nvl(i_account_seq_number, l_account_seq_number);
    else
        com_api_error_pkg.raise_error(
            i_error       => 'ACCOUNT_SEQ_NUMBER_IS_ALREADY_USED'
          , i_env_param1  => i_account_seq_number
          , i_env_param2  => i_entity_type
          , i_env_param3  => i_object_id
          , i_entity_type => i_entity_type
          , i_object_id   => i_object_id
          , i_mask_error  => i_mask_error
        );
    end if;

exception
    when com_api_error_pkg.e_application_error then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            raise;
        else
            o_account_seq_number := l_account_seq_number;
        end if;
end get_seq_number;

procedure copy_account_object(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_source_object_id    in     com_api_type_pkg.t_long_id
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_is_pos_default      in     com_api_type_pkg.t_boolean            default null
  , i_is_atm_default      in     com_api_type_pkg.t_boolean            default null
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number default null
) is
begin
    insert into acc_account_object(
        id
      , account_id
      , entity_type
      , object_id
      , usage_order
      , split_hash
      , is_pos_default
      , is_atm_default
      , account_seq_number
    )
    select acc_account_object_seq.nextval
         , account_id
         , entity_type
         , i_object_id
         , usage_order
         , i_split_hash
         , i_is_pos_default
         , i_is_atm_default
         , i_account_seq_number
      from acc_account_object
     where object_id   = i_source_object_id
       and entity_type = i_entity_type;
end;

procedure remove_account_object(
    i_account_object_id in     com_api_type_pkg.t_long_id
) is
    l_inst_id                  com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_inst_id
      from acc_account a
         , acc_account_object o
     where a.id = o.account_id
       and o.id = i_account_object_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    delete from acc_account_object where id = i_account_object_id;
end;

function account_object_exists(
    i_account_id        in     com_api_type_pkg.t_account_id
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result            com_api_type_pkg.t_boolean;
begin
    begin
        select com_api_type_pkg.TRUE
          into l_result
          from acc_account_object a
         where a.entity_type = i_entity_type
           and a.object_id   = i_object_id
           and a.account_id  = i_account_id;
    exception
        when no_data_found then
            l_result := com_api_type_pkg.FALSE;
        when others then
            trc_log_pkg.debug(
                i_text       => lower($$PLSQL_UNIT) || '.account_object_exists FAILED: '
                             || 'i_account_id [#1], i_entity_type [#2], i_object_id [#3]'
              , i_env_param1 => i_account_id
              , i_env_param2 => i_entity_type
              , i_env_param3 => i_object_id
            );
            l_result := com_api_type_pkg.FALSE;
    end;
    return l_result;
end;

procedure create_gl_accounts (
    i_entity_type     in      com_api_type_pkg.t_dict_value
  , i_currency        in      com_api_type_pkg.t_curr_code
  , i_inst_id         in      com_api_type_pkg.t_inst_id
  , i_agent_id        in      com_api_type_pkg.t_agent_id
) is
    l_account_type    com_api_type_pkg.t_dict_tab;
    l_account_number  com_api_type_pkg.t_account_number;
    l_id              com_api_type_pkg.t_long_id;
begin
    select atp.account_type
      bulk collect into l_account_type
      from (select t.*
              from acc_account_type_entity t
             where t.entity_type = i_entity_type
               and t.inst_id     = i_inst_id
            minus
            select t.*
              from acc_account_type_entity t
                 , acc_gl_account_mvw a
             where t.entity_type  = i_entity_type
               and t.inst_id      = i_inst_id
               and t.account_type = a.account_type
               and a.entity_id    = decode(i_entity_type
                                         , ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id
                                         , ost_api_const_pkg.ENTITY_TYPE_AGENT, i_agent_id)
               and a.entity_type  = t.entity_type
               and a.currency     = i_currency
        ) atp;

    if l_account_type.count > 0 then
        for i in 1 .. l_account_type.count loop
            l_id := null;
            l_account_number := null;

            create_gl_account (
                o_id               => l_id
              , io_account_number  => l_account_number
              , i_entity_type      => i_entity_type
              , i_account_type     => l_account_type(i)
              , i_currency         => i_currency
              , i_inst_id          => i_inst_id
              , i_agent_id         => i_agent_id
              , i_refresh_mvw      => com_api_type_pkg.FALSE
            );
        end loop;
        dbms_mview.refresh('acc_gl_account_mvw');
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ACCOUNT_TYPE_NOT_DEFINED'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_currency
          , i_env_param3 => i_inst_id
          , i_env_param4 => i_agent_id
        );
    end if;
end;

procedure create_gl_account (
    o_id                    out com_api_type_pkg.t_medium_id
    , io_account_number     in out com_api_type_pkg.t_account_number
    , i_entity_type         in com_api_type_pkg.t_dict_value
    , i_account_type        in com_api_type_pkg.t_dict_value
    , i_currency            in com_api_type_pkg.t_curr_code
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_agent_id            in com_api_type_pkg.t_agent_id
    , i_refresh_mvw         in com_api_type_pkg.t_boolean
) is
    l_check_total           number;
    l_check_currency        number;
    l_split_hash            com_api_type_pkg.t_tiny_id := null;
begin
    select
        count(*)                                        total_count
        , sum(decode(currency, i_currency, 1, 0))       currency_count
    into
        l_check_total
        , l_check_currency
    from
        acc_gl_account_mvw
    where
        entity_id = decode(i_entity_type, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id, ost_api_const_pkg.ENTITY_TYPE_AGENT, i_agent_id)
        and entity_type = i_entity_type
        and account_type = i_account_type;

    if l_check_currency > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'GL_ACCOUNT_TYPE_NOT_UNIQUE'
          , i_env_param1  => i_entity_type
          , i_env_param2  => i_inst_id
          , i_env_param3  => i_agent_id
          , i_env_param4  => i_account_type
          , i_env_param5  => i_currency
        );
    end if;

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    );

    assert_account_type (
        i_account_type          => i_account_type
        , i_entity_type         => i_entity_type
        , i_object_id           => case i_entity_type
                                       when ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then i_inst_id
                                       when ost_api_const_pkg.ENTITY_TYPE_AGENT then i_agent_id
                                   end
        , i_inst_id             => i_inst_id
    );

    create_account (
        o_id                    => o_id
        , io_split_hash         => l_split_hash
        , i_account_type        => i_account_type
        , io_account_number     => io_account_number
        , i_currency            => i_currency
        , i_inst_id             => i_inst_id
        , i_agent_id            => i_agent_id
        , i_status              => acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
        , i_contract_id         => null
        , i_customer_id         => null
        , i_customer_number     => null
    );

    if i_refresh_mvw = com_api_type_pkg.TRUE then
        dbms_mview.refresh('acc_gl_account_mvw');
    end if;
end;

procedure get_account_info(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_curr_code             in      com_api_type_pkg.t_curr_code        default null
  , o_account_number           out  com_api_type_pkg.t_account_number
  , o_inst_id                  out  com_api_type_pkg.t_inst_id
) is
begin
    select account_number
         , inst_id
      into o_account_number
         , o_inst_id
      from (
            select a.account_number
                 , a.inst_id
              from acc_account a
                 , acc_account_object b
             where b.entity_type = i_entity_type
               and b.object_id   = i_object_id
               and b.account_id  = a.id
               and a.currency    = nvl(i_curr_code, a.currency)
             order by b.usage_order
           )
     where rownum = 1;
exception
    when no_data_found then
        o_account_number := null;
        o_inst_id        := null;
end;

procedure get_account_info(
    i_account_id            in      com_api_type_pkg.t_medium_id
  , o_account_number           out  com_api_type_pkg.t_account_number
  , o_entity_type              out  com_api_type_pkg.t_dict_value
  , o_inst_id                  out  com_api_type_pkg.t_inst_id
) is
begin
    select a.account_number
         , b.entity_type
         , a.inst_id
      into o_account_number
         , o_entity_type
         , o_inst_id
      from acc_account a
         , acc_account_object b
     where a.id         = i_account_id
       and b.account_id = a.id
       and rownum = 1;
exception
    when no_data_found then
        o_account_number := null;
        o_entity_type    := null;
        o_inst_id        := null;
end;

/*
 * Invalidating cached account record, it should be called after
 * any change of an account to force getting account data from the table.
 */
procedure clear_cache
is
begin
    g_account := null;
end;

procedure get_account_info(
    i_account_id          in     com_api_type_pkg.t_medium_id
  , o_account_rec            out acc_api_type_pkg.t_account_rec
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) is
begin
    if g_account.account_id = i_account_id then
        o_account_rec := g_account;
    else
        select a.id
             , a.split_hash
             , a.account_type
             , a.account_number
             , null as friendly_name
             , a.currency
             , a.inst_id
             , a.agent_id
             , a.status
             , null as status_reason
             , a.contract_id
             , a.customer_id
             , a.scheme_id
             , null as mod_id
          into o_account_rec
          from acc_account a
         where a.id = i_account_id;
    end if;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'ACCOUNT_NOT_FOUND'
              , i_env_param1 => i_account_id
            );
        end if;
end;

procedure close_account(
    i_account_id          in     com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.close_account: ';
    l_account                    acc_api_type_pkg.t_account_rec;
    l_params                     com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_account_id [' || i_account_id || ']');

    l_account :=
        get_account(
            i_account_id => i_account_id
          , i_mask_error => com_api_const_pkg.FALSE
        );

    if l_account.status = acc_api_const_pkg.ACCOUNT_STATUS_CLOSED then
        com_api_error_pkg.raise_error(
            i_error         => 'ACCOUNT_ALREADY_CLOSED'
          , i_env_param1    => i_account_id
        );
    end if;

    set_account_status(
        i_account_id  => i_account_id
      , i_status      => acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
      , i_reason      => acc_api_const_pkg.EVENT_ACCOUNT_CLOSING
    );

    prd_api_service_pkg.close_service(
        i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
      , i_inst_id     => l_account.inst_id
      , i_split_hash  => l_account.split_hash
      , i_eff_date    => com_api_sttl_day_pkg.get_sysdate()
      , i_params      => l_params
    );

    close_balance(i_account_id => i_account_id);

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end;

procedure close_balance(
    i_account_id          in     com_api_type_pkg.t_medium_id
) is
    l_status                     com_api_type_pkg.t_dict_value;
    l_params                     com_api_type_pkg.t_param_tab;
begin
    for balance in (
        select b.id
             , b.balance
             , b.balance_type
             , b.currency
          from acc_balance_vw b
         where b.account_id = i_account_id
           and b.status     = acc_api_const_pkg.BALANCE_STATUS_ACTIVE
    ) loop
        if balance.balance != 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'UNABLE_CLOSE_NONEMPTY_BALANCE'
              , i_env_param1 => i_account_id
              , i_env_param2 => balance.id
              , i_env_param3 => balance.balance_type
              , i_env_param4 => balance.balance
            );
        end if;

        l_params.delete;
        rul_api_param_pkg.set_param(
            io_params  => l_params
          , i_name     => 'BALANCE_TYPE'
          , i_value    => balance.balance_type
        );
        rul_api_param_pkg.set_param(
            io_params  => l_params
          , i_name     => 'CURRENCY'
          , i_value    => balance.currency
        );

        evt_api_status_pkg.change_status(
            i_initiator       => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_BALANCE
          , i_object_id       => balance.id
          , i_new_status      => acc_api_const_pkg.BALANCE_STATUS_CLOSED
          , i_eff_date        => get_sysdate
          , i_reason          => null
          , o_status          => l_status
          , i_params          => l_params
          , i_register_event  => com_api_type_pkg.TRUE
        );

        update acc_balance_vw b
           set b.close_date      = com_api_sttl_day_pkg.get_sysdate()
             , b.close_sttl_date = com_api_sttl_day_pkg.get_open_sttl_date(b.inst_id)
         where b.id = balance.id;
    end loop;
end close_balance;

procedure set_account_status(
    i_account_id      in      com_api_type_pkg.t_medium_id
  , i_status          in      com_api_type_pkg.t_dict_value
  , i_reason          in      com_api_type_pkg.t_dict_value    default null
) is
    l_returned_status         com_api_type_pkg.t_dict_value;
    l_params                  com_api_type_pkg.t_param_tab;
begin
    evt_api_status_pkg.change_status(
        i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id      => i_account_id
      , i_new_status     => i_status
      , i_reason         => i_reason
      , o_status         => l_returned_status
      , i_eff_date       => get_sysdate
      , i_raise_error    => com_api_const_pkg.TRUE
      , i_params         => l_params
    );
    clear_cache();
end;

procedure find_account (
    i_account_number      in     com_api_type_pkg.t_account_number
  , i_oper_type           in     com_api_type_pkg.t_dict_value
  , i_party_type          in     com_api_type_pkg.t_dict_value
  , i_msg_type            in     com_api_type_pkg.t_dict_value          default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id             default null
  , o_account_id             out com_api_type_pkg.t_medium_id
  , o_currency               out com_api_type_pkg.t_curr_code
  , o_status                 out com_api_type_pkg.t_dict_value
  , o_customer_id            out com_api_type_pkg.t_medium_id
  , o_split_hash             out com_api_type_pkg.t_tiny_id
  , o_inst_id                out com_api_type_pkg.t_inst_id
  , o_iss_network_id         out com_api_type_pkg.t_network_id
  , o_resp_code              out com_api_type_pkg.t_dict_value
) is
    l_account_type               com_api_type_pkg.t_dict_value;
begin
    select a.id
         , a.customer_id
         , a.split_hash
         , a.inst_id
         , i.network_id
         , a.account_type
         , a.status
         , a.currency
      into o_account_id
         , o_customer_id
         , o_split_hash
         , o_inst_id
         , o_iss_network_id
         , l_account_type
         , o_status
         , o_currency
      from acc_account a
         , ost_institution i
     where a.account_number = i_account_number
       and (i_inst_id is null or a.inst_id = i_inst_id)
       and a.inst_id = i.id;

    if acc_api_selection_pkg.check_account_restricted (
           i_oper_type      => i_oper_type
         , i_inst_id        => o_inst_id
         , i_account_type   => l_account_type
         , i_account_status => o_status
         , i_party_type     => i_party_type
         , i_msg_type       => i_msg_type
       ) = com_api_type_pkg.TRUE
    then
        o_resp_code := aup_api_const_pkg.RESP_CODE_ACCOUNT_RESTRICTED;
    else
        o_resp_code := aup_api_const_pkg.RESP_CODE_OK;
    end if;

exception
    when no_data_found then
        trc_log_pkg.error(
            i_text       => 'ACCOUNT_NOT_FOUND'
          , i_env_param1 => i_account_number
          , i_env_param2 => i_inst_id
        );
    when too_many_rows then
        trc_log_pkg.error(
            i_text       => 'ACCOUNT_NUMBER_NOT_UNIQUE'
          , i_env_param1 => i_account_number
          , i_env_param2 => i_inst_id
        );
end find_account;

procedure find_account (
    i_account_number        in     com_api_type_pkg.t_account_number
    , i_oper_type           in     com_api_type_pkg.t_dict_value
    , i_party_type          in     com_api_type_pkg.t_dict_value
    , i_msg_type            in     com_api_type_pkg.t_dict_value    default null
    , i_inst_id             in     com_api_type_pkg.t_inst_id        default null
    , o_account_id             out com_api_type_pkg.t_medium_id
    , o_customer_id            out com_api_type_pkg.t_medium_id
    , o_split_hash             out com_api_type_pkg.t_tiny_id
    , o_inst_id                out com_api_type_pkg.t_inst_id
    , o_iss_network_id         out com_api_type_pkg.t_network_id
    , o_resp_code              out com_api_type_pkg.t_dict_value
) is
    l_currency              com_api_type_pkg.t_curr_code;
    l_status                com_api_type_pkg.t_dict_value;
begin
    find_account (
        i_account_number    => i_account_number
        , i_oper_type       => i_oper_type
        , i_party_type      => i_party_type
        , i_msg_type        => i_msg_type
        , i_inst_id         => i_inst_id
        , o_account_id      => o_account_id
        , o_currency        => l_currency
        , o_status          => l_status
        , o_customer_id     => o_customer_id
        , o_split_hash      => o_split_hash
        , o_inst_id         => o_inst_id
        , o_iss_network_id  => o_iss_network_id
        , o_resp_code       => o_resp_code
    );
end;

procedure find_account (
    i_account_number        in     com_api_type_pkg.t_account_number
    , i_oper_type           in     com_api_type_pkg.t_dict_value
    , i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_party_type          in     com_api_type_pkg.t_dict_value
    , i_msg_type            in     com_api_type_pkg.t_dict_value    default null
    , o_account_id             out com_api_type_pkg.t_medium_id
    , o_resp_code              out com_api_type_pkg.t_dict_value
) is
    l_account_type          com_api_type_pkg.t_dict_value;
    l_account_status        com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text                  => 'Searching for account [#1][#2]'
        , i_env_param1          => i_account_number
        , i_env_param2          => i_inst_id
    );

    select
        a.id
        , a.account_type
        , a.status
    into
        o_account_id
        , l_account_type
        , l_account_status
    from
        acc_account a
    where
        a.account_number = i_account_number
        and a.inst_id = i_inst_id
        and rownum = 1;

    if acc_api_selection_pkg.check_account_restricted (
           i_oper_type      => i_oper_type
         , i_inst_id        => i_inst_id
         , i_account_type   => l_account_type
         , i_account_status => l_account_status
         , i_party_type     => i_party_type
         , i_msg_type       => i_msg_type
       ) = com_api_type_pkg.TRUE
    then
        o_resp_code := aup_api_const_pkg.RESP_CODE_ACCOUNT_RESTRICTED;
    else
        o_resp_code := aup_api_const_pkg.RESP_CODE_OK;
    end if;

exception
    when too_many_rows or no_data_found then
        trc_log_pkg.error (
            i_text          => 'Error when searching account [#1] in institution [#2]: [#3]'
            , i_env_param1  => i_account_number
            , i_env_param2  => i_inst_id
            , i_env_param3  => sqlerrm
        );
        o_account_id := null;
end;

procedure find_account (
    i_customer_id           in      com_api_type_pkg.t_account_number
  , i_account_type          in      com_api_type_pkg.t_dict_value
  , io_currency             in out  com_api_type_pkg.t_curr_code
  , o_account_id               out  com_api_type_pkg.t_medium_id
  , o_account_number           out  com_api_type_pkg.t_account_number
) is
    l_account_rec                   acc_api_type_pkg.t_account_rec;
begin
    l_account_rec := get_account(
                         i_customer_id   => i_customer_id
                       , i_account_type  => i_account_type
                       , i_currency      => io_currency
                       , i_mask_error    => com_api_const_pkg.TRUE
                     );
    if l_account_rec.account_id is not null then
        o_account_id     := l_account_rec.account_id;
        o_account_number := l_account_rec.account_number;
        io_currency      := l_account_rec.currency;
    end if;
end find_account;

procedure get_account_info(
    i_account_number in     com_api_type_pkg.t_account_number
  , i_currency       in     com_api_type_pkg.t_curr_code
  , i_rate_type      in     com_api_type_pkg.t_dict_value
  , o_accounts          out sys_refcursor
) is
begin
    open o_accounts for
    select a.account_number
         , a.account_type
         , a.currency
         , a.status
         , nvl(sum(case b.balance_type when acc_api_const_pkg.BALANCE_TYPE_LEDGER
                   then com_api_rate_pkg.convert_amount(
                            i_src_amount      => b.balance
                          , i_src_currency    => b.currency
                          , i_dst_currency    => a.currency
                          , i_rate_type       => t.rate_type
                          , i_inst_id         => a.inst_id
                          , i_eff_date        => get_sysdate
                          , i_mask_exception  => com_api_const_pkg.TRUE
                          , i_exception_value => null
                        )
                   else 0 end)
              , 0) ledger_balance
         , nvl(sum(case b.balance_type when acc_api_const_pkg.BALANCE_TYPE_HOLD
                   then com_api_rate_pkg.convert_amount(
                            i_src_amount      => b.balance
                          , i_src_currency    => b.currency
                          , i_dst_currency    => a.currency
                          , i_rate_type       => t.rate_type
                          , i_inst_id         => a.inst_id
                          , i_eff_date        => get_sysdate
                          , i_mask_exception  => com_api_const_pkg.TRUE
                          , i_exception_value => null
                        )
                   else 0 end)
              , 0) hold_balance
         , nvl(sum(case b.balance_type when crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                   then
                       case when a.currency = b.currency then b.balance
                       else com_api_rate_pkg.convert_amount(
                                i_src_amount      => b.balance
                              , i_src_currency    => b.currency
                              , i_dst_currency    => a.currency
                              , i_rate_type       => t.rate_type
                              , i_inst_id         => a.inst_id
                              , i_eff_date        => get_sysdate
                              , i_mask_exception  => com_api_const_pkg.TRUE
                              , i_exception_value => null
                            )
                        end
                   else 0 end)
              , 0) assigned_exceed_limit_balance
         , nvl(sum(t.aval_impact *
                       com_api_rate_pkg.convert_amount(
                           i_src_amount      => b.balance
                         , i_src_currency    => b.currency
                         , i_dst_currency    => nvl(i_currency, a.currency)
                         , i_rate_type       => i_rate_type
                         , i_inst_id         => a.inst_id
                         , i_eff_date        => get_sysdate
                         , i_mask_exception  => com_api_const_pkg.TRUE
                         , i_exception_value => null
                       ))
              ,0) available_balance
      from acc_account a
         , acc_balance b
         , acc_balance_type t
     where a.account_number =  i_account_number
       and b.account_id     = a.id
       and t.inst_id        = a.inst_id
       and t.account_type   = a.account_type
       and t.balance_type   = b.balance_type
  group by a.account_number
         , a.account_type
         , a.currency
         , a.status;
end;

function get_accounts(
    i_contract_id         in     com_api_type_pkg.t_medium_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
) return acc_api_type_pkg.t_account_tab
is
    cursor l_cur_accounts(
        p_contract_id in com_api_type_pkg.t_medium_id
      , p_inst_id     in com_api_type_pkg.t_inst_id
      , p_split_hash  in com_api_type_pkg.t_tiny_id
    ) is
    select id
         , split_hash
         , account_type
         , account_number
         , null as friendly_name
         , currency
         , inst_id
         , agent_id
         , status
         , null as status_reason
         , contract_id
         , customer_id
         , scheme_id
         , null as mod_id
      from acc_account
     where contract_id = p_contract_id
       and split_hash  = p_split_hash
       and inst_id     = p_inst_id;

    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_accounts: ';
    l_accounts_tab               acc_api_type_pkg.t_account_tab;
begin
    open l_cur_accounts(i_contract_id, i_inst_id, i_split_hash);
    fetch l_cur_accounts bulk collect into l_accounts_tab; -- limit BULK_LIMIT;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_accounts_tab.count() = #1'
      , i_env_param1 => l_accounts_tab.count()
    );

    close l_cur_accounts;

    return l_accounts_tab;
exception
    when others then
        if l_cur_accounts%isopen then
            close l_cur_accounts;
        end if;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with i_contract_id [#1], i_inst_id [#2], i_split_hash [#3]'
          , i_env_param1 => i_contract_id
          , i_env_param2 => i_inst_id
          , i_env_param3 => i_split_hash
        );
        raise;
end get_accounts;

function next_customer_account(
    i_customer_id    in     com_api_type_pkg.t_medium_id
  , i_currency       in     com_api_type_pkg.t_curr_code
  , i_account_type   in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_sign is
begin
    for rec in (
        select
            decode(count(a.id),0 ,0, to_number(max(substr(a.account_number, 11, 1))) + 1) next_val
        from
            acc_account_vw a
        where
            a.customer_id = i_customer_id
        and
            a.currency = i_currency
        and
            (a.account_type = i_account_type or i_account_type is null))
    loop
        if rec.next_val > 9 then
            com_api_error_pkg.raise_error(
                i_error      => 'MAX_NUMBER_ACCOUNT'
              , i_env_param1 => prd_api_customer_pkg.get_customer_number(i_customer_id)
              , i_env_param2 => i_currency
            );
        else
            return rec.next_val;
        end if;
    end loop;
end;

function get_account_id(
    i_account_number        in     com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_account_id is
begin
    for rec in (
        select
            a.id
        from
            acc_account a
        where
            a.account_number = i_account_number)
    loop
        return rec.id;
    end loop;
    return com_api_type_pkg.FALSE;

end get_account_id;

procedure modify_account(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_new_agent_id        in     com_api_type_pkg.t_agent_id
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_account: ';
    l_old_agent_id               com_api_type_pkg.t_agent_id;
    l_inst_id                    com_api_type_pkg.t_inst_id;
begin
    begin
        select a.agent_id
             , a.inst_id
          into l_old_agent_id
             , l_inst_id
          from acc_account a
         where a.id         = i_account_id
           and a.split_hash = i_split_hash;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'ACCOUNT_NOT_FOUND'
              , i_env_param1        => i_account_id
            );
    end;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    if l_old_agent_id is null or l_old_agent_id != i_new_agent_id then
        update acc_account a
           set a.agent_id   = i_new_agent_id
         where a.id         = i_account_id
           and a.split_hash = i_split_hash;
    end if;

    clear_cache();

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_account_id [#1], i_split_hash [#2], i_new_agent_id [#3], '
                                   || 'l_old_agent_id [#4], sql%rowcount [#5]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_split_hash
      , i_env_param3 => i_new_agent_id
      , i_env_param4 => l_old_agent_id
      , i_env_param5 => sql%rowcount
    );
end modify_account;

/*
 * Function searches and returns an account record by <i_account_id> if it isn't NULL
 * (<i_account_number> and <i_inst_id> are ignored in this case),
 * otherwise it uses <i_account_number> with <i_inst_id> to locate an account.
 * If <i_inst_id> is NULL then first account will be returned.
 * Exceptions ACCOUNT_NOT_FOUND and ACCOUNT_NUMBER_NOT_UNIQUE are raised when searching is failed and <i_mask_error> is FALSE.
 */
function get_account(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_account_number      in     com_api_type_pkg.t_account_number default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id        default null
  , i_mask_error          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return acc_api_type_pkg.t_account_rec
is
    LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_account: ';
    l_account_id          com_api_type_pkg.t_account_id;
    l_account_rec         acc_api_type_pkg.t_account_rec;
begin
    begin
        if i_account_id is not null then
            if i_account_number is not null then
                trc_log_pkg.debug(LOG_PREFIX || 'i_account_number will be ignored because i_account_id is defined');
            end if;
            l_account_id := i_account_id;

        elsif i_account_number is not null then
            begin
                select a.id
                  into l_account_id
                  from acc_account a
                 where a.account_number = i_account_number
                   and (i_inst_id is null or a.inst_id = i_inst_id);
            exception
                when no_data_found then
                    if i_mask_error = com_api_const_pkg.TRUE then
                        trc_log_pkg.debug(
                            i_text       => 'Account [#1] does not exist in institution [#2].'
                          , i_env_param1 => i_account_number
                          , i_env_param2 => i_inst_id
                        );
                        raise;
                    else
                        com_api_error_pkg.raise_error(
                            i_error      => 'ACCOUNT_NOT_FOUND'
                          , i_env_param1 => i_account_number
                          , i_env_param2 => i_inst_id
                        );
                    end if;
                when too_many_rows then
                    if i_mask_error = com_api_const_pkg.TRUE then
                        trc_log_pkg.debug(
                            i_text       => 'Account [#1] is not unique in institution [#2].'
                          , i_env_param1 => i_account_number
                          , i_env_param2 => i_inst_id
                        );
                        raise;
                    else
                        com_api_error_pkg.raise_error(
                            i_error      => 'ACCOUNT_NUMBER_NOT_UNIQUE'
                          , i_env_param1 => i_account_number
                          , i_env_param2 => i_inst_id
                        );
                    end if;
            end;
        end if;
        -- We always unmask an error, it allows to make a DEBUG logging record on
        -- handling <others> exception in any case, <i_mask_error> is checked later
        get_account_info(
            i_account_id  => l_account_id
          , o_account_rec => l_account_rec
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    exception
        when others then
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'i_account_id [' || i_account_id || '], i_account_number [' || i_account_number
                                     || '], i_inst_id [' || i_inst_id || '], i_mask_error [' || i_mask_error
                                     || '], l_account_id [' || l_account_id || ']'
            );
            -- None application exceptions are always raised, with any value of <i_mask_error>
            if i_mask_error = com_api_const_pkg.FALSE
               or
               com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
            then
                raise;
            end if;
    end;

    return l_account_rec;
end get_account;

function get_account(
    i_customer_id         in     com_api_type_pkg.t_account_number
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code      default null
  , i_mask_error          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return acc_api_type_pkg.t_account_rec
is
    LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_account: ';
    l_account_rec         acc_api_type_pkg.t_account_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_customer_id [#1], i_account_type [#2], i_currency [#3]'
      , i_env_param1 => i_customer_id
      , i_env_param2 => i_account_type
      , i_env_param3 => i_currency
    );
    begin
        select a.id
             , a.split_hash
             , a.account_type
             , a.account_number
             , null as friendly_name
             , a.currency
             , a.inst_id
             , a.agent_id
             , a.status
             , null as status_reason
             , a.contract_id
             , a.customer_id
             , a.scheme_id
             , null as mod_id
          into l_account_rec
          from acc_account a
         where a.customer_id  = i_customer_id
           and a.account_type = i_account_type
           and (i_currency is null or a.currency = i_currency)
           and a.status      != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
           and rownum         = 1;
    exception
        when no_data_found then
            if i_mask_error = com_api_const_pkg.FALSE then
                trc_log_pkg.error(
                    i_text        => 'CUSTOMER_ACCOUNT_NOT_FOUND'
                  , i_env_param1  => i_customer_id
                  , i_env_param2  => i_account_type
                  , i_env_param3  => i_currency
                );
            else
                com_api_error_pkg.raise_error(
                    i_error       => 'CUSTOMER_ACCOUNT_NOT_FOUND'
                  , i_env_param1  => i_customer_id
                  , i_env_param2  => i_account_type
                  , i_env_param3  => i_currency
                );
            end if;
    end;
    return l_account_rec;
end get_account;

function get_account(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code      default null
  , i_mask_error          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return acc_api_type_pkg.t_account_rec
is
    LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_account: ';
    l_account_rec         acc_api_type_pkg.t_account_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_entity_type [#1], i_object_id [' || i_object_id
                                   || '], i_account_type [#2], i_currency [#3]'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_account_type
      , i_env_param3 => i_currency
    );
    begin
        select a.id
             , a.split_hash
             , a.account_type
             , a.account_number
             , null as friendly_name
             , a.currency
             , a.inst_id
             , a.agent_id
             , a.status
             , null as status_reason
             , a.contract_id
             , a.customer_id
             , a.scheme_id
             , null as mod_id
          into l_account_rec
          from acc_account a
          join acc_account_object ao
              on ao.account_id = a.id
         where ao.entity_type = i_entity_type
           and ao.object_id   = i_object_id
           and a.account_type = i_account_type
           and a.currency     = nvl(i_currency, a.currency)
           and a.status      != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED;
    exception
        when no_data_found then
            if i_mask_error = com_api_const_pkg.TRUE then
                trc_log_pkg.warn(
                    i_text       => 'ENTITY_ACCOUNT_NOT_FOUND'
                  , i_env_param1 => i_entity_type
                  , i_env_param2 => i_object_id
                  , i_env_param3 => i_account_type
                  , i_env_param4 => i_currency
                );
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'ENTITY_ACCOUNT_NOT_FOUND'
                  , i_env_param1 => i_entity_type
                  , i_env_param2 => i_object_id
                  , i_env_param3 => i_account_type
                  , i_env_param4 => i_currency
                );
            end if;
    end;
    return l_account_rec;
end get_account;

procedure add_unlink_account(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_usage_order         in     com_api_type_pkg.t_tiny_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_is_pos_default      in     com_api_type_pkg.t_boolean
  , i_is_atm_default      in     com_api_type_pkg.t_boolean
  , i_is_atm_currency     in     com_api_type_pkg.t_boolean
  , i_is_pos_currency     in     com_api_type_pkg.t_boolean
  , i_account_seq_number  in     acc_api_type_pkg.t_account_seq_number
  , o_unlink_account_id      out com_api_type_pkg.t_long_id
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_unlink_account: ';
    l_sysdate                    date;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_account_id [#1], i_entity_type [#2], i_object_id [#3], i_split_hash [#4]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_entity_type
      , i_env_param3 => i_object_id
      , i_env_param4 => i_split_hash
    );

    l_sysdate := get_sysdate;

    insert into acc_unlink_account(
        id
      , object_id
      , account_id
      , entity_type
      , usage_order
      , split_hash
      , is_pos_default
      , is_atm_default
      , is_atm_currency
      , is_pos_currency
      , unlink_date
      , account_seq_number
    ) values (
        acc_unlink_account_seq.nextval
      , i_object_id
      , i_account_id
      , i_entity_type
      , i_usage_order
      , i_split_hash
      , i_is_pos_default
      , i_is_atm_default
      , i_is_atm_currency
      , i_is_pos_currency
      , l_sysdate
      , i_account_seq_number
    )
    returning id into o_unlink_account_id;

    evt_api_event_pkg.register_event (
        i_event_type          => iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD
      , i_eff_date            => l_sysdate
      , i_entity_type         => i_entity_type
      , i_object_id           => i_object_id
      , i_inst_id             => i_inst_id
      , i_split_hash          => i_split_hash
    );

    trc_log_pkg.debug('Unlink account registered; o_unlink_account_id: ' || o_unlink_account_id);

end add_unlink_account;

procedure add_account_link(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_description         in     com_api_type_pkg.t_name
  , i_is_active           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , o_account_link_id        out com_api_type_pkg.t_medium_id
) is
begin
    insert into acc_account_link(
        id
      , account_id
      , entity_type
      , object_id
      , description
      , is_active
    ) values (
        acc_account_link_seq.nextval
      , i_account_id
      , i_entity_type
      , i_object_id
      , i_description
      , i_is_active
    )
    returning id into o_account_link_id;

    trc_log_pkg.debug('Link account registered. o_account_link_id: ' || o_account_link_id);
exception
    when dup_val_on_index then
        trc_log_pkg.debug('Account was already linked');
end add_account_link;

function get_account_reg_date(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
) return date
is
    l_reg_date                   date;
begin
    select min(open_date)
      into l_reg_date
      from acc_balance
     where account_id = i_account_id
       and split_hash = i_split_hash;

    return l_reg_date;
end get_account_reg_date;

function get_account_number(
    i_account_id          in     com_api_type_pkg.t_account_id
  , i_mask_error          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_account_number
is
begin
    return get_account(
               i_account_id => i_account_id
             , i_mask_error => i_mask_error
           ).account_number;
end get_account_number;

function check_active_account(
    i_card_id             in     com_api_type_pkg.t_medium_id
  , i_curr_code           in     com_api_type_pkg.t_curr_code           default null
) return com_api_type_pkg.t_boolean
is
    l_result                     com_api_type_pkg.t_boolean;
begin
    select decode(count(1), 0, 0, 1)
      into l_result
      from acc_account_object o
         , acc_account a
     where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
       and o.object_id   = i_card_id
       and o.account_id  = a.id
       and a.status      = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
       and a.currency    = nvl(i_curr_code, a.currency);

    return l_result;
end;

procedure reconnect_account(
    i_account_id          in     com_api_type_pkg.t_medium_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_contract_id         in     com_api_type_pkg.t_long_id
) as
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.reconnect_account: ';
    l_split_hash                 com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_account_id [#1], i_customer_id [#2], i_contract_id [#3]'
      , i_env_param1 => i_account_id
      , i_env_param2 => i_customer_id
      , i_env_param3 => i_contract_id
    );

    begin
        select split_hash
          into l_split_hash
          from prd_customer
         where id = i_customer_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error => 'CUSTOMER_NOT_FOUND'
            );
    end;

    update acc_account_vw a
       set a.customer_id = i_customer_id
         , a.contract_id = i_contract_id
         , a.split_hash  = l_split_hash
     where a.id = i_account_id;

    clear_cache();

    update acc_balance_vw b
       set b.split_hash = l_split_hash
     where b.account_id = i_account_id;

    update acc_account_object_vw ao
       set ao.split_hash = l_split_hash
     where ao.account_id = i_account_id;

    evt_api_event_pkg.change_split_hash(
        i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
      , i_split_hash  => l_split_hash
    );

    prd_api_service_pkg.update_service_object(
        i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
      , i_split_hash  => l_split_hash
      , i_contract_id => i_contract_id
    );
end reconnect_account;

function get_default_accounts(
    i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_use_atm_default     in     com_api_type_pkg.t_boolean
  , i_use_pos_default     in     com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_text
is
    l_account_number_tab         com_api_type_pkg.t_name_tab;
    l_currency_tab               com_api_type_pkg.t_name_tab;
    l_result                     com_api_type_pkg.t_text;
begin
    select a.account_number
         , a.currency
      bulk collect into
           l_account_number_tab
         , l_currency_tab
      from acc_account_object ao
         , acc_account a
     where ao.object_id       = i_object_id
       and ao.entity_type     = i_entity_type
       and a.id               = ao.account_id
       and a.status          != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
       and (
               (
                      (ao.is_atm_default  = com_api_type_pkg.TRUE and i_use_atm_default = com_api_type_pkg.TRUE)
                   or (ao.is_atm_currency = com_api_type_pkg.TRUE and i_use_atm_default = com_api_type_pkg.TRUE)
               )
               or
               (
                      (ao.is_pos_default  = com_api_type_pkg.TRUE and i_use_pos_default = com_api_type_pkg.TRUE)
                   or (ao.is_pos_currency = com_api_type_pkg.TRUE and i_use_pos_default = com_api_type_pkg.TRUE)
               )
           );

    if l_account_number_tab.count > 0 then
        -- It is instead of function "listagg" for decrease CPU load.
        for i in 1 .. l_account_number_tab.count loop
            if l_result is not null then
                l_result := l_result || ', ';
            end if;
            l_result := l_result || l_account_number_tab(i) || '(' || l_currency_tab(i) || ')';
        end loop;
    end if;

    return l_result;
end get_default_accounts;

procedure set_object_default_account(
    i_object_id           in     com_api_type_pkg.t_long_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_account_id          in     com_api_type_pkg.t_account_id
  , i_is_pos_default      in     com_api_type_pkg.t_boolean
  , i_is_atm_default      in     com_api_type_pkg.t_boolean
) is
    l_account_tab                acc_api_type_pkg.t_account_tab;
begin
    acc_api_selection_pkg.get_accounts(
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , o_accounts      => l_account_tab
    );

    for i in 1 .. l_account_tab.count loop
        update acc_account_object
           set is_pos_default = case when l_account_tab(i).account_id <> i_account_id then com_api_const_pkg.FALSE else nvl(i_is_pos_default, 0) end
             , is_atm_default = case when l_account_tab(i).account_id <> i_account_id then com_api_const_pkg.FALSE else nvl(i_is_atm_default, 0) end
         where account_id = l_account_tab(i).account_id;
    end loop;
end set_object_default_account;

end acc_api_account_pkg;
/
