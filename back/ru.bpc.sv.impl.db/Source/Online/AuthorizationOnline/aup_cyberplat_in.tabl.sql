create table aup_cyberplat_in (
    auth_id          number(16)
    , tech_id        varchar2(36)
    , action         varchar2(7)
    , subscr_number  varchar2(30)
    , pmt_type       number(3)
    , amount         number(22, 4)
    , receipt        varchar2(128)
    , mes            number(3)
    , addl           varchar2(2000)
    , code           number(2)
    , oper_date      date
    , authcode       number(15)
    , time_mark      varchar2(16)
    , is_response    number(1)
    , device_id      number(8)
    , part_key       as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition aup_cyberplat_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))     -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_cyberplat_in.action is 'Request type. Valid values are check,payment, cancel, status.'
/
comment on column aup_cyberplat_in.addl is 'Additional data from agent or additional date to agent in accordance with message direction.'
/
comment on column aup_cyberplat_in.amount is 'Amount of payment. '
/
comment on column aup_cyberplat_in.authcode is 'Unique payment identifier assigned by service provider.'
/
comment on column aup_cyberplat_in.auth_id is 'Authorization id assigned to operation.'
/
comment on column aup_cyberplat_in.code is 'Response code. Valid values are ''-3'' - ''99''.'
/
comment on column aup_cyberplat_in.is_response is 'Flag shows if the record belongs to system response or request.'
/
comment on column aup_cyberplat_in.mes is 'Cancellation reason identifier.'
/
comment on column aup_cyberplat_in.oper_date is 'Operation date and time.'
/
comment on column aup_cyberplat_in.pmt_type is 'Payment type.'
/
comment on column aup_cyberplat_in.receipt is 'Unique payment number provided by payment agent. It is used to match cancel and status requests from agent with payment requests.'
/
comment on column aup_cyberplat_in.subscr_number is 'Subscriber number, i.e. account number of customer.'
/
comment on column aup_cyberplat_in.tech_id is 'Technical identifier of the message.'
/
comment on column aup_cyberplat_in.time_mark is 'Timestamp of record insertion into database.'
/
comment on table aup_cyberplat_in is 'Table is used to store incoming cyberplat-based requests.'
/
comment on column aup_cyberplat_in.device_id is 'Identifier of device that is associated with payment agent system.'
/
