create or replace force view com_array_element_vw as
select id
     , seqnum
     , array_id
     , element_value
     , element_number
     , numeric_value
  from com_array_element
/