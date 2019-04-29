create or replace force view com_ui_address_vw as
select a.id
     , a.lang
     , a.country
     , a.region
     , a.city
     , a.street
     , a.house
     , a.apartment
     , a.postal_code
     , a.region_code
     , a.seqnum
     , com_api_address_pkg.get_address_string(
           i_address_id   => a.id
         , i_lang         => a.lang
         , i_enable_empty => 1
       ) address_string
     , case when a.latitude is not null and a.longitude is not null
            then 'N'||to_char(a.latitude, 'FM990.00000')||', W'||to_char(a.longitude, 'FM990.00000')
            else null
       end coord_label
     , case when a.latitude is not null and a.longitude is not null
            then 'http://maps.google.com/maps?t=h&z=18&q=loc:'||to_char(a.latitude, 'FM990.00000')||','||to_char(a.longitude, 'FM990.00000')
            else null
       end coord_link
     , a.latitude
     , a.longitude
     , a.inst_id
     , a.place_code
  from com_address a
  where a.inst_id = get_user_sandbox
/
