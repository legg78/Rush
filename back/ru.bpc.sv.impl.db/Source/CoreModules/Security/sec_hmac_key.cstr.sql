alter table sec_hmac_key add (
    constraint sec_hmac_key_pk primary key (id)
  , constraint sec_hmac_key_uk unique (object_id, entity_type, key_index, lmk_id)
)
/