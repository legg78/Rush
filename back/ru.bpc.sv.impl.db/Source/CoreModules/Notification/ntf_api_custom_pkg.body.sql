create or replace package body ntf_api_custom_pkg is
/*********************************************************
 *  Custom events and custom event objects API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 12.02.2016 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2016-12-12 10:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: NTF_API_CUSTOM_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Procedure inserts a new custom EVENT's record or updates existed one if its ID is passed.
 * @io_id     ID of record that should be updated,
              if it is NOT passed, it will contain ID of a new (inserted) record
 */
procedure set_custom_event(
    io_id                   in out com_api_type_pkg.t_medium_id
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_channel_id            in     com_api_type_pkg.t_tiny_id
  , i_delivery_address      in     com_api_type_pkg.t_full_desc
  , i_delivery_time         in     com_api_type_pkg.t_name
  , i_status                in     com_api_type_pkg.t_dict_value
  , i_mod_id                in     com_api_type_pkg.t_tiny_id
  , i_start_date            in     date
  , i_end_date              in     date
  , i_customer_id           in     com_api_type_pkg.t_long_id
  , i_contact_type          in     com_api_type_pkg.t_dict_value
) is
    l_delivery_time                com_api_type_pkg.t_name;
begin
    l_delivery_time := lpad(substr(i_delivery_time, 1, instr(i_delivery_time, '-') - 1), 2, '0')
                    || '-'
                    || replace(
                           lpad(substr(i_delivery_time, instr(i_delivery_time, '-') + 1), 2, '0')
                         , '00'
                         , '24'
                       );

    if io_id is null then
        io_id := ntf_custom_event_seq.nextval;

        insert into ntf_custom_event(
            id
          , event_type
          , entity_type
          , object_id
          , channel_id
          , delivery_address
          , delivery_time
          , mod_id
          , start_date
          , end_date
          , status
          , customer_id
          , contact_type
        ) values (
            io_id
          , i_event_type
          , i_entity_type
          , i_object_id
          , i_channel_id
          , i_delivery_address
          , l_delivery_time
          , i_mod_id
          , i_start_date
          , i_end_date
          , i_status
          , i_customer_id
          , i_contact_type
        );
    else
        update ntf_custom_event
           set channel_id       = i_channel_id
             , delivery_address = i_delivery_address
             , delivery_time    = l_delivery_time
             , mod_id           = i_mod_id
             , start_date       = i_start_date
             , end_date         = i_end_date
             , event_type       = i_event_type
             , status           = i_status
             , customer_id      = i_customer_id
             , contact_type     = i_contact_type
         where id               = io_id;
    end if;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'CUSTOM_EVENT_ALREADY_EXISTS'
          , i_env_param1 => i_event_type
          , i_env_param2 => i_entity_type
          , i_env_param3 => i_object_id
          , i_env_param4 => i_channel_id
          , i_env_param5 => i_delivery_address
          , i_env_param6 => i_customer_id
        );

end set_custom_event;

/*
 * Procedure inserts/updates a custom OBJECT's record by unique key i_custom_event_id + i_object_id.
 */
procedure set_custom_object(
    i_custom_event_id       in     com_api_type_pkg.t_short_id
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_is_active             in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_custom_object: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START i_custom_event_id=' || i_custom_event_id || ' i_object_id=' || i_object_id 
                                 || ' i_entity_type=' || i_entity_type || ' i_is_active=' || i_is_active
    );
    merge into ntf_custom_object dst
    using (
        select i_custom_event_id as custom_event_id
             , i_object_id       as object_id
          from dual
    ) src
    on (
            src.custom_event_id = dst.custom_event_id
        and src.object_id       = dst.object_id
    )
    when matched then
        update set is_active = i_is_active
                 , entity_type = i_entity_type
    when not matched then
        insert (
            id
          , custom_event_id
          , object_id
          , entity_type
          , is_active
        ) values (
            ntf_custom_object_seq.nextval
          , src.custom_event_id
          , src.object_id
          , i_entity_type
          , i_is_active
        );

end set_custom_object;

/*
 * Function returns count of custom objects that are linked with specified custom event.
 * @i_custom_event_id       ID of parent custom event which custom object should be calculated
 * @i_excluded_object_id    custom object ID that should NOT be calculated (optional)
 */
function get_active_objects_count(
    i_custom_event_id       in     com_api_type_pkg.t_medium_id
  , i_excluded_object_id    in     com_api_type_pkg.t_long_id      default null
) return com_api_type_pkg.t_count
is
    l_count                        com_api_type_pkg.t_count := 0;
begin
    select count(*)
      into l_count
      from ntf_custom_object
     where custom_event_id = i_custom_event_id
       and (i_excluded_object_id is null or object_id != i_excluded_object_id)
       and is_active = com_api_const_pkg.TRUE;

    return l_count;
end;

/*
 * Procedure insert/update record in ntf_custom_event and related record in ntf_custom_object.
 */
procedure set_event_with_object(
    io_id                   in out com_api_type_pkg.t_medium_id
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_channel_id            in     com_api_type_pkg.t_tiny_id
  , i_delivery_address      in     com_api_type_pkg.t_full_desc
  , i_delivery_time         in     com_api_type_pkg.t_name
  , i_status                in     com_api_type_pkg.t_dict_value
  , i_mod_id                in     com_api_type_pkg.t_tiny_id
  , i_start_date            in     date
  , i_end_date              in     date
  , i_customer_id           in     com_api_type_pkg.t_long_id
  , i_contact_type          in     com_api_type_pkg.t_dict_value
  , i_linked_object_id      in     com_api_type_pkg.t_medium_id
  , i_is_active             in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_event_with_object: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START io_id=' || io_id || ' i_event_type=' || i_event_type || ' i_entity_type=' || i_entity_type
                                 || ' i_object_id=' || i_object_id || ' i_customer_id=' || i_customer_id || ' i_linked_object_id=' || i_linked_object_id
                                 || ' i_is_active=' || i_is_active
    );

    set_custom_event(
        io_id              => io_id
      , i_event_type       => i_event_type
      , i_entity_type      => i_entity_type
      , i_object_id        => i_object_id
      , i_channel_id       => i_channel_id
      , i_delivery_address => i_delivery_address
      , i_delivery_time    => i_delivery_time
      , i_status           => case
                                  when i_status is not null then
                                      i_status
                                  when i_is_active = com_api_const_pkg.TRUE
                                    or i_linked_object_id is not null -- and i_is_active = false
                                       and io_id is not null
                                       and get_active_objects_count(
                                               i_custom_event_id    => io_id
                                             , i_excluded_object_id => i_linked_object_id
                                           ) > 0
                                  then
                                      ntf_api_const_pkg.STATUS_ALWAYS_SEND
                                  else
                                      ntf_api_const_pkg.STATUS_DO_NOT_SEND
                              end
      , i_mod_id           => i_mod_id
      , i_start_date       => i_start_date
      , i_end_date         => i_end_date
      , i_customer_id      => i_customer_id
      , i_contact_type     => i_contact_type
    );

    if  i_linked_object_id is not null
        and
        i_is_active is not null
    then
        set_custom_object(
            i_custom_event_id => io_id
          , i_object_id       => i_linked_object_id
          , i_entity_type     => i_entity_type 
          , i_is_active       => i_is_active
        );
    end if;
end set_event_with_object;

--procedure remove_custom_event(
--    i_id                    in      com_api_type_pkg.t_medium_id
--) is
--begin
--    delete from ntf_custom_object
--     where custom_event_id = i_id;
--
--    delete from ntf_custom_event
--     where id = i_id;
--end;

--procedure remove_custom_object(
--    i_id                    in      com_api_type_pkg.t_long_id
--) is
--begin
--    delete from ntf_custom_object
--     where id = i_id;
--end;

/**
*    Parse a string with comma-separated phones and store the data in ntf_custom_*
*    @param i_mobile              - string with comma-separated phones
*    @param i_card_id             - card identifier
*    @param i_customer_id         - customer identifier
*    @param i_scheme_notification - notification schema identifier
*/
procedure add_custom_events(
    i_mobile                in     com_api_type_pkg.t_name
  , i_card_id               in     com_api_type_pkg.t_medium_id
  , i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_scheme_notification   in     com_api_type_pkg.t_tiny_id
) is
    l_mobile_phone              com_api_type_pkg.t_name;
    l_is_main                   com_api_type_pkg.t_boolean;
    l_object_id                 com_api_type_pkg.t_long_id;
    l_custom_event_id           com_api_type_pkg.t_medium_id;
    l_custom_object_id          com_api_type_pkg.t_long_id;
    l_length                    com_api_type_pkg.t_long_id;
    l_mobile                    com_api_type_pkg.t_name;
begin
    l_mobile := i_mobile;
    loop
        -- parse phone numbers
        if instr(l_mobile, ',') = 0 then
            l_length := length(l_mobile);
        else
            l_length := instr(l_mobile, ',') - 1;
        end if;

        l_mobile_phone := trim(substr(l_mobile, 1, l_length));
        if trim(l_mobile_phone) not like '+%' then
            l_mobile_phone := '+' || trim(l_mobile_phone);
            l_mobile := '+' || trim(l_mobile);
        end if;
        l_mobile := trim(substr(l_mobile, instr(l_mobile, ',') + 1));

        trc_log_pkg.info('l_mobile_phone = ' || l_mobile_phone);

        select decode(cu.entity_type, com_api_const_pkg.ENTITY_TYPE_COMPANY, 0,  decode(cu.object_id, ca.person_id, 1, 0)) is_main
          into l_is_main
          from iss_card_vw c
          join iss_cardholder ca on ca.id = c.cardholder_id
          join prd_customer cu on cu.id = c.customer_id
         where c.id = i_card_id;

        for event in (
            select event_type
                 , entity_type
                 , channel_id
                 , delivery_time
                 , status
                 , contact_type
              from ntf_scheme_event
             where scheme_id = i_scheme_notification
               and (entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER or
                   (entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER and l_is_main = com_api_type_pkg.TRUE)
               )
        ) loop
            if event.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                then l_object_id := iss_api_cardholder_pkg.get_cardholder_by_card(i_card_id => i_card_id);

            elsif event.entity_type = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                then l_object_id := iss_api_card_pkg.get_customer_id (i_card_id => i_card_id);
            end if;

            begin
                select ce.id as custom_event_id
                     , ceo.id as custom_object_id
                  into l_custom_event_id
                     , l_custom_object_id
                  from ntf_custom_event  ce
                  join ntf_custom_object ceo on ceo.custom_event_id = ce.id
                 where ce.event_type        = event.event_type
                   and ce.entity_type       = event.entity_type
                   and ce.object_id         = l_object_id
                   and ce.channel_id        = event.channel_id
                   and (ceo.object_id       = i_card_id            or i_card_id            is null)
                   and (ce.delivery_address = trim(l_mobile_phone) or trim(l_mobile_phone) is null)
                   and (ce.contact_type     = event.contact_type   or ce.contact_type      is null);

                -- if resords are found, then update states
                ntf_api_custom_pkg.set_custom_event(
                    io_id                   => l_custom_event_id
                  , i_event_type            => event.event_type
                  , i_entity_type           => event.entity_type
                  , i_object_id             => l_object_id
                  , i_channel_id            => event.channel_id
                  , i_delivery_address      => trim(l_mobile_phone)
                  , i_delivery_time         => event.delivery_time
                  , i_status                => nvl(event.status, ntf_api_const_pkg.STATUS_ALWAYS_SEND)
                  , i_mod_id                => null
                  , i_start_date            => get_sysdate
                  , i_end_date              => null
                  , i_customer_id           => i_customer_id
                  , i_contact_type          => event.contact_type
                );

            exception
                when no_data_found then
                    ntf_ui_custom_pkg.set_custom_event (
                        io_id                   => l_custom_event_id
                      , i_event_type            => event.event_type
                      , i_entity_type           => event.entity_type
                      , i_object_id             => l_object_id
                      , i_channel_id            => event.channel_id
                      , i_delivery_address      => trim(l_mobile_phone)
                      , i_delivery_time         => event.delivery_time
                      , i_status                => nvl(event.status, ntf_api_const_pkg.STATUS_ALWAYS_SEND)
                      , i_mod_id                => null
                      , i_start_date            => get_sysdate
                      , i_end_date              => null
                      , i_customer_id           => i_customer_id
                      , i_contact_type          => event.contact_type
                    );

                    ntf_ui_custom_pkg.set_custom_object (
                        io_id                   => l_custom_object_id
                      , i_custom_event_id       => l_custom_event_id
                      , i_object_id             => i_card_id
                      , i_is_active             => com_api_type_pkg.TRUE
                      , i_entity_type           => iss_api_const_pkg.ENTITY_TYPE_CARD
                    );

            end;

            l_custom_event_id := null;
            l_custom_object_id := null;
        end loop;

        if l_mobile = l_mobile_phone then
            exit;
        end if;

    end loop;

end add_custom_events;

procedure deactivate_custom_event(
    i_custom_event_id       in     com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug (
        i_text        => 'Deactivate Custom Event event[#1]'
      , i_env_param1  => i_custom_event_id
    );

    update ntf_custom_event
       set status = ntf_api_const_pkg.STATUS_DO_NOT_SEND
     where id = i_custom_event_id;

end deactivate_custom_event;

procedure clone_custom_event(
    i_src_object_id             in     com_api_type_pkg.t_long_id
  , i_src_entity_type           in     com_api_type_pkg.t_dict_value
  , i_dst_object_id             in     com_api_type_pkg.t_long_id
  , i_dst_entity_type           in     com_api_type_pkg.t_dict_value
  , i_linked_object_id          in     com_api_type_pkg.t_medium_id
  , i_is_active                 in     com_api_type_pkg.t_boolean
) as
    l_custom_event_id                  com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug('clone_custom_event; '
                   || 'i_src_object_id = ' || i_src_object_id || '; '
                   || 'i_src_entity_type = ' || i_src_entity_type || '; '
                   || 'i_dst_object_id = ' || i_dst_object_id || '; '
                   || 'i_dst_entity_type = ' || i_dst_entity_type || '; '
                   || 'i_linked_object_id = ' || i_linked_object_id || '; '
    );

    for r in (
        select e.id
             , e.event_type
             , e.channel_id
             , e.delivery_address
             , e.delivery_time
             , e.status
             , e.mod_id
             , e.start_date
             , e.end_date
             , e.customer_id
             , e.contact_type
             , (select e2.id
                 from ntf_custom_event e2
                where e2.entity_type          = i_dst_entity_type
                  and e2.object_id            = i_dst_object_id
                  and e2.channel_id           = e.channel_id
                  and e2.delivery_address     = e.delivery_address
                  and nvl(e2.event_type, '#') = nvl(e.event_type, '#')) as custom_event_id
          from ntf_custom_event e
         where e.entity_type           = i_src_entity_type
           and e.object_id             = i_src_object_id
    )
    loop
        trc_log_pkg.debug('custom_event_id = ' || r.custom_event_id||'; ');

        if r.custom_event_id is not null then
            l_custom_event_id := r.custom_event_id;
        else
            l_custom_event_id := null;

            set_custom_event(
                io_id                   => l_custom_event_id
              , i_event_type            => r.event_type
              , i_entity_type           => i_dst_entity_type
              , i_object_id             => i_dst_object_id
              , i_channel_id            => r.channel_id
              , i_delivery_address      => r.delivery_address
              , i_delivery_time         => r.delivery_time
              , i_status                => r.status
              , i_mod_id                => r.mod_id
              , i_start_date            => r.start_date
              , i_end_date              => r.end_date
              , i_customer_id           => r.customer_id
              , i_contact_type          => r.contact_type
            );
        end if;
        
        if i_is_active = com_api_const_pkg.TRUE 
           and i_linked_object_id is not null
        then
            set_custom_object(
                i_custom_event_id => l_custom_event_id
              , i_object_id       => i_linked_object_id
              , i_entity_type     => i_dst_entity_type
              , i_is_active       => i_is_active
            );
        end if;
    end loop;
end clone_custom_event;

end ntf_api_custom_pkg;
/
