create or replace package body cst_amk_evt_rule_proc_pkg is

procedure init_cycle_counter
is
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_next_date                     date;
    l_cycle_type                    com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_service_type_id               com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_count                         com_api_type_pkg.t_long_id;
    l_card_id                       com_api_type_pkg.t_medium_id;
    l_cycle_id                      com_api_type_pkg.t_short_id;
    l_fee_type                      com_api_type_pkg.t_dict_value;
    l_fee_id                        com_api_type_pkg.t_short_id;
    l_attr_name                     com_api_type_pkg.t_name;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_date  := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_cycle_type  := rul_api_param_pkg.get_param_char('CYCLE_TYPE', l_params);
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);

    l_test_mode :=
        evt_api_shared_data_pkg.get_param_char(
            i_name        => 'ATTR_MISS_TESTMODE'
          , i_mask_error  => com_api_const_pkg.TRUE
          , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
        );
    l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_RISE_ERROR);

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type  => l_entity_type
          , i_object_id    => l_object_id
        );

    begin
        select fee_type
          into l_fee_type
          from fcl_fee_type
         where cycle_type = l_cycle_type;

        l_attr_name := prd_api_attribute_pkg.get_attr_name(i_object_type => l_fee_type);

        l_service_id := 
            prd_api_service_pkg.get_active_service_id(
                i_entity_type => l_entity_type
              , i_object_id   => l_object_id
              , i_attr_name   => l_attr_name
              , i_split_hash  => l_split_hash
              , i_eff_date    => l_event_date
              , i_inst_id     => l_inst_id
            );
    exception
        when no_data_found then
            l_service_id := null;
    end;

    if l_service_id in (-50000612, -50000613) then
        fcl_api_cycle_pkg.switch_cycle (
            i_cycle_type         => l_cycle_type
            , i_product_id       => l_product_id
            , i_entity_type      => l_entity_type
            , i_object_id        => l_object_id
            , i_params           => l_params
            , i_start_date       => l_event_date
            , i_eff_date         => l_event_date
            , i_split_hash       => l_split_hash
            , i_inst_id          => l_inst_id
            , i_service_id       => l_service_id
            , o_new_finish_date  => l_next_date
            , i_test_mode        => l_test_mode
            , i_cycle_id         => l_cycle_id
        );
    end if;
exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error not in ('PRD_NO_ACTIVE_SERVICE', 'FEE_NOT_DEFINED') then
            raise;
        end if;
end init_cycle_counter;

end cst_amk_evt_rule_proc_pkg;
/
