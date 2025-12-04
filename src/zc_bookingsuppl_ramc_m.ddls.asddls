@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking supplement projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_bookingsuppl_ramc_m
  as projection on ZI_booksuppl_ramc_m
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      /* Associations */
      _Booking : redirected to parent ZC_booking_ramc_m,
      _Supplement,
      _SupplementText,
      _Travel  : redirected to ZC_travel_ramc_m
}
