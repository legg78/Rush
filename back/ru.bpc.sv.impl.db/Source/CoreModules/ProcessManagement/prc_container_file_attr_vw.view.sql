create or replace force view prc_container_file_attr_vw as
select pfa.characterset
     , pfa.file_name_mask
     , pfa.name_format_id
     , pc.container_process_id
     , pd.directory_path
     , pf.file_type
     , pf.file_purpose
     , pf.saver_id
     , pc.process_id 
     , pfa.line_separator
  from prc_file_attribute pfa, 
       prc_container pc,
       prc_directory pd,
       prc_file pf
 where pfa.container_id = pc.id
   and pc.process_id = pf.process_id
   and pfa.location_ID = pd.id(+)
/