create or replace package body agr_prc_calulation_pkg is

 
 

procedure clear_aggr_value(i_aggr_value in com_api_type_pkg.t_long_id)
is
begin
  update agr_value 
     set count= 0,
         value = 0,
         currency = null
   where id = i_aggr_value;

end;


procedure get_inst_part( i_tables in com_api_type_pkg.t_name
                         , o_tables out com_api_type_pkg.t_name
                         , o_field  out com_api_type_pkg.t_name
                         , o_id     out com_api_type_pkg.t_long_id
)
is
begin

    begin
      select field into o_field from agr_parameter where flag =1 and table_name= i_tables;
      o_tables :=i_tables;

     exception
       when no_data_found then
         null;
    end;   
      
    if o_field is not null then
        return;
    end if;
    
    select field, table_name, id into o_field, o_tables, o_id from agr_parameter where table_name in (                          
        select table_name from agr_parameter where parent_id in (
               select id from agr_parameter where table_name =i_tables)
        )
    and flag = 1                          
    order by table_name;

    if o_field is not null then
        return;
    end if;    
    
    for tab in (select table_name from agr_parameter where parent_id in (
               select id from agr_parameter where table_name =i_tables))
    loop

        get_inst_part(i_tables => tab.table_name
                      , o_tables => o_tables
                      , o_field  => o_field
                      , o_id     => o_id); 

        if o_field is not null then 
            return;
        end if;

    end loop;
    
end;


procedure get_network_part( i_tables in com_api_type_pkg.t_name
                         , o_fields out agr_api_type_pkg.t_field_tab
)
is
field_rec  agr_api_type_pkg.t_field_rec;
begin


      for rec in (select id, field   from agr_parameter where flag = 2 and table_name= i_tables)
      loop
          field_rec.f_name  := rec.field;
          field_rec.f_table := i_tables;
          field_rec.f_id    := rec.id;
          o_fields(o_fields.count) := field_rec;
          field_rec := null;
      end loop;
         
      
    if o_fields.count>0 then
        return;
    end if;
    
    for rec in (select id, field, table_name from agr_parameter where table_name in (                          
                    select table_name from agr_parameter where parent_id in (
                           select id from agr_parameter where table_name =i_tables)
                    )
                and flag = 2                          
                order by table_name)
    loop
          field_rec.f_name  := rec.field;
          field_rec.f_table := rec.table_name;
          field_rec.f_id    := rec.id;
          o_fields(o_fields.count) := field_rec;
          field_rec := null;
    end loop;

    if o_fields.count>0 then
        return;
    end if;    
    
    for tab in (select table_name from agr_parameter where parent_id in (
               select id from agr_parameter where table_name =i_tables))
    loop

        get_network_part(i_tables => tab.table_name
                      , o_fields     => o_fields); 

        if o_fields.count>0 then
            return;
        end if;

    end loop;
    
end;

function get_query( i_type_id in com_api_type_pkg.t_long_id 
                    , io_fields in out agr_api_type_pkg.t_field_tab
                    , i_network_id in com_api_type_pkg.t_inst_id    
) return com_api_type_pkg.t_param_value
is
  q_select com_api_type_pkg.t_param_value;
  q_table  com_api_type_pkg.t_param_value;
  q_where  com_api_type_pkg.t_param_value;
  q_group  com_api_type_pkg.t_param_value;
  q_pivot0 com_api_type_pkg.t_param_value;
  q_pivot  com_api_type_pkg.t_param_value;

  
  inst_field com_api_type_pkg.t_name;
  inst_table com_api_type_pkg.t_name;
  inst_filed_id com_api_type_pkg.t_long_id;
  
  network_field  agr_api_type_pkg.t_field_rec;
  network_fields agr_api_type_pkg.t_field_tab;
  
  i number :=0;
  
  q_tables com_api_type_pkg.t_param_tab;
  q_name com_api_type_pkg.t_name;

  
  oper_field com_api_type_pkg.t_name;
  oper_table com_api_type_pkg.t_name;
  
  procedure add_table(i_table com_api_type_pkg.t_name)
  is
  begin
      if not q_tables.exists(i_table) then
          q_tables(i_table) := '';
      end if; 
  end;
  
  procedure add_field(i_name com_api_type_pkg.t_name
                      , i_type com_api_type_pkg.t_byte_char
                      , i_format com_api_type_pkg.t_name
                      , i_id com_api_type_pkg.t_long_id)
  is
      field agr_api_type_pkg.t_field_rec;
  begin
      field.f_name   := i_name;
      field.f_type   := i_type;
      field.f_format := i_format;
      field.f_id     := i_id;
      
      
      io_fields(io_fields.count) := field;
  end;
begin
    
    
    for tab in (  select table_name  from agr_rule r, agr_parameter p  where r.param_id = p.id  and r.type_id = i_type_id)
    loop
        get_inst_part (i_tables => tab.table_name
                      , o_tables => inst_table
                      , o_field  => inst_field
                      , o_id     => inst_filed_id);
        
        exit when inst_field is not null;
        
    end loop;
    
    for tab in (  select table_name  from agr_rule r, agr_parameter p  where r.param_id = p.id  and r.type_id = i_type_id)
    loop    
        get_network_part( i_tables => tab.table_name
                        , o_fields =>network_fields);
         exit when network_fields.count>0;
        
    end loop;
    
    if network_fields.count>0 then
      for i in network_fields.first..network_fields.last
      loop
          add_table(i_table => network_fields(i).f_table);
      end loop;    
    end if;
        
    i :=0;
    for fiedls in (
                    select p.*,r.type as f_type from agr_rule r, agr_parameter p
                     where r.param_id = p.id
                       and r.type_id = i_type_id
                       and (r.type = 'm' or r.type = 'cc'))
    loop
        if q_select is null then
            q_select := 'select ';
        else
            q_select := q_select||', ';
        end if;
          q_select := q_select||fiedls.table_name||'.'||fiedls.field||' as '||fiedls.f_type||i;
          add_field(i_name => fiedls.f_type||i
                  , i_type => fiedls.type
                  , i_format => null
                  , i_id     => fiedls.id);

          i :=i+1;
          
          add_table(i_table => fiedls.table_name);
          
        if q_group is null then
           q_group := ' group by ';
            else
           q_group := q_group||', ';
        end if;
        
        q_group := q_group|| fiedls.table_name||'.'||fiedls.field; 
          
    end loop;  

    i :=0;
    for fiedls in (
                    select p.* from agr_rule r, agr_parameter p
                     where r.param_id = p.id
                       and r.type_id = i_type_id
                       and r.type = 's')
    loop
        if q_select is null then
            q_select := 'select ';
        else
            q_select := q_select||', ';
        end if;
          q_select := q_select||'sum('||fiedls.table_name||'.'||fiedls.field||') as s'||i;

          add_field(i_name => 's'||i
                  , i_type => fiedls.type
                  , i_format => null
                  , i_id     => fiedls.id);

          i :=i+1;
          
          add_table(i_table => fiedls.table_name);
          
    end loop;
    
    i :=0;
    for fiedls in (
                    select p.* from agr_rule r, agr_parameter p
                     where r.param_id = p.id
                       and r.type_id = i_type_id
                       and r.type = 'c')
    loop
        if q_select is null then
            q_select := 'select ';
        else
            q_select := q_select||', ';
        end if;
          q_select := q_select||'count('||fiedls.table_name||'.'||fiedls.field||') as c'||i;
          
          add_table(i_table => fiedls.table_name);

          add_field(i_name => 'c'||i
                  , i_type => fiedls.type
                  , i_format => null
                  , i_id     => fiedls.id);
          i :=i+1;          
    end loop;
    
    if inst_field is not null then
        if q_select is null then
            q_select := 'select ';
        else
            q_select := q_select||', ';
        end if;
        
        q_select := q_select||inst_table||'.'||inst_field||' as i0';
        
        add_field(i_name => 'i0'
                  , i_type => null--c_type_varchar
                  , i_format => null
                  , i_id     => inst_filed_id);
              
        add_table(i_table => inst_table);
        
        q_group := q_group|| ', '||inst_table||'.'||inst_field; 
        
    end if;

    
    q_name := q_tables.first;
    loop
        begin
            select field into oper_field from agr_parameter where table_name = q_name and flag = 0;
                oper_table := q_name;
                exit;
            exception 
                when no_data_found then
                    null;
        end;
        
        q_name := q_tables.next(q_name);
        exit when q_name is null;
    end loop;
    
    if oper_table is not null then 
        add_table(i_table => oper_table);
    end if;
    
     
    if q_tables.count>0 then
        q_name := q_tables.first;
        loop
           if q_table is null then 
                   q_table := ' from '||q_name;
               else
                   q_table := q_table||', '||q_name;
           end if;        
         q_name := q_tables.next(q_name);
         exit when q_name is null;
        end loop;
    end if;
    

    q_table := q_table||', opr_oper_stage';

    q_where := ' where ';

    if oper_field is not null then
      q_where := q_where||oper_table||'.'||oper_field||'= opr_oper_stage.oper_id(+) and opr_oper_stage.proc_stage(+) = ''PSTGAGGR'' and nvl(opr_oper_stage.status,''OPST0100'') = ''OPST0100'' '; 
    end if;
    
    begin
        select condition into q_name from agr_type where id = i_type_id;
        if q_name is not null then
            q_where := q_where||' and ('||q_name||')';
        end if;
        exception 
            when no_data_found then 
               null;
    end; 
    
    q_name := q_tables.first;

    loop
      for rec in (select l1.field f1, l1.table_name t1, l2.field f2, l2.table_name t2 from agr_parameter l1, agr_parameter l2 where l2.table_name = q_name and l1.parent_id = l2.id)  
      loop
          if q_tables.exists(rec.t1) then
              q_where := q_where|| ' and '||rec.t2||'.'||rec.f2||'='||rec.t1||'.'||rec.f1;
          end if;
      end loop;
      q_name := q_tables.next(q_name);

      exit when q_name is null;
    end loop;
    
    q_where := q_where|| ' and '||inst_table||'.'||inst_field||' = :inst_id';     
    
    if network_fields.count>0 then
      q_name:= '';
      for i in network_fields.first..network_fields.last
      loop
          if q_name is null then
              q_name := ' and :network_id in (';
              else
              q_name := q_name||', ';
          end if;
          q_name := q_name||network_fields(i).f_table||'.'||network_fields(i).f_name;
      end loop;

      q_where := q_where|| q_name||') ';

    end if;
    
    
    for field_no in io_fields.first..io_fields.last 
    loop
      if q_pivot is null then
              q_pivot0 := 'select * from ((select ';
              q_pivot := ')) unpivot include nulls ( value for value_type in (';
          else
              q_pivot0:= q_pivot0||' , ';
              q_pivot := q_pivot||' , ';
      end if;
      
      q_pivot0 := q_pivot0||'to_char('||io_fields(field_no).f_name||') '||io_fields(field_no).f_name;
      q_pivot :=q_pivot||io_fields(field_no).f_name;
      
    end loop;
    
    q_pivot0 :=q_pivot0||' from (';
    q_pivot := q_pivot||')))';
    
    
    return q_pivot0 || q_select || q_table || q_where || q_group || q_pivot;
end;

function insert_value(i_count com_api_type_pkg.t_param_value
                      , i_sum com_api_type_pkg.t_param_value
                      , i_curr com_api_type_pkg.t_param_value
                      , i_type com_api_type_pkg.t_long_id)
                    return com_api_type_pkg.t_long_id
is

ret_id com_api_type_pkg.t_long_id;

begin
   
   insert into agr_value 
   ( id, type_id, count, value, currency) 
   values 
   (agr_value_seq.nextval, i_type, i_count, i_sum, i_curr)
   returning id    
   into ret_id;

   return ret_id;
end;

function insert_param_value(i_value com_api_type_pkg.t_param_value
                      , i_param_id com_api_type_pkg.t_long_id
                      , i_value_id com_api_type_pkg.t_long_id
                      , i_type_id com_api_type_pkg.t_long_id)
                    return com_api_type_pkg.t_long_id
is

ret_id com_api_type_pkg.t_long_id;

begin
   
   insert into agr_param_value 
   ( id, type_id, value_id, param_id, value) 
   values 
   (agr_param_value_seq.nextval, i_type_id, i_value_id, i_param_id, i_value)
   returning id    
   into ret_id;

   return ret_id;
end;                       

procedure update_oper(i_network_id in com_api_type_pkg.t_inst_id
                      , i_inst_id in com_api_type_pkg.t_inst_id )
is
begin 
    merge into
        opr_oper_stage dst
    using (select opr_operation.id, opr_oper_stage.proc_stage, opr_oper_stage.status, opr_participant.split_hash  
    from opr_operation, opr_participant, opr_oper_stage
         where            opr_operation.id = opr_oper_stage.oper_id(+)                                     
                          and opr_oper_stage.proc_stage(+) = 'PSTGAGGR'
                          and nvl(opr_oper_stage.status, 'OPST0100') = 'OPST0100'                                                    
                          and i_network_id in (opr_participant.card_network_id
                                            , opr_participant.network_id)
                          and opr_operation.id = opr_participant.oper_id
                          and opr_participant.inst_id = i_inst_id
                         
                          ) src 
    on (
       DST.OPER_ID = src.id
       and DST.PROC_STAGE = src.proc_stage
    )
    when matched then
       update set
          status = 'OPST0400'
    when not matched then
        insert(oper_id, proc_stage, exec_order, status, split_hash) values
        (src.id, 'PSTGAGGR', (select ops.exec_order from opr_proc_stage ops where ops.proc_stage = 'PSTGAGGR'), 'OPST0400', src.split_hash );

end;

procedure process(
    i_inst_id      in com_api_type_pkg.t_inst_id
    , i_aggr_type  in com_api_type_pkg.t_long_id default null
    , i_aggr_value in com_api_type_pkg.t_long_id default null
    , i_network_id in com_api_type_pkg.t_inst_id    
)
is

    CONST_PROC_NAME    constant com_api_type_pkg.t_name := 'AGR_PRC_CALULATION_PKG.PROCESS';
    l_estimated_count           com_api_type_pkg.t_long_id; 
    l_processed_count           com_api_type_pkg.t_long_id :=0;
    
    query com_api_type_pkg.t_param_value;

    fields agr_api_type_pkg.t_field_tab;


    l_data_cur sys_refcursor;

    l_value_type com_api_type_pkg.t_param_value;
    l_value      com_api_type_pkg.t_param_value;

    l_count com_api_type_pkg.t_medium_id;
    l_sum   com_api_type_pkg.t_money;
    l_curr  com_api_type_pkg.t_curr_code;

    l_value_id  com_api_type_pkg.t_long_id;

    l_param_value agr_api_type_pkg.field_values_table;

    procedure add_param_value(i_name com_api_type_pkg.t_name
                              ,i_value com_api_type_pkg.t_param_value)
    is

     rec agr_api_type_pkg.field_value_record;

    begin
        for i in fields.first..fields.last
        loop
            if (upper(fields(i).f_name)=upper(i_name)) then
                rec.field_no := fields(i).f_id;
                exit;
            end if;
        end loop;
            
        rec.field_value := i_value;
        
        l_param_value(l_param_value.count) :=rec;
    end;                          


    procedure insert_param_values(i_value_id  com_api_type_pkg.t_long_id
                                  ,i_type_id  com_api_type_pkg.t_long_id)
    is
    l_id  com_api_type_pkg.t_long_id;
    begin
        

        if l_param_value is not null and l_param_value.count>0  then  
        for param_no in l_param_value.first..l_param_value.last
        loop
            l_id := insert_param_value(i_value =>l_param_value(param_no).field_value
                                  , i_param_id => l_param_value(param_no).field_no
                                  , i_value_id => i_value_id
                                  , i_type_id  => i_type_id);
        end loop;
        end if;
        
        l_param_value.delete();
    end;
                    
begin
    prc_api_stat_pkg.log_start;
    
    trc_log_pkg.debug (
        i_text       => CONST_PROC_NAME||' i_inst_id:'||i_inst_id||' i_aggr_type:'||i_aggr_type||' i_aggr_value:'||i_aggr_value||' i_network_id:'||i_network_id);    
    
    select count(*) into l_estimated_count from agr_type where network_id =i_network_id and nvl(i_aggr_type,id)= id;
    
    trc_log_pkg.debug (
        i_text       => 'Aggregate type to process: [#1]'
      , i_env_param1 => l_estimated_count
    );
    
    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );
    
    -- clear aggr_value
    if i_aggr_value is not null then
        clear_aggr_value(i_aggr_value => i_aggr_value);
    end if;

    -- select rules    
    for aggr_type in (select id, condition from agr_type where network_id =i_network_id and nvl(i_aggr_type,id)= id)
    loop
        
       -- create query
        query := get_query (i_type_id =>aggr_type.id
                            , io_fields => fields
                            , i_network_id => i_network_id);
                            
                            dbms_output.put_line(query);
        
        open l_data_cur for query using i_inst_id, i_network_id;
        loop
            l_curr := null;
            l_count:= null;
            l_sum  := null;

            for i in fields.first..fields.last
            loop
                fetch l_data_cur into l_value_type, l_value;
                exit when l_data_cur%notfound;                
                
                if l_value_type like 'CC%' then 
                        l_curr:= l_value;
                        add_param_value(i_name => l_value_type
                                        , i_value => l_value);                        
                    elsif (l_value_type like 'C%') then
                        l_count:= l_value;
                    elsif (l_value_type like 'S%') then
                        l_sum:= l_value;
                    else
                        add_param_value(i_name => l_value_type
                                        , i_value => l_value);
                end if;

            end loop;
            
            exit when l_data_cur%notfound;
                        
            -- save sum/count to value
            l_value_id := insert_value(i_count => l_count
                      , i_sum => l_sum
                      , i_curr => l_curr
                      , i_type => aggr_type.id);
          
            -- save value to param_value
            insert_param_values(i_value_id => l_value_id
                              ,i_type_id   =>  aggr_type.id);


        end loop;  
        
        close l_data_cur;      
        
        l_processed_count := l_processed_count+1;
        
        prc_api_stat_pkg.log_current (
            i_current_count   => l_processed_count
          , i_excepted_count  => 0
        );        
        
    end loop;

    
    -- update operation stage
    if i_aggr_type is null and i_aggr_value is null then 
        update_oper(i_network_id => i_network_id
                    , i_inst_id => i_inst_id);
    end if;
     
    
    trc_log_pkg.debug (CONST_PROC_NAME || ' was successfully completed.');

    prc_api_stat_pkg.log_end (
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );     
        
        raise;   
end;

end;
/
