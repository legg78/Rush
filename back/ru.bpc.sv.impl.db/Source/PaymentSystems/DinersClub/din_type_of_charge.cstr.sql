alter table din_type_of_charge add (constraint din_type_of_charge_uk unique (is_incoming, oper_type, is_reversal, terminal_type, mcc))
/
alter table din_type_of_charge drop constraint din_type_of_charge_uk
/
alter table din_type_of_charge add (constraint din_type_of_charge_uk unique (is_incoming, oper_type, is_reversal, terminal_type, mcc, is_icc_transaction))
/
