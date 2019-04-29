create or replace package body cst_tym_opr_rule_pkg is

procedure check_card_activated is
    l_entity_type                   com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_oper_reason                   com_api_type_pkg.t_dict_value;
    l_seq_number                    com_api_type_pkg.t_tiny_id;
    l_number_of_activations         number(8);
    l_expir_date                    date;
begin
    l_entity_type  := iss_api_const_pkg.ENTITY_TYPE_CARD;
    l_account_name := opr_api_shared_data_pkg.get_param_char(
                          i_name       => 'ACCOUNT_NAME'
                        , i_mask_error => com_api_type_pkg.TRUE
                      );
    l_party_type   := com_api_const_pkg.PARTICIPANT_ISSUER;

    l_oper_reason  := coalesce(
                          opr_api_shared_data_pkg.get_operation().oper_reason
                        , opr_api_shared_data_pkg.get_param_char('OPER_REASON')
                      );
    l_object_id    := opr_api_shared_data_pkg.get_object_id(
                          io_entity_type   => l_entity_type
                        , i_account_name   => l_account_name
                        , i_party_type     => l_party_type
                        , o_inst_id        => l_inst_id
                      );

    l_seq_number := opr_api_shared_data_pkg.get_participant(l_party_type).card_seq_number;
    l_expir_date := opr_api_shared_data_pkg.get_participant(l_party_type).card_expir_date;

    l_object_id := iss_api_card_instance_pkg.get_card_instance_id(
                       i_card_id     => l_object_id
                     , i_seq_number  => l_seq_number
                     , i_expir_date  => l_expir_date
                     , i_state       => iss_api_const_pkg.CARD_STATE_ACTIVE
                     , i_raise_error => com_api_type_pkg.TRUE
                   );

    select count(status)
      into l_number_of_activations
      from evt_status_log
     where object_id    = l_object_id
       and status       = 'CSTS0000';

    trc_log_pkg.debug(
        i_text          => 'Number of activations: [#1] '
      , i_env_param1    => l_number_of_activations
    );

    if l_number_of_activations = 0 then
        opr_api_shared_data_pkg.set_param(
            i_name      => 'IS_ACTIVATED'
          , i_value     => com_api_type_pkg.FALSE
        );
    else
        opr_api_shared_data_pkg.set_param(
            i_name      => 'IS_ACTIVATED'
          , i_value     => com_api_type_pkg.TRUE
        );
    end if;

    trc_log_pkg.debug(
        i_text          => 'IS ACTIVATED TP: [#1] '
      , i_env_param1    => opr_api_shared_data_pkg.get_param_num('IS_ACTIVATED')
    );
end check_card_activated;

end cst_tym_opr_rule_pkg;
/
