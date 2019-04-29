create or replace package body csm_api_check_pkg as
/*********************************************************
 *  Case management check API  <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 29.11.2016 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: csm_api_check_pkg <br />
 *  @headcom
 **********************************************************/

-- Perform check
procedure perform_check (
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_card_number           in      com_api_type_pkg.t_card_number
  , i_merchant_number       in      com_api_type_pkg.t_account_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_msg_type              in      com_api_type_pkg.t_dict_value
  , i_dispute_id            in      com_api_type_pkg.t_long_id
  , i_original_id           in      com_api_type_pkg.t_long_id
  , i_de_024                in      mcw_api_type_pkg.t_de024
  , i_reason_code           in      com_api_type_pkg.t_mcc
  , i_de004                 in      mcw_api_type_pkg.t_de004   default null
  , i_de049                 in      mcw_api_type_pkg.t_de049   default null
)
is
    l_params                        com_api_type_pkg.t_param_tab;
    l_is_reversal                   com_api_type_pkg.t_boolean;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    l_sttl_type                     com_api_type_pkg.t_dict_value;
begin
    begin
        select is_reversal
             , oper_type
             , sttl_type
          into l_is_reversal
             , l_oper_type
             , l_sttl_type
          from opr_operation
         where id = i_oper_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'NOT_ENOUGH_DATA_TO_FIND_OPERATIONS'
              , i_env_param1 => i_oper_id
            );
    end;
    
    rul_api_param_pkg.set_param (
        i_value   => i_de_024
      , i_name    => 'DE_024'
      , io_params => l_params
    );
    
    rul_api_param_pkg.set_param (
        i_value   => l_is_reversal
      , i_name    => 'IS_REVERSAL'
      , io_params => l_params
    );
    
    rul_api_param_pkg.set_param (
        i_value   => i_msg_type
      , i_name    => 'MESSAGE_TYPE'
      , io_params => l_params
    );
    
    rul_api_param_pkg.set_param (
        i_value   => l_oper_type
      , i_name    => 'OPER_TYPE'
      , io_params => l_params
    );
    
    rul_api_param_pkg.set_param (
        i_value   => i_reason_code
      , i_name    => 'REASON_CODE'
      , io_params => l_params
    );
    
    rul_api_param_pkg.set_param (
        i_value   => l_sttl_type
      , i_name    => 'STTL_TYPE'
      , io_params => l_params
    );
    
    for m in (select id from rul_mod where scale_id = 1017 order by priority) loop
        if rul_mod_static_pkg.check_condition(
               i_mod_id  => m.id
             , i_params  => l_params
           ) = com_api_const_pkg.TRUE
        then
            csm_api_case_pkg.add (
                i_inst_id               => i_inst_id
              , i_card_number           => i_card_number     
              , i_merchant_number       => i_merchant_number 
              , i_msg_type              => i_msg_type
              , i_oper_id               => i_oper_id
              , i_original_id           => i_original_id
              , i_dispute_id            => i_dispute_id
              , i_dispute_amount        => i_de004
              , i_dispute_currency      => i_de049
            );
            return;
        end if;         
    end loop;
       
end perform_check;

end csm_api_check_pkg;
/
