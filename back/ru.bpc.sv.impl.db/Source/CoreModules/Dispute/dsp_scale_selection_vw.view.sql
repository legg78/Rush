create or replace force view dsp_scale_selection_vw as
select d.id
     , d.seqnum
     , d.scale_type
     , d.mod_id
     , d.init_rule_id
  from dsp_scale_selection d
/
