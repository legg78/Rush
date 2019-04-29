create or replace package body app_api_service_pkg as
/******************************************************************
 * The api for app service <br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 26.11.2010 <br />
 * Module: app_api_service_pkg <br />
 * @headcom
 ******************************************************************/

function add_modifier(
    i_scale_id             in            com_api_type_pkg.t_tiny_id
  , i_mod_condition        in            com_api_type_pkg.t_text
  , i_mod_name             in            com_api_type_pkg.t_name
) return com_api_type_pkg.t_tiny_id
is
    l_mod_id               com_api_type_pkg.t_tiny_id;
    l_seq_num              com_api_type_pkg.t_seqnum;
begin
    rul_api_mod_pkg.add_mod(
        o_id           => l_mod_id
      , o_seqnum       => l_seq_num
      , i_scale_id     => i_scale_id
      , i_condition    => i_mod_condition
      , i_priority     => null
      , i_lang         => com_ui_user_env_pkg.get_user_lang
      , i_name         => i_mod_name
      , i_description  => null
    );
    return l_mod_id;
end;

procedure process_modifier(
    i_attr_id              in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_mod_condition        in            com_api_type_pkg.t_text
  , i_mod_name             in            com_api_type_pkg.t_name
  , io_mod_id              in out nocopy com_api_type_pkg.t_tiny_id
) is
    l_scale_id             com_api_type_pkg.t_tiny_id;
    l_mod_cnt              com_api_type_pkg.t_tiny_id;
    l_mod_id               com_api_type_pkg.t_tiny_id;
begin
    if io_mod_id is not null then
        trc_log_pkg.debug(
           i_text        => 'Going to check scale for attribute [#1], mod_id [#2], inst [#3]'
         , i_env_param1  => i_attr_id
         , i_env_param2  => io_mod_id
         , i_env_param3  => i_inst_id
        );

        begin
            select s.id
              into l_scale_id
              from rul_mod m
                 , prd_attribute_scale s
             where m.scale_id = s.scale_id
               and m.id = io_mod_id
               and s.attr_id = i_attr_id
               and s.inst_id = i_inst_id;

            trc_log_pkg.debug(
                i_text          => 'Scale id [#1]'
              , i_env_param1    => l_scale_id
            );

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'ATTRIBUTE_SCALE_NOT_FOUND'
                  , i_env_param1 => i_attr_id
                );
        end;

    elsif i_mod_condition is not null then
        trc_log_pkg.debug(
           i_text        => 'Going to find scale for attribute [#1]'
         , i_env_param1  => i_attr_id
        );

        begin
            select scale_id
              into l_scale_id
              from prd_attribute_scale
             where attr_id = i_attr_id
               and inst_id = i_inst_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'ATTRIBUTE_SCALE_NOT_FOUND'
                  , i_env_param1 => i_attr_id
                );
        end;

        if l_scale_id is not null then
            trc_log_pkg.debug(
                i_text        => 'Going to find existing modifier with name [#1] and condition [#2] within scale [#3]'
              , i_env_param1  => i_mod_name
              , i_env_param2  => i_mod_condition
              , i_env_param3  => l_scale_id
            );

            select min(m.id) as mod_id
                 , count(*) as mod_cnt
              into l_mod_id
                 , l_mod_cnt
              from rul_mod m
             where replace(m.condition, ' ') = replace(i_mod_condition, ' ')
               and m.scale_id = l_scale_id;

            if l_mod_cnt = 0 then
                trc_log_pkg.debug(
                    i_text       => 'Existing modifier was not found, new modifier will be created'
                );

                if i_mod_name is null then
                    com_api_error_pkg.raise_error(
                        i_error => 'UNABLE_TO_CREATE_MODIFIER'
                    );
                end if;

                l_mod_id :=
                    add_modifier(
                        i_scale_id       => l_scale_id
                      , i_mod_condition  => i_mod_condition
                      , i_mod_name       => i_mod_name
                    );

            elsif l_mod_cnt = 1 then
                trc_log_pkg.debug(
                    i_text       => 'Existing modifier [#1] found'
                  , i_env_param1 => l_mod_id
                );

            else
                com_api_error_pkg.raise_error(
                    i_error => 'TOO_MANY_MODIFIERS_FOUND'
                );
            end if;
        end if;

        io_mod_id := l_mod_id;
    end if;
end process_modifier;

procedure process_fee_attribute(
    i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_service_id           in            com_api_type_pkg.t_short_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_params               in            com_api_type_pkg.t_param_tab
  , i_campaign_id          in            com_api_type_pkg.t_short_id    default null
  , i_start_date           in            date                           default null
  , i_end_date             in            date                           default null
) is
    l_fee_rate_calc        com_api_type_pkg.t_dict_value;
    l_fee_base_calc        com_api_type_pkg.t_dict_value;
    l_attr_id_tab          com_api_type_pkg.t_number_tab;
    l_attribute_tab        com_api_type_pkg.t_number_tab;
    l_attribute_rec        prd_api_type_pkg.t_attribute;
    l_value_id             com_api_type_pkg.t_long_id;
    l_fee_fixed_value      com_api_type_pkg.t_money;
    l_fee_percent_value    com_api_type_pkg.t_money;
    l_currency             com_api_type_pkg.t_curr_code;
    l_start_date           date;
    l_end_date             date;
    l_fee_id               com_api_type_pkg.t_long_id;
    l_cycle_id             com_api_type_pkg.t_long_id;
    l_limit_id             com_api_type_pkg.t_long_id;
    l_created_fee_id       com_api_type_pkg.t_long_id;
    l_seqnum               com_api_type_pkg.t_seqnum;
    l_mod_condition        com_api_type_pkg.t_text;
    l_mod_name             com_api_type_pkg.t_name;
    l_mod_id               com_api_type_pkg.t_tiny_id;
    l_cycle_type           com_api_type_pkg.t_dict_value;
    l_need_fee_id          com_api_type_pkg.t_boolean;
    l_length_algo          com_api_type_pkg.t_dict_value;

    l_fee_tier_tab         com_api_type_pkg.t_number_tab;
    l_sum_threshold        com_api_type_pkg.t_money;
    l_count_threshold      com_api_type_pkg.t_money;
    l_fee_min_value        com_api_type_pkg.t_money;
    l_fee_max_value        com_api_type_pkg.t_money;
    l_threshold_tab        t_threshold_tab;
    l_cycle_data_id        com_api_type_pkg.t_long_id;
    l_cycle_start_date     date;
    l_cycle_length_type    com_api_type_pkg.t_dict_value;
    l_cycle_length         com_api_type_pkg.t_tiny_id;
    l_cycle_workdays_only  com_api_type_pkg.t_boolean;
    l_fee_cycle_type       com_api_type_pkg.t_dict_value;
begin
    app_api_application_pkg.get_appl_id_value(
        i_element_name  => 'ATTRIBUTE_FEE'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_attr_id_tab
      , o_appl_data_id  => l_attribute_tab
    );

    for i in 1 .. nvl(l_attribute_tab.last, 0) loop

        l_attribute_rec := prd_api_attribute_pkg.get_attribute(
                               i_attr_id    => l_attr_id_tab(i)
                             , i_mask_error => com_api_type_pkg.FALSE
                           );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FEE_RATE_CALC'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_fee_rate_calc
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FEE_BASE_CALC'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_fee_base_calc
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FEE_FIXED_VALUE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_fee_fixed_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FEE_PERCENT_VALUE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_fee_percent_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FEE_MIN_VALUE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_fee_min_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FEE_MAX_VALUE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_fee_max_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CURRENCY'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_currency
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'START_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_start_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'END_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_end_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_CONDITION'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_condition
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_NAME'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_ID'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CYCLE_LENGTH_TYPE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_cycle_type
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'LENGTH_TYPE_ALGORITHM'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_length_algo
        );

        if l_fee_percent_value is null and l_fee_fixed_value is null then
            com_api_error_pkg.raise_error(
                i_error      => 'UNABLE_TO_CREATE_FEE_TIER'
              , i_env_param1 => l_fee_percent_value
              , i_env_param2 => l_fee_fixed_value
            );
        end if;

        process_modifier(
            i_attr_id        => l_attr_id_tab(i)
          , i_inst_id        => i_inst_id
          , i_mod_condition  => l_mod_condition
          , i_mod_name       => l_mod_name
          , io_mod_id        => l_mod_id
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name   => 'CYCLE'
          , i_parent_id      => l_attribute_tab(i)
          , o_appl_data_id   => l_cycle_data_id
        );

        if l_cycle_data_id is not null then
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CYCLE_START_DATE'
              , i_parent_id      => l_cycle_data_id
              , o_element_value  => l_cycle_start_date
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'CYCLE_LENGTH_TYPE'
              , i_parent_id      => l_cycle_data_id
              , o_element_value  => l_cycle_length_type
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'CYCLE_LENGTH'
              , i_parent_id      => l_cycle_data_id
              , o_element_value  => l_cycle_length
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'CYCLE_WORKDAYS_ONLY'
              , i_parent_id      => l_cycle_data_id
              , o_element_value  => l_cycle_workdays_only
            );

            select cycle_type
              into l_fee_cycle_type
              from fcl_fee_type_vw
             where fee_type = l_attribute_rec.object_type;

            fcl_ui_cycle_pkg.add_cycle(
                i_cycle_type     => l_fee_cycle_type
              , i_length_type    => l_cycle_length_type
              , i_cycle_length   => l_cycle_length
              , i_trunc_type     => null
              , i_inst_id        => i_inst_id
              , i_workdays_only  => l_cycle_workdays_only
              , o_cycle_id       => l_cycle_id
            );

            fcl_api_cycle_pkg.add_cycle_counter(
                i_cycle_type      => l_fee_cycle_type
              , i_entity_type     => i_entity_type
              , i_object_id       => i_object_id
              , i_split_hash      => null
              , i_next_date       => coalesce(l_cycle_start_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id))
              , i_inst_id         => i_inst_id
            );
        else
            l_cycle_id := null;
        end if;
        l_limit_id := null;

        if l_attribute_rec.definition_level = prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT then
            select case
                       when cycle_type is not null or limit_type is not null then
                           com_api_const_pkg.TRUE
                       else
                           com_api_const_pkg.FALSE
                   end
              into l_need_fee_id
              from fcl_fee_type
             where fee_type = l_attribute_rec.object_type;

            if l_need_fee_id = com_api_const_pkg.TRUE then
                begin
                    l_fee_id := prd_api_product_pkg.get_fee_id(
                        i_product_id     => i_product_id
                      , i_entity_type    => i_entity_type
                      , i_object_id      => i_object_id
                      , i_fee_type       => l_attribute_rec.object_type
                      , i_params         => i_params
                      , i_service_id     => i_service_id
                      , i_eff_date       => com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id)
                      , i_inst_id        => i_inst_id
                      , i_mask_error     => com_api_const_pkg.TRUE
                    );

                    select nvl(l_cycle_id, min(cycle_id))
                         , min(limit_id)
                      into l_cycle_id
                         , l_limit_id
                      from fcl_fee_vw
                     where id = l_fee_id;
                exception
                    when com_api_error_pkg.e_application_error then
                        trc_log_pkg.debug(
                            i_text       => 'Fee with type [#1] was not defined in parent product'
                          , i_env_param1 => l_attribute_rec.object_type
                         );
                end;
            end if;
        end if;

        fcl_ui_fee_pkg.add_fee(
            i_fee_type       => l_attribute_rec.object_type
          , i_currency       => l_currency
          , i_fee_rate_calc  => l_fee_rate_calc
          , i_fee_base_calc  => nvl(l_fee_base_calc, fcl_api_const_pkg.FEE_BASE_INCOMING_AMOUNT)
          , i_limit_id       => l_limit_id
          , i_cycle_id       => l_cycle_id
          , i_inst_id        => i_inst_id
          , o_fee_id         => l_created_fee_id
          , o_seqnum         => l_seqnum
        );

        l_threshold_tab.delete;

        fcl_ui_fee_pkg.add_fee_tier(
            i_fee_id                => l_created_fee_id
          , i_fixed_rate            => l_fee_fixed_value
          , i_percent_rate          => l_fee_percent_value
          , i_min_value             => l_fee_min_value
          , i_max_value             => l_fee_max_value
          , i_length_type           => l_cycle_type
          , i_sum_threshold         => 0
          , i_count_threshold       => 0
          , i_length_type_algorithm => l_length_algo
          , o_fee_tier_id           => l_value_id
          , o_seqnum                => l_seqnum
        );
        l_threshold_tab(1).sum_threshold   := 0;
        l_threshold_tab(1).count_threshold := 0;

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'FEE_TIER'
          , i_parent_id     => l_attribute_tab(i)
          , o_appl_data_id  => l_fee_tier_tab
        );

        for i in 1 .. nvl(l_fee_tier_tab.last, 0) loop

            app_api_application_pkg.get_element_value(
                i_element_name   => 'SUM_THRESHOLD'
              , i_parent_id      => l_fee_tier_tab(i)
              , o_element_value  => l_sum_threshold
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'COUNT_THRESHOLD'
              , i_parent_id      => l_fee_tier_tab(i)
              , o_element_value  => l_count_threshold
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'FEE_FIXED_VALUE'
              , i_parent_id      => l_fee_tier_tab(i)
              , o_element_value  => l_fee_fixed_value
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'FEE_PERCENT_VALUE'
              , i_parent_id      => l_fee_tier_tab(i)
              , o_element_value  => l_fee_percent_value
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'FEE_MIN_VALUE'
              , i_parent_id      => l_fee_tier_tab(i)
              , o_element_value  => l_fee_min_value
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'FEE_MAX_VALUE'
              , i_parent_id      => l_fee_tier_tab(i)
              , o_element_value  => l_fee_max_value
            );

            if nvl(l_sum_threshold, 0) = 0 and nvl(l_count_threshold, 0) = 0 then

                com_api_error_pkg.raise_error(
                    i_error      => 'FEE_TIER_THRESHOLD_IS_NULL'
                  , i_env_param1 => l_attribute_rec.object_type
                  , i_env_param2 => l_sum_threshold
                  , i_env_param3 => l_count_threshold
                );
            else
                -- check when tier already added
                for t in 1..l_threshold_tab.count loop
                    if l_sum_threshold = l_threshold_tab(t).sum_threshold and l_count_threshold = l_threshold_tab(t).count_threshold then

                        com_api_error_pkg.raise_error(
                            i_error      => 'FEE_TIER_THRESHOLD_EXISTS'
                          , i_env_param1 => l_attribute_rec.object_type
                          , i_env_param2 => l_sum_threshold
                          , i_env_param3 => l_count_threshold
                        );
                    end if;
                end loop;

                fcl_ui_fee_pkg.add_fee_tier(
                    i_fee_id                => l_created_fee_id
                  , i_fixed_rate            => l_fee_fixed_value
                  , i_percent_rate          => l_fee_percent_value
                  , i_min_value             => l_fee_min_value
                  , i_max_value             => l_fee_max_value
                  , i_length_type           => l_cycle_type
                  , i_sum_threshold         => l_sum_threshold
                  , i_count_threshold       => l_count_threshold
                  , i_length_type_algorithm => l_length_algo
                  , o_fee_tier_id           => l_value_id
                  , o_seqnum                => l_seqnum
                );

                l_threshold_tab(l_threshold_tab.count + 1).sum_threshold := l_sum_threshold;
                l_threshold_tab(l_threshold_tab.count).count_threshold   := l_count_threshold;
            end if;
        end loop;

        l_value_id := null;
        prd_ui_attribute_value_pkg.set_attr_value_fee(
            io_attr_value_id    => l_value_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_name         => l_attribute_rec.attr_name
          , i_mod_id            => l_mod_id
          , i_start_date        => nvl(i_start_date, l_start_date)
          , i_end_date          => nvl(i_end_date, l_end_date)
          , i_fee_id            => l_created_fee_id
          , i_check_start_date  => com_api_type_pkg.FALSE
          , i_campaign_id       => i_campaign_id
        );
    end loop;

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'ATTRIBUTE_FEE'
        );
end process_fee_attribute;

procedure process_limit_attribute(
    i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_service_id           in            com_api_type_pkg.t_short_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_params               in            com_api_type_pkg.t_param_tab
  , i_campaign_id          in            com_api_type_pkg.t_short_id    default null
  , i_start_date           in            date                           default null
  , i_end_date             in            date                           default null
) is
    l_attr_id_tab          com_api_type_pkg.t_number_tab;
    l_attribute_tab        com_api_type_pkg.t_number_tab;
    l_start_date           date;
    l_end_date             date;
    l_attr_name            com_api_type_pkg.t_name;
    l_data_type            com_api_type_pkg.t_dict_value;
    l_object_type          com_api_type_pkg.t_dict_value;
    l_limit_count_value    com_api_type_pkg.t_long_id;
    l_limit_sum_value      com_api_type_pkg.t_money;
    l_currency             com_api_type_pkg.t_curr_code;
    l_counter_algorithm    com_api_type_pkg.t_dict_value;
    l_cycle_id             com_api_type_pkg.t_long_id;
    l_limit_id             com_api_type_pkg.t_long_id;
    l_created_limit_id     com_api_type_pkg.t_long_id;
    l_value_id             com_api_type_pkg.t_long_id;
    l_definition_level     com_api_type_pkg.t_dict_value;
    l_mod_condition        com_api_type_pkg.t_text;
    l_mod_name             com_api_type_pkg.t_name;
    l_mod_id               com_api_type_pkg.t_tiny_id;
    l_check_type           com_api_type_pkg.t_dict_value;
    l_cycle_type           com_api_type_pkg.t_dict_value;

    l_limit_type           com_api_type_pkg.t_dict_value;
    l_cycle_data_id        com_api_type_pkg.t_long_id;
    l_cycle_start_date     date;
    l_cycle_length_type    com_api_type_pkg.t_dict_value;
    l_cycle_length         com_api_type_pkg.t_tiny_id;
    l_cycle_workdays_only  com_api_type_pkg.t_boolean;
begin
   app_api_application_pkg.get_appl_id_value(
        i_element_name  => 'ATTRIBUTE_LIMIT'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_attr_id_tab
      , o_appl_data_id  => l_attribute_tab
    );

    for i in 1 .. nvl(l_attribute_tab.last, 0) loop
        begin
            select a.attr_name
                 , a.data_type
                 , a.object_type
                 , a.definition_level
                 , l.cycle_type
                 , l.limit_type
              into l_attr_name
                 , l_data_type
                 , l_object_type
                 , l_definition_level
                 , l_cycle_type
                 , l_limit_type
              from prd_attribute a
                 , fcl_limit_type l
             where a.id = l_attr_id_tab(i)
               and a.object_type = l.limit_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'ATTRIBUTE_NOT_FOUND'
                  , i_env_param1 => l_attr_id_tab(i)
                );
        end;
        app_api_application_pkg.get_element_value(
            i_element_name   => 'LIMIT_COUNT_VALUE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_limit_count_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'LIMIT_SUM_VALUE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_limit_sum_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'LIMIT_CHECK_TYPE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_check_type
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CURRENCY'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_currency
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'COUNTER_ALGORITHM'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_counter_algorithm
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'START_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_start_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'END_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_end_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_CONDITION'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_condition
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_NAME'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_ID'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_id
        );

        process_modifier(
            i_attr_id        => l_attr_id_tab(i)
          , i_inst_id        => i_inst_id
          , i_mod_condition  => l_mod_condition
          , i_mod_name       => l_mod_name
          , io_mod_id        => l_mod_id
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name   => 'CYCLE'
          , i_parent_id      => l_attribute_tab(i)
          , o_appl_data_id   => l_cycle_data_id
        );

        if l_cycle_data_id is not null and l_cycle_type is not null then
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CYCLE_START_DATE'
              , i_parent_id      => l_cycle_data_id
              , o_element_value  => l_cycle_start_date
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'CYCLE_LENGTH_TYPE'
              , i_parent_id      => l_cycle_data_id
              , o_element_value  => l_cycle_length_type
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'CYCLE_LENGTH'
              , i_parent_id      => l_cycle_data_id
              , o_element_value  => l_cycle_length
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'CYCLE_WORKDAYS_ONLY'
              , i_parent_id      => l_cycle_data_id
              , o_element_value  => l_cycle_workdays_only
            );

            fcl_ui_cycle_pkg.add_cycle(
                i_cycle_type     => l_cycle_type
              , i_length_type    => l_cycle_length_type
              , i_cycle_length   => l_cycle_length
              , i_trunc_type     => null
              , i_inst_id        => i_inst_id
              , i_workdays_only  => l_cycle_workdays_only
              , o_cycle_id       => l_cycle_id
            );

            fcl_api_cycle_pkg.add_cycle_counter(
                i_cycle_type      => l_cycle_type
              , i_entity_type     => i_entity_type
              , i_object_id       => i_object_id
              , i_split_hash      => null
              , i_next_date       => coalesce(l_cycle_start_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id))
              , i_inst_id         => i_inst_id
            );
        else
            l_cycle_id := null;
        end if;

        if l_definition_level = prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT and l_cycle_type is not null and l_cycle_id is null then
            begin
                l_limit_id := prd_api_product_pkg.get_limit_id(
                    i_product_id     => i_product_id
                  , i_entity_type    => i_entity_type
                  , i_object_id      => i_object_id
                  , i_limit_type     => l_object_type
                  , i_params         => i_params
                  , i_service_id     => i_service_id
                  , i_eff_date       => com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id)
                  , i_inst_id        => i_inst_id
                  , i_mask_error     => com_api_const_pkg.TRUE
                );

                select min(cycle_id)
                  into l_cycle_id
                  from fcl_limit_vw
                 where id = l_limit_id;
            exception
                when com_api_error_pkg.e_application_error then
                    trc_log_pkg.debug(
                        i_text       => 'Limit with type [#1] was not defined in parent product'
                      , i_env_param1 => l_limit_type
                     );
            end;
        end if;

        fcl_ui_limit_pkg.add_limit(
            i_limit_type         => l_object_type
          , i_cycle_id           => l_cycle_id
          , i_count_limit        => l_limit_count_value
          , i_sum_limit          => l_limit_sum_value
          , i_currency           => l_currency
          , i_posting_method     => acc_api_const_pkg.POSTING_METHOD_IMMEDIATE
          , i_inst_id            => i_inst_id
          , i_is_custom          => com_api_const_pkg.FALSE
          , i_limit_base         => null
          , i_limit_rate         => null
          , i_check_type         => l_check_type
          , i_counter_algorithm  => l_counter_algorithm
          , o_limit_id           => l_created_limit_id
        );

        l_value_id := null;
        prd_ui_attribute_value_pkg.set_attr_value_limit(
            io_attr_value_id    => l_value_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_name         => l_attr_name
          , i_mod_id            => l_mod_id
          , i_start_date        => nvl(i_start_date, l_start_date)
          , i_end_date          => nvl(i_end_date, l_end_date)
          , i_limit_id          => l_created_limit_id
          , i_check_start_date  => com_api_type_pkg.FALSE
          , i_campaign_id       => i_campaign_id
        );
    end loop;
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
           i_appl_data_id  => i_appl_data_id
         , i_element_name  => 'ATTRIBUTE_LIMIT'
        );
end process_limit_attribute;

procedure process_cycle_attribute(
    i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_service_id           in            com_api_type_pkg.t_short_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_campaign_id          in            com_api_type_pkg.t_short_id    default null
  , i_start_date           in            date                           default null
  , i_end_date             in            date                           default null
) is
    l_attribute_tab                      com_api_type_pkg.t_number_tab;
    l_attr_id_tab                        com_api_type_pkg.t_number_tab;
    l_start_date                         date;
    l_end_date                           date;
    l_value_id                           com_api_type_pkg.t_long_id;
    l_attribute_rec                      prd_api_type_pkg.t_attribute;
    l_cycle_start_date                   date;
    l_cycle_length_type                  com_api_type_pkg.t_dict_value;
    l_cycle_length                       com_api_type_pkg.t_tiny_id;
    l_created_cycle_id                   com_api_type_pkg.t_long_id;
    l_mod_condition                      com_api_type_pkg.t_text;
    l_mod_name                           com_api_type_pkg.t_name;
    l_mod_id                             com_api_type_pkg.t_tiny_id;
    l_shift_attr_tab                     com_api_type_pkg.t_number_tab;
    l_shift_attr_id_tab                  com_api_type_pkg.t_number_tab;
    l_shift_type                         com_api_type_pkg.t_dict_value;
    l_shift_priority                     com_api_type_pkg.t_tiny_id;
    l_shift_sign                         com_api_type_pkg.t_sign;
    l_shift_length_type                  com_api_type_pkg.t_dict_value;
    l_shift_length                       com_api_type_pkg.t_tiny_id;
    l_cycle_shift_id                     com_api_type_pkg.t_short_id;
begin
    app_api_application_pkg.get_appl_id_value(
        i_element_name  => 'ATTRIBUTE_CYCLE'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_attr_id_tab
      , o_appl_data_id  => l_attribute_tab
    );

    for i in 1 .. nvl(l_attribute_tab.last, 0) loop

        l_attribute_rec := prd_api_attribute_pkg.get_attribute(
                               i_attr_id    => l_attr_id_tab(i)
                             , i_mask_error => com_api_type_pkg.FALSE
                           );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CYCLE_START_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_cycle_start_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CYCLE_LENGTH_TYPE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_cycle_length_type
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CYCLE_LENGTH'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_cycle_length
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'START_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_start_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'END_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_end_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_CONDITION'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_condition
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_NAME'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_ID'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_id
        );

        process_modifier(
            i_attr_id        => l_attr_id_tab(i)
          , i_inst_id        => i_inst_id
          , i_mod_condition  => l_mod_condition
          , i_mod_name       => l_mod_name
          , io_mod_id        => l_mod_id
        );

        fcl_ui_cycle_pkg.add_cycle(
            i_cycle_type     => l_attribute_rec.object_type
          , i_length_type    => l_cycle_length_type
          , i_cycle_length   => l_cycle_length
          , i_trunc_type     => null
          , i_inst_id        => i_inst_id
          , i_workdays_only  => null
          , o_cycle_id       => l_created_cycle_id
        );

        app_api_application_pkg.get_appl_id_value(
            i_element_name  => 'SHIFT'
          , i_parent_id     => l_attribute_tab(i)
          , o_element_value => l_shift_attr_id_tab
          , o_appl_data_id  => l_shift_attr_tab
        );

        for j in 1 .. nvl(l_shift_attr_tab.last, 0) loop

            app_api_application_pkg.get_element_value(
                i_element_name   => 'SHIFT_TYPE'
              , i_parent_id      => l_shift_attr_tab(j)
              , o_element_value  => l_shift_type
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'SHIFT_PRIORITY'
              , i_parent_id      => l_shift_attr_tab(j)
              , o_element_value  => l_shift_priority
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'SHIFT_SIGN'
              , i_parent_id      => l_shift_attr_tab(j)
              , o_element_value  => l_shift_sign
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'SHIFT_LENGTH_TYPE'
              , i_parent_id      => l_shift_attr_tab(j)
              , o_element_value  => l_shift_length_type
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'SHIFT_LENGTH'
              , i_parent_id      => l_shift_attr_tab(j)
              , o_element_value  => l_shift_length
            );

            fcl_ui_cycle_pkg.add_cycle_shift(
                i_cycle_id          => l_created_cycle_id
              , i_shift_type        => l_shift_type
              , i_priority          => l_shift_priority
              , i_shift_sign        => l_shift_sign
              , i_length_type       => l_shift_length_type
              , i_shift_length      => l_shift_length
              , o_cycle_shift_id    => l_cycle_shift_id
            );
        end loop;

        l_value_id := null;
        prd_ui_attribute_value_pkg.set_attr_value_cycle(
            io_attr_value_id    => l_value_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_name         => l_attribute_rec.attr_name
          , i_mod_id            => l_mod_id
          , i_start_date        => nvl(i_start_date, l_start_date)
          , i_end_date          => nvl(i_end_date, l_end_date)
          , i_cycle_id          => l_created_cycle_id
          , i_check_start_date  => com_api_type_pkg.FALSE
          , i_campaign_id       => i_campaign_id
        );

        trc_log_pkg.debug(
            i_text       => 'process_cycle_attribute - add counter: '
                         || 'i_entity_type [#1], l_object_type [#2], l_cycle_start_date [#3]'
          , i_env_param1 => i_entity_type
          , i_env_param2 => l_attribute_rec.object_type
          , i_env_param3 => to_char(l_cycle_start_date, 'dd.mm.yyyy hh24:mi:ss')
        );
        -- This procedure updates next cycle date. This is needed for example after merchant product is changed.
        fcl_api_cycle_pkg.add_cycle_counter(
            i_cycle_type      => l_attribute_rec.object_type
          , i_entity_type     => i_entity_type
          , i_object_id       => i_object_id
          , i_split_hash      => null
          , i_next_date       => coalesce(l_cycle_start_date, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id))
          , i_inst_id         => i_inst_id
        );
    end loop;
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
           i_appl_data_id  => i_appl_data_id
         , i_element_name  => 'ATTRIBUTE_CYCLE'
        );
end process_cycle_attribute;

procedure process_attribute(
    i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_service_id           in            com_api_type_pkg.t_short_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_params               in            com_api_type_pkg.t_param_tab
  , i_service_status       in            com_api_type_pkg.t_dict_value  default null
  , i_campaign_id          in            com_api_type_pkg.t_short_id    default null
  , i_start_date           in            date                           default null
  , i_end_date             in            date                           default null
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_attribute: ';
    l_attribute_tab                      com_api_type_pkg.t_number_tab;
    l_attr_id_tab                        com_api_type_pkg.t_number_tab;
    l_start_date                         date;
    l_end_date                           date;
    l_value_id                           com_api_type_pkg.t_long_id;
    l_attr_name                          com_api_type_pkg.t_name;
    l_attr_num_value                     number;
    l_attr_char_value                    com_api_type_pkg.t_name;
    l_attr_date_value                    date;
    l_mod_condition                      com_api_type_pkg.t_text;
    l_mod_name                           com_api_type_pkg.t_name;
    l_mod_id                             com_api_type_pkg.t_tiny_id;
    l_status                             com_api_type_pkg.t_dict_value;
    l_srv_start_date                     date;
    l_dummy                              com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START for entity [#1][#2], campaign [#3]'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_object_id
      , i_env_param3 => i_campaign_id
    );

    if i_service_status is not null then
        l_status := i_service_status;
    else
        begin
            select 1
              into l_dummy
              from prd_service s
                 , prd_service_type t
             where s.id              = i_service_id
               and s.service_type_id = t.id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'SERVICE_NOT_FOUND'
                  , i_env_param1  => i_service_id
                  , i_env_param2  => i_object_id
                  , i_env_param3  => i_entity_type
                );
        end;

        select max(o.status)
          into l_status
          from prd_service_object o
         where o.service_id  = i_service_id
           and o.object_id   = i_object_id
           and o.entity_type = i_entity_type;
    end if;

    app_api_application_pkg.get_element_value(
        i_element_name   => 'START_DATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_srv_start_date
    );

    if l_status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED
       and l_srv_start_date is null
    then
        com_api_error_pkg.raise_error (
            i_error       => 'SERVICE_IS_NOT_ACTIVE'
          , i_env_param1  => i_service_id
          , i_env_param2  => i_object_id
          , i_env_param3  => i_entity_type
        );
    end if;

    app_api_application_pkg.get_appl_id_value(
        i_element_name  => 'ATTRIBUTE_NUM'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_attr_id_tab
      , o_appl_data_id  => l_attribute_tab
    );

    for i in 1 .. nvl(l_attribute_tab.last, 0) loop

        l_attr_name := prd_api_attribute_pkg.get_attribute(
                           i_attr_id    => l_attr_id_tab(i)
                         , i_mask_error => com_api_type_pkg.FALSE
                       ).attr_name;

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ATTRIBUTE_VALUE_NUM'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_attr_num_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'START_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_start_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'END_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_end_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_CONDITION'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_condition
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_NAME'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_ID'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_id
        );

        process_modifier(
            i_attr_id        => l_attr_id_tab(i)
          , i_inst_id        => i_inst_id
          , i_mod_condition  => l_mod_condition
          , i_mod_name       => l_mod_name
          , io_mod_id        => l_mod_id
        );

        l_value_id := null;

        prd_ui_attribute_value_pkg.set_attr_value_num (
            io_id               => l_value_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_name         => l_attr_name
          , i_mod_id            => l_mod_id
          , i_start_date        => nvl(i_start_date, l_start_date)
          , i_end_date          => nvl(i_end_date, l_end_date)
          , i_value             => l_attr_num_value
          , i_check_start_date  => com_api_type_pkg.FALSE
          , i_campaign_id       => i_campaign_id
        );
    end loop;

    app_api_application_pkg.get_appl_id_value(
        i_element_name  => 'ATTRIBUTE_CHAR'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_attr_id_tab
      , o_appl_data_id  => l_attribute_tab
    );

    for i in 1 .. nvl(l_attribute_tab.last, 0) loop

        l_attr_name := prd_api_attribute_pkg.get_attribute(
                           i_attr_id    => l_attr_id_tab(i)
                         , i_mask_error => com_api_type_pkg.FALSE
                       ).attr_name;

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ATTRIBUTE_VALUE_CHAR'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_attr_char_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'START_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_start_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'END_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_end_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_CONDITION'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_condition
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_NAME'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_ID'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_id
        );

        process_modifier(
            i_attr_id        => l_attr_id_tab(i)
          , i_inst_id        => i_inst_id
          , i_mod_condition  => l_mod_condition
          , i_mod_name       => l_mod_name
          , io_mod_id        => l_mod_id
        );

        l_value_id := null;

        prd_ui_attribute_value_pkg.set_attr_value_char (
            io_id               => l_value_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_name         => l_attr_name
          , i_mod_id            => l_mod_id
          , i_start_date        => nvl(i_start_date, l_start_date)
          , i_end_date          => nvl(i_end_date, l_end_date)
          , i_value             => l_attr_char_value
          , i_check_start_date  => com_api_type_pkg.FALSE
          , i_campaign_id       => i_campaign_id
        );
    end loop;

    app_api_application_pkg.get_appl_id_value(
        i_element_name  => 'ATTRIBUTE_DATE'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_attr_id_tab
      , o_appl_data_id  => l_attribute_tab
    );

    for i in 1 .. nvl(l_attribute_tab.last, 0) loop

        l_attr_name := prd_api_attribute_pkg.get_attribute(
                           i_attr_id    => l_attr_id_tab(i)
                         , i_mask_error => com_api_type_pkg.FALSE
                       ).attr_name;

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ATTRIBUTE_VALUE_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_attr_date_value
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'START_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_start_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'END_DATE'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_end_date
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_CONDITION'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_condition
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_NAME'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MOD_ID'
          , i_parent_id      => l_attribute_tab(i)
          , o_element_value  => l_mod_id
        );

        process_modifier(
            i_attr_id        => l_attr_id_tab(i)
          , i_inst_id        => i_inst_id
          , i_mod_condition  => l_mod_condition
          , i_mod_name       => l_mod_name
          , io_mod_id        => l_mod_id
        );

        l_value_id := null;

        prd_ui_attribute_value_pkg.set_attr_value_date(
            io_id               => l_value_id
          , i_service_id        => i_service_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_attr_name         => l_attr_name
          , i_mod_id            => l_mod_id
          , i_start_date        => nvl(i_start_date, l_start_date)
          , i_end_date          => nvl(i_end_date, l_end_date)
          , i_value             => l_attr_date_value
          , i_check_start_date  => com_api_type_pkg.FALSE
          , i_campaign_id       => i_campaign_id
        );
    end loop;

    process_fee_attribute(
        i_object_id     => i_object_id
      , i_inst_id       => i_inst_id
      , i_entity_type   => i_entity_type
      , i_service_id    => i_service_id
      , i_product_id    => i_product_id
      , i_appl_data_id  => i_appl_data_id
      , i_params        => i_params
      , i_start_date    => i_start_date
      , i_end_date      => i_end_date
      , i_campaign_id   => i_campaign_id
    );

    process_cycle_attribute(
        i_object_id     => i_object_id
      , i_inst_id       => i_inst_id
      , i_entity_type   => i_entity_type
      , i_service_id    => i_service_id
      , i_product_id    => i_product_id
      , i_appl_data_id  => i_appl_data_id
      , i_campaign_id   => i_campaign_id
      , i_start_date    => i_start_date
      , i_end_date      => i_end_date
    );

    process_limit_attribute(
        i_object_id     => i_object_id
      , i_inst_id       => i_inst_id
      , i_entity_type   => i_entity_type
      , i_service_id    => i_service_id
      , i_product_id    => i_product_id
      , i_appl_data_id  => i_appl_data_id
      , i_params        => i_params
      , i_campaign_id   => i_campaign_id
      , i_start_date    => i_start_date
      , i_end_date      => i_end_date
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
           i_appl_data_id  => i_appl_data_id
         , i_element_name  => 'ATTRIBUTE'
        );
end process_attribute;

procedure process_entity_service(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_element_name         in            com_api_type_pkg.t_name
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , io_params              in out nocopy com_api_type_pkg.t_param_tab
) is
    l_root_id              com_api_type_pkg.t_long_id;
    l_service_value_tab    com_api_type_pkg.t_number_tab;
    l_service_id_tab       com_api_type_pkg.t_number_tab;
    l_object_id_tab        com_api_type_pkg.t_number_tab;
    l_object_value_tab     com_api_type_pkg.t_number_tab;
    l_count                pls_integer := 0;
    l_start_date           date;
    l_end_date             date;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_cust_appl_data_id    com_api_type_pkg.t_long_id;
    l_product_id           com_api_type_pkg.t_short_id;
--    l_service_number       com_api_type_pkg.t_name;
--    l_service_id           com_api_type_pkg.t_short_id;
    l_service_id_proc_tab  com_api_type_pkg.t_number_tab;
    l_start_date_tab       com_api_type_pkg.t_date_tab;
    l_postponed_event      evt_api_type_pkg.t_postponed_event;
    l_status               com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => 'app_api_service_pkg.process_entity_service START for entity [#1][#2]'
                     || ', i_appl_data_id [' || i_appl_data_id || ']'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_object_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_root_id
      , o_element_value  => l_inst_id
    );

    if i_entity_type != ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
    then
        l_cust_appl_data_id := app_api_application_pkg.get_customer_appl_data_id;
    else
        l_cust_appl_data_id := app_api_application_pkg.get_customer_appl_data_id(
                                   i_element_name => 'INSTITUTION'
                                 , i_parent_id    => l_root_id
                               );
    end if;

    trc_log_pkg.debug('customer_data_id='||l_cust_appl_data_id);

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CONTRACT'
      , i_parent_id      => l_cust_appl_data_id
      , o_appl_data_id   => l_appl_data_id
    );
    trc_log_pkg.debug('contract_data_id='||l_appl_data_id);

    app_api_application_pkg.get_appl_id_value(
        i_element_name   => 'SERVICE'
      , i_parent_id      => l_appl_data_id
      , o_element_value  => l_service_value_tab
      , o_appl_data_id   => l_service_id_tab
    );
    trc_log_pkg.debug('found '||nvl(l_service_id_tab.count, 0)||' services ');

    for i in 1 .. nvl(l_service_id_tab.last, 0) loop
        l_appl_data_id := l_service_id_tab(i);
        trc_log_pkg.debug('process service '||l_service_id_tab(i));

        app_api_application_pkg.get_appl_id_value(
            i_element_name   => 'SERVICE_OBJECT'
          , i_parent_id      => l_service_id_tab(i)
          , o_element_value  => l_object_value_tab
          , o_appl_data_id   => l_object_id_tab
        );

        for j in 1 .. nvl(l_object_value_tab.last, 0) loop
            if l_object_value_tab(j) = i_appl_data_id then
                -- we found a service for this object!
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'START_DATE'
                  , i_parent_id      => l_object_id_tab(j)
                  , o_element_value  => l_start_date
                );

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'END_DATE'
                  , i_parent_id      => l_object_id_tab(j)
                  , o_element_value  => l_end_date
                );

                if l_product_id is null then
                    begin
                        select product_id
                          into l_product_id
                          from prd_contract
                         where id = i_contract_id;

                        trc_log_pkg.debug('contract''s product_id [' || l_product_id || ']');
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error (
                                i_error       => 'CONTRACT_NOT_FOUND'
                              , i_env_param1  => i_contract_id
                            );
                    end;
                end if;

                prd_ui_service_pkg.set_service_object(
                    i_service_id           => l_service_value_tab(i)
                  , i_contract_id          => i_contract_id
                  , i_entity_type          => i_entity_type
                  , i_object_id            => i_object_id
                  , i_start_date           => l_start_date
                  , i_end_date             => l_end_date
                  , i_inst_id              => l_inst_id
                  , i_params               => io_params
                  , i_need_postponed_event => com_api_type_pkg.TRUE
                  , o_postponed_event      => l_postponed_event
                );

                -- New values of object attributes could be used in processing of event of service activation
                begin
                    select o.status
                      into l_status
                      from prd_service_object o
                     where o.service_id  = l_service_value_tab(i)
                       and o.entity_type = i_entity_type
                       and o.object_id   = i_object_id;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error (
                            i_error       => 'SERVICE_NOT_FOUND'
                          , i_env_param1  => l_service_value_tab(i)
                          , i_env_param2  => i_object_id
                          , i_env_param3  => i_entity_type
                        );
                end;

                if l_status not in (prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED, prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE) then

                    process_attribute (
                        i_object_id       => i_object_id
                      , i_inst_id         => l_inst_id
                      , i_entity_type     => i_entity_type
                      , i_service_id      => l_service_value_tab(i)
                      , i_product_id      => l_product_id
                      , i_appl_data_id    => l_object_id_tab(j)
                      , i_params          => io_params
                      , i_service_status  => l_status
                    );

                end if;

                evt_api_event_pkg.register_postponed_event(
                    i_postponed_event      => l_postponed_event
                );

                l_service_id_proc_tab(l_service_id_proc_tab.count + 1) := l_service_value_tab(i);
                l_start_date_tab(l_start_date_tab.count + 1) := l_start_date;
            end if;
        end loop;
    end loop;

    -- Check that exists initial service for object
    select count(1)
      into l_count
      from prd_service_object o
     where o.object_id   = i_object_id
       and o.entity_type = i_entity_type
       and exists (
               select 1
                 from prd_service s
                    , prd_service_type t
                where s.id         = o.service_id
                  and t.id         = s.service_type_id
                  and t.is_initial = com_api_type_pkg.TRUE
                  and rownum       = 1
           )
       and rownum = 1;

    if l_count = 0
       and i_entity_type not in (
               prd_api_const_pkg.ENTITY_TYPE_CONTRACT
             , prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
             , pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           )
    then
        -- We raise this error only when a service object does not exists
        com_api_error_pkg.raise_error(
            i_error         => 'INITIAL_SERVICE_NOT_FOUND'
          , i_env_param1    => i_entity_type
        );
    end if;

    for i in 1..nvl(l_service_id_proc_tab.last, 0)
    loop
        prd_api_service_pkg.check_conditional_service(
            i_service_id     => l_service_id_proc_tab(i)
          , i_contract_id    => i_contract_id
          , i_entity_type    => i_entity_type
          , i_object_id      => i_object_id
          , i_date           => coalesce(l_start_date_tab(i), com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id))
        );
    end loop;

    trc_log_pkg.debug('app_api_service_pkg.process_entity_service END');
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => nvl(l_appl_data_id, i_appl_data_id)
          , i_element_name  => i_element_name
        );
end process_entity_service;

procedure close_service(
    i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_forced               in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) is
begin
    prd_api_service_pkg.close_service (
        i_entity_type   => i_entity_type
        , i_object_id   => i_object_id
        , i_inst_id     => i_inst_id
        , i_params      => app_api_application_pkg.g_params
    );
end close_service;

end app_api_service_pkg;
/
