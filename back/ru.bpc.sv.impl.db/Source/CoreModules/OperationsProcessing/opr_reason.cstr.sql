alter table opr_reason add constraint opr_reason_pk primary key (
    id
)
/
alter table opr_reason add constraint opr_reason_uk unique (
    oper_type
  , reason_dict
)
/
