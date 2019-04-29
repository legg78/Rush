create unique index pmo_schedule_uk on pmo_schedule (
    event_type
  , entity_type
  , object_id
  , order_id
)
/
