begin
    update prc_parameter_value
       set param_id = 10004518
         , param_value = case param_value
                             when 'UPIN0010' then 'USIC4610'
                             when 'UPIN0020' then 'USIC4620'
                         end
     where param_id = 10002347;
end;
