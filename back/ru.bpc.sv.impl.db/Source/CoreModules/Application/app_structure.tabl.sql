create table app_structure
(
    id                  number(8)
  , appl_type           varchar2(8)
  , element_id          number(8)
  , parent_element_id   number(8)
  , min_count           number(4)
  , max_count           number(4)
  , default_value       varchar2(200)
  , is_visible          number(1)
  , is_updatable        number(1)
  , display_order       number(4)
  , is_info             number(1)
  , lov_id              number(4)
  , is_wizard           number(1)
  , edit_form           varchar2(200)
  , is_parent_desc      number(1)
)
/

comment on table app_structure is 'Application structure. Each application type has own structure.'
/

comment on column app_structure.id is 'Primary key.'
/
comment on column app_structure.appl_type is 'Reference to application type.'
/
comment on column app_structure.element_id is 'Reference to application element - block or field.'
/
comment on column app_structure.parent_element_id is 'Reference to parent element (block).'
/
comment on column app_structure.min_count is 'Minimum count of elements of that type in parent block (if 0 then element is optional if 1 element is mandatory).'
/
comment on column app_structure.max_count is 'Maximum count of element of that type in parent block.'
/
comment on column app_structure.default_value is 'Default value.'
/
comment on column app_structure.is_visible is 'Visible flag. Should display in visual form or not.'
/
comment on column app_structure.is_updatable is 'Updatable flag. Is user can redefine default value.'
/
comment on column app_structure.display_order is 'Displaying order.'
/
comment on column app_structure.is_info is 'Information field. Is field using to form parent block description.'
/
comment on column app_structure.lov_id is 'Reference to list of possible values. Redefine LOV from app_elements.'
/
comment on column app_structure.is_wizard is 'Information field. Element can be added only through the wizard.'
/
comment on column app_structure.edit_form is 'Custom visual form for editing application complex element'
/
comment on column app_structure.is_parent_desc is 'Is parent block description.'
/
alter table app_structure add (is_insertable number(1))
/
comment on column app_structure.is_insertable is 'Insertable flag. Is user can add new.'
/
