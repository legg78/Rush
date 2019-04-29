create or replace package body iss_api_cardholder_pkg is
/*********************************************************
*  Issuer application - API for cardholder <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 26.04.2010 <br />
*  Module: IAP_API_CARDHOLDER_PKG <br />
*  @headcom
**********************************************************/

function count_cardholder_number (
    i_cardholder_number  in     com_api_type_pkg.t_name
  , i_inst_id            in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_boolean is
    l_cnt                com_api_type_pkg.t_count := 0;
begin
    select
        count(*)
    into
        l_cnt
    from
        iss_cardholder c
    where
        cardholder_number = i_cardholder_number
    and
        inst_id = i_inst_id;

    return l_cnt;
end;

procedure create_cardholder(
    o_id                    out com_api_type_pkg.t_medium_id
  , i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_person_id          in     com_api_type_pkg.t_person_id
  , i_cardholder_name    in     com_api_type_pkg.t_name
  , i_relation           in     com_api_type_pkg.t_dict_value
  , i_resident           in     com_api_type_pkg.t_boolean
  , i_nationality        in     com_api_type_pkg.t_curr_code
  , i_marital_status     in     com_api_type_pkg.t_dict_value
  , io_cardholder_number in out com_api_type_pkg.t_name
  , i_inst_id            in     com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX  constant com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.create_cardholder';
    l_params             com_api_type_pkg.t_param_tab;
    l_ret_val            com_api_type_pkg.t_sign;
    l_cardholder_name    com_api_type_pkg.t_name       := upper(i_cardholder_name);
    l_object_key         com_api_type_pkg.t_semaphore_name;
begin
    savepoint sp_create_cardholder;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ': i_customer_id [' || i_customer_id
                             || '], i_inst_id [' || i_inst_id
                             || '], i_person_id [' || i_person_id
                             || '], l_cardholder_name [' || l_cardholder_name || ']'
                             || '], i_relation [' || i_relation || ']'
                             || '], i_resident [' || i_resident || ']'
                             || '], i_nationality [' || i_nationality || ']'
                             || '], i_marital_status [' || i_marital_status || ']'
    );

    io_cardholder_number := upper(io_cardholder_number);

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    );

    o_id := iss_cardholder_seq.nextval;
    l_params('CARDHOLDER_ID') := o_id;
    l_params('INST_ID')       := i_inst_id;

    if io_cardholder_number is not null then
        if rul_api_name_pkg.check_name(
               i_inst_id         => i_inst_id
             , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
             , i_name            => io_cardholder_number
             , i_param_tab       => l_params
           ) = com_api_const_pkg.TRUE
        then
            -- Check cardholder name for uniqueness
            for rec in (
                select 1
                  from iss_cardholder a
                 where a.cardholder_number = io_cardholder_number
                   and a.inst_id           = i_inst_id
            ) loop
                com_api_error_pkg.raise_error(
                    i_error      => 'CARDHOLDER_NUMBER_NOT_UNIQUE'
                  , i_env_param1 => io_cardholder_number
                  , i_env_param2 => i_inst_id
                );
            end loop;

        else
            com_api_error_pkg.raise_error(
                i_error       => 'ENTITY_NAME_DONT_FIT_FORMAT'
              , i_env_param1  => i_inst_id
              , i_env_param2  => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
              , i_env_param3  => io_cardholder_number
            );
        end if;
    else
        io_cardholder_number := rul_api_name_pkg.get_name(
                                    i_inst_id     => i_inst_id
                                  , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                  , i_param_tab   => l_params
                                );
        io_cardholder_number := upper(io_cardholder_number);
    end if;

    l_object_key := io_cardholder_number || '.' || i_inst_id;

    if com_api_lock_pkg.request_lock(
           i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
         , i_object_key  => l_object_key
       ) = 0
    then
        if count_cardholder_number(
               i_cardholder_number => io_cardholder_number
             , i_inst_id           => i_inst_id
           ) != 0
        then
            com_api_error_pkg.raise_error (
                i_error         => 'CARDHOLDER_NUMBER_NOT_UNIQUE'
                , i_env_param1  => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                , i_env_param2  => io_cardholder_number
                , i_env_param3  => i_inst_id
            );
        end if;

        insert into iss_cardholder (
            id
          , person_id
          , cardholder_number
          , cardholder_name
          , relation
          , resident 
          , nationality
          , marital_status
          , inst_id
          , seqnum
        ) values (
            o_id
          , i_person_id
          , io_cardholder_number
          , l_cardholder_name
          , i_relation
          , i_resident
          , i_nationality
          , i_marital_status 
          , i_inst_id
          , 1
        );

        -- Clear parameters
        l_params.delete;

        evt_api_event_pkg.register_event(
            i_event_type     => iss_api_const_pkg.EVENT_TYPE_CARDHOLDER_CREATION
          , i_eff_date       => com_api_sttl_day_pkg.get_sysdate
          , i_object_id      => o_id
          , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
          , i_inst_id        => i_inst_id
          , i_split_hash     => com_api_hash_pkg.get_split_hash(
                                    i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                  , i_object_id   => i_customer_id
                                )
          , i_param_tab      => l_params
        );

        l_ret_val := com_api_lock_pkg.release_lock(
                         i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                       , i_object_key  => l_object_key
                     );
    else
        com_api_error_pkg.raise_error (
            i_error         => 'UNABLE_LOCK_OBJECT'
            , i_env_param1  => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
            , i_env_param2  => io_cardholder_number
        );
    end if;

exception
    when others then
        rollback to savepoint sp_create_cardholder;

        l_ret_val := com_api_lock_pkg.release_lock(
                         i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                       , i_object_key  => l_object_key
                     );

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
end;

/* Procedure changes cardholder name for cardholder and associated card instances,
 * it also generates a new event.
 * i_is_event_forced    — if this flag is set to true then a new event will be generated
                          even when cardholder name isn't changed (or i_cardholder_name is empty)
 */
procedure modify_cardholder(
    i_id                  in     com_api_type_pkg.t_medium_id
  , i_cardholder_name     in     com_api_type_pkg.t_name
  , i_relation            in     com_api_type_pkg.t_dict_value
  , i_resident            in     com_api_type_pkg.t_boolean
  , i_nationality         in     com_api_type_pkg.t_curr_code
  , i_marital_status      in     com_api_type_pkg.t_dict_value
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_is_event_forced     in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name        := lower($$PLSQL_UNIT) || '.modify_cardholder';
    l_id_tab                     com_api_type_pkg.t_medium_tab;
    l_id_list                    com_api_type_pkg.t_full_desc;
    l_params                     com_api_type_pkg.t_param_tab;
    l_cardholder_name            com_api_type_pkg.t_name        := upper(i_cardholder_name);
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ': i_id [' || i_id || '], i_inst_id [' || i_inst_id
                             || '], l_cardholder_name [' || l_cardholder_name
                             || '], i_relation [' || i_relation || ']'
                             || '], i_resident [' || i_resident || ']'
                             || '], i_nationality [' || i_nationality || ']'
                             || '], i_marital_status [' || i_marital_status || ']'
                             || '], i_is_event_forced [' || i_is_event_forced || ']'
    );
    
    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );                             
    if l_cardholder_name is not null then
        update iss_cardholder ch
           set ch.cardholder_name = l_cardholder_name
             , ch.relation = i_relation
             , ch.resident = i_resident
             , ch.nationality = i_nationality
             , ch.marital_status = i_marital_status
         where ch.id = i_id;
     end if;

    -- It is possible that some cardholder is associated with 2 or more cards of different
    -- customers (e.g. father and mother issue different cards for his son, so he is a cardholder
    -- but this cardholder belongs neither to mother customer nor to father customer).
    -- So it is needed to register events for all associated cards.
    if  i_is_event_forced = com_api_const_pkg.TRUE
        or
        sql%rowcount > 0
    then
        for r in (
            select split_hash
              from iss_card
             where cardholder_id = i_id
          group by split_hash
        ) loop
            evt_api_event_pkg.register_event(
                i_event_type  => iss_api_const_pkg.EVENT_TYPE_CARDHOLDER_MODIFY
              , i_eff_date    => com_api_sttl_day_pkg.get_sysdate
              , i_object_id   => i_id
              , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
              , i_inst_id     => i_inst_id
              , i_split_hash  => r.split_hash
              , i_param_tab   => l_params
            );
        end loop;
    end if;

    if l_cardholder_name is not null then
        -- Updating corresponding card instances with state Personalization required,
        -- cardholder names of all other instances can't be changed
        update iss_card_instance
           set cardholder_name = l_cardholder_name
         where state = iss_api_const_pkg.CARD_STATE_PERSONALIZATION
           and id in (
                   select ci.id
                     from iss_card_instance ci
                     join iss_card c           on c.id  = ci.card_id
                     join iss_cardholder ch    on ch.id = c.cardholder_id
                    where ch.id = i_id
                      and ch.inst_id = i_inst_id
               )
        returning id bulk collect into l_id_tab;

        if trc_config_pkg.is_debug = com_api_const_pkg.TRUE then
            -- List of modified card instances for debug logging
            if l_id_tab.count() > 0 then
                for i in l_id_tab.first() .. l_id_tab.last() loop
                    l_id_list := l_id_list || l_id_tab(i) || ', ';
                end loop;
            end if;

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': old cardholder names of instances [#1] were updated'
              , i_env_param1 => substr(l_id_list, 1, length(l_id_list)-2)
            );
        end if;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || ' FAILED with l_id_tab.count() = ' || l_id_tab.count()
                   || ', length(l_id_list) = ' || length(l_id_list)
        );
        raise;
end modify_cardholder;

function get_cardholder_name(
    i_id                  in    com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name
is
    l_cardholder_name     com_api_type_pkg.t_name;
begin
    if i_id is not null then
        begin
            select a.cardholder_name
              into l_cardholder_name
              from iss_cardholder a
             where a.id = i_id;
        exception
            when no_data_found then
                null;
            when others then
                trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_cardholder_name(i_id => [' || i_id || ']) failed');
                raise;
        end;
    end if;

    return l_cardholder_name;
end get_cardholder_name;

function get_cardholder_by_card(
    i_card_number         in    com_api_type_pkg.t_card_number
  , i_mask_error          in    com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_medium_id
is
    l_cardholder_id             com_api_type_pkg.t_medium_id;
begin
    begin
        select c.cardholder_id
          into l_cardholder_id
          from iss_card c
          join iss_card_number cn on cn.card_id = c.id
         where reverse(cn.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => i_card_number));
    exception
        when no_data_found then
            if i_mask_error = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'CARDHOLDER_NOT_FOUND'
                  , i_env_param1 => 'card_mask = ' || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                );
            end if;
    end;
    return l_cardholder_id;
end get_cardholder_by_card;

function get_cardholder_by_card(
    i_card_id             in    com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_medium_id
is
begin
    for rec in (
        select a.cardholder_id
          from iss_card a
         where a.id = i_card_id
    ) loop
        return rec.cardholder_id;
    end loop;
    return null;
end;

function get_cardholder_by_contract(
    i_contract_id         in    com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_medium_id
is
begin
    for rec in (
        select a.cardholder_id
          from iss_card a
         where a.contract_id = i_contract_id
    ) loop
        return rec.cardholder_id;
    end loop;
    return null;
end;

/*
 * Returns record with cardholder data.
 * The following parameters are used for searching in order of priority (until first successful try):
 * 1) i_inst_id + i_cardholder_number;
 * 2) i_inst_id + i_person_id;
 * 3) i_card_id;
 * 4) i_card_number.
 */
function get_cardholder(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_cardholder_number   in     com_api_type_pkg.t_name
  , i_person_id           in     com_api_type_pkg.t_medium_id   default null
  , i_card_id             in     com_api_type_pkg.t_medium_id   default null
  , i_card_number         in     com_api_type_pkg.t_card_number default null
  , i_mask_error          in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_cardholder
 is
    LOG_PREFIX   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_cardholder: ';
    l_result              iss_api_type_pkg.t_cardholder;
    l_params              com_api_type_pkg.t_name;
    l_card_number         com_api_type_pkg.t_card_number;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_inst_id [' || i_inst_id
               || '], i_cardholder_number [' || i_cardholder_number || '], i_person_id [' || i_person_id
               || '], i_card_id [' || i_card_id || '], i_card_number [' || iss_api_card_pkg.get_card_mask(i_card_number) || ']'
    );
    if i_inst_id is not null and i_cardholder_number is not null then
        begin
            select ch.id
                 , ch.person_id
                 , ch.cardholder_number
                 , ch.cardholder_name
                 , ch.relation
                 , ch.resident
                 , ch.nationality 
                 , ch.marital_status
                 , ch.inst_id
              into l_result
              from iss_cardholder ch
             where ch.inst_id = i_inst_id
               and ch.cardholder_number = i_cardholder_number;

            l_params := 'i_inst_id [' || i_inst_id || '], i_cardholder_number [' || i_cardholder_number || ']';
        exception
            when no_data_found then
                null;
        end;
    end if;

    if l_result.id is null and i_inst_id is not null and i_person_id is not null then
        begin
            select ch.id
                 , ch.person_id
                 , ch.cardholder_number
                 , ch.cardholder_name
                 , ch.relation
                 , ch.resident
                 , ch.nationality
                 , ch.marital_status
                 , ch.inst_id
              into l_result
              from iss_cardholder ch
             where ch.inst_id = i_inst_id
               and ch.person_id = i_person_id;

            l_params := 'i_inst_id [' || i_inst_id || '], i_person_id [' || i_person_id || ']';
        exception
            when no_data_found then
                null;
            when too_many_rows then
                if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                    trc_log_pkg.debug(
                        i_text       => 'Several registered cardholders associated with a person with identifier [#1]'
                      , i_env_param1 => i_person_id
                    );
                else
                    -- It can't be raised with i_cardholder_number because of unique index for ch.cardholder_number
                    com_api_error_pkg.raise_error(
                        i_error      => 'PERSON_LINK_WITH_MANY_CARDHOLDERS'
                      , i_env_param1 => i_person_id
                    );
                end if;
        end;
    end if;

    if l_result.id is null and i_card_id is not null then
        begin
            select ch.id
                 , ch.person_id
                 , ch.cardholder_number
                 , ch.cardholder_name
                 , ch.relation
                 , ch.resident
                 , ch.nationality
                 , ch.marital_status 
                 , ch.inst_id
              into l_result
              from iss_card c
              join iss_cardholder ch  on ch.id = c.cardholder_id
             where c.id = i_card_id;

            l_params := 'i_card_id [' || i_card_id || ']';
        exception
            when no_data_found then
                null;
        end;
    end if;

    if l_result.id is null and i_card_number is not null then
        begin
            l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);

            select ch.id
                 , ch.person_id
                 , ch.cardholder_number
                 , ch.cardholder_name
                 , ch.relation
                 , ch.resident
                 , ch.nationality
                 , ch.marital_status 
                 , ch.inst_id
              into l_result
              from iss_card c
              join iss_card_number cn on cn.card_id = c.id
              join iss_cardholder ch  on ch.id = c.cardholder_id
             where reverse(cn.card_number) = reverse(l_card_number);

            l_params := 'i_card_number [' || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number) || ']';
        exception
            when no_data_found then
                null;
        end;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'cardholder ' || case when l_result.id is null then 'NOT found' else 'found by '||l_params end);

    if l_result.id is null and nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error      => 'CARDHOLDER_NOT_FOUND'
          , i_env_param1 => l_params
          , i_env_param2 => i_inst_id
        );
    end if;

    return l_result;
end get_cardholder;

function get_cardholder(
    i_cardholder_id       in     com_api_type_pkg.t_long_id
  , i_mask_error          in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_cardholder as
    l_result              iss_api_type_pkg.t_cardholder;
begin
    select ch.id
         , ch.person_id
         , ch.cardholder_number
         , ch.cardholder_name
         , ch.relation
         , ch.resident
         , ch.nationality
         , ch.marital_status 
         , ch.inst_id
      into l_result
      from iss_cardholder ch  
     where ch.id = i_cardholder_id;
     
     return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'CARDHOLDER_NOT_FOUND'
              , i_env_param1 => i_cardholder_id
            );
        end if;
        return l_result;
end;


procedure get_cardholder_info_by_card(
    i_card_id             in     com_api_type_pkg.t_medium_id
  , o_address                out com_api_type_pkg.t_double_name
  , o_city                   out com_api_type_pkg.t_double_name
  , o_country                out com_api_type_pkg.t_country_code
  , o_postal_code            out com_api_type_pkg.t_postal_code
  , o_cardholder_name        out com_api_type_pkg.t_name
  , o_birthday               out com_api_type_pkg.t_date_short
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_cardholder_info_by_card: ';
    l_cardhoder_id           com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_card_id [' || i_card_id || ']'
    );

    select ch.id
         , p.name
         , p.birthday
         , trim(ad.street||' '||ad.house) as address
         , ad.city
         , ad.country_name
         , ad.postal_code
      into l_cardhoder_id
         , o_cardholder_name
         , o_birthday
         , o_address
         , o_city
         , o_country
         , o_postal_code
      from iss_cardholder ch
         , iss_card c
         , (select ca.id
                 , ca.lang
                 , ca.country
                 , ca.region
                 , ca.city
                 , ca.street
                 , ca.house
                 , ca.apartment
                 , ca.postal_code
                 , ca.region_code
                 , ct.name country_name
                 , ob.object_id
                 , row_number() over (partition by ob.object_id order by decode(ob.address_type, 'ADTPHOME', -1, ob.address_id)
                                                                       , decode(ca.lang, com_api_const_pkg.LANGUAGE_ENGLISH, 1, 2)) rn
              from com_address ca
                 , com_address_object ob
                 , com_country ct
             where ca.id = ob.address_id
               and ob.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
               and ct.code(+) = ca.country
           ) ad
         , (select id
                 , get_translit(trim(surname||' '||first_name)) name
                 , to_char(birthday, 'mmddyyyy') birthday
                 , row_number() over (partition by id order by decode(lang, com_api_const_pkg.LANGUAGE_ENGLISH, 1, 2)) rn
              from com_person
           ) p
     where c.cardholder_id = ch.id
       and c.id = i_card_id
       and ch.id = ad.object_id(+)
       and ch.person_id = p.id
       and p.rn = 1
       and ad.rn(+) = 1;
exception
    when no_data_found then
        trc_log_pkg.debug(LOG_PREFIX || 'cardholder NOT found');
end;

end iss_api_cardholder_pkg;
/
