create or replace force view prc_ui_container_parameter_vw as
select b.id as param_id
     , a.id as process_id
     , b.param_name
     , b.data_type
     , b.lov_id
     , b.parent_id
     , get_text('prc_parameter', 'label', b.id, c.lang) as label
     , get_text('prc_parameter', 'description', b.id, c.lang) as description
     , c.lang
  from prc_process_vw a
     , prc_parameter_vw b
     , com_language_vw c
 where a.is_container = 1
   and (a.id, b.id) in (
        select container_process_id, e.param_id
          from (
                select connect_by_root(container_process_id) container_process_id
                     , process_id
                  from prc_container
                  connect by prior container_process_id = process_id
               ) d
             , prc_process_parameter e
         where d.process_id = e.process_id
       )
/
