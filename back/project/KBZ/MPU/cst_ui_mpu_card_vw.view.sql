create or replace force view cst_ui_mpu_card_vw as
select c.id
     , c.card_number
     , l.lang
  from cst_mpu_card c
     , com_language_vw l
/
