create or replace force view cup_ui_file_vw as
select
    c.id
  , c.is_incoming
  , c.is_rejected
  , c.network_id
  , c.trans_date
  , c.inst_id
  , c.inst_name
  , c.action_code
  , c.file_number
  , c.pack_no
  , c.version
  , c.crc
  , c.encoding
  , c.file_type
from cup_file c
/
