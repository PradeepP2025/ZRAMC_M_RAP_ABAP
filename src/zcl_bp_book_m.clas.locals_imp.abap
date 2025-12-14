CLASS lhc_zi_booking_ramc_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE ZI_booking_ramc_m\_Bookingsupp.

ENDCLASS.

CLASS lhc_zi_booking_ramc_m IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    DATA: lv_max_booking_supp_id TYPE  /dmo/booking_supplement_id.

    READ ENTITIES OF zi_travel_ramc_m IN LOCAL MODE

    ENTITY zi_booking_ramc_m BY  \_BookingSupp FROM CORRESPONDING #( entities )
    LINK DATA(lt_booking_supplements).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_group_entity>) GROUP BY <fs_group_entity>-%tky.

      lv_max_booking_supp_id = REDUCE #( INIT lv_max = CONV /dmo/booking_supplement_id( '0' )
                               FOR ls_supp IN lt_booking_supplements USING KEY entity
                                  WHERE ( source-travelid = <fs_group_entity>-travelid AND
                                         source-bookingid = <fs_group_entity>-BookingId )
                                  NEXT lv_max = COND /dmo/booking_supplement_id( WHEN ls_supp-target-bookingsupplementid > lv_max
                                                                      THEN ls_supp-target-bookingsupplementid
                                                                      ELSE lv_max ) ).
      lv_max_booking_supp_id = REDUCE #( INIT lv_max = lv_max_booking_supp_id
                                 FOR ls_entity IN entities USING KEY entity
                                     WHERE ( travelid = <fs_group_entity>-travelid AND
                                             bookingid = <fs_group_entity>-BookingId )
                                 FOR ls_booking IN ls_entity-%target
                                 NEXT lv_max = COND /dmo/booking_supplement_id( WHEN ls_booking-bookingsupplementid > lv_max
                                                                     THEN ls_booking-bookingsupplementid
                                                                     ELSE lv_max  ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>) USING KEY entity
       WHERE travelid = <fs_group_entity>-TravelId AND bookingid = <fs_group_entity>-BookingId.

        LOOP AT <fs_entities>-%target ASSIGNING FIELD-SYMBOL(<fs_booking>).
          APPEND CORRESPONDING #( <fs_booking> ) TO mapped-zi_booksuppl_ramc_m ASSIGNING FIELD-SYMBOL(<fs_new_map_book>).
          IF <fs_booking>-BookingSupplementId IS INITIAL.
            lv_max_booking_supp_id += 1.
            <fs_new_map_book>-BookingSupplementId = lv_max_booking_supp_id.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
