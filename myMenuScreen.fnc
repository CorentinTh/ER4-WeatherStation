
/*
      - Weather station project -
    ER4 - IUT Annecy-Le-vieux - 2017

       • Anne LENSING
       • Helena STICKELBROECK
       • Cyrille DUPONT
       • Corentin THOMASSET
*/


func menuScreen()
    var loop := 1;
    var xtouched, ytouched;

    img_Show(hndl, glbBackgroundType); // We display the background
    img_Show(hndl, IMAGE_MENU_PANEL);  // We display the button "SETTINGS" & "HISTORIC"
    img_Show(hndl, IMAGE_BACK);        // We dsiplay the back button (top left corner)

    while(1 == loop)

        // We check if an interaction occured
        if(getTouchStatus() == TOUCH_PRESSED)
            // We get the X and Y coordinates of the touched point
            xtouched := touch_Get(TOUCH_GETX);
            ytouched := touch_Get(TOUCH_GETY);

            if(isDotInBox(xtouched, ytouched,0,0,80,42))  // Back button
                  glbStateDispaly := STATE_MAIN_SCREEN;   // We change the state of the display : we go back to the main screen ...
                  loop := 0;                              // ... and we go out of the while loop
            else
                if(isDotInBox(xtouched, ytouched,95,70,130,40))  // Setting button
                    glbStateDispaly := STATE_SETTING;            // We change the state of the display : we go back to the setting screen ...
                    loop := 0;                                   // ... and we go out of the while loop
                else
                    if(isDotInBox(xtouched, ytouched,95,133,130,40))  // Historic button
                       glbStateDispaly := STATE_HISTORIC;             // We change the state of the display : we go back to the historic screen ...
                       loop := 0;                                     // ... and we go out of the while loop
                    endif
                endif
            endif
        endif
    wend
endfunc
