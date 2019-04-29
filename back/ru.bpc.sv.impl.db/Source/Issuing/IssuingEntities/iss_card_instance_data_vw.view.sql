create or replace force view iss_card_instance_data_vw as
select
    i.card_instance_id
  , i.pvv
  , i.kcolb_nip
  , i.pvk_index
  , i.pin_block_format
  , i.old_pvv
  , i.pvv_change_id
  , i.pin_offset
from
    iss_card_instance_data i
/
