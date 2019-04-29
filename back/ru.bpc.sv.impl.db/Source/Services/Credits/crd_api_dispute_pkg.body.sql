create or replace package body crd_api_dispute_pkg is

procedure set_debt_status (
    i_oper_id           in  com_api_type_pkg.t_long_id
    , i_status          in  com_api_type_pkg.t_dict_value     
)is
begin
    for r in (
        select id
             , status
             , oper_id 
          from crd_debt 
         where oper_id = i_oper_id
           and status in (crd_api_const_pkg.DEBT_STATUS_ACTIVE, crd_api_const_pkg.DEBT_STATUS_SUSPENDED, crd_api_const_pkg.DEBT_STATUS_PAID) 
    )loop
        if (r.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE and i_status = crd_api_const_pkg.DEBT_STATUS_SUSPENDED)
           or (r.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE and i_status = crd_api_const_pkg.DEBT_STATUS_COLLECT)  
           or (r.status = crd_api_const_pkg.DEBT_STATUS_SUSPENDED and i_status = crd_api_const_pkg.DEBT_STATUS_ACTIVE)  
           or (r.status = crd_api_const_pkg.DEBT_STATUS_PAID and i_status = crd_api_const_pkg.DEBT_STATUS_CANCELED)  
           or (r.status = crd_api_const_pkg.DEBT_STATUS_PAID and i_status = crd_api_const_pkg.DEBT_STATUS_SUSPENDED)  
           or (r.status = crd_api_const_pkg.DEBT_STATUS_SUSPENDED and i_status = crd_api_const_pkg.DEBT_STATUS_CANCELED) 
        then
           
           update crd_debt
              set status = i_status
            where id = r.id;    
        else
            com_api_error_pkg.raise_error(
                i_error         => 'DEBT_WRONG_STATUS'
              , i_env_param1    => r.status
              , i_env_param2    => i_status
            ); 
            
        end if;
    end loop;            
end;

end;
/

