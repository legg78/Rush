create or replace package body pmo_api_search_pkg as
/************************************************************
 * API for search of payment orders and authorizations <br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 15.02.2012  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_api_search_pkg <br />
 * @headcom
 ************************************************************/

function get_payment_params(
    i_payment_order_id      in      com_api_type_pkg.t_long_id
  , o_merchant_number          out  com_api_type_pkg.t_merchant_number
  , o_terminal_number          out  com_api_type_pkg.t_merchant_number
  , o_acq_inst_id              out  com_api_type_pkg.t_inst_id
  , o_mcc                      out  com_api_type_pkg.t_mcc
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_card_number              out  com_api_type_pkg.t_card_number
  , o_account_number           out  com_api_type_pkg.t_account_number
  , o_client_id_type           out  com_api_type_pkg.t_dict_value
  , o_client_id_value          out  com_api_type_pkg.t_name
  , o_purpose_id               out  com_api_type_pkg.t_short_id
  , o_payment_param_id_tab     out  com_api_type_pkg.t_number_tab
  , o_payment_param_val_tab    out  com_api_type_pkg.t_varchar2_tab
  , o_oper_type                out  com_api_type_pkg.t_dict_value
  , o_dst_customer_id          out  com_api_type_pkg.t_medium_id
  , o_dst_card_number          out  com_api_type_pkg.t_card_number
  , o_dst_account_number       out  com_api_type_pkg.t_account_number
  , o_dst_client_id_type       out  com_api_type_pkg.t_dict_value
  , o_dst_client_id_value      out  com_api_type_pkg.t_name
  , o_oper_amount              out  com_api_type_pkg.t_money
  , o_oper_request_amount      out  com_api_type_pkg.t_money
  , o_oper_currency            out  com_api_type_pkg.t_curr_code
  , o_oper_surcharge_amount    out  com_api_type_pkg.t_money
  , o_oper_amount_algorithm    out  com_api_type_pkg.t_dict_value
  , o_oper_id                  out  com_api_type_pkg.t_long_id
  , o_oper_date                out  date
  , o_cardseqnumber            out  com_api_type_pkg.t_tiny_id
  , o_cardexpirdate            out  date
  , o_dstaccounttype           out  com_api_type_pkg.t_dict_value
  , o_oper_reason              out  com_api_type_pkg.t_dict_value
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , i_need_payment_params   in      com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_dict_value is

    l_need_payment_params       com_api_type_pkg.t_boolean := nvl(i_need_payment_params, com_api_const_pkg.TRUE);
    i                           binary_integer;

    l_dst_client_id_type        com_api_type_pkg.t_dict_value;
    l_dst_client_id_value       com_api_type_pkg.t_name;
    l_dst_account_number        com_api_type_pkg.t_name;
    l_client_id_type            com_api_type_pkg.t_dict_value;
    l_client_id_value           com_api_type_pkg.t_name;
    l_account_number            com_api_type_pkg.t_name;
    l_oper_surcharge_amount     com_api_type_pkg.t_money;
    l_oper_reason               com_api_type_pkg.t_dict_value;
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_object_id                 com_api_type_pkg.t_medium_id;
    
begin
    trc_log_pkg.debug('pmo_api_search_pkg.get_payment_params '||i_payment_order_id);
    
    select o.entity_type
         , o.object_id
      into l_entity_type
         , l_object_id
      from pmo_order o
     where o.id = i_payment_order_id;

    if l_need_payment_params = com_api_const_pkg.FALSE then
        select d.param_id
             , d.param_value
          bulk collect into 
               o_payment_param_id_tab
             , o_payment_param_val_tab
          from pmo_order_data d
         where d.order_id  = i_payment_order_id
           and d.param_id in (pmo_api_const_pkg.PARAM_TRANSFER_RECIPIENT_ACC
                            , pmo_api_const_pkg.PARAM_CBS_CLIENT_ID_TYPE
                            , pmo_api_const_pkg.PARAM_CBS_CLIENT_ID_VALUE
                            , pmo_api_const_pkg.PARAM_SOURCE_CLIENT_ID_TYPE
                            , pmo_api_const_pkg.PARAM_SOURCE_CLIENT_ID_VALUE
                            , pmo_api_const_pkg.PARAM_OPER_SURCHARGE_AMOUNT
                            , pmo_api_const_pkg.PARAM_OPER_REASON);

    else
        select d.param_id
             , d.param_value
          bulk collect into 
               o_payment_param_id_tab
             , o_payment_param_val_tab
          from pmo_order_data d
             , pmo_parameter p
         where d.order_id = i_payment_order_id
           and d.param_id = p.id
         order by d.id;

    end if;
        
    if o_payment_param_id_tab.count > 0 then
        for i in 1 .. o_payment_param_id_tab.count loop
            case o_payment_param_id_tab(i)
                when pmo_api_const_pkg.PARAM_SOURCE_CLIENT_ID_TYPE  then l_client_id_type        := o_payment_param_val_tab(i); 
                when pmo_api_const_pkg.PARAM_SOURCE_CLIENT_ID_VALUE then l_client_id_value       := o_payment_param_val_tab(i); 
                when pmo_api_const_pkg.PARAM_CBS_CLIENT_ID_TYPE     then l_dst_client_id_type    := o_payment_param_val_tab(i);
                when pmo_api_const_pkg.PARAM_CBS_CLIENT_ID_VALUE    then l_dst_client_id_value   := o_payment_param_val_tab(i); 
                when pmo_api_const_pkg.PARAM_TRANSFER_RECIPIENT_ACC then l_dst_account_number    := o_payment_param_val_tab(i);
                when pmo_api_const_pkg.PARAM_OPER_SURCHARGE_AMOUNT  then l_oper_surcharge_amount := o_payment_param_val_tab(i);
                when pmo_api_const_pkg.PARAM_OPER_REASON            then l_oper_reason           := o_payment_param_val_tab(i);
                else null;
            end case;
            trc_log_pkg.debug('pmo_api_search_pkg: param_id[' || o_payment_param_id_tab(i) || '] = ' || o_payment_param_val_tab(i));
        end loop; 
    end if;
    
    if l_account_number is not null then
        l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;
        l_client_id_value := l_account_number;
    elsif l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT and l_account_number is null then
        l_account_number := l_client_id_value;
    elsif l_client_id_type is null then 
        case l_entity_type
            when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            then l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;
                 l_client_id_value := to_char(l_object_id);
                 select account_number
                   into l_account_number
                   from acc_account
                  where id = l_object_id;
            when iss_api_const_pkg.ENTITY_TYPE_CARD
            then l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
                l_client_id_value := iss_api_card_pkg.get_card_number(i_card_id => l_object_id);
                select a.account_number
                  into l_account_number
                  from acc_account a
                     , acc_account_object ao
                 where ao.object_id   = l_object_id
                   and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and ao.account_id  = a.id;
            else
                 l_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER;
         end case; 
    end if;

    if l_dst_account_number is not null then
        l_dst_client_id_type := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;
        l_dst_client_id_value := l_dst_account_number;
    elsif l_dst_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT then
        if l_dst_account_number is null then
            l_dst_account_number := l_dst_client_id_value;
        end if;
    end if;

    select m.merchant_number
         , t.terminal_number
         , o.inst_id
         , r.mcc
         , o.customer_id
         , null                     card_number
         , l_account_number         account_number
         , l_client_id_type         client_id_type
         , case 
                when l_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER then c.customer_number 
                else l_client_id_value 
           end                      client_id_value
         , r.oper_type
         , null                     dst_customer_id
         , null                     dst_card_number
         , l_dst_account_number     dst_account_number
         , case o.purpose_id 
                when 10000003 then aup_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT 
                else l_dst_client_id_type 
           end
         , case o.purpose_id 
                when 10000003 then l_dst_account_number 
                else l_dst_client_id_value 
           end
         , o.amount                 oper_amount
         , o.amount                 oper_request_amount
         , o.currency               oper_currency
         , l_oper_surcharge_amount  oper_surcharge_amount
         , s.amount_algorithm       oper_amount_algorithm
         , null                     id
         , o.event_date             oper_date
         , null                     card_seq_number
         , null                     card_expir_date
         , null                     account_type
         , o.purpose_id
         , l_oper_reason            oper_reason
         , c.split_hash
      into o_merchant_number
         , o_terminal_number
         , o_acq_inst_id
         , o_mcc
         , o_customer_id
         , o_card_number
         , o_account_number
         , o_client_id_type
         , o_client_id_value
         , o_oper_type
         , o_dst_customer_id
         , o_dst_card_number
         , o_dst_account_number
         , o_dst_client_id_type
         , o_dst_client_id_value
         , o_oper_amount
         , o_oper_request_amount
         , o_oper_currency
         , o_oper_surcharge_amount
         , o_oper_amount_algorithm
         , o_oper_id
         , o_oper_date
         , o_cardseqnumber
         , o_cardexpirdate
         , o_dstaccounttype
         , o_purpose_id
         , o_oper_reason
         , o_split_hash
     from pmo_order    o
        , prd_customer c
        , pmo_purpose  r
        , acq_terminal t
        , acq_merchant m
        , pmo_schedule s
    where o.id          = i_payment_order_id
      and c.id(+)       = o.customer_id
      and r.id          = o.purpose_id
      and t.id(+)       = r.terminal_id
      and m.id(+)       = t.merchant_id
      and s.order_id(+) = o.id;

    return aup_api_const_pkg.RESP_CODE_OK;
    
exception
    when others then
        trc_log_pkg.debug(sqlerrm);
        return aup_api_const_pkg.RESP_CODE_ERROR;
end get_payment_params;

end pmo_api_search_pkg;
/
