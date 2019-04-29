create or replace force view com_ui_version_vw as
select a.version_number
     , a.build_date
     , a.install_date
     , a.revision
     , a.part_name
     , get_article_text(a.part_name, b.lang) part_name_desc
     , b.lang
     , a.git_revision
     , a.release
  from com_version a
     , com_language_vw b
/
