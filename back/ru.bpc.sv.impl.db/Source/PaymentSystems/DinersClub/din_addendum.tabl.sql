create table din_addendum(
    id                           number(16)
  , function_code                varchar2(2)
  , fin_id                       number(16)
  , file_id                      number(16)
  , record_number                number(8)
)
/

comment on table din_addendum is 'Diners Club additional detail records for financial messages'
/
comment on column din_addendum.id is 'Primary key'
/
comment on column din_addendum.function_code is 'Function code [FUNCD], it is type of an addendum message'
/
comment on column din_addendum.fin_id is 'Reference (foreign key) to parent table DIN_FIN_MESSAGE'
/
comment on column din_addendum.file_id is 'Reference to a clearing file (primary key of the table DIN_FILE and PRC_SESSION_FILE)'
/
comment on column din_addendum.record_number is 'Record number in a clearing file'
/
