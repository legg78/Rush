create table com_version(
    version_number      varchar2(200)
  , build_date          date
  , install_date        date
)
/

comment on table com_version is 'List of system versions.'
/

comment on column com_version.version_number is 'Number of system version.'
/

comment on column com_version.build_date is 'Date of build.'
/

comment on column com_version.install_date is 'Release installation date.'
/
alter table com_version add part_name varchar2(8)
/
comment on column com_version.part_name is 'Part of build.'
/
alter table com_version add revision number(12)
/
comment on column com_version.revision is 'SVN revision.'
/
alter table com_version add git_revision varchar2(40)
/
comment on column com_version.git_revision is 'GIT revision'
/
alter table com_version add release varchar2(8)
/
comment on column com_version.release is 'PA DSS release number'
/
