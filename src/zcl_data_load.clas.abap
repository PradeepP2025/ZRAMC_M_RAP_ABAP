CLASS zcl_data_load DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES       if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_data_load IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.



    " delete existing entries in the database table

    DELETE FROM ztravel_ramc_m.

    DELETE FROM zBOOKING_ramc_m.

    DELETE FROM zbooksuppl_ram_m.

    COMMIT WORK.

    " insert travel demo data

    INSERT ztravel_ramc_m FROM (

        SELECT *

          FROM /dmo/travel_m

      ).

    COMMIT WORK.



    " insert booking demo data

    INSERT zbooking_ramc_m FROM (

        SELECT travel_id,booking_id,booking_date,customer_id,carrier_id,connection_id,flight_date,flight_price,currency_code,booking_status
        FROM   /dmo/booking_m

      ).

    COMMIT WORK.

    INSERT zbooksuppl_ram_m FROM (

        SELECT travel_id,booking_id,booking_supplement_id,supplement_id,price,currency_code

          FROM   /dmo/booksuppl_m

      ).
    COMMIT WORK.
    out->write( 'Travel and booking demo data inserted.').
  ENDMETHOD.
ENDCLASS.
