
 /*
      - Weather station project -
    ER4 - IUT Annecy-Le-vieux - 2017

       • Anne LENSING
       • Helena STICKELBROECK
       • Cyrille DUPONT
       • Corentin THOMASSET
*/


// This function manages the historic
func historicScreen()

    /*
        We want to know if the user has slided on the right or on the left in order to display previous or next value in the historic
        to do that we proceed in this way :

        1.  To detect a slide to the right :
            a.  We check is the user pressed the user in the left
            b.  We check if he has gone to the middle of the display while moving

        2. To detect a slide to the left :
            a.  We check is the user pressed the user in the right
            b.  We check if he has gone to the middle of the display while moving
    */

    var offset := 0;
    var loop := 1;
    var touchStatus;
    var wasOnRight := 0;
    var wasOnleft := 0;
    var x,y;
    var hasSlided := 0;

    // We dispaly the background
    img_Show(hndl, glbBackgroundType);

    // We display the header of the historic pannel (back button + title)
    img_Show(hndl, IMAGE_BACK_HISORIC);

    // We draw the historic
    drawHistoric(0,0);

    while(1 == loop)
        touchStatus := getTouchStatus();
        x := touch_Get(TOUCH_GETX);
        y := touch_Get(TOUCH_GETY);

        // We check if the user is pressing the screen
        if(touchStatus == TOUCH_PRESSED)
            if(isDotInBox(x, y,0,0,80,42))              // Back button
                glbStateDispaly := STATE_MENU_SCREEN;   // We change the state of the display : we go back to the menu screen
                loop := 0;                              // And we go out of the while loop
            else
                if(isInBox(x,y,0, 0, 50, 240))    // Step 1.a : We check if he has pressed on the left of the display
                    wasOnleft:=1;
                endif
                if(isInBox(x,y, 270, 0, 50, 240)) // Step 2.a : We check if he has pressed on the right of the display
                    wasOnRight:=1;
                endif
            endif
        endif

        // We he release, we reset our variables
        if(touchStatus == TOUCH_RELEASED)
            wasOnRight:=0;
            wasOnleft:=0;
            hasSlided := 0;
        endif

        if(touchStatus == TOUCH_MOVING || touchStatus == TOUCH_PRESSED)
            // Step 1.b and 2.b (they are the same) : We check if he has been to the middle of the screen
            if(isInBox(x,y, 100, 0, 120, 240) && (1 == wasOnleft || 1 == wasOnRight) && (0 == hasSlided))
                hasSlided := 1;

                // If he can from the left we decrease our offset
                if(1 == wasOnleft)
                    offset -= (offset == 0) ? 0 : 1;
                endif

                // If he can from the right we increase our offset
                if(1 == wasOnRight)
                    offset ++;
                endif

                // Then we update only the historic (not the header on the top)
                myClipWindow(0, 26, 320, 214);
                gfx_Clipping(ON);
                img_Show(hndl, glbBackgroundType);
                drawHistoric(0,offset);
                gfx_Clipping(OFF);

            endif
        endif
    wend
endfunc

