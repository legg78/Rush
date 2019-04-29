create or replace package body evt_api_status_pkg as
/*********************************************************
*  API for status events<br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 04.04.2011 <br />
*  Module: EVT_API_STATUS_PKG <br />
*  @headcom
**********************************************************/

procedure add_status_log(
    i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initiator             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_reason                in      com_api_type_pkg.t_dict_value
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_eff_date              in      date                             default null
  , i_event_date            in      date                             default null
) is
    l_user_id               com_api_type_pkg.t_short_id;
    l_session_id            com_api_type_pkg.t_long_id;
    l_eff_date              date;
begin
    l_user_id    := com_ui_user_env_pkg.get_user_id;
    l_session_id := prc_api_session_pkg.get_session_id;
    l_eff_date   := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    insert into evt_status_log(
        id
      , entity_type
      , object_id
      , event_type
      , initiator
      , reason
      , status
      , change_date
      , user_id
      , session_id
      , event_date
    ) values (
        com_api_id_pkg.get_id(evt_status_log_seq.nextval, l_eff_date) 
      , i_entity_type
      , i_object_id
      , i_event_type
      , i_initiator
      , i_reason
      , i_status
      , l_eff_date
      , l_user_id
      , l_session_id
      , i_event_date
    );

end;

procedure add_status_log (
    i_event_type            in      com_api_type_pkg.t_dict_tab
  , i_initiator             in      com_api_type_pkg.t_dict_tab
  , i_entity_type           in      com_api_type_pkg.t_dict_tab
  , i_object_id             in      com_api_type_pkg.t_number_tab
  , i_reason                in      com_api_type_pkg.t_dict_tab
  , i_status                in      com_api_type_pkg.t_dict_tab
  , i_eff_date              in      com_api_type_pkg.t_date_tab
  , i_event_date            in      com_api_type_pkg.t_date_tab
) is
    l_user_id               com_api_type_pkg.t_short_id;
    l_session_id            com_api_type_pkg.t_long_id;
    l_sysdate               date;
begin
    l_user_id    := com_ui_user_env_pkg.get_user_id;
    l_session_id := prc_api_session_pkg.get_session_id;
    l_sysdate    := com_api_sttl_day_pkg.get_sysdate;

    forall i in 1..i_object_id.count
        insert into evt_status_log (
            id
          , entity_type
          , object_id
          , event_type
          , initiator
          , reason
          , status
          , change_date
          , user_id
          , session_id
          , event_date
        ) values (
            com_api_id_pkg.get_id(evt_status_log_seq.nextval, nvl(i_eff_date(i), l_sysdate))
          , i_entity_type(i)
          , i_object_id(i)
          , i_event_type(i)
          , i_initiator(i)
          , i_reason(i)
          , i_status(i)
          , nvl(i_eff_date(i), l_sysdate)
          , l_user_id
          , l_session_id
          , i_event_date(i)
        );
end;

function get_result_status(
    i_initiator             in      com_api_type_pkg.t_dict_value
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initial_status        in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_dict_value
result_cache relies_on (evt_status_map)
is
    l_result_status                 com_api_type_pkg.t_dict_value;
begin
    select min(result_status) keep (dense_rank first order by inst_id)
      into l_result_status
      from evt_status_map
     where initial_status = i_initial_status
       and initiator      = i_initiator
       and event_type     = i_event_type
       and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);

    return l_result_status;
end;

procedure change_status(
    i_initiator             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_new_status            in      com_api_type_pkg.t_dict_value
  , i_reason                in      com_api_type_pkg.t_dict_value
  , o_status                   out  com_api_type_pkg.t_dict_value
  , i_eff_date              in      date                             default null
  , i_raise_error           in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_register_event        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_params                in      com_api_type_pkg.t_param_tab
  , i_inst_id               in      com_api_type_pkg.t_tiny_id       default null
  , i_event_date            in      date                             default null
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_status: ';
    l_old_status             com_api_type_pkg.t_dict_value;
    l_old_state              com_api_type_pkg.t_dict_value;
    l_new_state              com_api_type_pkg.t_dict_value;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_split_hash             com_api_type_pkg.t_tiny_id;
    l_event_type             com_api_type_pkg.t_dict_value;
    l_status_dict            com_api_type_pkg.t_dict_value;
    l_eff_date               date;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'entity_type=' || i_entity_type || ', object_id=' || i_object_id
                                 || ', status=' || i_new_status || ', initiator=' || i_initiator);
    
    if i_object_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'OBJECT_NOT_FOUND'
          , i_env_param2 => i_entity_type
        );
    end if;
    
    l_status_dict := substr(i_new_status, 1, 4);

    if i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        select decode(l_status_dict,'MRCS',status, null)
             , inst_id
             , split_hash
          into l_old_status
             , l_inst_id
             , l_split_hash
          from acq_merchant
         where id = i_object_id;

    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
        select decode(l_status_dict,'TRMS',status, null)
             , inst_id
             , split_hash
          into l_old_status
             , l_inst_id
             , l_split_hash
          from acq_terminal
         where id = i_object_id;

    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select decode(l_status_dict, 'CSTE', state, 'CSTS', status, null)
             , decode(l_status_dict, 'CSTE', status, 'CSTS', state, null)
             , inst_id
             , split_hash
          into l_old_status
             , l_old_state
             , l_inst_id
             , l_split_hash
          from iss_card_instance
         where id = i_object_id;

    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select status
             , inst_id
             , split_hash
          into l_old_status
             , l_inst_id
             , l_split_hash
          from acc_account
         where id = i_object_id;

    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_BALANCE then
        select status
             , inst_id
             , split_hash
          into l_old_status
             , l_inst_id
             , l_split_hash
          from acc_balance
         where id = i_object_id;

    elsif i_entity_type = net_api_const_pkg.ENTITY_TYPE_HOST then
        select m.status
             , m.inst_id
             , c.split_hash
          into l_old_status
             , l_inst_id
             , l_split_hash
          from net_member m
             , prd_customer c
         where m.id                 = i_object_id
           and c.ext_entity_type(+) = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
           and c.ext_object_id(+)   = m.inst_id ;

    elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_DEBT then
        select d.status
             , d.inst_id
             , d.split_hash
          into l_old_status
             , l_inst_id
             , l_split_hash
          from crd_debt d
         where d.id                 = i_object_id;

    elsif i_entity_type = prc_api_const_pkg.ENTITY_TYPE_SESSION then
        select result_code
             , inst_id
             , com_api_const_pkg.DEFAULT_SPLIT_HASH
          into l_old_status
             , l_inst_id
             , l_split_hash
          from prc_session
         where id = i_object_id;

    elsif i_entity_type = prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE then
        select f.status
             , s.inst_id
             , com_api_const_pkg.DEFAULT_SPLIT_HASH
          into l_old_status
             , l_inst_id
             , l_split_hash
          from prc_session_file f
             , prc_session s
         where f.id = i_object_id
           and f.session_id = s.id;

    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select status
             , inst_id
             , split_hash
          into l_old_status
             , l_inst_id
             , l_split_hash
          from prd_customer
         where id = i_object_id;

    elsif i_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
        select status
             , id
             , null
          into l_old_status
             , l_inst_id
             , l_split_hash
          from ost_institution
         where id = i_object_id;

    else
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_CHANGE_STATUS'
          , i_env_param1 => i_entity_type
        );
    end if;
    
    trc_log_pkg.debug(LOG_PREFIX || 'l_old_status=' || l_old_status || ', l_old_state=' || l_old_state
                                 || ', l_inst_id=' || l_inst_id || ', l_split_hash=' || l_split_hash);
    
    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );
    
    if l_old_status != i_new_status then
        select min(event_type) keep(dense_rank first order by priority)
          into l_event_type
          from evt_status_map
         where initial_status = l_old_status
           and result_status  = i_new_status
           and initiator      = i_initiator
           and inst_id in (l_inst_id, ost_api_const_pkg.DEFAULT_INST);

        if l_event_type is null then
            com_api_error_pkg.raise_error(
                i_error      => 'ILLEGAL_STATUS_COMBINATION'
              , i_env_param1 => i_entity_type
              , i_env_param2 => l_old_status
              , i_env_param3 => i_new_status
              , i_mask_error => com_api_type_pkg.boolean_not(i_raise_error)
            );
        end if;

        if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            l_new_state :=
                get_result_status(
                    i_initiator       => i_initiator
                  , i_event_type      => l_event_type
                  , i_initial_status  => l_old_state
                  , i_inst_id         => l_inst_id
                );

            if l_status_dict  = 'CSTE' then
                update iss_card_instance
                   set state  = i_new_status
                     , status = nvl(l_new_state, status)
                 where id     = i_object_id
                returning status into o_status;
            elsif l_status_dict = 'CSTS' then
                update iss_card_instance
                   set status = i_new_status
                     , state  = nvl(l_new_state, state)
                 where id     = i_object_id
                returning status into o_status;
                
                iss_api_card_token_pkg.change_token_status(
                    i_event_type        => l_event_type
                  , i_initiator         => i_initiator
                  , i_card_instance_id  => i_object_id
                  , i_reason            => i_reason
                  , i_inst_id           => l_inst_id
                  , i_eff_date          => i_eff_date
                );
            end if;
        elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            if l_status_dict = 'MRCS' then
                update acq_merchant
                   set status = i_new_status
                 where id     = i_object_id
                returning status into o_status;
            end if;
        elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            if l_status_dict = 'TRMS' then
                update acq_terminal
                   set status = i_new_status
                 where id     = i_object_id
                returning status into o_status;
            end if;
        elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            if l_status_dict = 'ACST' then
                update acc_account
                   set status = i_new_status
                 where id     = i_object_id
                returning status into o_status;

                acc_api_account_pkg.clear_cache();
            end if;
        elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_BALANCE then
            if l_status_dict = 'BLST' then
                update acc_balance
                   set status = i_new_status
                 where id     = i_object_id
                returning status into o_status;
            end if;
        elsif i_entity_type = net_api_const_pkg.ENTITY_TYPE_HOST then
            if l_status_dict = 'HSST' then
                update net_member
                   set status = i_new_status
                 where id     = i_object_id
                returning status into o_status;
            end if;
        elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_DEBT then
            if l_status_dict = 'DBTS' then
                update crd_debt
                   set status = i_new_status
                 where id     = i_object_id
                returning status into o_status;
            end if;
        elsif i_entity_type = prc_api_const_pkg.ENTITY_TYPE_SESSION then
            if l_status_dict = 'PRSR' then
                update prc_session
                   set result_code = i_new_status
                 where id = i_object_id;
            end if;
        elsif i_entity_type = prc_api_const_pkg.ENTITY_TYPE_SESSION_FILE then
            update prc_session_file
               set status = i_new_status
             where id     = i_object_id;
        elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            update prd_customer
               set status = i_new_status
             where id     = i_object_id;
        elsif i_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
            update ost_institution
               set status = i_new_status
             where id     = i_object_id;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'UNABLE_CHANGE_STATUS'
              , i_env_param1 => i_entity_type
            );
        end if;

        add_status_log(
            i_event_type    => l_event_type
          , i_initiator     => i_initiator
          , i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_reason        => nvl(i_reason, l_event_type)
          , i_status        => i_new_status
          , i_eff_date      => i_eff_date
          , i_event_date    => i_event_date
        );

        if l_new_state is not null then
            add_status_log(
                i_event_type    => l_event_type
              , i_initiator     => i_initiator
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_reason        => nvl(i_reason, l_event_type)
              , i_status        => l_new_state
              , i_eff_date      => i_eff_date
              , i_event_date    => i_event_date
            );
        end if;

        trc_log_pkg.debug('Change status to ' || i_new_status ||
                          ' for ' || get_article_text(i_entity_type) || ' ' || i_object_id);

        if i_register_event = com_api_const_pkg.TRUE then

            l_eff_date := coalesce(i_eff_date, com_api_sttl_day_pkg.get_calc_date(l_inst_id));

            evt_api_event_pkg.register_event(
                i_event_type   => l_event_type
              , i_eff_date     => l_eff_date
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_inst_id      => l_inst_id
              , i_split_hash   => l_split_hash
              , i_param_tab    => i_params
            );
        end if;
    else
        trc_log_pkg.debug (
            i_text        => 'Change of status is not required - old status[#1] new status[#2]'
          , i_env_param1  => l_old_status
          , i_env_param2  => i_new_status
        );
    end if;

exception
    when com_api_error_pkg.e_application_error then
        if  nvl(i_raise_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE
            and
            com_api_error_pkg.get_last_error = 'ILLEGAL_STATUS_COMBINATION'
        then
            trc_log_pkg.debug(LOG_PREFIX || 'illegal status combination => EXIT from the procedure');
        else
            raise;
        end if;
end change_status;

procedure change_status(
    i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initiator             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_reason                in      com_api_type_pkg.t_dict_value
  , i_eff_date              in      date                             default null
  , i_params                in      com_api_type_pkg.t_param_tab
  , i_register_event        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id               in      com_api_type_pkg.t_tiny_id       default null
  , i_event_date            in      date                             default null
  , i_raise_error           in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_status: ';
    l_new_status                    com_api_type_pkg.t_dict_value;
    l_new_state                     com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_old_status                    com_api_type_pkg.t_dict_value;
    l_old_state                     com_api_type_pkg.t_dict_value;
begin
    begin
        if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            select status
                 , state
                 , inst_id
                 , split_hash
              into l_old_status
                 , l_old_state
                 , l_inst_id
                 , l_split_hash
              from iss_card_instance
             where id = i_object_id;
        elsif i_entity_type = net_api_const_pkg.ENTITY_TYPE_HOST then
            select m.status
                 , m.inst_id
                 , c.split_hash
              into l_old_status
                 , l_inst_id
                 , l_split_hash
              from net_member m
                 , prd_customer c
             where m.id                 = i_object_id
               and c.ext_entity_type(+) = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
               and c.ext_object_id(+)   = m.inst_id;
        elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_DEBT then
            select d.status
                 , d.inst_id
                 , d.split_hash
              into l_old_status
                 , l_inst_id
                 , l_split_hash
              from crd_debt d
             where d.id                 = i_object_id;
        elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            select status
                 , inst_id
                 , split_hash
              into l_old_status
                 , l_inst_id
                 , l_split_hash
              from acc_account
             where id = i_object_id;
        elsif i_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
            select status
                 , id
                 , null
              into l_old_status
                 , l_inst_id
                 , l_split_hash
              from ost_institution
             where id = i_object_id;
        else
            null;
        end if;
    exception
        when no_data_found then
            null;
    end;

    l_new_status :=
        get_result_status(
            i_initiator       => i_initiator
          , i_event_type      => i_event_type
          , i_initial_status  => l_old_status
          , i_inst_id         => l_inst_id
        );

    l_new_state :=
        get_result_status(
            i_initiator       => i_initiator
          , i_event_type      => i_event_type
          , i_initial_status  => l_old_state
          , i_inst_id         => l_inst_id
        );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_new_status [#1], l_old_status [#2], l_new_state [#3], l_old_state [#4]'
      , i_env_param1 => l_new_status
      , i_env_param2 => l_old_status
      , i_env_param3 => l_new_state
      , i_env_param4 => l_old_state
    );

    if l_new_state is null and l_new_status is null then
        trc_log_pkg.warn(
            i_text       => 'UNABLE_CHANGE_STATUS_OR_STATE'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_event_type
        );
    end if;

    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
       and nvl(l_new_status, l_old_status) != l_old_status
       and (
            (
             l_old_state = nvl(l_new_state, l_old_state)
             and
             iss_api_const_pkg.CARD_STATE_ACTIVE != l_old_state
            )
            or
            l_new_state not in (iss_api_const_pkg.CARD_STATE_ACTIVE, iss_api_const_pkg.CARD_STATE_CLOSED)
           )
    then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_CHANGE_STATUS'
          , i_env_param1 => i_entity_type
          , i_mask_error => com_api_type_pkg.boolean_not(i_raise_error)
        );
    end if;

    if l_new_status is not null then
        if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            update iss_card_instance
               set status = l_new_status
             where id     = i_object_id;

            iss_api_card_token_pkg.change_token_status(
                i_event_type        => i_event_type
              , i_initiator         => i_initiator
              , i_card_instance_id  => i_object_id
              , i_reason            => i_reason
              , i_inst_id           => l_inst_id
              , i_eff_date          => i_eff_date
            );
        elsif i_entity_type = net_api_const_pkg.ENTITY_TYPE_HOST then
            update net_member
               set status = l_new_status
             where id     = i_object_id;

        elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_DEBT then
            update crd_debt
               set status = l_new_status
             where id     = i_object_id;

        elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            update acc_account
               set status = l_new_status
             where id     = i_object_id;

            acc_api_account_pkg.clear_cache();

        elsif i_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
            update ost_institution
               set status = l_new_status
             where id     = i_object_id;
        end if;

        add_status_log(
            i_event_type    => i_event_type
          , i_initiator     => i_initiator
          , i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_reason        => nvl(i_reason, i_event_type)
          , i_status        => l_new_status
          , i_eff_date      => i_eff_date
          , i_event_date    => i_event_date
        );
    end if;

    if l_new_state is not null then
        if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            update iss_card_instance
               set state = l_new_state
             where id    = i_object_id;
        end if;

        add_status_log(
            i_event_type    => i_event_type
          , i_initiator     => i_initiator
          , i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_reason        => nvl(i_reason, i_event_type)
          , i_status        => l_new_state
          , i_eff_date      => i_eff_date
          , i_event_date    => i_event_date
        );
    end if;

    if l_new_status is not null and i_register_event = com_api_const_pkg.TRUE then
        evt_api_event_pkg.register_event (
            i_event_type          => i_event_type
          , i_eff_date            => coalesce(i_eff_date, com_api_sttl_day_pkg.get_calc_date(l_inst_id))
          , i_entity_type         => i_entity_type
          , i_object_id           => i_object_id
          , i_inst_id             => l_inst_id
          , i_split_hash          => l_split_hash
          , i_param_tab           => i_params
        );
    end if;

exception
    when com_api_error_pkg.e_application_error then
        if  nvl(i_raise_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE
            and
            com_api_error_pkg.get_last_error in ('UNABLE_CHANGE_STATUS_OR_STATE', 'UNABLE_CHANGE_STATUS')
        then
            trc_log_pkg.debug(LOG_PREFIX || 'unable to change status/state => EXIT from the procedure');
        else
            raise;
        end if;
end change_status;

/*
 * Procedure changes status of an event in table EVT_EVENT_OBJECT.
 * @i_id           - PK vaue for table EVT_EVENT_OBJECT
 * @i_event_status - new status of event
 */
procedure change_event_status(
    i_id                    in      com_api_type_pkg.t_long_id
  , i_event_status          in      com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_event_status: ';
    l_dict                   com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_id [' || i_id || '], i_event_status [#1]'
      , i_env_param1 => i_event_status
    );

    l_dict := substr(i_event_status, 1, 4);

    if l_dict != evt_api_const_pkg.EVENT_STATUS_KEY then
        com_api_error_pkg.raise_error(
            i_error      => 'CODE_NOT_CORRESPOND_TO_DICT'
          , i_env_param1 => i_event_status
          , i_env_param2 => evt_api_const_pkg.EVENT_STATUS_KEY
        );
    else
        com_api_dictionary_pkg.check_article(
            i_dict => l_dict
          , i_code => i_event_status
        );
    end if;

    update evt_event_object
       set status = i_event_status
     where id = i_id;
 
    trc_log_pkg.debug(
        i_text => 'Event''s status was ' || case sql%rowcount when 0 then 'not ' end || 'updated'
    );
end change_event_status;

/*
 * Function searches and returns event type that is associated with a transition
 * from specified initial status to result one.
 */
function get_event_type(
    i_initiator             in      com_api_type_pkg.t_dict_value
  , i_initial_status        in      com_api_type_pkg.t_dict_value
  , i_result_status         in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_raise_error           in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_dict_value
is
    l_event_type             com_api_type_pkg.t_dict_value;
begin
    begin
        select m.event_type
          into l_event_type
          from evt_status_map m
         where m.initiator      = i_initiator
           and m.initial_status = i_initial_status
           and m.result_status  = i_result_status
           and m.inst_id        = i_inst_id;
    exception
        when no_data_found then
            if i_raise_error = com_api_type_pkg.TRUE then
                com_api_error_pkg.raise_error(
                    i_error      => 'EVENT_TYPE_IS_NOT_DEFINED_FOR_STATUS_COMBINATION'
                  , i_env_param1 => i_initiator
                  , i_env_param2 => i_initial_status
                  , i_env_param3 => i_result_status
                  , i_env_param4 => i_inst_id
                );
            else
                trc_log_pkg.debug(
                    i_text       => 'EVENT_TYPE_IS_NOT_DEFINED_FOR_STATUS_COMBINATION'
                  , i_env_param1 => i_initiator
                  , i_env_param2 => i_initial_status
                  , i_env_param3 => i_result_status
                  , i_env_param4 => i_inst_id
                );
            end if;
    end;
    return l_event_type;
end get_event_type;

procedure change_status_event_date (
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_medium_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_initiator             in      com_api_type_pkg.t_dict_value
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_event_date            in      date
) is
begin
    update evt_status_log_vw
       set event_date    = i_event_date
     where entity_type   = i_entity_type
       and object_id     = i_object_id
       and event_type    = i_event_type
       and initiator     = i_initiator
       and status        = i_status;
end change_status_event_date;

function get_status_reason(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_raise_error           in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_dict_value
is
    l_result                com_api_type_pkg.t_dict_value;
begin
    select r.reason as status_reason
      into l_result
      from (
          select s.reason
            from evt_status_log_vw s
           where s.object_id    = i_object_id
             and s.entity_type  = i_entity_type
           order by s.id desc
      ) r
     where rownum = 1;

    return l_result;
exception
    when no_data_found then
        if i_raise_error = com_api_const_pkg.FALSE then
            return null;
        else
            com_api_error_pkg.raise_error(
                i_error         => 'OBJECT_NOT_FOUND'
              , i_env_param1    => i_entity_type
              , i_env_param2    => i_object_id
            );
        end if;
end get_status_reason;

end;
/
