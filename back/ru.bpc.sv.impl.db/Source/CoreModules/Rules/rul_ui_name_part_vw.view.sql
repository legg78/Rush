create or replace force view rul_ui_name_part_vw as
select
    a.id
    , a.format_id
    , a.part_order
    , a.base_value_type
    , a.base_value
    , a.transformation_type
    , a.transformation_mask
    , a.part_length
    , a.pad_type
    , a.pad_string
    , b.prpt_value
    , a.check_part
from
    rul_name_part a
    , (select
           v.part_id
           , substr(replace(sys_connect_by_path(v.property,'_~!@#$%^&*()_'),'_~!@#$%^&*()_',';'),2) prpt_value
       from (
           select
               row_number() over(partition by t.part_id order by t.property) rn
               , t.part_id
               , t.property
               , count(*) over(partition by t.part_id) cnt
           from (
               select
                   b.part_id
                   , a.property_name || '=' || b.property_value property
               from 
                   rul_name_part_prpt a
                   , rul_name_part_prpt_value_vw b
               where 
                   a.id = b.property_id
           ) t
       ) v
       where
          v.rn = v.cnt
       start with v.rn = 1
       connect by prior v.rn = v.rn - 1
          and prior v.part_id = v.part_id
       order by v.part_id
    ) b
where
    a.id = b.part_id(+)
/
