create or replace trigger opr_participant_unpivot_vw_trg
instead of update
on opr_participant_unpivot_vw
referencing new as new old as old
for each row
begin
    if updating then
        com_ui_reject_pkg.update_field_value(
            i_table_name        => 'opr_participant_vw'
            , i_pk_field_name   => 'oper_id'
            , i_pk_value        => :old.oper_id
            , i_upd_field_name  => :old.column_name
            , i_upd_value       => :new.value
            , i_pk2_field_name  => 'participant_type'
            , i_pk2_value       => :old.participant_type
        );
    end if;
end opr_participant_unpivot_vw_trg;
/