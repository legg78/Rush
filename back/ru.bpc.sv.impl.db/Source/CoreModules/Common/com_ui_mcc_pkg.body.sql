create or replace package body com_ui_mcc_pkg as
/********************************************************* 
 *  Acquiring application API  <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 12.10.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: com_ui_mcc_pkg <br /> 
 *  @headcom 
 **********************************************************/
procedure add_mcc(
    o_id                     out  com_api_type_pkg.t_medium_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_mcc                 in      com_api_type_pkg.t_mcc
  , i_tcc                 in      com_api_type_pkg.t_dict_value
  , i_diners_code         in      com_api_type_pkg.t_dict_value
  , i_mastercard_cab_type in      com_api_type_pkg.t_dict_value
  , i_name                in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value   default null
) is
begin
    o_id     := com_mcc_seq.nextval;
    o_seqnum := 1;

    insert into com_mcc_vw(
        id
      , seqnum
      , mcc
      , tcc
      , diners_code
      , mastercard_cab_type
    ) values (
        o_id
      , o_seqnum
      , i_mcc
      , i_tcc
      , i_diners_code
      , i_mastercard_cab_type
    );

    if i_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'COM_MCC'
          , i_column_name  => 'NAME'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_name
        );
    end if;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_MCC'
          , i_env_param1 => i_mcc
        );
end;

procedure modify_mcc(
    i_id                  in     com_api_type_pkg.t_medium_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_mcc                 in     com_api_type_pkg.t_mcc
  , i_tcc                 in     com_api_type_pkg.t_dict_value
  , i_diners_code         in     com_api_type_pkg.t_dict_value
  , i_mastercard_cab_type in     com_api_type_pkg.t_dict_value
  , i_name                in     com_api_type_pkg.t_name
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is
begin
    update com_mcc_vw
       set seqnum              = io_seqnum
         , mcc                 = i_mcc
         , tcc                 = i_tcc
         , diners_code         = i_diners_code
         , mastercard_cab_type = i_mastercard_cab_type
     where id                  = i_id;
     
    io_seqnum  := io_seqnum + 1;
    
    if i_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'COM_MCC'
          , i_column_name  => 'NAME'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_name
        );
    end if;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_MCC'
          , i_env_param1 => i_mcc
        );
end;

procedure remove_mcc(
    i_id                  in     com_api_type_pkg.t_short_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
) is
begin
    update com_mcc_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete com_mcc_vw
     where id     = i_id;
     
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'COM_MCC'
      , i_object_id    => i_id
    );
end;


end;
/
