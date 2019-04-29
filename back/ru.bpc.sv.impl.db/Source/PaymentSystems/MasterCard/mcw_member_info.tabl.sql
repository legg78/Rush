create table mcw_member_info (
    member_id       varchar2(12) not null
    , region        varchar2(3)
    , endpoint      varchar2(12)
    , name          varchar2(200)
    , country       varchar2(3)
)
/

comment on table mcw_member_info is 'This table provides the layout of the expanded member parameter'
/

comment on column mcw_member_info.member_id is 'The member ID pertaining to the member profile described.'
/

comment on column mcw_member_info.region is 'Interchange Region'
/

comment on column mcw_member_info.endpoint is 'This is the default routing endpoint at the member ID level.'
/

comment on column mcw_member_info.name is 'The member name.'
/

comment on column mcw_member_info.country is 'Numeric country code established by ISO.'
/
alter table mcw_member_info add npg_ica varchar2(1)
/
comment on column mcw_member_info.npg_ica is 'National Payment Gateway Processor Switch.'
/
