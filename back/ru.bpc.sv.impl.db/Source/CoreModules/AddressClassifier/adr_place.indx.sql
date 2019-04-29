create index adr_place_place_code_ndx on adr_place (place_code, comp_level)
/

create index adr_place_postal_ndx on adr_place(postal_code asc)
/

create index adr_place_parent_ndx on adr_place (parent_id)
/