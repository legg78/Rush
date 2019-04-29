create or replace package body pmo_api_order_pkg as

/************************************************************
 * API for Payment Order<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 14.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_API_ORDER_PKG <br />
 * @headcom
 ************************************************************/

BULK_LIMIT                      binary_integer := 400;

procedure add_order(
    o_id                            out com_api_type_pkg.t_long_id
  , i_customer_id               in      com_api_type_pkg.t_medium_id
  , i_entity_type               in      com_api_type_pkg.t_dict_value
  , i_object_id                 in      com_api_type_pkg.t_long_id
  , i_purpose_id                in      com_api_type_pkg.t_short_id
  , i_template_id               in      com_api_type_pkg.t_tiny_id
  , i_amount                    in      com_api_type_pkg.t_money
  , i_currency                  in      com_api_type_pkg.t_curr_code
  , i_event_date                in      date
  , i_status                    in      com_api_type_pkg.t_dict_value
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_attempt_count             in      com_api_type_pkg.t_tiny_id
  , i_is_prepared_order         in      com_api_type_pkg.t_boolean
  , i_is_template               in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_dst_customer_id           in      com_api_type_pkg.t_medium_id    default null
  , i_in_purpose_id             in      com_api_type_pkg.t_medium_id    default null
  , i_split_hash                in      com_api_type_pkg.t_tiny_id      default null
  , i_payment_order_number      in      com_api_type_pkg.t_name         default null
  , i_expiration_date           in      date                            default null
  , i_resp_code                 in      com_api_type_pkg.t_dict_value   default null
  , i_resp_amount               in      com_api_type_pkg.t_money        default null
  , i_order_originator_refnum   in      com_api_type_pkg.t_rrn          default null
) is
    l_split_hash                   com_api_type_pkg.t_tiny_id;
    l_count                        com_api_type_pkg.t_long_id;
    l_payment_order_number         com_api_type_pkg.t_name;
    l_params                       com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug('pmo_api_order_pkg.add_order START i_customer_id=' || i_customer_id ||
        ' i_entity_type=' || i_entity_type || ' i_object_id=' || i_object_id ||
        ' i_purpose_id=' || i_purpose_id || ' i_template_id=' || i_template_id ||
        ' i_amount=' || i_amount || ' i_currency=' || i_currency ||
        ' i_is_prepared_order=' || i_is_prepared_order || ' i_attempt_count=' || i_attempt_count ||
        ' i_is_template=' || i_is_template || ' i_originator_refnum = ' || i_order_originator_refnum
    );
    if i_split_hash is null and i_customer_id is not null then
        begin
            select a.split_hash
              into l_split_hash
              from prd_customer_vw a
             where a.id = i_customer_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error => 'CUSTOMER_NOT_FOUND'
                  , i_env_param1 => i_customer_id
                );
        end;
    elsif i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash( i_purpose_id );
    else
        l_split_hash := i_split_hash;
    end if;

    if i_purpose_id is not null then
        select count(1)
          into l_count
          from pmo_purpose
         where id = i_purpose_id;

        if l_count = 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'PAYMENT_PURPOSE_NOT_FOUND'
              , i_env_param1 => i_purpose_id
            );
        end if;
    end if;

    if i_in_purpose_id is not null then
        select count(1)
          into l_count
          from pmo_purpose
         where id = i_in_purpose_id;

        if l_count = 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'PAYMENT_PURPOSE_NOT_FOUND'
              , i_env_param1 => i_in_purpose_id
            );
        end if;
    end if;

    o_id := com_api_id_pkg.get_id(pmo_order_seq.nextval, i_event_date);

    if i_payment_order_number is null then
        rul_api_param_pkg.set_param (
            i_value   => o_id
          , i_name    => 'PAYMENT_ORDER_ID'
          , io_params => l_params
        );

        l_payment_order_number := rul_api_name_pkg.get_name (
                i_inst_id             => i_inst_id
              , i_entity_type         => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
              , i_param_tab           => l_params
              , i_double_check_value  => null
            );
    else
        l_payment_order_number := i_payment_order_number;
    end if;

    insert into pmo_order(
        id
      , customer_id
      , entity_type
      , object_id
      , purpose_id
      , template_id
      , amount
      , currency
      , event_date
      , status
      , inst_id
      , attempt_count
      , split_hash
      , is_template
      , templ_status
      , is_prepared_order
      , in_purpose_id
      , dst_customer_id
      , payment_order_number
      , expiration_date
      , resp_code
      , resp_amount
      , originator_refnum
    ) values (
        o_id
      , i_customer_id
      , i_entity_type
      , i_object_id
      , i_purpose_id
      , i_template_id
      , i_amount
      , i_currency
      , i_event_date
      , i_status
      , i_inst_id
      , i_attempt_count
      , l_split_hash
      , i_is_template
      , null
      , i_is_prepared_order
      , i_in_purpose_id
      , i_dst_customer_id
      , l_payment_order_number
      , i_expiration_date
      , i_resp_code
      , i_resp_amount
      , i_order_originator_refnum
    );
    trc_log_pkg.debug('order added, id = '||o_id);
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error         => 'PAYMENT_ORDER_NUMBER_NOT_UNIQUE'
          , i_env_param1    => l_payment_order_number
        );

end add_order;

procedure choose_host_by_priority(
    i_provider_id        in     com_api_type_pkg.t_short_id
  , i_network_id         in     com_api_type_pkg.t_tiny_id      default null
  , i_host_prev          in     com_api_type_pkg.t_tiny_id      default null
  , o_host_member_id        out com_api_type_pkg.t_tiny_id
  , io_execution_type       out com_api_type_pkg.t_dict_value
  , o_host_next             out com_api_type_pkg.t_boolean
  , o_responce_code         out com_api_type_pkg.t_dict_value

) is
    l_count                 com_api_type_pkg.t_tiny_id;

begin
    trc_log_pkg.debug('Choose host by priority: Provider:'|| i_provider_id ||', host:'|| nvl(i_host_prev, -1));

    select count(1)
      into l_count
      from pmo_provider_host b
         , net_member m
     where b.provider_id = i_provider_id
       and m.id = b.host_member_id
       and (b.inactive_till is null or b.inactive_till < get_sysdate)
       and (m.inactive_till is null or m.inactive_till < get_sysdate)
       and (i_network_id is null or m.network_id = i_network_id)
       and (io_execution_type is null or b.execution_type = io_execution_type)
       and m.status = net_api_const_pkg.HOST_STATUS_ACTIVE;

    trc_log_pkg.debug('l_count:'|| l_count);

    -- if only 1 record and i_host_prev is not null
    if l_count = 1 and i_host_prev is not null then
        o_host_member_id := i_host_prev;
        o_host_next      := com_api_const_pkg.FALSE;

    else
        trc_log_pkg.debug('i_host_prev:['|| i_host_prev || '], io_execution_type:[' || io_execution_type || '], i_network_id:[' || i_network_id || '], i_provider_id=' || i_provider_id || ']');

        select a.host_member_id
             , a.execution_type
             , nvl2(a.host_next, com_api_type_pkg.TRUE, com_api_type_pkg.FALSE) host_next
          into o_host_member_id
             , io_execution_type
             , o_host_next
          from (
                select b.host_member_id
                     , b.execution_type
                     , lag(b.host_member_id, 1) over (order by b.priority) host_prev
                     , lead(b.host_member_id, 1) over (order by b.priority) host_next
                  from pmo_provider_host b
                     , net_member m
                 where b.provider_id = i_provider_id
                   and m.id = b.host_member_id
                   and (b.inactive_till is null or b.inactive_till < get_sysdate)
                   and (m.inactive_till is null or m.inactive_till < get_sysdate)
                   and (i_network_id is null or m.network_id = i_network_id)
                   and (io_execution_type is null or b.execution_type = io_execution_type)
                   and m.status = net_api_const_pkg.HOST_STATUS_ACTIVE
                 order by b.priority
               ) a
         where (a.host_prev = i_host_prev or (i_host_prev is null and a.host_prev is null));

    end if;

    o_responce_code := pmo_api_const_pkg.SUCCESSFUL_AUTHORIZATION;

exception
    when no_data_found then
        o_responce_code := pmo_api_const_pkg.CHANNEL_NOT_AVAILABLE;
        o_host_next     := com_api_const_pkg.FALSE;
        trc_log_pkg.debug('Choose host by priority: host not found ');
end;

function check_min_max_amount(
    i_amount             in     com_api_type_pkg.t_money
  , i_currency           in     com_api_type_pkg.t_curr_code
  , i_purpose_id         in     com_api_type_pkg.t_short_id
  , i_payment_host_id    in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean is
    l_provider_id         com_api_type_pkg.t_short_id;
    l_contract_id         com_api_type_pkg.t_medium_id;
    l_product_id          com_api_type_pkg.t_short_id;
    l_min_amount          com_api_type_pkg.t_money;
    l_max_amount          com_api_type_pkg.t_money;
    l_amount              com_api_type_pkg.t_money;
    l_min_fee_id          com_api_type_pkg.t_short_id;
    l_max_fee_id          com_api_type_pkg.t_short_id;
    l_currency            com_api_type_pkg.t_curr_code;
    l_params              com_api_type_pkg.t_param_tab;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_rate_type           com_api_type_pkg.t_dict_value;
    l_custom_result       com_api_type_pkg.t_boolean;
    l_custom_attr_present com_api_type_pkg.t_boolean;
begin

    if i_amount is null then
        return com_api_const_pkg.TRUE;
    end if;

    l_custom_result := cst_api_order_pkg.check_min_max_amount(
        i_amount            => i_amount
      , i_currency          => i_currency
      , i_purpose_id        => i_purpose_id
      , i_payment_host_id   => i_payment_host_id
      , o_attr_present      => l_custom_attr_present
    );

    if l_custom_attr_present = com_api_const_pkg.TRUE then
        return l_custom_result;
    end if;

    begin
        select p.provider_id
             , c.product_id
             , c.id
             , cu.inst_id
          into l_provider_id
             , l_product_id
             , l_contract_id
             , l_inst_id
          from pmo_purpose p
             , prd_customer cu
             , prd_contract c
         where p.id               = i_purpose_id
           and cu.ext_entity_type = prd_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER
           and cu.ext_object_id   = p.provider_id
           and c.id               = cu.contract_id
           and c.contract_type    = prd_api_const_pkg.CONTRACT_TYPE_SERVICE_PROVIDER;
    exception
        when no_data_found then
            return com_api_const_pkg.TRUE;
    end;

    l_params.delete();

    rul_api_param_pkg.set_param (
        i_value   => i_payment_host_id
      , i_name    => 'PAYMENT_HOST_ID'
      , io_params => l_params
    );

    rul_api_param_pkg.set_param (
        i_value   => i_purpose_id
      , i_name    => 'PURPOSE_ID'
      , io_params => l_params
    );

    l_min_fee_id := prd_api_product_pkg.get_fee_id (
        i_product_id   => l_product_id
      , i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
      , i_object_id    => l_contract_id
      , i_fee_type     => pmo_api_const_pkg.FEE_TYPE_MIN_PAYMENT
      , i_params       => l_params
      , i_eff_date     => get_sysdate
      , i_inst_id      => l_inst_id
    );

    l_min_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id          => l_min_fee_id
          , i_base_amount     => 0
          , i_base_count      => 1
          , io_base_currency  => l_currency
          , i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
          , i_object_id       => l_contract_id
          , i_eff_date        => get_sysdate
          , i_calc_period     => 1
        );

    l_max_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id   => l_product_id
          , i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
          , i_object_id    => l_contract_id
          , i_fee_type     => pmo_api_const_pkg.FEE_TYPE_MAX_PAYMENT
          , i_params       => l_params
          , i_eff_date     => get_sysdate
          , i_inst_id      => l_inst_id
        );

    l_max_amount :=
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id          => l_max_fee_id
          , i_base_amount     => 0
          , i_base_count      => 1
          , io_base_currency  => l_currency
          , i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
          , i_object_id       => l_contract_id
          , i_eff_date        => get_sysdate
          , i_calc_period     => 1
        );

    if l_currency != i_currency then

        begin
            select rate_type
              into l_rate_type
              from fcl_fee_rate
             where fee_type = pmo_api_const_pkg.FEE_TYPE_MAX_PAYMENT
               and inst_id  = l_inst_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error        => 'FEE_RATE_TYPE_NOT_FOUND'
                    , i_env_param1 => pmo_api_const_pkg.FEE_TYPE_MAX_PAYMENT
                    , i_env_param2 => l_inst_id
                );
        end;

        l_amount :=
            com_api_rate_pkg.convert_amount(
                i_src_amount        => i_amount
                , i_src_currency    => i_currency
                , i_dst_currency    => l_currency
                , i_rate_type       => l_rate_type
                , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
                , i_inst_id         => l_inst_id
                , i_eff_date        => get_sysdate
            );
    else
        l_amount := i_amount;
    end if;

    trc_log_pkg.debug('check_min_max_amount: l_amount='||l_amount||', l_min_amount='||l_min_amount||', l_max_amount='||l_max_amount);

    return case when l_amount between l_min_amount and l_max_amount
                then com_api_const_pkg.TRUE
                else com_api_const_pkg.FALSE
           end;

end;

procedure choose_host(
    i_purpose_id         in     com_api_type_pkg.t_short_id
  , i_network_id         in     com_api_type_pkg.t_tiny_id    default null
  , i_host_prev          in     com_api_type_pkg.t_tiny_id    default null
  , i_change_reason      in     com_api_type_pkg.t_dict_value default null
  , i_original_id        in     com_api_type_pkg.t_long_id    default null
  , i_amount             in     com_api_type_pkg.t_money      default null
  , i_currency           in     com_api_type_pkg.t_curr_code  default null
  , i_choose_host_mode   in     com_api_type_pkg.t_dict_value
  , io_execution_type    in out com_api_type_pkg.t_dict_value
  , o_host_member_id        out com_api_type_pkg.t_tiny_id
  , o_host_next             out com_api_type_pkg.t_boolean
  , o_response_code         out com_api_type_pkg.t_dict_value
) is
    l_halt_seconds       com_api_type_pkg.t_long_id;
    l_host_prev          com_api_type_pkg.t_tiny_id := i_host_prev;
begin
    trc_log_pkg.debug('Choose host Start: i_host_prev='||l_host_prev||', i_change_reason='||i_change_reason||', i_choose_host_mode='||i_choose_host_mode);
    case i_choose_host_mode
        when pmo_api_const_pkg.CHOOSE_HOST_MODE_ALG then
            if l_host_prev is not null then
                if i_change_reason = net_api_const_pkg.STATUS_CHANGE_REASON_AGG then
                    net_api_host_pkg.get_host_param_value(
                        i_param_name     => 'AGG_HALT_TIME'
                      , i_host_member_id => l_host_prev
                      , o_param_value    => l_halt_seconds
                    );
                    if l_halt_seconds is not null then
                        update net_member
                          set inactive_till = get_sysdate + l_halt_seconds/(60*60*24)
                        where id            = l_host_prev;
                        trc_log_pkg.debug('Choose host member inactive till updated: inactive_till='||to_char(get_sysdate + l_halt_seconds/(60*60*24), 'dd.mm.yyyy hh24:mi:ss'));
                    end if;
                elsif i_change_reason = net_api_const_pkg.STATUS_CHANGE_REASON_PROV then
                    net_api_host_pkg.get_host_param_value(
                        i_param_name     => 'SRVPRV_HALT_TIME'
                      , i_host_member_id => l_host_prev
                      , o_param_value    => l_halt_seconds
                    );
                    if l_halt_seconds is not null then
                        update pmo_provider_host
                          set inactive_till  = get_sysdate + l_halt_seconds/(60*60*24)
                        where host_member_id = l_host_prev;
                        trc_log_pkg.debug('Choose host provider host inactive till updated: inactive_till='||to_char(get_sysdate + l_halt_seconds/(60*60*24), 'dd.mm.yyyy hh24:mi:ss'));
                    end if;
                elsif i_change_reason = net_api_const_pkg.STATUS_CHANGE_REASON_SRV then
                    null;
                end if;
            end if;

            for rec in (
                select a.host_algorithm
                     , a.provider_id
                  from pmo_purpose_vw a
                 where a.id = i_purpose_id
            ) loop
                while nvl(o_host_next, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                     and o_host_member_id is null
                loop
                    case rec.host_algorithm
                    when pmo_api_const_pkg.PAYMENT_HOST_ALG_PRIORITY
                    then choose_host_by_priority(
                             i_provider_id      => rec.provider_id
                           , i_network_id       => i_network_id
                           , i_host_prev        => l_host_prev
                           , o_host_member_id   => o_host_member_id
                           , io_execution_type  => io_execution_type
                           , o_host_next        => o_host_next
                           , o_responce_code    => o_response_code
                         );
                         trc_log_pkg.debug('Choose host: host found [' || o_host_member_id ||']');
                    else o_response_code := pmo_api_const_pkg.SERVICE_NOT_ALLOWED;
                         trc_log_pkg.debug('Choose host: host not found ');
                    end case;

                    if o_host_member_id is not null then
                        if check_min_max_amount(
                               i_amount             => i_amount
                             , i_currency           => i_currency
                             , i_purpose_id         => i_purpose_id
                             , i_payment_host_id    => o_host_member_id
                           ) = com_api_const_pkg.FALSE
                        then
                            l_host_prev := o_host_member_id;
                            o_host_member_id := null;
                        end if;
                    else
                        o_host_next := com_api_const_pkg.FALSE;
                    end if;
                end loop;
            end loop;

        when pmo_api_const_pkg.CHOOSE_HOST_MODE_HOST then
            begin
                select
                    o.payment_host_id
                into
                    o_host_member_id
                from
                    opr_operation o
                where
                    o.id = i_original_id;

                o_response_code := pmo_api_const_pkg.SUCCESSFUL_AUTHORIZATION;
            exception
                when no_data_found then
                    trc_log_pkg.debug('Choose host: original operation not found ' || i_original_id);
            end;

        else
            trc_log_pkg.debug('Choose host: choose host mode not supported ' || i_choose_host_mode);
    end case;

    if o_response_code is null then
        o_response_code :=  pmo_api_const_pkg.SERVICE_NOT_ALLOWED;
        trc_log_pkg.debug('Choose host: Purpose not found');
    end if;
    trc_log_pkg.debug('Choose host Finish: o_response_code='||o_response_code||', o_host_member_id='||o_host_member_id||', o_host_next='||o_host_next);
end;

procedure register_payment(
    i_purpose_id         in     com_api_type_pkg.t_short_id
  , i_auth_id            in     com_api_type_pkg.t_long_id
  , i_template_id        in     com_api_type_pkg.t_medium_id := null
  , o_order_id              out com_api_type_pkg.t_long_id
  , o_response_code         out com_api_type_pkg.t_dict_value
) is
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_entity_type           com_api_type_pkg.t_dict_value := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
    l_object_id             com_api_type_pkg.t_long_id;
    l_amount                com_api_type_pkg.t_money;
    l_currency              com_api_type_pkg.t_curr_code;
    l_event_date            date;
    l_status                com_api_type_pkg.t_dict_value := pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_attempt_count         com_api_type_pkg.t_tiny_id := 0;
    l_account_number        com_api_type_pkg.t_account_number;
begin
    -- check puspose
    for i1 in (
        select 1
          from pmo_purpose_vw a
         where a.id = i_purpose_id)
    loop
        trc_log_pkg.debug('Register payment: purpose found ' || i_purpose_id);
        begin
            select i.customer_id
                 , p.inst_id
                 , a.oper_amount
                 , a.oper_currency
                 , a.oper_date
                 , i.account_number
              into l_customer_id
                 , l_inst_id
                 , l_amount
                 , l_currency
                 , l_event_date
                 , l_account_number
              from opr_operation a
                 , opr_participant p
                 , opr_participant i
             where a.id = i_auth_id
               and p.oper_id = a.id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and i.oper_id = a.id
               and i.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;
        exception
            when no_data_found then
                trc_log_pkg.info('Register payment: customer not found!');
                o_response_code := pmo_api_const_pkg.CUSTOMER_NOT_FOUND;
        end;

        begin
            if l_account_number is not null then
                select b.id
                  into l_object_id
                  from acc_account b
                 where b.account_number = l_account_number;
            else
                select b.id
                  into l_object_id
                  from acc_account b
                 where b.customer_id = l_customer_id
                   and b.currency    = l_currency
                   and b.status     != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
                   and rownum = 1;
            end if;
        exception
            when no_data_found then
                trc_log_pkg.info('Register payment: Account not found!');
                o_response_code := pmo_api_const_pkg.ACCOUNT_NOT_FOUND;
        end;

        add_order(
            o_id                => o_order_id
          , i_customer_id       => l_customer_id
          , i_entity_type       => l_entity_type
          , i_object_id         => l_object_id
          , i_purpose_id        => i_purpose_id
          , i_template_id       => i_template_id
          , i_amount            => l_amount
          , i_currency          => l_currency
          , i_event_date        => l_event_date
          , i_status            => l_status
          , i_inst_id           => l_inst_id
          , i_attempt_count     => l_attempt_count
          , i_is_prepared_order => com_api_type_pkg.FALSE
          , i_expiration_date   => null
        );

        if o_response_code is null then
            o_response_code := pmo_api_const_pkg.SUCCESSFUL_AUTHORIZATION;
        end if;

    end loop;

    if o_response_code is null then
        o_response_code := pmo_api_const_pkg.CHANNEL_NOT_AVAILABLE;
        trc_log_pkg.debug('Register payment: purpose not found '|| i_purpose_id);
    end if;

end register_payment;

procedure register_payment_parameter_web(
    i_order_id          in      com_api_type_pkg.t_long_id
  , i_purpose_id        in      com_api_type_pkg.t_short_id         default null
  , i_params            in      com_param_map_tpt
) is
begin
    trc_log_pkg.debug('i_order_id='||i_order_id||', i_params.count='||nvl(i_params.count, 0));

    if nvl(i_params.count, 0)>0 then
        for rec in (
            select name, char_value , number_value, date_value, condition
              from table(cast(i_params as com_param_map_tpt)) x
        ) loop
            trc_log_pkg.debug('name='||rec.name||', char_value='||rec.char_value
            ||', number_value='||rec.number_value
            ||', date_value='||rec.date_value
            ||', condition='||rec.condition);
        end loop;
    end if;

    for rec in (
        select p.id         as param_id
             , nvl(x.char_value, pp.default_value) as param_value
             , p.pattern
             , p.param_name
             , p.data_type
             , u.id         as purpose_id
             , s.direction
          from pmo_order o
             , pmo_purpose_parameter pp
             , pmo_parameter p
             , pmo_service s
             , table(cast(i_params as com_param_map_tpt)) x
             , pmo_purpose   u
         where o.id          = i_order_id
           and u.id          = nvl(i_purpose_id, o.purpose_id)
           and pp.param_id   = p.id
           and x.name(+)     = p.param_name
           and u.id          = pp.purpose_id
           and u.service_id  = s.id
    ) loop
        trc_log_pkg.debug('id='||rec.param_id||', param_name='||rec.param_name||', value='||rec.param_value);

        if rec.pattern is not null and not regexp_like(replace(rec.param_value, chr(10)), rec.pattern) then
            com_api_error_pkg.raise_error(
                i_error         => 'INCORRECT_PAYMENT_ORDER_PARAM_VALUE'
              , i_env_param1    => rec.param_name
              , i_env_param2    => rec.pattern
              , i_env_param3    => rec.param_value
            );
        end if;

        insert into pmo_order_data(
            id
          , order_id
          , param_id
          , param_value
          , purpose_id
          , direction
        ) values (
            to_number(substr(to_char(i_order_id),1,6)||lpad(pmo_order_data_seq.nextval,10,'0'))
          , i_order_id
          , rec.param_id
          , decode(rec.data_type, com_api_const_pkg.DATA_TYPE_NUMBER
                 , to_char(to_number(rec.param_value, get_number_format))
                 , rec.param_value)
          , rec.purpose_id
          , rec.direction
        );

    end loop;

end;

procedure register_payment_parameter(
    i_order_id          in      com_api_type_pkg.t_long_id
  , i_purpose_id        in      com_api_type_pkg.t_short_id         default null
  , i_param_id_tab      in      com_api_type_pkg.t_number_tab
  , i_param_val_tab     in      com_api_type_pkg.t_desc_tab
) is
begin
    for rec in (
        select a.id
             , p.id as purpose_id
             , s.direction
          from pmo_order a
             , pmo_purpose p
             , pmo_service s
         where a.id = i_order_id
           and p.id = nvl(i_purpose_id, a.purpose_id)
           and s.id = p.service_id
    ) loop
        forall i in 1 .. i_param_id_tab.count
            insert into pmo_order_data(
                id
              , order_id
              , param_id
              , param_value
              , purpose_id
              , direction
            ) values (
                to_number(substr(to_char(rec.id),1,6)||lpad(pmo_order_data_seq.nextval,10,'0'))
              , rec.id
              , i_param_id_tab(i)
              , i_param_val_tab(i)
              , rec.purpose_id
              , rec.direction
            );

        insert into pmo_order_data(
            id
          , order_id
          , param_id
          , param_value
          , purpose_id
          , direction
        )
        select to_number(substr(to_char(rec.id),1,6)||lpad(pmo_order_data_seq.nextval,10,'0'))
             , rec.id
             , a.param_id
             , a.default_value
             , rec.purpose_id
             , rec.direction
          from pmo_purpose_parameter a
         where purpose_id     = rec.purpose_id
           and default_value is not null
           and not exists (
                       select 1
                         from pmo_order_data b
                        where a.param_id = b.param_id
                          and b.order_id = rec.id
                   );

    end loop;

end register_payment_parameter;

procedure add_order_detail (
    i_order_id              in com_api_type_pkg.t_long_id
  , i_entity_type           in com_api_type_pkg.t_dict_value
  , i_object_id             in com_api_type_pkg.t_long_id
) is
begin
    insert into pmo_order_detail_vw (
        id
      , order_id
      , entity_type
      , object_id
    ) values (
        to_number(substr(to_char(i_order_id),1,6)||lpad(pmo_order_detail_seq.nextval,10,'0'))
      , i_order_id
      , i_entity_type
      , i_object_id
    );
end;

procedure process_prepared_orders (
    i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_event_date            in     date
  , i_template_id           in     com_api_type_pkg.t_medium_id
  , o_id                       out com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug (
        i_text        => 'Going to update prepared payment orders [#1][#2][#3]'
      , i_env_param1  => i_customer_id
      , i_env_param2  => i_purpose_id
      , i_env_param3  => i_template_id
    );

    update pmo_order b
       set b.template_id = i_template_id
         , b.event_date = i_event_date
         , b.status = pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
     where b.id in (
            select id
              from pmo_order
             where status      = pmo_api_const_pkg.PMO_STATUS_PREPARATION
               and event_date <= i_event_date
               and customer_id = i_customer_id
               and purpose_id  = i_purpose_id
        )
    returning b.id
    bulk collect into o_id;

    trc_log_pkg.debug (
        i_text          => '[#1] payment orders updated'
      , i_env_param1    => sql%rowcount
    );
end;

procedure post_orders (
    i_orders                in pmo_api_type_pkg.t_payment_order_tab
) is
begin
    trc_log_pkg.debug (
        i_text          => 'Going to flush [#1] payment orders'
      , i_env_param1    => i_orders.count
    );

    forall i in 1 .. i_orders.count
        insert into pmo_order (
            id
          , customer_id
          , entity_type
          , object_id
          , purpose_id
          , template_id
          , amount
          , currency
          , event_date
          , status
          , inst_id
          , attempt_count
          , split_hash
          , payment_order_number
        ) values (
            i_orders(i).id
          , i_orders(i).customer_id
          , i_orders(i).entity_type
          , i_orders(i).object_id
          , i_orders(i).purpose_id
          , i_orders(i).template_id
          , i_orders(i).amount
          , i_orders(i).currency
          , i_orders(i).event_date
          , i_orders(i).status
          , i_orders(i).inst_id
          , i_orders(i).attempt_count
          , i_orders(i).split_hash
          , i_orders(i).payment_order_number
        );

    trc_log_pkg.debug (
        i_text          => '[#1] payment orders saved'
      , i_env_param1    => sql%rowcount
    );
exception
    when com_api_error_pkg.e_dml_errors then
        for i in 1..sql%bulk_exceptions.count loop
            com_api_error_pkg.raise_error (
                i_error         => 'PAYMENT_ORDER_NUMBER_NOT_UNIQUE'
              , i_env_param1    => i_orders(i).payment_order_number
            );
        end loop;
end;

procedure post_orders_data (
    i_id          in      com_api_type_pkg.t_number_tab
  , i_template    in      com_api_type_pkg.t_number_tab
) is
begin
    trc_log_pkg.debug (
        i_text          => 'Going to flush [#1] payment order data'
      , i_env_param1    => i_id.count
    );

    -- remove old data
    forall i in 1..i_id.count
        delete from pmo_order_data
         where order_id = i_id(i);

    -- add new data
    forall i in 1..i_id.count
        insert into pmo_order_data (
            id
          , order_id
          , param_id
          , param_value
          , purpose_id
          , direction
        )
        select to_number(substr(to_char(i_id(i)),1,6)||lpad(pmo_order_data_seq.nextval,10,'0'))
             , i_id(i)
             , t.param_id
             , t.param_value
             , t.purpose_id
             , t.direction
          from pmo_order_data t
         where t.order_id = i_template(i);

    trc_log_pkg.debug (
        i_text          => '[#1] payment order data saved'
      , i_env_param1    => sql%rowcount
    );
end;

procedure register_payment (
    i_event_type      in     com_api_type_pkg.t_dict_value
  , i_entity_type     in     com_api_type_pkg.t_dict_value
  , i_object_id       in     com_api_type_pkg.t_long_id
  , i_event_date      in     date
) is
    l_order_tab             pmo_api_type_pkg.t_payment_order_tab;
    j                       binary_integer;

    l_schedule_id           com_api_type_pkg.t_number_tab;
    l_template_id           com_api_type_pkg.t_number_tab;
    l_attempt_limit         com_api_type_pkg.t_number_tab;
    l_amount_algorithm      com_api_type_pkg.t_dict_tab;
    l_customer_id           com_api_type_pkg.t_number_tab;
    l_purpose_id            com_api_type_pkg.t_number_tab;
    l_is_prepared_order     com_api_type_pkg.t_boolean_tab;
    l_inst_id               com_api_type_pkg.t_inst_id_tab;

    l_id                    com_api_type_pkg.t_number_tab;
    l_template              com_api_type_pkg.t_number_tab;
    l_succ_id               com_api_type_pkg.t_number_tab;

    l_params                com_api_type_pkg.t_param_tab;

    cursor l_schedules is
    select s.id
         , s.order_id
         , s.attempt_limit
         , s.amount_algorithm
         , t.customer_id
         , t.purpose_id
         , t.is_prepared_order
         , t.inst_id
      from pmo_schedule_vw s
         , pmo_order_vw t
     where s.event_type  = i_event_type
       and s.entity_type = i_entity_type
       and s.object_id   = i_object_id
       and t.id          = s.order_id
       and t.is_template = 1
     order by t.is_prepared_order;
begin
    open l_schedules;
    loop
        fetch l_schedules
        bulk collect into
            l_schedule_id
          , l_template_id
          , l_attempt_limit
          , l_amount_algorithm
          , l_customer_id
          , l_purpose_id
          , l_is_prepared_order
          , l_inst_id
        limit BULK_LIMIT;

        for i in 1 .. l_schedule_id.count loop
            if l_is_prepared_order(i) = com_api_type_pkg.TRUE then
                process_prepared_orders (
                    i_customer_id  => l_customer_id(i)
                  , i_purpose_id   => l_purpose_id(i)
                  , i_event_date   => i_event_date
                  , i_template_id  => l_template_id(i)
                  , o_id           => l_succ_id
                );

                --
                for k in 1 .. l_succ_id.count loop
                    l_id(l_id.count + 1) := l_succ_id(k);
                    l_template(l_template.count + 1) := l_template_id(i);
                end loop;

            else
                j                          := l_order_tab.count + 1;

                l_order_tab(j).id          := com_api_id_pkg.get_id(pmo_order_seq.nextval, i_event_date);
                l_order_tab(j).customer_id := l_customer_id(i);
                l_order_tab(j).entity_type := i_entity_type;
                l_order_tab(j).object_id   := i_object_id;
                l_order_tab(j).purpose_id  := l_purpose_id(i);
                l_order_tab(j).template_id := l_template_id(i);
                case l_amount_algorithm(i)
                    when 'POAA....' then
                        null;
                    else
                        null;
                end case;
                l_order_tab(j).amount            := null;
                l_order_tab(j).currency          := null;
                l_order_tab(j).event_date        := i_event_date;
                l_order_tab(j).status            := pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC;
                l_order_tab(j).inst_id           := l_inst_id(i);
                l_order_tab(j).attempt_count     := l_attempt_limit(i);
                l_order_tab(j).split_hash        := com_api_hash_pkg.get_split_hash(prd_api_const_pkg.ENTITY_TYPE_CUSTOMER, l_customer_id(i));

                rul_api_param_pkg.set_param (
                    i_value   => l_order_tab(j).id
                  , i_name    => 'PAYMENT_ORDER_ID'
                  , io_params => l_params
                );

                l_order_tab(j).payment_order_number := rul_api_name_pkg.get_name (
                        i_inst_id             => l_order_tab(j).inst_id
                      , i_entity_type         => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                      , i_param_tab           => l_params
                      , i_double_check_value  => null
                    );

                l_id(l_id.count + 1)             := l_order_tab(j).id;
                l_template(l_template.count + 1) := l_order_tab(j).template_id;
            end if;
        end loop;

        exit when l_schedules%notfound;
    end loop;
    close l_schedules;

    post_orders (
        i_orders  => l_order_tab
    );

    post_orders_data (
        i_id        => l_id
      , i_template  => l_template
    );

exception
    when others then
        if l_schedules%isopen then
            close l_schedules;
        end if;
end;

function get_order_data_value(
    i_order_id      in      com_api_type_pkg.t_long_id
  , i_param_name    in      com_api_type_pkg. t_name
  , i_direction     in      com_api_type_pkg.t_sign                 default null
) return com_api_type_pkg.t_param_value is
    l_result com_api_type_pkg.t_param_value;
begin
    select min(param_value)
      into l_result
      from pmo_order_data d
         , pmo_parameter p
     where d.order_id   = i_order_id
       and d.param_id   = p.id
       and p.param_name = i_param_name
       and nvl(i_direction, d.direction) = d.direction;

    return l_result;
end;

procedure add_schedule(
    o_id                     out com_api_type_pkg.t_long_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_order_id            in     com_api_type_pkg.t_long_id
  , i_event_type          in     com_api_type_pkg.t_dict_value
  , i_amount_algorithm    in     com_api_type_pkg.t_dict_value
  , i_entity_type         in     com_api_type_pkg.t_dict_value default null
  , i_object_id           in     com_api_type_pkg.t_long_id    default null
  , i_attempt_limit       in     com_api_type_pkg.t_tiny_id    default null
  , i_cycle_id            in     com_api_type_pkg.t_long_id    default null
) is
begin
    o_id := com_api_id_pkg.get_id(pmo_schedule_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
    o_seqnum := 1;

    insert into pmo_schedule_vw(
        id
      , seqnum
      , order_id
      , event_type
      , entity_type
      , object_id
      , attempt_limit
      , amount_algorithm
      , cycle_id
    ) values (
        o_id
      , o_seqnum
      , i_order_id
      , i_event_type
      , i_entity_type
      , i_object_id
      , i_attempt_limit
      , i_amount_algorithm
      , i_cycle_id
    );

end add_schedule;

procedure modify_schedule(
    i_id                    in      com_api_type_pkg.t_medium_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_amount_algorithm      in      com_api_type_pkg.t_dict_value   default null
  , i_attempt_limit         in      com_api_type_pkg.t_tiny_id      default null
  , i_cycle_id              in      com_api_type_pkg.t_long_id      default null
  , i_event_type            in      com_api_type_pkg.t_dict_value   default null
) is
begin
    update pmo_schedule_vw
       set seqnum           = io_seqnum
         , amount_algorithm = i_amount_algorithm
         , attempt_limit    = i_attempt_limit
         , cycle_id         = i_cycle_id
         , event_type       = i_event_type
     where id = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure add_order_data(
    i_order_id           in     com_api_type_pkg.t_long_id
  , i_param_name         in     com_api_type_pkg.t_name
  , i_param_value        in     com_api_type_pkg.t_param_value
  , i_purpose_id         in     com_api_type_pkg.t_short_id     default null
) is
begin
    merge into pmo_order_data_vw a
      using (select i_order_id    as order_id
                  , p.id          as param_id
                  , i_param_value as param_value
                  , u.id          as purpose_id
                  , s.direction
               from pmo_parameter         p
                  , pmo_purpose_parameter t
                  , pmo_purpose           u
                  , pmo_order             o
                  , pmo_service           s
              where p.param_name = upper(i_param_name)
                and p.id         = t.param_id
                and t.purpose_id = nvl(i_purpose_id, o.purpose_id)
                and o.id         = i_order_id
                and u.service_id = s.id
                and t.purpose_id = u.id
             ) b
       on (a.param_id = b.param_id and a.order_id = b.order_id and a.purpose_id = b.purpose_id and a.direction = b.direction)
    when matched then
    update set param_value = b.param_value
    when not matched then
    insert (
        id
      , order_id
      , param_id
      , param_value
      , purpose_id
      , direction
    ) values (
        com_api_id_pkg.get_id(pmo_order_data_seq.nextval)
      , b.order_id
      , b.param_id
      , b.param_value
      , b.purpose_id
      , b.direction
    );
end;

procedure set_order_status(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value
) is
begin
    update pmo_order
       set status = i_status
     where id = i_order_id
       and status not in (pmo_api_const_pkg.PMO_STATUS_CANCELED, pmo_api_const_pkg.PMO_STATUS_PROCESSED);
end;

procedure set_attempt_count(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_attempt_count         in      com_api_type_pkg.t_tiny_id
) is
begin
    update pmo_order
       set attempt_count = i_attempt_count
     where id = i_order_id;
end;

procedure set_order_amount(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_amount_rec            in      com_api_type_pkg.t_amount_rec
) is
begin
    update pmo_order
       set amount   = i_amount_rec.amount
         , currency = i_amount_rec.currency
     where id = i_order_id;
end;

procedure get_own_template(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , o_template_tab             out  com_api_type_pkg.t_auth_long_tab
  , o_template_name_tab        out  com_api_type_pkg.t_name_tab
) is
begin
    select to_char(o.id) template_id
         , get_text (
             i_table_name  => 'pmo_order'
           , i_column_name => 'label'
           , i_object_id   => o.id
           , i_lang        => i_lang
         ) template_name
      bulk collect into
           o_template_tab
         , o_template_name_tab
      from opr_participant p
         , pmo_order o
     where p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and p.oper_id = i_auth_id
       and o.customer_id = p.customer_id
       and o.purpose_id = i_purpose_id
       and o.is_template = 1;
end;

procedure set_order_purpose (
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_direction             in      com_api_type_pkg.t_sign         default null
) is
begin

    if nvl(i_direction, com_api_const_pkg.DEBIT) = com_api_const_pkg.DEBIT then
        update  pmo_order_vw
           set  purpose_id = nvl(purpose_id, i_purpose_id)
         where  id = i_order_id;
    else
        update  pmo_order_vw
           set  in_purpose_id = nvl(in_purpose_id, i_purpose_id)
         where  id = i_order_id;
    end if;
end;

procedure calc_order_amount(
    i_amount_algorithm      in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date
  , i_template_id           in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_original_order_rec    in      pmo_api_type_pkg.t_payment_order_rec    default null
  , i_order_id              in      com_api_type_pkg.t_long_id
  , io_amount               in out  com_api_type_pkg.t_amount_rec
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.calc_order_amount: ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'start i_amount_algorithm [#1], i_entity_type [#2], i_object_id [#3], i_template_id [#4]'
      , i_env_param1 => i_amount_algorithm
      , i_env_param2 => i_entity_type
      , i_env_param3 => i_object_id
      , i_env_param4 => i_template_id
    );
    case i_amount_algorithm
        when pmo_api_const_pkg.PMO_AMOUNT_ALGO_IMCOMING then
            null;

        when pmo_api_const_pkg.PMO_AMOUNT_ALGO_MAD then

            pmo_api_algo_proc_pkg.calc_order_amount_mad(
                i_account_id    => i_object_id
              , i_split_hash    => i_split_hash
              , o_amount        => io_amount
            );
        when pmo_api_const_pkg.PMO_AMOUNT_ALGO_TAD then

            pmo_api_algo_proc_pkg.calc_order_amount_tad(
                i_account_id    => i_object_id
              , i_split_hash    => i_split_hash
              , o_amount        => io_amount
            );

        when pmo_api_const_pkg.PMO_AMOUNT_ALGO_TAD_OVD_MAD then

            pmo_api_algo_proc_pkg.calc_order_amount_tad_ovd_mad(
                i_account_id    => i_object_id
              , i_split_hash    => i_split_hash
              , i_eff_date      => i_eff_date
              , o_amount        => io_amount
            );

        when pmo_api_const_pkg.PMO_AMOUNT_ALGO_TAD_PCT then

            pmo_api_algo_proc_pkg.calc_direct_debit_amount(
                i_object_id     => i_object_id
              , i_entity_type   => i_entity_type
              , i_split_hash    => i_split_hash
              , i_eff_date      => i_eff_date
              , o_amount        => io_amount
            );

        when pmo_api_const_pkg.PMO_AMOUNT_ALGO_FIXED then

            calc_order_amount_fixed(
              i_customer_id     => i_object_id
              , i_template_id   => i_template_id
              , i_split_hash    => i_split_hash
              , io_amount       => io_amount
            );

        when pmo_api_const_pkg.PMO_AMOUNT_ALGO_REMAIN_AMOUNT then

            pmo_api_algo_proc_pkg.calc_original_order_amount(
                i_original_order_rec    => i_original_order_rec
              , io_amount               => io_amount
            );

        else
            -- if new algorithm procedure exists then run it, else run old user-exit.
            if rul_api_algorithm_pkg.check_algorithm_exists(
                    i_algorithm             => i_amount_algorithm
                ) = com_api_type_pkg.TRUE then

                pmo_api_algo_proc_pkg.process_amount_algorithm(
                    i_amount_algorithm      => i_amount_algorithm
                  , i_entity_type           => i_entity_type
                  , i_object_id             => i_object_id
                  , i_eff_date              => i_eff_date
                  , i_template_id           => i_template_id
                  , i_split_hash            => i_split_hash
                  , i_order_id              => i_order_id
                  , io_amount               => io_amount
                );

            else
                cst_api_order_pkg.calc_order_amount(
                    i_amount_algorithm      => i_amount_algorithm
                  , i_entity_type           => i_entity_type
                  , i_object_id             => i_object_id
                  , i_eff_date              => i_eff_date
                  , i_template_id           => i_template_id
                  , i_split_hash            => i_split_hash
                  , io_amount               => io_amount
                );
            end if;
    end case;

    trc_log_pkg.debug(
        LOG_PREFIX
        || ' calculated amount value = ' || io_amount.amount
        || ', currency = ' || io_amount.currency
        || ', amount algorithm = '
        || i_amount_algorithm
    );

end;

procedure calc_order_amount_fixed(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_template_id           in      com_api_type_pkg.t_long_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , io_amount               in out  com_api_type_pkg.t_amount_rec
) is
begin
    select amount
         , currency
      into io_amount.amount
         , io_amount.currency
      from pmo_order
     where id = i_template_id;
exception
    when no_data_found then
        null;
end calc_order_amount_fixed;

procedure get_order_list(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_status                in     com_api_type_pkg.t_dict_value
  , i_service_provider_id   in     com_api_type_pkg.t_short_id default null
  , o_order_list               out sys_refcursor
) is

    l_sysdate       date;
begin
    trc_log_pkg.debug('pmo_api_order_pkg.get_order_list - started.');

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    open o_order_list for
        select o.id
             , o.split_hash
             , o.customer_id
             , c.customer_number
             , o.amount
             , o.currency
             , o.inst_id
             , o.event_date
             , o.entity_type
             , o.object_id
             , o.purpose_id
          from pmo_order o
             , prd_customer c
             , pmo_purpose p
         where (o.inst_id     = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and (o.purpose_id  = i_purpose_id or i_purpose_id is null)
           and decode(o.status, 'POSA0001', o.status, null) = i_status
           and o.customer_id  = c.id
           and o.amount       > 0
           and o.event_date  <= l_sysdate
           and p.id           = o.purpose_id
           and (p.provider_id = i_service_provider_id or i_service_provider_id is null)
         order by o.id;

    trc_log_pkg.debug('pmo_api_order_pkg.get_order_list - end.');
exception
    when no_data_found then
        null;
end get_order_list;

procedure get_order_list_count(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_status                in     com_api_type_pkg.t_dict_value
  , i_service_provider_id   in     com_api_type_pkg.t_short_id default null
  , o_order_list_count         out com_api_type_pkg.t_long_id
) is

    l_sysdate       date;

    cursor cu_order_count is
        select count(1)
          from pmo_order o
             , prd_customer c
             , pmo_purpose p
         where (o.inst_id     = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and (o.purpose_id  = i_purpose_id or i_purpose_id is null)
           and decode(o.status, 'POSA0001', o.status, null) = i_status
           and o.customer_id  = c.id
           and o.amount       > 0
           and o.event_date    <= l_sysdate
           and p.id           = o.purpose_id
           and (p.provider_id = i_service_provider_id or i_service_provider_id is null);
begin
    trc_log_pkg.debug('pmo_api_order_pkg.get_order_list_count - started.');

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    open cu_order_count;
    fetch cu_order_count into o_order_list_count;
    close cu_order_count;

    o_order_list_count := coalesce(o_order_list_count, 0);

    trc_log_pkg.debug('pmo_api_order_pkg.get_order_list_count - end.');
end get_order_list_count;

procedure get_order_parameters(
    i_order_id              in      com_api_type_pkg.t_long_id
  , o_order_parameters          out sys_refcursor
) is
begin
    trc_log_pkg.debug('pmo_api_order_pkg.get_order_parameters - started.');

    open o_order_parameters for
        select p.param_name
             , d.param_value
          from pmo_order_data d
             , pmo_parameter p
         where d.order_id = i_order_id
           and d.param_id = p.id
         order by d.id;

    trc_log_pkg.debug('pmo_api_order_pkg.get_order_parameters - end.');
end get_order_parameters;

procedure get_order_evt_list(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_subscriber_name       in     com_api_type_pkg.t_name
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , o_order_evt_list           out sys_refcursor
) is

    l_sysdate                      date;
    l_subscriber_name              com_api_type_pkg.t_name;

begin
    trc_log_pkg.debug('pmo_api_order_pkg.get_order_evt_list - started.');

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    l_subscriber_name := upper(i_subscriber_name);

    open o_order_evt_list for
        select a.id
             , o.id as order_id
             , o.customer_id
             , o.entity_type
             , o.object_id
             , o.purpose_id
             , o.template_id
             , o.amount
             , o.currency
             , o.event_date
             , o.status
             , o.inst_id
             , o.attempt_count
             , o.split_hash
             , o.payment_order_number
             , c.customer_number
             , b.amount_algorithm
          from evt_event_object a
             , pmo_order        o
             , evt_event        e
             , prd_customer     c
             , pmo_schedule     b
         where decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
           and (o.purpose_id     = i_purpose_id or i_purpose_id is null)
           and o.inst_id         = i_inst_id
           and o.customer_id     = c.id
           and o.template_id     = b.order_id
           and a.object_id       = o.id
           and a.entity_type     = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and a.eff_date       <= l_sysdate
           and e.event_type      = i_event_type
           and a.event_id        = e.id
           and o.split_hash in (select split_hash from com_api_split_map_vw);

    trc_log_pkg.debug('pmo_api_order_pkg.get_order_evt_list - end.');
end get_order_evt_list;

procedure get_order_evt_list_count(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_subscriber_name       in     com_api_type_pkg.t_name
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_purpose_id            in     com_api_type_pkg.t_short_id
  , o_order_evt_list_count     out com_api_type_pkg.t_long_id
) is

    l_sysdate                      date;
    l_subscriber_name              com_api_type_pkg.t_name;

    cursor cu_event_objects_count is
        select count(1)
          from evt_event_object a
             , evt_event        e
             , pmo_order        o
             , prd_customer     c
             , pmo_schedule     b
         where decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
           and (o.purpose_id     = i_purpose_id or i_purpose_id is null)
           and o.inst_id         = i_inst_id
           and o.customer_id     = c.id
           and o.template_id     = b.order_id
           and a.object_id       = o.id
           and a.entity_type     = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and a.eff_date       <= l_sysdate
           and e.event_type      = i_event_type
           and a.event_id        = e.id
           and o.split_hash in (select split_hash from com_api_split_map_vw);
begin
    trc_log_pkg.debug('pmo_api_order_pkg.get_order_evt_list_count - started.');

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    l_subscriber_name := upper(i_subscriber_name);

    open cu_event_objects_count;
    fetch cu_event_objects_count into o_order_evt_list_count;
    close cu_event_objects_count;

    o_order_evt_list_count := coalesce(o_order_evt_list_count, 0);

    trc_log_pkg.debug('pmo_api_order_pkg.get_order_evt_list_count - end.');
end get_order_evt_list_count;

function get_order(
    i_order_id          in   com_api_type_pkg.t_long_id
  , i_mask_error        in   com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
)
return pmo_api_type_pkg.t_payment_order_rec
is
    LOG_PREFIX      constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.get_order: ';
    l_order                  pmo_api_type_pkg.t_payment_order_rec;
begin
    trc_log_pkg.debug(
        i_text       => 'get_order: order id [#1] mask [#2]'
      , i_env_param1 => i_order_id
      , i_env_param2 => i_mask_error
    );
    select id
         , customer_id
         , entity_type
         , object_id
         , purpose_id
         , template_id
         , amount
         , currency
         , event_date
         , status
         , inst_id
         , attempt_count
         , split_hash
         , payment_order_number
         , expiration_date
         , resp_code
         , resp_amount
         , originator_refnum
      into l_order
      from pmo_order o
     where o.id = i_order_id;

    return l_order;
exception
    when no_data_found then
       if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'Payment order id [#1]'
              , i_env_param1 => i_order_id
            );
       else
            com_api_error_pkg.raise_error(
                i_error      => 'PAYMENT_ORDER_NOT_FOUND'
              , i_env_param1 => i_order_id
            );
       end if;
       return null;
end get_order;

procedure perform_pmo_retry(
    i_order_rec         in      pmo_api_type_pkg.t_payment_order_rec
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.perform_pmo_retry: ';
    l_eff_date                  date;
    l_next_date                 date;
    l_event_type                com_api_type_pkg.t_dict_value;
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_object_id                 com_api_type_pkg.t_long_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_service_id                com_api_type_pkg.t_short_id;
    l_invoice_id                com_api_type_pkg.t_medium_id;
    l_cycle_id                  com_api_type_pkg.t_short_id;
    l_product_id                com_api_type_pkg.t_short_id;
begin
    if i_order_rec.entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD
                                 , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                 , prd_api_const_pkg.ENTITY_TYPE_CUSTOMER)
    then
        l_event_type :=
            case i_order_rec.entity_type
            when iss_api_const_pkg.ENTITY_TYPE_CARD         then pmo_api_const_pkg.DIR_DEBIT_CYCLE_RETRY_CARD
            when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT      then pmo_api_const_pkg.DIR_DEBIT_CYCLE_RETRY_ACCOUNT
            when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER     then pmo_api_const_pkg.DIR_DEBIT_CYCLE_RETRY_CUSTOMER
            end;

        l_eff_date      := com_api_sttl_day_pkg.get_sysdate;
        l_entity_type   := pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER;
        l_object_id     := i_order_rec.id;
        l_split_hash    := i_order_rec.split_hash;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'event type [#1], object [#2], entity type [#3], eff. date [#4]'
          , i_env_param1 => l_event_type
          , i_env_param2 => l_object_id
          , i_env_param3 => l_entity_type
          , i_env_param4 => com_api_type_pkg.convert_to_char(l_eff_date)
        );

        rul_api_shared_data_pkg.load_payment_order_params(
            i_payment_order_id => i_order_rec.id
          , io_params          => l_param_tab
        );

        if i_order_rec.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            l_service_id :=
                crd_api_service_pkg.get_active_service(
                    i_account_id => i_order_rec.object_id
                  , i_eff_date   => l_eff_date
                  , i_split_hash => l_split_hash
                  , i_mask_error => com_api_const_pkg.TRUE
                );

            trc_log_pkg.debug(
                i_text       => 'load_invoice_params; credit service [#1] for account [#2]'
              , i_env_param1 => l_service_id
              , i_env_param2 => i_order_rec.object_id
            );

            if l_service_id is not null then
                l_invoice_id :=
                    crd_invoice_pkg.get_last_invoice(
                        i_entity_type => i_order_rec.entity_type
                      , i_object_id   => i_order_rec.object_id
                      , i_split_hash  => l_split_hash
                      , i_mask_error  => com_api_const_pkg.TRUE
                    ).id;
            end if;

            if l_invoice_id is not null then
                rul_api_shared_data_pkg.load_invoice_params(
                    i_invoice_id => l_invoice_id
                  , io_params    => l_param_tab
                );
            end if;
        end if;

        rul_api_param_pkg.set_param(
            i_name    => 'EVENT_DATE'
          , i_value   => l_eff_date
          , io_params => l_param_tab
        );

        l_product_id :=
            prd_api_product_pkg.get_product_id(
                i_entity_type => i_order_rec.entity_type
              , i_object_id   => i_order_rec.object_id
              , i_eff_date    => l_eff_date
              , i_inst_id     => i_order_rec.inst_id

            );

        l_cycle_id :=
            prd_api_product_pkg.get_attr_value_number(
                i_product_id        => l_product_id
              , i_entity_type       => i_order_rec.entity_type
              , i_object_id         => i_order_rec.object_id
              , i_attr_name         => prd_api_attribute_pkg.get_attr_name(i_object_type => l_event_type)
              , i_params            => l_param_tab
              , i_eff_date          => l_eff_date
              , i_split_hash        => l_split_hash
              , i_inst_id           => i_order_rec.inst_id
              , i_use_default_value => com_api_const_pkg.TRUE
              , i_default_value     => null
            );

        if l_cycle_id is not null then
            fcl_api_cycle_pkg.switch_cycle(
                i_cycle_type        => l_event_type
              , i_product_id        => l_product_id
              , i_entity_type       => l_entity_type
              , i_object_id         => l_object_id
              , i_params            => l_param_tab
              , i_start_date        => l_eff_date
              , i_eff_date          => l_eff_date
              , i_split_hash        => l_split_hash
              , i_inst_id           => i_order_rec.inst_id
              , o_new_finish_date   => l_next_date
              , i_test_mode         => fcl_api_const_pkg.ATTR_MISS_IGNORE
              , i_cycle_id          => l_cycle_id
            );
        end if;

        trc_log_pkg.debug(
            i_text       => 'l_cycle_id [#1]; l_next_date [#2]'
          , i_env_param1 => l_cycle_id
          , i_env_param2 => l_next_date
        );
    else
        trc_log_pkg.debug(
            i_text       => 'Perform_pmo_retry can''t be used for entity type [#1]'
          , i_env_param1 => i_order_rec.entity_type
        );
    end if;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end perform_pmo_retry;

procedure process_pmo_response(
    i_order_id              in      com_api_type_pkg.t_long_id
  , i_resp_code             in      com_api_type_pkg.t_dict_value
  , i_resp_amount_rec       in      com_api_type_pkg.t_amount_rec
) is
    l_order_rec                     pmo_api_type_pkg.t_payment_order_rec;
begin
    l_order_rec :=
        pmo_api_order_pkg.get_order(
            i_order_id          => i_order_id
        );

    update pmo_order o
       set o.resp_code      = i_resp_code
         , o.resp_amount    = i_resp_amount_rec.amount
         , o.status         = case i_resp_code
                              when pmo_api_const_pkg.PMO_RESPONSE_CODE_PROCESSED then
                                   pmo_api_const_pkg.PMO_STATUS_PROCESSED
                              else o.status end
     where o.id             = i_order_id;

    if    i_resp_code = pmo_api_const_pkg.PMO_RESPONSE_CODE_FAILED
       or (
               i_resp_code = pmo_api_const_pkg.PMO_RESPONSE_CODE_PROCESSED
           and i_resp_amount_rec.amount < l_order_rec.amount
          )
    then
        perform_pmo_retry(
            i_order_rec     => l_order_rec
        );
    end if;

    evt_api_event_pkg.register_event (
        i_event_type    => pmo_api_const_pkg.EVENT_TYPE_PMO_RESPONSE_LOADED
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
      , i_object_id     => i_order_id
      , i_inst_id       => l_order_rec.inst_id
      , i_split_hash    => com_api_hash_pkg.get_split_hash(pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER, i_order_id)
    );

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end process_pmo_response;

function check_is_pmo_expired(
    i_expiration_date   in      date
  , i_order_id          in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_tiny_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_boolean
is
    l_sysdate                   date                            := com_api_sttl_day_pkg.get_sysdate;
    l_event_type                com_api_type_pkg.t_dict_value;
begin
    if i_expiration_date is not null and i_expiration_date < l_sysdate then
        update pmo_order
           set status    = pmo_api_const_pkg.PMO_STATUS_CANCELED
             , resp_code = pmo_api_const_pkg.PMO_RESPONSE_CODE_EXPIRED
          where id       = i_order_id;

        l_event_type :=
            case i_entity_type
            when iss_api_const_pkg.ENTITY_TYPE_CARD     then pmo_api_const_pkg.EVENT_TYPE_PMO_EXPIRED_CARD
            when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT  then pmo_api_const_pkg.EVENT_TYPE_PMO_EXPIRED_ACC
            when com_api_const_pkg.ENTITY_TYPE_CUSTOMER then pmo_api_const_pkg.EVENT_TYPE_PMO_EXPIRED_CUST
            end;

        evt_api_event_pkg.register_event(
            i_event_type  => l_event_type
          , i_eff_date    => l_sysdate
          , i_entity_type => i_entity_type
          , i_object_id   => i_object_id
          , i_inst_id     => i_inst_id
          , i_split_hash  => i_split_hash
          , i_param_tab   => i_param_tab
          , i_status      => evt_api_const_pkg.EVENT_STATUS_READY
        );
        return com_api_const_pkg.TRUE;
    else
        return com_api_const_pkg.FALSE;
    end if;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end check_is_pmo_expired;

procedure add_order_with_params(
    io_payment_order_id     in out  com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_customer_id           in      com_api_type_pkg.t_medium_id default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_template_id           in      com_api_type_pkg.t_tiny_id
  , i_amount_rec            in      com_api_type_pkg.t_amount_rec
  , i_eff_date              in      date
  , i_order_status          in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_attempt_count         in      com_api_type_pkg.t_tiny_id
  , i_payment_order_number  in      com_api_type_pkg.t_name
  , i_expiration_date       in      date
  , i_register_event        in      com_api_type_pkg.t_boolean
  , i_is_prepared_order     in      com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
  , i_originator_refnum     in      com_api_type_pkg.t_rrn       default null
  , i_param_tab             in      com_api_type_pkg.t_param_tab
) is
    l_payment_order_id              com_api_type_pkg.t_long_id;
    l_payment_order_number          com_api_type_pkg.t_name;
    l_order_data_id                 com_api_type_pkg.t_long_id;
    l_param_id                      com_api_type_pkg.t_short_id;
    l_param_value                   com_api_type_pkg.t_param_value;
    l_cycle_type                    com_api_type_pkg.t_dict_value;
    l_expiration_date               date;

    l_acc_id                        com_api_type_pkg.t_long_id;
    l_param_tab                     com_api_type_pkg.t_param_tab := i_param_tab;
    l_direction                     com_api_type_pkg.t_sign;
begin

    trc_log_pkg.debug(
        i_text => 'add_order_with_params i_entity_type=' || i_entity_type || ' and i_object_id=' || i_object_id
    );

    io_payment_order_id := nvl(io_payment_order_id, com_api_id_pkg.get_id(pmo_order_seq.nextval, i_eff_date));

    if i_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD
                       , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       , prd_api_const_pkg.ENTITY_TYPE_CUSTOMER)
    then
        case i_entity_type
            when iss_api_const_pkg.ENTITY_TYPE_CARD then
                l_cycle_type := pmo_api_const_pkg.DIRECT_DEBIT_EXP_CARD_CYCLE;
            when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                l_cycle_type := pmo_api_const_pkg.DIRECT_DEBIT_EXP_ACC_CYCLE;
            when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                l_cycle_type := pmo_api_const_pkg.DIRECT_DEBIT_EXP_CUST_CYCLE;
        end case;

        l_expiration_date :=
            coalesce(
                i_expiration_date
              , fcl_api_cycle_pkg.calc_next_date(
                    i_cycle_type    => l_cycle_type
                  , i_entity_type   => i_entity_type
                  , i_object_id     => i_object_id
                  , i_split_hash    => i_split_hash
                  , i_eff_date      => i_eff_date
                  , i_inst_id       => i_inst_id
                  , i_raise_error   => com_api_type_pkg.FALSE
                )
            );
    end if;

    if i_payment_order_number is null then
        rul_api_param_pkg.set_param(
            i_value   => io_payment_order_id
          , i_name    => 'PAYMENT_ORDER_ID'
          , io_params => l_param_tab
        );

        l_payment_order_number :=
            rul_api_name_pkg.get_name(
                i_inst_id             => i_inst_id
              , i_entity_type         => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
              , i_param_tab           => l_param_tab
              , i_double_check_value  => null
            );
    else
        l_payment_order_number := i_payment_order_number;
    end if;
    trc_log_pkg.debug(
        i_text => 'l_payment_order_number=' || l_payment_order_number
    );

    begin
        insert into pmo_order(
            id
          , customer_id
          , entity_type
          , object_id
          , purpose_id
          , template_id
          , amount
          , currency
          , event_date
          , status
          , inst_id
          , attempt_count
          , split_hash
          , is_template
          , is_prepared_order
          , payment_order_number
          , expiration_date
          , originator_refnum
        ) values (
            io_payment_order_id
          , i_customer_id
          , i_entity_type
          , i_object_id
          , i_purpose_id
          , i_template_id
          , i_amount_rec.amount
          , i_amount_rec.currency
          , i_eff_date
          , coalesce(i_order_status, pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC)
          , i_inst_id
          , i_attempt_count
          , i_split_hash
          , com_api_const_pkg.FALSE
          , nvl(i_is_prepared_order, com_api_const_pkg.FALSE)
          , l_payment_order_number
          , l_expiration_date
          , i_originator_refnum
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error         => 'PAYMENT_ORDER_NUMBER_NOT_UNIQUE'
              , i_env_param1    => l_payment_order_number
            );
    end;

    select s.direction
      into l_direction
      from pmo_purpose p
         , pmo_service s
     where p.id = i_purpose_id
       and s.id = p.service_id;

    pmo_api_param_function_pkg.load_order_params(
        i_order_id  => io_payment_order_id
      , i_param_tab => l_param_tab
    );

    for c_cur in (
        select u.param_id
             , p.param_name
             , d.param_value
             , u.default_value
             , nvl(u.param_function, p.param_function) as param_function
          from pmo_purpose_parameter u
             , pmo_order o
             , pmo_order_data d
             , pmo_parameter p
         where o.id             = i_template_id
           and o.purpose_id     = u.purpose_id
           and u.param_id       = d.param_id(+)
           and p.id             = u.param_id
           and d.order_id(+)    = i_template_id
     ) loop
        trc_log_pkg.debug(
            i_text => 'param_function= [' || c_cur.param_function || ']'
        );
        
        l_order_data_id := to_number(substr(to_char(io_payment_order_id), 1, 6) || lpad(pmo_order_data_seq.nextval, 10, '0'));
        l_param_id      := c_cur.param_id;

        if c_cur.param_function is not null then
            execute immediate 'begin :l_param_value := ' || c_cur.param_function || '; end;'  using out l_param_value;
            l_param_value := nvl(l_param_value, c_cur.default_value);
        else
            l_param_value := nvl(c_cur.param_value, c_cur.default_value);
        end if;

        insert into pmo_order_data(
            id
          , order_id
          , param_id
          , param_value
          , purpose_id
          , direction
        ) values (
            l_order_data_id
          , io_payment_order_id
          , l_param_id
          , l_param_value
          , i_purpose_id
          , l_direction
        );

        trc_log_pkg.debug(
            i_text          => 'pmo_prc_schedule_pkg.process: template_id [#1], param_name [#2], param_id [#3], param_value [#4]'
          , i_env_param1    => i_template_id
          , i_env_param2    => c_cur.param_name
          , i_env_param3    => l_param_id
          , i_env_param4    => l_param_value
        );
    end loop;

    if i_register_event = com_api_const_pkg.TRUE then
        evt_api_event_pkg.register_event(
            i_event_type     => pmo_api_const_pkg.EVENT_TYPE_PAY_ORDER_CREATE
          , i_eff_date       => i_eff_date
          , i_entity_type    => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
          , i_object_id      => io_payment_order_id
          , i_inst_id        => i_inst_id
          , i_split_hash     => i_split_hash
          , i_param_tab      => l_param_tab
          , i_status         => null
        );
    end if;

    trc_log_pkg.debug(
        i_text          => 'Added payment order: id [#1], l_template_id [#2]'
      , i_env_param1    => io_payment_order_id
      , i_env_param2    => i_template_id
    );

end add_order_with_params;

procedure add_order_with_params(
    io_payment_order_id     in out  com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_customer_id           in      com_api_type_pkg.t_medium_id default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_template_id           in      com_api_type_pkg.t_tiny_id
  , i_oper_id_tab           in      com_api_type_pkg.t_long_tab
  , i_eff_date              in      date
  , i_order_status          in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_attempt_count         in      com_api_type_pkg.t_tiny_id
  , i_payment_order_number  in      com_api_type_pkg.t_name
  , i_expiration_date       in      date
  , i_register_event        in      com_api_type_pkg.t_boolean
  , i_is_prepared_order     in      com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
  , i_originator_refnum     in      com_api_type_pkg.t_rrn       default null
  , io_param_tab            in out nocopy com_api_type_pkg.t_param_tab
) is
    l_payment_order_algorithm       com_api_type_pkg.t_dict_value;
    l_amount_rec                    com_api_type_pkg.t_amount_rec;
begin

    io_payment_order_id := nvl(io_payment_order_id, com_api_id_pkg.get_id(pmo_order_seq.nextval, i_eff_date));

    opr_api_operation_pkg.link_payment_order(
        i_oper_id_tab      => i_oper_id_tab
      , i_payment_order_id => io_payment_order_id
      , i_mask_error       => com_api_const_pkg.FALSE
    );

    if i_purpose_id is not null then
        begin
            select amount_algorithm
              into l_payment_order_algorithm
              from pmo_purpose
             where id = i_purpose_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'PAYMENT_PURPOSE_NOT_FOUND'
                  , i_env_param1 => i_purpose_id
                );
        end;
    end if;

    calc_order_amount(
        i_amount_algorithm      => l_payment_order_algorithm
      , i_entity_type           => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
      , i_object_id             => io_payment_order_id
      , i_eff_date              => i_eff_date
      , i_template_id           => i_template_id
      , i_split_hash            => i_split_hash
      , i_original_order_rec    => null
      , i_order_id              => io_payment_order_id
      , io_amount               => l_amount_rec
    );

    pmo_api_order_pkg.add_order_with_params(
        io_payment_order_id     => io_payment_order_id
      , i_entity_type           => i_entity_type
      , i_object_id             => i_object_id
      , i_customer_id           => i_customer_id
      , i_split_hash            => i_split_hash
      , i_purpose_id            => i_purpose_id
      , i_template_id           => i_template_id
      , i_amount_rec            => l_amount_rec
      , i_eff_date              => i_eff_date
      , i_order_status          => nvl(i_order_status, pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC)
      , i_inst_id               => i_inst_id
      , i_attempt_count         => i_attempt_count
      , i_payment_order_number  => i_payment_order_number
      , i_expiration_date       => i_expiration_date
      , i_register_event        => i_register_event
      , i_is_prepared_order     => i_is_prepared_order
      , i_originator_refnum     => i_originator_refnum
      , i_param_tab             => io_param_tab
    );

end add_order_with_params;

function match_order_with_operation(
    i_originator_refnum     in      com_api_type_pkg.t_rrn
  , i_order_date            in      date
) return com_api_type_pkg.t_long_id
is
    l_order_id    com_api_type_pkg.t_long_id;
begin
    select id
      into l_order_id
      from opr_operation
     where originator_refnum = i_originator_refnum
       and oper_date         = i_order_date;

    return l_order_id;
exception
    when no_data_found then
        return null; -- Operation can be not found.
    when too_many_rows then
        com_api_error_pkg.raise_error(
            i_error => 'TOO_MANY_OPERATIONS_FOUND'
        );
end match_order_with_operation;

procedure add_oper_to_prepared_order(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_oper_id               in      com_api_type_pkg.t_long_id
  , o_prepared_order_id        out  com_api_type_pkg.t_long_id
) is
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
    l_order_id              com_api_type_pkg.t_long_id;
    l_cycle_type            com_api_type_pkg.t_dict_value;
    l_template_id           com_api_type_pkg.t_long_id;
    l_params                com_api_type_pkg.t_param_tab;
    l_order_date            date;
    l_prev_date             date;
    l_amount_rec            com_api_type_pkg.t_amount_rec;
    l_cycle_id              com_api_type_pkg.t_long_id;
begin
    begin
      select t.id
           , s.entity_type
           , s.object_id
           , s.event_type
        into l_template_id
           , l_entity_type
           , l_object_id
           , l_cycle_type
        from pmo_order t
           , pmo_schedule s
       where t.customer_id  = i_customer_id
         and s.order_id     = t.id
         and t.purpose_id   = i_purpose_id
         and t.templ_status in (
                                 pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
                               , pmo_api_const_pkg.PAYMENT_TMPL_STATUS_SUSP
                               )
         and t.is_template  = com_api_const_pkg.TRUE
         and rownum = 1;

    exception
        when no_data_found then
            null;
    end;

    if l_template_id is null then
        trc_log_pkg.debug(
            i_text  => 'Template not found customer_id = ' || i_customer_id || ', purpose_id = ' || i_purpose_id
        );
        return;
    end if;

    -- get order cycle date
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type     => l_cycle_type
      , i_entity_type    => l_entity_type
      , i_object_id      => l_object_id
      , i_split_hash     => i_split_hash
      , o_prev_date      => l_prev_date
      , o_next_date      => l_order_date
    );

    -- find/create prepared payment order
    begin
      select t.id
        into o_prepared_order_id
        from pmo_order t
       where t.status       = pmo_api_const_pkg.PMO_STATUS_PREPARATION
         and t.event_date   = l_order_date
         and t.template_id  = l_template_id;

        trc_log_pkg.debug(
            i_text  => 'Found order order_id = ' || l_order_id
        );

    exception
        when no_data_found then

            l_amount_rec.amount     := null;
            l_amount_rec.currency   := null;

            pmo_api_order_pkg.add_order_with_params(
                io_payment_order_id     => o_prepared_order_id
              , i_entity_type           => l_entity_type
              , i_object_id             => l_object_id
              , i_customer_id           => i_customer_id
              , i_split_hash            => i_split_hash
              , i_purpose_id            => i_purpose_id
              , i_template_id           => l_template_id
              , i_amount_rec            => l_amount_rec
              , i_eff_date              => l_order_date
              , i_order_status          => pmo_api_const_pkg.PMO_STATUS_PREPARATION
              , i_inst_id               => i_inst_id
              , i_attempt_count         => 0
              , i_payment_order_number  => null
              , i_expiration_date       => null
              , i_register_event        => com_api_const_pkg.TRUE
              , i_is_prepared_order     => com_api_type_pkg.TRUE
              , i_param_tab             => l_params
            );

            trc_log_pkg.debug(
                i_text  => 'Created order order_id = ' || o_prepared_order_id
            );
    end;

    -- link operation
    pmo_api_order_pkg.add_order_detail(
        i_order_id       => o_prepared_order_id
        , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id    => i_oper_id
    );
end add_oper_to_prepared_order;

function check_purpose_exists(
    i_purpose_id                in      com_api_type_pkg.t_short_id
  , i_mask_error                in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_boolean
is
    l_purpose_id                com_api_type_pkg.t_short_id;
begin
    select id
      into l_purpose_id
      from pmo_purpose p
     where p.id = i_purpose_id;

    return com_api_const_pkg.TRUE;

exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        else
            com_api_error_pkg.raise_error(
                i_error => 'PAYMENT_PURPOSE_NOT_EXISTS'
              , i_env_param1 => i_purpose_id
            );
        end if;
end check_purpose_exists;

function check_purpose_exists(
    i_purpose_number            in      com_api_type_pkg.t_name
  , i_mask_error                in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_boolean
is
    l_purpose_id                com_api_type_pkg.t_short_id;
begin
    select id
      into l_purpose_id
      from pmo_purpose p
     where p.purpose_number = i_purpose_number;

    return com_api_const_pkg.TRUE;

exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'PAYMENT_PURPOSE_NOT_EXISTS'
              , i_env_param1 => i_purpose_number
            );
        end if;
end check_purpose_exists;

end pmo_api_order_pkg;
/
