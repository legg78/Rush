create table rpt_document_content(
    id                    number(16) not null
  , part_key              as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual      -- [@skip patch]
  , document_id           number(16)
  , content_type          varchar2(8)
  , report_id             number(8)
  , template_id           number(8)
  , file_name             varchar2(200)
  , mime_type             varchar2(8)
  , save_path             varchar2(2000)
  , document_content      clob
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition rpt_document_cont_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))  -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table rpt_document_content is 'Document contents'
/

comment on column rpt_document_content.id is 'Primary key'
/
comment on column rpt_document_content.document_id is 'Reference to document'
/
comment on column rpt_document_content.content_type is 'Type of document content if document contain a few parts.'
/
comment on column rpt_document_content.report_id is 'Reference to report if document type is report'
/
comment on column rpt_document_content.template_id is 'Report teplate used for document generation'
/
comment on column rpt_document_content.file_name is 'Real file name'
/
comment on column rpt_document_content.mime_type is 'Type of data contained into file'
/
comment on column rpt_document_content.save_path is 'Path to saved file of document (contain unique auto-generated file name) '
/
comment on column rpt_document_content.document_content is 'Content'
/
