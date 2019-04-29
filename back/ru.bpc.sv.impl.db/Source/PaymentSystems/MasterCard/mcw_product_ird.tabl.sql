create table mcw_product_ird (
    arrangement_code  varchar2(8) not null
    , arrangement_type  varchar2(1) not null
    , product_id        varchar2(3) not null
    , brand               varchar2(8) not null
    , ird               varchar2(2) not null
    , primary key (
       arrangement_code
       , arrangement_type
       , product_id
       , brand
       , ird
    )
)
organization index
/


comment on table mcw_product_ird is 'Card Program Identifier and Product Restrictions'
/

comment on column mcw_product_ird.arrangement_code is 'The business service arrangement ID'
/

comment on column mcw_product_ird.arrangement_type is 'The business service arrangement type'
/

comment on column mcw_product_ird.product_id is 'The three-position GCMS Product IDs that are valid for the card program identifier, business service arrangement type, business service ID code, and IRD.'
/

comment on column mcw_product_ird.brand is 'The card program identifier value pertaining to the interchange fee group'
/
