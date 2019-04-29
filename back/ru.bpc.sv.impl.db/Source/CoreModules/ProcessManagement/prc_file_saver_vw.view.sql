create or replace force view prc_file_saver_vw as
select t.id
     , t.seqnum
     , t.source
     , t.is_parallel
     , t.post_source
  from prc_file_saver t
/
