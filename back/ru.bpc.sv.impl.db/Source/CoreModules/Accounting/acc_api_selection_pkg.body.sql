create or replace package body acc_api_selection_pkg is

procedure get_account(
    i_selection_id              in com_api_type_pkg.t_tiny_id
  , i_entity_type               in com_api_type_pkg.t_dict_value
  , i_object_id                 in com_api_type_pkg.t_long_id
  , i_account_number            in com_api_type_pkg.t_account_number
  , i_party_type                in com_api_type_pkg.t_dict_value
  , i_oper_type                 in com_api_type_pkg.t_dict_value
  , i_msg_type                  in com_api_type_pkg.t_dict_value
  , i_iso_type                  in com_api_type_pkg.t_dict_value
  , i_oper_currency             in com_api_type_pkg.t_curr_code
  , i_sttl_currency             in com_api_type_pkg.t_curr_code
  , i_bin_currency              in com_api_type_pkg.t_curr_code
  , i_show_friendly_numbers     in com_api_type_pkg.t_boolean -- force to show customized "frendly" accounts' numbers
  , o_accounts                 out acc_api_type_pkg.t_account_tab
  , i_is_forced_processing      in com_api_type_pkg.t_boolean       default null
  , i_terminal_type             in com_api_type_pkg.t_dict_value    default null
  , i_oper_amount               in com_api_type_pkg.t_long_id        default null
  , i_rate_type                 in com_api_type_pkg.t_dict_value     default null
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_account(1): ';
    CRLF                        constant varchar2(100) := chr(13) || chr(10);
    INDENT                      constant varchar2(100) := CRLF || '    ';
    COMMA                       constant varchar2(100) := CRLF || '  , ';
    -- Defining templates of select queries with placeholders
    ACC_FRIENDLY_PLACEHOLDER    constant varchar2(100) := '##FRIENDLY_ACCOUNT_NUMBER##';
    ACC_FRIENDLY_NAME_FIELD     constant varchar2(500) :=
       'cst_api_name_pkg.get_friendly_account_number(
            i_account_id     => a.id
          , i_account_number => a.account_number
          , i_inst_id        => a.inst_id
          , i_currency       => a.currency
          , i_account_type   => a.account_type
        )';
    ACC_PRIORITY_PLACEHOLDER    constant varchar2(100) := '##ACCOUNT_PRIORITY##';
    ISO_TYPE_PLACEHOLDER        constant varchar2(100) := '##ISO_ACCOUNT_TYPE##';
    MODIFIER_PLACEHOLDER        constant varchar2(100) := '##MODIFIER##';

    WHERE_PLACEHOLDER           constant varchar2(100) := '##WHERE##';
    ORDER_PLACEHOLDER           constant varchar2(100) := '##ORDER_BY##';

    PARAMS_STMT                 constant com_api_type_pkg.t_text := '
  , (select :account_number p_account_number' ||
         ', :iso_type p_iso_type' ||
         ', :party_type p_party_type' ||
         ', :oper_type p_oper_type' ||
         ', :msg_type p_msg_type' ||
         ', :terminal_type p_terminal_type' ||
         ', :oper_currency p_oper_currency' ||
         ', :sttl_currency p_sttl_currency' ||
         ', :bin_currency p_bin_currency ' ||
         ', :entity_type p_entity_type' ||
         ', :object_id p_object_id' ||
    ' from dual'||
   ') x ';

    SELECT_STMT                 constant com_api_type_pkg.t_text := '
select
    a.id
  , a.split_hash
  , a.account_type
  , a.account_number
  , ' || ACC_FRIENDLY_PLACEHOLDER || ' as friendly_name
  , a.currency
  , a.inst_id
  , a.agent_id
  , a.status
  , null as status_reason
  , a.contract_id
  , a.customer_id
  , a.scheme_id
  , ' || MODIFIER_PLACEHOLDER || ' as mod_id'
    ;

    CURSOR_STMT_ANY             constant com_api_type_pkg.t_text :=
SELECT_STMT || '
from
    acc_account a
  , acc_account_object o'
    || ISO_TYPE_PLACEHOLDER
    || PARAMS_STMT
    || ACC_PRIORITY_PLACEHOLDER || '
where
    o.entity_type = x.p_entity_type
    and o.object_id = x.p_object_id
    and a.id = o.account_id '
    || WHERE_PLACEHOLDER || '
order by '
    || ORDER_PLACEHOLDER;

    CURSOR_STMT_CST             constant com_api_type_pkg.t_text :=
SELECT_STMT || '
from
    acc_account a'
    || ISO_TYPE_PLACEHOLDER
    || PARAMS_STMT
    || ACC_PRIORITY_PLACEHOLDER || '
where
    a.customer_id = x.p_object_id '
    || WHERE_PLACEHOLDER || '
order by '
    || ORDER_PLACEHOLDER;

    CURSOR_STMT_CNT             constant com_api_type_pkg.t_text :=
SELECT_STMT || '
from
    acc_account a'
    || ISO_TYPE_PLACEHOLDER
    || PARAMS_STMT
    || ACC_PRIORITY_PLACEHOLDER || '
where
    a.contract_id = x.p_object_id '
    || WHERE_PLACEHOLDER || '
order by '
    || ORDER_PLACEHOLDER;

    cursor l_steps_cur is
        select
            id
            , selection_id
            , exec_order
            , step
        from
            acc_selection_step_vw
        where
            selection_id = i_selection_id
        order by
            exec_order;

    l_accounts_cur              sys_refcursor;

    l_step_rec                  acc_api_type_pkg.t_selection_step_rec;
    l_steps                     acc_api_type_pkg.t_selection_step_tab;

    l_where_stmt                com_api_type_pkg.t_text;
    l_order_stmt                com_api_type_pkg.t_text;
    l_cursor_stmt               com_api_type_pkg.t_text;

    l_check_balance             com_api_type_pkg.t_boolean;
    l_accounts                  acc_api_type_pkg.t_account_tab;

    function check_account_balance(
        i_accounts      in acc_api_type_pkg.t_account_tab
    ) return acc_api_type_pkg.t_account_tab
    is
        l_accounts      acc_api_type_pkg.t_account_tab;
        l_iter          pls_integer;
        l_bal_amt       com_api_type_pkg.t_money;
        l_oper_amount   com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug(
            i_text => 'check_account_balance: begin [' || i_accounts.count || ']'
        );

        l_iter := i_accounts.first;
        while l_iter <= i_accounts.last loop
            l_bal_amt := acc_api_balance_pkg.get_aval_balance_amount_only(
                i_account_id => i_accounts(l_iter).account_id
            );
            trc_log_pkg.debug(
                i_text => 'check_account_balance: balanc(' || i_accounts(l_iter).account_id || ') = ' || l_bal_amt
                       || ' i_accounts.currency=' || i_accounts(l_iter).currency);

            if i_oper_currency != i_accounts(l_iter).currency then
                l_oper_amount :=
                com_api_rate_pkg.convert_amount(
                         i_src_amount      => i_oper_amount
                       , i_src_currency    => i_oper_currency
                       , i_dst_currency    => i_accounts(l_iter).currency
                       , i_rate_type       => i_rate_type
                       , i_inst_id         => i_accounts(l_iter).inst_id
                       , i_eff_date        => get_sysdate
                );
            end if;

            if l_bal_amt >= l_oper_amount then
                l_accounts(l_accounts.count + 1) := i_accounts(l_iter);
            end if;
            l_iter := i_accounts.next(l_iter);

        end loop;

        trc_log_pkg.debug(
            i_text => 'check_account_balance: end [' || l_accounts.count || ']'
        );

        return l_accounts;
    end check_account_balance;

begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Going to find account for entity [#1][#2] using algoritm [#3], oper_amount [#4], oper_currency [#5], rate_type [#6]'
      , i_env_param1  => i_entity_type
      , i_env_param2  => i_object_id
      , i_env_param3  => i_selection_id
      , i_env_param4  => i_oper_amount
      , i_env_param5  => i_oper_currency
      , i_env_param6  => i_rate_type
    );

    -- fetch check balance flag
    for tab in (select check_aval_balance
                  from acc_selection
                 where id = i_selection_id)
    loop
        l_check_balance := tab.check_aval_balance;
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'l_check_balance [#1]'
          , i_env_param1 => l_check_balance
        );
    end loop;

    -- Fetch algorithm steps
    l_steps.delete;

    if i_selection_id is null then
        if i_oper_type is not null then
            l_step_rec.step := acc_api_const_pkg.SELECTION_STEP_PRIORITY;
            l_steps(l_steps.count+1) := l_step_rec;
        end if;
        if i_iso_type is not null then
            l_step_rec.step := acc_api_const_pkg.SELECTION_STEP_ISO_TYPE;
            l_steps(l_steps.count+1) := l_step_rec;
        end if;
        l_step_rec.step := acc_api_const_pkg.SELECTION_STEP_USAGE_ORDER;
        l_steps(l_steps.count+1) := l_step_rec;
    else
        open  l_steps_cur;
        fetch l_steps_cur bulk collect into l_steps;
        close l_steps_cur;

        if not l_steps.count > 0 then
            com_api_error_pkg.raise_error (
                i_error       => 'ACC_SELECTION_ALGORITHM_NOT_DEFINED'
              , i_env_param1  => i_selection_id
            );
        end if;
    end if;

    -- Make primary statement
    l_cursor_stmt :=
        case i_entity_type
            when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then CURSOR_STMT_CST
            when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then CURSOR_STMT_CNT
                                                        else CURSOR_STMT_ANY
        end;

    -- Determine if friendly account's numbers are required
    l_cursor_stmt := replace(l_cursor_stmt,
                             ACC_FRIENDLY_PLACEHOLDER,
                             case
                                 when i_show_friendly_numbers = com_api_type_pkg.TRUE
                                 then ACC_FRIENDLY_NAME_FIELD
                                 else 'null'
                             end);

    trc_log_pkg.debug('Count of selection steps = ' || l_steps.count);

    -- Make where and order by clauses
    for i in 1 .. l_steps.count loop

        case l_steps(i).step
        when acc_api_const_pkg.SELECTION_STEP_ACCOUNT then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Account number will be prioritized [#1]'
              , i_env_param1  => i_account_number
            );
            if i_account_number is not null then
                l_order_stmt := l_order_stmt || COMMA
                             || 'decode(a.account_number, x.p_account_number, 0, 1)';
            end if;

        when acc_api_const_pkg.SELECTION_STEP_EXACT_ACCOUNT then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Exact account will be searched [#1]'
              , i_env_param1  => i_account_number
            );
            l_where_stmt := l_where_stmt || INDENT || 'and a.account_number = x.p_account_number';
            l_order_stmt := l_order_stmt || COMMA  || 'decode(a.account_number, x.p_account_number, 0, 1)';

        when acc_api_const_pkg.SELECTION_STEP_ISO_TYPE then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] ISO type will be prioritized [#1]'
              , i_env_param1  => i_iso_type
            );

            l_cursor_stmt := replace(l_cursor_stmt, ISO_TYPE_PLACEHOLDER, COMMA || 'acc_iso_account_type t');

            l_where_stmt  := l_where_stmt
                          || INDENT || 'and t.account_type = a.account_type'
                          || INDENT || 'and t.inst_id = a.inst_id'
                          || INDENT || 'and x.p_iso_type like t.iso_type';

            l_order_stmt  := l_order_stmt || COMMA || 't.priority';

        when acc_api_const_pkg.SELECTION_STEP_USAGE_ORDER then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Usage order will be prioritized'
            );
            if i_entity_type in (prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                               , prd_api_const_pkg.ENTITY_TYPE_CONTRACT)
            then
                l_order_stmt := l_order_stmt || COMMA || 'a.id';
            else
                l_order_stmt := l_order_stmt || COMMA || 'o.usage_order';
            end if;

        when acc_api_const_pkg.SELECTION_STEP_ACC_SEQ_NUMBER then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Account sequence number will be prioritized'
            );
            if i_entity_type in (prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                               , prd_api_const_pkg.ENTITY_TYPE_CONTRACT)
            then
                l_order_stmt := l_order_stmt || COMMA || 'a.id';
            else
                l_order_stmt := l_order_stmt || COMMA || 'o.account_seq_number';
            end if;

        when acc_api_const_pkg.SELECTION_STEP_PRIORITY then
            trc_log_pkg.debug(
                i_text       => '[' || i || '] Selection priority will be forced, operation type [#1] will be prioritized'
              , i_env_param1 => i_oper_type
            );

            l_cursor_stmt := replace( --select
                                 l_cursor_stmt
                               , MODIFIER_PLACEHOLDER
                               , 'p.mod_id'
                             );
            l_cursor_stmt := replace( --from
                                 l_cursor_stmt
                               , ACC_PRIORITY_PLACEHOLDER
                               , COMMA || 'acc_selection_priority p' ||
                                 COMMA || 'rul_mod m'
                             );
            l_where_stmt  := l_where_stmt
                          || INDENT || 'and a.inst_id like p.inst_id'
                          || INDENT || 'and a.account_type like p.account_type'
                          || INDENT || 'and (a.status like p.account_status or '
                                            || nvl(i_is_forced_processing, com_api_const_pkg.FALSE)
                                            || ' = ' || com_api_const_pkg.TRUE
                                    || ')'
                          || INDENT || 'and x.p_oper_type like p.oper_type'
                          || INDENT || 'and nvl(x.p_party_type, ''%'') like p.party_type'
                          || INDENT || 'and nvl(x.p_msg_type, ''%'') like p.msg_type'
                          || INDENT || 'and a.currency like nvl(p.account_currency, ''%'')'
                          || INDENT || 'and p.mod_id = m.id(+)';
            l_order_stmt  := l_order_stmt
                          || case
                                 when nvl(i_is_forced_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                                 then COMMA ||
                                      'decode(a.status, ''' || acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE || ''', 0, '''
                                                            || acc_api_const_pkg.ACCOUNT_STATUS_CLOSED || ''', 2, 1)'
                             end
                          || COMMA || 'm.priority nulls last' -- records with non-empty modifiers should be prioritized
                          || COMMA || 'p.priority';           -- secondly, use priority from ACC_SELECTION_PRIORITY

        when acc_api_const_pkg.SELECTION_STEP_OPR_CURRENCY then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Operation currency will be prioritized [#1]'
              , i_env_param1  => i_oper_currency
            );
            l_order_stmt := l_order_stmt || COMMA || 'decode(a.currency, x.p_oper_currency, 0, 1)';

        when acc_api_const_pkg.SELECTION_STEP_STTL_CURRENCY then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Settlement currency will be prioritized [#1]'
              , i_env_param1  => i_sttl_currency
            );
            l_order_stmt := l_order_stmt || COMMA || 'decode(a.currency, x.p_sttl_currency, 0, 1)';

        when acc_api_const_pkg.SELECTION_STEP_BIN_CURRENCY then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] BIN currency will be prioritized [#1]'
              , i_env_param1  => i_bin_currency
            );
            l_order_stmt := l_order_stmt || COMMA || 'decode(a.currency, x.p_bin_currency, 0, 1)';

        when acc_api_const_pkg.SELECTION_STEP_EXACT_OPR_CURR then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Operation currency will be restriction [#1]'
              , i_env_param1  => i_oper_currency
            );
            l_where_stmt := l_where_stmt || INDENT || 'and a.currency = x.p_oper_currency';
            l_order_stmt := l_order_stmt || COMMA  || 'decode(a.currency, x.p_oper_currency, 0, 1)';

        when acc_api_const_pkg.SELECTION_STEP_TERMINAL_TYPE then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Terminal type will be prioritized [#1]'
              , i_env_param1  => i_oper_currency
            );
            l_order_stmt := l_order_stmt || COMMA
                || 'decode(x.p_terminal_type'
                ||     ', ''' || acq_api_const_pkg.TERMINAL_TYPE_POS || ''''
                ||         ', decode(o.is_pos_default, 1, 0, 1)'
                ||     ', ''' || acq_api_const_pkg.TERMINAL_TYPE_ATM || ''''
                ||         ', decode(o.is_atm_default, 1, 0, 1)'
                ||     ', 1'
                || ')';

        when acc_api_const_pkg.SELECTION_STEP_DEF_CURRENCY then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Default POS/ATM currency will be prioritized [#1], type [#2]'
              , i_env_param1  => i_oper_currency
              , i_env_param2  => i_terminal_type
            );
            l_where_stmt := l_where_stmt || INDENT || 'and a.currency = x.p_oper_currency';
            l_order_stmt := l_order_stmt || COMMA
                || 'decode('
                ||     'a.currency'
                ||   ', x.p_oper_currency'
                ||   ', decode('
                ||          'o.is_pos_currency'
                ||        ', 1'
                ||        ', decode(x.p_terminal_type, ''' || acq_api_const_pkg.TERMINAL_TYPE_POS || ''', 0, 1)'
                ||        ', decode('
                ||              'o.is_atm_currency'
                ||            ', 1'
                ||            ', decode(x.p_terminal_type, ''' || acq_api_const_pkg.TERMINAL_TYPE_ATM || ''', 0, 1)'
                ||            ', 1'
                ||          ')'
                ||     ')'
                ||   ', 1'
                || ')';
                
        when acc_api_const_pkg.SELECTION_STEP_DEF_ACCOUNT then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Default account selection if ATM default and POS default equal true will be prioritized'
            );
            if l_cursor_stmt like '%acc_account_object o%' then
                l_order_stmt := l_order_stmt || COMMA
                    || 'decode('
                    ||     'o.is_atm_default + o.is_pos_default'
                    ||   ', 2'
                    ||   ', 0'
                    ||   ', 1'
                    || ')';
            else
                 l_order_stmt := l_order_stmt || COMMA
                    || 'case'
                    ||     ' when exists(select 1 from acc_account_object o where o.account_id = a.id and is_atm_default = 1 and is_pos_default = 1)'
                    ||         ' then 0'
                    ||     ' else 1'
                    || ' end';
            end if;
            
        when acc_api_const_pkg.SELECTION_STEP_ATM_DEFAULT then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Default account selection if ATM default equal true will be prioritized'
            );
            if l_cursor_stmt like '%acc_account_object o%' then
                l_order_stmt := l_order_stmt || COMMA
                    || 'decode('
                    ||     'o.is_atm_default'
                    ||   ', 1'
                    ||   ', 0'
                    ||   ', 1'
                    || ')';
            else
                 l_order_stmt := l_order_stmt || COMMA
                    || 'case'
                    ||     ' when exists(select 1 from acc_account_object o where o.account_id = a.id and is_atm_default = 1)'
                    ||         ' then 0'
                    ||     ' else 1'
                    || ' end';
            end if;
            
        when acc_api_const_pkg.SELECTION_STEP_POS_DEFAULT then
            trc_log_pkg.debug(
                i_text        => '[' || i || '] Default account selection if POS default equal true will be prioritized'
            );
            if l_cursor_stmt like '%acc_account_object o%' then
                l_order_stmt := l_order_stmt || COMMA
                    || 'decode('
                    ||     'o.is_pos_default'
                    ||   ', 1'
                    ||   ', 0'
                    ||   ', 1'
                    || ')';
            else
                 l_order_stmt := l_order_stmt || COMMA
                    || 'case'
                    ||     ' when exists(select 1 from acc_account_object o where o.account_id = a.id and is_pos_default = 1)'
                    ||         ' then 0'
                    ||     ' else 1'
                    || ' end';
            end if;
            
        else
            com_api_error_pkg.raise_error(
                i_error       => 'ILLEGAL_ACCOUNT_ALGORITHM_STEP'
              , i_env_param1  => l_steps(i).step
            );
        end case;

    end loop;

    -- Cut first "," delimiter
    l_order_stmt := ltrim(l_order_stmt, COMMA);
    l_order_stmt := INDENT || nvl(l_order_stmt, 'a.id');

    l_cursor_stmt := replace(l_cursor_stmt, ACC_PRIORITY_PLACEHOLDER, '');
    l_cursor_stmt := replace(l_cursor_stmt, ISO_TYPE_PLACEHOLDER, '');
    l_cursor_stmt := replace(l_cursor_stmt, WHERE_PLACEHOLDER, l_where_stmt);
    l_cursor_stmt := replace(l_cursor_stmt, ORDER_PLACEHOLDER, l_order_stmt);
    -- If algorithm SELECTION_STEP_PRIORITY isn't used
    l_cursor_stmt := replace(l_cursor_stmt, MODIFIER_PLACEHOLDER, 'null');

    trc_log_pkg.debug(
        i_text  => l_cursor_stmt
    );

    open l_accounts_cur for l_cursor_stmt
    using
        i_account_number
      , i_iso_type
      , i_party_type
      , i_oper_type
      , i_msg_type
      , i_terminal_type
      , i_oper_currency
      , i_sttl_currency
      , i_bin_currency
      , i_entity_type
      , i_object_id;

    fetch l_accounts_cur bulk collect into l_accounts;
    close l_accounts_cur;

    if l_check_balance = com_api_const_pkg.TRUE then
        o_accounts := check_account_balance(
            i_accounts => l_accounts
        );
    else
        o_accounts := l_accounts;
    end if;

    if not o_accounts.count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'ACCOUNT_BY_ALGORITHM_NOT_FOUND'
          , i_env_param1 => i_account_number
        );
    end if;

    trc_log_pkg.debug(
        i_text       => 'get_account: count of accunts [#1]'
      , i_env_param1 => o_accounts.count
    );

exception
    when others then
        if l_accounts_cur%isopen then
            close l_accounts_cur;
        end if;
        if l_steps_cur%isopen then
            close l_steps_cur;
        end if;

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            trc_log_pkg.debug(LOG_PREFIX || 'FAILED');
            trc_log_pkg.debug('l_cursor_stmt:' || CRLF || l_cursor_stmt);
            trc_log_pkg.debug('l_where_stmt:'  || CRLF || l_where_stmt);
            trc_log_pkg.debug('l_order_stmt:'  || CRLF || l_order_stmt);

            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end get_account;

/*
 * Function returns an account that is selected in according to checking modifiers from table
 * ACC_SELECTION_PRIORITY (if applicable, for algorithm ACC_SELECTION_PRIORITY only);
 * if no modifiers are configurated for the table or all of them are false then an account is choosen
 * by priority field. If more than one modifier are configurated for the selection then they are
 * checked in according to field RUL_MOD.priority.
 * Note: sorting by modifiers (with their priorities) and field priority is executed on fetching the
 * cursor in function get_account().
 */
function select_account(
    i_accounts                  in acc_api_type_pkg.t_account_tab
  , i_params                    in com_api_type_pkg.t_param_tab
) return acc_api_type_pkg.t_account_rec
is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.select_account';
    l_is_found                     com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_index                        binary_integer;
    l_params                       com_api_type_pkg.t_param_tab;
begin
    l_params := i_params;

    acc_cst_selection_pkg.modify_params(io_params => l_params);

    if i_params.count() != l_params.count() then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': parameters were modified by acc_cst_selection_pkg.modify_params():'
                                       ||  ' source i_params.count() = #1, modified l_params.count() = 2'
          , i_env_param1 => i_params.count()
          , i_env_param2 => l_params.count()
        );
    end if;

    -- Look through incoming array of accounts (it is sorted!) until an account with successful
    -- modifier check is met, or until an account without a modifier is met.
    -- If the array contains only accounts with modifiers and all of them is failed then no one
    -- account is returned.
    l_index := i_accounts.first();
    while l_is_found = com_api_const_pkg.FALSE and l_index is not null
    loop
        l_is_found := case
                          when i_accounts(l_index).mod_id is null
                          then com_api_const_pkg.TRUE
                          else rul_api_mod_pkg.check_condition(
                                   i_mod_id  => i_accounts(l_index).mod_id
                                 , i_params  => l_params
                               )
                      end;
        if l_is_found = com_api_const_pkg.FALSE then
            l_index := i_accounts.next(l_index);
        end if;
    end loop;

    return case
               when i_accounts.exists(l_index)
               then i_accounts(l_index)
               else cast(null as acc_api_type_pkg.t_account_rec)
           end;
exception
    when com_api_error_pkg.e_fatal_error
      or com_api_error_pkg.e_application_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' FAILED: i_accounts.count() = #1, l_index = #2, l_is_found = #3'
          , i_env_param1 => i_accounts.count()
          , i_env_param2 => l_index
          , i_env_param3 => case l_is_found
                                when com_api_const_pkg.FALSE then 'false'
                                when com_api_const_pkg.TRUE  then 'true'
                                                             else null
                            end
        );
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end select_account;

procedure get_account(
    o_account_id               out com_api_type_pkg.t_medium_id
  , o_account_number           out com_api_type_pkg.t_account_number
  , o_inst_id                  out com_api_type_pkg.t_inst_id
  , o_agent_id                 out com_api_type_pkg.t_agent_id
  , o_currency                 out com_api_type_pkg.t_curr_code
  , o_account_type             out com_api_type_pkg.t_dict_value
  , o_status                   out com_api_type_pkg.t_dict_value
  , o_contract_id              out com_api_type_pkg.t_medium_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
  , o_scheme_id                out com_api_type_pkg.t_tiny_id
  , o_split_hash               out com_api_type_pkg.t_tiny_id
  , i_selection_id              in com_api_type_pkg.t_tiny_id
  , i_entity_type               in com_api_type_pkg.t_dict_value
  , i_object_id                 in com_api_type_pkg.t_long_id
  , i_account_number            in com_api_type_pkg.t_account_number
  , i_oper_type                 in com_api_type_pkg.t_dict_value
  , i_iso_type                  in com_api_type_pkg.t_dict_value
  , i_oper_currency             in com_api_type_pkg.t_curr_code
  , i_sttl_currency             in com_api_type_pkg.t_curr_code
  , i_bin_currency              in com_api_type_pkg.t_curr_code
  , i_party_type                in com_api_type_pkg.t_dict_value
  , i_msg_type                  in com_api_type_pkg.t_dict_value
  , i_is_forced_processing      in com_api_type_pkg.t_boolean       default null
  , i_terminal_type             in com_api_type_pkg.t_dict_value    default null
  , i_oper_amount               in com_api_type_pkg.t_long_id        default null
  , i_rate_type                 in com_api_type_pkg.t_dict_value     default null
  , i_params                    in com_api_type_pkg.t_param_tab
) is
    l_accounts                     acc_api_type_pkg.t_account_tab;
begin
    get_account(
        i_selection_id          => i_selection_id
      , i_entity_type           => i_entity_type
      , i_object_id             => i_object_id
      , i_account_number        => i_account_number
      , i_party_type            => i_party_type
      , i_oper_type             => i_oper_type
      , i_msg_type              => i_msg_type
      , i_iso_type              => i_iso_type
      , i_oper_currency         => i_oper_currency
      , i_sttl_currency         => i_sttl_currency
      , i_bin_currency          => i_bin_currency
      , i_show_friendly_numbers => com_api_type_pkg.FALSE
      , i_is_forced_processing  => i_is_forced_processing
      , i_terminal_type         => i_terminal_type
      , i_oper_amount           => i_oper_amount
      , i_rate_type             => i_rate_type
      , o_accounts              => l_accounts
    );

    l_accounts(1) := select_account(
                         i_accounts => l_accounts
                       , i_params   => i_params
                     );

    o_account_id     := l_accounts(1).account_id;
    o_account_number := l_accounts(1).account_number;
    o_inst_id        := l_accounts(1).inst_id;
    o_agent_id       := l_accounts(1).agent_id;
    o_currency       := l_accounts(1).currency;
    o_account_type   := l_accounts(1).account_type;
    o_status         := l_accounts(1).status;
    o_contract_id    := l_accounts(1).contract_id;
    o_customer_id    := l_accounts(1).customer_id;
    o_scheme_id      := l_accounts(1).scheme_id;
    o_split_hash     := l_accounts(1).split_hash;

end get_account;

procedure get_account(
    o_account_id               out com_api_type_pkg.t_medium_id
  , o_account_number           out com_api_type_pkg.t_account_number
  , o_inst_id                  out com_api_type_pkg.t_inst_id
  , o_agent_id                 out com_api_type_pkg.t_agent_id
  , o_currency                 out com_api_type_pkg.t_curr_code
  , o_account_type             out com_api_type_pkg.t_dict_value
  , o_contract_id              out com_api_type_pkg.t_medium_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
  , o_scheme_id                out com_api_type_pkg.t_tiny_id
  , o_split_hash               out com_api_type_pkg.t_tiny_id
  , i_selection_id              in com_api_type_pkg.t_tiny_id
  , i_entity_type               in com_api_type_pkg.t_dict_value
  , i_object_id                 in com_api_type_pkg.t_long_id
  , i_account_number            in com_api_type_pkg.t_account_number
  , i_oper_type                 in com_api_type_pkg.t_dict_value
  , i_iso_type                  in com_api_type_pkg.t_dict_value
  , i_oper_currency             in com_api_type_pkg.t_curr_code
  , i_sttl_currency             in com_api_type_pkg.t_curr_code
  , i_bin_currency              in com_api_type_pkg.t_curr_code
  , i_party_type                in com_api_type_pkg.t_dict_value
  , i_msg_type                  in com_api_type_pkg.t_dict_value
  , i_is_forced_processing      in com_api_type_pkg.t_boolean       default null
  , i_terminal_type             in com_api_type_pkg.t_dict_value    default null
  , i_oper_amount               in com_api_type_pkg.t_long_id       default null
  , i_rate_type                 in com_api_type_pkg.t_dict_value    default null
  , i_params                    in com_api_type_pkg.t_param_tab
) is
    l_accounts                  acc_api_type_pkg.t_account_tab;
begin
    get_account(
        i_selection_id          => i_selection_id
      , i_entity_type           => i_entity_type
      , i_object_id             => i_object_id
      , i_account_number        => i_account_number
      , i_oper_type             => i_oper_type
      , i_iso_type              => i_iso_type
      , i_oper_currency         => i_oper_currency
      , i_sttl_currency         => i_sttl_currency
      , i_bin_currency          => i_bin_currency
      , i_party_type            => i_party_type
      , i_msg_type              => i_msg_type
      , i_show_friendly_numbers => com_api_type_pkg.FALSE
      , i_is_forced_processing  => i_is_forced_processing
      , i_terminal_type         => i_terminal_type
      , i_oper_amount           => i_oper_amount
      , i_rate_type             => i_rate_type
      , o_accounts              => l_accounts
    );

    l_accounts(1) := select_account(
                         i_accounts => l_accounts
                       , i_params   => i_params
                     );

    o_account_id     := l_accounts(1).account_id;
    o_account_number := l_accounts(1).account_number;
    o_inst_id        := l_accounts(1).inst_id;
    o_agent_id       := l_accounts(1).agent_id;
    o_currency       := l_accounts(1).currency;
    o_account_type   := l_accounts(1).account_type;
    o_contract_id    := l_accounts(1).contract_id;
    o_customer_id    := l_accounts(1).customer_id;
    o_scheme_id      := l_accounts(1).scheme_id;
    o_split_hash     := l_accounts(1).split_hash;

end get_account;

procedure get_accounts(
    i_entity_type               in com_api_type_pkg.t_dict_value
  , i_object_id                 in com_api_type_pkg.t_long_id
  , i_oper_type                 in com_api_type_pkg.t_dict_value    default null
  , i_account_type              in com_api_type_pkg.t_dict_value    default null
  , i_selection_id              in com_api_type_pkg.t_tiny_id       default null
  , i_party_type                in com_api_type_pkg.t_dict_value    default com_api_const_pkg.PARTICIPANT_ISSUER
  , i_msg_type                  in com_api_type_pkg.t_dict_value    default null
  , i_show_friendly_numbers     in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , o_accounts                 out acc_api_type_pkg.t_account_tab
  , i_is_forced_processing      in com_api_type_pkg.t_boolean       default null
  , i_terminal_type             in com_api_type_pkg.t_dict_value    default null
  , i_oper_amount               in com_api_type_pkg.t_long_id       default null
  , i_rate_type                 in com_api_type_pkg.t_dict_value    default null
) is
begin
    trc_log_pkg.debug(
        i_text        => 'Get accounts by operation and iso: [#1][#2][#3][#4][#5]'
      , i_env_param1  => i_entity_type
      , i_env_param2  => i_object_id
      , i_env_param3  => i_oper_type
      , i_env_param4  => i_account_type
      , i_env_param5  => i_party_type
    );

    get_account(
        i_selection_id          => i_selection_id
      , i_entity_type           => i_entity_type
      , i_object_id             => i_object_id
      , i_account_number        => null
      , i_oper_type             => i_oper_type
      , i_iso_type              => i_account_type
      , i_oper_currency         => null
      , i_sttl_currency         => null
      , i_bin_currency          => null
      , i_party_type            => i_party_type
      , i_msg_type              => i_msg_type
      , i_show_friendly_numbers => i_show_friendly_numbers
      , i_is_forced_processing  => i_is_forced_processing
      , i_terminal_type         => i_terminal_type
      , i_oper_amount           => i_oper_amount
      , i_rate_type             => i_rate_type
      , o_accounts              => o_accounts
    );

    trc_log_pkg.debug(
        i_text        => 'Countr of retrieved accounts is [#1]'
      , i_env_param1  => o_accounts.count()
    );

end get_accounts;

function check_account_restricted(
    i_oper_type                 in com_api_type_pkg.t_dict_value
  , i_inst_id                   in com_api_type_pkg.t_inst_id
  , i_account_type              in com_api_type_pkg.t_dict_value
  , i_account_status            in com_api_type_pkg.t_dict_value
  , i_party_type                in com_api_type_pkg.t_dict_value
  , i_msg_type                  in com_api_type_pkg.t_dict_value
  , i_is_forced_processing      in com_api_type_pkg.t_boolean        default null
) return com_api_type_pkg.t_boolean
is
    l_priority                      com_api_type_pkg.t_tiny_id;
begin
    begin
        select p.priority
          into l_priority
          from acc_selection_priority p
         where i_oper_type like p.oper_type
           and i_inst_id like p.inst_id
           and i_account_type like p.account_type
           and (i_account_status like p.account_status
                or
                nvl(i_is_forced_processing, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE)
           and i_party_type like p.party_type
           and (i_msg_type is null or i_msg_type like p.msg_type)
           and rownum = 1;
    exception
        when no_data_found then
            l_priority := null;
    end;

    return case when l_priority is null then com_api_type_pkg.TRUE
                                        else com_api_type_pkg.FALSE
           end;
end check_account_restricted;

end acc_api_selection_pkg;
/
