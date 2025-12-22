@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface view managed'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_booking_ramc_m
  as select from zbooking_ramc_m
   association        to parent ZI_travel_ramc_m         as _Travel  on  $projection.TravelId = _Travel.TravelId
  composition [0..*] of ZI_booksuppl_ramc_m      as _BookingSupp
  association [1..1] to /DMO/I_Carrier           as _Carrier        on  $projection.CarrierId = _Carrier.AirlineID
  association [1..1] to /DMO/I_Customer          as _Customer       on  $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Connection        as _Connection     on  $projection.CarrierId    = _Connection.AirlineID
                                                                    and $projection.ConnectionId = _Connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _Booking_status on  $projection.BookingStatus = _Booking_status.BookingStatus
{
  key travel_id      as TravelId,
  key booking_id     as BookingId,
      booking_date   as BookingDate,
      customer_id    as CustomerId,
      carrier_id     as CarrierId,
      connection_id  as ConnectionId,
      flight_date    as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price   as FlightPrice,
      currency_code  as CurrencyCode,
      booking_status as BookingStatus,
      _Carrier,
      _Customer,
      _Connection,
      _Booking_status,
      _Travel,
      _BookingSupp
}
