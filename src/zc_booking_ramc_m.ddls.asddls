@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_booking_ramc_m
  as projection on ZI_booking_ramc_m
{
      @Search.defaultSearchElement: true
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      /* Associations */
      _BookingSupp : redirected to composition child ZC_bookingsuppl_ramc_m,
      _Booking_status,
      _Carrier,
      _Connection,
      _Customer,
      _Travel      : redirected to parent ZC_travel_ramc_m
}
