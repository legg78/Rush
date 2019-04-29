create or replace force view net_card_type_feature_vw as
select 
    n.id
    , n.seqnum
    , n.card_type_id
    , n.card_feature
from 
    net_card_type_feature n
/
