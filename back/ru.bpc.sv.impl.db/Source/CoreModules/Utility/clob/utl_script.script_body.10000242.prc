declare
    l_cnt           com_api_type_pkg.t_long_id;
begin
    update prd_product p
       set p.split_hash = com_api_hash_pkg.get_split_hash(i_value => p.id)
     where p.split_hash is null;

    update prd_service s
       set s.split_hash = com_api_hash_pkg.get_split_hash(i_value => s.id)
     where s.split_hash is null;

    commit;

    select sum(column_value)
      into l_cnt
      from table(utl_parallel_update_pkg.attribute_value_update(cursor(
              select v.entity_type
                   , v.object_id
                from prd_attribute_value v
               where v.entity_type in (prd_api_const_pkg.ENTITY_TYPE_PRODUCT)
                 and exists (select 1
                              from prd_product p
                                where p.id = v.object_id)
               union all
              select v.entity_type
                   , v.object_id
                from prd_attribute_value v
               where v.entity_type in (prd_api_const_pkg.ENTITY_TYPE_SERVICE)
           )));
end;
