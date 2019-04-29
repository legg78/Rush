create table rul_name_transform( 
    id                number(4)
  , seqnum            number(4)
  , function_name     varchar2(200)
  , inst_id           number(4)
)
/

comment on table rul_name_transform is 'Rule name transformation'
/
comment on column rul_name_transform.id is 'Identifier'
/
comment on column rul_name_transform.seqnum is 'Seqnum'
/
comment on column rul_name_transform.function_name is 'Function name'
/
comment on column rul_name_transform.inst_id is 'Institution'
/
