create table din_type_of_charge_impact(
    type_of_charge               varchar2(2)
  , impact                       number(1)
)
/

comment on table din_type_of_charge_impact is 'Reference table for detection credit/debit impact for types of charge'
/
comment on column din_type_of_charge_impact.type_of_charge is 'Type of charge [TYPCH]'
/
comment on column din_type_of_charge_impact.impact is 'Impact of a type of charge (-1 — debit / 1 — credit)'
/

comment on table din_type_of_charge_impact is 'Obsolete, may be deleted'
/
