insert into com_module (id, name, module_code, dict_code) values (60, 'Financial requests', 'FRQ', NULL)
/
update com_module set dict_code=16 where id=60
/
update com_module set module_code = 'ORQ' where id = 60
/
