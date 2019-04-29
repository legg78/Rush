create table mcw_cab_program_ird (
    arrangement_type    varchar2(1)
    , arrangement_code  varchar2(8)
    , cab_program       varchar2(4)
    , brand             varchar2(3)
    , ird               varchar2(2)
)
/

comment on table mcw_cab_program_ird is 'Card Acceptor Business Program Restrictions.'
/
comment on column mcw_cab_program_ird.arrangement_type is 'The business service arrangement type.'
/
comment on column mcw_cab_program_ird.arrangement_code is 'The business service arrangement ID code.'
/
comment on column mcw_cab_program_ird.cab_program is 'Card Acceptor Business (CAB) Program.'
/
comment on column mcw_cab_program_ird.brand is 'The card program identifier associated to the account range.'
/
comment on column mcw_cab_program_ird.ird is 'Interchange rate designator value.'
/
