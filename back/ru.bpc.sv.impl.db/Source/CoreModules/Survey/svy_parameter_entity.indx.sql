create index svy_param_entity_prm_id_ndx on svy_parameter_entity (param_id)
/
drop index svy_param_entity_prm_id_ndx
/
create unique index svy_prm_ent_prm_id_ent_typ_ndx on svy_parameter_entity (param_id, entity_type)
/
