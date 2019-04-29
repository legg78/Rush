create or replace force view prc_session_file_vw as
select
    a.id
    , a.session_id
    , a.file_attr_id
    , a.file_name
    , a.file_date
    , a.record_count
    , a.crc_value
    , a.status
    , a.file_contents
    , a.file_bcontents
    , a.file_xml_contents
    , a.file_type
    , a.thread_number
    , a.object_id
    , a.entity_type
from
    prc_session_file a
/
