create or replace package body gui_ui_wizard_pkg is
/************************************************************
 * User interface for graphical user interface <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 27.08.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2012-12-20 15:16:11 +0300#$ <br />
 * Revision: $LastChangedRevision: 26384 $ <br />
 * Module: gui_ui_wizard_pkg <br />
 * @headcom
 ************************************************************/

procedure add_wizard (
    o_id                      out com_api_type_pkg.t_tiny_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , i_lang                 in     com_api_type_pkg.t_dict_value
  , i_name                 in     com_api_type_pkg.t_name
  , i_maker_privilege_id   in     com_api_type_pkg.t_short_id default null
  , i_checker_privilege_id in     com_api_type_pkg.t_short_id default null
) is
begin
    o_id := gui_wizard_seq.nextval;
    o_seqnum := 1;

    insert into gui_wizard_vw (
        id
      , seqnum
      , maker_privilege_id
      , checker_privilege_id
    ) values (
        o_id
      , o_seqnum
      , i_maker_privilege_id
      , i_checker_privilege_id
    );

    com_api_i18n_pkg.add_text (
        i_table_name     => 'gui_wizard'
        , i_column_name  => 'name'
        , i_object_id    => o_id
        , i_lang         => i_lang
        , i_text         => i_name
        , i_check_unique => com_api_type_pkg.TRUE
    );

end;

procedure modify_wizard (
    i_id                   in     com_api_type_pkg.t_tiny_id
  , io_seqnum              in out com_api_type_pkg.t_seqnum
  , i_lang                 in     com_api_type_pkg.t_dict_value
  , i_name                 in     com_api_type_pkg.t_name
  , i_maker_privilege_id   in     com_api_type_pkg.t_short_id default null
  , i_checker_privilege_id in     com_api_type_pkg.t_short_id default null
) is
begin
    update gui_wizard_vw
       set seqnum               = io_seqnum
         , maker_privilege_id   = i_maker_privilege_id
         , checker_privilege_id = i_checker_privilege_id
     where id                   = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'gui_wizard'
      , i_column_name  => 'name'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_name
      , i_check_unique => com_api_type_pkg.TRUE
    );

end;

procedure remove_wizard (
    i_id     in     com_api_type_pkg.t_tiny_id
  , i_seqnum in     com_api_type_pkg.t_seqnum
) is
begin
    -- delete wizard step
    for step in (
        select id
             , seqnum
          from gui_wizard_step_vw
         where wizard_id = i_id
    ) loop
        gui_ui_wizard_pkg.remove_wizard_step (
            i_id     => step.id
          , i_seqnum => step.seqnum
        );
    end loop;

    -- remove text
    com_api_i18n_pkg.remove_text (
        i_table_name => 'gui_wizard'
      , i_object_id  => i_id
    );

    update gui_wizard_vw
       set seqnum = i_seqnum
     where id     = i_id;

    -- delete wizard
    delete from gui_wizard_vw
     where id = i_id;
end;
    
procedure add_wizard_step (
    o_id             out com_api_type_pkg.t_tiny_id
  , o_seqnum         out com_api_type_pkg.t_seqnum
  , i_wizard_id   in     com_api_type_pkg.t_tiny_id
  , i_step_order  in     com_api_type_pkg.t_tiny_id
  , i_step_source in     com_api_type_pkg.t_name
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_name        in     com_api_type_pkg.t_name
) is
begin
    o_id     := gui_wizard_step_seq.nextval;
    o_seqnum := 1;

    insert into gui_wizard_step_vw (
        id
      , seqnum
      , wizard_id
      , step_order
      , step_source
    ) values (
        o_id
      , o_seqnum
      , i_wizard_id
      , i_step_order
      , i_step_source
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'gui_wizard_step'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_name
    );

end;

procedure modify_wizard_step (
    i_id          in     com_api_type_pkg.t_tiny_id
  , io_seqnum     in out com_api_type_pkg.t_seqnum
  , i_wizard_id   in     com_api_type_pkg.t_tiny_id
  , i_step_order  in     com_api_type_pkg.t_tiny_id
  , i_step_source in     com_api_type_pkg.t_name
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_name        in     com_api_type_pkg.t_name
) is
begin
    update gui_wizard_step_vw
       set seqnum      = io_seqnum
         , step_order  = i_step_order
         , step_source = i_step_source
     where id          = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'gui_wizard_step'
      , i_column_name  => 'name'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_name
    );

end;

procedure remove_wizard_step (
    i_id      in     com_api_type_pkg.t_tiny_id
  , i_seqnum  in     com_api_type_pkg.t_seqnum
) is
begin
    -- remove text
    com_api_i18n_pkg.remove_text (
        i_table_name => 'gui_wizard_step'
      , i_object_id  => i_id
    );

    update gui_wizard_step_vw
       set seqnum = i_seqnum
     where id     = i_id;

    -- delete wizard step
    delete from gui_wizard_step_vw
     where id = i_id;
end;

end;
/
