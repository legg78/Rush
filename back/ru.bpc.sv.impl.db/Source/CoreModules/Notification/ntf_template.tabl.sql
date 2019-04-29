create table ntf_template (
    id                    number(8)
    , seqnum              number(4)
    , notif_id            number(4)
    , channel_id          number(4)
    , lang                varchar2(8)
    , report_template_id  number(8)
)
/
comment on table ntf_template is 'Notification templates.'
/
comment on column ntf_template.id is 'Primary key.'
/
comment on column ntf_template.seqnum is 'Data version sequencial number.'
/
comment on column ntf_template.notif_id is 'Reference to notification.'
/
comment on column ntf_template.channel_id is 'Reference to delivery channel.'
/
comment on column ntf_template.lang is 'Language of template.'
/
comment on column ntf_template.report_template_id is 'Message template for reports generation system.'
/
