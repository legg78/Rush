create or replace force view sec_api_host_des_key_vw as
select a.key_type,
       a.key_prefix,
       a.key_length,
       a.check_value,
       a.key_value,
       a.object_id,
       a.lmk_id
  from sec_des_key a
 where a.entity_type = 'ENTTHOST'
/

