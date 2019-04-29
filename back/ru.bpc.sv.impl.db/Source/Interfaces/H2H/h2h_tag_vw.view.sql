create or replace force view h2h_tag_vw as
select id
     , t.seqnum
     , t.tag
     , t.fe_tag_id
     , t.mcw_field
     , t.vis_field
     , t.jcb_field
     , t.din_field
     , t.amx_field
     , t.mup_field
  from h2h_tag t
/
