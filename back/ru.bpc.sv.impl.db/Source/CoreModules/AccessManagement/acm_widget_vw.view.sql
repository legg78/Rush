create or replace force view acm_widget_vw as
select id
     , seqnum
     , path
     , css_name
     , is_external
     , width
     , height
     , priv_id
     , params_path
  from acm_widget
/