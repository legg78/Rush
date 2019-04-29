alter table com_version add ( constraint com_version_pk primary key(version_number))
/
alter table com_version drop constraint com_version_pk
/
update com_version set revision = 0 where revision is null
/
alter table com_version add (constraint com_version_pk primary key(version_number,revision))
/
alter table com_version drop constraint com_version_pk cascade
/
alter table com_version add ( constraint com_version_pk primary key(version_number))
/
alter table com_version drop constraint com_version_pk cascade
/
alter table com_version add ( constraint com_version_pk primary key(version_number, part_name))
/
alter table com_version drop constraint com_version_pk cascade
/
alter table com_version add ( constraint com_version_pk primary key(version_number, part_name, git_revision))
/
