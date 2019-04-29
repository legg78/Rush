create table vis_tcr3(
    id                          number(16)
  , trans_comp_number           varchar2(1)
  , business_application_id     varchar2(2)
  , business_format_code        varchar2(2)
  , passenger_name              varchar2(20)
  , departure_date              date
  , orig_city_airport_code      varchar2(3)
  , carrier_code_1              varchar2(2)
  , service_class_code_1        varchar2(1)
  , stop_over_code_1            varchar2(1)
  , dest_city_airport_code_1    varchar2(3)
  , carrier_code_2              varchar2(2)
  , service_class_code_2        varchar2(1)
  , stop_over_code_2            varchar2(1)
  , dest_city_airport_code_2    varchar2(3)
  , carrier_code_3              varchar2(2)
  , service_class_code_3        varchar2(1)
  , stop_over_code_3            varchar2(1)
  , dest_city_airport_code_3    varchar2(3)
  , carrier_code_4              varchar2(2)
  , service_class_code_4        varchar2(1)
  , stop_over_code_4            varchar2(1)
  , dest_city_airport_code_4    varchar2(3)
  , travel_agency_code          varchar2(8)
  , travel_agency_name          varchar2(25)
  , restrict_ticket_indicator   varchar2(1)
  , fare_basis_code_1           varchar2(6)
  , fare_basis_code_2           varchar2(6)
  , fare_basis_code_3           varchar2(6)
  , fare_basis_code_4           varchar2(6)
  , comp_reserv_system          varchar2(4)
  , flight_number_1             varchar2(5)
  , flight_number_2             varchar2(5)
  , flight_number_3             varchar2(5)
  , flight_number_4             varchar2(5)
  , credit_reason_indicator     varchar2(1)
  , ticket_change_indicator     varchar2(1)
)
/
comment on table vis_tcr3 is 'VISA TCR3 data table.'
/
comment on column vis_tcr3.id is 'Primary key. VISA financial message identifier.'
/
comment on column vis_tcr3.trans_comp_number is 'Transaction Component Sequence Number.'
/
comment on column vis_tcr3.business_application_id is 'Business Application Identifier.'
/
comment on column vis_tcr3.business_format_code is 'Business Format Code.'
/
comment on column vis_tcr3.passenger_name is 'Passenger Name.'
/
comment on column vis_tcr3.departure_date is 'Departure Date in format: MMDDYY.'
/
comment on column vis_tcr3.orig_city_airport_code is 'Origination City/Airport Code.'
/
comment on column vis_tcr3.carrier_code_1 is 'Trip Leg 1 Information. Carrier Code.'
/
comment on column vis_tcr3.service_class_code_1 is 'Trip Leg 1 Information. Service Class.'
/
comment on column vis_tcr3.stop_over_code_1 is 'Trip Leg 1 Information. Stop-Over Code.'
/
comment on column vis_tcr3.dest_city_airport_code_1 is 'Trip Leg 1 Information. Destination City/Airport Code.'
/
comment on column vis_tcr3.carrier_code_2 is 'Trip Leg 2 Information. Carrier Code.'
/
comment on column vis_tcr3.service_class_code_2 is 'Trip Leg 2 Information. Service Class.'
/
comment on column vis_tcr3.stop_over_code_2 is 'Trip Leg 2 Information. Stop-Over Code.'
/
comment on column vis_tcr3.dest_city_airport_code_2 is 'Trip Leg 2 Information. Destination City/Airport Code.'
/
comment on column vis_tcr3.carrier_code_3 is 'Trip Leg 3 Information. Carrier Code.'
/
comment on column vis_tcr3.service_class_code_3 is 'Trip Leg 3 Information. Service Class.'
/
comment on column vis_tcr3.stop_over_code_3 is 'Trip Leg 3 Information. Stop-Over Code.'
/
comment on column vis_tcr3.dest_city_airport_code_3 is 'Trip Leg 3 Information. Destination City/Airport Code.'
/
comment on column vis_tcr3.carrier_code_4 is 'Trip Leg 4 Information. Carrier Code.'
/
comment on column vis_tcr3.service_class_code_4 is 'Trip Leg 4 Information. Service Class.'
/
comment on column vis_tcr3.stop_over_code_4 is 'Trip Leg 4 Information. Stop-Over Code.'
/
comment on column vis_tcr3.dest_city_airport_code_4 is 'Trip Leg 4 Information. Destination City/Airport Code.'
/
comment on column vis_tcr3.travel_agency_code is 'Travel Agency Code'
/
comment on column vis_tcr3.travel_agency_name is 'Travel Agency Name'
/
comment on column vis_tcr3.restrict_ticket_indicator is 'Restricted Ticket Indicator'
/
comment on column vis_tcr3.fare_basis_code_1 is 'Fare Basis Code - Leg 1'
/
comment on column vis_tcr3.fare_basis_code_2 is 'Fare Basis Code - Leg 2'
/
comment on column vis_tcr3.fare_basis_code_3 is 'Fare Basis Code - Leg 3'
/
comment on column vis_tcr3.fare_basis_code_4 is 'Fare Basis Code - Leg 4'
/
comment on column vis_tcr3.comp_reserv_system is 'Computerized Reservation System'
/
comment on column vis_tcr3.flight_number_1 is 'Flight Number - Leg 1'
/
comment on column vis_tcr3.flight_number_2 is 'Flight Number - Leg 2'
/
comment on column vis_tcr3.flight_number_3 is 'Flight Number - Leg 3'
/
comment on column vis_tcr3.flight_number_4 is 'Flight Number - Leg 4'
/
comment on column vis_tcr3.credit_reason_indicator is 'Credit Reason Indicator'
/
comment on column vis_tcr3.ticket_change_indicator is 'Ticket Change Indicator'
/
