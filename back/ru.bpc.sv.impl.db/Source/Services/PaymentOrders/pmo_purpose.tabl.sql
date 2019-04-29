create table pmo_purpose(
    id                  number (8)
  , provider_id         number (8)
  , service_id          number (8)
  , host_algorithm      varchar2(8)
  , oper_type           varchar2(8)
  , terminal_id         number(8)
  , mcc                 varchar2(4)
)
/

comment on table pmo_purpose is 'Payment purpose (To whom and for what)'
/

comment on column pmo_purpose.id is 'Primary key'
/
comment on column pmo_purpose.provider_id is 'Reference to service provider (To whom)'
/
comment on column pmo_purpose.service_id is 'Reference to service (For what)'
/
comment on column pmo_purpose.host_algorithm is 'Algorithm of choosing payment host to implement payment order with corresponding purpose'
/
comment on column pmo_purpose.oper_type is 'Operation type should be used to create operation from order with current purpose'
/
comment on column pmo_purpose.terminal_id is 'Terminal should be used to create operation from order with current purpose'
/
comment on column pmo_purpose.mcc is 'Merchant category code should be used to create operation from order with current purpose'
/

alter table pmo_purpose add (purpose_number varchar2(200))
/
comment on column pmo_purpose.purpose_number is 'Payment purpose external number'
/

alter table pmo_purpose add (zero_order_status varchar2(8))
/
comment on column pmo_purpose.zero_order_status is 'Status of scheduled payment order with order sum equal to 0'
/
alter table pmo_purpose add (mod_id number(4))
/
comment on column pmo_purpose.mod_id is 'Modifier define availability of paying to service provider.'
/
alter table pmo_purpose add amount_algorithm varchar2(8)
/
comment on column pmo_purpose.amount_algorithm is 'Amount algorithm'
/
alter table pmo_purpose add inst_id number(4)
/
comment on column pmo_purpose.inst_id is 'Institution identifier'
/
