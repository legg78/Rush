create or replace package body acm_ui_filter_component_pkg as
/*********************************************************
*  UI for access management filter component<br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 18.05.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_FILTER_COMPONENT_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_filter_id     in     com_api_type_pkg.t_short_id
  , i_name          in     com_api_type_pkg.t_name
  , i_value         in     com_api_type_pkg.t_name
) is
begin
    o_id := acm_filter_component_seq.nextval;
    o_seqnum := 1;
    insert into acm_filter_component_vw(
        id
      , seqnum
      , filter_id
      , name
      , value
    ) values (
        o_id
      , o_seqnum
      , i_filter_id
      , i_name
      , i_value
    );

end add;

procedure modify(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_filter_id     in     com_api_type_pkg.t_short_id
  , i_name          in     com_api_type_pkg.t_name
  , i_value         in     com_api_type_pkg.t_name
) is
begin
    update
        acm_filter_component_vw a
    set
        a.filter_id = i_filter_id
      , a.name = i_name
      , a.value = i_value
      , a.seqnum = io_seqnum
    where
        a.id = i_id;

    io_seqnum := io_seqnum + 1;

end modify;

procedure modify_package(
    i_filter_id     in     com_api_type_pkg.t_short_id
  , i_package       in     com_param_map_tpt
) is
begin
    if i_package is not null then
        -- remove
        delete
            acm_filter_component_vw a
        where
            a.filter_id = i_filter_id
        and a.name not in
            (select b.name from table(cast(i_package as com_param_map_tpt)) b);

        if i_package is not null then
            for i in 1..i_package.count loop
                update acm_filter_component_vw dst
                   set dst.value      = i_package(i).char_value
                 where dst.filter_id  = i_filter_id
                   and dst.name       = i_package(i).name;

                 if sql%rowcount = 0 then
                     insert into acm_filter_component_vw (
                         id
                       , seqnum
                       , filter_id
                       , name
                       , value
                     ) values (
                         acm_filter_component_seq.nextval
                       , 1
                       , i_filter_id
                       , i_package(i).name
                       , i_package(i).char_value
                     );
                 end if;
             end loop;
         end if;
    end if;
end modify_package;

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
  , i_seqnum        in     com_api_type_pkg.t_seqnum
) is
begin
    update acm_filter_component_vw
    set seqnum = i_seqnum where id = i_id;

    delete acm_filter_component_vw where id = i_id;

end remove;

end acm_ui_filter_component_pkg;
/
