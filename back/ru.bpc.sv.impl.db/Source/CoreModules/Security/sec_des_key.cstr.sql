alter table sec_des_key add (
    constraint sec_des_key_pk primary key (id)
  , constraint sec_des_key_uk unique (object_id, entity_type, key_type, key_index, lmk_id)
)
/