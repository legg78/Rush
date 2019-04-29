create or replace force view cst_mpu_card_vw as
select c.id
     , c.card_number
  from cst_mpu_card c
/
