CLASS lhc_zi_travel_ramc_m DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_ramc_m RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_travel_ramc_m RESULT result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_ramc_m~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_ramc_m~copytravel.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_ramc_m~rejecttravel RESULT result.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_ramc_m\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_ramc_m.

ENDCLASS.

CLASS lhc_zi_travel_ramc_m IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lt_entities) = entities.

    DELETE lt_entities WHERE travelid IS NOT INITIAL.
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          =  CONV #( lines( lt_entities ) )
         IMPORTING
            number            = DATA(lv_latest_num)
            returncode        = DATA(lv_return)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_mesg).
        LOOP AT lt_entities INTO DATA(ls_entities).

          APPEND VALUE #( %cid = ls_entities-%cid
                          %key = ls_entities-%key ) TO failed-zi_travel_ramc_m.
          APPEND VALUE #( %cid = ls_entities-%cid
                          %key = ls_entities-%key
                          %msg = lo_mesg ) TO reported-zi_travel_ramc_m.
        ENDLOOP.
        EXIT.
    ENDTRY.
    DATA(lv_curr_num) = lv_latest_num + 1.

    DATA: lt_travel_m TYPE TABLE FOR MAPPED EARLY zi_travel_ramc_m,
          ls_travel_m LIKE LINE OF lt_travel_m.

    LOOP AT lt_entities INTO ls_entities.
      lv_curr_num = lv_curr_num + 1.
      APPEND VALUE #( %cid = ls_entities-%cid
                      travelid = lv_curr_num ) TO mapped-zi_travel_ramc_m.
    ENDLOOP.
  ENDMETHOD.
  METHOD earlynumbering_cba_Booking.

    DATA: lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel_ramc_m IN LOCAL MODE
    ENTITY zi_travel_ramc_m BY  \_Booking FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_group_entity>) GROUP BY <fs_group_entity>-TravelId .

      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                               FOR ls_link IN lt_link_data USING KEY entity
                                  WHERE ( source-travelid = <fs_group_entity>-travelid )
                                  NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
                                                                      THEN ls_link-target-BookingId
                                                                      ELSE lv_max ) ).
      lv_max_booking = REDUCE #( INIT lv_max = lv_max_booking
                                 FOR ls_entity IN entities USING KEY entity
                                     WHERE ( travelid = <fs_group_entity>-travelid )
                                 FOR ls_booking IN ls_entity-%target
                                 NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_booking-BookingId
                                                                     THEN ls_booking-BookingId
                                                                     ELSE lv_max  ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>) USING KEY entity
       WHERE travelid = <fs_group_entity>-TravelId.

        LOOP AT <fs_entities>-%target ASSIGNING FIELD-SYMBOL(<fs_booking>).
          APPEND CORRESPONDING #( <fs_booking> ) TO mapped-zi_booking_ramc_m ASSIGNING FIELD-SYMBOL(<fs_new_map_book>).

          IF <fs_booking>-BookingId IS INITIAL.
            lv_max_booking += 10.
            <fs_new_map_book>-bookingid = lv_max_booking.

          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
  METHOD acceptTravel.
  ENDMETHOD.

  METHOD copyTravel.

    DATA: it_travel        TYPE TABLE FOR CREATE zi_travel_ramc_m,
          it_booking_cba   TYPE TABLE FOR CREATE zi_travel_ramc_m\_Booking,
          it_booksuppl_cba TYPE TABLE FOR CREATE zi_booking_ramc_m\_BookingSupp.



    READ TABLE keys ASSIGNING FIELD-SYMBOL(<fs_without_cids>) WITH KEY %cid = ' '.

    ASSERT <fs_without_cids> IS NOT ASSIGNED.

    READ ENTITIES OF zi_travel_ramc_m IN LOCAL MODE
    ENTITY zi_travel_ramc_m
             ALL FIELDS WITH CORRESPONDING #( keys )
             RESULT DATA(lt_travel_r)
             FAILED DATA(lt_failed).

    READ ENTITIES OF zi_travel_ramc_m IN LOCAL MODE
    ENTITY zi_travel_ramc_m BY \_Booking
           ALL FIELDS WITH CORRESPONDING #( lt_travel_r )
           RESULT DATA(lt_booking_r).

    READ ENTITIES OF zi_travel_ramc_m IN LOCAL MODE
    ENTITY zi_booking_ramc_m BY \_BookingSupp
           ALL FIELDS WITH CORRESPONDING #( lt_booking_r )
           RESULT DATA(lt_booking_supp_r).



    LOOP AT lt_travel_r ASSIGNING FIELD-SYMBOL(<ls_travel_r>).


      APPEND VALUE #(  %cid =  keys[ KEY entity travelid = <ls_travel_r>-travelid ]-%cid
                         %data = CORRESPONDING #( <ls_travel_r> EXCEPT travelid ) )
                      TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-EndDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-OverallStatus = 'O'.

      APPEND VALUE #( %cid_ref = <ls_travel>-%cid  ) TO it_booking_cba ASSIGNING FIELD-SYMBOL(<it_booking>).


      LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<ls_booking_r>) USING KEY entity
                                                                  WHERE travelid = <ls_travel_r>-travelid.

        APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId
                        %data = CORRESPONDING #( <ls_booking_r> EXCEPT travelid )  ) TO <it_booking>-%target ASSIGNING
                        FIELD-SYMBOL(<ls_booking_n>).

        <ls_booking_n>-BookingStatus = 'N'.

        APPEND VALUE #( %cid_ref = <ls_booking_n>-%cid ) TO it_booksuppl_cba ASSIGNING FIELD-SYMBOL(<ls_booksupp>).


        LOOP AT lt_booking_supp_r ASSIGNING FIELD-SYMBOL(<ls_booking_supp_r>) USING KEY entity
                 WHERE travelid = <ls_travel_r>-TravelId AND bookingid = <ls_booking_r>-BookingId.

          APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId &&  <ls_booking_supp_r>-BookingSupplementId
                          %data = CORRESPONDING #(  <ls_booking_supp_r> EXCEPT travelid BookingId ) )
                          TO <ls_booksupp>-%target.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_ramc_m IN LOCAL MODE

       ENTITY zi_travel_ramc_m
       CREATE FIELDS ( AgencyID CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
       WITH it_travel

       ENTITY zi_travel_ramc_m CREATE BY \_Booking
       FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus  )
       WITH it_booking_cba
       ENTITY zi_booking_ramc_m
       CREATE BY \_BookingSupp
       FIELDS ( BookingsupplementId SupplementId Price CurrencyCode )
       WITH it_booksuppl_cba
       MAPPED DATA(it_mapped).

    mapped-zi_travel_ramc_m = it_mapped-zi_travel_ramc_m.




  ENDMETHOD.

  METHOD rejectTravel.
  ENDMETHOD.

ENDCLASS.
