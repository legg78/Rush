create unique index com_flexible_field_ndx on com_flexible_field (
    entity_type
    , name
)
/
drop index com_flexible_field_ndx
/
create index com_flexible_field_ndx on com_flexible_field (
    entity_type
)
/

create unique index com_flexible_field_uk on com_flexible_field (
    name
  , entity_type
)
/
