CREATE OR REPLACE package body opr_ui_rule_selection_pkg is

    procedure check_unique(
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
        , i_msg_type            in com_api_type_pkg.t_dict_value
        , i_proc_stage          in com_api_type_pkg.t_dict_value
        , i_sttl_type           in com_api_type_pkg.t_dict_value
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_oper_reason         in com_api_type_pkg.t_dict_value
        , i_is_reversal         in com_api_type_pkg.t_dict_value
        , i_iss_inst_id         in com_api_type_pkg.t_dict_value
        , i_acq_inst_id         in com_api_type_pkg.t_dict_value
        , i_terminal_type       in com_api_type_pkg.t_dict_value
        , i_oper_currency       in com_api_type_pkg.t_curr_code
        , i_account_currency    in com_api_type_pkg.t_curr_code
        , i_sttl_currency       in com_api_type_pkg.t_curr_code
        , i_mod_id              in com_api_type_pkg.t_tiny_id
        , i_rule_set_id         in com_api_type_pkg.t_tiny_id
        , i_exec_order          in com_api_type_pkg.t_tiny_id
    ) is
    begin
        for rec in (
            select 1
              from opr_rule_selection_vw a
             where 1=1
               and nvl(lower(trim(a.msg_type)), '%')   = nvl(lower(trim(i_msg_type)), '%')
               and nvl(lower(trim(a.proc_stage)), '%') = nvl(lower(trim(i_proc_stage)), '%') 
               and nvl(lower(trim(a.sttl_type)), '%')  = nvl(lower(trim(i_sttl_type)), '%') 
               and nvl(lower(trim(a.oper_type)), '%')  = nvl(lower(trim(i_oper_type)), '%')
               and nvl(a.oper_reason, '%') = nvl(i_oper_reason, '%')
               and nvl(a.is_reversal, '0') = nvl(i_is_reversal, '0')
               and nvl(a.iss_inst_id, '%') = nvl(i_iss_inst_id, '%')
               and nvl(a.acq_inst_id, '%') = nvl(i_acq_inst_id, '%')
               and nvl(lower(trim(a.terminal_type)), '%') = nvl(lower(trim(i_terminal_type)), '%')
               and nvl(a.oper_currency, '%')    = nvl(i_oper_currency, '%')
               and nvl(a.account_currency, '%') = nvl(i_account_currency, '%')
               and nvl(a.sttl_currency, '%')    = nvl(i_sttl_currency, '%') 
               and nvl(a.mod_id, -1)            = nvl(i_mod_id, -1)
               and nvl(a.rule_set_id, -1)       = nvl(i_rule_set_id, -1) 
               and (i_id is null or i_id != id)
        ) loop
            com_api_error_pkg.raise_error(
                i_error      => 'OPERATION_RULE_TEMPLATE_NOT_UNIQUE'
              , i_env_param1 => i_msg_type
              , i_env_param2 => i_proc_stage
              , i_env_param3 => i_sttl_type
              , i_env_param4 => i_oper_type
              , i_env_param5 => i_oper_reason
              , i_env_param6 => i_terminal_type
            );
        end loop;
    end;
    
    procedure add (
        o_id                    out com_api_type_pkg.t_short_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_msg_type            in com_api_type_pkg.t_dict_value
        , i_proc_stage          in com_api_type_pkg.t_dict_value
        , i_sttl_type           in com_api_type_pkg.t_dict_value
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_oper_reason         in com_api_type_pkg.t_dict_value
        , i_is_reversal         in com_api_type_pkg.t_dict_value
        , i_iss_inst_id         in com_api_type_pkg.t_dict_value
        , i_acq_inst_id         in com_api_type_pkg.t_dict_value
        , i_terminal_type       in com_api_type_pkg.t_dict_value
        , i_oper_currency       in com_api_type_pkg.t_curr_code
        , i_account_currency    in com_api_type_pkg.t_curr_code
        , i_sttl_currency       in com_api_type_pkg.t_curr_code
        , i_mod_id              in com_api_type_pkg.t_tiny_id
        , i_rule_set_id         in com_api_type_pkg.t_tiny_id
        , i_exec_order          in com_api_type_pkg.t_tiny_id
    ) is
    begin    
        -- check unique
        check_unique(
                i_id                    => o_id
                , i_seqnum              => o_seqnum
                , i_msg_type            => i_msg_type
                , i_proc_stage          => i_proc_stage 
                , i_sttl_type           => i_sttl_type
                , i_oper_type           => i_oper_type
                , i_oper_reason         => i_oper_reason
                , i_is_reversal         => i_is_reversal
                , i_iss_inst_id         => i_iss_inst_id
                , i_acq_inst_id         => i_acq_inst_id
                , i_terminal_type       => i_terminal_type
                , i_oper_currency       => i_oper_currency
                , i_account_currency    => i_account_currency
                , i_sttl_currency       => i_sttl_currency
                , i_mod_id              => i_mod_id
                , i_rule_set_id         => i_rule_set_id
                , i_exec_order          => i_exec_order
            );
        
        o_id := opr_rule_selection_seq.nextval;
        o_seqnum := 1;
        insert into opr_rule_selection_vw (
            id
            , seqnum
            , msg_type
            , proc_stage
            , sttl_type
            , oper_type
            , oper_reason
            , is_reversal
            , iss_inst_id
            , acq_inst_id
            , terminal_type
            , oper_currency
            , account_currency
            , sttl_currency
            , mod_id
            , rule_set_id
            , exec_order
        ) values (
            o_id
            , o_seqnum
            , i_msg_type
            , i_proc_stage
            , i_sttl_type
            , i_oper_type
            , i_oper_reason
            , i_is_reversal
            , i_iss_inst_id
            , i_acq_inst_id
            , i_terminal_type
            , i_oper_currency
            , i_account_currency
            , i_sttl_currency
            , i_mod_id
            , i_rule_set_id
            , i_exec_order
        );
    end;

    procedure modify (
        i_id                    in com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_msg_type            in com_api_type_pkg.t_dict_value
        , i_proc_stage          in com_api_type_pkg.t_dict_value
        , i_sttl_type           in com_api_type_pkg.t_dict_value
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_oper_reason         in com_api_type_pkg.t_dict_value
        , i_is_reversal         in com_api_type_pkg.t_dict_value
        , i_iss_inst_id         in com_api_type_pkg.t_dict_value
        , i_acq_inst_id         in com_api_type_pkg.t_dict_value
        , i_terminal_type       in com_api_type_pkg.t_dict_value
        , i_oper_currency       in com_api_type_pkg.t_curr_code
        , i_account_currency    in com_api_type_pkg.t_curr_code
        , i_sttl_currency       in com_api_type_pkg.t_curr_code
        , i_mod_id              in com_api_type_pkg.t_tiny_id
        , i_rule_set_id         in com_api_type_pkg.t_tiny_id
        , i_exec_order          in com_api_type_pkg.t_tiny_id
    ) is
    begin
        -- check unique
        check_unique(
                i_id                    => i_id
                , i_seqnum              => io_seqnum
                , i_msg_type            => i_msg_type
                , i_proc_stage          => i_proc_stage 
                , i_sttl_type           => i_sttl_type
                , i_oper_type           => i_oper_type
                , i_oper_reason         => i_oper_reason
                , i_is_reversal         => i_is_reversal
                , i_iss_inst_id         => i_iss_inst_id
                , i_acq_inst_id         => i_acq_inst_id
                , i_terminal_type       => i_terminal_type
                , i_oper_currency       => i_oper_currency
                , i_account_currency    => i_account_currency
                , i_sttl_currency       => i_sttl_currency
                , i_mod_id              => i_mod_id
                , i_rule_set_id         => i_rule_set_id
                , i_exec_order          => i_exec_order
            );

        update
            opr_rule_selection_vw
        set
            seqnum = io_seqnum
            , msg_type = i_msg_type
            , proc_stage = i_proc_stage
            , sttl_type = i_sttl_type
            , oper_type = i_oper_type
            , oper_reason = i_oper_reason
            , is_reversal = i_is_reversal
            , iss_inst_id = i_iss_inst_id
            , acq_inst_id = i_acq_inst_id
            , terminal_type = i_terminal_type
            , oper_currency = i_oper_currency
            , account_currency = i_account_currency
            , sttl_currency = i_sttl_currency
            , mod_id = i_mod_id
            , rule_set_id = i_rule_set_id
            , exec_order = i_exec_order
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;
    end;

    procedure remove (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            opr_rule_selection_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            opr_rule_selection_vw
        where
            id = i_id;
    end;

end;
/