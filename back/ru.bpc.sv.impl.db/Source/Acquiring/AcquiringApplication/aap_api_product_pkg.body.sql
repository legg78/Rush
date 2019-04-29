create or replace package body aap_api_product_pkg as
/*********************************************************
*  Process product definition when creating merchant, terminal, etc <br />
*  Created by Fomichev E.(fomichev@bpc.ru)  at 07.06.2010 <br />
*  Module: AAP_API_PRODUCT_PKG <br />
*  @headcom
**********************************************************/

procedure process_product(
    i_product_id           in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
begin
--    for r in (
--        select b.object_type cycle_type
--          from rul_product_attr_mvw a
--             , rul_attr b
--         where a.product_id  = i_product_id
--           and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--           and a.attr_id     = b.id
--           and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE
--        union all
--        select c.cycle_type
--          from rul_product_attr_mvw a
--             , rul_attr b
--             , fcl_fee_type_vw c
--         where a.product_id  = i_product_id
--           and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--           and a.attr_id     = b.id
--           and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--           and c.fee_type    = b.object_type
--           and c.cycle_type is not null
--           and i_entity_type = nvl(c.entity_type, i_entity_type)
--        union all
--        select c.cycle_type
--          from rul_product_attr_mvw a
--             , rul_attr b
--             , fcl_limit_type_vw c
--         where a.product_id  = i_product_id
--           and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--           and a.attr_id     = b.id
--           and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
--           and c.limit_type  = b.object_type
--           and c.cycle_type is not null
--           and i_entity_type = nvl(c.entity_type, i_entity_type)
--        union all
--        select d.cycle_type
--          from rul_product_attr_mvw a
--             , rul_attr b
--             , fcl_fee_type_vw c
--             , fcl_limit_type_vw d
--         where a.product_id  = i_product_id
--           and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--           and a.attr_id     = b.id
--           and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--           and c.fee_type    = b.object_type
--           and c.limit_type is not null
--           and c.limit_type  = d.limit_type
--           and d.cycle_type is not null
--           and i_entity_type = nvl(c.entity_type, i_entity_type)
--    ) loop
--        fcl_api_cycle_pkg.add_cycle_counter(
--            i_cycle_type        => r.cycle_type
--          , i_entity_type       => i_entity_type
--          , i_object_id         => i_object_id
--          , i_inst_id           => i_inst_id
--        );
--    end loop;

--    for r in (
--        select b.object_type limit_type
--          from rul_product_attr_mvw a
--             , rul_attr b
--         where a.product_id  = i_product_id
--           and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--           and a.attr_id     = b.id
--           and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
--        union
--        select c.limit_type
--          from rul_product_attr_mvw a
--             , rul_attr b
--             , fcl_fee_type_vw c
--         where a.product_id  = i_product_id
--           and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--           and a.attr_id     = b.id
--           and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--           and c.fee_type    = b.object_type
--           and c.limit_type is not null
--           and i_entity_type = nvl(c.entity_type, i_entity_type)
--    ) loop
--        fcl_api_limit_pkg.add_limit_counter(
--            i_limit_type   =>  r.limit_type
--          , i_entity_type  =>  i_entity_type
--          , i_object_id    =>  i_object_id
--          , i_inst_id      =>  i_inst_id
--        );
--    end loop;
    null;
end;


procedure change_product(
    i_old_product_id       in            com_api_type_pkg.t_long_id
  , i_new_product_id       in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
    l_date date;
    l_params               com_api_type_pkg.t_param_tab;
begin
--    if i_old_product_id = i_new_product_id then
--        return;
--    end if;
--
--    for r in (
--        select o.cycle_type old_cycle_type, n.cycle_type new_cycle_type
--          from (
--                select b.object_type cycle_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                 where a.product_id  = i_old_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE
--                union all
--                select c.cycle_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_fee_type_vw c
--                 where a.product_id  = i_old_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--                   and c.fee_type    = b.object_type
--                   and c.cycle_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--                union all
--                select c.cycle_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_limit_type_vw c
--                 where a.product_id  = i_old_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
--                   and c.limit_type  = b.object_type
--                   and c.cycle_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--                union all
--                select d.cycle_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_fee_type_vw c
--                     , fcl_limit_type_vw d
--                 where a.product_id  = i_old_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--                   and c.fee_type    = b.object_type
--                   and c.limit_type is not null
--                   and c.limit_type  = d.limit_type
--                   and d.cycle_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--               ) o
--            full join
--               (
--                select b.object_type cycle_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                 where a.product_id  = i_new_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE
--                union all
--                select c.cycle_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_fee_type_vw c
--                 where a.product_id  = i_new_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--                   and c.fee_type    = b.object_type
--                   and c.cycle_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--                union all
--                select c.cycle_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_limit_type_vw c
--                 where a.product_id  = i_new_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
--                   and c.limit_type  = b.object_type
--                   and c.cycle_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--                union all
--                select d.cycle_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_fee_type_vw c
--                     , fcl_limit_type_vw d
--                 where a.product_id  = i_new_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--                   and c.fee_type    = b.object_type
--                   and c.limit_type is not null
--                   and c.limit_type  = d.limit_type
--                   and d.cycle_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--               ) n
--          on o.cycle_type = n.cycle_type
--    ) loop
--
--        if r.old_cycle_type is null and r.new_cycle_type is not null then
--            fcl_api_cycle_pkg.add_cycle_counter(
--                i_cycle_type        => r.new_cycle_type
--              , i_entity_type       => i_entity_type
--              , i_object_id         => i_object_id
--              , i_inst_id           => i_inst_id
--            );
--/*
--        elsif r.old_cycle_id is not null and r.new_cycle_id is not null and r.old_cycle_id != r.new_cycle_id then
--            fcl_api_cycle_pkg.recalc_next_date(
--                i_cycle_type       =>  r.type_new
--              , i_prod_id          =>  r.id_new
--              , i_entity_type      =>  i_entity_type
--              , i_object_id        =>  r.id_new
--              , i_params           =>  l_params
--              , i_split_hash       =>  null
--              , o_new_finish_date  =>  l_date
--            );
--*/
--        elsif r.old_cycle_type is not null and r.new_cycle_type is null then
--            fcl_api_cycle_pkg.remove_cycle_counter(
--                i_cycle_type        => r.old_cycle_type
--              , i_entity_type       => i_entity_type
--              , i_object_id         => i_object_id
--            );
--        else
--            null;
--        end if;
--
--    end loop;
--
--    for r in (
--        select o.limit_type old_limit_type, n.limit_type new_limit_type
--          from (
--                select c.limit_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_fee_type_vw c
--                 where a.product_id  = i_old_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--                   and c.fee_type    = b.object_type
--                   and c.limit_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--                union all
--                select c.limit_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_limit_type_vw c
--                 where a.product_id  = i_old_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
--                   and c.limit_type  = b.object_type
--                   and c.limit_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--               ) o
--           full join
--               (
--                select c.limit_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_fee_type_vw c
--                 where a.product_id  = i_new_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE
--                   and c.fee_type    = b.object_type
--                   and c.limit_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--                union all
--                select c.limit_type
--                  from rul_product_attr_mvw a
--                     , rul_attr b
--                     , fcl_limit_type_vw c
--                 where a.product_id  = i_new_product_id
--                   and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_ACQ_PRODUCT
--                   and a.attr_id     = b.id
--                   and b.entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
--                   and c.limit_type  = b.object_type
--                   and c.limit_type is not null
--                   and i_entity_type = nvl(c.entity_type, i_entity_type)
--               ) n
--         on o.limit_type = n.limit_type
--    ) loop
--        if r.old_limit_type is null and r.new_limit_type is not null then
--            fcl_api_limit_pkg.add_limit_counter(
--                i_limit_type   =>  r.new_limit_type
--              , i_entity_type  =>  i_entity_type
--              , i_object_id    =>  i_object_id
--              , i_inst_id      =>  i_inst_id
--            );
--/*
--        elsif r.old_limit_id is not null and r.new_limit_id is not null and r.old_limit_id != r.new_limit_id then
--            fcl_api_limit_pkg.zero_limit_counter(
--                i_limit_type   => r.type_old
--              , i_entity_type  => i_entity_type
--              , i_object_id    => i_object_id
--              , i_split_hash   => null
--            );
--*/
--        elsif r.old_limit_type is not null and r.new_limit_type is null then
--            fcl_api_limit_pkg.remove_limit_counter(
--                i_limit_type   => r.old_limit_type
--              , i_entity_type  => i_entity_type
--              , i_object_id    => i_object_id
--            );
--        else
--            null;
--        end if;
--    end loop;
--    --rul_product_fee_mvw
    null;

end;

end;
/
