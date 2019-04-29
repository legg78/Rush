create table frp_case_event (
    id                  number(4)
  , seqnum              number(4)
  , case_id             number(4)
  , event_type          varchar2(8)
  , resp_code           varchar2(8)
  , risk_threshold      number(4))
/


comment on table frp_case_event is 'Events could be raised due case execution.'
/

comment on column frp_case_event.id is 'Primary key.'
/

comment on column frp_case_event.seqnum is 'Sequential number of data record version.'
/

comment on column frp_case_event.case_id is 'Reference to fraud case.'
/

comment on column frp_case_event.event_type is 'Fraud event type.'
/

comment on column frp_case_event.resp_code is 'Authorization response code returning if such event detected.'
/

comment on column frp_case_event.risk_threshold is 'Event risk lower threshold.'
/