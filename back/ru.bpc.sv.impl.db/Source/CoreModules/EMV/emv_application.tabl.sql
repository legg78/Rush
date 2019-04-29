create table emv_application (
    id                number(8) not null
    , seqnum          number(4)
    , inst_id         number(4)
    , aid             varchar2(200)
    , emv_scheme_id   varchar2(8)
    , mod_id          number(4)
    , id_owner        varchar2(10)
)
/
comment on table emv_application is 'EMV card application'
/
comment on column emv_application.id is 'Primary key'
/
comment on column emv_application.seqnum is 'Data version sequencial number.'
/
comment on column emv_application.inst_id is 'Owner institution identifier'
/
comment on column emv_application.aid is 'Application Identifier'
/
comment on column emv_application.emv_scheme_id is 'EMV scheme identifier'
/
comment on column emv_application.mod_id is 'Modifier identifier'
/
comment on column emv_application.id_owner is 'Identifier of the Application Specification Owner'
/
alter table emv_application rename column emv_scheme_id to type
/
comment on column emv_application.type is 'Application type'
/
alter table emv_application drop column inst_id
/
alter table emv_application add appl_scheme_id number(4)
/
comment on column emv_application.appl_scheme_id is 'Reference to emv scheme'
/
alter table emv_application drop column type
/
alter table emv_application add pix varchar2(200)
/
comment on column emv_application.pix is 'Primary Application Identifier Extension'
/
