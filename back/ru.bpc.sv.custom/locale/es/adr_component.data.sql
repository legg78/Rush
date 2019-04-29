insert into adr_component (id, lang, abbreviation, comp_name, comp_level, country_id) values (101, 'LANGESP', 'Dept', 'Department', 1, 170)
/
insert into adr_component (id, lang, abbreviation, comp_name, comp_level, country_id) values (102, 'LANGESP', NULL, 'Municipality', 2, 170)
/
update adr_component set country_id = 47 where id = 101 and lang = 'LANGESP'
/
update adr_component set country_id = 47 where id = 102 and lang = 'LANGESP'
/
