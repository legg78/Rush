create or replace package body csm_api_progress_pkg as
/*********************************************************
 *  Case management API  <br />
 *  Created by Nick (shalnov@bpcbt.com)  at 05.04.2019 <br />
 *  Module: csm_api_progress_pkg <br />
 *  @headcom
 **********************************************************/

procedure get_msg_type(
    i_network_id              in     com_api_type_pkg.t_tiny_id
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_mask_error              in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_msg_type                   out com_api_type_pkg.t_dict_value
  , o_is_reversal                out com_api_type_pkg.t_boolean
) is
    l_mask_error    com_api_type_pkg.t_boolean := nvl(i_mask_error, com_api_const_pkg.FALSE);
begin
    trc_log_pkg.debug(
        i_text       => 'csm_api_progress_pkg.get_msg_type: i_network_id [#1], i_case_progress [#2]' 
      , i_env_param1 => i_network_id
      , i_env_param2 => i_case_progress
    );
    select msg_type
         , is_reversal
      into o_msg_type
         , o_is_reversal
      from (
            select m.msg_type
                 , m.is_reversal
                 , row_number() over (order by m.priority) rn
              from csm_progress_map m
             where i_network_id like m.network_id
               and m.case_progress = i_case_progress
            ) where rn = 1;

    trc_log_pkg.debug(
        i_text       => 'csm_api_progress_pkg.get_msg_type: msg_type [#1], is_reversal [#2]' 
      , i_env_param1 => o_msg_type
      , i_env_param2 => o_is_reversal
    );    
exception
    when no_data_found then
        if l_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error             => 'CSM_MSG_NOT_FOUND'
              , i_env_param1        => i_network_id
              , i_env_param2        => i_case_progress
            );
        else
            trc_log_pkg.debug(
                i_text => 'get_msg_type: not found'
            );
        end if;    
        
end get_msg_type;

procedure get_case_progress(
    i_network_id              in     com_api_type_pkg.t_tiny_id
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_is_reversal             in     com_api_type_pkg.t_boolean 
  , i_mask_error              in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_case_progress              out com_api_type_pkg.t_dict_value
) is
    l_mask_error            com_api_type_pkg.t_boolean := nvl(i_mask_error, com_api_const_pkg.FALSE);
begin
    trc_log_pkg.debug(
        i_text       => 'csm_api_progress_pkg.get_case_progress: i_network_id [#1], i_msg_type [#2], i_is_reversal [#3]' 
      , i_env_param1 => i_network_id
      , i_env_param2 => i_msg_type
      , i_env_param3 => i_is_reversal
    );
    
    select case_progress
      into o_case_progress
      from (select case_progress
                 , row_number() over (order by m.priority) rn
              from csm_progress_map m
             where i_network_id like m.network_id
               and m.is_reversal = i_is_reversal
               and m.msg_type    = i_msg_type
           ) where rn = 1; 
    
    trc_log_pkg.debug(
        i_text       => 'get_case_progress: msg_type [#1], case_progress [#2]' 
      , i_env_param1 => o_case_progress
    );
exception
    when no_data_found then
        if l_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error             => 'CSM_PROGRESS_NOT_FOUND'
              , i_env_param1        => i_network_id
              , i_env_param2        => i_msg_type
              , i_env_param3        => i_is_reversal
            );
        else
            trc_log_pkg.debug(
                i_text => 'get_case_progress: progress not found'
            );
        end if;
end get_case_progress;

function get_is_incoming(
    i_flow_id                 in     com_api_type_pkg.t_tiny_id
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_is_reversal             in     com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_boolean result_cache
is
    l_res       com_api_type_pkg.t_boolean;
begin
    -- probably better via conf table
    trc_log_pkg.debug('csm_api_progress_pkg.get_is_incoming: i_flow_id=' || i_flow_id || ' i_msg_type=' || i_msg_type || ' i_is_reversal=' || i_is_reversal);
    
    case 
        when i_flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
        then
            case i_is_reversal
                when com_api_const_pkg.TRUE
                then
                    case i_msg_type
                        when 'MSGTCHBK' then
                            l_res := com_api_const_pkg.FALSE;
                        when 'MSGTREPR' then
                            l_res := com_api_const_pkg.TRUE;
                        else null;
                    end case;
                when com_api_const_pkg.FALSE
                then
                    case i_msg_type
                        when 'MSGTCHBK' then
                            l_res := com_api_const_pkg.TRUE;
                        when 'MSGTREPR' then
                            l_res := com_api_const_pkg.FALSE;
                        when 'MSGTRTRQ' then
                            l_res := com_api_const_pkg.TRUE;
                        else null;
                    end case;
            end case;
        when i_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
        then
            case i_is_reversal
                when com_api_const_pkg.TRUE
                then
                    case i_msg_type
                        when 'MSGTCHBK' then
                            l_res := com_api_const_pkg.TRUE;
                        when 'MSGTREPR' then
                            l_res := com_api_const_pkg.FALSE;
                        else null;
                    end case;
                when com_api_const_pkg.FALSE
                then
                    case i_msg_type
                        when 'MSGTCHBK' then
                            l_res := com_api_const_pkg.FALSE;
                        when 'MSGTREPR' then
                            l_res := com_api_const_pkg.TRUE;
                        when 'MSGTRTRQ' then
                            l_res := com_api_const_pkg.FALSE;
                        else null;
                    end case;
            end case;
        else
            com_api_error_pkg.raise_error(
                i_error             => 'CSM_FLOW_NOT_SUPPORTED'
              , i_env_param1        => i_flow_id
            );
            
    end case;
    
    trc_log_pkg.debug(
        i_text       => 'get_is_incoming: return [#1]'
      , i_env_param1 => l_res
    );
    
    return l_res; 
end get_is_incoming;

end csm_api_progress_pkg;
/
