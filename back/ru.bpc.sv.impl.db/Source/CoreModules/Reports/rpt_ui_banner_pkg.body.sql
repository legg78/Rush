create or replace package body rpt_ui_banner_pkg as
/*
  Interface for report banner definition <br />
  Created by Fomichev A.(fomichev@bpc.ru)  at 20.09.2010 <br />
  Last changed by $Author: Fomichev A. $ <br />
  $LastChangedDate:: 2010-08-20 11:44:00 +0400#$ <br />
  Module: rpt_ui_banner_pkg <br />
*/
procedure add_banner(
    o_id               out  com_api_type_pkg.t_short_id
  , o_seqnum           out  com_api_type_pkg.t_tiny_id
  , i_status        in      com_api_type_pkg.t_dict_value
  , i_filename      in      com_api_type_pkg.t_name
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_label         in      com_api_type_pkg.t_name
  , i_description   in      com_api_type_pkg.t_full_desc
  , i_lang          in      com_api_type_pkg.t_dict_value   default null
) is
begin
    if com_api_i18n_pkg.text_is_present(i_table_name   => 'RPT_BANNER'
                                      , i_column_name  => 'LABEL'
                                      , i_inst_id       => i_inst_id
                                      , i_text          => i_label
                                      , i_lang          => i_lang
       ) = com_api_type_pkg.TRUE
    then
        com_api_error_pkg.raise_error(
           i_error       => 'DUPLICATE_DESCRIPTION_IN_INSTITUTE'
         , i_env_param1  => 'RPT_BANNER'
         , i_env_param2  => 'LABEL'
         , i_env_param3  => i_inst_id
         , i_env_param4  => i_label
         , i_env_param5  => i_lang
        );

    else
        select rpt_banner_seq.nextval
             , 1
        into   o_id
             , o_seqnum
        from dual;
       
        insert into rpt_banner_vw(
            id
          , seqnum
          , status
          , filename
          , inst_id
        ) values(
            o_id
          , o_seqnum
          , i_status
          , i_filename
          , i_inst_id
        );
        
        com_api_i18n_pkg.add_text(
            i_table_name   => 'RPT_BANNER'
          , i_column_name  => 'LABEL'
          , i_object_id    => o_id
          , i_text         => i_label
          , i_lang         => i_lang 
        );
        
        com_api_i18n_pkg.add_text(
            i_table_name   => 'RPT_BANNER'
          , i_column_name  => 'DESCRIPTION'
          , i_object_id    => o_id
          , i_text         => i_description
          , i_lang         => i_lang 
        );
    end if;       
end;

procedure modify_banner(
    i_id           in      com_api_type_pkg.t_short_id
  , io_seqnum      in out  com_api_type_pkg.t_tiny_id
  , i_status       in      com_api_type_pkg.t_dict_value
  , i_filename     in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
  , i_lang         in      com_api_type_pkg.t_dict_value   default null
) is
begin
    update rpt_banner_vw
    set    status   = i_status
         , filename = i_filename
         , seqnum   = io_seqnum
    where  id = i_id;
    
    io_seqnum := io_seqnum + 1;
  
     com_api_i18n_pkg.add_text(
        i_table_name   => 'RPT_BANNER'
      , i_column_name  => 'LABEL'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang 
    );
    
    com_api_i18n_pkg.add_text(
        i_table_name   => 'RPT_BANNER'
      , i_column_name  => 'DESCRIPTION'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang 
    );
end;

procedure remove_banner(
    i_id      in     com_api_type_pkg.t_short_id
  , i_seqnum  in     com_api_type_pkg.t_tiny_id
) is
begin

    for curs_rb in (select report_id 
                      from rpt_report_banner_vw 
                     where banner_id = i_id) 
    loop
        com_api_error_pkg.raise_error(
            i_error       =>  'EXISTS_RPTB_CHILD_RECORD'
          , i_env_param1  =>  to_char(curs_rb.report_id)
        );
    end loop;

    update rpt_banner_vw
       set seqnum  = i_seqnum
     where id      = i_id;
     
    delete rpt_banner_vw
     where id      = i_id;
     
    com_api_i18n_pkg.remove_text(
        i_table_name  => 'RPT_BANNER'
      , i_object_id   => i_id
    );

end;

end;
/
