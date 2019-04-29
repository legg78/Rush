create or replace package body nbc_cst_fin_message_pkg as

procedure set_participant_type(
    i_auth_rec              in            aut_api_type_pkg.t_auth_rec
  , i_inst_id               in            com_api_type_pkg.t_inst_id
  , io_fin_rec              in out nocopy nbc_api_type_pkg.t_nbc_fin_mes_rec
  , i_bank_code             in            com_api_type_pkg.t_name
  , i_iss_inst_code_by_pan  in            com_api_type_pkg.t_name
) is
    l_receiving_inst_code      com_api_type_pkg.t_name;
begin

--OPTP0689:
--ACQ = 1001, ISS # 1001 => ACQ
--ACQ # 1001, ISS = 1001 => ISS, BNB
--OPTP0610:
--ACQ = 1001, ISS # 1001 => ACQ, BNB
--ACQ # 1001, ISS = 1001 => ISS
--ACQ # 1001, ISS # 1001 => BNB
--OPTP0621:
--ACQ = 1001, ISS = 1001 => ISS, ACQ
--ACQ # 1001, ISS # 1001 => BNB
--OPTP0613:
--ACQ = 1001, ISS # 1001 => ACQ

    l_receiving_inst_code      := trim(aup_api_tag_pkg.get_tag_value(
                                      i_auth_id   => i_auth_rec.id
                                    , i_tag_id    => nbc_api_const_pkg.TAG_RECEIVING_INST_CODE
                                  ));

    trc_log_pkg.debug (
        i_text          => 'set_participant_type: oper_type [#1]'
      , i_env_param1    => i_auth_rec.oper_type
    );

    trc_log_pkg.debug (
        i_text          => 'set_participant_type: acq_inst_id [#1], iss_inst_id [#2], i_inst_id [#3], i_iss_inst_code_by_pan [#4], l_receiving_inst_code [#5], i_bank_code [#6]'
      , i_env_param1    => i_auth_rec.acq_inst_id
      , i_env_param2    => i_auth_rec.iss_inst_id
      , i_env_param3    => i_inst_id
      , i_env_param4    => i_iss_inst_code_by_pan
      , i_env_param5    => l_receiving_inst_code
      , i_env_param6    => i_bank_code
    );

    case i_auth_rec.oper_type

        when 'OPTP0689' then
            if i_auth_rec.acq_inst_id = i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                io_fin_rec.proc_code        := '40';
                io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                io_fin_rec.acq_inst_code    := i_bank_code;
                io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

            elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id = i_inst_id then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ISSUER;
                io_fin_rec.add_party_type   := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                io_fin_rec.proc_code        := '40';
                io_fin_rec.iss_inst_code    := i_bank_code;
                io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                io_fin_rec.bnb_inst_code    := i_bank_code;

            end if;

        when 'OPTP0610' then
            if i_auth_rec.acq_inst_id = i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                io_fin_rec.add_party_type   := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                io_fin_rec.proc_code        := '41';
                io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                io_fin_rec.acq_inst_code    := i_bank_code;
                io_fin_rec.bnb_inst_code    := i_bank_code;

            elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id = i_inst_id and i_auth_rec.acq_inst_bin = l_receiving_inst_code then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ISSUER;
                io_fin_rec.proc_code        := '41';
                io_fin_rec.iss_inst_code    := i_bank_code;
                io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

            elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id = i_inst_id and i_auth_rec.acq_inst_bin != l_receiving_inst_code then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ISSUER;
                io_fin_rec.proc_code        := '48';
                io_fin_rec.mti              := '0230';
                io_fin_rec.iss_inst_code    := i_bank_code;
                io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

            elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                io_fin_rec.proc_code        := '48';
                io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                io_fin_rec.bnb_inst_code    := i_bank_code;

            end if;

        when 'OPTP0621' then
            if i_auth_rec.acq_inst_id = i_inst_id and i_auth_rec.iss_inst_id = i_inst_id then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                io_fin_rec.add_party_type   := nbc_api_const_pkg.PARTICIPANT_ISSUER;
                io_fin_rec.proc_code        := '42';
                io_fin_rec.mti              := '0230';
                io_fin_rec.iss_inst_code    := i_bank_code;
                io_fin_rec.acq_inst_code    := i_bank_code;
                io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

            elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id != i_inst_id and i_bank_code = l_receiving_inst_code then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                io_fin_rec.proc_code        := '42';
                io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

            elsif i_auth_rec.acq_inst_id != i_inst_id and i_auth_rec.iss_inst_id != i_inst_id and i_bank_code != l_receiving_inst_code then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_BENEFICIARY;
                io_fin_rec.proc_code        := '48';
                io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                io_fin_rec.acq_inst_code    := i_auth_rec.acq_inst_bin;
                io_fin_rec.bnb_inst_code    := i_bank_code;

            end if;

        when 'OPTP0613' then
            if i_auth_rec.acq_inst_id = i_inst_id and i_auth_rec.iss_inst_id != i_inst_id then

                io_fin_rec.participant_type := nbc_api_const_pkg.PARTICIPANT_ACQUIRER;
                io_fin_rec.proc_code        := '48';
                io_fin_rec.mti              := '0230';
                io_fin_rec.iss_inst_code    := i_iss_inst_code_by_pan;
                io_fin_rec.acq_inst_code    := i_bank_code;
                io_fin_rec.bnb_inst_code    := l_receiving_inst_code;

            end if;

        else null;
    end case;
end set_participant_type;

end;
/
