create or replace force view app_flow_filter_vw as
select a.id
     , a.seqnum
     , a.stage_id
     , a.struct_id
     , a.min_count
     , a.max_count
     , a.is_visible
     , a.is_updatable
     , a.is_insertable
     , a.default_value
  from app_flow_filter a
/
