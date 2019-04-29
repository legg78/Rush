alter table app_structure add (
    constraint app_structure_pk primary key(id)
  , constraint app_structure_uk unique (appl_type, element_id, parent_element_id)
)
/