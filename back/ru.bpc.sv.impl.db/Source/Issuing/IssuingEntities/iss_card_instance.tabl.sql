create table iss_card_instance (
    id                          number(12) not null
    , split_hash                number(4)
    , card_id                   number(12)
    , seq_number                number(4)
    , state                     varchar2(8)
    , reg_date                  date
    , iss_date                  date
    , start_date                date
    , expir_date                date
    , cardholder_name           varchar2(200)
    , company_name              varchar2(200)
    , pin_request               varchar2(8)
    , pin_mailer_request        varchar2(8)
    , embossing_request         varchar2(8)
    , status                    varchar2(8)
    , perso_priority            varchar2(8)
    , perso_method_id           number(4)
    , bin_id                    number(8)
    , inst_id                   number(4)
    , agent_id                  number(8)
    , blank_type_id             number(4)
    , icc_instance_id           number(12)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/

/
comment on column iss_card_instance.id is 'Card instance identifier'
/
comment on column iss_card_instance.split_hash is 'Hash value to split processing'
/
comment on column iss_card_instance.card_id is 'Card identifier'
/
comment on column iss_card_instance.seq_number is 'Card instance sequential number'
/
comment on column iss_card_instance.state is 'Card instance state'
/
comment on column iss_card_instance.reg_date is 'Card instance registration date'
/
comment on column iss_card_instance.iss_date is 'Card instance issuing date'
/
comment on column iss_card_instance.start_date is 'Card instance start date'
/
comment on column iss_card_instance.expir_date is 'Card instance expiration date'
/
comment on column iss_card_instance.cardholder_name is 'Embossed cardholder name'
/
comment on column iss_card_instance.company_name is 'Embossed company name'
/
comment on column iss_card_instance.pin_request is 'Requesting action about PIN generation'
/
comment on column iss_card_instance.pin_mailer_request is 'Requesting action about PIN mailer printing'
/
comment on column iss_card_instance.embossing_request is 'Requesting action about plastic embossing'
/
comment on column iss_card_instance.status is 'Card instance status for processing'
/
comment on column iss_card_instance.perso_priority is 'Personalization priority'
/
comment on column iss_card_instance.perso_method_id is 'Identifier of personalization method'
/
comment on column iss_card_instance.bin_id is 'Issuing bin identifier'
/
comment on column iss_card_instance.inst_id is 'Institution identifier'
/
comment on column iss_card_instance.agent_id is 'Agent which ordered a card'
/
comment on column iss_card_instance.blank_type_id is 'Identifier of blank for card embossing'
/
comment on column iss_card_instance.icc_instance_id is 'Parent icc card instance identifier'
/
alter table iss_card_instance enable row movement
/
alter table iss_card_instance add (delivery_channel varchar2(8))
/
comment on column iss_card_instance.delivery_channel is 'Card delivery channel (dictionary CRDC)'
/
alter table iss_card_instance add (preceding_card_instance_id number(12))
/
comment on column iss_card_instance.preceding_card_instance_id is 'Id of a preceding card''s instance (for reissuing)'
/
alter table iss_card_instance add (reissue_reason varchar2(8))
/
comment on column iss_card_instance.reissue_reason is 'Reason of reissuing defines reissue command and reissuing flags (EVNT dictionary)'
/
alter table iss_card_instance add (reissue_date date)
/
comment on column iss_card_instance.reissue_date is 'Date of card''s instance reissuing'
/
alter table iss_card_instance add (session_id number(16))
/
comment on column iss_card_instance.session_id is 'Session id of a process which provided a card''s instance reissuing'
/

alter table iss_card_instance add (card_uid varchar2(200))
/
comment on column iss_card_instance.card_uid is 'Unique identification number of card instance'
/
alter table iss_card_instance add delivery_ref_number varchar2(200)
/
comment on column iss_card_instance.delivery_ref_number is 'Delivery tracking reference number'
/
alter table iss_card_instance add delivery_status varchar2(8)
/
comment on column iss_card_instance.delivery_status is 'Card delivery status (dictionary CRDS)'
/
alter table iss_card_instance add embossed_surname varchar2(200)
/
comment on column iss_card_instance.embossed_surname is 'Cardholder Surname (for embossing)'
/
alter table iss_card_instance add embossed_first_name varchar2(200)
/
comment on column iss_card_instance.embossed_first_name is 'Cardholder First Name (for embossing)'
/
alter table iss_card_instance add embossed_second_name varchar2(200)
/
comment on column iss_card_instance.embossed_second_name is 'Cardholder Middle Name (for embossing)'
/
alter table iss_card_instance add embossed_title varchar2(8)
/
comment on column iss_card_instance.embossed_title is 'Cardholder Title (for embossing)'
/
alter table iss_card_instance add embossed_line_additional varchar2(200)
/
comment on column iss_card_instance.embossed_line_additional is 'Additional line (for embossing)'
/
alter table iss_card_instance add cardholder_photo_file_name varchar2(255)
/
comment on column iss_card_instance.cardholder_photo_file_name is 'Name of file with card holder photography'
/
alter table iss_card_instance add cardholder_sign_file_name varchar2(255)
/
comment on column iss_card_instance.cardholder_sign_file_name is 'Name of file with card holder signature sample'
/
alter table iss_card_instance add supplementary_info_1 varchar2(200)
/
comment on column iss_card_instance.supplementary_info_1 is 'Supplementary Info 1'
/
alter table iss_card_instance add is_last_seq_number number(1)
/
comment on column iss_card_instance.is_last_seq_number is 'If Card instance sequential number is last then 1 else 0'
/
