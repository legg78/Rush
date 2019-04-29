declare
    CRD_INTEREST_CALC_START_DATE           constant com_api_type_pkg.t_short_id   := 10001828;
    CRD_INTEREST_START_DATE_TRNSF          constant com_api_type_pkg.t_short_id   := 10003084;
    INTEREST_CALC_DATE_BEG_NEXT            constant com_api_type_pkg.t_dict_value := 'ICSD0003';
    INTEREST_CALC_DATE_POSTING             constant com_api_type_pkg.t_dict_value := 'ICSD0001';
    INTER_DATE_TRNSF_END_OF_DAY            constant com_api_type_pkg.t_dict_value := 'ISDT0003';
    INTER_DATE_TRNSF_REAL_TIME             constant com_api_type_pkg.t_dict_value := 'ISDT0002';

    l_count                                         com_api_type_pkg.t_count      := 0;
    l_id                                            com_api_type_pkg.t_medium_id;

    cursor cur_attribute_values is
        select v.*
          from prd_attribute a
             , prd_attribute_value v
         where v.attr_id    = a.id
           and a.id         = CRD_INTEREST_CALC_START_DATE
    for update of v.attr_value nowait;

begin
    dbms_output.enable(buffer_size => NULL);

    for r in cur_attribute_values loop
        dbms_output.put_line('prd_attribute_value.id = '         || r.id
                        || ', prd_attribute_value.attr_value = ' || r.attr_value);

        if r.attr_value = INTEREST_CALC_DATE_BEG_NEXT then
            update prd_attribute_value
               set attr_value = INTEREST_CALC_DATE_POSTING
             where current of cur_attribute_values;

            dbms_output.put_line('    updating ' || INTEREST_CALC_DATE_BEG_NEXT
                                         || '=>' || INTEREST_CALC_DATE_POSTING);
        end if;

        l_id := prd_attribute_value_seq.nextval;

        insert into prd_attribute_value(
            id
          , service_id
          , object_id
          , entity_type
          , attr_id
          , mod_id
          , start_date
          , end_date
          , register_timestamp
          , attr_value
          , split_hash
        ) values (
            l_id
          , r.service_id
          , r.object_id
          , r.entity_type
          , CRD_INTEREST_START_DATE_TRNSF
          , r.mod_id
          , r.start_date
          , r.end_date
          , r.register_timestamp
          , case r.attr_value
                when INTEREST_CALC_DATE_BEG_NEXT
                then INTER_DATE_TRNSF_END_OF_DAY
                else INTER_DATE_TRNSF_REAL_TIME
            end
          , r.split_hash
        );

        dbms_output.put_line('    inserting new value with id [' || l_id || '], attr_value = '
                             || case r.attr_value
                                    when INTEREST_CALC_DATE_BEG_NEXT
                                    then INTER_DATE_TRNSF_END_OF_DAY
                                    else INTER_DATE_TRNSF_REAL_TIME
                                end);

        l_count := l_count + 1;
    end loop;

    dbms_output.put_line('Script completed. Total product attribute values were processed: ' || l_count);
end;
