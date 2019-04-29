create table amx_rejected_detail (
    reject_message_id       number(16) not null
    , order_code            number(3)
    , reject_reason_code    varchar2(4) 
)
/
comment on table amx_rejected_detail is 'Reject codes for messages'
/
comment on column amx_rejected_detail.reject_message_id is 'Transaction identifier'
/
comment on column amx_rejected_detail.order_code is 'Order of code in code list '
/
comment on column amx_rejected_detail.reject_reason_code is 'Reject reason code'
/

