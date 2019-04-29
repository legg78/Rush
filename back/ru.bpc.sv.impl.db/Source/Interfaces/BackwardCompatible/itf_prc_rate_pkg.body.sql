create or replace package body itf_prc_rate_pkg as
/*********************************************************
 *  Process for load currency rates <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 03.06.2013 <br />
 *  Last changed by $Author: kopachev $ <br />
 *  $LastChangedDate:: 2011-11-15 11:43:12 +0300#$ <br />
 *  Revision: $LastChangedRevision: 13781 $ <br />
 *  Module: com_prc_rate_pkg   <br />
 *  @headcom
 **********************************************************/
    BULK_LIMIT                  constant integer := 400;

    procedure load_rates_tlv (
        i_rate_type           in   com_api_type_pkg.t_dict_value
    )is
        l_rates                     sys_refcursor;
        
        l_excepted_count            com_api_type_pkg.t_long_id := 0;
        l_processed_count           com_api_type_pkg.t_long_id := 0;
        l_estimate_count            com_api_type_pkg.t_long_id := 0;
        l_raw_data                  com_api_type_pkg.t_raw_tab;

        l_header_str                com_api_type_pkg.t_attr_name;     
        l_inverted_str              com_api_type_pkg.t_attr_name;     
        l_tags_tab                  itf_api_type_pkg.tag_value_tab;    
        l_inst_id                   com_api_type_pkg.t_inst_id; 
        l_rate_type                 com_api_type_pkg.t_dict_value;
        l_effective_date            com_api_type_pkg.t_attr_name;
        l_expiration_date           com_api_type_pkg.t_attr_name;
        l_src_scale                 com_api_type_pkg.t_inst_id;
        l_src_currency              com_api_type_pkg.t_curr_code;
        l_src_exponent_scale        com_api_type_pkg.t_inst_id;
        l_dst_scale                 com_api_type_pkg.t_inst_id;
        l_dst_currency              com_api_type_pkg.t_curr_code;
        l_dst_exponent_scale        com_api_type_pkg.t_inst_id;
        l_inverted                  com_api_type_pkg.t_inst_id;
        l_rate                      com_api_type_pkg.t_attr_name;
        l_rate_numb                 com_api_type_pkg.t_money;    
        l_coma_pos                  com_api_type_pkg.t_inst_id;   
        
        l_id                        com_api_type_pkg.t_short_id;
        l_seqnum                    com_api_type_pkg.t_tiny_id;
        l_count                     number;
        
    procedure enum_rates (
        o_rates                     in out sys_refcursor
        , i_file_id                 in com_api_type_pkg.t_long_id
    ) is
    begin
        open o_rates for
            select d.raw_data
            from
                prc_session_file s
                , prc_file_raw_data d
            where
                s.session_id = prc_api_session_pkg.get_session_id
                and d.session_file_id = s.id
                and s.id = i_file_id;
    end;
    
    procedure get_value_of_tag(
        i_tag          in      com_api_type_pkg.t_attr_name
        , i_tags_tab   in      itf_api_type_pkg.tag_value_tab
        , o_val        out     com_api_type_pkg.t_attr_name
    )is
    begin
        for i in 1..i_tags_tab.count loop
            if i_tags_tab(i).tag = i_tag then 
                o_val := i_tags_tab(i).value;
                exit;
            end if;    
        end loop;

    end;

    procedure get_value_of_tag(
        i_tag          in      com_api_type_pkg.t_attr_name
        , i_direct_tag in      com_api_type_pkg.t_attr_name
        , i_tags_tab   in      itf_api_type_pkg.tag_value_tab
        , i_direction  in      com_api_type_pkg.t_attr_name
        , o_val        out     com_api_type_pkg.t_attr_name
    )is 
        l_parent_id    com_api_type_pkg.t_postal_code;
    begin
        for i in 1..i_tags_tab.count loop
            if i_tags_tab(i).tag = i_direct_tag and i_tags_tab(i).value = i_direction then
                l_parent_id := i_tags_tab(i).parent_id;
                exit;
            end if;
        end loop;

        for i in 1..i_tags_tab.count loop
            if i_tags_tab(i).tag = i_tag and i_tags_tab(i).parent_id = l_parent_id then
                o_val := i_tags_tab(i).value;
                exit;
            end if;
        end loop;

    end;
                    
    begin
        savepoint load_rates_tlv;
        prc_api_stat_pkg.log_start;
        
        -- estimate records
        select
            count(*)
        into
            l_estimate_count
        from
            prc_session_file s
            , prc_file_raw_data d
        where
            s.session_id = get_session_id
            and d.session_file_id = s.id;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimate_count
        );
        
        for rec in(
            select s.id 
                 , s.file_name 
              from prc_session_file s
            where    
                s.session_id = prc_api_session_pkg.get_session_id 
        )
        loop
            trc_log_pkg.debug (
                i_text          => 'Process file [#1]'
                , i_env_param1  => rec.file_name
            );            
        
            enum_rates (
                o_rates         => l_rates
                , i_file_id     => rec.id
            );
            
            loop
                fetch l_rates
                bulk collect into
                l_raw_data
                limit BULK_LIMIT;

                trc_log_pkg.debug (
                    i_text          => 'l_raw_data count=' || l_raw_data.count
                );            

                for i in l_raw_data.first..l_raw_data.last   
                loop
                    begin
                        l_header_str := substr(l_raw_data(i), 1, 4);
                        --first or last string of file
                        if l_header_str <> 'FF45' and l_header_str <> 'FF46' then
                            --get tab of tags
                            trc_log_pkg.debug (
                                i_text          => 'itf_api_tlv_pkg.get_tlv_tab - start'
                            );            
                            
                            itf_api_tlv_pkg.get_tlv_tab(
                                    i_string        =>     l_raw_data(i)
                                    , o_tags_tab    =>     l_tags_tab
                            ); 
                            trc_log_pkg.debug (
                                i_text          => 'itf_api_tlv_pkg.get_tlv_tab - OK'
                            );            
                            
                            --get values
                            get_value_of_tag(
                                                    i_tag          => FIELD_TAG_CONVERSION_DATE
                                                    , i_tags_tab   => l_tags_tab
                                                    , o_val        => l_effective_date    
                            ); 
                            
                            get_value_of_tag(
                                                    i_tag          => FIELD_TAG_CONVERSION_RATE
                                                    , i_tags_tab   => l_tags_tab
                                                    , o_val        => l_rate    
                            ); 
                            get_value_of_tag(
                                                    i_tag          => FIELD_TAG_COMMA_POSITION
                                                    , i_tags_tab   => l_tags_tab
                                                    , o_val        => l_coma_pos    
                            ); 
                              
                            l_rate_numb := int_to_float(l_rate, l_coma_pos);
                            trc_log_pkg.debug (
                                i_text          => 'l_rate_numb=' || l_rate_numb
                            );            

                            get_value_of_tag(
                                                    i_tag          => FIELD_TAG_MULTIPLE_FLAG
                                                    , i_tags_tab   => l_tags_tab
                                                    , o_val        => l_inverted_str    
                            ); 
                            if l_inverted_str = 'M' then 
                                l_inverted := 1;
                            else
                                l_inverted := 0;
                            end if;

                            get_value_of_tag(
                                                    i_tag          => FIELD_TAG_INSTITUTION_ID
                                                    , i_tags_tab   => l_tags_tab
                                                    , o_val        => l_inst_id    
                            ); 

                            get_value_of_tag(
                                                    i_tag          => FIELD_TAG_CURRENCY_CODE
                                                    , i_direct_tag => FIELD_TAG_DIRECTION_TYPE
                                                    , i_tags_tab   => l_tags_tab
                                                    , i_direction  => 'CURRSOUR'
                                                    , o_val        => l_src_currency    
                            ); 

                            get_value_of_tag(
                                                    i_tag          => FIELD_TAG_CURRENCY_CODE
                                                    , i_direct_tag => FIELD_TAG_DIRECTION_TYPE
                                                    , i_tags_tab   => l_tags_tab
                                                    , i_direction  => 'CURRDEST'
                                                    , o_val        => l_dst_currency    
                            ); 

                            trc_log_pkg.debug (
                                i_text          => 'com_api_rate_pkg.set_rate Start'
                            );            
                            
                            --save rate
                            com_api_rate_pkg.set_rate (
                                o_id              => l_id
                                , o_seqnum        => l_seqnum
                                , o_count         => l_count
                                , i_src_currency  => l_src_currency
                                , i_dst_currency  => l_dst_currency
                                , i_rate_type     => i_rate_type
                                , i_inst_id       => l_inst_id
                                , i_eff_date      => to_date(l_effective_date, 'dd.mm.yyyy')
                                , i_rate          => l_rate_numb
                                , i_inverted      => l_inverted
                                , i_src_scale     => 1  
                                , i_dst_scale     => 1  
                                , i_exp_date      => null 
                            );
                            trc_log_pkg.debug (
                                i_text          => 'com_api_rate_pkg.set_rate Ok'
                            );            
                                        
                            l_processed_count := l_processed_count + 1;
                        end if;
                        
                    exception
                        when others then
                            if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                                l_excepted_count := l_excepted_count + 1;
                            else
                                raise;
                            end if;                
                    end;    
                end loop;
                
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                    , i_excepted_count  => l_excepted_count
                );
                exit when l_rates%notfound;
            end loop;
            close l_rates;        
        end loop;  
         
        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
        
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_processed_count
        );

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );        

    exception
        when others then
            rollback to savepoint load_rates_tlv;
            
            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;

            raise;        
    end;
    
    function int_to_float( 
      i_int  in     number, -- unsigned integer
      i_pos  in     number  -- comma position 
    )
    return number 
    is
      l_result      number;
      l_comma_c     varchar2(35) := '1';
    begin
        if (i_pos = 0) then
            l_result := i_int;
        else
            for i in 1..i_pos loop
                l_comma_c := l_comma_c || '0';
                l_result := i_int / to_number(l_comma_c);  
            end loop;
        end if;
        return(l_result);
    end int_to_float;    
    
end;
/
