delete app_type where appl_type = 'APTPPRDT'
/
insert into app_type (appl_type, module_code, xsd_source) values ('APTPPRDT', 'PRD', NULL)
/
update app_type set appl_type = 'APTPIPRD' where appl_type = 'APTPPRDT'
/

