begin
    update com_flexible_data
       set field_id = case
                          when field_id = 10003744 then -50001291
                          when field_id = 10003745 then -50001292
                          when field_id = 10003792 then -50001293
                          else field_id
                      end
     where field_id in (10003744, 10003745, 10003792);
end;
