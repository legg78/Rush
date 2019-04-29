create or replace force view frp_ui_matrix_value_vw as 
select id
     , seqnum
     , matrix_id
     , x_value
     , y_value               
     , matrix_value
  from frp_matrix_value
/
