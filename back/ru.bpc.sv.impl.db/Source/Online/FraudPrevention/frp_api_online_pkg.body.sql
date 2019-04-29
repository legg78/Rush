create or replace package body frp_api_online_pkg as

procedure load_hist(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_is_external           in      com_api_type_pkg.t_boolean
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_hist_depth            in      com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.load_hist: ';
    cu_auth_hist            com_api_type_pkg.t_ref_cur;
begin
    frp_buffer_pkg.auth_id.delete;
    frp_buffer_pkg.msg_type.delete;
    frp_buffer_pkg.oper_type.delete;
    frp_buffer_pkg.resp_code.delete;
    frp_buffer_pkg.acq_bin.delete;
    frp_buffer_pkg.merchant_number.delete;
    frp_buffer_pkg.merchant_country.delete;
    frp_buffer_pkg.merchant_city.delete;
    frp_buffer_pkg.merchant_street.delete;
    frp_buffer_pkg.merchant_region.delete;
    frp_buffer_pkg.mcc.delete;
    frp_buffer_pkg.terminal_number.delete;
    frp_buffer_pkg.card_data_input_mode.delete;
    frp_buffer_pkg.card_data_output_cap.delete;
    frp_buffer_pkg.pin_presence.delete;
    frp_buffer_pkg.oper_amount.delete;
    frp_buffer_pkg.oper_currency.delete;
    frp_buffer_pkg.oper_date.delete;
    frp_buffer_pkg.card_number.delete;

    open cu_auth_hist for
        select id
             , msg_type
             , oper_type
             , resp_code
             , acq_inst_bin
             , merchant_number
             , merchant_country
             , merchant_city
             , merchant_street
             , merchant_region
             , mcc
             , terminal_number
             , card_data_input_mode
             , card_data_output_cap
             , pin_presence
             , oper_amount
             , oper_currency
             , oper_date
             , card_number
          from (
                select a.id
                     , a.msg_type
                     , a.oper_type
                     , a.resp_code
                     , a.acq_inst_bin
                     , a.merchant_number
                     , a.merchant_country
                     , a.merchant_city
                     , a.merchant_street
                     , a.merchant_region
                     , a.mcc
                     , a.terminal_number
                     , a.card_data_input_mode
                     , a.card_data_output_cap
                     , a.pin_presence
                     , a.oper_amount
                     , a.oper_currency
                     , a.oper_date
                     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                  from frp_auth a
                     , frp_auth_object b
                     , frp_auth_card c
                 where b.entity_type = i_entity_type
                   and b.object_id   = i_object_id
                   and b.is_external = i_is_external
                   and b.auth_id     = a.id
                   and c.id(+)       = a.id
                   and a.split_hash  = com_api_hash_pkg.get_split_hash(a.id)
                 order by b.auth_id desc
          )
         where rownum <= i_hist_depth
         order by id desc;

    fetch cu_auth_hist bulk collect into
        frp_buffer_pkg.auth_id
      , frp_buffer_pkg.msg_type
      , frp_buffer_pkg.oper_type
      , frp_buffer_pkg.resp_code
      , frp_buffer_pkg.acq_bin
      , frp_buffer_pkg.merchant_number
      , frp_buffer_pkg.merchant_country
      , frp_buffer_pkg.merchant_city
      , frp_buffer_pkg.merchant_street
      , frp_buffer_pkg.merchant_region
      , frp_buffer_pkg.mcc
      , frp_buffer_pkg.terminal_number
      , frp_buffer_pkg.card_data_input_mode
      , frp_buffer_pkg.card_data_output_cap
      , frp_buffer_pkg.pin_presence
      , frp_buffer_pkg.oper_amount
      , frp_buffer_pkg.oper_currency
      , frp_buffer_pkg.oper_date
      , frp_buffer_pkg.card_number
    limit 1000;

    close cu_auth_hist;

    trc_log_pkg.debug(LOG_PREFIX || 'frp_buffer_pkg.auth_id.count [' || frp_buffer_pkg.auth_id.count || ']');
exception
    when others then
        if cu_auth_hist%isopen then
            close cu_auth_hist;
        end if;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with i_entity_type [#1], i_object_id [#2], '
                                       || 'i_is_external [#3], i_auth_id [#4], i_hist_depth [#5]'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_is_external
          , i_env_param4 => i_auth_id
          , i_env_param5 => i_hist_depth
        );
        raise;
end load_hist;

procedure register_alert(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_is_external           in      com_api_type_pkg.t_boolean
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_check_id              in      com_api_type_pkg.t_short_id
)is
    l_need_save             com_api_type_pkg.t_boolean;
    l_case_id               com_api_type_pkg.t_tiny_id;
    l_alert_type            com_api_type_pkg.t_dict_value;
begin
    select alert_type
         , case_id
      into l_alert_type
         , l_case_id
      from frp_check
     where id = i_check_id;

    if l_alert_type = frp_api_const_pkg.ALERT_TYPE_NEVER then
        l_need_save := com_api_const_pkg.FALSE;
    elsif l_alert_type = frp_api_const_pkg.ALERT_TYPE_ALWAYS then
        l_need_save := com_api_const_pkg.TRUE;
    elsif l_alert_type = frp_api_const_pkg.ALERT_TYPE_IF_USED then
        select count(1)
          into l_need_save
          from frp_check
         where case_id = l_case_id
           and upper(expression) like '%ALERT_'||i_check_id||'%'
           and rownum = 1;
    end if;

    if l_need_save = com_api_const_pkg.TRUE then
        insert into frp_alert(
            id
          , auth_id
          , check_id
          , entity_type
          , object_id
          , is_external
        ) values (
            frp_alert_seq.nextval
          , i_auth_id
          , i_check_id
          , i_entity_type
          , i_object_id
          , i_is_external
        );
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.register_alert FAILED: i_entity_type [#1], i_object_id [#2], '
                                                || 'i_is_external [#3], i_auth_id [#4], i_check_id [#5]'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_is_external
          , i_env_param4 => i_auth_id
          , i_env_param5 => i_check_id
        );
        raise;
end register_alert;

procedure register_fraud(
    i_case_id               in      com_api_type_pkg.t_tiny_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_is_external           in      com_api_type_pkg.t_boolean
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
)is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.register_fraud: ';
begin
    declare
        l_rec    frp_fraud%rowtype;
    begin
        select *
          into l_rec
          from frp_fraud f
         where f.auth_id = i_auth_id
           and f.entity_type = i_entity_type
           and f.object_id = i_object_id
           and f.is_external = i_is_external;

        trc_log_pkg.warn(
            i_text       => LOG_PREFIX || 'fraud entry already exists: {i_auth_id [#1], i_entity_type [#2], '
                                       || 'i_object_id [#3], i_is_external [#4], case_id [#5], event_type [#6]}'
          , i_env_param1 => i_auth_id
          , i_env_param2 => i_entity_type
          , i_env_param3 => i_object_id
          , i_env_param4 => i_is_external
          , i_env_param5 => l_rec.case_id
          , i_env_param6 => l_rec.event_type
        );

        return;
        
    exception
        when no_data_found then
            null; -- It's ok so insertion should be executed
    end;

    insert into frp_fraud(
        id
      , seqnum
      , auth_id
      , entity_type
      , object_id
      , is_external
      , case_id
      , event_type
    ) values (
        com_api_id_pkg.get_id(frp_fraud_seq.nextval, get_sysdate)
      , 1
      , i_auth_id
      , i_entity_type
      , i_object_id
      , i_is_external
      , i_case_id
      , i_event_type
    );
end register_fraud;

procedure execute_case(
    i_case_id               in      com_api_type_pkg.t_tiny_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_is_external           in      com_api_type_pkg.t_boolean
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , o_resp_code                out  com_api_type_pkg.t_dict_value
  , o_fraud_is_registered      out  com_api_type_pkg.t_boolean
) is
    l_total_risk            com_api_type_pkg.t_tiny_id := 0;
    l_check_risk            com_api_type_pkg.t_tiny_id := 0;
    l_event_type            com_api_type_pkg.t_dict_value;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text        => 'Executing checks in case [#1].'
      , i_env_param1  => i_case_id
      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id   => i_auth_id
    );

    o_fraud_is_registered := com_api_type_pkg.FALSE;

    for r in (
        select id as check_id
          from frp_check
         where case_id = i_case_id
    ) loop
        l_check_risk :=
            frp_static_pkg.execute_check(
                i_check_id          => r.check_id
            );

        if l_check_risk > 0 then
            register_alert(
                i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_is_external       => i_is_external
              , i_auth_id           => frp_buffer_pkg.auth_id(1)
              , i_check_id          => r.check_id
            );

            l_total_risk := l_total_risk + l_check_risk;
        end if;

        trc_log_pkg.debug(
            i_text        => 'Check ['||r.check_id||'] completed: risk ['||l_check_risk||'], total risk ['||l_total_risk||'].'
          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id   => i_auth_id
        );
    end loop;

    select nvl(min(event_type) keep (dense_rank last order by risk_threshold), frp_api_const_pkg.EVENT_LEGAL_AUTH_REG)
         , nvl(min(resp_code)  keep (dense_rank last order by risk_threshold), aup_api_const_pkg.RESP_CODE_OK)
      into l_event_type
         , o_resp_code
      from frp_case_event b
     where l_total_risk >= risk_threshold
       and case_id = i_case_id;

    if l_event_type = frp_api_const_pkg.EVENT_LEGAL_AUTH_REG then
        o_fraud_is_registered := com_api_type_pkg.FALSE;

    else
        o_fraud_is_registered := com_api_type_pkg.TRUE;

        register_fraud(
            i_case_id               => i_case_id
          , i_entity_type           => i_entity_type
          , i_object_id             => i_object_id
          , i_is_external           => i_is_external
          , i_auth_id               => frp_buffer_pkg.auth_id(1)
          , i_event_type            => l_event_type
        );

        evt_api_event_pkg.register_event(
            i_event_type            => l_event_type
          , i_eff_date              => frp_buffer_pkg.oper_date(1)
          , i_entity_type           => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
          , i_object_id             => frp_buffer_pkg.auth_id(1)
          , i_inst_id               => i_inst_id
          , i_split_hash            => i_split_hash
          , i_param_tab             => l_param_tab
        );
    end if;

    trc_log_pkg.debug(
        i_text        => 'All checks are done. Fraud is #1 detected with event type [#2].'
      , i_env_param1  => case when o_fraud_is_registered = com_api_type_pkg.FALSE then 'not' else null end
      , i_env_param2  => l_event_type
      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id   => i_auth_id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.execute_case FAILED: i_case_id [#1], i_entity_type [#2], '
                         || 'i_object_id [#3], i_is_external [#4], i_inst_id [#5], i_split_hash [#6]'
          , i_env_param1 => i_case_id
          , i_env_param2 => i_entity_type
          , i_env_param3 => i_object_id
          , i_env_param4 => i_is_external
          , i_env_param5 => i_inst_id
          , i_env_param6 => i_split_hash
        );
        raise;
end execute_case;

procedure define_object(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_external_id           in      com_api_type_pkg.t_name
  , o_object_id                out  com_api_type_pkg.t_long_id
  , o_is_external              out  com_api_type_pkg.t_boolean
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
) is
    l_external_id           com_api_type_pkg.t_name;
begin
    if i_object_id is not null then
        o_split_hash  := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
        o_is_external := com_api_const_pkg.FALSE;
        o_object_id   := i_object_id;
    elsif i_external_id is not null then
        o_split_hash := com_api_hash_pkg.get_split_hash(i_external_id);
        o_is_external := com_api_const_pkg.TRUE;

        -- hashing card numbers with MD5 algorithm
        l_external_id :=
            case i_entity_type
                when iss_api_const_pkg.ENTITY_TYPE_CARD
                then dbms_crypto.hash(i_external_id, dbms_crypto.HASH_MD5)
                else i_external_id
            end;

        begin
            select id
              into o_object_id
              from frp_external_object
             where external_id = l_external_id
               and entity_type = i_entity_type;
        exception
            when no_data_found then
                insert into frp_external_object (
                    id
                  , entity_type
                  , external_id
                ) values (
                    frp_external_object_seq.nextval
                  , i_entity_type
                  , l_external_id
                ) returning id into o_object_id;
        end;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.define_object FAILED: i_entity_type [#1], i_object_id [#2], i_external_id [#3]'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_external_id
        );
        raise;
end define_object;

procedure register_auth(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_is_external           in      com_api_type_pkg.t_boolean
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_resp_code             in      com_api_type_pkg.t_dict_value    default null
) is
begin
    begin
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.register_auth: i_entity_type [#1], i_object_id [#2], i_auth_id [#3], i_resp_code [#4]'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_auth_id
          , i_env_param4 => i_resp_code
        );
    
        insert into frp_auth (
            id
          , msg_type
          , oper_type
          , resp_code
          , acq_inst_bin
          , merchant_number
          , merchant_country
          , merchant_city
          , merchant_street
          , merchant_region
          , mcc
          , terminal_number
          , card_data_input_mode
          , card_data_output_cap
          , pin_presence
          , oper_amount
          , oper_currency
          , oper_date
          , split_hash
        ) select a.id
               , o.msg_type
               , o.oper_type
               , nvl(i_resp_code, a.resp_code)
               , o.acq_inst_bin
               , o.merchant_number
               , o.merchant_country
               , o.merchant_city
               , o.merchant_street
               , o.merchant_region
               , o.mcc
               , o.terminal_number
               , a.card_data_input_mode
               , a.card_data_output_cap
               , a.pin_presence
               , o.oper_amount
               , o.oper_currency
               , o.oper_date
               , com_api_hash_pkg.get_split_hash(a.id)
            from aut_auth a
               , opr_operation o
           where a.id = i_auth_id
             and o.id = a.id;

         insert into frp_auth_card (
             id
           , card_number
           , split_hash
         ) select auth_id
                , card_number -- using encoded card number
                , split_hash
             from aut_card
            where auth_id = i_auth_id;

    exception
        when dup_val_on_index then

            update frp_auth
               set resp_code = nvl(i_resp_code, resp_code)     
             where id =  i_auth_id;   
            
            trc_log_pkg.debug(
                i_text       => lower($$PLSQL_UNIT) || '.register_auth. Update resp_code: i_resp_code [#1], i_auth_id [#2]'
              , i_env_param1 => i_resp_code
              , i_env_param2 => i_auth_id
            );
    end;

    begin
        insert into frp_auth_object (
            auth_id
          , entity_type
          , object_id
          , is_external
        ) values (
            i_auth_id
          , i_entity_type
          , i_object_id
          , i_is_external
        );
    exception
        when dup_val_on_index then
            null;
    end;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.register_auth FAILED: i_entity_type [#1], i_object_id [#2], '
                         || 'i_auth_id [#3], i_is_external [#4], i_split_hash [#5], i_resp_code [#6]'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_auth_id
          , i_env_param4 => i_is_external
          , i_env_param5 => i_split_hash
          , i_env_param6 => i_resp_code
        );
        raise;
end register_auth;

procedure check_suite(
    i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_oper_date         in      date
  , o_resp_code            out  com_api_type_pkg.t_dict_value
  , o_suite_id             out  com_api_type_pkg.t_tiny_id
) is
    l_suite_id          com_api_type_pkg.t_tiny_id;
begin

    case when i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
         then
            select min(suite_id) keep (dense_rank last order by start_date)
              into l_suite_id
              from frp_suite_object
             where entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and object_id   = i_object_id
               and i_oper_date between start_date and nvl(end_date, i_oper_date);

            if l_suite_id is null then
                select min(suite_id) keep (dense_rank last order by start_date)
                  into l_suite_id
                  from frp_suite_object
                 where entity_type = iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
                   and object_id in (
                       select
                           bin_id
                       from (
                           select
                               b.id bin_id
                               , row_number() over (order by length(b.bin) desc) rec_num
                           from
                               iss_bin b
                               , iss_card_number c
                           where
                               c.card_number like bin || '%' -- token begins from BIN 
                               and c.card_id = i_object_id
                       ) b
                       where
                           b.rec_num = 1
                   )
                   and i_oper_date between start_date and nvl(end_date, i_oper_date);
            end if;

            if l_suite_id is null then
                select min(suite_id) keep (dense_rank last order by start_date)
                  into l_suite_id
                  from frp_suite_object
                 where entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                   and object_id in (
                       select
                           iss_inst_id
                       from (
                           select
                               b.inst_id iss_inst_id
                               , row_number() over (order by length(b.bin) desc) rec_num
                           from
                               iss_bin b
                               , iss_card_number c  -- token begins from BIN
                           where
                               c.card_number like bin || '%'
                               and c.card_id = i_object_id
                       ) b
                       where
                           b.rec_num = 1
                   )
                   and i_oper_date between start_date and nvl(end_date, i_oper_date);
            end if;
         when i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
         then
            select min(suite_id) keep (dense_rank last order by start_date)
              into l_suite_id
              from frp_suite_object
             where entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and object_id   = i_object_id
               and i_oper_date between start_date and nvl(end_date, i_oper_date);

            if l_suite_id is null then
                select min(suite_id) keep (dense_rank last order by start_date)
                  into l_suite_id
                  from frp_suite_object
                 where entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                   and object_id in (
                           select a.inst_id
                             from acc_account a
                            where a.id = i_object_id
                       )
                   and i_oper_date between start_date and nvl(end_date, i_oper_date);
            end if;
         when i_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
         then
            select min(suite_id) keep (dense_rank last order by start_date)
              into l_suite_id
              from frp_suite_object
             where entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
               and object_id   = i_object_id
               and i_oper_date between start_date and nvl(end_date, i_oper_date);

            if l_suite_id is null then
                select min(suite_id) keep (dense_rank last order by start_date)
                  into l_suite_id
                  from frp_suite_object
                 where entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                   and object_id in (
                           select t.inst_id
                             from acq_terminal t
                            where t.id = i_object_id
                       )
                   and i_oper_date between start_date and nvl(end_date, i_oper_date);
            end if;
        else
            null;
    end case;

    o_suite_id := l_suite_id;
    if l_suite_id is null then
        o_resp_code := aup_api_const_pkg.RESP_CODE_OK;
        trc_log_pkg.info(
            i_text          => 'Suite not found for object [#1] and entity_type [#2]'
          , i_env_param1    => i_object_id
          , i_env_param2    => i_entity_type
        );

    end if;

exception
    when others then
        o_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
end;

procedure check_legality(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_external_id           in      com_api_type_pkg.t_name         default null
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_suite_id              in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , io_resp_code            in out  com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_legality: ';

    cursor l_cur_cases(
        p_suite_id in frp_suite_case.suite_id%type
    ) is
        select row_number() over (order by b.priority) as case_num
             , b.priority
             , a.id
             , a.hist_depth
             , max(a.hist_depth) over (partition by b.suite_id) as max_hist_depth
          from frp_case a
          join frp_suite_case b on b.case_id = a.id
         where b.suite_id = p_suite_id
         order by b.priority;

    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_is_external           com_api_type_pkg.t_boolean;
    l_object_id             com_api_type_pkg.t_long_id;
    l_suite_id              com_api_type_pkg.t_tiny_id;
    l_resp_code             com_api_type_pkg.t_dict_value;
begin
    define_object(
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_external_id   => i_external_id
      , o_object_id     => l_object_id
      , o_is_external   => l_is_external
      , o_split_hash    => l_split_hash
    );

    register_auth(
        i_entity_type   => i_entity_type
      , i_object_id     => l_object_id
      , i_auth_id       => i_auth_id
      , i_is_external   => l_is_external
      , i_split_hash    => l_split_hash
      , i_resp_code     => io_resp_code
    );

    if nvl(i_suite_id,0) = 0 then
        -- checking suite by entity_type and object
        check_suite(
            i_object_id    => i_object_id
          , i_entity_type  => i_entity_type
          , i_oper_date    => get_sysdate
          , o_resp_code    => l_resp_code
          , o_suite_id     => l_suite_id
        );
        io_resp_code := l_resp_code;
    end if;
    if nvl(i_suite_id,0) != 0 then
        l_suite_id := i_suite_id;
    end if;

    if l_suite_id is not null then
        -- checking fraud cases (by their priorities) for the selected suite until a first fraud's detection
        declare
            l_fraud_is_registered   com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
            l_rec                   l_cur_cases%rowtype;
            l_cnt                   com_api_type_pkg.t_count := 0;
        begin
            trc_log_pkg.debug(
                i_text        => 'Checking for legality: authorization [#1], object [#2][#3], suite [#4].'
              , i_env_param1  => i_auth_id
              , i_env_param2  => l_object_id
              , i_env_param3  => i_entity_type
              , i_env_param4  => l_suite_id
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => i_auth_id -- consider i_auth_id is equal to operation identifier
            );

            open l_cur_cases(p_suite_id => l_suite_id);
            loop
                fetch l_cur_cases into l_rec;

                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'l_rec: case_num [' || l_rec.case_num || '], id [' || l_rec.id
                                         || '], hist_depth [' || l_rec.hist_depth
                                         || '], max_hist_depth [' || l_rec.max_hist_depth || ']'
                );
                l_cnt := l_cnt + 1; -- for debugging

                exit when l_cur_cases%notfound
                       or l_fraud_is_registered = com_api_type_pkg.TRUE;

                if l_rec.case_num = 1 then
                    load_hist(
                        i_entity_type   => i_entity_type
                      , i_object_id     => l_object_id
                      , i_is_external   => l_is_external
                      , i_auth_id       => i_auth_id
                      , i_hist_depth    => l_rec.max_hist_depth
                    );
                end if;

                -- case will execute only if authorization history fully collected
                if frp_buffer_pkg.auth_id.count >= l_rec.hist_depth then
                    execute_case(
                        i_case_id             => l_rec.id
                      , i_entity_type         => i_entity_type
                      , i_object_id           => l_object_id
                      , i_is_external         => l_is_external
                      , i_inst_id             => i_inst_id
                      , i_split_hash          => l_split_hash
                      , i_auth_id             => i_auth_id
                      , o_resp_code           => io_resp_code
                      , o_fraud_is_registered => l_fraud_is_registered
                    );
                end if;
            end loop;

            close l_cur_cases;

            trc_log_pkg.debug(
                i_text        => 'Checking for legality has been '
                              || case when l_fraud_is_registered = com_api_type_pkg.TRUE then 'halted' else 'completed' end
                              || '.'
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => i_auth_id
            );
        exception
            when others then
                if l_cur_cases%isopen then
                    close l_cur_cases;
                end if;

                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'FAILED with l_cnt = ' || l_cnt || ', i_entity_type [#1], i_object_id [#2], '
                                               || 'i_external_id [#3], i_auth_id [#4], i_inst_id [#5], io_resp_code [#6]'
                  , i_env_param1 => i_entity_type
                  , i_env_param2 => i_object_id
                  , i_env_param3 => i_external_id
                  , i_env_param4 => i_auth_id
                  , i_env_param5 => i_inst_id
                  , i_env_param6 => io_resp_code
                );
                raise;
        end;
    end if;
exception
    when others then
        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end check_legality;

procedure register_auth(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id      default null
  , i_external_id           in      com_api_type_pkg.t_name         default null
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_resp_code             in      com_api_type_pkg.t_dict_value   default null
) is
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_is_external           com_api_type_pkg.t_boolean;
    l_object_id             com_api_type_pkg.t_long_id;
begin
    define_object(
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_external_id   => i_external_id
      , o_object_id     => l_object_id
      , o_is_external   => l_is_external
      , o_split_hash    => l_split_hash
    );

    register_auth(
        i_entity_type   => i_entity_type
      , i_object_id     => l_object_id
      , i_auth_id       => i_auth_id
      , i_is_external   => l_is_external
      , i_split_hash    => l_split_hash
      , i_resp_code     => i_resp_code
    );

exception
    when others then
        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end register_auth;

end;
/