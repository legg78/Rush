create or replace force view com_address_vw as
select id
     , seqnum
     , lang
     , country
     , region
     , city
     , street
     , house
     , apartment
     , postal_code
     , region_code
     , latitude
     , longitude
     , inst_id
     , place_code
     , comments
  from com_address
/ 