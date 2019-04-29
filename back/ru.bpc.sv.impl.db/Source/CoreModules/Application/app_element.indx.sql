create unique index app_element_uk on app_element (upper(name))
/
drop index app_element_uk
/
create unique index app_element_uk on app_element (name)
/
