alter table mup_currency_rate add constraint mup_currency_rate_pk primary key(id)
/
alter table mup_currency_rate add (constraint mup_currency_rate_uk unique (rates_date, base_curr_code, curr_code))
/
