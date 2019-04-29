alter table rpt_document_content add constraint rpt_document_content_pk primary key (id) using index
/
alter table rpt_document_content add constraint rpt_document_content_uk unique(document_id, content_type) using index
/
