create or replace force view prc_file_vw as
select
    a.id
    , a.process_id
    , a.file_purpose
    , a.saver_class
    , a.file_nature
    , a.xsd_source
    , a.file_type
    , a.saver_id
from
    prc_file a
/
