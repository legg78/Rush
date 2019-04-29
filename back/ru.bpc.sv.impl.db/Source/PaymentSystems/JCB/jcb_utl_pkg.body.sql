create or replace package body jcb_utl_pkg is

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
    
    procedure get_jcb_transaction_type (
        i_oper_type          in com_api_type_pkg.t_dict_value
        , i_mcc              in com_api_type_pkg.t_mcc
        , o_de003_1          out jcb_api_type_pkg.t_de003s
        , i_standard_version in com_api_type_pkg.t_tiny_id default null
    ) is
    begin   
        if i_oper_type in (
            opr_api_const_pkg.OPERATION_TYPE_PAYMENT
            , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
            , opr_api_const_pkg.OPERATION_TYPE_REFUND
        ) then
            if i_oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND then
        
                o_de003_1 := jcb_api_const_pkg.PROC_CODE_REFUND;
            else          
                o_de003_1 := jcb_api_const_pkg.PROC_CODE_SENDER_CREDIT;
                
            end if;
            
        else
            if i_oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT then
            
                o_de003_1 := jcb_api_const_pkg.PROC_CODE_SENDER_DEBIT;
                
            elsif i_mcc = jcb_api_const_pkg.MCC_ATM then
                
                o_de003_1 := jcb_api_const_pkg.PROC_CODE_ATM;
            
            elsif i_mcc = jcb_api_const_pkg.MCC_CASH then 
            
                o_de003_1 := jcb_api_const_pkg.PROC_CODE_CASH;
            
            elsif   i_mcc in (4829, 6050, 6051, 6529, 6530, 6534, 7511, 7995)
                and i_standard_version < jcb_api_const_pkg.STANDARD_ID_VERISON_18Q2
            then
                o_de003_1 := jcb_api_const_pkg.PROC_CODE_UNIQUE;
            
            else
                o_de003_1 := jcb_api_const_pkg.PROC_CODE_PURCHASE;
            
            end if;
        end if;
            
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_UNDEFINED_MCC'
              , i_env_param1    => i_mcc 
            );
    end;

    function get_message_impact (
        i_mti               in jcb_api_type_pkg.t_mti
        , i_de024           in jcb_api_type_pkg.t_de024
        , i_de003_1         in jcb_api_type_pkg.t_de003s
        , i_is_reversal     in com_api_type_pkg.t_boolean
        , i_is_incoming     in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_sign
        result_cache
        relies_on(jcb_msg_impact)
    is
        l_impact               com_api_type_pkg.t_sign;
    begin
        select impact
          into l_impact
          from jcb_msg_impact
         where mti         =    i_mti
           and de024       =    i_de024
           and i_de003_1   like de003_1 
           and is_reversal =    i_is_reversal 
           and is_incoming =    i_is_incoming;

        return l_impact;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'MC_FIN_MESSAGE_IMPACT_NOT_FOUND'
              , i_env_param1 => i_mti
              , i_env_param2 => i_de024
              , i_env_param3 => i_de003_1
              , i_env_param4 => i_is_reversal
              , i_env_param5 => i_is_incoming
            );
    end;
    
    procedure add_curr_exp (
        io_p3002                in out jcb_api_type_pkg.t_p3002
        , i_curr_code           in com_api_type_pkg.t_curr_code
    ) is
        l_pos                   number;
        l_len                   number;
        l_curr_exp              number(1);
    begin
        if i_curr_code is not null then
            l_len := nvl(length(io_p3002), 0);
            l_pos := 1;
            loop
                exit when l_pos > l_len;
                if substr(io_p3002, l_pos, 3) = i_curr_code then
                    return;
                else
                    l_pos := l_pos + 4;
                end if;
            end loop;

            l_curr_exp := com_api_currency_pkg.get_currency_exponent(i_curr_code);

            io_p3002 := io_p3002 || i_curr_code || to_char(l_curr_exp);
        end if;
        
    end;

    function get_arn(
        i_prefix            in      varchar2        default '7'
      , i_acquirer_bin      in      varchar2
      , i_proc_date         in      date            default null
    ) return varchar2 is
        l_proc_date         date := i_proc_date;
        l_result            varchar2(23);
        l_sequence          number(11);
    begin
        if l_proc_date is null then
            l_proc_date := com_api_sttl_day_pkg.get_sysdate;
        end if;

        select acq_arn_seq.nextval into l_sequence from dual;

        l_result := (
            i_prefix
            || lpad(i_acquirer_bin, 6, 0)
            || to_char(l_proc_date, 'MMDD')
            || to_char(l_sequence, 'FM09999999999')
        );

        return l_result || com_api_checksum_pkg.get_luhn_checksum(l_result);
    end;

end;
/
