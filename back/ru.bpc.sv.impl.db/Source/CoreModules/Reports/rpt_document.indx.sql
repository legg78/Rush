create index rpt_document_entity_object_ndx on rpt_document(entity_type, object_id)
/

create index rpt_document_number_ndx on rpt_document (document_number, trunc(document_date), document_type)
/