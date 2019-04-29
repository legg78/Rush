create or replace package body adt_ui_entity_pkg as

procedure modify_status(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , io_audit_status     in out  com_api_type_pkg.t_boolean
) is
    l_audit_status      com_api_type_pkg.t_boolean;
begin
    begin
        select is_active
          into l_audit_status
          from adt_entity_vw
         where entity_type = i_entity_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'AUDIT_ENTITY_NOT_EXIST'
              , i_env_param1    => i_entity_type
            );
    end;
    
    if io_audit_status is null or
       io_audit_status != l_audit_status 
    then
        update adt_entity_vw
           set is_active = decode(is_active, com_api_type_pkg.TRUE, com_api_type_pkg.FALSE, com_api_type_pkg.TRUE)
         where entity_type = i_entity_type;
         
        select is_active 
          into io_audit_status 
          from adt_entity_vw 
         where entity_type = i_entity_type;
    end if;
        
end;

end;
/