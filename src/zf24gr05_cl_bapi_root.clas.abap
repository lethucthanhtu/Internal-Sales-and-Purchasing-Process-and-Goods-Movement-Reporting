class zf24gr05_cl_bapi_root definition
*  inheriting from z211_cl_sep490_root
  public
  create public .

  public section.

    " Definition of message structure
*    types: begin of ty_message,
*             delivery      type likp-vbeln,
*             cell_color    type lvc_t_scol,
*             msgid         type msgid,
*             msgty         type msgty,
*             msgty_icon(4),
*             msgno         type msgno,
*             msgtxt        type string,
*           end of ty_message.
    types: ty_message type ZF24GR05_S_MESSAGE.

    " Table types for messages
    types: ty_t_message  type standard table of ty_message with empty key,
           rty_t_message type standard table of ty_message with empty key.

    " Table types for deliveries
    types: ty_delivery    type ty_message-delivery,
           ty_t_delivery  type standard table of ty_delivery,
           rty_t_delivery type standard table of ty_delivery with empty key .       "

    methods constructor.

    " Get successful deliveries
    methods get_success_deliveries
      returning
        value(rt_delivery) type rty_t_delivery .

    " Get failed deliveries
    methods get_failed_deliveries
      returning
        value(rt_delivery) type rty_t_delivery .

    methods:
      display_msg
        importing
          is_display  type abap_bool     " Flag to indicate whether to display messages
          it_messages type ty_t_message. " Input table of messages

  protected section.

    " Internal tables for success and failed deliveries
    data: t_success_delivery type ty_t_delivery,
          t_failed_delivery  type ty_t_delivery.

    " Coordinates for ALV popup
    data: start_column type i, " Starting column of ALV popup
          end_column   type i, " Ending column of ALV popup
          start_line   type i, " Starting line of ALV popup
          end_line     type i. " Ending line of ALV popup

  private section.

    " Reference to ALV table object
    data: lo_alv type ref to cl_salv_table.

    " Method to build the field catalog for ALV
    methods:
      build_fieldcat.

ENDCLASS.



CLASS ZF24GR05_CL_BAPI_ROOT IMPLEMENTATION.


  method build_fieldcat.

    " Build field catalog for ALV display
    try.

        " Get columns object from ALV
        data(lo_columns) = lo_alv->get_columns( ).

        " Optimize column widths
        lo_columns->set_optimize( abap_true ).

        " Set column properties for MSGID
        data(lo_col) = lo_columns->get_column( 'MSGID' ).
        lo_col->set_short_text( 'Msg ID' ).
        lo_col->set_medium_text( 'Message ID' ).
        lo_col->set_long_text( 'Message ID' ).

        " Set column properties for MSGNO
        lo_col = lo_columns->get_column( 'MSGNO' ).
        lo_col->set_short_text( 'Msg. No' ).
        lo_col->set_medium_text( 'Message Number' ).
        lo_col->set_long_text( 'Message Number' ).

        " Set column properties for MSGTY
        lo_col = lo_columns->get_column( 'MSGTY' ).
        lo_col->set_short_text( 'Msg Type' ).
        lo_col->set_medium_text( 'Message Type' ).
        lo_col->set_long_text( 'Message Type' ).

        " Set column properties for MSGTXT
        lo_col = lo_columns->get_column( 'MSGTXT' ).
        lo_col->set_short_text( 'Msg txt' ).
        lo_col->set_medium_text( 'Message Text' ).
        lo_col->set_long_text( 'Message Text' ).

      catch cx_salv_not_found into data(ls_error).

        " Handle exception when a column is not found
        message ls_error->get_longtext( )
          type 'S'
          display like 'E'.

    endtry.

  endmethod. " build_fieldcat


  method constructor.

    super->constructor( ).

    clear: t_success_delivery,
           t_failed_delivery.

    " Set default popup coordinates
    start_column = 25.
    end_column = 100.
    start_line = 6.
    end_line = 10.

  endmethod. " constructor


  method display_msg.

    IF it_messages[] is INITIAL.
      " Return message is empty
      MESSAGE S300(ZF24GR05_MESSAGE)
          DISPLAY LIKE 'E'.

      return.
    ENDIF.

    " Skip display if the flag is false
    if is_display = abap_false.
      return.
    endif.

    " Adjust ending line based on message count
    end_line = end_line + lines( it_messages ).

    " Ensure end line does not exceed the screen limit
    if end_line >= 100.
      end_line = 100.
    endif.

    " Display error messages in ALV if any errors occurred

*    data: lo_alv type ref to cl_salv_table.

    " Prepare messages for display
    data(lt_message) = it_messages.

    try.

        " Create ALV table for message display
        cl_salv_table=>factory(
          importing
            r_salv_table = lo_alv
          changing
            t_table      = lt_message
        ).

        " Set list header for ALV
        lo_alv->get_display_settings( )->set_list_header( text-001 ).

        " Build field catalog for ALV
        me->build_fieldcat( ).

        lo_alv->set_screen_popup(
          start_column = start_column
          end_column   = end_column
          start_line   = start_line
          end_line     = end_line
        ).

        " Display the ALV table
        lo_alv->display( ).

      catch cx_root into data(ls_error).

        " Handle generic errors during ALV display
        message ls_error->get_text( )
          type 'E'.

    endtry.

  endmethod. " display_msg


  method get_failed_deliveries.

    " Remove duplicate failed deliveries
    delete adjacent duplicates
      from t_failed_delivery
      comparing all fields.

    " Return the list of failed deliveries
    rt_delivery = t_failed_delivery.

  endmethod. " get_failed_deliveries


  method get_success_deliveries.

    " Remove duplicate successful deliveries
    delete adjacent duplicates
      from t_success_delivery
      comparing all fields.

    " Return the list of successful deliveries
    rt_delivery = t_success_delivery.

  endmethod. " get_success_deliveries
ENDCLASS.
