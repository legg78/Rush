create or replace force view opr_ui_merchant_address_vw as
select id oper_id
     , merchant_number
     , merchant_street   || ', ' ||
       merchant_city     || ', ' ||
       merchant_region   || ', ' ||
       merchant_country  || ', ' ||
       merchant_postcode merchant_address
  from opr_operation
/
