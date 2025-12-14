CLASS zcl_rap_entity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_rap_entity IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

** Create entity data

    DATA: lt_book TYPE TABLE FOR CREATE zi_travel_ramc_m.

** Read Entity

    READ ENTITY zi_travel_ramc_m
    FROM VALUE #(  (
                     %key-TravelId = '00004427'
                     %control = VALUE #(
                          agencyid = if_abap_behv=>mk-on
                          customerid = if_abap_behv=>mk-on

                      ) )
                     )
      RESULT DATA(lt_result)
      FAILED DATA(lt_fail).

    out->write( lt_result ).
    out->write( lt_fail ).

    MODIFY ENTITY zi_travel_ramc_m
    DELETE FROM VALUE #( ( %key-TravelId = '00004427' ) )
    FAILED DATA(lt_failed)
    MAPPED DATA(lt_map)
    REPORTED DATA(lt_reported).


    MODIFY ENTITY zi_booking_ramc_m
    DELETE FROM VALUE #( (  %key-TravelId = '00004437'
                            %key-BookingId = '10') )
    FAILED DATA(lt_fail1)
    MAPPED DATA(lt_maped)
    REPORTED DATA(lt_rep).



    MODIFY ENTITY zi_travel_ramc_m
    CREATE AUTO FILL CID WITH VALUE #(  (  %data-begindate = '20251225'
                                           %control-BeginDate = if_abap_behv=>mk-on   ) )
    FAILED DATA(lt_f)
    MAPPED DATA(lt_m)
    REPORTED DATA(lt_r).



    MODIFY ENTITY zi_travel_ramc_m
    UPDATE SET FIELDS WITH VALUE #(  ( %key-TravelId = '00004423'
                                       begindate = '20260202' ) ).




    MODIFY ENTITIES OF zi_travel_ramc_m

    ENTITY zI_travel_ramc_m
    UPDATE FIELDS ( begindate ) WITH VALUE  #( ( %key-TravelId = '00004345'
                                               begindate = '20260101' ) )
    ENTITY zi_travel_ramc_m
    DELETE FROM VALUE #( ( travelid = '00004244' ) ).


*   MODIFY ENTITY  zi_travel_ramc_m

*    CREATE FROM VALUE #(  (

*         %cid = 'cid1'
*         %data-BeginDate = '20251211'
*         %control-BeginDate = if_abap_behv=>mk-on


*     ) )

** Create  Association
*CREATE BY \_Booking
*FROM VALUE #( (
*    %cid_ref = 'cid1'
*    %target = VALUE #( (
*        %cid = 'cid1'
*        %data-BookingDate = '20251211'
*        %control-BookingDate = if_abap_behv=>mk-on


*     ) )



*) )

*     FAILED FINAL(lt_failed)
*     MAPPED FINAL(lt_mapped)
*     REPORTED FINAL(lt_result).



    IF lt_failed IS NOT INITIAL.
      out->write( lt_failed ).
    ELSE.
      COMMIT ENTITIES.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
