create table din_addendum_type(
    function_code                varchar2(2)
  , parent_function_code         varchar2(2)
  , priority                     number(4)
  , is_unique                    varchar2(2)
  , description                  varchar2(200)
)
/

comment on table din_addendum_type is 'Diners Club reference table with addendum types. Every addendum type is associated with an unique function code'
/
comment on column din_addendum_type.function_code is 'Primary key. Function code [FUNCD], it is type of an addendum message'
/
comment on column din_addendum_type.priority is 'Priority of addendum type that defines order of addendums for every detail message in an outgoing clearing file'
/
comment on column din_addendum_type.parent_function_code is 'Parent function code. Only zero and first level hierarchy are available. If parent function code is defined for an addendum then that one can''t relate to the regular detail message XD (zero level in the hierarchy), it is only relates to the parent function code (1st level in the hierarchy).'
/
comment on column din_addendum_type.is_unique is 'Unique flag. If it is set to true (1) then an addendum is unique per financial message'
/
comment on column din_addendum_type.description is 'Description of addendum type'
/

comment on table din_addendum_type is 'Obsolete, may be deleted'
/
