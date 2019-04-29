create or replace force view vch_ui_card_number_vw as
select voucher_id
     , iss_api_token_pkg.decode_card_number(i_card_number => card_number) as card_number
  from vch_card_number
/