create or replace package body opr_api_clearing_pkg is

procedure mark_uploaded(
    i_id_tab           in     com_api_type_pkg.t_number_tab
) is
begin
    forall i in 1 .. i_id_tab.count
        update opr_operation
           set status = decode(status, opr_api_const_pkg.OPERATION_STATUS_WAIT_CLEARING, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY, status)
         where id     = i_id_tab(i);

end mark_uploaded;
    
procedure mark_settled(
    i_id_tab           in     com_api_type_pkg.t_number_tab
  , i_sttl_amount      in     com_api_type_pkg.t_number_tab
  , i_sttl_currency    in     com_api_type_pkg.t_curr_code_tab
) is
begin
    forall i in 1 .. i_id_tab.count
        update opr_operation
           set status        = decode(status, opr_api_const_pkg.OPERATION_STATUS_WAIT_SETTL, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY, status)
             , sttl_amount   = i_sttl_amount(i) 
             , sttl_currency = i_sttl_currency(i) 
         where id = i_id_tab(i); 

end mark_settled;

procedure match_reversal(
    i_oper_id           in     com_api_type_pkg.t_long_id
  , i_is_reversal       in     com_api_type_pkg.t_boolean
  , i_network_refnum    in     com_api_type_pkg.t_rrn
  , i_oper_amount       in     com_api_type_pkg.t_money
  , i_oper_currency     in     com_api_type_pkg.t_curr_code
  , i_card_number       in     com_api_type_pkg.t_card_number
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , io_match_status     in out com_api_type_pkg.t_dict_value
  , io_match_id         in out com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug(
        i_text       => 'match_reversal: i_oper_id [#1], i_is_reversal [#2], i_network_refnum [#3], i_oper_amount [#4], i_oper_currency [#5], i_card_number [#6]'
                        || ', i_inst_id [' || i_inst_id || '], io_match_status [' || io_match_status || '], io_match_id [' || io_match_id || ']'
      , i_env_param1 => i_oper_id
      , i_env_param2 => i_is_reversal
      , i_env_param3 => i_network_refnum
      , i_env_param4 => i_oper_amount
      , i_env_param5 => i_oper_currency
      , i_env_param6 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
    );

    if i_is_reversal = com_api_const_pkg.TRUE
       and io_match_status = opr_api_const_pkg.OPERATION_MATCH_MATCHED
    then          
        io_match_status := opr_api_const_pkg.OPERATION_MATCH_AUTO_MATCHED;

        for r in (
            select op.id as oper_id
              from opr_operation op
                 , opr_participant p
                 , opr_card c
             where op.network_refnum  = i_network_refnum
               and op.oper_amount     = i_oper_amount
               and op.oper_currency   = i_oper_currency
               and op.match_status   in (opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
                                       , opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE)
               and op.msg_type       in (opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                       , opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
                                       , opr_api_const_pkg.MESSAGE_TYPE_COMPLETION)
               and p.oper_id          = op.id
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and p.inst_id          = i_inst_id
               and p.client_id_type  in (opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                       , opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT)
               and c.oper_id          = p.oper_id
               and c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and c.card_number      = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
               and rownum             = 1
        )
        loop
            io_match_id := r.oper_id;

            update opr_operation op
               set match_status = opr_api_const_pkg.OPERATION_MATCH_AUTO_MATCHED
                 , match_id     = i_oper_id
             where op.id = r.oper_id;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text       => 'match_reversal: io_match_status [#1], io_match_id [#2]'
      , i_env_param1 => io_match_status
      , i_env_param2 => io_match_id
    );

end match_reversal;

end opr_api_clearing_pkg;
/
