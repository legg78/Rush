create or replace package body prd_api_attribute_value_pkg is

procedure check_product_limit_bounds(
    i_count_limit       in      com_api_type_pkg.t_long_id
  , i_sum_limit         in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_eff_date          in      date
) is
    l_limit             fcl_api_type_pkg.t_limit;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_sum_max_bound     com_api_type_pkg.t_money;
    l_rate_type         com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => 'check_product_limit_bounds. '
                     || 'i_count_limit [#1], i_sum_limit [#2], i_currency [#3], '
                     || 'i_limit_type [#4], i_mod_id [#5], i_product_id [#6]'
                     || 'i_service_id=' || i_service_id
      , i_env_param1 => i_count_limit
      , i_env_param2 => i_sum_limit
      , i_env_param3 => i_currency
      , i_env_param4 => i_limit_type
      , i_env_param5 => i_mod_id
      , i_env_param6 => i_product_id
    );

    -- check product-level limit
    begin
        select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT)
          into l_limit_id
          from (
                select v.attr_value as limit_id
                     , m.condition mod_condition
                     , p.level_priority
                     , v.mod_id
                     , a.data_type
                     , a.entity_type attr_entity_type
                     , v.register_timestamp
                     , v.start_date
                     , m.priority
                  from (
                        select connect_by_root id product_id
                             , level level_priority
                             , id parent_id
                             , product_type
                             , case when parent_id is null then 1 else 0 end top_flag
                          from prd_product
                         connect by prior parent_id = id
                           start with id = i_product_id
                       ) p
                     , prd_attribute_value v
                     , prd_attribute a
                     , prd_service s
                     , rul_mod m
                     , prd_product_service ps
                 where ps.product_id     = p.product_id
                   and ps.service_id     = s.id
                   and v.service_id      = s.id
                   and a.service_type_id = s.service_type_id
                   and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                   and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                   and v.attr_id         = a.id
                   and v.mod_id          = m.id(+)
                   and s.id              = i_service_id
                   and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                   and a.object_type     = i_limit_type
                   and i_eff_date between nvl(v.start_date, i_eff_date) and nvl(v.end_date, trunc(i_eff_date)+1)
                   and (v.mod_id         = i_mod_id or i_mod_id is null)
                 order by decode(level_priority, 0, 0, 1)
                        , priority nulls last
                        , level_priority
                        , start_date desc
                        , register_timestamp desc
               )
           where rownum = 1;
    exception
        when no_data_found then
            l_limit_id := null;
    end;

    if l_limit_id is not null then
        l_limit := fcl_api_limit_pkg.get_limit(i_limit_id  => l_limit_id);

        trc_log_pkg.debug(
            i_text       => 'limit bounds: sum_max_bound [#1], currency [#2], count_max_bound [#3]'
          , i_env_param1 => l_limit.sum_max_bound
          , i_env_param2 => l_limit.currency
          , i_env_param3 => l_limit.count_max_bound
        );

        if i_currency <> l_limit.currency then
            begin
                select r.rate_type
                  into l_rate_type
                  from fcl_limit_rate r
                 where r.inst_id = l_limit.inst_id
                   and r.limit_type = i_limit_type;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error         => 'LIMIT_RATE_TYPE_NOT_FOUND'
                      , i_env_param1    => i_limit_type
                      , i_env_param2    => l_limit.inst_id
                    );
            end;

            l_sum_max_bound :=
                com_api_rate_pkg.convert_amount(
                    i_src_amount      => l_limit.sum_max_bound
                  , i_src_currency    => l_limit.currency
                  , i_dst_currency    => i_currency
                  , i_rate_type       => l_rate_type
                  , i_inst_id         => l_limit.inst_id
                  , i_eff_date        => i_eff_date
                  , i_conversion_type => null
                );
        else
            l_sum_max_bound := l_limit.sum_max_bound;
        end if;

        if (l_sum_max_bound > 0 and (l_sum_max_bound < i_sum_limit or i_sum_limit < 0)) then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_SUM_OVERBOUND'
              , i_env_param1    => i_limit_type
              , i_env_param2    => i_sum_limit
              , i_env_param3    => i_currency
              , i_env_param4    => l_limit.sum_max_bound
              , i_env_param5    => l_limit.currency
            );
        end if;

        if (l_limit.count_max_bound > 0 and (l_limit.count_max_bound < i_count_limit or i_count_limit < 0)) then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_COUNT_OVERBOUND'
              , i_env_param1    => i_limit_type
              , i_env_param2    => i_count_limit
              , i_env_param3    => l_limit.count_max_bound
            );
        end if;
    end if;
end check_product_limit_bounds;

procedure set_attribute_value(
    io_id               in out com_api_type_pkg.t_medium_id
  , i_service_id        in     com_api_type_pkg.t_short_id
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_attr_id           in     com_api_type_pkg.t_short_id
  , i_mod_id            in     com_api_type_pkg.t_tiny_id
  , i_start_date        in     date                          default null
  , i_end_date          in     date
  , i_attr_value        in     com_api_type_pkg.t_text
  , i_definition_level  in     com_api_type_pkg.t_dict_value
  , i_check_start_date  in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in     com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in     com_api_type_pkg.t_short_id   default null
) is
    l_split_hash               com_api_type_pkg.t_tiny_id;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_event_type               com_api_type_pkg.t_dict_value;
    l_end_event_type           com_api_type_pkg.t_dict_value;
    l_params                   com_api_type_pkg.t_param_tab;
    l_sysdate                  date;
    l_attribute                prd_api_type_pkg.t_attribute;
    l_count                    com_api_type_pkg.t_count := 0;
    l_entity_type              com_api_type_pkg.t_dict_value;
    l_object_id                com_api_type_pkg.t_short_id;
begin
    l_inst_id :=
        coalesce(
             i_inst_id
           , ost_api_institution_pkg.get_object_inst_id(
                 i_entity_type  => i_entity_type
               , i_object_id    => i_object_id
               , i_mask_errors  => com_api_const_pkg.TRUE
             )
        );

    l_sysdate := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id);

    l_split_hash :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
        );

    if      i_start_date is not null
        and i_start_date < l_sysdate
        and i_check_start_date = com_api_type_pkg.TRUE
    then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_START_DATE'
          , i_env_param1 => to_char(i_start_date, get_date_format)
        );
    end if;

    if      i_start_date is not null
        and i_end_date is not null
        and i_start_date > i_end_date
    then
        com_api_error_pkg.raise_error(
            i_error      => 'INCONSISTENT_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(i_start_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(i_end_date)
        );
    end if;

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    trc_log_pkg.debug(
        i_text       => 'set_attribute_value, io_id [#1], i_campaign_id [#2], i_entity_type [#1], i_object_id [#2]'
      , i_env_param1 => io_id
      , i_env_param2 => i_campaign_id
      , i_env_param3 => i_entity_type
      , i_env_param4 => i_object_id
    );

    l_entity_type := i_entity_type;
    l_object_id   := i_object_id;

    if io_id is null then
        io_id := prd_attribute_value_seq.nextval;

        if i_campaign_id is not null then
            -- Promo campaign attributes should be saved for entity <Campaign> instead of <Product>, because they aren't
            -- used as-is but only for copying values to objects associated with the campaign (accounts, cards, etc.)
            case cpn_api_campaign_pkg.get_campaign(i_campaign_id => i_campaign_id).campaign_type
                when cpn_api_const_pkg.CAMPAIGN_TYPE_PROMO_CAMPAIGN then
                    l_entity_type := cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN;
                    l_object_id   := i_campaign_id;
                    l_split_hash  := null; -- Campaign has no split hash
                else
                    null;
            end case;

            trc_log_pkg.debug(
                i_text       => 'Entity object for saving campaign attributes is [#1][#2], split_hash [#3]'
              , i_env_param1 => l_entity_type
              , i_env_param2 => l_object_id
              , i_env_param3 => l_split_hash
            );

            begin
                insert into cpn_campaign_attribute_vw(
                    id
                  , campaign_id
                  , product_id
                  , service_id
                  , attribute_id
                ) values (
                    cpn_campaign_attribute_seq.nextval
                  , i_campaign_id
                  , case when i_entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT then i_object_id end
                  , i_service_id
                  , i_attr_id
                );
            exception
                when dup_val_on_index then
                    null; -- attribute is already registered for campaign
            end;

            insert into cpn_attribute_value_vw(
                id
              , campaign_id
              , attribute_value_id
            ) values (
                cpn_attribute_value_seq.nextval
              , i_campaign_id
              , io_id
            );
        end if;

        insert into prd_attribute_value_vw (
            id
          , service_id
          , object_id
          , entity_type
          , attr_id
          , mod_id
          , start_date
          , end_date
          , register_timestamp
          , attr_value
          , split_hash
        ) values (
            io_id
          , i_service_id
          , l_object_id
          , l_entity_type
          , i_attr_id
          , i_mod_id
          , nvl(i_start_date, l_sysdate)
          , i_end_date
          , systimestamp
          , i_attr_value
          , l_split_hash
        );

    else -- io_id is NOT null
        if i_campaign_id is null then
            for rec in (
                select v.campaign_id
                  from cpn_attribute_value_vw v
                  where v.attribute_value_id =  io_id
            ) loop
                -- The value of attribute [#1] can only be changed through campaign [#2]
                com_api_error_pkg.raise_error(
                    i_error        => 'EDIT_VIA_CAMPAIGN_ONLY'
                  , i_env_param1   => io_id
                  , i_env_param2   => rec.campaign_id
                  , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
                  , i_object_id    => rec.campaign_id
                );
            end loop;
        end if;

        update cpn_attribute_value_vw c
           set campaign_id          = i_campaign_id
         where c.attribute_value_id = io_id;

        update prd_attribute_value_vw
           set service_id = i_service_id
             , mod_id     = i_mod_id
             , start_date = nvl(i_start_date, l_sysdate)
             , end_date   = i_end_date
             , attr_value = i_attr_value
         where id         = io_id;
    end if;

    case l_entity_type
        when prd_api_const_pkg.ENTITY_TYPE_PRODUCT then
            l_event_type     := prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT;
            l_end_event_type := prd_api_const_pkg.EVENT_PRODUCT_ATTR_END_CHANGE;

        when prd_api_const_pkg.ENTITY_TYPE_SERVICE then
            null;

        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            l_event_type     := iss_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_CARD;
            l_end_event_type := iss_api_const_pkg.EVENT_CARD_ATTR_END_CHANGE;

        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            l_event_type     := acc_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_ACCOUNT;
            l_end_event_type := acc_api_const_pkg.EVENT_ACCOUNT_ATTR_END_CHANGE;

        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            l_event_type     := acq_api_const_pkg.EVENT_MERCHANT_ATTR_CHANGE;
            l_end_event_type := acq_api_const_pkg.EVENT_MERCHANT_ATTR_END_CHANGE;

        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            l_event_type     := acq_api_const_pkg.EVENT_TERMINAL_ATTR_CHANGE;
            l_end_event_type := acq_api_const_pkg.EVENT_TERMINAL_ATTR_END_CHANGE;

        when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            l_event_type     := prd_api_const_pkg.EVENT_ATTR_CHANGE_CUSTOMER;

        when cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN then
            l_event_type     := cpn_api_const_pkg.EVENT_PROMO_CMPGN_ATTR_CHANGE;
            l_end_event_type := null;

        else
            null;
    end case;

    -- New events are registered for both begin and end of a validity period
    if     l_event_type     is not null
        or l_end_event_type is not null
    then
        l_attribute := prd_api_attribute_pkg.get_attribute(i_attr_id => i_attr_id);

        rul_api_param_pkg.set_param (
            io_params   => l_params
          , i_name      => 'PRODUCT_ATTRIBUTE'
          , i_value     => i_attr_id
        );

        rul_api_param_pkg.set_param (
            io_params   => l_params
          , i_name      => 'ATTRIBUTE_VALUE'
          , i_value     => i_attr_value
        );

        rul_api_param_pkg.set_param(
            io_params   => l_params
          , i_name      => 'ENTITY_TYPE'
          , i_value     => l_attribute.entity_type
        );

        rul_api_param_pkg.set_param(
            io_params   => l_params
          , i_name      => 'OBJECT_TYPE'
          , i_value     => l_attribute.object_type
        );

        rul_api_param_pkg.set_param (
            io_params   => l_params
          , i_name      => 'ATTR_START_DATE'
          , i_value     => coalesce(i_start_date, l_sysdate)
        );

        rul_api_param_pkg.set_param (
            io_params   => l_params
          , i_name      => 'ATTR_END_DATE'
          , i_value     => i_end_date
        );

        if l_event_type is not null then
            evt_api_event_pkg.register_event(
                i_event_type   => l_event_type
              , i_eff_date     => greatest(i_start_date, l_sysdate)
              , i_param_tab    => l_params
              , i_entity_type  => l_entity_type
              , i_object_id    => i_object_id
              , i_inst_id      => l_inst_id
              , i_split_hash   => l_split_hash
            );

            if l_event_type = prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT then
                evt_api_event_pkg.register_event(
                    i_event_type   => prd_api_const_pkg.EVENT_ATTR_CHANGE_PRD_ATTR_LVL
                  , i_eff_date     => greatest(i_start_date, l_sysdate)
                  , i_param_tab    => l_params
                  , i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_PRODUCT_ATTR_VAL
                  , i_object_id    => io_id
                  , i_inst_id      => l_inst_id
                  , i_split_hash   => l_split_hash
                );
            end if;
        end if;

        if      i_end_date       is not null
            and l_end_event_type is not null
        then
            evt_api_event_pkg.register_event(
                i_event_type  => l_end_event_type
              , i_eff_date    => i_end_date
              , i_param_tab   => l_params
              , i_entity_type => l_entity_type
              , i_object_id   => i_object_id
              , i_inst_id     => l_inst_id
              , i_split_hash  => l_split_hash
            );

            if l_event_type = prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT then
                evt_api_event_pkg.register_event(
                    i_event_type   => prd_api_const_pkg.EVENT_ATTR_CHANGE_PRD_ATTR_LVL
                  , i_eff_date     => i_end_date
                  , i_param_tab    => l_params
                  , i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_PRODUCT_ATTR_VAL
                  , i_object_id    => io_id
                  , i_inst_id      => l_inst_id
                  , i_split_hash   => l_split_hash
                );
            end if;
        end if;
    end if;
end set_attribute_value;

procedure modify_attribute_value (
    i_id          in     com_api_type_pkg.t_medium_id
  , i_service_id  in     com_api_type_pkg.t_short_id
  , i_mod_id      in     com_api_type_pkg.t_tiny_id
  , i_start_date  in     date                          default null
  , i_end_date    in     date
  , i_attr_value  in     com_api_type_pkg.t_text
  , i_campaign_id in     com_api_type_pkg.t_short_id   default null
) is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_attribute_value: ';
    l_inst_id            com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_id [#1], i_service_id [#2], i_mod_id [#3], '
                                   || 'i_start_date [#4], i_end_date [#5], i_attr_value [#6]'
      , i_env_param1 => i_id
      , i_env_param2 => i_service_id
      , i_env_param3 => i_mod_id
      , i_env_param4 => to_char(i_start_date, com_api_const_pkg.DATE_FORMAT)
      , i_env_param5 => to_char(i_end_date, com_api_const_pkg.DATE_FORMAT)
      , i_env_param6 => i_attr_value
    );

    if  i_start_date is not null
        and i_end_date is not null
        and i_start_date > i_end_date
    then
        com_api_error_pkg.raise_error(
            i_error      => 'INCONSISTENT_DATE'
          , i_env_param1 => to_char(i_start_date, get_date_format)
          , i_env_param2 => to_char(i_end_date, get_date_format)
        );
    end if;

    select ost_api_institution_pkg.get_object_inst_id(
               i_entity_type => entity_type
             , i_object_id   => object_id
             , i_mask_errors  => com_api_type_pkg.TRUE
           )
      into l_inst_id
      from prd_attribute_value_vw
     where id = i_id;

     if i_campaign_id is null then
        for rec in (
            select v.campaign_id
              from cpn_attribute_value_vw v
              where v.attribute_value_id = i_id
        ) loop
            -- The value of attribute [#1] can only be changed through campaign [#2]
            com_api_error_pkg.raise_error(
                i_error        => 'EDIT_VIA_CAMPAIGN_ONLY'
              , i_env_param1   => i_id
              , i_env_param2   => rec.campaign_id
              , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
              , i_object_id    => rec.campaign_id
            );
        end loop;
    end if;

    update cpn_attribute_value_vw v
       set campaign_id          = i_campaign_id
     where v.attribute_value_id = i_id;

    update prd_attribute_value_vw
       set service_id = i_service_id
         , mod_id     = i_mod_id
         , start_date = coalesce(i_start_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id))
         , end_date   = i_end_date
         , attr_value = i_attr_value
     where id         = i_id;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '[#1] rows are updated'
      , i_env_param1 => sql%rowcount
    );
end modify_attribute_value;

procedure set_attr_value_num(
    io_id               in out com_api_type_pkg.t_medium_id
  , i_service_id        in     com_api_type_pkg.t_short_id
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_attr_name         in     com_api_type_pkg.t_name
  , i_mod_id            in     com_api_type_pkg.t_tiny_id
  , i_start_date        in     date                          default null
  , i_end_date          in     date
  , i_value             in     number
  , i_check_start_date  in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in     com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in     com_api_type_pkg.t_short_id   default null
) is
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_attribute_rec            prd_api_type_pkg.t_attribute;
begin
    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                         i_entity_type => i_entity_type
                       , i_object_id   => i_object_id
                       , i_mask_errors => com_api_type_pkg.TRUE
                     );
    else
        l_inst_id := i_inst_id;
    end if;

    l_attribute_rec := prd_api_attribute_pkg.get_attribute(
                           i_attr_name  => i_attr_name
                         , i_mask_error => com_api_type_pkg.FALSE
                       );

    if nvl(l_attribute_rec.data_type, '~') != com_api_const_pkg.DATA_TYPE_NUMBER then
        com_api_error_pkg.raise_error(
            i_error       => 'WRONG_ATTRIBUTE_DATA_TYPE'
          , i_env_param1  => i_attr_name
          , i_env_param2  => l_attribute_rec.data_type
          , i_env_param3  => com_api_const_pkg.DATA_TYPE_NUMBER
        );
    else
        set_attribute_value(
            io_id               => io_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_id           => l_attribute_rec.id
          , i_mod_id            => i_mod_id
          , i_start_date        => i_start_date
          , i_end_date          => i_end_date
          , i_attr_value        => to_char(i_value, com_api_const_pkg.NUMBER_FORMAT)
          , i_definition_level  => l_attribute_rec.definition_level
          , i_check_start_date  => case
                                       when io_id is null then i_check_start_date
                                                          else com_api_type_pkg.FALSE
                                   end
          , i_inst_id           => l_inst_id
          , i_campaign_id       => i_campaign_id
        );
    end if;
end set_attr_value_num;

procedure set_attr_value_date(
    io_id               in out com_api_type_pkg.t_medium_id
  , i_service_id        in     com_api_type_pkg.t_short_id
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_attr_name         in     com_api_type_pkg.t_name
  , i_mod_id            in     com_api_type_pkg.t_tiny_id
  , i_start_date        in     date                          default null
  , i_end_date          in     date
  , i_value             in     date
  , i_check_start_date  in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in     com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in     com_api_type_pkg.t_short_id   default null
) is
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_attribute_rec            prd_api_type_pkg.t_attribute;
begin
    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                         i_entity_type => i_entity_type
                       , i_object_id   => i_object_id
                       , i_mask_errors => com_api_type_pkg.TRUE
                     );
    else
        l_inst_id := i_inst_id;
    end if;

    l_attribute_rec := prd_api_attribute_pkg.get_attribute(
                           i_attr_name  => i_attr_name
                         , i_mask_error => com_api_type_pkg.FALSE
                       );

    if nvl(l_attribute_rec.data_type, '~') != com_api_const_pkg.DATA_TYPE_DATE then
        com_api_error_pkg.raise_error(
            i_error       => 'WRONG_ATTRIBUTE_DATA_TYPE'
          , i_env_param1  => i_attr_name
          , i_env_param2  => l_attribute_rec.data_type
          , i_env_param3  => com_api_const_pkg.DATA_TYPE_DATE
        );
    else
        set_attribute_value(
            io_id               => io_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_id           => l_attribute_rec.id
          , i_mod_id            => i_mod_id
          , i_start_date        => i_start_date
          , i_end_date          => i_end_date
          , i_attr_value        => to_char(i_value, com_api_const_pkg.DATE_FORMAT)
          , i_definition_level  => l_attribute_rec.definition_level
          , i_check_start_date  => case
                                       when io_id is null then i_check_start_date
                                                          else com_api_type_pkg.FALSE
                                   end
          , i_inst_id           => l_inst_id
          , i_campaign_id       => i_campaign_id
        );
    end if;
end set_attr_value_date;

procedure set_attr_value_char(
    io_id               in out com_api_type_pkg.t_medium_id
  , i_service_id        in     com_api_type_pkg.t_short_id
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_attr_name         in     com_api_type_pkg.t_name
  , i_mod_id            in     com_api_type_pkg.t_tiny_id
  , i_start_date        in     date                          default null
  , i_end_date          in     date
  , i_value             in     com_api_type_pkg.t_text
  , i_check_start_date  in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in     com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in     com_api_type_pkg.t_short_id   default null
) is
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_attribute_rec            prd_api_type_pkg.t_attribute;
begin
    trc_log_pkg.debug(
        i_text         => 'set_attr_value_char, io_id=#1, icampaign_id=[#2]'
      , i_env_param1   => io_id
      , i_env_param2   => i_campaign_id
    );

    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                         i_entity_type => i_entity_type
                       , i_object_id   => i_object_id
                       , i_mask_errors => com_api_type_pkg.TRUE
                     );
    else
        l_inst_id := i_inst_id;
    end if;

    l_attribute_rec := prd_api_attribute_pkg.get_attribute(
                           i_attr_name  => i_attr_name
                         , i_mask_error => com_api_type_pkg.FALSE
                       );

    if nvl(l_attribute_rec.data_type, '~') != com_api_const_pkg.DATA_TYPE_CHAR then
        com_api_error_pkg.raise_error(
            i_error       => 'WRONG_ATTRIBUTE_DATA_TYPE'
          , i_env_param1  => i_attr_name
          , i_env_param2  => l_attribute_rec.data_type
          , i_env_param3  => com_api_const_pkg.DATA_TYPE_CHAR
        );
    else
        set_attribute_value(
            io_id               => io_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_id           => l_attribute_rec.id
          , i_mod_id            => i_mod_id
          , i_start_date        => i_start_date
          , i_end_date          => i_end_date
          , i_attr_value        => i_value
          , i_definition_level  => l_attribute_rec.definition_level
          , i_check_start_date  => case
                                       when io_id is null then i_check_start_date
                                                          else com_api_type_pkg.FALSE
                                   end
          , i_inst_id           => l_inst_id
          , i_campaign_id       => i_campaign_id
        );
    end if;
end set_attr_value_char;

procedure set_attr_value_fee (
    io_attr_value_id    in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date      default null
  , i_end_date          in      date
  , i_fee_id            in      com_api_type_pkg.t_short_id
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in      com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
    l_fee_type        com_api_type_pkg.t_dict_value;
    l_cycle_type      com_api_type_pkg.t_dict_value;
    l_limit_type      com_api_type_pkg.t_dict_value;
    l_cycle_id        com_api_type_pkg.t_short_id;
    l_limit_id        com_api_type_pkg.t_long_id;
    l_object_type     com_api_type_pkg.t_dict_value;
    l_entity_type     com_api_type_pkg.t_dict_value;
    l_service_id      com_api_type_pkg.t_short_id;
    l_inst_id         com_api_type_pkg.t_inst_id;
begin
    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                         i_entity_type => i_entity_type
                       , i_object_id   => i_object_id
                       , i_mask_errors => com_api_type_pkg.TRUE
                     );
    else
        l_inst_id := i_inst_id;
    end if;

    l_service_id := i_service_id;
    if l_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type => i_entity_type
              , i_object_id   => i_object_id
              , i_attr_name   => i_attr_name
              , i_eff_date    => coalesce(
                                     i_start_date
                                   , com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id)
                                 )
              , i_inst_id     => l_inst_id
            );
    end if;

    if io_attr_value_id is null then
        begin
            select cycle_id
                 , limit_id
                 , fee_type
                 , inst_id
              into l_cycle_id
                 , l_limit_id
                 , l_fee_type
                 , l_inst_id
              from fcl_fee_vw
             where id = i_fee_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'FEE_NOT_FOUND'
                  , i_env_param1  => i_fee_id
                );
        end;

        begin
            select a.entity_type
                 , a.object_type
              into l_entity_type
                 , l_object_type
              from prd_attribute_vw a
                 , prd_service_type_vw e
             where a.attr_name = upper(i_attr_name)
               and e.id        = a.service_type_id
               and (
                    e.entity_type = i_entity_type
                    or
                    i_entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                    or
                    i_entity_type = prd_api_const_pkg.ENTITY_TYPE_SERVICE
                   );

            if  l_entity_type    <> fcl_api_const_pkg.ENTITY_TYPE_FEE
                or l_object_type <> l_fee_type
            then
                com_api_error_pkg.raise_error (
                    i_error       => 'INCONSISTENT_ATTR_FEE'
                  , i_env_param1  => l_entity_type
                  , i_env_param2  => l_object_type
                );
            end if;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'ATTR_NOT_FOUND_FOR_ENTITY'
                  , i_env_param1  => l_fee_type
                  , i_env_param2  => i_entity_type
                );
        end;

        begin
            select cycle_type
                 , limit_type
              into l_cycle_type
                 , l_limit_type
              from fcl_fee_type_vw
             where fee_type = l_fee_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error        => 'FEE_TYPE_NOT_FOUND'
                  , i_env_param1   => l_fee_type
                  , i_entity_type  => i_entity_type
                  , i_object_id    => i_object_id
                );
        end;

        if l_cycle_type is not null and l_cycle_id is not null
           and i_entity_type not in (
               prd_api_const_pkg.ENTITY_TYPE_PRODUCT
             , prd_api_const_pkg.ENTITY_TYPE_SERVICE
           )
        then
            fcl_api_cycle_pkg.add_cycle_counter (
                i_cycle_type   => l_cycle_type
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_inst_id      => l_inst_id
            );
        end if;

        if l_limit_type is not null and l_limit_id is not null
           and i_entity_type not in (
               prd_api_const_pkg.ENTITY_TYPE_PRODUCT
             , prd_api_const_pkg.ENTITY_TYPE_SERVICE
           )
        then
            fcl_api_limit_pkg.add_limit_counter (
                i_limit_type   => l_limit_type
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_inst_id      => l_inst_id
            );
        end if;
    end if;

    set_attr_value_num (
        io_id               => io_attr_value_id
      , i_service_id        => l_service_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_mod_id            => i_mod_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_value             => i_fee_id
      , i_check_start_date  => i_check_start_date
      , i_inst_id           => l_inst_id
      , i_campaign_id       => i_campaign_id
    );
end set_attr_value_fee;

procedure set_attr_value_cycle (
    io_attr_value_id    in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date      default null
  , i_end_date          in      date
  , i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in      com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
    l_inst_id         com_api_type_pkg.t_inst_id;
    l_cycle_type      com_api_type_pkg.t_dict_value;
    l_object_type     com_api_type_pkg.t_dict_value;
    l_entity_type     com_api_type_pkg.t_dict_value;
    l_service_id      com_api_type_pkg.t_short_id;
begin
    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                         i_entity_type => i_entity_type
                       , i_object_id   => i_object_id
                       , i_mask_errors => com_api_type_pkg.TRUE
                     );
    else
        l_inst_id := i_inst_id;
    end if;

    l_service_id := i_service_id;
    if l_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type => i_entity_type
              , i_object_id   => i_object_id
              , i_attr_name   => i_attr_name
              , i_eff_date    => coalesce(
                                     i_start_date
                                   , com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id)
                                 )
              , i_inst_id     => l_inst_id
            );
    end if;

    if io_attr_value_id is null then
        begin
            select cycle_type
                 , inst_id
              into l_cycle_type
                 , l_inst_id
              from fcl_cycle_vw
             where id = i_cycle_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'CYCLE_NOT_FOUND'
                  , i_env_param1  => i_cycle_id
                );
        end;

        begin
            select a.entity_type
                 , a.object_type
              into l_entity_type
                 , l_object_type
              from prd_attribute_vw a
                 , prd_service_type_vw e
             where a.attr_name = upper(i_attr_name)
               and e.id        = a.service_type_id
               and (
                    e.entity_type = i_entity_type
                    or
                    i_entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                    or
                    i_entity_type = prd_api_const_pkg.ENTITY_TYPE_SERVICE
                   );

            if l_entity_type   <> fcl_api_const_pkg.ENTITY_TYPE_CYCLE
              or l_object_type <> l_cycle_type
            then
                com_api_error_pkg.raise_error (
                    i_error       => 'INCONSISTENT_ATTR_CYCLE'
                  , i_env_param1  => l_entity_type
                  , i_env_param2  => l_object_type
                );
            end if;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'ATTR_NOT_FOUND_FOR_ENTITY'
                  , i_env_param1  => l_cycle_type
                  , i_env_param2  => i_entity_type
                );
        end;

        if i_entity_type not in (
               prd_api_const_pkg.ENTITY_TYPE_PRODUCT
             , prd_api_const_pkg.ENTITY_TYPE_SERVICE
           )
        then
            fcl_api_cycle_pkg.add_cycle_counter (
                i_cycle_type   => l_cycle_type
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_inst_id      => l_inst_id
            );
        end if;
    end if;

    set_attr_value_num (
        io_id               => io_attr_value_id
      , i_service_id        => l_service_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_mod_id            => i_mod_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_value             => i_cycle_id
      , i_check_start_date  => i_check_start_date
      , i_inst_id           => l_inst_id
      , i_campaign_id       => i_campaign_id
    );
end set_attr_value_cycle;

procedure set_attr_value_limit (
    io_attr_value_id    in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date      default null
  , i_end_date          in      date
  , i_limit_id          in      com_api_type_pkg.t_long_id
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in      com_api_type_pkg.t_inst_id    default null
  , i_is_cyclic         in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
    l_inst_id         com_api_type_pkg.t_inst_id;
    l_cycle_type      com_api_type_pkg.t_dict_value;
    l_limit_type      com_api_type_pkg.t_dict_value;
    l_cycle_id        com_api_type_pkg.t_short_id;
    l_object_type     com_api_type_pkg.t_dict_value;
    l_entity_type     com_api_type_pkg.t_dict_value;
    l_service_id      com_api_type_pkg.t_short_id;
    l_next_date       date;
    l_start_date      date;
    l_count_limit     com_api_type_pkg.t_long_id;
    l_sum_limit       com_api_type_pkg.t_money;
    l_currency        com_api_type_pkg.t_curr_code;
begin
    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                         i_entity_type => i_entity_type
                       , i_object_id   => i_object_id
                       , i_mask_errors => com_api_type_pkg.TRUE
                     );
    else
        l_inst_id := i_inst_id;
    end if;

    l_start_date := coalesce(
                        i_start_date
                      , com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id)
                    );

    l_service_id := i_service_id;
    if l_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type => i_entity_type
              , i_object_id   => i_object_id
              , i_attr_name   => i_attr_name
              , i_eff_date    => l_start_date
              , i_inst_id     => l_inst_id
            );
    end if;

    if io_attr_value_id is null then
        begin
            select cycle_id
                 , limit_type
                 , inst_id
                 , count_limit
                 , sum_limit
                 , currency
              into l_cycle_id
                 , l_limit_type
                 , l_inst_id
                 , l_count_limit
                 , l_sum_limit
                 , l_currency
              from fcl_limit_vw
             where id = i_limit_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'LIMIT_NOT_FOUND'
                  , i_env_param1  => i_limit_id
                );
        end;

        begin
            select a.entity_type
                 , a.object_type
              into l_entity_type
                 , l_object_type
              from prd_attribute_vw a
                 , prd_service_type_vw e
             where a.attr_name = upper(i_attr_name)
               and e.id        = a.service_type_id
                and (
                     e.entity_type = i_entity_type
                     or
                     i_entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                     or
                     i_entity_type = prd_api_const_pkg.ENTITY_TYPE_SERVICE
                    );
            if l_entity_type   <> fcl_api_const_pkg.ENTITY_TYPE_LIMIT
               or l_object_type <> l_cycle_type
            then
                com_api_error_pkg.raise_error (
                    i_error       => 'INCONSISTENT_ATTR_LIMIT'
                  , i_env_param1  => l_entity_type
                  , i_env_param2  => l_object_type
                );
            end if;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'ATTR_NOT_FOUND_FOR_ENTITY'
                  , i_env_param1  => l_limit_type
                  , i_env_param2  => i_entity_type
                );
        end;

        if i_entity_type not in (
               prd_api_const_pkg.ENTITY_TYPE_PRODUCT
             , prd_api_const_pkg.ENTITY_TYPE_SERVICE
           )
        then
            check_product_limit_bounds(
                i_count_limit       => l_count_limit
              , i_sum_limit         => l_sum_limit
              , i_currency          => l_currency
              , i_limit_type        => l_limit_type
              , i_mod_id            => i_mod_id
              , i_product_id        => prd_api_product_pkg.get_product_id(
                                           i_entity_type  => i_entity_type
                                         , i_object_id    => i_object_id
                                         , i_eff_date     => l_start_date
                                         , i_inst_id      => i_inst_id
                                       )
              , i_service_id        => l_service_id
              , i_eff_date          => l_start_date
            );
        end if;

        begin
            select cycle_type
              into l_cycle_type
              from fcl_limit_type_vw
             where limit_type = l_limit_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error        => 'LIMIT_TYPE_NOT_FOUND'
                  , i_env_param1   => l_limit_type
                  , i_entity_type  => i_entity_type
                  , i_object_id    => i_object_id
                );
        end;

        if l_cycle_type is not null and l_cycle_id is not null
           and i_entity_type not in (
               prd_api_const_pkg.ENTITY_TYPE_PRODUCT
             , prd_api_const_pkg.ENTITY_TYPE_SERVICE
           )
        then
            if i_is_cyclic = com_api_const_pkg.TRUE then
                l_next_date :=
                    fcl_api_cycle_pkg.calc_next_date(
                        i_cycle_id          => l_cycle_id
                      , i_start_date        => l_start_date
                    );
            else
                l_next_date :=
                    fcl_api_cycle_pkg.calc_next_date(
                        i_cycle_type        => l_cycle_type
                      , i_entity_type       => i_entity_type
                      , i_object_id         => i_object_id
                      , i_start_date        => l_start_date
                      , i_inst_id           => l_inst_id
                      , i_raise_error       => com_api_type_pkg.TRUE
                    );
            end if;

            fcl_api_cycle_pkg.add_cycle_counter (
                i_cycle_type   => l_cycle_type
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_inst_id      => l_inst_id
              , i_next_date    => l_next_date
            );
        end if;

        if i_entity_type not in (
               prd_api_const_pkg.ENTITY_TYPE_PRODUCT
             , prd_api_const_pkg.ENTITY_TYPE_SERVICE
           )
        then
            fcl_api_limit_pkg.add_limit_counter (
                i_limit_type   => l_limit_type
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_inst_id      => l_inst_id
            );

        end if;
    end if;

    set_attr_value_num (
        io_id               => io_attr_value_id
      , i_service_id        => l_service_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_mod_id            => i_mod_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_value             => i_limit_id
      , i_check_start_date  => i_check_start_date
      , i_inst_id           => l_inst_id
      , i_campaign_id       => i_campaign_id
    );
end set_attr_value_limit;

procedure set_attr_value(
    io_id               in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date                          default null
  , i_end_date          in      date
  , i_value_num         in      number
  , i_value_char        in      com_api_type_pkg.t_text
  , i_value_date        in      date
  , i_data_type         in      com_api_type_pkg.t_dict_value
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_inst_id           in      com_api_type_pkg.t_inst_id    default null
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
begin
    case i_data_type
        when com_api_const_pkg.DATA_TYPE_NUMBER then
            set_attr_value_num(
                io_id               => io_id
              , i_service_id        => i_service_id
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_attr_name         => i_attr_name
              , i_mod_id            => i_mod_id
              , i_start_date        => i_start_date
              , i_end_date          => i_end_date
              , i_value             => i_value_num
              , i_check_start_date  => i_check_start_date
              , i_inst_id           => i_inst_id
              , i_campaign_id       => i_campaign_id
            );
        when com_api_const_pkg.DATA_TYPE_CHAR then
            set_attr_value_char(
                io_id               => io_id
              , i_service_id        => i_service_id
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_attr_name         => i_attr_name
              , i_mod_id            => i_mod_id
              , i_start_date        => i_start_date
              , i_end_date          => i_end_date
              , i_value             => i_value_char
              , i_check_start_date  => i_check_start_date
              , i_inst_id           => i_inst_id
              , i_campaign_id       => i_campaign_id
            );
        when com_api_const_pkg.DATA_TYPE_DATE then
            set_attr_value_date(
                io_id               => io_id
              , i_service_id        => i_service_id
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_attr_name         => i_attr_name
              , i_mod_id            => i_mod_id
              , i_start_date        => i_start_date
              , i_end_date          => i_end_date
              , i_value             => i_value_date
              , i_check_start_date  => i_check_start_date
              , i_inst_id           => i_inst_id
              , i_campaign_id       => i_campaign_id
            );
        else
            com_api_error_pkg.raise_error(
                i_error       => 'WRONG_ATTRIBUTE_DATA_TYPE'
              , i_env_param1  => i_attr_name
              , i_env_param2  => i_data_type
            );
        end case;
end set_attr_value;

end prd_api_attribute_value_pkg;
/
