create or replace package body acq_ui_merchant_tree_pkg as
/*********************************************************
 *  UI for acquiring merchant type tree <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 18.09.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: acq_ui_merchant_tree_pkg  <br />
 *  @headcom
 **********************************************************/
procedure add_merchant_branch(
    io_branch_id        in out  com_api_type_pkg.t_tiny_id
  , i_merchant_type     in      com_api_type_pkg.t_dict_value
  , i_parent_type       in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_merchant_type     com_api_type_pkg.t_dict_value;
    l_cnt               com_api_type_pkg.t_count := 0;
begin
    if i_merchant_type = acq_api_const_pkg.MERCHANT_TYPE_TERMINAL and i_parent_type is null then
        com_api_error_pkg.raise_error(
            i_error         => 'BAD_ROOT_MERCHANT'
          , i_env_param1    => i_merchant_type
        );
    end if;

    if i_parent_type is not null then
        select count(id)
          into l_cnt
          from acq_merchant_type_tree_vw
         where merchant_type = i_parent_type
           and inst_id       = i_inst_id;
        if l_cnt = 0 then
            com_api_error_pkg.raise_error(
                i_error         => 'PARENT_MERCHANT_NOT_FOUND_IN_TREE'
              , i_env_param1    => i_parent_type
            );
        end if;
    end if;

    if i_merchant_type is null then
        com_api_error_pkg.raise_error(
            i_error  => 'MERCHANT_TYPE_NOT_DEFINED'
        );
    end if;

    if i_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error  => 'INSTITUTION_NOT_DEFINED'
        );
    end if;

    if i_parent_type = acq_api_const_pkg.MERCHANT_TYPE_TERMINAL then
        com_api_error_pkg.raise_error(
            i_error           => 'INCORRECT_PARENT_MERCHANT_TYPE'
            , i_env_param1    => i_parent_type
        );
    end if;

    begin
        io_branch_id :=  acq_merchant_type_tree_seq.nextval;

        insert into acq_merchant_type_tree_vw(
            id
          , merchant_type
          , parent_merchant_type
          , inst_id
          , seqnum
        ) values (
            io_branch_id
          , i_merchant_type
          , i_parent_type
          , i_inst_id
          , 1
        );
    exception
       when dup_val_on_index then
           com_api_error_pkg.raise_error(
               i_error       =>  'DUPLICATE_TYPE_TREE'
             , i_env_param1  =>  i_merchant_type
             , i_env_param2  =>  i_parent_type
             , i_env_param3  =>  ost_ui_institution_pkg.get_inst_name(i_inst_id)
           );
    end;

    select count(1) cnt
         , min(merchant_type) keep (dense_rank first order by lvl) t
      into l_cnt
         , l_merchant_type
      from (
          select connect_by_iscycle is_cycle
               , merchant_type
               , level lvl
          from acq_merchant_type_tree_vw
          connect by nocycle prior merchant_type = parent_merchant_type
            and prior inst_id = inst_id
          start with parent_merchant_type is null and inst_id = i_inst_id
      ) where is_cycle <> 0;

    if l_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'CYCLIC_MERCHANT_TREE_FOUND'
          , i_env_param1 => l_merchant_type
          , i_env_param2 => ost_ui_institution_pkg.get_inst_name(i_inst_id, com_ui_user_env_pkg.get_user_lang)
        );

    end if;
end;

procedure remove_merchant_branch(
    i_branch_id  in      com_api_type_pkg.t_tiny_id
) is
    l_count              com_api_type_pkg.t_count := 0;
    l_inst_id            com_api_type_pkg.t_inst_id;
    l_merchant_type      com_api_type_pkg.t_dict_value;
begin
    select merchant_type
         , inst_id
      into l_merchant_type
         , l_inst_id
      from acq_merchant_type_tree_vw
     where id = i_branch_id;

    select count(1)
      into l_count
      from acq_merchant_vw
     where (merchant_type, inst_id) in
        (select merchant_type, inst_id
           from acq_merchant_type_tree_vw
          where id = i_branch_id -- parent
          or id in(select id -- childs
                     from acq_merchant_type_tree_vw t1
                    where t1.inst_id                = l_inst_id
                      and t1.id                    != i_branch_id
                  connect by prior t1.merchant_type = t1.parent_merchant_type
                         and prior t1.inst_id       = t1.inst_id
                    start with t1.id                = i_branch_id));
    -- forbid deletting if merhant of this type exists
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'MERCHANT_TYPE_USED'
          , i_env_param1 => l_merchant_type
        );
    end if;
    -- cascade deleting
    delete from acq_merchant_type_tree_vw a
     where a.id = i_branch_id -- parent
        or (a.id, a.inst_id) in -- childs
            (select t1.id, t1.inst_id
              from acq_merchant_type_tree_vw t1
             where t1.inst_id                = l_inst_id
               and t1.id                    != i_branch_id
           connect by prior t1.merchant_type = t1.parent_merchant_type
                  and prior t1.inst_id       = t1.inst_id
             start with t1.id                = i_branch_id);

end;

end;
/

