create table scr_bucket (
    id                number(12) not null
  , account_id        number(12)
  , customer_id       number(12)
  , revised_bucket    varchar2(2)
  , eff_date          date
  , expir_date        date
  , valid_period      number(3)
  , reason            varchar2(128)
  , user_id           varchar2(32)
)
/
comment on table scr_bucket is 'Scoring bucket'
/
comment on column scr_bucket.id is 'Primary key'
/
comment on column scr_bucket.account_id is 'Account identifier'
/
comment on column scr_bucket.customer_id is 'Customer identifier'
/
comment on column scr_bucket.revised_bucket is 'Manually bucket to update to SV'
/
comment on column scr_bucket.eff_date is 'The date manually bucket is effective'
/
comment on column scr_bucket.expir_date is 'The date manually bucket is expire'
/
comment on column scr_bucket.valid_period is 'Period that manually bucket is effective'
/
comment on column scr_bucket.reason is 'Reason to adjust bucket'
/
comment on column scr_bucket.user_id is 'Person in charge of revising bucket'
/
alter table scr_bucket add (log_date date)
/
