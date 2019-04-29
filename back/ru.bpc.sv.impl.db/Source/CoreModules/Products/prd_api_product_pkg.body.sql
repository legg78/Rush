create or replace package body prd_api_product_pkg is
/*************************************************************
*  API for products <br />
*  Created by Kopachev D (kopachev@bpcbt.com)  at 25.11.2010 <br />
*  Module: PRD_API_PRODUCT_PKG <br />
*  @headcom
**************************************************************/

g_entity_type           com_api_type_pkg.t_dict_value;
g_object_id             com_api_type_pkg.t_long_id;
g_product_id            com_api_type_pkg.t_short_id;
g_eff_date              date;

procedure get_attr_value(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id    default null
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , o_value                out  com_api_type_pkg.t_text
  , o_data_type            out  com_api_type_pkg.t_dict_value
  , o_entity_type          out  com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id    default null
  , i_mask_error        in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_default_value     in      com_api_type_pkg.t_text       default null
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_attr_value';

    l_attribute_rec             prd_api_type_pkg.t_attribute;
    l_service_rec               prd_api_type_pkg.t_service;
    l_service_id                com_api_type_pkg.t_short_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_eff_date                  date;
    l_mods                      com_api_type_pkg.t_number_tab;
    l_values                    com_api_type_pkg.t_varchar2_tab;

    cursor cu_product_attr_cur is
        select attr_value
             , mod_id
          from (
                select v.attr_value
                     , 0                           as level_priority
                     , v.mod_id
                     , v.register_timestamp
                     , v.start_date
                     , m.priority
                  from prd_attribute_value v
                     , rul_mod m
                 where l_attribute_rec.definition_level in (prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT
                                                          , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_OBJECT)
                   and v.entity_type     = i_entity_type
                   and v.object_id       = i_object_id
                   and v.attr_id         = l_attribute_rec.id
                   and v.service_id      = l_service_id
                   and v.split_hash      = l_split_hash
                   and m.id(+)           = v.mod_id
                   and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                union all
                select v.attr_value
                     , p.level_priority
                     , v.mod_id
                     , v.register_timestamp
                     , v.start_date
                     , m.priority                  as mod_priority
                  from (
                        select connect_by_root id  as product_id
                             , level               as level_priority
                             , id                  as parent_id
                             , split_hash
                             , case when parent_id is null then 1 else 0 end top_flag
                          from prd_product
                         connect by prior parent_id = id
                           start with id = i_product_id
                       ) p
                     , prd_attribute_value v
                     , rul_mod m
                     , prd_product_service ps
                 where l_attribute_rec.definition_level in (prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT
                                                          , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE)
                   and v.entity_type     = decode(l_attribute_rec.definition_level, 'SADLSRVC', decode(p.top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                   and v.object_id       = decode(l_attribute_rec.definition_level, 'SADLSRVC', l_service_id,             p.parent_id)
                   and v.split_hash      = decode(l_attribute_rec.definition_level, 'SADLSRVC', l_service_rec.split_hash, p.split_hash)
                   and v.attr_id         = l_attribute_rec.id
                   and v.service_id      = l_service_id
                   and ps.product_id     = p.product_id
                   and ps.service_id     = l_service_id
                   and m.id(+)           = v.mod_id
                   and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
               )
        order by
              decode(level_priority, 0, 0, 1)
            , priority nulls last
            , level_priority
            , start_date desc
            , register_timestamp desc;

begin
    l_inst_id  := coalesce(
                      i_inst_id
                    , ost_api_institution_pkg.get_object_inst_id(
                          i_entity_type => i_entity_type
                        , i_object_id   => i_object_id
                        , i_mask_errors => com_api_type_pkg.TRUE
                      )
                  );
    l_eff_date := prd_cst_attribute_value_pkg.get_effective_date (
                      i_product_id        => i_product_id
                    , i_entity_type       => i_entity_type
                    , i_object_id         => i_object_id
                    , i_attr_name         => i_attr_name
                    , i_params            => i_params
                    , i_service_id        => i_service_id
                    , i_eff_date          => i_eff_date
                    , i_split_hash        => i_split_hash
                    , i_inst_id           => i_inst_id
                  );
    l_eff_date := coalesce(l_eff_date, i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id));

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    l_attribute_rec := prd_api_attribute_pkg.get_attribute(
                           i_attr_name       => i_attr_name
                         , i_is_result_cache => com_api_const_pkg.TRUE
                       );

    if i_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => i_entity_type
              , i_object_id        => i_object_id
              , i_attr_name        => i_attr_name
              , i_service_type_id  => l_attribute_rec.service_type_id
              , i_split_hash       => l_split_hash
              , i_eff_date         => l_eff_date
              , i_mask_error       => i_mask_error
              , i_inst_id          => l_inst_id
            );
    else
        l_service_id := i_service_id;
    end if;

    l_service_rec := prd_api_service_pkg.get_service_rec(
                         i_service_id => l_service_id
                     );

    if l_attribute_rec.service_type_id = l_service_rec.service_type_id then
        open cu_product_attr_cur;

        fetch cu_product_attr_cur
           bulk collect
           into l_values
              , l_mods;

        close cu_product_attr_cur;
    end if;

    if l_values.count > 0 then
        o_data_type     := l_attribute_rec.data_type;
        o_entity_type   := l_attribute_rec.entity_type;

        o_value         := rul_api_mod_pkg.select_value (
                               i_mods          => l_mods
                             , i_values        => l_values
                             , i_params        => i_params
                           );
    elsif i_use_default_value = com_api_type_pkg.TRUE then
        -- It's optional attribute with default value.
        o_value     := i_default_value;
        o_data_type := l_attribute_rec.data_type;
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' FAILED: l_service_id [#1], l_split_hash [#2], l_inst_id [#3], l_mods.count [#4], l_values.count [#5]'
          , i_env_param1 => l_service_id
          , i_env_param2 => l_split_hash
          , i_env_param3 => l_inst_id
          , i_env_param4 => l_mods.count()
          , i_env_param5 => l_values.count()
        );
        com_api_error_pkg.raise_error(
            i_error      => 'ATTRIBUTE_VALUE_NOT_DEFINED'
          , i_env_param1 => i_attr_name
          , i_env_param2 => i_product_id
          , i_env_param3 => i_object_id
          , i_env_param4 => i_entity_type
          , i_env_param5 => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_mask_error => i_mask_error
        );
    end if;

exception when others then
    if cu_product_attr_cur%isopen then
        close cu_product_attr_cur;
    end if;

    raise;
end get_attr_value;

function get_attr_value_number(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      number                          default null
) return number is
    l_value             com_api_type_pkg.t_text;
    l_data_type         com_api_type_pkg.t_dict_value;
    l_entity_type       com_api_type_pkg.t_dict_value;
begin
    get_attr_value(
        i_product_id        => i_product_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_params            => i_params
      , i_service_id        => i_service_id
      , i_eff_date          => i_eff_date
      , o_value             => l_value
      , o_data_type         => l_data_type
      , o_entity_type       => l_entity_type
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , i_mask_error        => i_mask_error
      , i_use_default_value => i_use_default_value
      , i_default_value     => to_char(i_default_value, com_api_const_pkg.NUMBER_FORMAT)
    );

    if l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        return to_number(l_value, com_api_const_pkg.NUMBER_FORMAT);
    else
        com_api_error_pkg.raise_error(
            i_error       => 'WRONG_ATTRIBUTE_DATA_TYPE'
          , i_env_param1  => i_attr_name
          , i_env_param2  => com_api_const_pkg.DATA_TYPE_NUMBER
          , i_env_param3  => l_data_type
          , i_mask_error  => i_mask_error
        );
    end if;
end get_attr_value_number;

function get_attr_value_date(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      date                            default null
) return date is
    l_value             com_api_type_pkg.t_text;
    l_data_type         com_api_type_pkg.t_dict_value;
    l_entity_type       com_api_type_pkg.t_dict_value;
begin
    get_attr_value (
        i_product_id        => i_product_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_params            => i_params
      , i_service_id        => i_service_id
      , i_eff_date          => i_eff_date
      , o_value             => l_value
      , o_data_type         => l_data_type
      , o_entity_type       => l_entity_type
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , i_use_default_value => i_use_default_value
      , i_default_value     => to_char(i_default_value, com_api_const_pkg.DATE_FORMAT)
    );

    if l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        return to_date(l_value, com_api_const_pkg.DATE_FORMAT);
    else
        com_api_error_pkg.raise_error(
            i_error         => 'WRONG_ATTRIBUTE_DATA_TYPE'
            , i_env_param1  => i_attr_name
            , i_env_param2  => com_api_const_pkg.DATA_TYPE_DATE
            , i_env_param3  => l_data_type
        );
    end if;
end get_attr_value_date;

function get_attr_value_char(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      com_api_type_pkg.t_text         default null
) return varchar2 is
    l_value             com_api_type_pkg.t_text;
    l_data_type         com_api_type_pkg.t_dict_value;
    l_entity_type       com_api_type_pkg.t_dict_value;
begin
    get_attr_value (
        i_product_id        => i_product_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_params            => i_params
      , i_service_id        => i_service_id
      , i_eff_date          => i_eff_date
      , o_value             => l_value
      , o_data_type         => l_data_type
      , o_entity_type       => l_entity_type
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , i_use_default_value => i_use_default_value
      , i_default_value     => i_default_value
    );

    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        return l_value;
    else
        com_api_error_pkg.raise_error(
            i_error           => 'WRONG_ATTRIBUTE_DATA_TYPE'
          , i_env_param1      => i_attr_name
          , i_env_param2      => com_api_const_pkg.DATA_TYPE_CHAR
          , i_env_param3      => l_data_type
        );
    end if;
end get_attr_value_char;

procedure get_fees_mods(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_fees                 out  com_api_type_pkg.t_varchar2_tab
  , o_mods                 out  com_api_type_pkg.t_number_tab
  , o_start_dates          out  com_api_type_pkg.t_date_tab
  , o_end_dates            out  com_api_type_pkg.t_date_tab
) is
    l_attribute_rec             prd_api_type_pkg.t_attribute;
    l_service_rec               prd_api_type_pkg.t_service;
    l_service_id                com_api_type_pkg.t_short_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_eff_date                  date;
    l_attr_name                 com_api_type_pkg.t_name;

    cursor cu_product_fee_cur is
        select fee_id
             , mod_id
             , start_date
             , end_date
          from (
                select v.attr_value         as fee_id
                     , m.condition          as mod_condition
                     , 0                    as level_priority
                     , v.mod_id
                     , v.register_timestamp
                     , v.start_date
                     , v.end_date
                     , m.priority
                  from prd_attribute_value v
                     , rul_mod m
                 where v.entity_type     = i_entity_type
                   and v.object_id       = i_object_id
                   and v.attr_id         = l_attribute_rec.id
                   and v.service_id      = l_service_id
                   and v.split_hash      = l_split_hash
                   and m.id(+)           = v.mod_id
                   and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                union all
                select v.attr_value
                     , m.condition          as mod_condition
                     , p.level_priority
                     , v.mod_id
                     , v.register_timestamp
                     , v.start_date
                     , v.end_date
                     , m.priority           as mod_priority
                  from (
                        select level        as level_priority
                             , id           as product_id
                             , split_hash
                          from prd_product
                         connect by prior parent_id = id
                           start with id = i_product_id
                       ) p
                     , prd_attribute_value v
                     , rul_mod m
                 where v.entity_type     = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                   and v.object_id       = p.product_id
                   and v.attr_id         = l_attribute_rec.id
                   and v.service_id      = l_service_id
                   and v.split_hash      = p.split_hash
                   and m.id(+)           = v.mod_id
                   and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
               )
      order by decode(level_priority, 0, 0, 1)
             , priority nulls last
             , level_priority
             , start_date desc
             , register_timestamp desc;

begin
    l_inst_id  := coalesce(
                      i_inst_id
                    , ost_api_institution_pkg.get_object_inst_id(
                          i_entity_type => i_entity_type
                        , i_object_id   => i_object_id
                        , i_mask_errors => com_api_type_pkg.TRUE
                      )
                  );
    l_eff_date := prd_cst_attribute_value_pkg.get_effective_date(
                      i_product_id        => i_product_id
                    , i_entity_type       => i_entity_type
                    , i_object_id         => i_object_id
                    , i_fee_type          => i_fee_type
                    , i_params            => i_params
                    , i_service_id        => i_service_id
                    , i_eff_date          => i_eff_date
                    , i_split_hash        => i_split_hash
                    , i_inst_id           => i_inst_id
                  );
    l_eff_date := coalesce(l_eff_date, i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id));

    if i_split_hash is null then
        l_split_hash  := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash  := i_split_hash;
    end if;

    l_attr_name       := prd_api_attribute_pkg.get_attr_name(
                             i_object_type => i_fee_type
                         );

    l_attribute_rec   := prd_api_attribute_pkg.get_attribute(
                             i_attr_name       => l_attr_name
                           , i_is_result_cache => com_api_const_pkg.TRUE
                           , i_mask_error      => i_mask_error
                         );

    if i_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => i_entity_type
              , i_object_id        => i_object_id
              , i_attr_name        => l_attr_name
              , i_service_type_id  => l_attribute_rec.service_type_id
              , i_split_hash       => l_split_hash
              , i_eff_date         => l_eff_date
              , i_inst_id          => l_inst_id
            );
    else
        l_service_id := i_service_id;
    end if;

    l_service_rec := prd_api_service_pkg.get_service_rec(
                         i_service_id => l_service_id
                     );

    if l_attribute_rec.service_type_id = l_service_rec.service_type_id then
        open cu_product_fee_cur;

        fetch cu_product_fee_cur
           bulk collect
           into o_fees
              , o_mods
              , o_start_dates
              , o_end_dates;

        close cu_product_fee_cur;
    end if;

exception when others then
    if cu_product_fee_cur%isopen then
        close cu_product_fee_cur;
    end if;

    raise;
end get_fees_mods;

procedure get_fees_mods(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , o_fees                 out  com_api_type_pkg.t_varchar2_tab
  , o_mods                 out  com_api_type_pkg.t_number_tab
) is
    l_start_dates               com_api_type_pkg.t_date_tab;
    l_end_dates                 com_api_type_pkg.t_date_tab;
begin
    get_fees_mods(
        i_product_id   => i_product_id
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_fee_type     => i_fee_type
      , i_params       => i_params
      , i_service_id   => i_service_id
      , i_eff_date     => i_eff_date
      , i_split_hash   => i_split_hash
      , i_inst_id      => i_inst_id
      , o_fees         => o_fees
      , o_mods         => o_mods
      , o_start_dates  => l_start_dates
      , o_end_dates    => l_end_dates
    );
end get_fees_mods;

function get_fee_id(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_short_id
is
    l_mods                      com_api_type_pkg.t_number_tab;
    l_fees                      com_api_type_pkg.t_varchar2_tab;
    l_result                    com_api_type_pkg.t_param_value;
begin
    get_fees_mods(
        i_product_id   => i_product_id
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_fee_type     => i_fee_type
      , i_params       => i_params
      , i_service_id   => i_service_id
      , i_eff_date     => i_eff_date
      , i_split_hash   => i_split_hash
      , i_inst_id      => i_inst_id
      , o_fees         => l_fees
      , o_mods         => l_mods
    );

    if l_fees.count = 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'FEE_NOT_DEFINED'
          , i_env_param1  => i_fee_type
          , i_env_param2  => i_product_id
          , i_env_param3  => i_object_id
          , i_env_param4  => i_entity_type
          , i_env_param5  => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_mask_error  => i_mask_error
        );
    end if;

    l_result := rul_api_mod_pkg.select_value(
                    i_mods    => l_mods
                  , i_values  => l_fees
                  , i_params  => i_params
                );
    return to_number(l_result, com_api_const_pkg.NUMBER_FORMAT);
end get_fee_id;

procedure get_fee_id(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_fee_id               out  com_api_type_pkg.t_short_id
  , o_start_date           out  date
  , o_end_date             out  date
) is
    l_mods                      com_api_type_pkg.t_number_tab;
    l_fees                      com_api_type_pkg.t_varchar2_tab;
    l_start_dates               com_api_type_pkg.t_date_tab;
    l_end_dates                 com_api_type_pkg.t_date_tab;
    l_index                     binary_integer;
begin
    get_fees_mods(
        i_product_id   => i_product_id
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_fee_type     => i_fee_type
      , i_params       => i_params
      , i_service_id   => i_service_id
      , i_eff_date     => i_eff_date
      , i_split_hash   => i_split_hash
      , i_inst_id      => i_inst_id
      , i_mask_error   => i_mask_error
      , o_fees         => l_fees
      , o_mods         => l_mods
      , o_start_dates  => l_start_dates
      , o_end_dates    => l_end_dates
    );

    if l_fees.count = 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'FEE_NOT_DEFINED'
          , i_env_param1  => i_fee_type
          , i_env_param2  => i_product_id
          , i_env_param3  => i_object_id
          , i_env_param4  => i_entity_type
          , i_env_param5  => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_mask_error  => i_mask_error
        );
    end if;

    l_index      := rul_api_mod_pkg.select_condition(
                        i_mods    => l_mods
                      , i_params  => i_params
                    );

    o_fee_id     := to_number(l_fees(l_index), com_api_const_pkg.NUMBER_FORMAT);
    o_start_date := l_start_dates(l_index);
    o_end_date   := l_end_dates(l_index);
exception
    when com_api_error_pkg.e_application_error then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            raise;
        else
            o_fee_id := null;
        end if;
end get_fee_id;

function get_fee_id(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_fee               in      fcl_api_type_pkg.t_fee
  , i_fee_tier          in      fcl_api_type_pkg.t_fee_tier_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_short_id is
    l_attribute_rec             prd_api_type_pkg.t_attribute;
    l_service_rec               prd_api_type_pkg.t_service;
    l_service_id                com_api_type_pkg.t_short_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_eff_date                  date;
    l_result                    com_api_type_pkg.t_param_value;
    l_attr_name                 com_api_type_pkg.t_name;
    l_fees                      com_api_type_pkg.t_varchar2_tab;

    cursor cu_product_fee_cur is
        select v.attr_value  as fee_id
          from prd_attribute_value v
         where v.entity_type  = i_entity_type
           and v.object_id    = i_object_id
           and v.attr_id      = l_attribute_rec.id
           and v.service_id   = l_service_id
           and v.split_hash   = l_split_hash
        union all
        select v.attr_value  as fee_id
          from (
                select level      as level_priority
                     , id         as product_id
                     , split_hash
                  from prd_product
                 connect by prior parent_id = id
                   start with id = i_product_id
               ) p
             , prd_attribute_value v
         where v.entity_type     = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and v.object_id       = p.product_id
           and v.attr_id         = l_attribute_rec.id
           and v.service_id      = l_service_id
           and v.split_hash      = p.split_hash;
begin
    l_inst_id  :=
        coalesce(
            i_inst_id
          , ost_api_institution_pkg.get_object_inst_id(
                i_entity_type => i_entity_type
              , i_object_id   => i_object_id
              , i_mask_errors => com_api_type_pkg.TRUE
            )
        );

    l_eff_date :=
        coalesce(
            prd_cst_attribute_value_pkg.get_effective_date(
                i_product_id  => i_product_id
              , i_entity_type => i_entity_type
              , i_object_id   => i_object_id
              , i_fee_type    => i_fee_type
              , i_params      => i_params
              , i_service_id  => i_service_id
              , i_eff_date    => i_eff_date
              , i_split_hash  => i_split_hash
              , i_inst_id     => i_inst_id
            )
          , i_eff_date
          , com_api_sttl_day_pkg.get_calc_date(
                i_inst_id     => l_inst_id
            )
        );

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    l_attr_name      := prd_api_attribute_pkg.get_attr_name(
                            i_object_type => i_fee_type
                        );

    l_attribute_rec  := prd_api_attribute_pkg.get_attribute(
                            i_attr_name       => l_attr_name
                          , i_is_result_cache => com_api_const_pkg.TRUE
                        );

    if i_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => i_entity_type
              , i_object_id        => i_object_id
              , i_attr_name        => l_attr_name
              , i_service_type_id  => l_attribute_rec.service_type_id
              , i_split_hash       => l_split_hash
              , i_eff_date         => l_eff_date
              , i_inst_id          => l_inst_id
            );
    else
        l_service_id := i_service_id;
    end if;

    l_service_rec := prd_api_service_pkg.get_service_rec(
                         i_service_id => l_service_id
                     );

    if l_attribute_rec.service_type_id = l_service_rec.service_type_id then
        open cu_product_fee_cur;

        fetch cu_product_fee_cur
           bulk collect
           into l_fees;

        close cu_product_fee_cur;
    end if;

    if i_mask_error = com_api_const_pkg.FALSE and l_fees.count = 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'FEE_NOT_DEFINED'
          , i_env_param1  => i_fee_type
          , i_env_param2  => i_product_id
          , i_env_param3  => i_object_id
          , i_env_param4  => i_entity_type
          , i_env_param5  => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_mask_error  => i_mask_error
        );
    end if;

    l_result :=
        fcl_api_fee_pkg.select_fee(
            i_fee      => i_fee
          , i_fee_tier => i_fee_tier
          , i_fees     => l_fees
        );

    return to_number(l_result, com_api_const_pkg.NUMBER_FORMAT);

exception when others then
    if cu_product_fee_cur%isopen then
        close cu_product_fee_cur;
    end if;

    raise;
end get_fee_id;

function get_cycle_id(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_short_id
is
    l_attribute_rec             prd_api_type_pkg.t_attribute;
    l_service_rec               prd_api_type_pkg.t_service;
    l_service_id                com_api_type_pkg.t_short_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_eff_date                  date;
    l_result                    com_api_type_pkg.t_param_value;
    l_result_num                com_api_type_pkg.t_short_id;
    l_fee_attr_name             com_api_type_pkg.t_name;
    l_limit_attr_name           com_api_type_pkg.t_name;
    l_cycle_attr_name           com_api_type_pkg.t_name;
    l_values                    com_api_type_pkg.t_varchar2_tab;
    l_mods                      com_api_type_pkg.t_number_tab;

    cursor cu_product_cycle_cur is
        select cycle_id
             , mod_id
          from (
                select v.attr_value         as cycle_id
                     , 0                    as level_priority
                     , v.mod_id
                     , v.register_timestamp
                     , v.start_date
                     , m.priority
                  from prd_attribute_value v
                     , rul_mod m
                 where l_attribute_rec.definition_level in (prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT
                                                          , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_OBJECT)
                   and v.entity_type     = i_entity_type
                   and v.object_id       = i_object_id
                   and v.attr_id         = l_attribute_rec.id
                   and v.service_id      = l_service_id
                   and v.split_hash      = l_split_hash
                   and v.mod_id          = m.id(+)
                   and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                union all
                select v.attr_value
                     , p.level_priority
                     , v.mod_id
                     , v.register_timestamp
                     , v.start_date
                     , m.priority           as mod_priority
                  from (
                        select connect_by_root id as product_id
                             , level              as level_priority
                             , id                 as parent_id
                             , split_hash
                             , case when parent_id is null then 1 else 0 end top_flag
                          from prd_product
                         connect by prior parent_id = id
                           start with id = i_product_id
                       ) p
                     , prd_attribute_value v
                     , rul_mod m
                     , prd_product_service ps
                 where l_attribute_rec.definition_level in (prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT
                                                          , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE)
                   and v.entity_type     = decode(l_attribute_rec.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                   and v.object_id       = decode(l_attribute_rec.definition_level, 'SADLSRVC', l_service_id,             p.parent_id)
                   and v.split_hash      = decode(l_attribute_rec.definition_level, 'SADLSRVC', l_service_rec.split_hash, p.split_hash)
                   and v.attr_id         = l_attribute_rec.id
                   and v.service_id      = l_service_id
                   and ps.product_id     = p.product_id
                   and ps.service_id     = l_service_id
                   and m.id(+)           = v.mod_id
                   and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
               )
        order by
               decode(level_priority, 0, 0, 1)
             , priority nulls last
             , level_priority
             , start_date desc
             , register_timestamp desc;

begin
    l_inst_id  := coalesce(
                      i_inst_id
                    , ost_api_institution_pkg.get_object_inst_id(
                          i_entity_type => i_entity_type
                        , i_object_id   => i_object_id
                        , i_mask_errors => com_api_type_pkg.TRUE
                      )
                  );
    l_eff_date := prd_cst_attribute_value_pkg.get_effective_date (
                      i_product_id        => i_product_id
                    , i_entity_type       => i_entity_type
                    , i_object_id         => i_object_id
                    , i_cycle_type        => i_cycle_type
                    , i_params            => i_params
                    , i_service_id        => i_service_id
                    , i_eff_date          => i_eff_date
                    , i_split_hash        => i_split_hash
                    , i_inst_id           => i_inst_id
                  );
    l_eff_date := coalesce(l_eff_date, i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id));

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    l_service_id := i_service_id;

    trc_log_pkg.debug(
        i_text => 'prd_api_product_pkg.get_cycle_id:'
               || ' i_product_id='    || i_product_id
               || ', i_entity_type='  || i_entity_type
               || ', i_object_id='    || i_object_id
               || ', i_cycle_type='   || i_cycle_type
               || ', i_params.count=' || i_params.count
               || ', l_eff_date='     || to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
               || ', l_service_id='   || l_service_id
    );

    declare
        l_fee_type   com_api_type_pkg.t_dict_value;
        l_fee_id     com_api_type_pkg.t_short_id;
    begin
        select fee_type
          into l_fee_type
          from fcl_fee_type
         where cycle_type = i_cycle_type;

        if l_service_id is null then
            l_fee_attr_name := prd_api_attribute_pkg.get_attr_name(i_object_type => l_fee_type);

            l_service_id :=
                prd_api_service_pkg.get_active_service_id(
                    i_entity_type => i_entity_type
                  , i_object_id   => i_object_id
                  , i_attr_name   => l_fee_attr_name
                  , i_split_hash  => l_split_hash
                  , i_eff_date    => l_eff_date
                  , i_inst_id     => l_inst_id
                );
        end if;

        l_fee_id :=
            get_fee_id (
                i_product_id   => i_product_id
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_fee_type     => l_fee_type
              , i_params       => i_params
              , i_service_id   => l_service_id
              , i_eff_date     => i_eff_date
              , i_split_hash   => l_split_hash
            );

        begin
            select cycle_id
              into l_result_num
              from fcl_fee
             where id = l_fee_id;

            if l_result_num is null then
                raise no_data_found;
            end if;

             return l_result_num;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'CYCLE_NOT_DEFINED'
                  , i_env_param1  => i_cycle_type
                  , i_env_param2  => i_product_id
                  , i_env_param3  => i_object_id
                  , i_env_param4  => i_entity_type
                  , i_env_param5  => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
                  , i_mask_error  => i_mask_error
                );
        end;
    exception
        when no_data_found then
            null;
    end;

    declare
        l_limit_type com_api_type_pkg.t_dict_value;
        l_limit_id   com_api_type_pkg.t_long_id;
    begin
        select limit_type
          into l_limit_type
          from fcl_limit_type
         where cycle_type = i_cycle_type;

        trc_log_pkg.debug('l_limit_type='||l_limit_type);

        if l_service_id is null then
            begin
                l_limit_attr_name := prd_api_attribute_pkg.get_attr_name(i_object_type => l_limit_type);

                l_service_id :=
                    prd_api_service_pkg.get_active_service_id(
                        i_entity_type => i_entity_type
                      , i_object_id   => i_object_id
                      , i_attr_name   => l_limit_attr_name
                      , i_split_hash  => l_split_hash
                      , i_eff_date    => l_eff_date
                      , i_inst_id     => l_inst_id
                    );
            exception
                when no_data_found then
                    null;
            end;
        end if;

        l_limit_id :=
            get_limit_id(
                i_product_id   => i_product_id
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_limit_type   => l_limit_type
              , i_params       => i_params
              , i_eff_date     => i_eff_date
              , i_split_hash   => l_split_hash
            );

        trc_log_pkg.debug('l_limit_id='||l_limit_id);

        begin
            select cycle_id
              into l_result_num
              from fcl_limit
             where id = l_limit_id;

            if l_result_num is null then
                raise no_data_found;
            end if;

            return l_result_num;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'CYCLE_NOT_DEFINED'
                  , i_env_param1  => i_cycle_type
                  , i_env_param2  => i_product_id
                  , i_env_param3  => i_object_id
                  , i_env_param4  => i_entity_type
                  , i_env_param5  => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
                  , i_mask_error  => i_mask_error
                );
        end;
    exception
        when no_data_found then
            null;
    end;

    l_cycle_attr_name := prd_api_attribute_pkg.get_attr_name(
                             i_object_type => i_cycle_type
                         );

    l_attribute_rec   := prd_api_attribute_pkg.get_attribute(
                             i_attr_name       => l_cycle_attr_name
                           , i_is_result_cache => com_api_const_pkg.TRUE
                         );

    if l_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type      => i_entity_type
              , i_object_id        => i_object_id
              , i_attr_name        => l_cycle_attr_name
              , i_service_type_id  => l_attribute_rec.service_type_id
              , i_split_hash       => l_split_hash
              , i_eff_date         => l_eff_date
              , i_inst_id          => l_inst_id
            );

        trc_log_pkg.debug(
            i_text          => 'set l_service_id to [#1]'
          , i_env_param1    => l_service_id
        );
    end if;

    l_service_rec := prd_api_service_pkg.get_service_rec(
                         i_service_id => l_service_id
                     );

    if l_attribute_rec.service_type_id = l_service_rec.service_type_id then
        open cu_product_cycle_cur;

        fetch cu_product_cycle_cur
           bulk collect
           into l_values
              , l_mods;

        close cu_product_cycle_cur;
    end if;

    for i in 1 .. l_values.count loop
        trc_log_pkg.debug(
            i_text          => 'rec.mod_id [#1], rec.cycle_id [#2]'
          , i_env_param1    => l_mods(i)
          , i_env_param2    => l_values(i)
        );
    end loop;

    if l_values.count > 0 then
        l_result := rul_api_mod_pkg.select_value(
                        i_mods     => l_mods
                      , i_values   => l_values
                      , i_params   => i_params
                    );
        return to_number(l_result, com_api_const_pkg.NUMBER_FORMAT);
    else
        com_api_error_pkg.raise_error(
            i_error       => 'CYCLE_NOT_DEFINED'
          , i_env_param1  => i_cycle_type
          , i_env_param2  => i_product_id
          , i_env_param3  => i_object_id
          , i_env_param4  => i_entity_type
          , i_env_param5  => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_mask_error  => i_mask_error
        );
    end if;

exception
    when com_api_error_pkg.e_application_error then
        if cu_product_cycle_cur%isopen then
            close cu_product_cycle_cur;
        end if;

        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
            return null;
        else
            raise;
        end if;

    when others then
        if cu_product_cycle_cur%isopen then
            close cu_product_cycle_cur;
        end if;

        raise;
end get_cycle_id;

function get_limit_id(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_limit_id: ';

    l_attribute_rec             prd_api_type_pkg.t_attribute;
    l_service_rec               prd_api_type_pkg.t_service;
    l_service_id                com_api_type_pkg.t_short_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_eff_date                  date;
    l_result                    com_api_type_pkg.t_param_value;
    l_fee_attr_name             com_api_type_pkg.t_name;
    l_limit_attr_name           com_api_type_pkg.t_name;
    l_values                    com_api_type_pkg.t_varchar2_tab;
    l_mods                      com_api_type_pkg.t_number_tab;

    cursor cu_product_limit_cur is
        select limit_id
             , mod_id
          from (
                select v.attr_value         as limit_id
                     , 0                    as level_priority
                     , v.mod_id
                     , v.register_timestamp
                     , v.start_date
                     , m.priority
                  from prd_attribute_value v
                     , rul_mod m
                 where v.entity_type     = i_entity_type
                   and v.object_id       = i_object_id
                   and v.attr_id         = l_attribute_rec.id
                   and v.service_id      = l_service_id
                   and v.split_hash      = l_split_hash
                   and m.id(+)           = v.mod_id
                   and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                union all
                select v.attr_value
                     , p.level_priority
                     , v.mod_id
                     , v.register_timestamp
                     , v.start_date
                     , m.priority           as mod_priority
                  from (
                        select level        as level_priority
                             , id           as product_id
                             , split_hash
                          from prd_product
                         connect by prior parent_id = id
                           start with id = i_product_id
                       ) p
                     , prd_attribute_value v
                     , rul_mod m
                 where v.entity_type     = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                   and v.object_id       = p.product_id
                   and v.attr_id         = l_attribute_rec.id
                   and v.service_id      = l_service_id
                   and v.split_hash      = p.split_hash
                   and m.id(+)           = v.mod_id
                   and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
               )
      order by
                decode(level_priority, 0, 0, 1)
              , priority nulls last
              , level_priority
              , start_date desc
              , register_timestamp desc;

begin
    l_inst_id  := coalesce(
                      i_inst_id
                    , ost_api_institution_pkg.get_object_inst_id(
                          i_entity_type => i_entity_type
                        , i_object_id   => i_object_id
                        , i_mask_errors => com_api_type_pkg.TRUE
                      )
                  );
    l_eff_date := prd_cst_attribute_value_pkg.get_effective_date (
                      i_product_id        => i_product_id
                    , i_entity_type       => i_entity_type
                    , i_object_id         => i_object_id
                    , i_limit_type        => i_limit_type
                    , i_params            => i_params
                    , i_service_id        => i_service_id
                    , i_eff_date          => i_eff_date
                    , i_split_hash        => i_split_hash
                    , i_inst_id           => i_inst_id
                  );
    l_eff_date := coalesce(l_eff_date, i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id));

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_eff_date [#1], i_entity_type=[#2], i_object_id=[#3]'
      , i_env_param1 => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param2 => i_entity_type
      , i_env_param3 => i_object_id
    );

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    l_service_id := i_service_id;

    declare
        l_fee_type      com_api_type_pkg.t_dict_value;
        l_fee_id        com_api_type_pkg.t_short_id;
    begin
        select fee_type
          into l_fee_type
          from fcl_fee_type
         where limit_type = i_limit_type;

        if l_service_id is null then
            l_fee_attr_name := prd_api_attribute_pkg.get_attr_name(i_object_type => l_fee_type);

            l_service_id :=
                prd_api_service_pkg.get_active_service_id(
                    i_entity_type => i_entity_type
                  , i_object_id   => i_object_id
                  , i_attr_name   => l_fee_attr_name
                  , i_split_hash  => l_split_hash
                  , i_eff_date    => l_eff_date
                  , i_mask_error  => i_mask_error
                  , i_inst_id     => l_inst_id
                );
        end if;

        l_fee_id :=
            get_fee_id (
                i_product_id    => i_product_id
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_fee_type      => l_fee_type
              , i_split_hash    => l_split_hash
              , i_params        => i_params
              , i_eff_date      => l_eff_date
            );

        declare
            l_result_num    com_api_type_pkg.t_long_id;
        begin
            select limit_id
              into l_result_num
              from fcl_fee
             where id = l_fee_id;

            if l_result_num is null then
                raise no_data_found;
            end if;

             return l_result_num;
        exception
            when no_data_found then
                if i_mask_error = com_api_type_pkg.TRUE then
                    trc_log_pkg.debug(
                        i_text        => 'Limit with type [#1] not defined in product [#2] or object [#3] of type [#4] on effective date [#5]. Case 1.'
                      , i_env_param1  => i_limit_type
                      , i_env_param2  => i_product_id
                      , i_env_param3  => i_object_id
                      , i_env_param4  => i_entity_type
                      , i_env_param5  => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
                    );
                    return null;
                else
                    com_api_error_pkg.raise_error(
                        i_error             => 'LIMIT_NOT_DEFINED'
                        , i_env_param1      => i_limit_type
                        , i_env_param2      => i_product_id
                        , i_env_param3      => i_object_id
                        , i_env_param4      => i_entity_type
                        , i_env_param5      => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
                    );
                end if;
        end;
    exception
        when no_data_found then
            null;
    end;

    l_limit_attr_name := prd_api_attribute_pkg.get_attr_name(i_object_type => i_limit_type);

    l_attribute_rec   := prd_api_attribute_pkg.get_attribute(
                             i_attr_name       => l_limit_attr_name
                           , i_is_result_cache => com_api_const_pkg.TRUE
                         );

    if l_service_id is null then
        l_service_id :=
            prd_api_service_pkg.get_active_service_id(
                i_entity_type     => i_entity_type
              , i_object_id       => i_object_id
              , i_attr_name       => l_limit_attr_name
              , i_service_type_id => l_attribute_rec.service_type_id
              , i_split_hash      => l_split_hash
              , i_eff_date        => l_eff_date
              , i_mask_error      => i_mask_error
              , i_inst_id         => l_inst_id
            );
    end if;

    l_service_rec := prd_api_service_pkg.get_service_rec(
                         i_service_id => l_service_id
                     );

    if l_attribute_rec.service_type_id = l_service_rec.service_type_id then
        open cu_product_limit_cur;

        fetch cu_product_limit_cur
           bulk collect
           into l_values
              , l_mods;

        close cu_product_limit_cur;
    end if;

    if l_values.count > 0 then
        l_result := rul_api_mod_pkg.select_value (
            i_mods     => l_mods
          , i_values   => l_values
          , i_params   => i_params
        );

        return to_number(l_result, com_api_const_pkg.NUMBER_FORMAT);
    else
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text        => 'Limit with type [#1] not defined in product [#2] or object [#3] of type [#4] on effective date [#5]. Case 2.'
              , i_env_param1  => i_limit_type
              , i_env_param2  => i_product_id
              , i_env_param3  => i_object_id
              , i_env_param4  => i_entity_type
              , i_env_param5  => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
            );
            return null;
        else
            com_api_error_pkg.raise_error(
                i_error       => 'LIMIT_NOT_DEFINED'
              , i_env_param1  => i_limit_type
              , i_env_param2  => i_product_id
              , i_env_param3  => i_object_id
              , i_env_param4  => i_entity_type
              , i_env_param5  => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
            );
        end if;
    end if;

exception when others then
    if cu_product_limit_cur%isopen then
        close cu_product_limit_cur;
    end if;

    raise;
end get_limit_id;

function get_limit_id(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is
    l_params            com_api_type_pkg.t_param_tab;
begin
    return get_limit_id(
               i_product_id  => get_product_id(
                                    i_entity_type => i_entity_type
                                  , i_object_id   => i_object_id
                                  , i_eff_date    => i_eff_date
                                  , i_inst_id     => i_inst_id
                                )
             , i_entity_type => i_entity_type
             , i_object_id   => i_object_id
             , i_limit_type  => i_limit_type
             , i_params      => l_params
             , i_service_id  => i_service_id
             , i_eff_date    => i_eff_date
             , i_split_hash  => i_split_hash
             , i_inst_id     => i_inst_id
             , i_mask_error  => i_mask_error
           );
exception
    when others then
        if i_mask_error = com_api_type_pkg.FALSE
           or
           com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.FALSE
        then
            raise;
        end if;

        return null;

end get_limit_id; -- 2th

function get_product_id(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date                            default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
) return com_api_type_pkg.t_short_id
is
    l_result                    com_api_type_pkg.t_short_id;
    l_eff_date                  date;
    l_inst_id                   com_api_type_pkg.t_inst_id;
begin
    l_inst_id  := coalesce(
                      i_inst_id
                    , ost_api_institution_pkg.get_object_inst_id(
                          i_entity_type => i_entity_type
                        , i_object_id   => i_object_id
                        , i_mask_errors => com_api_type_pkg.TRUE
                      )
                  );
    l_eff_date := coalesce(i_eff_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id));

    if g_product_id is not null then
        if g_entity_type = i_entity_type and g_object_id = i_object_id and g_eff_date = l_eff_date then
            return g_product_id;
        end if;
    end if;

    case i_entity_type
    when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        select nvl(h.product_id, b.product_id)
          into l_result
          from acq_merchant a
             , prd_contract b
             , prd_contract_history h
         where a.id          = i_object_id
           and a.contract_id = b.id
           and a.split_hash  = b.split_hash
           and h.split_hash(+) = a.split_hash
           and h.contract_id(+) = a.contract_id
           and h.start_date(+) <= l_eff_date
           and nvl(h.end_date(+), l_eff_date) >= l_eff_date;

    when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
        select nvl(h.product_id, b.product_id)
          into l_result
          from acq_terminal a
             , prd_contract b
             , prd_contract_history h
         where a.id          = i_object_id
           and a.contract_id = b.id
           and a.split_hash  = b.split_hash
           and h.split_hash(+) = a.split_hash
           and h.contract_id(+) = a.contract_id
           and h.start_date(+) <= l_eff_date
           and nvl(h.end_date(+), l_eff_date) >= l_eff_date;

    when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select nvl(h.product_id, b.product_id)
          into l_result
          from acc_account a
             , prd_contract b
             , prd_contract_history h
         where a.id          = i_object_id
           and a.contract_id = b.id
           and a.split_hash  = b.split_hash
           and h.split_hash(+) = a.split_hash
           and h.contract_id(+) = a.contract_id
           and h.start_date(+) <= l_eff_date
           and nvl(h.end_date(+), l_eff_date) >= l_eff_date;

    when iss_api_const_pkg.ENTITY_TYPE_CARD then
        select nvl(h.product_id, b.product_id)
          into l_result
          from iss_card a
             , prd_contract b
             , prd_contract_history h
         where a.id          = i_object_id
           and a.contract_id = b.id
           and a.split_hash  = b.split_hash
           and h.split_hash(+) = a.split_hash
           and h.contract_id(+) = a.contract_id
           and h.start_date(+) <= l_eff_date
           and nvl(h.end_date(+), l_eff_date) >= l_eff_date;

    when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select nvl(h.product_id, c.product_id)
          into l_result
          from iss_card a
             , iss_card_instance b
             , prd_contract c
             , prd_contract_history h
         where b.id          = i_object_id
           and a.id          = b.card_id
           and a.contract_id = c.id
           and a.split_hash  = b.split_hash
           and h.split_hash(+) = a.split_hash
           and h.contract_id(+) = a.contract_id
           and h.start_date(+) <= l_eff_date
           and nvl(h.end_date(+), l_eff_date) >= l_eff_date;

    when iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select nvl(h.product_id, b.product_id)
          into l_result
          from prd_customer a
             , prd_contract b
             , prd_contract_history h
         where a.id          = i_object_id
           and a.contract_id = b.id
           and a.split_hash  = b.split_hash
           and h.split_hash(+) = a.split_hash
           and h.contract_id(+) = a.contract_id
           and h.start_date(+) <= l_eff_date
           and nvl(h.end_date(+), l_eff_date) >= l_eff_date;

    when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
        select nvl(h.product_id, a.product_id)
          into l_result
          from prd_contract a
             , prd_contract_history h
         where a.id          = i_object_id
           and h.contract_id(+) = a.id
           and h.split_hash(+) = a.split_hash
           and h.start_date(+) <= l_eff_date
           and nvl(h.end_date(+), l_eff_date) >= l_eff_date;

    when ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
        select nvl(h.product_id, b.product_id)
          into l_result
          from prd_customer c
             , prd_contract b
             , prd_contract_history h
         where c.ext_entity_type    = i_entity_type
           and c.ext_object_id      = i_object_id
           and c.contract_id        = b.id
           and c.split_hash         = b.split_hash
           and b.contract_type      = ost_api_const_pkg.CONTRACT_TYPE_INSTITUTION
           and h.split_hash(+)      = c.split_hash
           and h.contract_id(+)     = c.contract_id
           and h.start_date(+)      <= l_eff_date
           and nvl(h.end_date(+), l_eff_date) >= l_eff_date;

    else
        l_result := null;

    end case;

    g_entity_type := i_entity_type;
    g_object_id   := i_object_id;
    g_product_id  := l_result;
    g_eff_date    := l_eff_date;

    return l_result;
exception
    when no_data_found then
        return null;
end get_product_id;

function get_product_type(
    i_product_id        in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value is
    l_product_type      com_api_type_pkg.t_dict_value;
begin
    for rec in (
        select a.product_type
          from prd_product_vw a
         where a.id = i_product_id
    ) loop
        l_product_type := rec.product_type;
    end loop;

    return l_product_type;
end get_product_type;

function generate_product_number(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date                            default com_api_sttl_day_pkg.get_sysdate()
) return com_api_type_pkg.t_name
is
    l_params            com_api_type_pkg.t_param_tab;
    l_result            com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.generate_product_number: initialization of l_params: '
                     || 'i_product_id [#1], i_inst_id [#2], i_eff_date [#3]'
      , i_env_param1 => i_product_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => prd_api_const_pkg.PRODUCT_NAME_FORMAT_PRODUCT_ID
      , i_value   => i_product_id
    );
    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => prd_api_const_pkg.PRODUCT_NAME_FORMAT_INST_ID
      , i_value   => i_inst_id
    );
    rul_api_param_pkg.set_param(
        io_params => l_params
      , i_name    => prd_api_const_pkg.PRODUCT_NAME_FORMAT_EFF_DATE
      , i_value   => i_eff_date
    );

    l_result := rul_api_name_pkg.get_name(
                    i_format_id  => prd_api_const_pkg.PRODUCT_NAME_FORMAT_ID
                  , i_param_tab  => l_params
                );

    return l_result;
end generate_product_number;

function get_product_id(
    i_product_number    in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_product_id: ';
    l_product_id                com_api_type_pkg.t_short_id;
    l_error_message             com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_product_number [#1], i_inst_id [#2], i_mask_error [#3]'
      , i_env_param1 => i_product_number
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_mask_error
    );

    begin
        select id
          into l_product_id
          from prd_product
         where product_number = i_product_number
           and inst_id        = i_inst_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'PRODUCT_NOT_FOUND'
                  , i_env_param1 => i_product_number
                );
            else
                l_error_message := ' - product NOT FOUND';
            end if;
        when too_many_rows then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'DUPLICATE_PRODUCT_NUMBER'
                  , i_env_param1 => i_product_number
                  , i_env_param2 => i_inst_id
                );
            else
                l_error_message := ' - DUPLICATED product number';
            end if;
    end;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'found product_id [#1]' || l_error_message
      , i_env_param1 => l_product_id
    );

    return l_product_id;
end get_product_id;

function get_product_number(
    i_product_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name is
    l_result        com_api_type_pkg.t_name;
begin
    select a.product_number
      into l_result
      from prd_product a
     where a.id = i_product_id;

    return l_result;
exception
    when no_data_found then
        return to_char(null);
end get_product_number;

function get_product_contract_type(
    i_product_id        in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value
is
    l_result com_api_type_pkg.t_dict_value;
begin
    select contract_type
      into l_result
      from prd_product
     where id = i_product_id;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'PRODUCT_NOT_FOUND'
          , i_env_param1  => i_product_id
        );
end get_product_contract_type;

function get_attr_value_number(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_product_id        in      com_api_type_pkg.t_short_id     default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      number                          default null
) return number is
    l_params            com_api_type_pkg.t_param_tab;
    l_save_mask_error   com_api_type_pkg.t_boolean;
    l_product_id        com_api_type_pkg.t_short_id  := i_product_id;
    l_result            number;
begin
    l_save_mask_error := com_api_error_pkg.get_mask_error;
    com_api_error_pkg.set_mask_error(
        i_mask_error  => i_mask_error
    );

    if l_product_id is null then
        l_product_id := get_product_id(
                            i_entity_type => i_entity_type
                          , i_object_id   => i_object_id
                          , i_eff_date    => i_eff_date
                          , i_inst_id     => i_inst_id
                        );
    end if;

    l_result := get_attr_value_number(
        i_product_id        => l_product_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_params            => l_params
      , i_service_id        => i_service_id
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , i_use_default_value => i_use_default_value
      , i_default_value     => i_default_value
    );

    com_api_error_pkg.set_mask_error(
        i_mask_error  => l_save_mask_error
    );
    return l_result;
exception
    when others then
        com_api_error_pkg.set_mask_error(
            i_mask_error  => l_save_mask_error
        );

        if i_mask_error = com_api_type_pkg.FALSE
           or
           com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.FALSE
        then
            raise;
        end if;

        return null;
end get_attr_value_number;

function get_attr_value_char(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_use_default_value in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_default_value     in      com_api_type_pkg.t_text         default null
) return varchar2
is
    l_params            com_api_type_pkg.t_param_tab;
    l_save_mask_error   com_api_type_pkg.t_boolean;
    l_result            com_api_type_pkg.t_text;
begin
    l_save_mask_error := com_api_error_pkg.get_mask_error;
    com_api_error_pkg.set_mask_error(
        i_mask_error  => i_mask_error
    );

    l_result := get_attr_value_char(
        i_product_id        => get_product_id(
                                   i_entity_type => i_entity_type
                                 , i_object_id   => i_object_id
                                 , i_eff_date    => i_eff_date
                                 , i_inst_id     => i_inst_id
                               )
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_params            => l_params
      , i_service_id        => i_service_id
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , i_use_default_value => i_use_default_value
      , i_default_value     => i_default_value
    );

    com_api_error_pkg.set_mask_error(
        i_mask_error  => l_save_mask_error
    );
    return l_result;
exception
    when others then
        com_api_error_pkg.set_mask_error(
            i_mask_error  => l_save_mask_error
        );

        if i_mask_error = com_api_type_pkg.FALSE
           or
           com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.FALSE
        then
            raise;
        end if;

        return null;
end get_attr_value_char;

procedure get_fee_amount(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_base_amount       in      com_api_type_pkg.t_money
  , i_base_count        in      com_api_type_pkg.t_long_id      default 1
  , i_base_currency     in      com_api_type_pkg.t_curr_code
  , io_fee_currency     in out  com_api_type_pkg.t_curr_code
  , o_fee_amount           out  com_api_type_pkg.t_money
  , i_calc_period       in      com_api_type_pkg.t_tiny_id      default null
  , i_fee_included      in      com_api_type_pkg.t_boolean      default null
  , i_start_date        in      date                            default null
  , i_end_date          in      date                            default null
  , i_tier_amount       in      com_api_type_pkg.t_money        default null
  , i_tier_count        in      com_api_type_pkg.t_long_id      default null
  , i_oper_date         in      date                            default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_fee_amount';
    l_fee_id                    com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_product_id [#1], i_entity_type [#2], i_object_id [#3], i_fee_type [#4]'
                                   || ', i_base_amount [#5]'
      , i_env_param1 => i_product_id
      , i_env_param2 => i_entity_type
      , i_env_param3 => i_object_id
      , i_env_param4 => i_fee_type
      , i_env_param5 => i_base_amount
    );

    begin
        l_fee_id :=
            prd_api_product_pkg.get_fee_id(
                i_product_id   => i_product_id
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_fee_type     => i_fee_type
              , i_service_id   => i_service_id
              , i_params       => i_params
              , i_eff_date     => i_eff_date
              , i_split_hash   => i_split_hash
              , i_inst_id      => i_inst_id
              , i_mask_error   => i_mask_error
            );
    exception
        when com_api_error_pkg.e_application_error then
            if      nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                and com_api_error_pkg.get_last_error() in ('FEE_NOT_DEFINED')
            then
                null;
            else
                raise;
            end if;
    end;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': l_fee_id [#1]'
      , i_env_param1 => l_fee_id
    );

    if l_fee_id is not null then
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id           => l_fee_id
          , i_base_amount      => i_base_amount
          , i_base_count       => i_base_count
          , i_base_currency    => i_base_currency
          , i_entity_type      => i_entity_type
          , i_object_id        => i_object_id
          , i_eff_date         => i_eff_date
          , i_calc_period      => i_calc_period
          , i_split_hash       => i_split_hash
          , i_fee_included     => i_fee_included
          , io_fee_currency    => io_fee_currency
          , o_fee_amount       => o_fee_amount
          , i_start_date       => i_start_date
          , i_end_date         => i_end_date
          , i_tier_amount      => i_tier_amount
          , i_tier_count       => i_tier_count
          , i_oper_date        => i_oper_date
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> o_fee_amount [#1], io_fee_currency [#2]'
      , i_env_param1 => o_fee_amount
      , i_env_param2 => io_fee_currency
    );
exception
    when com_api_error_pkg.e_application_error then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
            o_fee_amount := null;
        else
            raise;
        end if;
end get_fee_amount;

end prd_api_product_pkg;
/
