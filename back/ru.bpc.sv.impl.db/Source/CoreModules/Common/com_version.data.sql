update com_version set part_name = 'PARTCORE' where part_name is null
/
update com_version set release = '2.2.10' where release is null
/
insert into com_version (version_number, build_date, install_date, part_name, revision, git_revision, release) values ('2.2.22', to_date('2017.03.30 00:00:00', 'yyyy.mm.dd hh24:mi:ss'), to_date('2017.03.30 00:00:00', 'yyyy.mm.dd hh24:mi:ss'), 'PARTPDSS', NULL, 'absent', '2.2.22')
/
