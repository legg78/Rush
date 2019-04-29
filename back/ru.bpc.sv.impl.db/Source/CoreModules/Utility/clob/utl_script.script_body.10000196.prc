begin
    merge into com_flexible_field_standard fs
    using (select ff.id
             from com_flexible_field  ff
            where ff.entity_type in (com_api_const_pkg.ENTITY_TYPE_CUSTOMER, iss_api_const_pkg.ENTITY_TYPE_CARD)
          ) d
       on (d.id = fs.field_id
      and fs.standard_id = cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND)
     when matched then
   update set fs.seqnum = fs.seqnum + 1
     when not matched then
   insert (id, field_id, seqnum, standard_id)
   values (com_flex_field_standard_seq.nextval, d.id, 1, cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND);
end;
