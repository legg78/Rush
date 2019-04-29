begin
    update prd_attribute_value
       set attr_id = case
                         when attr_id = 10003747 then -50001300
                         when attr_id = 10004106 then -50001301
                         when attr_id = 10004424 then -50001302
                         else attr_id
                     end
     where attr_id in (10003747, 10004106, 10004424);
end;
