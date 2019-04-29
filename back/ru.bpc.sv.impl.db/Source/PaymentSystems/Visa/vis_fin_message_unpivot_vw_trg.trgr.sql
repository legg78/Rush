CREATE OR REPLACE TRIGGER vis_fin_message_unpivot_vw_trg
instead of update
on vis_fin_message_unpivot_vw
referencing new as new old as old
for each row
begin
    if updating then
        com_ui_reject_pkg.update_field_value(
            i_table_name        => 'vis_fin_message_vw'
            , i_pk_field_name   => 'id'
            , i_pk_value        => :old.id
            , i_upd_field_name  => :old.column_name
            , i_upd_value       => :new.value
        );
    end if;
end vis_fin_message_unpivot_vw_trg;
/
 