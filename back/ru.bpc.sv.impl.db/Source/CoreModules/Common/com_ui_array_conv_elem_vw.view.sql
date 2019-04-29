create or replace force view com_ui_array_conv_elem_vw as
select e.id
     , e.conv_id
     , e.in_element_value
     , e.out_element_value
  from com_array_conv_elem e
/