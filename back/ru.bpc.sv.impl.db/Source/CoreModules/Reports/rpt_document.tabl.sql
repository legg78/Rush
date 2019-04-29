create table rpt_document(
    id                    number(16)
  , part_key              as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual      -- [@skip patch]
  , seqnum                number(4)
  , document_type         varchar2(8)
  , document_number       varchar2(200)
  , document_date         date
  , entity_type           varchar2(8)
  , object_id             number(16)
  , inst_id               number(4)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition rpt_doc_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))            -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table rpt_document is 'Official documents. Generated as reports or loaded as scaned images.'
/

comment on column rpt_document.id is 'Primary key'
/
comment on column rpt_document.seqnum is 'Data version sequential number.'
/
comment on column rpt_document.document_type is 'Document type (Report, Image).'
/
comment on column rpt_document.document_number is 'Number of document'
/
comment on column rpt_document.document_date is 'Date of document creation'
/
comment on column rpt_document.entity_type is 'Type of entity assigned with document.'
/
comment on column rpt_document.object_id is 'Document owner object identificator'
/
comment on column rpt_document.inst_id is 'Institution identifier'
/
alter table rpt_document add start_date date
/
comment on column rpt_document.start_date is 'Document''s start date'
/
alter table rpt_document add end_date date
/
comment on column rpt_document.end_date is 'Document''s end date'
/
alter table rpt_document add status varchar2(8)
/
comment on column rpt_document.status is 'Document''s status'
/
