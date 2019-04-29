create or replace package body cln_api_rule_proc_pkg is

procedure create_case is
    l_object_id           com_api_type_pkg.t_long_id;
    l_entity_type         com_api_type_pkg.t_dict_value;
    l_customer_id         com_api_type_pkg.t_medium_id;
    l_test_mode           com_api_type_pkg.t_dict_value;

    l_id                  com_api_type_pkg.t_long_id;
    l_seqnum              com_api_type_pkg.t_tiny_id;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_sysdate             date;

begin
    l_object_id   := evt_api_shared_data_pkg.get_param_num ('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    l_test_mode := evt_api_shared_data_pkg.get_param_char(
                       i_name         => 'ATTR_MISS_TESTMODE'
                     , i_mask_error   => com_api_const_pkg.TRUE
                     , i_error_value  => fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE
                   );
    l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE);

    if l_entity_type <> acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        trc_log_pkg.info('cln_api_rule_proc_pkg.create_case: entity type ' || l_entity_type || ' does not maintain');
        return;
    end if;

    l_customer_id := prd_api_customer_pkg.get_customer_id(
                         i_entity_type  => l_entity_type
                       , i_object_id    => l_object_id
                     );

    if l_customer_id is null then
        if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
            com_api_error_pkg.raise_error(i_error  => 'CUSTOMER_NOT_FOUND');
        end if;
        return;
    end if;

    if cln_api_case_pkg.check_case_exists(i_customer_id => l_customer_id) = com_api_const_pkg.TRUE then
        trc_log_pkg.info(
            i_text       => 'COLL_CASE_OPENED_ON_CUSTOMER'
          , i_env_param1 => l_customer_id
        );
        return;
    end if;

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    begin
        cln_api_case_pkg.add_case(
            o_id                 => l_id
          , o_seqnum             => l_seqnum
          , i_inst_id            => l_inst_id
          , i_split_hash         => null
          , i_case_number        => null
          , i_creation_date      => l_sysdate
          , i_customer_id        => l_customer_id
          , i_user_id            => get_user_id  -- !!! TODO get default user of all new cases
          , i_status             => cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW
          , i_resolution         => null
        );
    exception
        when com_api_error_pkg.e_application_error then
            trc_log_pkg.error('cln_api_rule_proc_pkg.create_case: Could not add collection case');
            if l_test_mode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
                raise com_api_error_pkg.e_stop_execute_rule_set;
            elsif l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                raise;
            else
                null;
            end if;
    end;

    begin
        cln_api_action_pkg.add_action(
            o_id                   => l_id
          , o_seqnum               => l_seqnum
          , i_case_id              => l_id
          , i_split_hash           => null
          , i_activity_category    => cln_api_const_pkg.COLL_ACTIVITY_CATEG_SYSTEM
          , i_activity_type        => cln_api_const_pkg.EVENT_TYPE_CASE_CREATED
          , i_user_id              => null
          , i_action_date          => l_sysdate
          , i_eff_date             => l_sysdate
          , i_status               => cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW
          , i_resolution           => null
          , i_commentary           => null
        );
    exception
        when com_api_error_pkg.e_application_error then
            trc_log_pkg.error('cln_api_rule_proc_pkg.create_case: Could not add collection case action');
            if l_test_mode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
                raise com_api_error_pkg.e_stop_execute_rule_set;
            elsif l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                raise;
            else
                null;
            end if;
    end;

end create_case;

procedure resolve_case is
    l_object_id           com_api_type_pkg.t_long_id;
    l_entity_type         com_api_type_pkg.t_dict_value;
    l_event_type          com_api_type_pkg.t_dict_value;
    l_split_hash          com_api_type_pkg.t_tiny_id;
    l_customer_id         com_api_type_pkg.t_medium_id;
    l_test_mode           com_api_type_pkg.t_dict_value;
    l_case                cln_api_type_pkg.t_case_rec;
begin
    l_object_id   := evt_api_shared_data_pkg.get_param_num ('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_split_hash  := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');

    l_test_mode := evt_api_shared_data_pkg.get_param_char(
                       i_name         => 'ATTR_MISS_TESTMODE'
                     , i_mask_error   => com_api_const_pkg.TRUE
                     , i_error_value  => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                   );
    l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE);

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_customer_id := prd_api_customer_pkg.get_customer_id(
                             i_entity_type  => l_entity_type
                           , i_object_id    => l_object_id
                         );
        if l_customer_id is null then
            if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                com_api_error_pkg.raise_error(i_error  => 'ATTRIBUTE_NOT_FOUND');
            end if;
            return;
        end if;
    end if;

    l_case :=
        cln_api_case_pkg.get_case(
            i_customer_id => l_customer_id
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_const_pkg.TRUE
        );

    if l_case.id is not null then
        cln_api_case_pkg.change_case_status(
            i_case_id           => l_object_id
          , i_reason_code       => l_event_type
          , i_activity_category => cln_api_const_pkg.COLL_ACTIVITY_CATEG_SYSTEM
          , i_activity_type     => cln_api_const_pkg.EVENT_TYPE_CASE_STATUS_CHANGED
          , i_split_hash        => l_split_hash
        );
    else
        return;
    end if;

end resolve_case;

procedure register_system_action is
    l_object_id           com_api_type_pkg.t_long_id;
    l_entity_type         com_api_type_pkg.t_dict_value;
    l_event_type          com_api_type_pkg.t_dict_value;
    l_customer_id         com_api_type_pkg.t_medium_id;
    l_test_mode           com_api_type_pkg.t_dict_value;

    l_case                cln_api_type_pkg.t_case_rec;
    l_id                  com_api_type_pkg.t_long_id;
    l_seqnum              com_api_type_pkg.t_tiny_id;
    l_sysdate             date;

begin
    l_object_id   := evt_api_shared_data_pkg.get_param_num ('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');

    l_test_mode := evt_api_shared_data_pkg.get_param_char(
                       i_name         => 'ATTR_MISS_TESTMODE'
                     , i_mask_error   => com_api_const_pkg.TRUE
                     , i_error_value  => fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE
                   );
    l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE);

    if l_entity_type <> acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        trc_log_pkg.info('cln_api_rule_proc_pkg.register_system_action: entity type ' || l_entity_type || ' does not maintain');
        return;
    end if;

    l_customer_id := prd_api_customer_pkg.get_customer_id(
                         i_entity_type  => l_entity_type
                       , i_object_id    => l_object_id
                     );

    if l_customer_id is null then
        if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
            com_api_error_pkg.raise_error(i_error  => 'CUSTOMER_NOT_FOUND');
        end if;
        return;
    end if;

    l_case := cln_api_case_pkg.get_case(i_customer_id  => l_customer_id);
    if l_case.status = cln_api_const_pkg.COLLECTION_CASE_STATUS_CLOSED then
        trc_log_pkg.info(
            i_text       => 'CLN_CASE_IS_NOT_FOUND'
          , i_env_param1 => l_customer_id
        );
        return;
    end if;

    begin
        cln_api_action_pkg.add_action(
            o_id                   => l_id
          , o_seqnum               => l_seqnum
          , i_case_id              => l_case.id
          , i_split_hash           => null
          , i_activity_category    => cln_api_const_pkg.COLL_ACTIVITY_CATEG_SYSTEM
          , i_activity_type        => l_event_type
          , i_user_id              => null
          , i_action_date          => l_sysdate
          , i_eff_date             => l_sysdate
          , i_status               => cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW
          , i_resolution           => null
          , i_commentary           => null
        );
    exception
        when com_api_error_pkg.e_application_error then
            trc_log_pkg.error('cln_api_rule_proc_pkg.register_system_action: Could not add collection case action');
            if l_test_mode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
                raise com_api_error_pkg.e_stop_execute_rule_set;
            elsif l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                raise;
            else
                null;
            end if;
    end;

end register_system_action;

procedure register_collector_action is
    l_object_id           com_api_type_pkg.t_long_id;
    l_entity_type         com_api_type_pkg.t_dict_value;
    l_event_type          com_api_type_pkg.t_dict_value;
    l_customer_id         com_api_type_pkg.t_medium_id;
    l_test_mode           com_api_type_pkg.t_dict_value;
    l_activity_type       com_api_type_pkg.t_dict_value;

    l_case                cln_api_type_pkg.t_case_rec;
    l_id                  com_api_type_pkg.t_long_id;
    l_seqnum              com_api_type_pkg.t_tiny_id;
    l_sysdate             date;

begin
    l_object_id     := evt_api_shared_data_pkg.get_param_num ('OBJECT_ID');
    l_entity_type   := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type    := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_activity_type := evt_api_shared_data_pkg.get_param_char('ACTIVITY_TYPE');

    l_test_mode := evt_api_shared_data_pkg.get_param_char(
                       i_name         => 'ATTR_MISS_TESTMODE'
                     , i_mask_error   => com_api_const_pkg.TRUE
                     , i_error_value  => fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE
                   );
    l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE);

    if l_entity_type not in (acc_api_const_pkg.ENTITY_TYPE_ACCOUNT, iss_api_const_pkg.ENTITY_TYPE_CARD) then
        trc_log_pkg.debug('cln_api_rule_proc_pkg.register_collector_action: entity type ' || l_entity_type || ' does not maintain');
        return;
    end if;

/*???    if l_event_type not in (acc_api_const_pkg.EVENT_ACCOUNT_STATUS_CHANGE, iss_api_const_pkg.EVENT_TYPE_CARD_STATUS_CHANGE) then
        trc_log_pkg.debug('cln_api_rule_proc_pkg.register_collector_action: event type ' || l_event_type || ' does not maintain');
        return;
    end if;*/

    l_customer_id := prd_api_customer_pkg.get_customer_id(
                         i_entity_type  => l_entity_type
                       , i_object_id    => l_object_id
                     );

    if l_customer_id is null then
        if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
            com_api_error_pkg.raise_error(i_error  => 'CUSTOMER_NOT_FOUND');
        end if;
        return;
    end if;

    l_case := cln_api_case_pkg.get_case(i_customer_id  => l_customer_id);
    if l_case.status = cln_api_const_pkg.COLLECTION_CASE_STATUS_CLOSED then
        trc_log_pkg.info(
            i_text       => 'CLN_CASE_IS_NOT_FOUND'
          , i_env_param1 => l_customer_id
        );
        return;
    end if;

    begin
        cln_api_action_pkg.add_action(
            o_id                   => l_id
          , o_seqnum               => l_seqnum
          , i_case_id              => l_case.id
          , i_split_hash           => null
          , i_activity_category    => cln_api_const_pkg.COLL_ACTIVITY_CATEG_SYSTEM
          , i_activity_type        => l_activity_type
          , i_user_id              => get_user_id
          , i_action_date          => l_sysdate
          , i_eff_date             => l_sysdate
          , i_status               => cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW
          , i_resolution           => null
          , i_commentary           => null
        );
    exception
        when com_api_error_pkg.e_application_error then
            trc_log_pkg.error('cln_api_rule_proc_pkg.register_system_action: Could not add collection case action');
            if l_test_mode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
                raise com_api_error_pkg.e_stop_execute_rule_set;
            elsif l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                raise;
            else
                null;
            end if;
    end;

end register_collector_action;

procedure register_customer_action is
    l_object_id           com_api_type_pkg.t_long_id;
    l_entity_type         com_api_type_pkg.t_dict_value;
    l_event_type          com_api_type_pkg.t_dict_value;
    l_customer_id         com_api_type_pkg.t_medium_id;
    l_test_mode           com_api_type_pkg.t_dict_value;
    l_activity_type       com_api_type_pkg.t_dict_value;

    l_case                cln_api_type_pkg.t_case_rec;
    l_id                  com_api_type_pkg.t_long_id;
    l_seqnum              com_api_type_pkg.t_tiny_id;
    l_sysdate             date;

begin
    l_object_id     := evt_api_shared_data_pkg.get_param_num ('OBJECT_ID');
    l_entity_type   := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type    := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_activity_type := evt_api_shared_data_pkg.get_param_char('ACTIVITY_TYPE');

    l_test_mode := nvl(evt_api_shared_data_pkg.get_param_char(
                           i_name         => 'ATTR_MISS_TESTMODE'
                         , i_mask_error   => com_api_const_pkg.TRUE
                         , i_error_value  => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                       )
                     , fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE
                   );

    if l_entity_type <> evt_api_const_pkg.ENTITY_TYPE_EVENT then
        trc_log_pkg.debug('cln_api_rule_proc_pkg.register_customer_action: entity type ' || l_entity_type || ' does not maintain');
        return;
    end if;

/*???    if l_event_type <> crd_api_const_pkg.APPLY_PAYMENT_EVENT then
        trc_log_pkg.debug('cln_api_rule_proc_pkg.register_customer_action: event type ' || l_event_type || ' does not maintain');
        return;
    end if;*/

    l_customer_id := prd_api_customer_pkg.get_customer_id(
                         i_entity_type  => l_entity_type
                       , i_object_id    => l_object_id
                     );

    if l_customer_id is null then
        if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
            com_api_error_pkg.raise_error(i_error  => 'CUSTOMER_NOT_FOUND');
        end if;
        return;
    end if;

    l_case := cln_api_case_pkg.get_case(i_customer_id  => l_customer_id);
    if l_case.status = cln_api_const_pkg.COLLECTION_CASE_STATUS_CLOSED then
        trc_log_pkg.info(
            i_text       => 'CLN_CASE_IS_NOT_FOUND'
          , i_env_param1 => l_customer_id
        );
        return;
    end if;

    begin
        cln_api_action_pkg.add_action(
            o_id                   => l_id
          , o_seqnum               => l_seqnum
          , i_case_id              => l_case.id
          , i_split_hash           => null
          , i_activity_category    => cln_api_const_pkg.COLL_ACTIVITY_CATEG_CUST_RESP
          , i_activity_type        => l_activity_type
          , i_user_id              => get_user_id
          , i_action_date          => l_sysdate
          , i_eff_date             => l_sysdate
          , i_status               => cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW
          , i_resolution           => null
          , i_commentary           => null
        );
    exception
        when com_api_error_pkg.e_application_error then
            trc_log_pkg.error('cln_api_rule_proc_pkg.register_system_action: Could not add collection case action');
            if l_test_mode = fcl_api_const_pkg.ATTR_MISS_STOP_EXECUTE then
                raise com_api_error_pkg.e_stop_execute_rule_set;
            elsif l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                raise;
            else
                null;
            end if;
    end;

end register_customer_action;

end cln_api_rule_proc_pkg;
/
