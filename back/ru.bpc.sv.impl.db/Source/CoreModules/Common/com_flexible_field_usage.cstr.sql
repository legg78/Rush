alter table com_flexible_field_usage add (
    constraint com_flexible_field_usage_pk primary key (id)
)
/
alter table com_flexible_field_usage add(constraint com_flexible_field_usage_uk unique (field_id, usage))
/
