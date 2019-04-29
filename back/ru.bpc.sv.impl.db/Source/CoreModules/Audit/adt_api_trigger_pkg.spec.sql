create or replace package adt_api_trigger_pkg as

procedure create_audit_trigger(
    i_entity_type       in      com_api_type_pkg.t_dict_value           default null       
);
    
end;
/