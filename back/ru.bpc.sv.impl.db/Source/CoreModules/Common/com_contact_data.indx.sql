create index com_contact_data_address_ndx on com_contact_data (upper(commun_address), commun_method)
/
create index com_contact_data_contact_ndx on com_contact_data (contact_id)
/
drop index com_contact_data_address_ndx
/
alter table com_contact_data modify (commun_address varchar2(2000))
/
create index com_contact_data_address_ndx on com_contact_data (upper(commun_address), commun_method)
/
