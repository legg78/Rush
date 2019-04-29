create or replace package body mup_utl_pkg is
 
    function bitor(x in binary_integer, y in binary_integer) return binary_integer as
    begin
        return x + y - bitand(x,y);
    end;

    function pad_number (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2 is
    begin
        return
            case
                when length(i_data) < i_min_length then lpad(i_data, i_min_length, '0')
                when length(i_data) > i_max_length then substr(i_data, - i_max_length)
                else i_data
            end;
    end;
    
    function pad_char (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2 is
    begin
        return
            case
                when length(i_data) < i_min_length then rpad(i_data, i_min_length, ' ')
                when length(i_data) > i_max_length then substr(i_data, 1, i_max_length)
                else i_data
            end;
    end;
    
    procedure get_ipm_transaction_type (
        i_oper_type       in     com_api_type_pkg.t_dict_value
      , i_mcc             in     com_api_type_pkg.t_mcc
      , i_de022_5         in     mup_api_type_pkg.t_de022s
      , i_current_version in     com_api_type_pkg.t_tiny_id
      , o_de003_1            out mup_api_type_pkg.t_de003s
    ) is
    begin
        if i_oper_type in (
            opr_api_const_pkg.OPERATION_TYPE_PAYMENT
          , opr_api_const_pkg.OPERATION_TYPE_REFUND
          , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
          , opr_api_const_pkg.OPERATION_TYPE_CASHIN
        )
        then
            if i_mcc in ('6532', '6533', '6536', '6537') then
                o_de003_1 := mup_api_const_pkg.PROC_CODE_PAYMENT;
            elsif i_mcc in ('6012') then
                if i_de022_5 = '1' 
                then 
                    o_de003_1 := mup_api_const_pkg.PROC_CODE_CASH_IN;
                else
                    o_de003_1 := case when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND
                                      then mup_api_const_pkg.PROC_CODE_REFUND
                                      else mup_api_const_pkg.PROC_CODE_P2P_CREDIT
                                 end;
                end if;
            elsif i_mcc in ('6011') then
                o_de003_1 := mup_api_const_pkg.PROC_CODE_ATM;
            elsif i_mcc in ('6010') then
                o_de003_1 := mup_api_const_pkg.PROC_CODE_CASH;
            else 
                o_de003_1 := mup_api_const_pkg.PROC_CODE_REFUND; 
            end if;
            
        else
            if i_mcc = '6011' then
                o_de003_1 := mup_api_const_pkg.PROC_CODE_ATM;
            elsif i_mcc in ('6010') then
                o_de003_1 := mup_api_const_pkg.PROC_CODE_CASH;
            else
                o_de003_1 := mup_api_const_pkg.PROC_CODE_PURCHASE;
            end if;    
        end if;
    end;

    function get_message_impact (
        i_mti               in mup_api_type_pkg.t_mti
        , i_de024           in mup_api_type_pkg.t_de024
        , i_de003_1         in mup_api_type_pkg.t_de003s
        , i_is_reversal     in com_api_type_pkg.t_boolean
        , i_is_incoming     in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_sign
        result_cache
        relies_on(mup_msg_impact)
    is
        l_impact               com_api_type_pkg.t_sign;
    begin
        select impact
          into l_impact
          from mup_msg_impact
         where mti         =    i_mti
           and de024       =    i_de024
           and i_de003_1   like de003_1 
           and is_reversal =    i_is_reversal 
           and is_incoming =    i_is_incoming;

        return l_impact;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'MUP_FIN_MESSAGE_IMPACT_NOT_FOUND'
              , i_env_param1 => i_mti
              , i_env_param2 => i_de024
              , i_env_param3 => i_de003_1
              , i_env_param4 => i_is_reversal
              , i_env_param5 => i_is_incoming
            );
    end;
    
    function build_nrn (
        i_netw_refnum           in varchar2
    ) return mup_api_type_pkg.t_de063 is
    begin
        if i_netw_refnum is not null then

            return substr(i_netw_refnum, 5, 16);
        else
            return null;
        end if;
    end;
    
    function build_irn return mup_api_type_pkg.t_de095 is
    begin
        return lpad(mup_issuer_reference_seq.nextval, 10, '0');
    end;

    procedure add_curr_exp (
        io_p0148                in out mup_api_type_pkg.t_p0148
        , i_curr_code           in com_api_type_pkg.t_curr_code
    ) is
        l_pos                   number;
        l_len                   number;
        l_curr_exp              number(1);
    begin
        if i_curr_code is not null then
            l_len := nvl(length(io_p0148), 0);
            l_pos := 1;
            loop
                exit when l_pos > l_len;
                if substr(io_p0148, l_pos, 3) = i_curr_code then
                    return;
                else
                    l_pos := l_pos + 4;
                end if;
            end loop;

            l_curr_exp := com_api_currency_pkg.get_currency_exponent(i_curr_code);

            io_p0148 := io_p0148 || i_curr_code || to_char(l_curr_exp);
        end if;
    end;

    function get_acq_cmid (
        i_iss_inst_id           in com_api_type_pkg.t_inst_id
      , i_iss_network_id        in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) return com_api_type_pkg.t_cmid is
        l_result                com_api_type_pkg.t_cmid;
        l_host_id               com_api_type_pkg.t_tiny_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;
        l_param_tab             com_api_type_pkg.t_param_tab;
    begin
 
        l_host_id := 
            net_api_network_pkg.get_member_id(
                i_inst_id       => i_iss_inst_id
              , i_network_id    => i_iss_network_id
            );
        
        l_standard_id := 
            net_api_network_pkg.get_offline_standard(
                i_host_id       => l_host_id
            );

        l_result := 
            cmn_api_standard_pkg.get_varchar_value (
                i_inst_id       => i_inst_id
                , i_standard_id => l_standard_id
                , i_object_id   => l_host_id
                , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_param_name  => mup_api_const_pkg.CMID
                , i_param_tab   => l_param_tab
            );

       return nvl(l_result, ' ');
    end;

    function get_iss_cmid (
        i_card_number           in com_api_type_pkg.t_card_number
    ) return com_api_type_pkg.t_cmid is
        l_result                com_api_type_pkg.t_cmid;
       
        cursor l_iss_cmid is
        select
            bin.member_id
        from
            mup_bin_range bin
            , net_bin_range_index ind
        where
            ind.pan_prefix = substr(i_card_number, 1, 5)
            and i_card_number between ind.pan_low and ind.pan_high
            and ind.pan_low = bin.pan_low
            and ind.pan_high = bin.pan_high
        order by
            bin.priority;
    begin
        open l_iss_cmid;
        fetch l_iss_cmid into l_result;
        close l_iss_cmid;
 
       return nvl(l_result, ' ');
    exception
        when others then
            if l_iss_cmid%isopen then
                close l_iss_cmid;
            end if;
            raise;
    end;

    function get_p2158_1(
        i_iss_network_id        in com_api_type_pkg.t_tiny_id
    ) return mup_api_type_pkg.t_p2158_1
    is
    begin
        return case i_iss_network_id
                when mup_api_const_pkg.MUP_NETWORK_ID then '0001'
                when mup_api_const_pkg.CUP_NETWORK_ID then '0002'
                when mup_api_const_pkg.JCB_NETWORK_ID then '0003'
                when amx_api_const_pkg.TARGET_NETWORK then '0004'
                else '0001'
               end;
    end;
    
    procedure redefine_iss_networkd_id(
        io_network_id         in out com_api_type_pkg.t_tiny_id
      , i_emv_data            in     com_api_type_pkg.t_text
    ) as
        l_is_binary              com_api_type_pkg.t_boolean;
        l_emv_tag_tab            com_api_type_pkg.t_tag_value_tab;
        l_aid                    com_api_type_pkg.t_param_value;
        l_appl_scheme_type       com_api_type_pkg.t_dict_value;
        l_network_id             com_api_type_pkg.t_tiny_id;
        l_pan_seq_number         com_api_type_pkg.t_card_number;
    begin
        if io_network_id is null
           or io_network_id != mcw_api_const_pkg.MCW_NETWORK_ID
        then
            return;
        end if;

        trc_log_pkg.debug(
            i_text => 'redefine_iss_networkd_id'
        );
        
        if i_emv_data is null then
            trc_log_pkg.debug(
                i_text => 'no emv_data - return'
            );
            return;
        end if;
        
        l_is_binary := 
            nvl(
                set_ui_value_pkg.get_system_param_n(i_param_name => 'EMV_TAGS_IS_BINARY')
              , com_api_type_pkg.FALSE
            );
        
        emv_api_tag_pkg.parse_emv_data(
            i_emv_data    => i_emv_data
          , o_emv_tag_tab => l_emv_tag_tab
          , i_is_binary   => l_is_binary
        );
        
        l_aid := 
            emv_api_tag_pkg.get_tag_value(
                i_tag             => emv_api_const_pkg.EMV_TAG_AID
              , i_emv_tag_tab     => l_emv_tag_tab
              , i_mask_error      => com_api_const_pkg.TRUE
            );
        
        if l_is_binary = com_api_const_pkg.TRUE then
            l_aid := prs_api_util_pkg.hex2bin(i_hex_string => l_aid);
        end if;
        
        trc_log_pkg.debug(
            i_text => 'l_aid = ' || l_aid 
        );
        
        if l_aid is not null then
            l_appl_scheme_type := 
                emv_api_application_pkg.get_appl_scheme_type(
                    i_tag   => emv_api_const_pkg.EMV_TAG_AID
                  , i_value => l_aid
                );
            
            if l_appl_scheme_type = emv_api_const_pkg.EMV_SCHEME_MUP then
                l_network_id := mup_api_const_pkg.MUP_NETWORK_ID;
                
                trc_log_pkg.debug(
                    i_text => 'l_appl_scheme_type = ' || l_appl_scheme_type ||'; iss_network_id redefined to MUP ' || l_network_id
                );
            end if;
        end if;
        
        if l_network_id is null then
            l_pan_seq_number :=
                emv_api_tag_pkg.get_tag_value(
                    i_tag             => emv_api_const_pkg.EMV_TAG_PAN_SEQ_NUMBER
                  , i_emv_tag_tab     => l_emv_tag_tab
                  , i_mask_error      => com_api_const_pkg.TRUE
                );
            
            if l_is_binary = com_api_const_pkg.TRUE then
                l_pan_seq_number := prs_api_util_pkg.hex2bin(i_hex_string => l_pan_seq_number);
            end if;
            
            if l_pan_seq_number like '9%' then
                l_network_id := mup_api_const_pkg.MUP_NETWORK_ID;
                trc_log_pkg.debug(
                    i_text => 'l_pan_seq_number = ' || l_pan_seq_number ||'; iss_network_id redefined to MUP ' || l_network_id
                );
            end if;
        end if;
        
        io_network_id := nvl(l_network_id, io_network_id);

    end redefine_iss_networkd_id;

end mup_utl_pkg;
/
