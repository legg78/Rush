alter table din_type_of_charge_map add (constraint din_type_of_charge_map_pk primary key(id))
/ 
alter table din_type_of_charge_map add (constraint din_type_of_charge_map_uk unique (is_incoming, oper_type, is_reversal, terminal_type, mcc, is_icc_transaction))
/
