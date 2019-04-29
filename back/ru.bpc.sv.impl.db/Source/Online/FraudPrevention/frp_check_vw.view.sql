create or replace force view frp_check_vw as
select
    id
  , seqnum
  , case_id
  , check_type
  , alert_type
  , expression
  , risk_score
  , risk_matrix_id
from frp_check
/