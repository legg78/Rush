create or replace force view prd_attribute_scale_vw as
select
    n.id
    , n.seqnum
    , n.attr_id
    , n.inst_id
    , n.scale_id
from
    prd_attribute_scale n
/
