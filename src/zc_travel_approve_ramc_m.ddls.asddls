@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Approver Projection view'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: { type: #STANDARD,
             value: 'TravelId'
           }}
define root view entity ZC_travel_approve_ramc_m
  provider contract transactional_query
  as projection on zi_travel_ramc_m
{
      @UI.facet: [{

          id: 'Travel',
          purpose: #STANDARD,
          label: 'Travel',
          type: #IDENTIFICATION_REFERENCE,
          position: 10 },
          {  id: 'Booking',
          purpose: #STANDARD,
          label: 'Booking',
          type: #LINEITEM_REFERENCE,
          position: 20 ,
          targetElement: '_Booking' }]
      @UI: { lineItem: [{ position: 10, importance: #HIGH }],
             identification: [{ position: 10 }]}
      @Search.defaultSearchElement: true
  key TravelId,
      @UI: { lineItem: [{ position: 20, importance: #HIGH }],
                identification: [{ position: 20 }],
                selectionField: [{ position: 10 }]}
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: '/DMO/I_Agency',
              element: 'AgencyID' }}]
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Search.defaultSearchElement: true
      AgencyId,
      _Agency.Name       as AgencyName,
      @UI: { lineItem: [{ position: 30, importance: #HIGH }],
                      identification: [{ position: 30 }],
                      selectionField: [{ position: 20 }]}
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: '/DMO/I_Customer',
              element: 'CustomerID' }}]
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Search.defaultSearchElement: true
      CustomerId,
      _Customer.LastName as CustomerName,
      @UI: { identification: [ { position: 40 }]}
      BeginDate,
      @UI: { identification: [ { position: 50 }]}
      EndDate,
      @UI: { lineItem: [{ position: 50, importance: #HIGH }],
                      identification: [{ position: 60 }]}
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @UI: { lineItem: [{ position: 60, importance: #HIGH }],
                      identification: [{ position: 70 }]}
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'I_Currency',
              element: 'Currency'
          }}]
      CurrencyCode,
      Description,
      @UI: { lineItem: [{ position: 15, importance: #HIGH },
                         { type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'AcceptTravel' },
                         { type: #FOR_ACTION, dataAction: 'rejectTravel', label: 'rejectTravel'}],
              identification: [{ position: 15 },
                               { type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'AcceptTravel'},
                               { type: #FOR_ACTION, dataAction: 'rejectTravel', label: 'RejectTravel'}],
              textArrangement: #TEXT_ONLY,
              selectionField: [{ position: 40 }]}
      @EndUserText.label: 'Overall Status'
      @Consumption.valueHelpDefinition: [{
          qualifier: '',
          entity: {
              name: '/DMO/I_Overall_Status_VH',
              element: 'OverallStatus'
          }}]
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      OverallStatus,
      @UI.hidden: true
      _Status._Text.Text as OverallStatusText : localized,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_booking_approve_ramc_m,
      _Currency,
      _Customer,
      _Status
}
