create or replace force view com_array_conversion_vw as
select id
     , seqnum
     , in_array_id
     , in_lov_id
     , out_array_id
     , out_lov_id
     , conv_type
  from com_array_conversion
/