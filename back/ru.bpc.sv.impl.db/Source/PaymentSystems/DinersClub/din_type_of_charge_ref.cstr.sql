alter table din_type_of_charge_ref add (constraint din_type_of_charge_ref_pk primary key (id))
/
alter table din_type_of_charge_ref add (constraint din_type_of_charge_ref_uk unique (type_of_charge))
/
