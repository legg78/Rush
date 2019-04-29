create or replace force view prs_blank_type_vw as
select n.id
     , n.card_type_id
     , n.inst_id
     , n.seqnum
     , n.is_active
     , n.is_contactless
  from prs_blank_type n
/
