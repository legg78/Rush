create or replace force view opr_oper_detail_vw as
select o.id
     , o.oper_id
     , o.object_id
     , o.entity_type
  from opr_oper_detail o
/
