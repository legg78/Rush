create or replace package body iss_api_card_token_pkg is
/*********************************************************
*  API for issuing card tokens <br />
*  Created by Manoli M.(manoli@bpcbt.com)  at 10.03.2017 <br />
*  Module: iss_api_card_token_pkg  <br />
*  @headcom
**********************************************************/

/*
 * Add card token.
 * @param  io_token_id         - Token identifier
 * @param  i_card_id           - Card number identifier
 * @param  i_card_instance_id  - Card instance identifier
 * @param  i_token             - Card token
 * @param  i_split_hash        - Split hash value
 * @param  i_init_oper_id      - Operation identifier which create card token
 * @param  i_wallet_provider   - Wallet provider
 */
procedure add_token(
    i_token_id         in      com_api_type_pkg.t_medium_id
  , i_card_id          in      com_api_type_pkg.t_medium_id
  , i_card_instance_id in      com_api_type_pkg.t_medium_id
  , i_token            in      com_api_type_pkg.t_card_number
  , i_split_hash       in      com_api_type_pkg.t_tiny_id
  , i_init_oper_id     in      com_api_type_pkg.t_long_id
  , i_wallet_provider  in      com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_card_token: ';
    l_split_hash      com_api_type_pkg.t_tiny_id;
    l_token_id        com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'io_token_id [#1], i_card_id [#2], i_card_instance_id [#3], i_token [#4], i_split_hash [#5], i_init_oper_id [#6]'
      , i_env_param1 => i_token_id
      , i_env_param2 => i_card_id
      , i_env_param3 => i_card_instance_id
      , i_env_param4 => i_token
      , i_env_param5 => i_split_hash
      , i_env_param6 => i_init_oper_id
    );
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_wallet_provider [#1]'
      , i_env_param1 => i_wallet_provider
    );

    l_token_id := iss_card_token_seq.nextval;

    begin
        select nvl(i_split_hash, c.split_hash) as split_hash
          into l_split_hash
          from iss_card c
         where id = i_card_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'CARD_NOT_FOUND'
              , i_env_param1    => i_card_id
            );
    end;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'adding new card token with id [#1]'
      , i_env_param1 => l_token_id
    );

    insert into iss_card_token_vw (
        id
      , card_id
      , card_instance_id
      , token
      , status
      , split_hash
      , init_oper_id
      , close_session_file_id
      , wallet_provider
    ) values (
        l_token_id
      , i_card_id
      , i_card_instance_id
      , i_token
      , iss_api_const_pkg.CARD_TOKEN_STATUS_ACTIVE
      , l_split_hash
      , i_init_oper_id
      , to_number(null)
      , i_wallet_provider
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_TO_CONNECT_EXISTED_TOKEN'
          , i_env_param1 => i_token
          , i_env_param2 => i_card_id
        ); 
end add_token;

/*
 * Change card token status.
 * @param  i_token_id           - Token identifier
 * @param  i_card_id            - Card number identifier
 * @param  i_status             - New status for token
 * @param  i_close_sess_file_id - Session_file_id of closing token (set status to suspended)
 * @param  i_init_oper_id       - Id of operation, which initiated token status changing 
 */
procedure change_token_status(
    i_token_id              in com_api_type_pkg.t_medium_id
  , i_status                in com_api_type_pkg.t_dict_value
  , i_card_instance_id      in com_api_type_pkg.t_medium_id   default null
  , i_close_sess_file_id    in com_api_type_pkg.t_long_id     default null
  , i_init_oper_id          in com_api_type_pkg.t_long_id     default null
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_token_status: ';
    l_params            com_api_type_pkg.t_param_tab;
    l_card_instance_id  com_api_type_pkg.t_medium_id;

    procedure change_status(
        i_token_id         in com_api_type_pkg.t_medium_id
      , i_card_instance_id in com_api_type_pkg.t_medium_id
      , i_status           in com_api_type_pkg.t_dict_value
    ) is
        LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_token_status.change_status: ';
        l_card_instance       iss_api_type_pkg.t_card_instance;
        l_event_type          com_api_type_pkg.t_dict_value;
    begin
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'suspending status for token with id [#1]'
          , i_env_param1 => i_token_id
        );

        if i_card_instance_id is not null then
            l_card_instance := iss_api_card_instance_pkg.get_instance(
                                   i_id           => i_card_instance_id
                                 , i_raise_error  => com_api_const_pkg.TRUE
                               );
        end if;

        l_event_type := opr_api_shared_data_pkg.get_param_char('EVENT_TYPE');

        update iss_card_token t
           set t.status                = i_status
             , t.close_session_file_id = case i_status
                                             when iss_api_const_pkg.CARD_TOKEN_STATUS_DEACTIVATED
                                             then i_close_sess_file_id
                                             else t.close_session_file_id
                                         end
             , t.update_oper_id        = case i_status
                                             when iss_api_const_pkg.CARD_TOKEN_STATUS_SUSPEND
                                             then i_init_oper_id

                                             when iss_api_const_pkg.CARD_TOKEN_STATUS_ACTIVE
                                             then i_init_oper_id

                                             when iss_api_const_pkg.CARD_TOKEN_STATUS_DEACTIVATED
                                             then i_init_oper_id

                                             else t.update_oper_id
                                         end
             , t.event_type            = l_event_type
         where t.id = i_token_id;

        if sql%rowcount > 0 then

            trc_log_pkg.debug(
                i_text       => 'Going for register event [#1] for token [#2] status [#3]'
              , i_env_param1 => opr_api_shared_data_pkg.get_param_char('EVENT_TYPE')
              , i_env_param2 => i_token_id
              , i_env_param3 => i_status
            );

            evt_api_status_pkg.add_status_log(
                i_event_type  => opr_api_shared_data_pkg.get_param_char('EVENT_TYPE')
              , i_initiator   => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN
              , i_object_id   => i_token_id
              , i_reason      => nvl(opr_api_shared_data_pkg.g_operation.oper_type, opr_api_shared_data_pkg.get_param_char('EVENT_TYPE'))
              , i_status      => i_status
              , i_eff_date    => get_sysdate
            );

            evt_api_event_pkg.register_event(
                i_event_type    => opr_api_shared_data_pkg.get_param_char('EVENT_TYPE')
              , i_eff_date      => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_card_instance.inst_id)
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN
              , i_object_id     => i_token_id
              , i_inst_id       => l_card_instance.inst_id
              , i_split_hash    => l_card_instance.split_hash
              , i_param_tab     => l_params
            );
        end if;
    end change_status;

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_token_id [#1], i_instance_id [#2], i_status [#3]'
      , i_env_param1 => i_token_id
      , i_env_param2 => i_card_instance_id
      , i_env_param3 => i_status
    );
    
    if i_card_instance_id is not null then
        l_card_instance_id := i_card_instance_id;
    elsif i_token_id is not null then
        begin
            select t.card_instance_id
              into l_card_instance_id
              from iss_card_token t
             where t.id = i_token_id;
        exception
            when no_data_found then
               com_api_error_pkg.raise_error(
                   i_error       => 'CARD_TOKEN_IS_NOT_FOUND'
                 , i_env_param1  => i_token_id
               );
        end;
    else
        l_card_instance_id := null;
    end if;
    
    if i_status = iss_api_const_pkg.CARD_TOKEN_STATUS_DEACTIVATED then
        if i_card_instance_id is not null then
            for i in (
                select t.id as token_id
                  from iss_card_token t
                 where t.card_instance_id = i_card_instance_id
            ) loop
                change_status(
                    i_token_id         => i.token_id
                  , i_card_instance_id => l_card_instance_id
                  , i_status           => i_status
                );
            end loop;
        elsif i_token_id is not null then
            change_status(
                i_token_id         => i_token_id
              , i_card_instance_id => l_card_instance_id
              , i_status           => i_status
            );
        end if;
    elsif i_status in (iss_api_const_pkg.CARD_TOKEN_STATUS_ACTIVE, iss_api_const_pkg.CARD_TOKEN_STATUS_SUSPEND) and i_token_id is not null then
        change_status(
            i_token_id         => i_token_id
          , i_card_instance_id => l_card_instance_id
          , i_status           => i_status
        );
    else
        trc_log_pkg.error(
            i_text       => 'IMPOSSIBLE_TO_CHANGE_CARD_TOKEN_STATUS'
          , i_env_param1 => i_token_id
          , i_env_param2 => i_status
        );
    end if;
end change_token_status;

procedure change_token_status(
    i_event_type            in com_api_type_pkg.t_dict_value
  , i_initiator             in com_api_type_pkg.t_dict_value
  , i_card_instance_id      in com_api_type_pkg.t_medium_id default null
  , i_reason                in com_api_type_pkg.t_dict_value
  , i_inst_id               in com_api_type_pkg.t_tiny_id default null
  , i_eff_date              in date default null
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_token_status: ';
    l_token_id_tab      com_api_type_pkg.t_medium_tab;
    l_new_status_tab    com_api_type_pkg.t_dict_tab;
    l_inst_id_tab       com_api_type_pkg.t_inst_id_tab;
    l_split_hash_tab    com_api_type_pkg.t_tiny_tab;
    l_params            com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_event_type [#1], i_instance_id [#2], i_initiator [#3]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_card_instance_id
      , i_env_param3 => i_initiator
    );
    
    select m.token_id
         , m.new_status
         , m.inst_id
         , m.split_hash
    bulk collect into
           l_token_id_tab
         , l_new_status_tab
         , l_inst_id_tab
         , l_split_hash_tab
      from (
        select t.id     as token_id
             , t.status as old_status
             , (
                   select max(m.result_status) keep (dense_rank first order by m.inst_id, m.priority)
                     from evt_status_map m
                    where m.initial_status = t.status
                      and m.initiator      = i_initiator
                      and m.event_type     = i_event_type
                      and m.inst_id       in (nvl(i_inst_id, i.inst_id), ost_api_const_pkg.DEFAULT_INST)
               ) as new_status
             , i.inst_id
             , i.split_hash
          from iss_card_token t
             , iss_card_instance i
         where t.card_instance_id  = i_card_instance_id
           and t.status           != iss_api_const_pkg.CARD_TOKEN_STATUS_DEACTIVATED
           and i.id                = t.card_instance_id
      ) m
     where m.new_status is not null;

    forall i in 1 .. l_token_id_tab.count
        update iss_card_token
           set status = l_new_status_tab(i)
         where id = l_token_id_tab(i);
    
    for i in 1 .. l_token_id_tab.count loop
        if l_new_status_tab(i) is not null then
            evt_api_status_pkg.add_status_log(
                i_event_type    => i_event_type
              , i_initiator     => i_initiator
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN
              , i_object_id     => l_token_id_tab(i)
              , i_reason        => nvl(i_reason, i_event_type)
              , i_status        => l_new_status_tab(i)
              , i_eff_date      => i_eff_date
            );

            evt_api_event_pkg.register_event(
                i_event_type    => iss_api_const_pkg.EVENT_TYPE_TOKEN_DEACTIVEATE
              , i_eff_date      => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id_tab(i))
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN
              , i_object_id     => l_token_id_tab(i)
              , i_inst_id       => l_inst_id_tab(i)
              , i_split_hash    => l_split_hash_tab(i)
              , i_param_tab     => l_params
            );
        end if;
    end loop;
    
end change_token_status;

/*
 * Relink card tokens to new card.
 * @param  i_card_instance_id  - Card instance identifier
 */
procedure relink_token(
    i_card_instance_id      in com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.relink_token: ';
    l_params                   com_api_type_pkg.t_param_tab;
    l_card_instance            iss_api_type_pkg.t_card_instance;
    l_event_type               com_api_type_pkg.t_dict_value;
    l_init_oper_id             com_api_type_pkg.t_long_id := opr_api_shared_data_pkg.get_operation().id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_instance_id [#1]'
      , i_env_param1 => i_card_instance_id
    );

    l_event_type := opr_api_shared_data_pkg.get_param_char(
                        i_name        => 'EVENT_TYPE'
                      , i_mask_error  => com_api_type_pkg.TRUE
                      , i_error_value => NULL);

    l_card_instance := iss_api_card_instance_pkg.get_instance(
                           i_id           => i_card_instance_id
                         , i_raise_error  => com_api_const_pkg.TRUE
                       );

    for i in (
        select t.id as token_id
          from iss_card_token t
         where t.card_instance_id = l_card_instance.preceding_card_instance_id
           and t.status           = iss_api_const_pkg.CARD_TOKEN_STATUS_ACTIVE
    ) loop
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'updating token_id [#1]. Set card_instance_id [#2], card_id [#3], split_hash [#4]'
          , i_env_param1 => i.token_id
          , i_env_param2 => i_card_instance_id
          , i_env_param3 => l_card_instance.card_id
          , i_env_param4 => l_card_instance.split_hash
        );

        update iss_card_token t
           set t.card_instance_id = i_card_instance_id,
               t.card_id          = l_card_instance.card_id,
               t.split_hash       = l_card_instance.split_hash,
               t.update_oper_id   = decode(l_event_type,
                                        iss_api_const_pkg.EVENT_TYPE_TOKEN_PAN_UPDATE, l_init_oper_id,
                                        null
                                    )
         where t.id               = i.token_id;

        rul_api_shared_data_pkg.load_card_params(
            i_card_id           => l_card_instance.card_id
          , i_card_instance_id  => i_card_instance_id
          , io_params           => l_params
        );

        evt_api_event_pkg.register_event(
            i_event_type        => nvl(l_event_type, iss_api_const_pkg.EVENT_TYPE_TOKEN_RELINK)
          , i_eff_date          => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_card_instance.inst_id)
          , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN
          , i_object_id         => i.token_id
          , i_inst_id           => l_card_instance.inst_id
          , i_split_hash        => l_card_instance.split_hash
          , i_param_tab         => l_params
        );
    end loop;
    
end relink_token;

function get_token(
    i_card_id               in com_api_type_pkg.t_medium_id
  , i_mask_error            in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_card_token_rec
is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_token: ';
    l_card_token               iss_api_type_pkg.t_card_token_rec;
    l_card_instance_id         com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_id [#1], i_mask_error [#2]'
      , i_env_param1 => i_card_id
      , i_env_param2 => i_mask_error
    );

    l_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(
                              i_card_id => i_card_id
                          );

    begin
        select id
             , card_id
             , card_instance_id
             , token
             , status
             , split_hash
             , init_oper_id
             , close_session_file_id
          into l_card_token
          from iss_card_token
         where card_id          = i_card_id
           and card_instance_id = l_card_instance_id
           and status           = iss_api_const_pkg.CARD_TOKEN_STATUS_ACTIVE
           and rownum           < 2;
    exception
        when no_data_found then
            if i_mask_error = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error        => 'ISS_CARD_TOKEN_NOT_FOUND'
                  , i_env_param1   => i_card_id
                  , i_env_param2   => null
                );
            else
                trc_log_pkg.debug(
                    i_text         => 'Card token for card_id [#1] does not found.'
                  , i_env_param1   => i_card_id
                );
                return null;
            end if;
    end;
    
    return l_card_token;
end get_token;

function get_token(
    i_token                 in com_api_type_pkg.t_card_number
  , i_mask_error            in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_card_token_rec
is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_token: ';
    l_card_token               iss_api_type_pkg.t_card_token_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_token [#1], i_mask_error [#2]'
      , i_env_param1 => i_token
      , i_env_param2 => i_mask_error
    );
    
    begin
        select id
             , card_id
             , card_instance_id
             , token
             , status
             , split_hash
             , init_oper_id
             , close_session_file_id
          into l_card_token
          from iss_card_token
         where token            = i_token
           and status           = iss_api_const_pkg.CARD_TOKEN_STATUS_ACTIVE;
    exception
        when no_data_found then
            if i_mask_error = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error        => 'ISS_CARD_TOKEN_NOT_FOUND'
                  , i_env_param1   => null
                  , i_env_param2   => i_token
                );
            else
                trc_log_pkg.debug(
                    i_text         => 'Card token for i_token [#1] does not found.'
                  , i_env_param1   => i_token
                );
                return null;
            end if;
    end;
    
    return l_card_token;
end get_token;

function get_card_id(
    i_token                 in com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_medium_id
is
    l_card_id                  com_api_type_pkg.t_medium_id;
begin
    l_card_id := iss_api_card_token_pkg.get_token(
                     i_token       => i_token
                   , i_mask_error  => com_api_const_pkg.TRUE
                 ).card_id;
    return l_card_id;
end get_card_id;

function get_token_id(
    i_token                 in com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_medium_id
is
    l_token_id com_api_type_pkg.t_medium_id;
begin
    select ct.id
      into l_token_id
      from iss_card_token ct
     where ct.token = i_token
       and ct.close_session_file_id is null;

    return l_token_id;
exception
    when no_data_found then
        return null;
end get_token_id;

end iss_api_card_token_pkg;
/
