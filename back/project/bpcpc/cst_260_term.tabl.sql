create table cst_260_term (
    rn                   number
  , inst_id              number(4, 0)
  , agent_id             number(8, 0)
  , region_code          varchar2(3 char)
  , terminal_type        varchar2(8 char)
  , terminal_id          number(8, 0)
  , terminal_number      varchar2(8 char)
  , start_date           date
  , end_date             date
  , postal_code          varchar2(10 char)
  , postal_address       varchar2(4000 char)
  , placement_type       varchar2(4000 char)
  , property_indicator   char(1 char)
  , fiscal_number        varchar2(1 char)
  , phone_number         varchar2(200 char)
)
/
comment on table cst_260_term is 'Terminals'
/
comment on column cst_260_term.rn is 'Row number'
/
comment on column cst_260_term.inst_id is 'Institution ID'
/
comment on column cst_260_term.agent_id is 'Agent ID'
/
comment on column cst_260_term.region_code is 'Region code'
/
comment on column cst_260_term.terminal_type is 'Terminal type'
/
comment on column cst_260_term.terminal_id is 'Terminal ID'
/
comment on column cst_260_term.terminal_number is 'Terminal number'
/
comment on column cst_260_term.start_date is 'Start date'
/
comment on column cst_260_term.end_date is 'End date'
/
comment on column cst_260_term.postal_code is 'Postal code'
/
comment on column cst_260_term.postal_address is 'Postal address'
/
comment on column cst_260_term.placement_type is 'Placement type'
/
comment on column cst_260_term.property_indicator is 'Property indicator'
/
comment on column cst_260_term.fiscal_number is 'Fiscal number'
/
comment on column cst_260_term.phone_number is 'Phone number'
/
alter table cst_260_term modify (terminal_number varchar2(16))
/

