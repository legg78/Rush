declare
    l_id     com_api_type_pkg.t_long_id;
begin
    l_id := com_api_id_pkg.get_from_id(to_date('2017-09-20','YYYY-MM-DD'));

    delete aup_tag where id = 10000223;
    update aup_tag_value a set tag_id = 50
     where tag_id = 68
       and a.auth_id >= l_id;
end;

