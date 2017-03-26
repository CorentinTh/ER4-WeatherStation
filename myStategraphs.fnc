
/*
      - Weather station project -
    ER4 - IUT Annecy-Le-vieux - 2017

       • Anne LENSING
       • Helena STICKELBROECK
       • Cyrille DUPONT
       • Corentin THOMASSET
*/

// This function manage the global state of the weather station
func mainStateGraph()

    switch(glbStateDispaly)

        // In this state we make the set up and we display the logo of the weather station
        case STATE_INIT:
            setUp();
            pause(2000);
            // When init is finished, we go to the main screen
            glbStateDispaly := STATE_MAIN_SCREEN;
            break;

        // This state manage the main screen, the toogle between the the time & date and the temperature
        case STATE_MAIN_SCREEN:
            mainScreen();
            break;

        // This state manage the menu that permit to go into the settings or view the historic
        case STATE_MENU_SCREEN:
            menuScreen();
            break;

        // This state manage the setting screen
        case STATE_SETTING:
            settingScreen();
            break;

        // This state manage the historic state
        case STATE_HISTORIC:
            historicScreen();
            break;

    endswitch
endfunc

