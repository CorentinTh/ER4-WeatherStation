
 /*
      - Weather station project -
    ER4 - IUT Annecy-Le-vieux - 2017

       • Anne LENSING
       • Helena STICKELBROECK
       • Cyrille DUPONT
       • Corentin THOMASSET
*/


// Discomment/comment to allow/disallow debug
//#constant DEBUG_ON

// Constants for the state graph
 #CONST
    STATE_INIT          0
    STATE_MAIN_SCREEN   1
    STATE_MENU_SCREEN   2
    STATE_SETTING       3
    STATE_HISTORIC      4
#END

// Constants to know the index of special characters for the digit picture
#CONST
    DIGIT_PERCENT    10
    DIGIT_CELCIUS    11
    DIGIT_FAHRENHEIT 12
    DIGIT_TWO_DOTS   13
    DIGIT_MINUS      14
    DIGIT_SLASH      15
    DIGIT_COMA       16
    DIGIT_MAX        16
#END

// Constants to know the index of pictures in the handler
#CONST
    IMAGE_BG_NORMAL         0
    IMAGE_BG_NORMAL_CIRCLE  1
    IMAGE_BG_COLD           2
    IMAGE_BG_COLD_CIRCLE    3
    IMAGE_BG_WARM           4
    IMAGE_BG_WARM_CIRCLE    5
    IMAGE_DIGIT_BIG         6
    IMAGE_DIGIT_SMALL       7
    IMAGE_DIGIT_XSMALL      8
    IMAGE_MONTH             9
    IMAGE_MENU_PANEL        10
    IMAGE_BACK              11
    IMAGE_ON_OFF            12
    IMAGE_CEL_FAR           13
    IMAGE_SETTING_0         14
    IMAGE_BTN_TOOGLE        15
    IMAGE_SETTING_1         16
    IMAGE_BACK_HISORIC      17
    IMAGE_LOADING           18
#END

// Constantes for RTC date format
#CONST
    U_SECONDES  0
    D_SECONDES  1
    U_MINUTES   2
    D_MINUTES   3
    U_HOUR      4
    D_HOUR      5
    U_DAY       6
    D_DAY       7
    U_MONTH     8
    D_MONTH     9
    U_YEAR      10
    D_YEAR      11
#END

// Divers constantes
#CONST
    W 320
    H 240
    TRANSPARENT_COLOR 0xEF7D    // Defining a colour will be display transparent
    FILE_IMAGES $"design2"
    FILE_DATA $"DATA.TXT"
    I2C_ADDRESS_CPT_TEMP 0x4E
    I2C_ADDRESS_RTC 0xDE
#END

// Defining a word in order to have custom error messages related to file managing
#DATA
    word FileErrors

    FEIDEERROR, FENOTPRESENT, FEPARTITIONTYPE, FEINVALIDMBR, FEINVALIDBR,
    FEMEDIANOTMNTD, FEFILENOTFOUND, FEINVALIDFILE, FEFATEOF, FEEOF,
    FEINVALIDCLUSTER, FEDIRFULL, FEMEDIAFULL, FEFILEOVERWRITE, FECANNOTINIT,
    FECANNOTREADMBR, FEMALLOCFAILED, FEINVALIDMODE, FEFINDERROR, FEINVALIDNAME

    byte     FEIDEERROR         "IDE command execution error",0
    byte     FENOTPRESENT       "CARD not present",0
    byte     FEPARTITIONTYPE    "WRONG partition type, not FAT16",0
    byte     FEINVALIDMBR       "MBR sector invalid signature",0
    byte     FEINVALIDBR        "Boot Record invalid signature",0
    byte     FEMEDIANOTMNTD     "Media not mounted",0
    byte     FEFILENOTFOUND     "File not found in open for read",0
    byte     FEINVALIDFILE      "File not open",0
    byte     FEFATEOF           "Fat attempt to read beyond EOF",0
    byte     FEEOF              "Reached the end of file",0
    byte     FEINVALIDCLUSTER   "Invalid cluster value > maxcls",0
    byte     FEDIRFULL          "All root dir entry are taken",0
    byte     FEMEDIAFULL        "All clusters in partition are taken",0
    byte     FEFILEOVERWRITE    "A file with same name exist already",0
    byte     FECANNOTINIT       "Cannot init the CARD",0
    byte     FECANNOTREADMBR    "Cannot read the MBR",0
    byte     FEMALLOCFAILED     "Malloc could not allocate the FILE struct",0
    byte     FEINVALIDMODE      "Mode was not r.w.",0
    byte     FEFINDERROR        "Failure during FILE search",0
    byte     FEINVALIDNAME      "Bad filename",0
#END


// Global variables
var *hndl;
var glbDateTime[20];
var glbTemperature;
var glbHumidity;
var glbIsCelcius := 1;
var glbModeSleepOn := 0;
var glbFrequenceSaveData := 30; // In minutes
var glbBackgroundType := 0;
var glbStateDispaly := STATE_INIT;
