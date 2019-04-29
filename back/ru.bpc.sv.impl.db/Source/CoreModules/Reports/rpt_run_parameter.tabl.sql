create table rpt_run_parameter (
    id           number(16)
  , part_key     as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , run_id       number(16)
  , param_id     number(8)
  , param_value  varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition rpt_run_parameter_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on table rpt_run_parameter is 'Logs of parameter values used for run reports.'
/
comment on column rpt_run_parameter.id is 'Primary key.'
/
comment on column rpt_run_parameter.run_id is 'Reference to report run.'
/
comment on column rpt_run_parameter.param_id is 'Reference to report parameter.'
/
comment on column rpt_run_parameter.param_value is 'Parameter value.'
/

