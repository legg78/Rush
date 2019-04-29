create or replace force view prc_ui_launch_parameter_vw as
select b.id as param_id
     , a.id as process_id
     , b.param_name
     , b.data_type
     , nvl(f.lov_id, b.lov_id) as lov_id
     , f.default_value
     , f.is_mandatory
     , get_text('prc_parameter', 'label', b.id, c.lang)         as label
     , coalesce(get_text('prc_process_parameter', 'description', f.id, c.lang), get_text('prc_parameter', 'description', b.id, c.lang))   as description
     , get_number_value(b.data_type, f.default_value)           as default_number_value
     , get_char_value  (b.data_type, f.default_value)           as default_char_value
     , get_date_value  (b.data_type, f.default_value)           as default_date_value
     , get_lov_value   (b.data_type, f.default_value, b.lov_id) as default_lov_value
     , c.lang
     , f.process_id proc_id
     , f.display_order
     , t.exec_order
     , t.visual_exec_order
     , b.parent_id
     , (select p.param_name  from prc_parameter p where p.id = b.parent_id) as parent_name
     , (select p.data_type   from prc_parameter p where p.id = b.parent_id) as parent_type
     , (select p.param_value from prc_parameter_value p where p.container_id = t.container_id and p.param_id = b.parent_id) as parent_value
  from prc_process a
     , prc_parameter b
     , prc_process_parameter f
     , com_language_vw c
     , (
        select container_process_id
             , e.param_id
             , d.process_id
             , d.exec_order
             , d.visual_exec_order
             , d.id as container_id
          from (
                select id
                     , connect_by_root(container_process_id)                         as container_process_id
                     , process_id
                     , substr(sys_connect_by_path(exec_order, '.'), 2)               as visual_exec_order
                     , substr(sys_connect_by_path(lpad(exec_order, 4, '0'), '.'), 2) as exec_order
                  from prc_container
                connect by
                    container_process_id = prior process_id
               ) d
             , prc_process_parameter e
         where d.process_id = e.process_id
           and not exists (
                           select null
                             from prc_parameter_value f
                            where f.container_id = d.id
                              and f.param_id     = e.param_id
                          )
       ) t
 where a.is_container    = 1
   and f.param_id        = b.id
   and a.id              = t.container_process_id
   and b.id              = t.param_id
   and f.process_id      = t.process_id
union all
select p.id as param_id
     , c.container_process_id as process_id
     , p.param_name
     , p.data_type
     , p.lov_id
     , p.default_value
     , p.is_mandatory
     , p.label
     , p.description
     , p.default_number_value
     , p.default_char_value
     , p.default_date_value
     , p.default_lov_value
     , p.lang
     , c.process_id as proc_id
     , p.display_order
     , c.exec_order
     , c.visual_exec_order
     , to_number(null) as parent_id
     , to_char(null)   as parent_name
     , to_char(null)   as parent_type
     , to_char(null)   as parent_value
  from prc_file f
  join prc_ui_file_attribute_vw a on f.id           = a.file_id
  join rpt_ui_parameter_vw p      on a.report_id    = p.report_id 
  join (
           select id
                , connect_by_root(container_process_id)                         as container_process_id
                , process_id
                , substr(sys_connect_by_path(exec_order, '.'), 2)               as visual_exec_order
                , substr(sys_connect_by_path(lpad(exec_order, 4, '0'), '.'), 2) as exec_order
             from prc_container
           connect by container_process_id = prior process_id
       ) c                        on a.container_id = c.id
  left join prc_parameter_value v on a.container_id = v.container_id and p.id = v.param_id 
 where f.file_nature  = 'FLNT0040'
   and not exists (
                   select null
                     from prc_parameter_value f
                    where f.container_id = a.container_id
                      and f.param_id     = p.id
                  )
/
