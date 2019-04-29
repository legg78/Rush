create table acm_section (
    id            number(4)  not null
  , parent_id     number(4)
  , module_code   varchar2(3)
  , action        varchar2(200)
  , section_type  varchar2(8)
  , is_visible    number(1)
  , display_order number(4)
)
/

comment on table acm_section is 'Module sections. Logical parts of user interface.'
/

comment on column acm_section.id is 'Primary key.'
/

comment on column acm_section.parent_id is 'Parent section identifier.'
/

comment on column acm_section.module_code is 'Reference to system module. Module code.'
/

comment on column acm_section.action is 'JSF navigation action.'
/

comment on column acm_section.section_type is 'Section type (folder, page).'
/

comment on column acm_section.is_visible is 'Flag to display section like menu element.'
/

comment on column acm_section.display_order is 'Item display order in menu list.'
/

alter table acm_section add(managed_bean_name varchar2(50))
/

comment on column acm_section.managed_bean_name is 'Bean name.'
/
