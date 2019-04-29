create or replace package body dsp_ui_scale_selection_pkg as
/*********************************************************
 *  UI dispute scale type selection <br/>
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 25.05.2017 <br/>
 *  Module: DSP_UI_SCALE_SELECTION_PKG <br/>
 *  @headcom
 **********************************************************/

/*
 * Add new selection of a dispute scale type.
 * @i_mod_id    - modifier should be from a scale of type SCTPDCNS.
 */
procedure add(
    o_id                       out com_api_type_pkg.t_tiny_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_scale_type            in     com_api_type_pkg.t_dict_value
  , i_mod_id                in     com_api_type_pkg.t_tiny_id
  , i_init_rule_id          in     com_api_type_pkg.t_tiny_id
  , i_label                 in     com_api_type_pkg.t_name
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
) is
begin
    o_id     := dsp_scale_selection_seq.nextval;
    o_seqnum := 1;

    com_api_dictionary_pkg.check_article(
        i_dict => rul_api_const_pkg.SCALE_TYPE_DICTIONARY
      , i_code => i_scale_type
    );

    insert into dsp_scale_selection_vw(
        id
      , seqnum
      , scale_type
      , mod_id
      , init_rule_id
    ) values (
        o_id
      , o_seqnum
      , i_scale_type
      , i_mod_id
      , i_init_rule_id
    );

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'dsp_scale_selection'
      , i_column_name => 'label'
      , i_object_id   => o_id
      , i_text        => i_label
      , i_lang        => i_lang
    );

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'dsp_scale_selection'
      , i_column_name => 'description'
      , i_object_id   => o_id
      , i_text        => i_description
      , i_lang        => i_lang
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_SCALE_TYPE_SELECTION'
          , i_env_param1 => o_id
          , i_env_param2 => i_scale_type
          , i_env_param3 => i_mod_id
        );
end add;

procedure modify(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_scale_type            in     com_api_type_pkg.t_dict_value
  , i_mod_id                in     com_api_type_pkg.t_tiny_id
  , i_init_rule_id          in     com_api_type_pkg.t_tiny_id
  , i_label                 in     com_api_type_pkg.t_name
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
) is
begin
    update dsp_scale_selection_vw
       set seqnum       = io_seqnum
         , scale_type   = i_scale_type
         , mod_id       = i_mod_id
         , init_rule_id = i_init_rule_id
     where id           = i_id;

    io_seqnum := io_seqnum + 1;

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'dsp_scale_selection'
      , i_column_name => 'label'
      , i_object_id   => i_id
      , i_text        => i_label
      , i_lang        => i_lang
    );

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'dsp_scale_selection'
      , i_column_name => 'description'
      , i_object_id   => i_id
      , i_text        => i_description
      , i_lang        => i_lang
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_SCALE_TYPE_SELECTION'
          , i_env_param1 => i_id
          , i_env_param2 => i_scale_type
          , i_env_param3 => i_mod_id
        );
end modify;

procedure remove(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , i_seqnum                in     com_api_type_pkg.t_seqnum
) is
begin
    update dsp_scale_selection_vw
       set seqnum     = i_seqnum
     where id         = i_id;

    delete from dsp_scale_selection_vw where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'dsp_scale_selection'
      , i_object_id  => i_id
    ); 
end remove;

end;
/
