alter table acm_component_state 
add constraint acm_component_state_pk 
primary key(id)
/

alter table acm_component_state
add constraint acm_component_state_uk
unique(user_id, component_id)
/

