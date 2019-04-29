create table nbc_iss_inst_code (
    pan_low        varchar2(24)
  , pan_high       varchar2(24)
  , iss_inst_code  varchar2(7)
)
/

comment on table nbc_iss_inst_code is 'NBC issuer institution code by PAN.'
/
comment on column nbc_iss_inst_code.pan_low is 'Range low value.'
/
comment on column nbc_iss_inst_code.pan_high is 'Range high value.'
/
comment on column nbc_iss_inst_code.iss_inst_code is 'Issuer institution code.'
/
alter table nbc_iss_inst_code add id number(16)
/
comment on column nbc_iss_inst_code.id is 'Primary key. Identifier.'
/
