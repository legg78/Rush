create table aup_reversals (
    orig_auth_id        number(16)
  , rvsl_attempts_count number(8)
  , rvsl_max_count number(8)
)
/
comment on table aup_reversals is 'Table is used to store number of attempts of sending reversals.'
/
comment on column aup_reversals.orig_auth_id is 'Identifier of original authorization.'
/
comment on column aup_reversals.rvsl_attempts_count is 'Number of attempts of sending reversals for given original authorization.'
/
comment on column aup_reversals.rvsl_max_count is 'Max attempts of sending reversals for given original authorization.'
/