create or replace package body prd_api_service_pkg is
/*********************************************************
 *  API for services of products <br />
 *  Created by Kopachev D. (kopachev@bpcbt.com)  at 20.10.2011 <br />
 *  Module: PRD_API_SERVICE_PKG <br />
 *  @headcom
 **********************************************************/

procedure add_service_log (
    i_service_object_id   in      com_api_type_pkg.t_medium_id
  , i_start_date          in      date
  , i_end_date            in      date
  , i_split_hash          in      com_api_type_pkg.t_tiny_id
) is
begin
    insert into prd_service_log_vw (
        id
      , service_object_id
      , start_date
      , end_date
      , split_hash
    ) values (
        prd_service_log_seq.nextval
      , i_service_object_id
      , i_start_date
      , i_end_date
      , i_split_hash
    );
end;

function get_active_service_id(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_attr_name           in     com_api_type_pkg.t_name
  , i_service_type_id     in     com_api_type_pkg.t_short_id     default null
  , i_split_hash          in     com_api_type_pkg.t_tiny_id      default null
  , i_eff_date            in     date
  , i_last_active         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_mask_error          in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_inst_id             in     com_api_type_pkg.t_inst_id      default null
) return com_api_type_pkg.t_short_id
is
    l_service_id          com_api_type_pkg.t_short_id;
    l_service_type_id     com_api_type_pkg.t_short_id;
    l_eff_date            date;
    l_split_hash          com_api_type_pkg.t_tiny_id;
    l_inst_id             com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug('entity_type = '||i_entity_type||', object_id='||i_object_id
        ||', attr_name='||i_attr_name
        ||', eff_date='||i_eff_date);

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(
            i_entity_type   => i_entity_type
            , i_object_id   => i_object_id
            , i_mask_errors => com_api_const_pkg.TRUE
        );
    else
        l_inst_id := i_inst_id;
    end if;

    l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id));

    if i_service_type_id is null then
        l_service_type_id := get_service_type_id(i_attr_name => i_attr_name);
    else
        l_service_type_id := i_service_type_id;
    end if;

    if nvl(i_last_active, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then

        select min(service_id)
          into l_service_id
          from prd_service_object o
             , prd_service s
         where o.service_id      = s.id
           and s.service_type_id = l_service_type_id
           and o.entity_type     = i_entity_type
           and o.object_id       = i_object_id
           and o.split_hash      = l_split_hash
           and l_eff_date between nvl(trunc(o.start_date), l_eff_date) and nvl(o.end_date, trunc(l_eff_date)+1);
    else

        select max(service_id)
          into l_service_id
          from prd_service_object o
             , prd_service s
         where o.service_id      = s.id
           and s.service_type_id = l_service_type_id
           and o.entity_type     = i_entity_type
           and o.object_id       = i_object_id
           and o.split_hash      = l_split_hash
           and l_eff_date       >= nvl(trunc(o.start_date), l_eff_date);
    end if;

    if l_service_id is null then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug (
                i_text        => 'PRD_NO_ACTIVE_SERVICE'
              , i_env_param1  => i_entity_type
              , i_env_param2  => i_object_id
              , i_env_param3  => i_attr_name
              , i_env_param4  => l_eff_date
              , i_entity_type => i_entity_type
              , i_object_id   => i_object_id
            );
        else
            com_api_error_pkg.raise_error(
                i_error       => 'PRD_NO_ACTIVE_SERVICE'
              , i_env_param1  => i_entity_type
              , i_env_param2  => i_object_id
              , i_env_param3  => i_attr_name
              , i_env_param4  => l_eff_date
              , i_entity_type => i_entity_type
              , i_object_id   => i_object_id
            );
        end if;
    end if;
    trc_log_pkg.debug('get_active_service_id='||l_service_id);
    return l_service_id;
exception
    when no_data_found then
        trc_log_pkg.debug (
            i_text       => 'Attribute [#1] not found'
          , i_env_param1 => i_attr_name
        );
        return null;
end;

function get_active_service_id(
    i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_attr_type           in     com_api_type_pkg.t_name
  , i_eff_date            in     date
) return com_api_type_pkg.t_short_id
is
    l_attr_name                  com_api_type_pkg.t_name;
    l_split_hash                 com_api_type_pkg.t_tiny_id;
begin
    l_split_hash :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
        );

    begin
        select attr_name
          into l_attr_name
          from prd_attribute
         where object_type = i_attr_type;
    exception
        when no_data_found or too_many_rows then
            com_api_error_pkg.raise_error(
                i_error       => 'ATTRIBUTE_NOT_FOUND'
              , i_env_param1  => i_attr_type
              , i_entity_type => i_entity_type
              , i_object_id   => i_object_id
            );
    end;

    return
        get_active_service_id(
            i_entity_type => i_entity_type
          , i_object_id   => i_object_id
          , i_attr_name   => l_attr_name
          , i_split_hash  => l_split_hash
          , i_eff_date    => i_eff_date
          , i_last_active => com_api_const_pkg.TRUE
        );
end;

procedure reset_counter_next_date(
    i_id                   in     com_api_type_pkg.t_long_id
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
) is
    l_service_id          com_api_type_pkg.t_short_id;
    l_service_type_id     com_api_type_pkg.t_short_id;
    l_split_hash          com_api_type_pkg.t_tiny_id;
    l_cycle_type_count    com_api_type_pkg.t_short_id;
    l_cycle_type_tab      com_dict_tpt    := com_dict_tpt();
begin
    trc_log_pkg.debug('Reset all cycle counter of service object ['|| i_id ||'], entity_type [' || i_entity_type || '], object_id ['|| i_object_id ||']');

    select o.service_id
         , s.service_type_id
         , o.split_hash
      into l_service_id
         , l_service_type_id
         , l_split_hash
      from prd_service_object o
         , prd_service s
     where o.id = i_id
       and s.id = o.service_id;

    select cycle_type
      bulk collect into l_cycle_type_tab
      from (
          select a.object_type as cycle_type
            from prd_attribute a
               , prd_service_type t
           where t.id              = l_service_type_id
             and a.service_type_id = t.id
             and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_CYCLE
           union
          select c.cycle_type
            from prd_service_type t
               , prd_attribute a
               , fcl_fee f
               , fcl_cycle c
           where t.id              = l_service_type_id
             and a.service_type_id = t.id
             and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
             and f.fee_type        = a.object_type
             and f.cycle_id        = c.id
           union
          select c.cycle_type
            from prd_attribute a
               , prd_service_type t
               , fcl_limit l
               , fcl_cycle c
           where t.id              = l_service_type_id
             and a.service_type_id = t.id
             and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
             and l.limit_type      = a.object_type
             and l.cycle_id        = c.id
      );

    l_cycle_type_count := l_cycle_type_tab.count;

    trc_log_pkg.debug('l_service_type_id ['|| l_service_type_id ||'], l_cycle_type_count [' || l_cycle_type_count || ']');

    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

        update fcl_cycle_counter c
           set c.next_date    = null
         where c.object_id    = i_object_id
           and c.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and c.split_hash   = l_split_hash
           and exists (
                   select column_value
                     from table(cast(l_cycle_type_tab as com_dict_tpt)) ids
                    where ids.column_value  = c.cycle_type
                      and rownum           <= l_cycle_type_count
               );

        update fcl_cycle_counter c
           set c.next_date    = null
         where c.object_id   in (select i.id from crd_invoice i where i.account_id = i_object_id and i.split_hash = l_split_hash)
           and c.entity_type  = crd_api_const_pkg.ENTITY_TYPE_INVOICE
           and c.split_hash   = l_split_hash
           and exists (
                   select column_value
                     from table(cast(l_cycle_type_tab as com_dict_tpt)) ids
                    where ids.column_value  = c.cycle_type
                      and rownum           <= l_cycle_type_count
               );

    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then

        update fcl_cycle_counter c
           set c.next_date    = null
         where c.object_id    = i_object_id
           and c.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
           and c.split_hash   = l_split_hash
           and exists (
                   select column_value
                     from table(cast(l_cycle_type_tab as com_dict_tpt)) ids
                    where ids.column_value  = c.cycle_type
                      and rownum           <= l_cycle_type_count
               );

        update fcl_cycle_counter c
           set c.next_date    = null
         where c.object_id   in (select i.id from iss_card_instance i where i.card_id = i_object_id and i.split_hash = l_split_hash)
           and c.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
           and c.split_hash   = l_split_hash
           and exists (
                   select column_value
                     from table(cast(l_cycle_type_tab as com_dict_tpt)) ids
                    where ids.column_value  = c.cycle_type
                      and rownum           <= l_cycle_type_count
               );

    else
        update fcl_cycle_counter c
           set c.next_date    = null
         where c.object_id    = i_object_id
           and c.entity_type  = i_entity_type
           and c.split_hash   = l_split_hash
           and exists (
                   select column_value
                     from table(cast(l_cycle_type_tab as com_dict_tpt)) ids
                    where ids.column_value  = c.cycle_type
                      and rownum           <= l_cycle_type_count
               );

    end if;

    trc_log_pkg.debug (
        i_text       => 'Updated [' ||sql%rowcount || '] rows'
    );

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'SERVICE_TYPE_NOT_FOUND'
          , i_env_param1  => i_id
        );
end;

procedure change_service_status (
    i_id                   in     com_api_type_pkg.t_long_id
  , i_sysdate              in     date
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_enable_event_type    in     com_api_type_pkg.t_dict_value
  , i_disable_event_type   in     com_api_type_pkg.t_dict_value
  , i_forced               in     com_api_type_pkg.t_boolean
  , i_params               in     com_api_type_pkg.t_param_tab
  , i_split_hash           in     com_api_type_pkg.t_tiny_id        default null
) is
    l_postponed_event     evt_api_type_pkg.t_postponed_event;
begin
    change_service_status (
        i_id                    => i_id
      , i_sysdate               => i_sysdate
      , i_entity_type           => i_entity_type
      , i_object_id             => i_object_id
      , i_inst_id               => i_inst_id
      , i_enable_event_type     => i_enable_event_type
      , i_disable_event_type    => i_disable_event_type
      , i_forced                => i_forced
      , i_params                => i_params
      , i_split_hash            => i_split_hash
      , i_need_postponed_event  => com_api_type_pkg.FALSE
      , o_postponed_event       => l_postponed_event
    );
end;

procedure change_service_status (
    i_id                    in     com_api_type_pkg.t_long_id
  , i_sysdate               in     date
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_enable_event_type     in     com_api_type_pkg.t_dict_value
  , i_disable_event_type    in     com_api_type_pkg.t_dict_value
  , i_forced                in     com_api_type_pkg.t_boolean
  , i_params                in     com_api_type_pkg.t_param_tab
  , i_split_hash            in     com_api_type_pkg.t_tiny_id       default null
  , i_need_postponed_event  in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , o_postponed_event          out evt_api_type_pkg.t_postponed_event
) is
    l_sysdate                      date;
    l_split_hash                   com_api_type_pkg.t_tiny_id;
    l_need_postponed_event         com_api_type_pkg.t_boolean    := nvl(i_need_postponed_event, com_api_type_pkg.FALSE);
begin
    l_sysdate := nvl(i_sysdate, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id));

    trc_log_pkg.debug(
        i_text       => 'change_service_status: id [#1], i_split_hash [#2], i_enable_event_type [#3], i_disable_event_type [#4], i_forced [#5], l_sysdate [#6]'
      , i_env_param1 => i_id
      , i_env_param2 => i_split_hash
      , i_env_param3 => i_enable_event_type
      , i_env_param4 => i_disable_event_type
      , i_env_param5 => i_forced
      , i_env_param6 => to_char(l_sysdate, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    update prd_service_object_vw
       set status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
     where id     = i_id
       and status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE
       and (start_date <= l_sysdate or i_forced = com_api_type_pkg.TRUE);

    if sql%rowcount > 0 then
        trc_log_pkg.debug(
            i_text       => 'change_service_status: set id [#1], status [#2]'
          , i_env_param1 => i_id
          , i_env_param2 => prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
        );

        if l_need_postponed_event = com_api_type_pkg.TRUE then
            evt_api_event_pkg.add_postponed_event (
                i_event_type      => i_enable_event_type
              , i_eff_date        => l_sysdate
              , i_object_id       => i_object_id
              , i_entity_type     => i_entity_type
              , i_inst_id         => i_inst_id
              , i_split_hash      => l_split_hash
              , i_param_tab       => i_params
              , o_postponed_event => o_postponed_event
            );
        else
            evt_api_event_pkg.register_event (
                i_event_type      => i_enable_event_type
              , i_eff_date        => l_sysdate
              , i_object_id       => i_object_id
              , i_entity_type     => i_entity_type
              , i_inst_id         => i_inst_id
              , i_split_hash      => l_split_hash
              , i_param_tab       => i_params
            );
        end if;
    else
        for r in (
            select a.id service_object_id
                 , t.disable_event_type
              from prd_service_object a
                 , prd_service b
                 , prd_service_type t
             where (a.entity_type, a.object_id, a.service_id) in
                     (
                      select x.entity_type, x.object_id, s.service_id
                        from (
                              select o.service_id
                                   , o.entity_type
                                   , o.object_id
                                   , c.product_id
                                from prd_service_object o
                                   , prd_contract c
                               where o.id     = i_id
                                 and o.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
                                 and (o.end_date <= l_sysdate or i_forced = com_api_type_pkg.TRUE)
                                 and c.id     = o.contract_id
                             ) x
                           , prd_product_service s
                     connect by prior s.id   = s.parent_id
                       start with s.service_id = x.service_id
                              and s.product_id = x.product_id
                    )
              and a.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
              and a.service_id = b.id
              and b.service_type_id = t.id
        ) loop
            update prd_service_object_vw
               set status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED
             where id     = r.service_object_id;

            trc_log_pkg.debug(
                i_text       => 'change_service_status: set id [#1], status [#2]'
              , i_env_param1 => r.service_object_id
              , i_env_param2 => prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED
            );

            reset_counter_next_date(
                i_id           => r.service_object_id
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
            );

            if l_need_postponed_event = com_api_type_pkg.TRUE then
                evt_api_event_pkg.add_postponed_event (
                    i_event_type      => r.disable_event_type
                  , i_eff_date        => l_sysdate
                  , i_object_id       => i_object_id
                  , i_entity_type     => i_entity_type
                  , i_inst_id         => i_inst_id
                  , i_split_hash      => l_split_hash
                  , i_param_tab       => i_params
                  , o_postponed_event => o_postponed_event
                );
            else
                evt_api_event_pkg.register_event (
                    i_event_type      => r.disable_event_type
                  , i_eff_date        => l_sysdate
                  , i_object_id       => i_object_id
                  , i_entity_type     => i_entity_type
                  , i_inst_id         => i_inst_id
                  , i_split_hash      => l_split_hash
                  , i_param_tab       => i_params
                );
            end if;
        end loop;

    end if;

end;

procedure change_service_object (
    i_service_id          in      com_api_type_pkg.t_tiny_id
  , i_entity_type         in      com_api_type_pkg.t_dict_value
  , i_object_id           in      com_api_type_pkg.t_long_id
  , i_params              in      com_api_type_pkg.t_param_tab
  , i_status              in      com_api_type_pkg.t_dict_value
) is
    l_contract_id         com_api_type_pkg.t_medium_id;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_start_date          date;
    l_end_date            date;
begin

    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        select contract_id
             , inst_id
          into l_contract_id
             , l_inst_id
          from iss_card
         where id = i_object_id;
    elsif i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select contract_id
             , inst_id
          into l_contract_id
             , l_inst_id
          from prd_customer
         where id = i_object_id;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select contract_id
             , inst_id
          into l_contract_id
             , l_inst_id
          from acc_account
         where id = i_object_id;
    end if;

    if i_status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE then
        l_start_date := trunc(com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id));
        l_end_date   := null;

    elsif i_status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE then
        l_start_date := trunc(com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id));
        l_end_date   := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id) - com_api_const_pkg.ONE_SECOND;
    end if;

    prd_ui_service_pkg.set_service_object (
        i_service_id   => i_service_id
      , i_contract_id  => l_contract_id
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_start_date   => l_start_date
      , i_end_date     => l_end_date
      , i_inst_id      => l_inst_id
      , i_params       => i_params
    );
end;

procedure get_available_service_list(
    i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_object_id     in     com_api_type_pkg.t_long_id
  , i_device_id     in     com_api_type_pkg.t_short_id
  , o_ref_cursor       out sys_refcursor
) is
    l_contract_id   com_api_type_pkg.t_medium_id;
begin
    if i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select contract_id
          into l_contract_id
          from prd_customer
         where id = i_object_id;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select contract_id
          into l_contract_id
          from acc_account
         where id = i_object_id;
    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        select contract_id
          into l_contract_id
          from iss_card
         where id = i_object_id;
    end if;

    open o_ref_cursor for
    select id
         , service_label
         , status
      from prd_ui_contract_service_vw a
     where a.lang        = get_user_lang
       and a.contract_id = l_contract_id;
end;

procedure get_service_parameters(
    i_service_id    in     com_api_type_pkg.t_short_id
  , o_ref_cursor       out sys_refcursor
) is
    l_service_type_id  com_api_type_pkg.t_short_id;
begin
    select service_type_id
      into l_service_type_id
      from prd_service
     where id = i_service_id;

    open o_ref_cursor for
    select id
       , attr_name
       , label
       , definition_level
       , is_visible
       , case when definition_level = prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_OBJECT
              then 1
              else 0
         end as is_editable
    from prd_ui_attribute_vw
   where service_type_id = l_service_type_id;
end;

procedure close_service (
    i_entity_type          in com_api_type_pkg.t_dict_value
    , i_object_id          in com_api_type_pkg.t_long_id
    , i_inst_id            in com_api_type_pkg.t_inst_id
    , i_split_hash         in com_api_type_pkg.t_tiny_id     default null
    , i_eff_date           in date                           default null
  , i_service_id           in com_api_type_pkg.t_tiny_id     default null
    , i_params             in com_api_type_pkg.t_param_tab
) is
    l_split_hash            com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    for service in (
        select o.id
             , t.disable_event_type
          from prd_service_object o
             , prd_service s
             , prd_service_type t
         where o.object_id    = i_object_id
           and o.entity_type  = i_entity_type
           and s.id           = o.service_id
           and t.id           = s.service_type_id
           and o.split_hash   = l_split_hash
           and nvl(i_service_id, s.id) = s.id
    ) loop
        trc_log_pkg.debug(
            i_text => 'close_service: service object .id=' || service.id
        );
        update
            prd_service_object
        set
            end_date = nvl(i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id))
            , start_date = nvl(start_date, end_date)
        where
            id = service.id;

        change_service_status (
            i_id                    => service.id
            , i_sysdate             => nvl(i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id))
            , i_entity_type         => i_entity_type
            , i_object_id           => i_object_id
            , i_inst_id             => i_inst_id
            , i_disable_event_type  => service.disable_event_type
            , i_enable_event_type   => null
            , i_forced              => com_api_type_pkg.FALSE
            , i_split_hash          => l_split_hash
            , i_params              => i_params
        );
    end loop;
end;

function generate_service_number(
    i_service_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date                            default null
) return com_api_type_pkg.t_name
is
    l_params            com_api_type_pkg.t_param_tab;
    l_eff_date          date;
begin
    l_eff_date := coalesce(i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id));

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.generate_service_number: ' ||
                        'i_service_id [#1], i_inst_id [#2], i_eff_date [#3]'
      , i_env_param1 => i_service_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_eff_date
    );

    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => prd_api_const_pkg.SERVICE_NAME_FORMAT_SERVICE_ID
      , i_value   => i_service_id
    );
    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => prd_api_const_pkg.SERVICE_NAME_FORMAT_INST_ID
      , i_value   => i_inst_id
    );
    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => prd_api_const_pkg.SERVICE_NAME_FORMAT_EFF_DATE
      , i_value   => l_eff_date
    );

    return rul_api_name_pkg.get_name(
               i_format_id  => prd_api_const_pkg.SERVICE_NAME_FORMAT_ID
             , i_param_tab  => l_params
           );
end generate_service_number;

function get_service_id(
    i_service_number      in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_mask_error          in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id
is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_service_id: ';
    l_service_id                 com_api_type_pkg.t_short_id;
    l_error_message              com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_service_number [#1], i_inst_id [#2], i_mask_error [#3]'
      , i_env_param1 => i_service_number
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_mask_error
    );

    begin
        select id
          into l_service_id
          from prd_service
         where service_number = i_service_number
           and inst_id        = i_inst_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'SERVICE_NOT_FOUND'
                  , i_env_param1 => i_service_number
                );
            else
                l_error_message := ' - service NOT FOUND';
            end if;
        when too_many_rows then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'DUPLICATE_SERVICE_NUMBER'
                  , i_env_param1 => i_service_number
                  , i_env_param2 => i_inst_id
                );
            else
                l_error_message := ' - DUPLICATED service number';
            end if;
    end;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'found service_id [#1]' || l_error_message
      , i_env_param1 => l_service_id
    );

    return l_service_id;
end get_service_id;

-- This "result_cache" method can not contain any methods and global variables.
function get_service_type_id(
    i_attr_name         in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_short_id
result_cache
relies_on (prd_attribute)
is
    l_service_type_id           com_api_type_pkg.t_short_id;
begin
    select service_type_id
      into l_service_type_id
      from prd_attribute
     where attr_name = i_attr_name;

    return l_service_type_id;
end;

function message_no_active_service(
    i_entity_type         in      com_api_type_pkg.t_dict_value
  , i_object_id           in      com_api_type_pkg.t_long_id
  , i_limit_type          in      com_api_type_pkg.t_name
  , i_eff_date            in      date
) return com_api_type_pkg.t_short_id
is
begin
    trc_log_pkg.debug (
        i_text        => 'PRD_NO_ACTIVE_SERVICE'
      , i_env_param1  => i_entity_type
      , i_env_param2  => i_object_id
      , i_env_param3  => i_limit_type
      , i_env_param4  => i_eff_date
      , i_entity_type => i_entity_type
      , i_object_id   => i_object_id
    );
    return null;
end message_no_active_service;

function get_conditional_service(
    i_service_id         com_api_type_pkg.t_short_id
  , i_product_id         com_api_type_pkg.t_short_id
)  return com_api_type_pkg.t_dict_value
result_cache
relies_on (prd_product_service)
is
    l_conditional_group    com_api_type_pkg.t_dict_value;
begin
    select s.conditional_group
      into l_conditional_group
      from prd_product_service s
     where s.service_id = i_service_id
       and s.product_id = i_product_id;

    return l_conditional_group;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'SERVICE_NOT_FOUND'
          , i_env_param1  => i_service_id
        );
end;

function check_conditional_service(
    i_service_id         com_api_type_pkg.t_short_id
  , i_product_id         com_api_type_pkg.t_short_id
  , i_service_count      com_api_type_pkg.t_count
) return com_api_type_pkg.t_boolean
is
    l_conditional_group    com_api_type_pkg.t_dict_value;
begin
    l_conditional_group :=
        get_conditional_service(
            i_service_id   => i_service_id
          , i_product_id   => i_product_id
        );

    if l_conditional_group is not null then
        if l_conditional_group = prd_api_const_pkg.CND_GROUP_MANY and i_service_count = 0 then
            return com_api_const_pkg.FALSE;
        elsif l_conditional_group = prd_api_const_pkg.CND_GROUP_ONE and i_service_count <> 1 then
            return com_api_const_pkg.FALSE;
        elsif l_conditional_group = prd_api_const_pkg.CND_GROUP_NOT_MORE_THAN_ONE and i_service_count > 1 then
            return com_api_const_pkg.FALSE;
        else
            return com_api_const_pkg.TRUE;
        end if;
    else
        return com_api_const_pkg.TRUE;
    end if;
end;

procedure check_conditional_service(
    i_service_id         com_api_type_pkg.t_short_id
  , i_contract_id        com_api_type_pkg.t_medium_id
  , i_entity_type        com_api_type_pkg.t_dict_value
  , i_object_id          com_api_type_pkg.t_long_id
  , i_date               date
) is
    l_product_service_id    com_api_type_pkg.t_medium_id;
    l_service_count         com_api_type_pkg.t_count := 0;
    l_conditional_group     com_api_type_pkg.t_dict_value;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_product_id            com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text => 'check_conditional_service' ||
                  '  i_service_id ' || i_service_id ||
                  '; i_contract_id '|| i_contract_id ||
                  '; i_object_id '  || i_object_id ||
                  '; i_entity_type '|| i_entity_type
    );
    begin
        select s.id
             , s.conditional_group
             , c.split_hash
             , c.product_id
          into l_product_service_id
             , l_conditional_group
             , l_split_hash
             , l_product_id
          from prd_contract c
             , prd_product_service s
         where s.service_id = i_service_id
           and s.product_id = c.product_id
           and c.id         = i_contract_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'SERVICE_NOT_FOUND'
              , i_env_param1  => i_service_id
              , i_env_param2  => i_contract_id
            );
    end;

    if l_conditional_group is not null then
        trc_log_pkg.debug(i_text => 'l_conditional_group ' || l_conditional_group);

        select count(*)
          into l_service_count
          from prd_product_service ps
             , prd_service_object s
         where ps.parent_id  = l_product_service_id
           and s.service_id  = ps.service_id
           and s.entity_type = i_entity_type
           and s.object_id   = i_object_id
           and s.split_hash  = l_split_hash
           and s.status      = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
           and (i_date >= s.start_date or s.start_date is null)
           and (i_date <= s.end_date   or s.end_date is null);

        if prd_api_service_pkg.check_conditional_service(
               i_service_id        => i_service_id
             , i_product_id        => l_product_id
             , i_service_count     => l_service_count
           ) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'CONDITIONAL_SERVICE_CHECK_FAILED'
              , i_env_param1 => l_product_service_id
              , i_env_param2 => l_service_count
            );
        end if;
    end if;
end;

procedure update_service_object(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_contract_id       in      com_api_type_pkg.t_medium_id
) as
begin
    update prd_service_object o
       set o.split_hash  = i_split_hash
         , o.contract_id = i_contract_id
     where o.object_id   = i_object_id
       and o.entity_type = i_entity_type;
end;

function check_service_attached(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_service_type_id       in  com_api_type_pkg.t_short_id
  , i_eff_date              in  date                          default null
) return com_api_type_pkg.t_boolean
is
    l_service_id            com_api_type_pkg.t_medium_id;
    l_card_entity_type      com_api_type_pkg.t_dict_value;
    l_card                  iss_api_type_pkg.t_card_rec;
    l_object_id             com_api_type_pkg.t_long_id;
    l_eff_date              date := coalesce(i_eff_date, com_api_sttl_day_pkg.get_sysdate);
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER then
        begin
            select st.entity_type
              into l_card_entity_type
              from prd_service_type st
             where st.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and st.id = i_service_type_id;
        exception
            when no_data_found then
                null;
        end;

        if l_card_entity_type is not null then
            for cu_card in (
                select c.id
                  from iss_card c
                 where c.cardholder_id = i_object_id
                   and prd_api_service_pkg.get_active_service_id(
                           i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
                         , i_object_id          => c.id
                         , i_attr_name          => null
                         , i_service_type_id    => i_service_type_id
                         , i_split_hash         => c.split_hash
                         , i_mask_error         => com_api_const_pkg.TRUE
                         , i_eff_date           => l_eff_date
                       ) is not null
            ) loop
                return com_api_const_pkg.TRUE;
            end loop;
        end if;

        return com_api_const_pkg.FALSE;

    elsif   i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
        or  i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
    then
        l_object_id         := i_object_id;

        if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            l_card :=
                iss_api_card_pkg.get_card(
                    i_card_instance_id          => i_object_id
                  , i_mask_error                => com_api_const_pkg.TRUE
                );
            l_object_id     := l_card.id;
        end if;

        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id         => l_object_id
              , i_attr_name         => null
              , i_service_type_id   => i_service_type_id
              , i_mask_error        => com_api_const_pkg.TRUE
              , i_eff_date          => l_eff_date
            );

        if l_service_id is not null then
            return com_api_const_pkg.TRUE;
        else
            return com_api_const_pkg.FALSE;
        end if;

    else
        trc_log_pkg.warn(
            i_text          => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1    => i_entity_type
        );
    end if;

end check_service_attached;

-- This "result_cache" method can not contain any methods and global variables.
function get_service_rec(
    i_service_id      in  com_api_type_pkg.t_short_id
) return prd_api_type_pkg.t_service
result_cache
relies_on (prd_service)
is
    l_service_rec         prd_api_type_pkg.t_service;
begin
    select s.id
         , s.seqnum
         , s.service_type_id
         , s.inst_id
         , s.status
         , s.service_number
         , s.split_hash
      into l_service_rec
      from prd_service s
     where s.id = i_service_id;

    return l_service_rec;
end get_service_rec;

procedure check_service_is_attached(
    i_service_id    in com_api_type_pkg.t_medium_id
  , i_entity_type   in com_api_type_pkg.t_dict_value
  , i_object_id     in com_api_type_pkg.t_long_id
  , i_event_date    in date
)
is
    l_cnt                           com_api_type_pkg.t_count := 0;
begin
    if i_service_id is not null then

        trc_log_pkg.debug(
            i_text       => 'check_is_service_attached : i_entity_type [#1], i_object_id [#2], l_service_id [#3]'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_service_id
        );

        select count(*)
          into l_cnt
          from prd_service_object
         where service_id  = i_service_id
           and entity_type = i_entity_type
           and object_id   = i_object_id
           and i_event_date between start_date and nvl(end_date, i_event_date)
           and status      = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE;

        if l_cnt = 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'SERVICE_NOT_ATTACHED_TO_ENTITY'
              , i_env_param1 => i_service_id
              , i_env_param2 => i_entity_type
              , i_env_param3 => i_object_id
            );
        end if;
    end if;
end check_service_is_attached;

end prd_api_service_pkg;
/
