create table frp_suite_case (
    suite_id number(4)
  , case_id  number(4)
  , priority number(4)
)
/

comment on table frp_suite_case is 'Cases included into suite.'
/

comment on column frp_suite_case.suite_id is 'Reference to suite.'
/

comment on column frp_suite_case.case_id is 'Reference to fraud case.'
/

comment on column frp_suite_case.priority is 'Case execution priority in suite.'
/