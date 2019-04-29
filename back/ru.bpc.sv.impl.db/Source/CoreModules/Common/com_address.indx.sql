create index com_address_postal_code_ndx on com_address (postal_code)
/

create index com_address_city_street_ndx on com_address (city, street, house)
/