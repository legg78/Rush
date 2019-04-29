create or replace force view frp_matrix_vw as
select
    id
  , seqnum
  , inst_id
  , x_scale
  , y_scale
  , matrix_type
from frp_matrix
/
