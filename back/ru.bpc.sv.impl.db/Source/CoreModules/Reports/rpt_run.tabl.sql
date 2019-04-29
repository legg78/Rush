create table rpt_run (
    id              number(16)
  , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , report_id       number(8)
  , start_date      date
  , finish_date     date
  , user_id         varchar2(200)
  , status          varchar2(8)
  , inst_id         number(4)
  , run_hash        varchar2(200)
  , first_run_id    number(16)
  , document_id     number(16)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))             -- [@skip patch]
(                                                                               -- [@skip patch]
    partition rpt_run_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                               -- [@skip patch]
******************** partition end ********************/
/

comment on table rpt_run is 'History of report runs.'
/
comment on column rpt_run.id is 'Primary key.'
/
comment on column rpt_run.report_id is 'Reference to report.'
/
comment on column rpt_run.start_date is 'Date of start executing report.'
/
comment on column rpt_run.finish_date is 'Date when report was finished.'
/
comment on column rpt_run.user_id is 'User identifier which run report.'
/
comment on column rpt_run.status is 'Report status (Runing, Generated, Failed).'
/
comment on column rpt_run.inst_id is 'Institution identifier.'
/
comment on column rpt_run.run_hash is 'Unique identifier of report run. Consist of parameter values passed to report run.'
/
comment on column rpt_run.first_run_id is 'Link to first run of report with same parameter values. Defined only for deterministic reports.'
/
comment on column rpt_run.document_id is 'Reference to document'
/
