alter table din_message_field add (constraint din_message_field_pk primary key (function_code, field_name))
/
alter table din_message_field drop constraint din_message_field_pk
/
alter table din_message_field add (constraint din_message_field_pk primary key (field_name, function_code))
/
