create table aup_amount
(
  auth_id      number(16),
  part_key     as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual,           -- [@skip patch]
  entity_type  varchar2(8),
  amount       number(22,4),
  currency     varchar2(3),
  amount_type  varchar2(8)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aup_amount_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))         -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_amount is 'Table is used to store authorization amounts for online authorization processing.'
/
comment on column aup_amount.auth_id is 'Authorization ID.'
/
comment on column aup_amount.entity_type is 'Type of amount entity (valid values are ENTTFEES, ENTTLIMT, ENTTBLNC).'
/
comment on column aup_amount.amount is 'Value of amount in currency.'
/
comment on column aup_amount.currency is 'Amount currency.'
/
comment on column aup_amount.amount_type is 'Type of amount that is taken from dictionaries depending on entity type ( FETP, BLTP, LMTP ).'
/
