create or replace package body opr_cst_shared_data_pkg is

procedure collect_global_oper_params(
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is 

    l_oper_id         com_api_type_pkg.t_long_id;
    l_auth_code       com_api_type_pkg.t_auth_code;
  
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_global_oper_params dummy'
    );
    
    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
           
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_global_oper_params dummy l_oper_id:' || l_oper_id        
    );
    
    select auth_code
      into l_auth_code
      from opr_operation o
         , opr_participant p
     where o.id = p.oper_id
       and o.msg_type           = OPR_API_CONST_PKG.MESSAGE_TYPE_POS_BATCH  
       and p.participant_type   = com_api_const_pkg.PARTICIPANT_ISSUER
       and o.id                 = l_oper_id;
    
    rul_api_param_pkg.set_param(
        i_value                 => l_auth_code
      , i_name                  => 'AUTH_CODE'
      , io_params               => io_params
    );

    exception
        when no_data_found
        then
            l_auth_code := null; 
            rul_api_param_pkg.set_param(
                i_value                 => l_auth_code
              , i_name                  => 'AUTH_CODE'
              , io_params               => io_params
            );
end;

procedure collect_oper_params(
    i_oper          in              opr_api_type_pkg.t_oper_rec         default null
  , i_iss_part      in              opr_api_type_pkg.t_oper_part_rec    default null 
  , i_acq_part      in              opr_api_type_pkg.t_oper_part_rec    default null 
  , io_params       in out nocopy   com_api_type_pkg.t_param_tab    
) is
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_oper_params dummy'
    );
    
end;

end opr_cst_shared_data_pkg;
/
