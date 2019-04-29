create table acc_macros_type (
    id                  number(4)
    , bunch_type_id     number(4)
    , seqnum            number(4)
    , status            varchar2(8)
)
/
comment on table acc_macros_type is 'list of types of macros'
/
comment on column acc_macros_type.id is 'macros type identifier'
/
comment on column acc_macros_type.bunch_type_id is 'Bunch type identifier'
/
comment on column acc_macros_type.seqnum is 'Number of version'
/
comment on column acc_macros_type.status is 'Status of macros upon creation'
/

