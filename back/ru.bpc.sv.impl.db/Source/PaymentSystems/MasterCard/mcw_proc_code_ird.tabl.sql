create table mcw_proc_code_ird (
    arrangement_code  varchar2(8) not null
    , arrangement_type  varchar2(1) not null
    , mti varchar2(4)
    , de024 varchar2(3)
    , de003_1 varchar2(2)
    , brand               varchar2(8) not null
    , ird               varchar2(2) not null
    , primary key (
       arrangement_code
       , arrangement_type
       , mti
       , de024
       , de003_1
       , brand
       , ird
    )
)
organization index
/
alter table mcw_proc_code_ird add (paypass_ind  varchar2(1 byte))
/
comment on column mcw_proc_code_ird.paypass_ind is 'Issuer PayPass Indicator'
/

comment on table mcw_proc_code_ird is 'This table contains list of IRD associated with brand and operation type'
/

comment on column mcw_proc_code_ird.arrangement_code is 'The business service arrangement ID'
/

comment on column mcw_proc_code_ird.arrangement_type is 'The business service arrangement type'
/

comment on column mcw_proc_code_ird.mti is 'Message T ype Identifier'
/

comment on column mcw_proc_code_ird.de024 is 'Function Code'
/

comment on column mcw_proc_code_ird.de003_1 is 'Cardholder Transaction Type'
/

comment on column mcw_proc_code_ird.brand is 'The card program identifier value pertaining to the interchange fee group'
/

comment on column mcw_proc_code_ird.ird is 'Interchange Rate Designator'
/
 