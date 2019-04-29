alter table iss_cardholder add constraint iss_cardholder_pk primary key
    (id)
/
alter table iss_cardholder add constraint iss_cardholder_un unique
    (cardholder_number)
using index
/
alter table iss_cardholder drop constraint iss_cardholder_un drop index
/
