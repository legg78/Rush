create table fcl_cycle_type (
    id              number(4) not null
    , cycle_type    varchar2(8)
    , is_repeating  number(1)
    , is_standard   number(1)
)
/
comment on table fcl_cycle_type is 'Cycle types.'
/
comment on column fcl_cycle_type.id is 'Primary key.'
/
comment on column fcl_cycle_type.cycle_type is 'Cycle type dictionary code'
/
comment on column fcl_cycle_type.is_repeating is 'Cycle is repeating or ad hoc.'
/
comment on column fcl_cycle_type.is_standard is 'Switch by common process or have own processor.'
/
alter table fcl_cycle_type add cycle_calc_start_date varchar2(8)
/
alter table fcl_cycle_type add cycle_calc_date_type varchar2(8)
/
comment on column fcl_cycle_type.cycle_calc_start_date is 'Cycle calculation start date'
/
comment on column fcl_cycle_type.cycle_calc_date_type is 'Cycle calculation date type'
/

