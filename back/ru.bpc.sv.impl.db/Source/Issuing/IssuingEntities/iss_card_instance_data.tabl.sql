create table iss_card_instance_data (
    card_instance_id    number(12)
    , pvv               number(4)
    , kcolb_nip         varchar2(16)
    , pvk_index         number(4)
    , pin_block_format  varchar2(8)
    , old_pvv           number(4)
)
/
comment on table iss_card_instance_data is 'Card instance sensitive data'
/
comment on column iss_card_instance_data.card_instance_id is 'Card instance identifier'
/
comment on column iss_card_instance_data.pvv is 'Pin offset or PVV'
/
comment on column iss_card_instance_data.kcolb_nip is 'Kcolb nip'
/
comment on column iss_card_instance_data.pvk_index is 'PVK Index used for PVV generation'
/
comment on column iss_card_instance_data.pin_block_format is 'Format of PIN block generated'
/
comment on column iss_card_instance_data.old_pvv is 'Old value pin offset or PVV'
/
alter table iss_card_instance_data add pvv_change_id number(16)
/
comment on column iss_card_instance_data.pvv_change_id is 'Transaction identifier which changed when PVV'
/
alter table iss_card_instance_data add pin_offset number(12)
/
comment on column iss_card_instance_data.pin_offset is 'Pin offset'
/
alter table iss_card_instance_data rename column pin_offset to obsolete_column_pin_offset
/
alter table iss_card_instance_data add (pin_offset varchar2(12))
/
begin
    update iss_card_instance_data set pin_offset = to_char(obsolete_column_pin_offset);
    commit;
end;
/
comment on column iss_card_instance_data.obsolete_column_pin_offset is 'Pin offset (obsolete column)'
/
comment on column iss_card_instance_data.pin_offset is 'Pin offset'
/
