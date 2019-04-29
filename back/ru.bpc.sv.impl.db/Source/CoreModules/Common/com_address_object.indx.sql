create index com_address_object_ndx on com_address_object(
    object_id
)
/

drop index com_address_object_ndx
/

create index com_address_object_addr_id_ndx on com_address_object (address_id)
/