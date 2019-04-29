create or replace package body acc_api_balance_pkg is
/*********************************************************
 *  API for account balances <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 28.10.2010 <br />
 *  Module: acc_api_balance_pkg  <br />
 *  @headcom
 **********************************************************/

procedure get_account_balances (
    i_account_id            in com_api_type_pkg.t_account_id
  , o_balances             out com_api_type_pkg.t_amount_by_name_tab
  , i_lock_balances         in com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
) is
    l_balance               com_api_type_pkg.t_money;
begin
    get_account_balances (
        i_account_id        => i_account_id
      , o_balances          => o_balances
      , o_balance           => l_balance
      , i_lock_balances     => i_lock_balances
    );
end;

procedure get_account_balances (
    i_account_id            in com_api_type_pkg.t_account_id
  , o_balances             out com_api_type_pkg.t_amount_by_name_tab
  , o_account_balance      out com_api_type_pkg.t_money
  , o_account_currency     out com_api_type_pkg.t_curr_code
  , i_lock_balances         in com_api_type_pkg.t_boolean
) is
    l_balances              acc_api_type_pkg.t_balance_tab;
begin
    trc_log_pkg.debug(
        i_text        => 'Searching balances for account [#1]'
      , i_env_param1  => i_account_id
    );

    if i_lock_balances = com_api_type_pkg.TRUE then
        select b.balance_type
             , b.currency balance_currency
             , case when t.balance_algorithm is null then b.balance + nvl(r.reserv_amount, 0)
                    else acc_cst_balance_pkg.get_balance_amount (b.account_id, t.balance_algorithm)
               end
             , a.currency account_currency
             , case when a.currency = b.currency then b.balance + nvl(r.reserv_amount, 0)
                    else com_api_rate_pkg.convert_amount(b.balance + nvl(r.reserv_amount, 0),
                                                         b.currency,
                                                         a.currency,
                                                         t.rate_type,
                                                         a.inst_id,
                                                         get_sysdate(),
                                                         com_api_type_pkg.FALSE,
                                                         null,
                                                         com_api_const_pkg.CONVERSION_TYPE_SELLING)
               end as amount
             , t.aval_impact
          bulk collect into
             l_balances
          from acc_account a
             , acc_balance b
             , acc_balance_type t
             , acc_api_balance_reserv_vw r
         where a.id = i_account_id
           and a.id = b.account_id
           and b.split_hash = a.split_hash
           and a.account_type = t.account_type
           and a.inst_id = t.inst_id
           and b.balance_type = t.balance_type
           and b.account_id = r.account_id(+)
           and b.balance_type = r.balance_type (+)
           and b.split_hash = r.split_hash(+)
           for update of
               b.balance
               nowait;
    else
        select b.balance_type
             , b.currency
             , case when t.balance_algorithm is null then b.balance + nvl(r.reserv_amount, 0)
                    else acc_cst_balance_pkg.get_balance_amount (b.account_id, t.balance_algorithm)
               end
             , a.currency
             , case when a.currency = b.currency then b.balance + nvl(r.reserv_amount, 0)
                    else com_api_rate_pkg.convert_amount(b.balance + nvl(r.reserv_amount, 0),
                                                         b.currency,
                                                         a.currency,
                                                         t.rate_type,
                                                         a.inst_id,
                                                         get_sysdate(),
                                                         com_api_type_pkg.FALSE,
                                                         null,
                                                         com_api_const_pkg.CONVERSION_TYPE_SELLING)
               end amount
             , t.aval_impact
          bulk collect into
               l_balances
          from acc_account a
             , acc_balance b
             , acc_balance_type t
             , acc_api_balance_reserv_vw r
         where a.id = i_account_id
           and a.id = b.account_id
           and b.split_hash = a.split_hash
           and a.account_type = t.account_type
           and a.inst_id = t.inst_id
           and b.balance_type = t.balance_type
           and b.account_id = r.account_id(+)
           and b.balance_type = r.balance_type (+)
           and b.split_hash = r.split_hash(+);
    end if;

    if l_balances.count > 0 then
        for i in 1 .. l_balances.count loop
            trc_log_pkg.debug(
                i_text        => 'Balance [#1] amount [#2][#3][#4][#5][#6]'
              , i_env_param1  => l_balances(i).balance_type
              , i_env_param2  => l_balances(i).balance_amount
              , i_env_param3  => l_balances(i).balance_currency
              , i_env_param4  => l_balances(i).aval_impact
              , i_env_param5  => l_balances(i).account_amount
              , i_env_param6  => l_balances(i).account_currency
            );

            o_balances(l_balances(i).balance_type).amount := l_balances(i).balance_amount;
            o_balances(l_balances(i).balance_type).currency := l_balances(i).balance_currency;

            o_account_balance := nvl(o_account_balance, 0) + l_balances(i).aval_impact * l_balances(i).account_amount;
        end loop;

        /*l_aval_balance :=
            acc_api_balance_pkg.get_aval_balance_amount (
                i_account_id    => i_account_id
              , i_date          => com_api_sttl_day_pkg.get_sysdate
              , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
              , i_mask_error    => com_api_type_pkg.TRUE
            );

        o_account_balance  := l_aval_balance.amount;
        o_account_currency := l_aval_balance.currency;*/
        o_account_currency := l_balances(1).account_currency;

        trc_log_pkg.debug(
            i_text        => 'Available [#1][#2]'
          , i_env_param1  => o_account_balance
          , i_env_param2  => o_account_currency
        );
    end if;

exception
    when com_api_error_pkg.e_resource_busy then
        com_api_error_pkg.raise_error (
            i_error       => 'RESOURCE_BUSY'
          , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_env_param2  => i_account_id
        );
end get_account_balances;

procedure get_account_balances (
    i_account_id            in com_api_type_pkg.t_account_id
  , o_balances             out com_api_type_pkg.t_amount_by_name_tab
  , o_balance              out com_api_type_pkg.t_money
  , i_lock_balances         in com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
) is
    l_account_currency      com_api_type_pkg.t_curr_code;
begin
    get_account_balances(
        i_account_id        => i_account_id
      , o_balances          => o_balances
      , o_account_balance   => o_balance
      , o_account_currency  => l_account_currency
      , i_lock_balances     => i_lock_balances
    );
end;

procedure get_account_balance (
    i_account_id            in com_api_type_pkg.t_account_id
    , o_account_balance     out com_api_type_pkg.t_money
    , o_account_currency    out com_api_type_pkg.t_curr_code
) is
    l_balances              com_api_type_pkg.t_amount_by_name_tab;
begin
    get_account_balances(
        i_account_id        => i_account_id
      , o_balances          => l_balances
      , o_account_balance   => o_account_balance
      , o_account_currency  => o_account_currency
      , i_lock_balances     => com_api_type_pkg.FALSE
    );
end;

function get_balance_amount (
    i_account_id            in com_api_type_pkg.t_account_id
  , i_balance_type          in com_api_type_pkg.t_dict_value
  , i_mask_error            in com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
  , i_lock_balance          in com_api_type_pkg.t_boolean     := com_api_type_pkg.TRUE
) return com_api_type_pkg.t_amount_rec is
    l_result                com_api_type_pkg.t_amount_rec;
begin
    begin
        if i_lock_balance = com_api_type_pkg.TRUE then
            select b.balance
                 , b.currency
              into l_result.amount
                 , l_result.currency
              from acc_balance b
                 , acc_account a
             where a.id           = i_account_id
               and b.account_id   = a.id
               and b.balance_type = i_balance_type
               and b.split_hash   = a.split_hash
            for update nowait;

        else
            select b.balance
                 , b.currency
              into l_result.amount
                 , l_result.currency
              from acc_balance b
                 , acc_account a
             where a.id           = i_account_id
               and b.account_id   = a.id
               and b.balance_type = i_balance_type
               and b.split_hash   = a.split_hash;

        end if;
    exception
        when no_data_found then
            if i_mask_error = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error (
                    i_error         => 'BALANCE_NOT_FOUND'
                    , i_env_param1  => i_account_id
                    , i_env_param2  => i_balance_type
                );
            else
                trc_log_pkg.error (
                    i_text          => 'BALANCE_NOT_FOUND'
                    , i_env_param1  => i_account_id
                    , i_env_param2  => i_balance_type
                );

                l_result := null;
            end if;

    when com_api_error_pkg.e_resource_busy then
        com_api_error_pkg.raise_error (
            i_error         => 'RESOURCE_BUSY'
            , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            , i_env_param2  => i_account_id
        );
    end;

    return l_result;
end;

function get_balance_amount (
    i_account_id            in com_api_type_pkg.t_account_id
  , i_balance_type          in com_api_type_pkg.t_dict_value
  , i_date                  in date
  , i_date_type             in com_api_type_pkg.t_dict_value
  , i_mask_error            in com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_inst_id               in com_api_type_pkg.t_inst_id      := null
) return com_api_type_pkg.t_amount_rec
is
    l_result                com_api_type_pkg.t_amount_rec;
    l_from_id               com_api_type_pkg.t_long_id;
    l_inst_id               com_api_type_pkg.t_inst_id         := i_inst_id;
    l_open_sttl_date        date;
begin
    begin
        if i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING then

            l_from_id := com_api_id_pkg.get_from_id(i_date);

            select l.currency
                 , (l.balance - nvl(sum(e.amount * e.balance_impact), 0)) balance
              into l_result.currency
                 , l_result.amount
              from acc_entry e
                 , acc_balance l
                 , acc_account a
             where a.id              = i_account_id
               and l.account_id      = a.id
               and l.split_hash      = a.split_hash
               and l.balance_type    = i_balance_type
               and e.account_id(+)   = l.account_id
               and e.balance_type(+) = l.balance_type
               and e.split_hash(+)   = l.split_hash
               and e.posting_date(+) > i_date
               and e.id(+)           > l_from_id
             group by l.currency
                    , l.balance;

        elsif i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK then

            if l_inst_id is null then
                select inst_id
                  into l_inst_id
                  from acc_account
                 where id = i_account_id;
            end if;

            l_open_sttl_date := com_api_sttl_day_pkg.get_sttl_day_open_date(
                                    i_sttl_date  => i_date
                                  , i_inst_id    => l_inst_id
                                );
            l_from_id        := com_api_id_pkg.get_from_id(l_open_sttl_date);

            select l.currency
                 , (l.balance - nvl(sum(e.amount * e.balance_impact), 0)) balance
              into l_result.currency
                 , l_result.amount
              from acc_entry e
                 , acc_balance l
                 , acc_account a
             where a.id              = i_account_id
               and l.account_id      = a.id
               and l.split_hash      = a.split_hash
               and l.balance_type    = i_balance_type
               and e.account_id(+)   = l.account_id
               and e.balance_type(+) = l.balance_type
               and e.split_hash(+)   = l.split_hash
               and e.sttl_date(+)    > i_date
               and e.id(+)           > l_from_id
             group by l.currency
                    , l.balance;

        else
            if i_mask_error = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error (
                    i_error          => 'BALANCE_DATE_TYPE_NOT_SUPPORTED'
                  , i_env_param1     => i_date_type
                );
            else
                trc_log_pkg.error (
                    i_text           => 'BALANCE_DATE_TYPE_NOT_SUPPORTED'
                  , i_env_param1     => i_date_type
                );

                l_result := null;
            end if;
        end if;

    exception
        when no_data_found then
            begin
                select 0
                     , currency
                  into l_result.amount
                     , l_result.currency
                  from acc_balance
                 where account_id   = i_account_id
                   and balance_type = i_balance_type;
            exception
                when no_data_found then
                    if i_mask_error = com_api_type_pkg.FALSE then
                        com_api_error_pkg.raise_error (
                            i_error          => 'BALANCE_NOT_FOUND'
                          , i_env_param1     => i_account_id
                          , i_env_param2     => i_balance_type
                        );
                    else
                        trc_log_pkg.error (
                            i_text           => 'BALANCE_NOT_FOUND'
                          , i_env_param1     => i_account_id
                          , i_env_param2     => i_balance_type
                        );

                        l_result := null;
                    end if;
            end;
    end;

    return l_result;
end;

function get_aval_balance_amount (
    i_account_id    in    com_api_type_pkg.t_account_id
  , i_date          in    date
  , i_date_type     in    com_api_type_pkg.t_dict_value
  , i_mask_error    in    com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
) return com_api_type_pkg.t_amount_rec is
    l_result              com_api_type_pkg.t_amount_rec;
    l_aval_algorithm      com_api_type_pkg.t_dict_value;
    l_split_hash          com_api_type_pkg.t_tiny_id;
    l_from_id             com_api_type_pkg.t_long_id;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_open_sttl_date      date;
begin
    select nvl(t.aval_algorithm, acc_api_const_pkg.AVAIL_ALGORITHM_OWN)
         , a.currency
         , a.split_hash
         , a.inst_id
      into l_aval_algorithm
         , l_result.currency
         , l_split_hash
         , l_inst_id
      from acc_product_account_type t
         , acc_account a
         , prd_contract c
         , prd_service_object so
     where a.id           = i_account_id
       and c.id           = a.contract_id
       and t.account_type = a.account_type
       and t.product_id   = c.product_id
       and t.currency     = a.currency
       and so.contract_id = c.id
       and so.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and so.object_id   = a.id
       and so.service_id  = t.service_id;

    -- check algorithm
    if l_aval_algorithm not in (acc_api_const_pkg.AVAIL_ALGORITHM_OWN
                              , acc_api_const_pkg.AVAIL_ALGORITHM_CARD)
    then
        l_result := acc_cst_balance_pkg.get_aval_balance_amount(
                        i_account_id        => i_account_id
                      , i_date              => i_date
                      , i_date_type         => i_date_type
                      , i_aval_algorithm    => l_aval_algorithm
                      , i_split_hash        => l_split_hash
                      , i_currency          => l_result.currency
                      , i_mask_error        => i_mask_error
                    );
        return l_result;
    end if;

    if i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING then

        l_from_id := com_api_id_pkg.get_from_id(i_date);

    elsif i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK then

        l_open_sttl_date := com_api_sttl_day_pkg.get_sttl_day_open_date(
                                i_sttl_date  => i_date
                              , i_inst_id    => l_inst_id
                            );
        l_from_id        := com_api_id_pkg.get_from_id(l_open_sttl_date);

    else
        if i_mask_error = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error       => 'BALANCE_DATE_TYPE_NOT_SUPPORTED'
              , i_env_param1  => i_date_type
            );
        else
            trc_log_pkg.error (
                i_text        => 'BALANCE_DATE_TYPE_NOT_SUPPORTED'
              , i_env_param1  => i_date_type
            );

            l_result := null;
        end if;
    end if;

    if l_aval_algorithm   = acc_api_const_pkg.AVAIL_ALGORITHM_OWN then

        select nvl(sum(
                       case
                           when m.currency = l_result.currency
                           then m.aval_impact * m.balance
                           else m.aval_impact * com_api_rate_pkg.convert_amount(
                                                    i_src_amount      => m.balance
                                                  , i_src_currency    => m.currency
                                                  , i_dst_currency    => l_result.currency
                                                  , i_rate_type       => m.rate_type
                                                  , i_inst_id         => m.inst_id
                                                  , i_eff_date        => i_date
                                                )
                       end
               ), 0) as balance
          into l_result.amount
          from (
                select b.balance_type
                     , b.currency
                     , b.account_id
                     , t.aval_impact
                     , t.rate_type
                     , t.inst_id
                     , (b.balance
                        - case
                              when i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                              then (
                                       select nvl(sum(e.amount * e.balance_impact), 0)
                                         from acc_entry e
                                        where e.account_id   = b.account_id
                                          and e.balance_type = b.balance_type
                                          and e.posting_date > i_date
                                          and e.split_hash   = b.split_hash
                                          and e.id           > l_from_id
                                    )
                              when i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                              then (
                                       select nvl(sum(e.amount * e.balance_impact), 0)
                                         from acc_entry e
                                        where e.account_id   = b.account_id
                                          and e.balance_type = b.balance_type
                                          and e.sttl_date    > i_date
                                          and e.split_hash   = b.split_hash
                                          and e.id           > l_from_id
                                   )
                          end) as balance
                  from acc_account a
                     , acc_balance_type t
                     , acc_balance b
                 where a.id              = i_account_id
                   and a.split_hash      = l_split_hash
                   and t.account_type    = a.account_type
                   and t.inst_id         = a.inst_id
                   and t.aval_impact    != com_api_const_pkg.NONE
                   and b.account_id      = a.id
                   and b.balance_type    = t.balance_type
                   and b.split_hash      = a.split_hash
               ) m;

    elsif l_aval_algorithm   = acc_api_const_pkg.AVAIL_ALGORITHM_CARD then

        select nvl(sum(
                       case
                           when m.currency = l_result.currency
                           then m.aval_impact * m.balance
                           else m.aval_impact * com_api_rate_pkg.convert_amount(
                                                    i_src_amount      => m.balance
                                                  , i_src_currency    => m.currency
                                                  , i_dst_currency    => l_result.currency
                                                  , i_rate_type       => m.rate_type
                                                  , i_inst_id         => m.inst_id
                                                  , i_eff_date        => i_date
                                                )
                       end
               ), 0) as balance
          into l_result.amount
          from (
                select b.balance_type
                     , b.currency
                     , b.account_id
                     , t.aval_impact
                     , t.rate_type
                     , t.inst_id
                     , (b.balance
                        - case
                              when i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                              then (
                                       select nvl(sum(e.amount * e.balance_impact), 0)
                                         from acc_entry e
                                        where e.account_id   = b.account_id
                                          and e.balance_type = b.balance_type
                                          and e.posting_date > i_date
                                          and e.split_hash   = b.split_hash
                                          and e.id           > l_from_id
                                    )
                              when i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                              then (
                                       select nvl(sum(e.amount * e.balance_impact), 0)
                                         from acc_entry e
                                        where e.account_id   = b.account_id
                                          and e.balance_type = b.balance_type
                                          and e.sttl_date    > i_date
                                          and e.split_hash   = b.split_hash
                                          and e.id           > l_from_id
                                   )
                          end) as balance
                  from acc_account_object o
                     , acc_account_object o2
                     , acc_account a
                     , acc_balance_type t
                     , acc_balance b
                 where o.account_id      = i_account_id
                   and o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and o.split_hash      = l_split_hash
                   and o2.object_id      = o.object_id
                   and o2.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and o2.split_hash     = o.split_hash
                   and a.id              = o2.account_id
                   and a.split_hash      = o2.split_hash
                   and t.account_type    = a.account_type
                   and t.inst_id         = a.inst_id
                   and t.aval_impact    != com_api_const_pkg.NONE
                   and b.account_id      = a.id
                   and b.balance_type    = t.balance_type
                   and b.split_hash      = a.split_hash
               ) m;

    end if;

    return l_result;
exception
    when no_data_found then
        select 0
             , currency
          into l_result.amount
             , l_result.currency
          from acc_account
         where id = i_account_id;

        return l_result;
end;

procedure get_object_accounts_balance (
    i_object_id             in com_api_type_pkg.t_long_id
    , i_entity_type         in com_api_type_pkg.t_dict_value
    , i_currency            in com_api_type_pkg.t_curr_code
    , i_rate_type           in com_api_type_pkg.t_dict_value
    , i_conversion_type     in com_api_type_pkg.t_dict_value
    , o_available           out com_api_type_pkg.t_money
) is
    l_accounts              acc_api_type_pkg.t_account_tab;
    l_balances              com_api_type_pkg.t_amount_by_name_tab;
    l_amount                com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text        => 'Get [#1][#2] accounts aval balance'
      , i_env_param1  => i_entity_type
      , i_env_param2  => i_object_id
    );

    acc_api_selection_pkg.get_accounts(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , o_accounts     => l_accounts
    );

    for i in 1..l_accounts.count loop
        acc_api_balance_pkg.get_account_balances (
            i_account_id  => l_accounts(i).account_id
            , o_balances  => l_balances
            , o_balance   => l_amount
        );

        o_available := nvl(o_available, 0)
                     + com_api_rate_pkg.convert_amount(
                           i_src_amount      => l_amount
                         , i_src_currency    => l_accounts(i).currency
                         , i_dst_currency    => i_currency
                         , i_rate_type       => i_rate_type
                         , i_conversion_type => i_conversion_type
                         , i_inst_id         => l_accounts(i).inst_id
                         , i_eff_date        => get_sysdate
                       );
    end loop;

    o_available := nvl(o_available, 0);

    trc_log_pkg.debug(
        i_text        => 'Available: [#1]'
      , i_env_param1  => o_available
    );
end;

function get_update_macros_type (
    i_inst_id               in com_api_type_pkg.t_inst_id
  , i_account_type          in com_api_type_pkg.t_dict_value
  , i_balance_type          in com_api_type_pkg.t_dict_value
  , i_raise_error           in com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
) return com_api_type_pkg.t_tiny_id is
    l_result                com_api_type_pkg.t_tiny_id;
begin
    begin
        select
            update_macros_type
        into
            l_result
        from
            acc_balance_type
        where
            inst_id = i_inst_id
            and account_type = i_account_type
            and balance_type = i_balance_type;

        if l_result is null then
            raise no_data_found;
        end if;
    exception
        when no_data_found or too_many_rows then
            if i_raise_error = com_api_type_pkg.FALSE then
                l_result := null;
            else
                com_api_error_pkg.raise_error (
                    i_error         => 'CANT_GET_DEFAULT_UPDATE_MACROS'
                    , i_env_param1  => i_inst_id
                    , i_env_param2  => i_account_type
                    , i_env_param3  => i_balance_type
                    , i_env_param4  => sqlerrm
                );
            end if;
    end;

    return l_result;
end;

function get_aval_balance_amount_only (
    i_account_id          in com_api_type_pkg.t_account_id
  , i_date                in date
  , i_date_type           in com_api_type_pkg.t_dict_value
  , i_mask_error          in com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE
) return com_api_type_pkg.t_money is
    l_res               com_api_type_pkg.t_amount_rec;
begin
    l_res := get_aval_balance_amount(i_account_id, i_date, i_date_type, i_mask_error);
    return l_res.amount;
end;

function get_aval_balance_amount (
    i_account_id          in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_amount_rec
is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_aval_balance_amount: ';
    l_result            com_api_type_pkg.t_amount_rec;
    l_aval_algorithm    com_api_type_pkg.t_dict_value;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_sysdate           date;
begin
    l_sysdate := get_sysdate;

    select nvl(t.aval_algorithm, acc_api_const_pkg.AVAIL_ALGORITHM_OWN)
         , a.currency
         , a.split_hash
      into l_aval_algorithm
         , l_result.currency
         , l_split_hash
      from acc_product_account_type t
         , acc_account a
         , prd_contract c
     where a.id           = i_account_id
       and c.id           = a.contract_id
       and t.account_type = a.account_type
       and t.product_id   = c.product_id
       and a.currency     = t.currency
       and rownum         = 1;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_account_id [#1], l_aval_algorithm [#2], l_result.currency [#3], l_split_hash [#4]'
      , i_env_param1 => i_account_id
      , i_env_param2 => l_aval_algorithm
      , i_env_param3 => l_result.currency
      , i_env_param4 => l_split_hash
    );

    --check algorithm
    if l_aval_algorithm not in (acc_api_const_pkg.AVAIL_ALGORITHM_OWN, acc_api_const_pkg.AVAIL_ALGORITHM_CARD) then
        l_result := acc_cst_balance_pkg.get_aval_balance_amount (
            i_account_id            => i_account_id
            , i_aval_algorithm      => l_aval_algorithm
            , i_split_hash          => l_split_hash
            , i_currency            => l_result.currency
        );
        return l_result;
    end if;

    if l_aval_algorithm   = acc_api_const_pkg.AVAIL_ALGORITHM_OWN then

        select nvl(sum(
                       case
                           when m.currency = l_result.currency
                           then m.aval_impact * m.balance
                           else m.aval_impact * com_api_rate_pkg.convert_amount(
                                                    i_src_amount      => m.balance
                                                  , i_src_currency    => m.currency
                                                  , i_dst_currency    => l_result.currency
                                                  , i_rate_type       => m.rate_type
                                                  , i_inst_id         => m.inst_id
                                                  , i_eff_date        => l_sysdate
                                                )
                       end
               ), 0) as balance
          into l_result.amount
          from (
                select b.balance_type
                     , b.currency
                     , b.account_id
                     , t.aval_impact
                     , t.rate_type
                     , t.inst_id
                     , (b.balance
                        + (
                             select nvl(sum(e.amount * e.balance_impact), 0)
                               from acc_entry_buffer e
                              where e.account_id   = b.account_id
                                and e.balance_type = b.balance_type
                                and e.posting_date > l_sysdate
                                and e.split_hash   = b.split_hash
                                and e.status       = 'BUSTRSRV'
                          )) as balance
                  from acc_account a
                     , acc_balance_type t
                     , acc_balance b
                 where a.id              = i_account_id
                   and a.split_hash      = l_split_hash
                   and t.account_type    = a.account_type
                   and t.inst_id         = a.inst_id
                   and t.aval_impact    != com_api_const_pkg.NONE
                   and b.account_id      = a.id
                   and b.balance_type    = t.balance_type
                   and b.split_hash      = a.split_hash
               ) m;

    elsif l_aval_algorithm   = acc_api_const_pkg.AVAIL_ALGORITHM_CARD then

        select nvl(sum(
                       case
                           when m.currency = l_result.currency
                           then m.aval_impact * m.balance
                           else m.aval_impact * com_api_rate_pkg.convert_amount(
                                                    i_src_amount      => m.balance
                                                  , i_src_currency    => m.currency
                                                  , i_dst_currency    => l_result.currency
                                                  , i_rate_type       => m.rate_type
                                                  , i_inst_id         => m.inst_id
                                                  , i_eff_date        => l_sysdate
                                                )
                       end
               ), 0) as balance
          into l_result.amount
          from (
                select b.balance_type
                     , b.currency
                     , b.account_id
                     , t.aval_impact
                     , t.rate_type
                     , t.inst_id
                     , (b.balance
                        + (
                             select nvl(sum(e.amount * e.balance_impact), 0)
                               from acc_entry_buffer e
                              where e.account_id   = b.account_id
                                and e.balance_type = b.balance_type
                                and e.posting_date > l_sysdate
                                and e.split_hash   = b.split_hash
                                and e.status       = 'BUSTRSRV'
                          )) as balance
                  from acc_account_object o
                     , acc_account_object o2
                     , acc_account a
                     , acc_balance_type t
                     , acc_balance b
                 where o.account_id      = i_account_id
                   and o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and o.split_hash      = l_split_hash
                   and o2.object_id      = o.object_id
                   and o2.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and o2.split_hash     = o.split_hash
                   and a.id              = o2.account_id
                   and a.split_hash      = o2.split_hash
                   and t.account_type    = a.account_type
                   and t.inst_id         = a.inst_id
                   and t.aval_impact    != com_api_const_pkg.NONE
                   and b.account_id      = a.id
                   and b.balance_type    = t.balance_type
                   and b.split_hash      = a.split_hash
               ) m;

    end if;

    return l_result;
exception
    when no_data_found then
        select 0
             , currency
          into l_result.amount
             , l_result.currency
          from acc_account
         where id = i_account_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'i_account_id [#1], l_aval_algorithm [#2], l_result{currency [#3]; amount [#4]}'
          , i_env_param1 => i_account_id
          , i_env_param2 => l_aval_algorithm
          , i_env_param3 => l_result.currency
          , i_env_param4 => l_result.amount
        );

        return l_result;
end;

function get_aval_balance_amount_only (
    i_account_id        in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_money is
    l_result            com_api_type_pkg.t_amount_rec;
begin
    l_result := get_aval_balance_amount(i_account_id);
    return l_result.amount;
end;

end;
/
