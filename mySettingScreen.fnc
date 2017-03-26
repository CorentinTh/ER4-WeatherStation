
/*
      - Weather station project -
    ER4 - IUT Annecy-Le-vieux - 2017

       • Anne LENSING
       • Helena STICKELBROECK
       • Cyrille DUPONT
       • Corentin THOMASSET
*/


// This function manage the setting state
func settingScreen()
    var private stateSetting := 0;

    // We display the background
    img_Show(hndl, glbBackgroundType);
    //We put the image taht permit to toogle between the too setting pannels
    img_SetPosition(hndl, IMAGE_BTN_TOOGLE, 115,215);

    // According to the state, we display either the pannel 0 (basic settings) or the pannel 1 (date / time adjustments)
    switch(stateSetting)
        case 0:
            settingPannel0();
            break;
         case 1:
            settingPannel1();
            break;
    endswitch

endfunc

// This function permit to adjust basic options
func settingPannel0()
    var loop := 1;
    var xtouched, ytouched;
    var oldUnit := -1;
    var oldEcoMode := -1;
    var digit;

    // We display the back button
    img_Show(hndl, IMAGE_BACK);
    // We display the On/Off button that permit to activate or desactivate the eco mode
    img_Show(hndl, IMAGE_ON_OFF);
    // We display the picture that contain all the text of the setting pannel ("Eco mode :", "Units :", ...)
    img_Show(hndl, IMAGE_SETTING_0);

    // We diaply only the rigth arrow of the button that permit to toogle between the two pannels
    myClipWindow(160, 200, 80, 50);
    gfx_Clipping(ON);
    img_Show(hndl, IMAGE_BTN_TOOGLE );
    gfx_Clipping(OFF);

    // We draw circles that permits to know in which pannel you are
    gfx_CircleFilled(150, 222, 4, WHITE);
    gfx_Circle(170, 222, 4, WHITE);

    while(1 == loop)

        // We draw the image that manage the unit (°C or °F) according to the current unit
        // We draw it only if their is the need
        if(oldUnit != glbIsCelcius)
            oldUnit := glbIsCelcius;
            img_SetWord(hndl, IMAGE_CEL_FAR, IMAGE_INDEX, glbIsCelcius);
            myClipWindow(175, 90, 144, 36);
            gfx_Clipping(ON);
            img_Show(hndl, glbBackgroundType);
            img_Show(hndl, IMAGE_CEL_FAR);
            gfx_Clipping(OFF);
        endif

        // We draw the image that manage the eco mode (on/off button)
        // We draw it only if their is the need
        if(oldEcoMode != glbModeSleepOn)
            oldEcoMode := glbModeSleepOn;
            img_SetWord(hndl, IMAGE_ON_OFF, IMAGE_INDEX, glbModeSleepOn);

            myClipWindow(175, 56, 74, 36);
            gfx_Clipping(ON);
            img_Show(hndl, glbBackgroundType);
            img_Show(hndl, IMAGE_ON_OFF);
            gfx_Clipping(OFF);
        endif

        // We now draw the value of the actual update time between the two screen of the main view
        digit := glbUpdateFrequenceToogleMainScreen / 1000;
        if(digit > 9)
            drawDigit(222, 127, (digit/10)%10,IMAGE_DIGIT_SMALL);
            drawDigit(231, 127, digit%10,IMAGE_DIGIT_SMALL);
        else
            drawDigit(228, 127, digit%10,IMAGE_DIGIT_SMALL);
        endif

        // Here we draw the frequence between two save in the µSD card
        if(glbFrequenceSaveData > 9)
            drawDigit(222, 157, (glbFrequenceSaveData/10)%10,IMAGE_DIGIT_SMALL);
            drawDigit(231, 157, glbFrequenceSaveData%10,IMAGE_DIGIT_SMALL);
        else
            drawDigit(228, 157, glbFrequenceSaveData%10,IMAGE_DIGIT_SMALL);
        endif


        // We check if an interaction occured
        if(getTouchStatus() == TOUCH_PRESSED)
            // We get the X and Y coordinates of the touched point
            xtouched := touch_Get(TOUCH_GETX);
            ytouched := touch_Get(TOUCH_GETY);

            if(isDotInBox(xtouched, ytouched,0,0,80,42))  // Back button
                glbStateDispaly := STATE_MENU_SCREEN;     // We change the state of the display : we go back to the menu screen ...
                loop := 0;                                // ... we go out of the while loop ...
                sys_SetTimer(TIMER7,10000);               // ... and we make that the eco mode will be take into account
            else
                // For managing the unit, we check :
                // (Celcius_button_pressed && Actual_unit_is_farenheit) || (Farenheit_button_pressed && Actual_unit_is_celcuis)
                if((isDotInBox(xtouched, ytouched,175, 90, 70 ,36) && glbIsCelcius == 0) || (isDotInBox(xtouched, ytouched,245, 90, 70 ,36) && glbIsCelcius == 1))
                    // If it's true, we toogle the unit
                    glbIsCelcius := !glbIsCelcius;
                else
                    // We check if the eco mode button has been touched
                    if(isDotInBox(xtouched, ytouched,175, 56, 70 ,36))
                        glbModeSleepOn := !glbModeSleepOn;
                    else
                        // We check we want to decrease the value of the frequence between the each panel of the main screen
                        if(isDotInBox(xtouched, ytouched, 180, 150, 50, 30))
                            glbUpdateFrequenceToogleMainScreen -= 1000;
                            glbUpdateFrequenceToogleMainScreen := (glbUpdateFrequenceToogleMainScreen < 1000) ? 30000 : glbUpdateFrequenceToogleMainScreen;

                            // We update only the needed part
                            myClipWindow(205, 150, 50, 30);
                            gfx_Clipping(ON);
                            img_Show(hndl, glbBackgroundType);
                            gfx_Clipping(OFF);
                        else
                            // We check we want to increase the value of the frequence between the each panel of the main screen
                            if(isDotInBox(xtouched, ytouched, 240, 150, 50, 30))
                                glbUpdateFrequenceToogleMainScreen += 1000;
                                glbUpdateFrequenceToogleMainScreen := (glbUpdateFrequenceToogleMainScreen > 30000) ? 1000 : glbUpdateFrequenceToogleMainScreen;

                                // We update only the needed part
                                myClipWindow(205, 150, 50, 30);
                                gfx_Clipping(ON);
                                img_Show(hndl, glbBackgroundType);
                                gfx_Clipping(OFF);
                            else
                                // We check we want to decrease the value between two save in the µSD card
                                if(isDotInBox(xtouched, ytouched, 180, 120, 50, 30))
                                    glbFrequenceSaveData -= 1;
                                    glbFrequenceSaveData := (glbFrequenceSaveData < 5) ? 99 : glbFrequenceSaveData;

                                    // We update only the needed part
                                    myClipWindow(205, 120, 50, 30);
                                    gfx_Clipping(ON);
                                    img_Show(hndl, glbBackgroundType);
                                    gfx_Clipping(OFF);
                                else
                                    // We check we want to increase the value between two save in the µSD card
                                    if(isDotInBox(xtouched, ytouched, 240, 120, 50, 30))
                                        glbFrequenceSaveData += 1;
                                        glbFrequenceSaveData := (glbFrequenceSaveData > 99) ? 5 : glbFrequenceSaveData;

                                        // We update only the needed part
                                        myClipWindow(205, 120, 50, 30);
                                        gfx_Clipping(ON);
                                        img_Show(hndl, glbBackgroundType);
                                        gfx_Clipping(OFF);
                                    else
                                        // The user pressed the bottom arrow to go to the pannel 1 (updating the time and date)
                                        if(isDotInBox(xtouched, ytouched, 160, 190, 160, 50))
                                             settingScreen.stateSetting := 1;
                                             loop := 0; // We go out of the while loop
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
    wend
endfunc

// This function permit to adjust the time and the dates
func settingPannel1()
    var loop := 1;
    var xtouched, ytouched;
    var month;
    var day;

    // We diaply the back button (go back to the menu pannel)
    img_Show(hndl, IMAGE_BACK);
    // We draw the template of this setting screen (many arrows)
    img_Show(hndl, IMAGE_SETTING_1);

    // We diaply only the rigth arrow of the button that permit to toogle between the two pannels
    myClipWindow(0, 200, 160, 50);
    gfx_Clipping(ON);
    img_Show(hndl, IMAGE_BTN_TOOGLE );
    gfx_Clipping(OFF);

    // We draw circles that permits to know in which pannel you are
    gfx_Circle(150, 222, 4, WHITE);
    gfx_CircleFilled(170, 222, 4, WHITE);

    // We get the current value for the month and the day
    month := glbDateTime[U_MONTH] + glbDateTime[D_MONTH]*10 - 1; // "-1" because we want our months to go from 0 to 11 (instead of 1 to 12)
    day := glbDateTime[U_DAY] + glbDateTime[D_DAY]*10;

    while(1 == loop)
        // Drawing the hour
        drawDigit(80, 63, glbDateTime[D_HOUR], IMAGE_DIGIT_BIG);
        drawDigit(110, 63, glbDateTime[U_HOUR], IMAGE_DIGIT_BIG);
        drawDigit(170, 63, glbDateTime[D_MINUTES], IMAGE_DIGIT_BIG);
        drawDigit(202, 63, glbDateTime[U_MINUTES], IMAGE_DIGIT_BIG);

        // Drawing the month
        img_SetWord(hndl, IMAGE_MONTH, IMAGE_INDEX, month);
        img_SetPosition(hndl, IMAGE_MONTH, 113,132);
        img_Show(hndl, IMAGE_MONTH);

        // Drawing the day
        if(day > 9) // To not display the 0 if the day is below 10 (to get "5" instead of "05")
            drawDigit(145, 173, (day/10)%10,IMAGE_DIGIT_SMALL);
            drawDigit(160, 173, day%10,IMAGE_DIGIT_SMALL);
        else
            drawDigit(153, 173, day%10,IMAGE_DIGIT_SMALL);
        endif

        // We check if an interaction occured
        if(getTouchStatus() == TOUCH_PRESSED)
            // We get the X and Y coordinates of the touched point
            xtouched := touch_Get(TOUCH_GETX);
            ytouched := touch_Get(TOUCH_GETY);

            // We save data in the RTC when the back button is pressed
            if(isDotInBox(xtouched, ytouched,0,0,80,42))  // Back button
                // We change the state of the display : we go back to the menu screen
                glbStateDispaly := STATE_MENU_SCREEN;
                // We go out of the while loop
                loop := 0;

                // We get the value of the day
                glbDateTime[D_DAY] := day / 10;
                glbDateTime[U_DAY] := day % 10;

                // We get the value of the month
                glbDateTime[D_MONTH] := (month+1) / 10;
                glbDateTime[U_MONTH] := (month+1) % 10;

                // And we save those data in the RTC
                setDateTimeI2C();
            else
                // Now we check if one arrow has been pressed

                // Hour tens
                if(isDotInBox(xtouched, ytouched,86,25,28,50))  // Up D_HOUR
                    glbDateTime[D_HOUR] ++;
                    glbDateTime[D_HOUR] := (glbDateTime[D_HOUR] > 2)  ? 0 : glbDateTime[D_HOUR];

                    myClipWindow(80, 63, 40, 40);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif
                if(isDotInBox(xtouched, ytouched,86,94,28,40))  // Down D_HOUR
                    glbDateTime[D_HOUR] --;
                    glbDateTime[D_HOUR] := (glbDateTime[D_HOUR] < 0)  ? 2 : glbDateTime[D_HOUR];

                    myClipWindow(80, 63, 40, 40);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif

                // Hour units
                if(isDotInBox(xtouched, ytouched,116,25,28,50))  // Up U_HOUR
                    glbDateTime[U_HOUR] ++;
                    glbDateTime[U_HOUR] := (glbDateTime[U_HOUR] > 9 || (glbDateTime[U_HOUR] > 3 && glbDateTime[D_HOUR] == 2))  ? 0 : glbDateTime[U_HOUR];

                    myClipWindow(110, 63, 40, 40);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif
                if(isDotInBox(xtouched, ytouched,116,94,28,40))  // Down U_HOUR
                    glbDateTime[U_HOUR] --;
                    glbDateTime[U_HOUR] := (glbDateTime[U_HOUR] < 0)  ? ((glbDateTime[D_HOUR] == 2) ? 3 : 9) : glbDateTime[U_HOUR];

                    myClipWindow(110, 63, 40, 40);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif


                // Minutes tens
                if(isDotInBox(xtouched, ytouched,175,25,28,50))  // Up D_MINUTES
                    glbDateTime[D_MINUTES] ++;
                    glbDateTime[D_MINUTES] := (glbDateTime[D_MINUTES] > 5)  ? 0 : glbDateTime[D_MINUTES];

                    myClipWindow(170, 63, 40, 40);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif
                if(isDotInBox(xtouched, ytouched,175,94,28,40))  // Down D_MINUTES
                    glbDateTime[D_MINUTES] --;
                    glbDateTime[D_MINUTES] := (glbDateTime[D_MINUTES] < 0)  ? 5 : glbDateTime[D_MINUTES];

                    myClipWindow(170, 63, 40, 40);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif

                // Minutes units
                if(isDotInBox(xtouched, ytouched,205,25,28,50))  // Up U_MIN
                    glbDateTime[U_MINUTES] ++;
                    glbDateTime[U_MINUTES] := (glbDateTime[U_MINUTES] > 9)  ? 0 : glbDateTime[U_MINUTES];

                    myClipWindow(202, 63, 40, 40);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif
                if(isDotInBox(xtouched, ytouched,205,94,28,40))  // Down U_MIN
                    glbDateTime[U_MINUTES] --;
                    glbDateTime[U_MINUTES] := (glbDateTime[U_MINUTES] < 0)  ? 9 : glbDateTime[U_MINUTES];

                    myClipWindow(202, 63, 40, 40);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif


                // Month
                if(isDotInBox(xtouched, ytouched,76,136,50,28))  // Down U_MONTH
                    month --;
                    month := (month < 0)  ? 11 : month;

                    myClipWindow(110, 136, 105, 36);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif
                if(isDotInBox(xtouched, ytouched,198,136,50,28))  // Up U_MONTH
                    month ++;
                    month := (month > 11)  ? 0 : month;

                    myClipWindow(110, 136, 105, 36);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif

                // Day
                if(isDotInBox(xtouched, ytouched,76,166,50,28))  // Down U_DAY
                    day --;
                    day := (day < 1)  ? ((month % 2 == 0) ? 31 : ((month == 1) ? 29 : 30)) : day;

                    myClipWindow(110, 166, 105, 36);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif
                if(isDotInBox(xtouched, ytouched,198,166,50,28))  // Up U_DAY
                    day ++;
                    day := ((day > 31 && month % 2 ==0) || (day > 30 && month % 2 == 1) || (day > 29 && month == 1))  ? 0 : day;

                    myClipWindow(110, 166, 105, 36);
                    gfx_Clipping(ON);
                    img_Show(hndl, glbBackgroundType);
                    gfx_Clipping(OFF);
                endif

                // The user pressed the bottom arrow to go to the pannel 0 (basic settings)
                if(isDotInBox(xtouched, ytouched, 0, 190, 160, 50))
                    settingScreen.stateSetting := 0;
                    loop := 0; // We go out of the while loop
                endif
            endif
        endif
    wend
endfunc

