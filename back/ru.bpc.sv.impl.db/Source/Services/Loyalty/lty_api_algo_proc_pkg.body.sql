create or replace package body lty_api_algo_proc_pkg is

g_params                com_api_type_pkg.t_param_tab;

procedure clear_shared_data is
begin
    rul_api_param_pkg.clear_params(
        io_params         => g_params
    );
end;

function get_param_num(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return number is
begin
    return rul_api_param_pkg.get_param_num(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_param_date(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return date is
begin
    return rul_api_param_pkg.get_param_date(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_param_char(
    i_name                in            com_api_type_pkg.t_name
  , i_mask_error          in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value         in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_name is
begin
    return rul_api_param_pkg.get_param_char(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            com_api_type_pkg.t_name
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            number
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure set_param(
    i_name                in            com_api_type_pkg.t_name
  , i_value               in            date
) is
begin
    rul_api_param_pkg.set_param(
        i_name     => i_name
      , io_params  => g_params
      , i_value    => i_value
    );
end;

procedure check_promo_level_turnover
is
    l_contract_rec                   prd_api_type_pkg.t_contract;
    l_object_id                      com_api_type_pkg.t_medium_id;
    l_entity_type                    com_api_type_pkg.t_dict_value;
    l_event_type                     com_api_type_pkg.t_dict_value;
    l_service_id                     com_api_type_pkg.t_short_id;
    l_level_threshold_limit_id       com_api_type_pkg.t_long_id;
    l_level_threshold_limit_count    com_api_type_pkg.t_long_id;
    l_level_threshold_limit_rec      fcl_api_type_pkg.t_limit;
    l_promotion_level_product        com_api_type_pkg.t_short_id;
    l_loyanty_prom_lev_thres_cync    com_api_type_pkg.t_dict_value;
    l_attribute_name                 com_api_type_pkg.t_name;
    l_limit_type                     com_api_type_pkg.t_dict_value;
begin
    l_contract_rec.end_date       := get_param_date(i_name => 'EFFECTIVE_DATE');
    l_contract_rec.inst_id        := get_param_num(i_name  => 'INST_ID');
    l_contract_rec.split_hash     := get_param_num(i_name  => 'SPLIT_HASH');
    l_contract_rec.product_id     := get_param_num(i_name  => 'PRODUCT_ID');
    l_contract_rec.id             := get_param_char(i_name => 'CONTRACT_ID');
    l_contract_rec.contract_type  := get_param_char(i_name => 'CONTRACT_TYPE');
    l_service_id                  := get_param_num(i_name  => 'SERVICE_ID');
    l_object_id                   := get_param_num(i_name  => 'OBJECT_ID');
    l_entity_type                 := get_param_char(i_name => 'ENTITY_TYPE');
    l_event_type                  := get_param_char(i_name => 'EVENT_TYPE');

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_loyanty_prom_lev_thres_cync := lty_api_const_pkg.LOYALTY_PROM_LEV_THRES_CYC_ACC;
        l_attribute_name              := lty_api_const_pkg.LOYALTY_ATTR_PROM_LEV_THRE_ACC;
        l_limit_type                  := lty_api_const_pkg.LOYALTY_PROM_LEV_THRES_LIM_ACC;

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        l_loyanty_prom_lev_thres_cync := lty_api_const_pkg.LOYALTY_PROM_LEV_THRES_CYC_CAR;
        l_attribute_name              := lty_api_const_pkg.LOYALTY_ATTR_PROM_LEV_THRE_CAR;
        l_limit_type                  := lty_api_const_pkg.LOYALTY_PROM_LEV_THRES_LIM_CAR;

    else
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => l_entity_type
        );
    end if;

    l_level_threshold_limit_id :=
        prd_api_product_pkg.get_limit_id(
            i_product_id  => l_contract_rec.product_id
          , i_entity_type => l_entity_type
          , i_object_id   => l_object_id
          , i_limit_type  => l_limit_type
          , i_params      => g_params
        );
    trc_log_pkg.debug(
        i_text            => 'Promotion level threshold limit id[#1]'
      , i_env_param1      => l_level_threshold_limit_id
    );

    l_level_threshold_limit_count :=
        fcl_api_limit_pkg.get_limit_sum_curr(
            i_limit_type  => l_limit_type
          , i_entity_type => l_entity_type
          , i_object_id   => l_object_id
          , i_limit_id    => l_level_threshold_limit_id
        );
    trc_log_pkg.debug(
        i_text            => 'Promotion level threshold limit counter id[#1]'
      , i_env_param1      => l_level_threshold_limit_count
    );

    set_param(
        i_name  => 'TURNOVER_AMOUNT'
      , i_value => l_level_threshold_limit_count
    );

    l_level_threshold_limit_rec :=
        fcl_api_limit_pkg.get_limit(
            i_limit_id => l_level_threshold_limit_id
        );
    trc_log_pkg.debug(
        i_text       => 'Promotion level threshold limit amount[#1]'
      , i_env_param1 => l_level_threshold_limit_rec.sum_limit
    );

    set_param(
        i_name       => 'THRESHOLD_AMOUNT'
      , i_value      => l_level_threshold_limit_rec.sum_limit
    );

    l_promotion_level_product :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id  => l_contract_rec.product_id
          , i_entity_type => l_entity_type
          , i_object_id   => l_object_id
          , i_attr_name   => l_attribute_name
          , i_params      => g_params
        );

    set_param(
        i_name  => 'PRODUCT_ID'
      , i_value => l_promotion_level_product
    );

    fcl_api_limit_pkg.zero_limit_counter(
        i_limit_type      => l_limit_type
      , i_entity_type     => l_entity_type
      , i_object_id       => l_object_id
    );

    trc_log_pkg.debug(i_text => 'check_promo_level_turnover finished');
end check_promo_level_turnover;

end;
/
