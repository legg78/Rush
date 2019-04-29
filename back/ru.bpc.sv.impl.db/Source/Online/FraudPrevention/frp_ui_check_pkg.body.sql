create or replace package body frp_ui_check_pkg as

procedure add_check(
    o_id                out  com_api_type_pkg.t_short_id 
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_case_id        in      com_api_type_pkg.t_tiny_id
  , i_check_type     in      com_api_type_pkg.t_dict_value
  , i_alert_type     in      com_api_type_pkg.t_dict_value
  , i_expression     in      com_api_type_pkg.t_name
  , i_risk_score     in      com_api_type_pkg.t_tiny_id
  , i_risk_matrix_id in      com_api_type_pkg.t_tiny_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
) is
begin
    select frp_check_seq.nextval into o_id from dual;
    
    o_seqnum := 1;
    
    insert into frp_check_vw(
        id
      , seqnum
      , case_id
      , check_type
      , alert_type
      , expression
      , risk_score
      , risk_matrix_id
    ) values (
        o_id
      , o_seqnum
      , i_case_id
      , i_check_type
      , i_alert_type
      , i_expression
      , i_risk_score
      , i_risk_matrix_id
    );
    
    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_check'
          , i_column_name   => 'label'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_check'
          , i_column_name   => 'description'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure modify_check(
    i_id             in      com_api_type_pkg.t_short_id 
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_case_id        in      com_api_type_pkg.t_tiny_id
  , i_check_type     in      com_api_type_pkg.t_dict_value
  , i_alert_type     in      com_api_type_pkg.t_dict_value
  , i_expression     in      com_api_type_pkg.t_name
  , i_risk_score     in      com_api_type_pkg.t_tiny_id
  , i_risk_matrix_id in      com_api_type_pkg.t_tiny_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
) is
    l_event_type   com_api_type_pkg.t_dict_value;
begin
    update frp_check_vw
       set seqnum         = io_seqnum
         , case_id        = i_case_id
         , check_type     = i_check_type
         , alert_type     = i_alert_type
         , expression     = i_expression
         , risk_score     = i_risk_score
         , risk_matrix_id = i_risk_matrix_id
     where id             = i_id;
     
    io_seqnum := io_seqnum + 1;
    
    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_check'
          , i_column_name   => 'label'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_check'
          , i_column_name   => 'description'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure remove_check(
    i_id           in      com_api_type_pkg.t_tiny_id  
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) is
begin
    update frp_check_vw
       set seqnum  = i_seqnum
     where id      = i_id;
     
    delete frp_check_vw
     where id      = i_id;
     
    com_api_i18n_pkg.remove_text(
        i_table_name        => 'frp_check'
      , i_object_id         => i_id
    );
end;

end;
/
