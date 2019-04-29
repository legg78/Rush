create table rpt_document_type (
    id            number(4) 
  , document_type varchar2(8) 
  , content_type  varchar2(8) 
  , is_report     number(1)
)
/

comment on table  rpt_document_type is 'Document types and parts of documents'
/
comment on column rpt_document_type.id is 'Primary key'
/
comment on column rpt_document_type.document_type is 'Document type'
/
comment on column rpt_document_type.content_type is 'Document part type'
/
comment on column rpt_document_type.is_report is 'If document generates by report'
/
