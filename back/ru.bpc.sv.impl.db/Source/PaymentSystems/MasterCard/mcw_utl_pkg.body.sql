create or replace package body mcw_utl_pkg is

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
        i_oper_type         in com_api_type_pkg.t_dict_value
        , i_mcc             in com_api_type_pkg.t_mcc
        , o_de003_1         out mcw_api_type_pkg.t_de003s
        , o_p0043           out mcw_api_type_pkg.t_p0043
    ) is
        l_cab_type          mcw_api_type_pkg.t_de003s;
    begin
        select
            mastercard_cab_type
        into
            l_cab_type
        from
            com_mcc
        where
            mcc = i_mcc;

        if i_oper_type in (
            opr_api_const_pkg.OPERATION_TYPE_PAYMENT
            , opr_api_const_pkg.OPERATION_TYPE_REFUND
            , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
        ) then
            case l_cab_type
                when mcw_api_const_pkg.CAB_TYPE_PAYMENT then
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_PAYMENT;
                    o_p0043 := 'C01';
                when mcw_api_const_pkg.CAB_TYPE_MONEYSEND then
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_PAYMENT;
                    o_p0043 := 'C07';
                when mcw_api_const_pkg.CAB_TYPE_ATM then
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_PAYMENT;
                when mcw_api_const_pkg.CAB_TYPE_UNIQUE then
                    if i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_PAYMENT) then
                        o_de003_1 := mcw_api_const_pkg.PROC_CODE_PAYMENT;
                    else
                        o_de003_1 := mcw_api_const_pkg.PROC_CODE_REFUND;
                    end if;
                else
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_REFUND;
            end case;
            if i_mcc = '7995' then
                o_p0043 := 'C04';
            end if;
        elsif i_oper_type in (
            opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
        ) then
            case l_cab_type
                when mcw_api_const_pkg.CAB_TYPE_UNIQUE then
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_UNIQUE;
                else
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_PURCHASE;
                    o_p0043 := 'C07';
            end case;
        elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY then
            o_de003_1 := mcw_api_const_pkg.PROC_CODE_BALANCE_INQUIRY;
        elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PIN_CHANGE then
            o_de003_1 := mcw_api_const_pkg.PROC_CODE_PIN_CHANGE;
        elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PIN_UNBLOCK then
            o_de003_1 := mcw_api_const_pkg.PROC_CODE_PIN_UNBLOCK;
        else
            case l_cab_type
                when mcw_api_const_pkg.CAB_TYPE_ATM then
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_ATM;
                when mcw_api_const_pkg.CAB_TYPE_CASH then
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_CASH;
                when mcw_api_const_pkg.CAB_TYPE_UNIQUE then
                    o_de003_1 := mcw_api_const_pkg.PROC_CODE_UNIQUE;
                else
                    o_de003_1 := 
                        case
                            when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_CASHBACK)
                            then mcw_api_const_pkg.PROC_CODE_CASHBACK
                            else mcw_api_const_pkg.PROC_CODE_PURCHASE
                        end;
            end case;
        end if;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'MCW_UNDEFINED_MCC'
              , i_env_param1    => i_mcc
            );
    end;

    function get_message_impact (
        i_mti               in mcw_api_type_pkg.t_mti
        , i_de024           in mcw_api_type_pkg.t_de024
        , i_de003_1         in mcw_api_type_pkg.t_de003s
        , i_is_reversal     in com_api_type_pkg.t_boolean
        , i_is_incoming     in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_sign
        result_cache
        relies_on(mcw_msg_impact)
    is
        l_impact               com_api_type_pkg.t_sign;
    begin
        select impact
          into l_impact
          from mcw_msg_impact
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

    function build_nrn (
        i_netw_refnum           in varchar2
        , i_netw_date           in date
    ) return mcw_api_type_pkg.t_de063 is
    begin
        if i_netw_refnum is not null then
            return
            (   ' ' ||
                case when nvl(length(i_netw_refnum), 0) = 13 then
                    i_netw_refnum
                else
                    rpad(substr(i_netw_refnum, 1, 9), 9, ' ') ||
                    to_char(nvl(i_netw_date, com_api_sttl_day_pkg.get_sysdate()), 'MMDD') ||
                    '  '
                end
            );
        else
            return null;
        end if;
    end;

    function build_irn return mcw_api_type_pkg.t_de095 is
    begin
        return lpad(mcw_issuer_reference_seq.nextval, 10, '0');
    end;

    procedure add_curr_exp (
        io_p0148                in out mcw_api_type_pkg.t_p0148
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
                , i_param_name  => mcw_api_const_pkg.CMID
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
            mcw_bin_range bin
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

    function get_iss_product (
        i_card_number           in com_api_type_pkg.t_card_number
    ) return com_api_type_pkg.t_curr_code is
        l_result                com_api_type_pkg.t_curr_code;

        cursor l_iss_product is
        select
            bin.product_id
        from
            mcw_bin_range bin
            , net_bin_range_index ind
        where
            ind.pan_prefix = substr(i_card_number, 1, 5)
            and i_card_number between ind.pan_low and ind.pan_high
            and ind.pan_low = bin.pan_low
            and ind.pan_high = bin.pan_high
        order by
            bin.priority;
    begin
       open l_iss_product;
       fetch l_iss_product into l_result;
       close l_iss_product;

       return nvl(l_result, ' ');
    exception
       when others then
           if l_iss_product%isopen then
               close l_iss_product;
           end if;
           raise;
    end;

    function fetch_rate(
        i_p0164_1             in mcw_api_type_pkg.t_p0164_1
      , i_p0164_3             in mcw_api_type_pkg.t_p0164_3
      , i_p0164_4             in mcw_api_type_pkg.t_p0164_4
      , i_de050               in com_api_type_pkg.t_curr_code
    ) return number is
        l_result                number;
    begin
        select rate
          into l_result
          from (select rt.p0164_2 * power(10, c1.exponent - c2.exponent) rate
                  from mcw_currency_rate rt
                     , com_currency c1
                     , com_currency c2
                 where rt.p0164_1  = i_p0164_1
                   and rt.p0164_3  = i_p0164_3
                   and rt.p0164_4 >= i_p0164_4
                   and rt.de050    = i_de050
                   and c1.code     = rt.p0164_1
                   and c2.code     = rt.de050
                 order by rt.p0164_4 desc
                     , rt.p0164_5 desc
               )
         where rownum = 1;

        return l_result;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text        => 'Rate for currency [#1] not found'
              , i_env_param1  => i_p0164_1
            );
            return null;
    end;


    function get_usd_rate (
        i_impact                in com_api_type_pkg.t_sign
        , i_curr_code           in com_api_type_pkg.t_curr_code
    ) return number is
        l_result                number := 1;
        l_rate_type             com_api_type_pkg.t_dict_value;
        l_validity_period       com_api_type_pkg.t_long_id;
    begin
        if i_curr_code != mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR then
            l_rate_type := 
                case i_impact
                    when com_api_type_pkg.DEBIT then 
                        mcw_api_const_pkg.RATE_TYPE_BUY
                    when com_api_type_pkg.CREDIT then
                        mcw_api_const_pkg.RATE_TYPE_SELL
                    else
                        null
                end;
            
            l_validity_period := nvl(set_ui_value_pkg.get_inst_param_n(i_param_name => mcw_api_const_pkg.RATE_VALIDITY_PERIOD)
                                   , mcw_api_const_pkg.DEFAULT_RATE_VALIDITY_PERIOD);
            
            l_result := fetch_rate (
                i_p0164_1    => i_curr_code
                , i_p0164_3  => l_rate_type
                , i_p0164_4  => trunc(get_sysdate) - l_validity_period
                , i_de050    => mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR
            );        
        end if;

        trc_log_pkg.debug (
            i_text          => 'Get rate [#1][#2] -> [#3][#4]'
            , i_env_param1  => i_impact
            , i_env_param2  => i_curr_code
            , i_env_param3  => l_result
            , i_env_param4  => mcw_api_const_pkg.CURRENCY_CODE_US_DOLLAR
        );
        return l_result;
    end;
    
    procedure get_bin_range_data(
        i_card_number       in     com_api_type_pkg.t_card_number
      , i_card_type_id      in     com_api_type_pkg.t_tiny_id
      , o_product_id           out com_api_type_pkg.t_dict_value
      , o_brand                out com_api_type_pkg.t_dict_value
      , o_region               out com_api_type_pkg.t_dict_value
      , o_product_type         out com_api_type_pkg.t_dict_value
    ) is
    begin
        for tab in (
            select 
                   n.product_id   as product_id
                 , n.brand        as brand
                 , n.region       as region
                 , n.product_type as product_type
              from (select bin.brand
                         , bin.product_id
                         , bin.product_type
                         , bin.region
                         , row_number() over (order by bin.priority) rn
                      from mcw_bin_range bin
                      join net_bin_range_index ind on ind.pan_low = bin.pan_low
                                                  and ind.pan_high = bin.pan_high
                                                  and ind.pan_prefix = substr(i_card_number, 1, 5)
                                                  and i_card_number between ind.pan_low and ind.pan_high
                      join net_card_type_map m on substr(m.network_card_type, 1, 3) = bin.brand
                                                  and m.card_type_id = i_card_type_id
                                                        
                   ) n
             where rn = 1
        )
        loop
            o_product_id   := tab.product_id;
            o_brand        := tab.brand;
            o_region       := tab.region;
            o_product_type := tab.product_type;            
        end loop;
        
        trc_log_pkg.debug(
            i_text => 'mcw get_bin_range_data: i_card_number=' || i_card_number || ' product_id=' || o_product_id || 
                      ' brand=' || o_brand || ' region=' || o_region || ' product_type=' || o_product_type
        );
        
    end get_bin_range_data;

end;
/
