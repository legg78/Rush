declare l_card_id com_api_type_pkg.t_medium_id; begin for c in (select cc.id from fcl_cycle_counter cc, fcl_cycle_type ct where cc.cycle_type = ct.cycle_type and ct.is_repeating = 1 and cc.entity_type  = 'ENTTCINS') loop select min(card_id) into l_card_id from iss_card_instance where id = c.id; update fcl_cycle_counter set entity_type = 'ENTTCARD', object_id = l_card_id where id = c.id; end loop; end;