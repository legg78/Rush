create unique index com_state_holiday_pk on com_state_holiday(id)
/

alter table com_state_holiday add (constraint com_state_holiday_pk primary key(id))
/