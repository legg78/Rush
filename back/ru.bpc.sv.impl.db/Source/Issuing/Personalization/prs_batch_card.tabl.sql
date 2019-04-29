create table prs_batch_card (
    id                     number(12) not null
    , batch_id             number(8)
    , process_order        number(4)
    , card_instance_id     number(12)
    , pin_request          varchar2(8)
    , pin_generated        number(1)
    , pin_mailer_request   varchar2(8)
    , pin_mailer_printed   number(1)
    , embossing_request    varchar2(8)
    , embossing_done       number(1)
)
/
comment on table prs_batch_card is 'Cards in batch for personalisation purpose'
/
comment on column prs_batch_card.id is 'Cards in batch identifier'
/
comment on column prs_batch_card.batch_id is 'Batch identifier'
/
comment on column prs_batch_card.process_order is 'Process order'
/
comment on column prs_batch_card.card_instance_id is 'Card instance identifier'
/
comment on column prs_batch_card.pin_request is 'Requesting action about pin generation'
/
comment on column prs_batch_card.pin_generated is 'PIN generated'
/
comment on column prs_batch_card.pin_mailer_request is 'Requesting action about pin mailer printing'
/
comment on column prs_batch_card.pin_mailer_printed is 'PIN mailer printed'
/
comment on column prs_batch_card.embossing_request is 'Requesting action about plastic embossing'
/
comment on column prs_batch_card.embossing_done is 'Plastic embossing'
/
