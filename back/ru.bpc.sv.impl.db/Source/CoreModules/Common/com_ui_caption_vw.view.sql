create or replace force view com_ui_caption_vw as
select *
from com_ui_label_vw
where label_type = 'CAPTION'
/