CREATE OR REPLACE package body bgn_api_rule_proc_pkg is

procedure create_bgn_fin_message is
    l_party_type        com_api_type_pkg.t_dict_value;
    l_fin_id            com_api_type_pkg.t_long_id;
    l_oper_rec          opr_api_type_pkg.t_oper_rec;
begin
    l_oper_rec  := opr_api_shared_data_pkg.get_operation();

    begin
        select id
          into l_fin_id
          from bgn_fin
         where oper_id      = l_oper_rec.id
           and is_incoming  = com_api_const_pkg.FALSE
           and is_invalid   = com_api_const_pkg.FALSE;

        trc_log_pkg.debug(
            i_text          => 'Outgoing borica message for operation [#1] already present with id [#2]'
          , i_env_param1    => l_oper_rec.id
          , i_env_param2    => l_fin_id
        );

    exception
        when no_data_found then
            l_party_type    := opr_api_shared_data_pkg.get_param_char(
                i_name          => 'PARTY_TYPE'
              , i_mask_error    => com_api_const_pkg.TRUE
              , i_error_value   => com_api_const_pkg.PARTICIPANT_ISSUER
            );
            bgn_api_fin_pkg.create_from_oper (
                i_oper_rec      => l_oper_rec
              , i_iss_rec       => opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER)
              , i_asq_rec       => opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ACQUIRER)
              , i_id            => null
              , i_inst_id       => opr_api_shared_data_pkg.get_participant(i_participant_type => l_party_type).inst_id
            );
    end;
end;

end;
/
