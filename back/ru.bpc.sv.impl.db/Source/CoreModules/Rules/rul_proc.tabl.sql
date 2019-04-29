create table rul_proc (
    id                  number(4)
    , proc_name         varchar2(200)
    , category          varchar2(8)
)
/
comment on table rul_proc is 'List of procedures used in rules'
/
comment on column rul_proc.id is 'Record identifier'
/
comment on column rul_proc.proc_name is 'Procedure name'
/
comment on column rul_proc.category is 'Category of procedure usage'
/