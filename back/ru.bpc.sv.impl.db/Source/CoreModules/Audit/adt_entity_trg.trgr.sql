create or replace trigger adt_entity_trg
instead of delete or insert or update
on adt_entity_vw 
referencing new as new old as old
for each row
declare
    l_trail_id                  com_api_type_pkg.t_long_id;
    l_action_type               com_api_type_pkg.t_dict_value;
    l_changed_count             pls_integer := 0;
begin
    if inserting then
    
        l_action_type := 'INSERT';
        
        null;
        
    elsif updating then
    
        l_action_type := 'UPDATE';
        
        update adt_entity
           set is_active = :new.is_active
         where entity_type = :old.entity_type;
         
    elsif deleting then
    
        l_action_type := 'DELETE';
        
        null;
        
    else
        null;
    end if;
    
    l_trail_id := adt_api_trail_pkg.get_trail_id;
        
    adt_api_trail_pkg.check_value(l_trail_id, 'IS_ACTIVE', :old.is_active, :new.is_active, l_changed_count);
        
    if l_changed_count > 0 then
        adt_api_trail_pkg.put_audit_trail(
            i_trail_id          => l_trail_id
          , i_entity_type       => :old.entity_type
          , i_object_id         => 0
          , i_action_type       => l_action_type
        );
    end if;
end;
/
