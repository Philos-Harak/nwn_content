/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_server_colors
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts that are used to change the color of names and text.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

// Basic color codes.                                             Message Notes
const string COLOR_BLACK = "000";       // <c\x20\x20\x20> Nothing.
const string COLOR_WHITE = "999";       // <c\xFF\xFF\xFF> _Debug messages.
const string COLOR_GRAY = "666";        // <c\xAA\xAA\xAA> Server messages
const string COLOR_YELLOW = "990";      // <c\xFF\xFF\x20> Generic messages to players.
const string COLOR_DARK_YELLOW = "660"; // <c\xAA\xAA\x20>
const string COLOR_RED = "900";         // <c\xFF\x20\x20> Negative message to players.
const string COLOR_DARK_RED = "600";    // <c\xAA\x20\x20>
const string COLOR_GREEN = "080";       // <c\x20\xFF\x20> Positive message to players.
const string COLOR_DARK_GREEN = "060";  // <c\x20\xAA\x20>
const string COLOR_BLUE = "009";        // <c\x20\x20\xFF>
const string COLOR_DARK_BLUE = "006";   // <c\x20\x20\xAA> In game descriptive text.
const string COLOR_CYAN = "099";        // <c\x20\xFF\xFF> Random Quest NPC's
const string COLOR_DARK_CYAN = "066";   // <c\x20\xAA\xAA>
const string COLOR_MAGENTA = "909";     // <c\xFF\x20\xFF> Main Quest Givers
const string COLOR_DARK_MAGENTA = "606";// <c\xAA\x20\xAA>
const string COLOR_LIGHT_MAGENTA = "868"; // <c\xAA\xE2\xAA> Combat text: Enemy name color.
const string COLOR_ORANGE = "950";      // <c\xFF\x8E\x20>
const string COLOR_DARK_ORANGE = "940"; // <c\xFF\x71\x20>  Combat text: base text color.
const string COLOR_GOLD = "860";        // <c\xE2\xAA\x20>
// Magic item / Enemy color codes                               Magic Items   Villains.
const string COLOR_MAGIC = "449";     // <c\x71\x71\xFF> (1 Power)     Weak      1 -  5 (1 Power)
const string COLOR_EXQUISITE = "808"; // <c\xE2\x20\xE2> (2 Powers)    Average   6 - 11 (2 Powers)
const string COLOR_LEGENDARY = "900"; // <c\xFF\x20\x20> (3 Powers)    Strong   12 - 17 (3 Powers)
const string COLOR_RELIC = "940";     // <c\xFF\x71\x20> (4 Powers)    Tough    18 - 19 (4 Powers)
const string COLOR_ARTIFACT = "990";  // <c\xFF\xFF\x20> (5 Powers)    Powerful 20 +    (5 Powers)
const string COLOR_SET = "070";       // <c\x20\xC6\x20> Set Items     Combined power creatures
const string COLOR_UNIQUE = "860";    // <c\xE2\xAA\x20> Unique Items  Unique creatures.
// Color codes for PC's
// COLOR_GOLD = "860"; Hardcore PC (Has not respawned.)

// Sets custom color tokens for TLK files.
void SetColorTokens();

// Strips the color codes from sText
string StripColorCodes(string sText);

// This function will make sString be the specified color
// as specified in sRGB.  RGB is the Red, Green, and Blue
// Each color can have a value from 0 to 9.
//   1 - 0 (20) 142 - 5 (8E)
//  32 - 1 (20) 170 - 6 (AA)
//  57 - 2 (39) 198 - 7 (C6)
//  85 - 3 (55) 226 - 8 (E2)
// 113 - 4 (71) 255 - 9 (FE)
string  AddColorToText(string sText, string sRGB= COLOR_WHITE);

// Colors a creatures name bases on it's CR.
// oCreature is the creatures name to color.
// sName is the sName to use.
string ColorVillainName(object oCreature, string sName);

// Sets custom color tokens for TLK files.
void SetColorTokens ()
{
    SetCustomToken (9000, "<c\x20\x20\x20>"); // Black
    SetCustomToken (9999, "<c\xFF\xFF\xFF>"); // White
    SetCustomToken (9990, "<c\xFF\xFF\x20>"); // Yellow
    SetCustomToken (9900, "<c\xFF\x20\x20>"); // Red
    SetCustomToken (9090, "<c\x20\xFF\x20>"); // Green
    SetCustomToken (9006, "<c\x20\x20\xAA>"); // DarkBlue
    SetCustomToken (9666, "<c\xAA\xAA\xAA>"); // Gray
    SetCustomToken (9039, "<c\x20\x55\xFF>"); // Blue
    SetCustomToken (9909, "<c\xFF\x20\xFF>"); // Purple
    SetCustomToken (9940, "<c\xFF\x71\x20>"); // Orange
    SetCustomToken (9860, "<c\xE2\xAA\x20>"); // Gold
    SetCustomToken (8999, "</c>");   // End color.
}

// This function will make sString be the specified color
// as specified in sRGB.  RGB is the Red, Green, and Blue
// If they already have a color it will be stripped.
// Each color can have a value from 0 to 9.
//   1 - 0 (20)[ ] 142 - 5 (8E)[?]
//  32 - 1 (20)[ ] 170 - 6 (AA)[ª]
//  57 - 2 (39)[9] 198 - 7 (C6)[Æ]
//  85 - 3 (55)[U] 226 - 8 (E2)[â]
// 113 - 4 (71)[q] 255 - 9 (FE)[ÿ]
string  AddColorToText(string sText, string sRGB = COLOR_WHITE)
{
    // Old info The magic characters (padded -- the last three characters are the same).
    string sColorCodes = "\x20\x20\x39\x55\x71\x8E\xAA\xC6\xE2\xFF";
    if(FindSubString(sText, "<c", 0) != -1) sText = StripColorCodes(sText);
    return "<c" + // Begin the color token.
           GetSubString (sColorCodes, StringToInt(GetSubString(sRGB, 0, 1)), 1) + // red
           GetSubString (sColorCodes, StringToInt(GetSubString(sRGB, 1, 1)), 1) + // green
           GetSubString (sColorCodes, StringToInt(GetSubString(sRGB, 2, 1)), 1) + // blue
           ">"  + // End the color token
            sText + "</c>";
}

// Colors a creatures name bases on it's CR.
// oCreature is the creatures name to color.
// sName is the sName to use.
string ColorVillainName(object oCreature, string sName)
{
    float fCR = GetChallengeRating(oCreature);
    if(fCR < 6.0f) sName = AddColorToText(sName, COLOR_MAGIC);
    else if(fCR < 12.0f) sName = AddColorToText(sName, COLOR_EXQUISITE);
    else if(fCR < 18.0f) sName = AddColorToText(sName, COLOR_LEGENDARY);
    else if(fCR < 20.0f) sName = AddColorToText(sName, COLOR_RELIC);
    else sName = AddColorToText(sName, COLOR_ARTIFACT);
    return sName;
}

// Strips the color codes from sText
string StripColorCodes(string sText)
{
    string sColorCode, sChar;
    int nStringLength = GetStringLength(sText);
    int i = FindSubString(sText, "<c", 0);
    while(i != -1)
    {
        sText = GetStringLeft(sText, i) + GetStringRight(sText, nStringLength - (i + 6));
        nStringLength = GetStringLength (sText);
        i = FindSubString(sText, "<c", i);
    }
    i = FindSubString (sText, "</", 0);
    while (i != -1)
    {
        sText = GetStringLeft(sText, i) + GetStringRight(sText, nStringLength - (i + 4));
        nStringLength = GetStringLength(sText);
        i = FindSubString(sText, "</", i);
    }
    return sText;
}
