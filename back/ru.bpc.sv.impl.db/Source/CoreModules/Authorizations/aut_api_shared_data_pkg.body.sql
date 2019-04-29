create or replace package body aut_api_shared_data_pkg is
/********************************************************* 
 *  API for shared data of authorization <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 01.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module:  AUT_API_SHARED_DATA_PKG  <br /> 
 *  @headcom
 **********************************************************/


procedure clear_shared_data is
begin
    --g_auth := null;
    g_amounts.delete;
    g_currencies.delete;
    g_accounts.delete;
    g_dates.delete;
    g_params.delete;
end;

procedure clear_params is
begin
    rul_api_param_pkg.clear_params (
        io_params       => g_params
    );
end;

function get_param_num (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return number is
begin
    return rul_api_param_pkg.get_param_num (
        i_name              => i_name
        , io_params         => g_params
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;

function get_param_date (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return date is
begin
    return rul_api_param_pkg.get_param_date (
        i_name              => i_name
        , io_params         => g_params
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;

function get_param_char (
    i_name              in com_api_type_pkg.t_name
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_name := null
) return com_api_type_pkg.t_name is
begin
    return rul_api_param_pkg.get_param_char (
        i_name              => i_name
        , io_params         => g_params
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in com_api_type_pkg.t_name
) is
begin
    rul_api_param_pkg.set_param (
        i_name              => i_name
        , io_params         => g_params
        , i_value           => i_value
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in number
) is
begin
    rul_api_param_pkg.set_param (
        i_name              => i_name
        , io_params         => g_params
        , i_value           => i_value
    );
end;

procedure set_param (
    i_name              in com_api_type_pkg.t_name
    , i_value           in date
) is
begin
    rul_api_param_pkg.set_param (
        i_name              => i_name
        , io_params         => g_params
        , i_value           => i_value
    );
end;

procedure set_amount (
    i_name              in com_api_type_pkg.t_name
    , i_amount          in com_api_type_pkg.t_money
    , i_currency        in com_api_type_pkg.t_curr_code
) is
begin
    rul_api_param_pkg.set_amount (
        i_name              => i_name
        , i_amount          => i_amount
        , i_currency        => i_currency
        , io_amount_tab     => g_amounts
    );
end;
    
procedure get_amount (
    i_name              in com_api_type_pkg.t_name
    , o_amount          out com_api_type_pkg.t_money
    , o_currency        out com_api_type_pkg.t_curr_code
    , i_mask_error      in com_api_type_pkg.t_boolean
    , i_error_amount    in com_api_type_pkg.t_money
    , i_error_currency  in com_api_type_pkg.t_curr_code
) is
begin
    rul_api_param_pkg.get_amount (
        i_name              => i_name
        , o_amount          => o_amount
        , o_currency        => o_currency
        , io_amount_tab     => g_amounts
        , i_mask_error      => i_mask_error
        , i_error_amount    => i_error_amount
        , i_error_currency  => i_error_currency
    );
end;

procedure set_account (
    i_name                  in com_api_type_pkg.t_name
  , i_account_rec           in acc_api_type_pkg.t_account_rec
) is
begin
    rul_api_param_pkg.set_account (
        i_name              => i_name
      , i_account_rec       => i_account_rec
      , io_account_tab      => g_accounts
    );
end;

procedure get_account (
    i_name                  in     com_api_type_pkg.t_name
  , o_account_rec              out acc_api_type_pkg.t_account_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE
  , i_error_value           in     com_api_type_pkg.t_account_id := null
) is
begin
    rul_api_param_pkg.get_account (
        i_name              => i_name
      , o_account_rec       => o_account_rec
      , io_account_tab      => g_accounts
      , i_mask_error        => i_mask_error
      , i_error_value       => i_error_value
    );
end;

procedure set_date (
    i_name              in com_api_type_pkg.t_name
    , i_date            in date
) is
begin
    rul_api_param_pkg.set_date (
        i_name              => i_name
        , i_date            => i_date
        , io_date_tab       => g_dates
    );
end;
    
procedure get_date (
    i_name              in com_api_type_pkg.t_name
    , o_date            out date
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in date := null
) is
begin
    rul_api_param_pkg.get_date (
        i_name              => i_name
        , o_date            => o_date
        , io_date_tab       => g_dates
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;
    
procedure set_currency (
    i_name              in com_api_type_pkg.t_name
    , i_currency        in com_api_type_pkg.t_curr_code
) is
begin
    rul_api_param_pkg.set_currency (
        i_name              => i_name
        , i_currency        => i_currency
        , io_currency_tab   => g_currencies
    );
end;
    
procedure get_currency (
    i_name              in com_api_type_pkg.t_name
    , o_currency        out com_api_type_pkg.t_curr_code
    , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_error_value     in com_api_type_pkg.t_curr_code := null
) is
begin
    rul_api_param_pkg.get_currency (
        i_name              => i_name
        , o_currency        => o_currency
        , io_currency_tab   => g_currencies
        , i_mask_error      => i_mask_error
        , i_error_value     => i_error_value
    );
end;
    
procedure set_returning_resp_code (
    i_resp_code             in com_api_type_pkg.t_dict_value 
) is
begin
    set_param (
        i_name                      => 'RETURNING_RESP_CODE'
        , i_value                   => i_resp_code
    );
end;
    
function get_returning_resp_code return com_api_type_pkg.t_dict_value is
begin
    return aut_api_shared_data_pkg.get_param_char (
        i_name                      => 'RETURNING_RESP_CODE'
        , i_mask_error              => com_api_type_pkg.TRUE
        , i_error_value             => aup_api_const_pkg.RESP_CODE_OK
    );
end;

function get_object_id (
    i_entity_type           in com_api_type_pkg.t_dict_value
    , i_account_name        in com_api_type_pkg.t_name
    , i_party_type          in com_api_type_pkg.t_dict_value
    , o_inst_id             out com_api_type_pkg.t_inst_id
    , o_account_number      out com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_long_id is

/*    l_account_id                    com_api_type_pkg.t_medium_id;
    l_currency                      com_api_type_pkg.t_curr_code;
    l_agent_id                      com_api_type_pkg.t_agent_id;
    l_account_type                  com_api_type_pkg.t_dict_value;
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_contract_id                   com_api_type_pkg.t_medium_id;*/
    l_account_rec                   acc_api_type_pkg.t_account_rec;

begin
    case i_entity_type
        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            if opr_api_shared_data_pkg.g_auth.merchant_id is not null then
                o_inst_id := opr_api_shared_data_pkg.g_auth.acq_inst_id;
                o_account_number := opr_api_shared_data_pkg.g_auth.account_number;
                return opr_api_shared_data_pkg.g_auth.merchant_id;
            end if;

        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            if opr_api_shared_data_pkg.g_auth.terminal_id is not null then
                o_inst_id := opr_api_shared_data_pkg.g_auth.acq_inst_id;
                o_account_number := opr_api_shared_data_pkg.g_auth.account_number;
                return opr_api_shared_data_pkg.g_auth.terminal_id;
            end if;

        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            if opr_api_shared_data_pkg.g_auth.card_id is not null then
                o_inst_id := opr_api_shared_data_pkg.g_auth.card_inst_id;
                o_account_number := opr_api_shared_data_pkg.g_auth.account_number;
                return opr_api_shared_data_pkg.g_auth.card_id;
            end if;

        when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            if opr_api_shared_data_pkg.g_auth.card_instance_id is not null then
                o_inst_id := opr_api_shared_data_pkg.g_auth.card_inst_id;
                o_account_number := opr_api_shared_data_pkg.g_auth.account_number;
                return opr_api_shared_data_pkg.g_auth.card_instance_id;
            end if;

        when iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            if (
                i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER
                and opr_api_shared_data_pkg.g_auth.customer_id is not null
            ) then
                o_inst_id := opr_api_shared_data_pkg.g_auth.card_inst_id;
                o_account_number := opr_api_shared_data_pkg.g_auth.account_number;
                return opr_api_shared_data_pkg.g_auth.customer_id;

            elsif (
                i_party_type = com_api_const_pkg.PARTICIPANT_DEST
                and opr_api_shared_data_pkg.g_auth.dst_customer_id is not null
            ) then
                o_inst_id := opr_api_shared_data_pkg.g_auth.dst_inst_id; 
                o_account_number := opr_api_shared_data_pkg.g_auth.dst_account_number;
                return opr_api_shared_data_pkg.g_auth.dst_customer_id;

            elsif i_account_name is not null then
                aut_api_shared_data_pkg.get_account(
                    i_name              => i_account_name
                  , o_account_rec       => l_account_rec
                );
                o_inst_id        := l_account_rec.inst_id;
                o_account_number := l_account_rec.account_number;
                return l_account_rec.customer_id;
            end if;

        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            if i_account_name is not null then
                aut_api_shared_data_pkg.get_account(
                    i_name              => i_account_name
                  , o_account_rec       => l_account_rec
                );
                o_inst_id        := l_account_rec.inst_id;
                o_account_number := l_account_rec.account_number;
                return l_account_rec.account_id;
            end if;

        when ost_api_const_pkg.ENTITY_TYPE_AGENT then
            if i_account_name is not null then
                aut_api_shared_data_pkg.get_account(
                    i_name              => i_account_name
                  , o_account_rec       => l_account_rec
                );
                o_inst_id        := l_account_rec.inst_id;
                o_account_number := l_account_rec.account_number;
                return l_account_rec.agent_id;
            end if;

        when ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
            if i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                o_account_number := opr_api_shared_data_pkg.g_auth.account_number;
                return opr_api_shared_data_pkg.g_auth.iss_inst_id;
            elsif i_party_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
                o_account_number := opr_api_shared_data_pkg.g_auth.account_number;
                return opr_api_shared_data_pkg.g_auth.acq_inst_id;
            elsif i_account_name is not null then
                aut_api_shared_data_pkg.get_account(
                    i_name              => i_account_name
                  , o_account_rec       => l_account_rec
                );
                o_inst_id        := l_account_rec.inst_id;
                o_account_number := l_account_rec.account_number;
                return o_inst_id;
            end if;
                
        when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
            if i_account_name is not null then
                aut_api_shared_data_pkg.get_account(
                    i_name              => i_account_name
                  , o_account_rec       => l_account_rec
                );
                o_inst_id        := l_account_rec.inst_id;
                o_account_number := l_account_rec.account_number;
                return l_account_rec.contract_id;
            end if;
        
    else
        null;
    end case;

    com_api_error_pkg.raise_error (
        i_error             => 'AUTH_ENTITY_NOT_AVAILABLE'
        , i_env_param1      => i_entity_type
        , i_env_param2      => i_account_name
        , i_env_param3      => i_party_type
    );
end;

function get_object_id (
    i_entity_type           in com_api_type_pkg.t_dict_value
    , i_account_name        in com_api_type_pkg.t_name
    , i_party_type          in com_api_type_pkg.t_dict_value
    , o_inst_id             out com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_long_id is
    l_account_number        com_api_type_pkg.t_account_number;
begin
    return get_object_id (
        i_entity_type       => i_entity_type
        , i_account_name    => i_account_name
        , i_party_type      => i_party_type
        , o_inst_id         => o_inst_id
        , o_account_number  => l_account_number
    );
end;

function get_object_id (
    i_entity_type           in com_api_type_pkg.t_dict_value
    , i_account_name        in com_api_type_pkg.t_name
    , i_party_type          in com_api_type_pkg.t_dict_value
    , o_account_number      out com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_long_id is
    l_inst_id               com_api_type_pkg.t_inst_id;
begin
    return get_object_id (
        i_entity_type       => i_entity_type
        , i_account_name    => i_account_name
        , i_party_type      => i_party_type
        , o_inst_id         => l_inst_id
        , o_account_number  => o_account_number
    );
end;

procedure load_card_params is
begin
    rul_api_shared_data_pkg.load_card_params(
        i_card_id  => opr_api_shared_data_pkg.g_auth.card_id
      , io_params  => g_params
    );
end;

procedure load_account_params is
begin
    rul_api_shared_data_pkg.load_account_params(
        i_account_id  => opr_api_shared_data_pkg.g_auth.dst_account_id
      , io_params     => opr_api_shared_data_pkg.g_params
    );
end;

procedure load_terminal_params is
begin
    rul_api_shared_data_pkg.load_terminal_params(
        i_terminal_id  => opr_api_shared_data_pkg.g_auth.terminal_id
      , io_params      => opr_api_shared_data_pkg.g_params
    );
end;
     
procedure load_merchant_params is
begin
    rul_api_shared_data_pkg.load_merchant_params(
        i_merchant_id  => opr_api_shared_data_pkg.g_auth.merchant_id
      , io_params      => opr_api_shared_data_pkg.g_params
    );

end;

procedure load_customer_params (
    i_party_type        in com_api_type_pkg.t_dict_value
) is
    l_object_id   com_api_type_pkg.t_medium_id;
begin
    if i_party_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
        select c.customer_id
          into l_object_id
          from acq_merchant m
             , prd_contract c
         where m.id = opr_api_shared_data_pkg.g_auth.merchant_id
           and c.id = m.contract_id;
    elsif i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER then
        l_object_id := opr_api_shared_data_pkg.g_auth.customer_id;
    elsif i_party_type = com_api_const_pkg.PARTICIPANT_DEST then
        l_object_id := opr_api_shared_data_pkg.g_auth.dst_customer_id;
    end if;

    rul_api_shared_data_pkg.load_customer_params (
        i_customer_id  => l_object_id
        , io_params    => g_params
    );
end;

procedure stop_process (
    i_resp_code         in com_api_type_pkg.t_dict_value
    , i_status          in com_api_type_pkg.t_dict_value
) is
begin
    if i_status is not null then
        opr_api_shared_data_pkg.g_auth.status := i_status;
    else
        set_param (
            i_name     => 'RETURNING_RESP_CODE'
            , i_value  => i_resp_code
        );
    end if;

    raise com_api_error_pkg.e_stop_process_operation;
end;
    
procedure rollback_process (
    i_resp_code         in com_api_type_pkg.t_dict_value
    , i_status          in com_api_type_pkg.t_dict_value
    , i_reason          in com_api_type_pkg.t_dict_value
) is
begin
    if i_status is not null then
        opr_api_shared_data_pkg.g_auth.status := i_status;
    else
        set_param (
            i_name     => 'RETURNING_RESP_CODE'
            , i_value  => i_resp_code
        );
    end if;
    opr_api_shared_data_pkg.g_auth.status_reason := i_reason;

    raise com_api_error_pkg.e_rollback_process_operation;
end rollback_process;

end aut_api_shared_data_pkg;
/
