create table lty_lottery_ticket (
    id                   number(16)
  , part_key             as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , seqnum               number(4)
  , split_hash           number(4)
  , customer_id          number(12)
  , card_id              number(12)
  , service_id           number(8)
  , ticket_number        varchar2(200)
  , registration_date    date
  , status               varchar2(8)
  , inst_id              number(4) 
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition lty_lottery_ticket_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table lty_lottery_ticket is 'Lottery ticket.'
/
comment on column lty_lottery_ticket.id is 'Primary key.'
/
comment on column lty_lottery_ticket.seqnum is 'Sequential number of data version.'
/
comment on column lty_lottery_ticket.split_hash is 'Hash value to split further processing.'
/
comment on column lty_lottery_ticket.customer_id is 'Customer identifier.'
/
comment on column lty_lottery_ticket.card_id is 'Card identifier.'
/
comment on column lty_lottery_ticket.service_id is 'Loyalty service identifier.'
/
comment on column lty_lottery_ticket.ticket_number is 'Lottery ticket number.'
/
comment on column lty_lottery_ticket.registration_date is 'Lottery ticket registration date.'
/
comment on column lty_lottery_ticket.status is 'Lottery ticket status (Active, Closed).'
/
comment on column lty_lottery_ticket.inst_id is 'Institution identifier.'
/
