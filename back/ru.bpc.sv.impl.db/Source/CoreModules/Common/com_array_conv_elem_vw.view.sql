create or replace force view com_array_conv_elem_vw as
select id
     , conv_id
     , in_element_value
     , out_element_value
  from com_array_conv_elem
/ 