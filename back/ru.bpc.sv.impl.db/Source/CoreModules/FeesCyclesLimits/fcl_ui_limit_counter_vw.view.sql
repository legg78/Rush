create or replace force view fcl_ui_limit_counter_vw as
select a.id
     , a.entity_type
     , a.object_id
     , a.limit_type
     , fcl_api_limit_pkg.get_limit_count_curr(a.limit_type, a.entity_type, a.object_id) count_value
     , fcl_api_limit_pkg.get_limit_sum_curr(a.limit_type, a.entity_type, a.object_id) sum_value
     , case when b.next_date > get_sysdate or b.next_date is null then a.prev_count_value else a.count_value end prev_count_value
     , case when b.next_date > get_sysdate or b.next_date is null then a.prev_sum_value else a.sum_value end prev_sum_value
     , case when b.next_date > get_sysdate or b.next_date is null then a.last_reset_date else b.next_date end last_reset_date
     , a.split_hash
     , a.inst_id
     , a.sum_limit
     , a.limit_currency
     , a.count_limit
     , case when b.next_date > get_sysdate or b.next_date is null then b.next_date
            else fcl_api_cycle_pkg.calc_next_date(b.cycle_type, a.entity_type, a.object_id, a.split_hash, get_sysdate)
       end next_date
     , b.cycle_type
     , com_api_i18n_pkg.get_text('prd_attribute', 'short_name', pa.id) as short_name
  from (
        select c.id
             , c.entity_type
             , c.object_id
             , c.limit_type
             , c.count_value
             , c.sum_value
             , c.prev_count_value
             , c.prev_sum_value
             , c.last_reset_date
             , c.split_hash
             , c.inst_id
             , t.cycle_type
             , fcl_api_limit_pkg.get_sum_limit(c.limit_type, c.entity_type, c.object_id, null,1) sum_limit
             , fcl_api_limit_pkg.get_limit_currency(c.limit_type, c.entity_type, c.object_id, null,1) limit_currency
             , fcl_api_limit_pkg.get_count_limit(c.limit_type, c.entity_type, c.object_id) count_limit
          from fcl_limit_counter c
             , fcl_limit_type t
         where c.limit_type = t.limit_type
       ) a
     , fcl_cycle_counter b
     , prd_attribute pa
 where a.cycle_type  = b.cycle_type(+)
   and a.entity_type = b.entity_type(+)
   and a.object_id   = b.object_id(+)
   and pa.object_type(+) = a.limit_type
   and pa.entity_type(+) = a.entity_type
/
