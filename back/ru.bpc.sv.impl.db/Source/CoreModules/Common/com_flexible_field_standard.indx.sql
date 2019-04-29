create index com_flexible_field_standard_uk on com_flexible_field_standard(standard_id, field_id)
/
drop index com_flexible_field_standard_uk
/
create index com_flexible_field_standard_uk on com_flexible_field_standard(field_id, standard_id)
/
