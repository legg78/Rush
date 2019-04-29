create table jcb_file (
    id                  number(8) not null
    , inst_id           number(4)
    , network_id        number(4)
    , is_incoming       number(1)
    , proc_date         date
    , session_file_id   number(16)
    , is_rejected       number(1)
    , reject_id         number(16)    
    , header_mti        varchar2(4)
    , header_de024      varchar2(3)
    , p3901             varchar2(25)
    , p3901_1           varchar2(3)
    , p3901_2           date
    , p3901_3           varchar2(11) 
    , p3901_4           varchar2(5)  
    , header_de071      number(8)
    , trailer_mti       varchar2(4)
    , trailer_de024     varchar2(3)
    , p3902             number(16)
    , p3903             number(8)
    , trailer_de071     number(8)
)
/

comment on table jcb_file is 'Japan Credit Bureau logical files'
/

comment on column jcb_file.id is 'Identifier'
/

comment on column jcb_file.inst_id is 'Institution identifier'
/

comment on column jcb_file.network_id is 'Network identifier'
/

comment on column jcb_file.is_incoming is 'Incoming indicator'
/

comment on column jcb_file.proc_date is 'Processing date'
/

comment on column jcb_file.session_file_id is 'Session file identifier'
/

comment on column jcb_file.is_rejected is 'Rejected idicator'
/

comment on column jcb_file.reject_id is 'Reject message identifier'
/

comment on column jcb_file.header_mti is 'The Message Type Identifier of file header'
/

comment on column jcb_file.header_de024 is 'Function Code of file header'
/

comment on column jcb_file.p3901 is 'File ID'
/

comment on column jcb_file.p3901_1 is 'File ID. File Type'
/

comment on column jcb_file.p3901_2 is 'File ID. File Reference Date'
/

comment on column jcb_file.p3901_3 is 'File ID. Processor ID'
/

comment on column jcb_file.p3901_4 is 'File ID. File Sequence Number'
/

comment on column jcb_file.header_de071 is 'Message Number of file header'
/

comment on column jcb_file.trailer_mti is 'The Message Type Identifier of file trailer'
/

comment on column jcb_file.trailer_de024 is 'Function Code of file trailer'
/

comment on column jcb_file.p3902 is 'Total Transaction Amount'
/

comment on column jcb_file.p3903 is 'Total Number of Messages'
/

comment on column jcb_file.trailer_de071 is 'Message Number of file trailer'
/

alter table jcb_file add(header_de100 varchar2(11))
/
comment on column jcb_file.header_de100 is 'Receiving Institution ID Code of file header'
/
alter table jcb_file add(trailer_de100 varchar2(11))
/
comment on column jcb_file.trailer_de100 is 'Receiving Institution ID Code of file trailer'
/
alter table jcb_file add(header_de033 varchar2(11))
/
comment on column jcb_file.header_de033 is 'Forwarding Institution ID Code of file header'
/
alter table jcb_file add(trailer_de033 varchar2(11))
/
comment on column jcb_file.trailer_de033 is 'Forwarding Institution ID Code of file trailer'
/
