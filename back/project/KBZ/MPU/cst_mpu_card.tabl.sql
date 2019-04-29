create table cst_mpu_card (
    id           number(16)  not null
  , card_number  varchar2(19) 
)
/
comment on table cst_mpu_card is 'Card numbers'
/
comment on column cst_mpu_card.id is 'Primary key. MPU financial message identifier'
/
comment on column cst_mpu_card.card_number is 'Card number (F2)'
/
