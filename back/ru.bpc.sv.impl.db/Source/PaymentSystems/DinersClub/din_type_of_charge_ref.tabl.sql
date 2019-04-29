create table din_type_of_charge_ref(
    id                           number(4)
  , type_of_charge               varchar2(2)
  , impact                       number(1)
)
/

comment on table din_type_of_charge_ref is 'Reference table for types of charge'
/
comment on column din_type_of_charge_ref.type_of_charge is 'Type of charge [TYPCH]'
/
comment on column din_type_of_charge_ref.impact is 'Impact of a type of charge (-1 - debit / 1 - credit)'
/
