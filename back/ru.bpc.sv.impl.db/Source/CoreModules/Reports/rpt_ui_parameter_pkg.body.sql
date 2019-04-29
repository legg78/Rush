create or replace package body rpt_ui_parameter_pkg as
/*********************************************************
*  UI for report parametets <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 19.05.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RPT_UI_PARAMETER_PKG <br />
*  @headcom
**********************************************************/

procedure check_display_order(
    i_report_id        in com_api_type_pkg.t_short_id
  , i_display_order    in com_api_type_pkg.t_tiny_id
  , i_direction        in com_api_type_pkg.t_boolean
) is
begin
    for rec in (
        select 1 from
            rpt_parameter_vw a
        where a.report_id     = i_report_id
          and a.display_order = i_display_order
          and a.direction     = i_direction)
    loop
        com_api_error_pkg.raise_error(
            i_error      => 'REPORT_PARAM_DISPLAY_ORDER_ALREADY_EXISTS'
          , i_env_param1 => i_report_id
          , i_env_param2 => i_display_order
        );
    end loop;
end check_display_order;

procedure add_parameter(
    i_report_id        in  com_api_type_pkg.t_short_id
  , i_system_name      in  com_api_type_pkg.t_attr_name
  , i_param_label      in  com_api_type_pkg.t_name
  , i_param_desc       in  com_api_type_pkg.t_name          default null
  , i_data_type        in  com_api_type_pkg.t_attr_name
  , i_default_value_n  in  number
  , i_default_value_d  in  date
  , i_default_value_v  in  com_api_type_pkg.t_full_desc
  , i_is_mandatory     in  com_api_type_pkg.t_boolean
  , i_display_order    in  com_api_type_pkg.t_tiny_id
  , i_lov_id           in  com_api_type_pkg.t_tiny_id
  , i_lang             in  com_api_type_pkg.t_name
  , o_param_id         out com_api_type_pkg.t_short_id
  , i_selection_form   in  com_api_type_pkg.t_name
) is
    l_count            com_api_type_pkg.t_short_id;
    l_value            com_api_type_pkg.t_full_desc;
begin
    select count(*)
      into l_count
      from rpt_report_vw
     where id = i_report_id;

    if l_count = 0 then
        com_api_error_pkg.raise_error(
            i_error       =>  'CAN_NOT_FIND_REPORT'
          , i_env_param1  =>  to_char(i_report_id,'TM9')
        );
    end if;

    if i_data_type is null or i_data_type not in (com_api_const_pkg.DATA_TYPE_CHAR
                                                , com_api_const_pkg.DATA_TYPE_NUMBER
                                                , com_api_const_pkg.DATA_TYPE_DATE)
    then
        COM_API_ERROR_PKG.raise_error(
            i_error       =>  'BAD_PARAMETER_TYPE'
          , i_env_param1  =>  i_data_type
        );
    end if;

    l_value :=
        case i_data_type
        when com_api_const_pkg.DATA_TYPE_CHAR   then i_default_value_v
        when com_api_const_pkg.DATA_TYPE_NUMBER then to_char(i_default_value_n, com_api_const_pkg.NUMBER_FORMAT)
        when com_api_const_pkg.DATA_TYPE_DATE   then to_char(i_default_value_d, com_api_const_pkg.DATE_FORMAT)
        else null
        end;

    --check unique display order
    check_display_order(
        i_report_id     =>  i_report_id
      , i_display_order =>  i_display_order
      , i_direction     =>  com_api_type_pkg.TRUE 
    );

    o_param_id := com_parameter_seq.nextval;
    insert into rpt_parameter_vw (
        id
      , seqnum
      , report_id
      , param_name
      , data_type
      , default_value
      , is_mandatory
      , display_order
      , lov_id
      , direction
	  , selection_form
    ) values (
        o_param_id
      , 1
      , i_report_id
      , upper(i_system_name)
      , i_data_type
      , l_value
      , i_is_mandatory
      , i_display_order
      , i_lov_id
      , 1
	  , i_selection_form
    );

    com_api_i18n_pkg.add_text(
        i_table_name   =>  'RPT_PARAMETER'
      , i_column_name  =>  'LABEL'
      , i_object_id    =>  o_param_id
      , i_text         =>  i_param_label
      , i_lang         =>  i_lang
    );

    if i_param_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   =>  'RPT_PARAMETER'
          , i_column_name  =>  'DESCRIPTION'
          , i_object_id    =>  o_param_id
          , i_text         =>  i_param_desc
          , i_lang         =>  i_lang
        );
    end if;

end;

procedure modify_parameter (
    i_param_id         in  com_api_type_pkg.t_short_id
  , i_system_name      in  com_api_type_pkg.t_attr_name
  , i_param_label      in  com_api_type_pkg.t_short_desc
  , i_param_desc       in  com_api_type_pkg.t_name          default null
  , i_is_mandatory     in  com_api_type_pkg.t_boolean
  , i_default_value_n  in  number
  , i_default_value_d  in  date
  , i_default_value_v  in  com_api_type_pkg.t_full_desc
  , i_display_order    in  com_api_type_pkg.t_tiny_id
  , i_lov_id           in  com_api_type_pkg.t_tiny_id
  , i_lang             in  com_api_type_pkg.t_name
  , i_selection_form   in  com_api_type_pkg.t_name
) is
    l_value            com_api_type_pkg.t_full_desc;
    l_data_type        com_api_type_pkg.t_dict_value;
    l_source_type      com_api_type_pkg.t_dict_value;
    l_report_id        com_api_type_pkg.t_short_id;
    l_display_order    com_api_type_pkg.t_tiny_id;
begin
    select p.data_type
         , r.source_type
         , p.report_id
         , p.display_order
      into l_data_type
         , l_source_type
         , l_report_id
         , l_display_order
      from rpt_parameter_vw p
         , rpt_report_vw    r
     where p.id = i_param_id
       and r.id = p.report_id;

    l_value :=
        case l_data_type
        when com_api_const_pkg.DATA_TYPE_CHAR   then i_default_value_v
        when com_api_const_pkg.DATA_TYPE_NUMBER then to_char(i_default_value_n, com_api_const_pkg.NUMBER_FORMAT)
        when com_api_const_pkg.DATA_TYPE_DATE   then to_char(i_default_value_d, com_api_const_pkg.DATE_FORMAT)
        else null
        end;

    --check unique display order
    if i_display_order != l_display_order then
        check_display_order(
            i_report_id     =>  l_report_id
          , i_display_order =>  i_display_order
          , i_direction     =>  com_api_type_pkg.TRUE 
        );
    end if;

    update rpt_parameter_vw
    set default_value  =  l_value
      , param_name     =  upper(i_system_name)
      , display_order  =  i_display_order
      , lov_id         =  i_lov_id
      , is_mandatory   =  case when l_source_type =   rpt_api_const_pkg. REPORT_SOURCE_SIMPLE
                               then i_is_mandatory
                               else is_mandatory
                          end
	  , selection_form = i_selection_form
    where id           =  i_param_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'RPT_PARAMETER'
      , i_column_name  => 'LABEL'
      , i_object_id    => i_param_id
      , i_text         => i_param_label
      , i_lang         => i_lang
    );
    
    if i_param_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   =>  'RPT_PARAMETER'
          , i_column_name  =>  'DESCRIPTION'
          , i_object_id    =>  i_param_id
          , i_text         =>  i_param_desc
          , i_lang         =>  i_lang
        );
    end if;
    
end;

procedure remove_parameter (
    i_param_id  in  com_api_type_pkg.t_short_id
) is
begin
    delete from rpt_parameter_vw where id = i_param_id;

    com_api_i18n_pkg.remove_text(
        i_table_name  => 'RPT_PARAMETER'
      , i_object_id   => i_param_id
    );
end;

procedure sync_parameters(
    i_report_id in      com_api_type_pkg.t_medium_id
) is
    l_param_id  com_api_type_pkg.t_short_id;
begin
    for rec in (
        select id
          from rpt_parameter_vw p
         where p.report_id = i_report_id
           and exists(select 1 from rpt_report_vw r
                       where r.id          = p.report_id
                         and r.source_type = rpt_api_const_pkg.REPORT_SOURCE_XML
                     )
           and (p.param_name, p.data_type, p.is_mandatory) not in (
               select
                   a.argument_name
                 , decode(a.data_type
                     , 'VARCHAR2', com_api_const_pkg.DATA_TYPE_CHAR
                     , 'NUMBER'  , com_api_const_pkg.DATA_TYPE_NUMBER
                     , 'DATE'    , com_api_const_pkg.DATA_TYPE_DATE
                 )
                 , decode(a.defaulted, 'Y', 0, 'N', 1 , 1)
                 from
                     rpt_report r
                   , user_arguments a
                where upper(to_char(r.data_source)) = a.package_name||'.'||a.object_name
                  and r.id                          = i_report_id
                  and r.source_type                 = rpt_api_const_pkg.REPORT_SOURCE_XML
                  and a.argument_name          not in ('O_XML', 'I_LANG')
               )
    ) loop
        com_api_i18n_pkg.remove_text(
            i_table_name  => 'RPT_PARAMETER'
          , i_object_id   => rec.id
        );
        delete rpt_parameter_vw p
        where p.id = rec.id;
    end loop;

    for rec in (
        select id
             , argument_name
             , param_data_type
             , row_number() over(order by position) * 10 as  display_order
             , is_mandatory
         from (
          select id
               , argument_name
               , decode(data_type
                   , 'VARCHAR2' , com_api_const_pkg.DATA_TYPE_CHAR
                   , 'NUMBER'   , com_api_const_pkg.DATA_TYPE_NUMBER
                   , 'DATE'     , com_api_const_pkg.DATA_TYPE_DATE
                 ) as param_data_type
               , position
               , decode(a.defaulted, 'Y', 0, 'N',1,1) as is_mandatory
            from rpt_report r
               , user_arguments a
            where upper(to_char(r.data_source)) = a.package_name||'.'||a.object_name
             and r.id                           = i_report_id
             and r.source_type                  = rpt_api_const_pkg.REPORT_SOURCE_XML
             and a.argument_name not in ('O_XML', 'I_LANG')
        ) x where not exists
             (select 1 from rpt_parameter p
               where upper(p.param_name) = x.argument_name
                 and p.report_id = x.id )
           order by position
    ) loop
        l_param_id := com_parameter_seq.nextval;

        insert into rpt_parameter_vw (
            id
          , seqnum
          , report_id
          , param_name
          , data_type
          , default_value
          , is_mandatory
          , display_order
          , lov_id
        ) values (
            l_param_id
          , 1
          , i_report_id
          , upper(rec.argument_name)
          , rec.param_data_type
          , null
          , rec.is_mandatory
          , rec.display_order
          , null
        );
        com_api_i18n_pkg.add_text(
            i_table_name   => 'RPT_PARAMETER'
          , i_column_name  => 'LABEL'
          , i_object_id    => l_param_id
          , i_text         => upper(rec.argument_name)
          , i_lang         => get_user_lang
        );
    end loop;
    
    -- sync only current report
    /*for rec in (
          select p.id param_id
            from rpt_parameter p
               , rpt_report r
           where p.report_id = r.id
              and r.source_type = rpt_api_const_pkg.REPORT_SOURCE_XML
              and upper(p.param_name) not in ('O_XML', 'I_LANG')
              and not exists(
                select 1
                from user_arguments a
                where upper(p.param_name) = a.argument_name
                  and upper(to_char(r.data_source)) = a.package_name||'.'||a.object_name
              )
    ) loop
        remove_parameter(i_param_id => rec.param_id);
    end loop;*/

end;

procedure add_out_parameter(
    o_param_id         out com_api_type_pkg.t_short_id
  , i_report_id        in  com_api_type_pkg.t_short_id
  , i_param_label      in  com_api_type_pkg.t_name
  , i_param_desc       in  com_api_type_pkg.t_name          default null
  , i_data_type        in  com_api_type_pkg.t_attr_name
  , i_display_order    in  com_api_type_pkg.t_tiny_id
  , i_lang             in  com_api_type_pkg.t_name
  , i_is_grouping      in  com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
  , i_is_sorting       in  com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
)is
    l_count            com_api_type_pkg.t_short_id;
begin
    select count(*)
      into l_count
      from rpt_report_vw
     where id = i_report_id;

    if l_count = 0 then
        com_api_error_pkg.raise_error(
            i_error       =>  'CAN_NOT_FIND_REPORT'
          , i_env_param1  =>  to_char(i_report_id,'TM9')
        );
    end if;

    --check unique display order
    check_display_order(
        i_report_id     =>  i_report_id
      , i_display_order =>  i_display_order
      , i_direction     =>  com_api_type_pkg.FALSE 
    );

    o_param_id := com_parameter_seq.nextval;
    insert into rpt_parameter_vw (
        id
      , seqnum
      , report_id
      , param_name
      , data_type
      , default_value
      , is_mandatory
      , display_order
      , lov_id
      , direction
      , is_grouping
      , is_sorting
    ) values (
        o_param_id
      , 1
      , i_report_id
      , null
      , i_data_type
      , null
      , null
      , i_display_order
      , null
      , 0 --direction always 0     
      , i_is_grouping  
      , i_is_sorting 
    );

    com_api_i18n_pkg.add_text(
        i_table_name   =>  'RPT_PARAMETER'
      , i_column_name  =>  'LABEL'
      , i_object_id    =>  o_param_id
      , i_text         =>  i_param_label
      , i_lang         =>  i_lang
    );

    if i_param_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   =>  'RPT_PARAMETER'
          , i_column_name  =>  'DESCRIPTION'
          , i_object_id    =>  o_param_id
          , i_text         =>  i_param_desc
          , i_lang         =>  i_lang
        );
    end if;
end;


procedure modify_out_parameter (
    i_param_id         in  com_api_type_pkg.t_short_id
  , i_param_label      in  com_api_type_pkg.t_name
  , i_param_desc       in  com_api_type_pkg.t_name          default null
  , i_display_order    in  com_api_type_pkg.t_tiny_id
  , i_lang             in  com_api_type_pkg.t_name
  , i_is_grouping      in  com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
  , i_is_sorting       in  com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
)is
    l_report_id        com_api_type_pkg.t_short_id;
    l_display_order    com_api_type_pkg.t_tiny_id;
begin
    select p.report_id
      into l_report_id
      from rpt_parameter_vw p
         , rpt_report_vw    r
     where p.id = i_param_id
       and r.id = p.report_id;

    --check unique display order
    if i_display_order != l_display_order then
        check_display_order(
            i_report_id     =>  l_report_id
          , i_display_order =>  i_display_order
          , i_direction     =>  com_api_type_pkg.FALSE
        );
    end if;

    update rpt_parameter_vw
    set display_order  =  i_display_order
      , is_grouping    =  i_is_grouping     
      , is_sorting     =  i_is_sorting     
    where id           =  i_param_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'RPT_PARAMETER'
      , i_column_name  => 'LABEL'
      , i_object_id    => i_param_id
      , i_text         => i_param_label
      , i_lang         => i_lang
    );
    
    if i_param_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   =>  'RPT_PARAMETER'
          , i_column_name  =>  'DESCRIPTION'
          , i_object_id    =>  i_param_id
          , i_text         =>  i_param_desc
          , i_lang         =>  i_lang
        );
    end if;

end;

end;
/
