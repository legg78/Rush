create or replace function get_next_business_day(i_day date, i_workingdays number) return date is
    l_result       date := trunc(i_day);
    l_workingdays  number := i_workingdays;
    l_count        number := 0;
begin
    loop
        l_result := l_result + 1;
        begin
            select 1 into l_count from dual
             where to_char(l_result, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') != 'SUN';
            
            l_workingdays := l_workingdays - l_count;
        exception
            when no_data_found then
                null;
        end;
        exit when l_workingdays <= 0;
    end loop;
    return l_result;
end;
/

