create index fcl_limit_history_source_ndx on fcl_limit_history(source_object_id, source_entity_type, limit_type)
/

create index fcl_limit_history_owner_ndx on fcl_limit_history(object_id, entity_type, limit_type)
/

drop index fcl_limit_history_source_ndx
/

drop index fcl_limit_history_owner_ndx
/

create index fcl_limit_history_source_ndx on fcl_limit_history(source_object_id, source_entity_type, limit_type)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create index fcl_limit_history_owner_ndx on fcl_limit_history(object_id, entity_type, limit_type)
/****************** partition start ********************
    local
******************** partition end ********************/
/