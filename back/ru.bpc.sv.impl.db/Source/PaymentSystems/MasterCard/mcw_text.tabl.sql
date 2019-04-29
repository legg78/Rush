create table mcw_text (
    id              number(16)
    , part_key      as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual            -- [@skip patch]
    , network_id    number(4)
    , inst_id       number(4)
    , file_id       number(8)
    , mti           varchar2(4)
    , de024         varchar2(3)
    , de025         varchar2(4)
    , de071         number(7)
    , de072         varchar2(999)
    , de093         varchar2(11)
    , de094         varchar2(11)
    , de100         varchar2(11)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition mcw_text_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table mcw_text is 'Currency Update/1644 Messages'
/

comment on column mcw_text.id is 'Identifier'
/
comment on column mcw_text.inst_id is 'Receiver institution'
/
comment on column mcw_text.file_id is 'File identifier'
/
comment on column mcw_text.mti is 'Message Type Identifier'
/
comment on column mcw_text.de024 is 'Function Code'
/
comment on column mcw_text.de025 is 'Message Reason Code'
/
comment on column mcw_text.de071 is 'Message Number'
/
comment on column mcw_text.de072 is 'Data Record'
/
comment on column mcw_text.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mcw_text.de094 is 'Transaction Originator Institution ID Code'
/
comment on column mcw_text.de100 is 'Receiving Institution ID Code'
/
