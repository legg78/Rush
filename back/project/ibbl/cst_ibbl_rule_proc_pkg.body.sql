create or replace package body cst_ibbl_rule_proc_pkg as

procedure prepaid_card_statement_wrapped
as
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_entity_type       com_api_type_pkg.t_dict_value  := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_param_map         com_param_map_tpt;
    l_prev_date         DATE;
    l_next_date         DATE;
    l_party_type        com_api_type_pkg.t_name := com_api_const_pkg.PARTICIPANT_ISSUER;
    l_account_name      com_api_type_pkg.t_name;
    l_account           acc_api_type_pkg.t_account_rec;
begin
    l_cycle_type :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'CYCLE_TYPE'
        );

    l_account_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name         => 'ACCOUNT_NAME'
        );

    opr_api_shared_data_pkg.get_account(
        i_name              => l_account_name
      , o_account_rec       => l_account
    );

    l_inst_id :=
        opr_api_shared_data_pkg.get_participant(
            i_participant_type    => l_party_type
        ).inst_id;

    l_split_hash :=
        opr_api_shared_data_pkg.get_participant(
            i_participant_type   => l_party_type
        ).split_hash;

    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type        => l_cycle_type
      , i_entity_type       => l_entity_type
      , i_object_id         => l_account.account_id
      , i_split_hash        => l_split_hash
      , i_add_counter       => com_api_const_pkg.FALSE
      , o_prev_date         => l_prev_date
      , o_next_date         => l_next_date
    );

    trc_log_pkg.debug(
        i_text       => 'cst_ibbl_rule_proc_pkg.prepaid_card_statement_wrapped -> process_cycle, start: l_entity_type [#1], ' ||
                        'l_cycle_type [#2], l_account.account_id [#3], l_inst_id [#4], l_split_hash [#5], l_prev_date [#6], l_next_date ['||l_next_date||']'
      , i_env_param1 => l_entity_type
      , i_env_param2 => l_cycle_type
      , i_env_param3 => l_account.account_id
      , i_env_param4 => l_inst_id
      , i_env_param5 => l_split_hash
      , i_env_param6 => l_prev_date
    );

    if l_prev_date is not null then
        evt_api_event_pkg.register_event(
            i_event_type        => l_cycle_type
          , i_eff_date          => l_prev_date
          , i_entity_type       => l_entity_type
          , i_object_id         => l_account.account_id
          , i_inst_id           => l_inst_id
          , i_split_hash        => l_split_hash
          , i_param_map         => l_param_map
          , i_status            => null
        );
    else
        com_api_error_pkg.raise_error (
            i_error         => 'CYCLE_NOT_FOUND'
        );
    end if;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end;

end cst_ibbl_rule_proc_pkg;
/
