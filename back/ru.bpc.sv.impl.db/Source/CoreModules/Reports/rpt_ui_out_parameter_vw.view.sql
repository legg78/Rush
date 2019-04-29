create or replace force view rpt_ui_out_parameter_vw as
select id
     , seqnum
     , report_id
     , data_type
     , display_order
     , get_text('RPT_PARAMETER','LABEL',       p.id, l.lang) label
     , get_text('RPT_PARAMETER','DESCRIPTION', p.id, l.lang) description
     , is_grouping
     , is_sorting
     , l.lang
  from rpt_parameter p
     , com_language_vw l
  where param_name is null   
/
