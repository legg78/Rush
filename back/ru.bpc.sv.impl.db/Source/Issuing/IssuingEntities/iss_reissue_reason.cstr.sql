alter table iss_reissue_reason add (
    constraint iss_reissue_reason_pk primary key (id)
  , constraint iss_reissue_reason_uk unique (inst_id, reissue_reason)
)
/
