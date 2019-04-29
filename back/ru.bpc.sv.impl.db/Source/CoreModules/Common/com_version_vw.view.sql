create or replace force view com_version_vw as
select version_number
     , build_date
     , install_date
     , part_name
     , revision
     , git_revision
     , release
  from com_version
/
