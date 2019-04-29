create or replace force view com_ui_person_info_vw as
select
    p.id
    , p.lang
    , p.title
    , p.first_name
    , p.second_name
    , p.surname
    , p.suffix
    , p.gender
    , p.birthday
    , p.place_of_birth
    , p.seqnum
    , d.id doc_id
    , d.id_type
    , d.id_series
    , d.id_number
    , a.address_type
    , a.adr_id
    , a.country
    , a.region
    , a.city
    , a.street
    , a.house
    , a.apartment
    , a.postal_code
    , a.region_code
from
    com_person_vw p
    , ( select
            x.object_id
            , x.id
            , x.id_type
            , x.id_series
            , x.id_number
            , row_number() over(partition by object_id order by x.id desc) rn
        from
            com_id_object x 
        where
            x.entity_type = 'ENTTPERS'
    ) d
    , ( select
            x.object_id
            , x.address_id
            , row_number() over (partition by object_id order by x.id desc) rn
            , x.address_type
            , a.id adr_id
            , a.lang adr_lang
            , a.country
            , a.region
            , a.city
            , a.street
            , a.house
            , a.apartment
            , a.postal_code
            , a.region_code
        from
            com_address_object x
            , com_address a
        where
            x.entity_type = 'ENTTPERS'
            and a.id = x.address_id
    ) a
where
    p.id = d.object_id(+)
    and d.rn(+) = 1
    and a.object_id(+) = p.id
    and a.rn(+) = 1
    and a.adr_lang(+) = p.lang
/
