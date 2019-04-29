create or replace force view prs_batch_card_vw as
select 
    n.id
    , n.batch_id
    , n.process_order
    , n.card_instance_id
    , n.pin_request
    , n.pin_generated
    , n.pin_mailer_request
    , n.pin_mailer_printed
    , n.embossing_request
    , n.embossing_done
from 
    prs_batch_card n
/
