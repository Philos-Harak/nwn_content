/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_color
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts that are used to change the color of names and text.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Basic color codes.                                             Message Notes
const string COLOR_BLACK = "000";       // <c   > <c\x20\x20\x20> Nothing.
const string COLOR_WHITE = "999";       // <c���> <c\xFF\xFF\xFF> _Debug messages.
const string COLOR_GRAY = "666";        // <c���> <c\xAA\xAA\xAA> Server messages
const string COLOR_YELLOW = "990";      // <c�� > <c\xFF\xFF\x20> Generic messages to players.
const string COLOR_DARK_YELLOW = "660"; // <c  �> <c\xAA\xAA\x20>
const string COLOR_RED = "900";         // <c�  > <c\xFF\x20\x20> Negative message to players.
const string COLOR_DARK_RED = "600";    // <c  �> <c\xAA\x20\x20>
const string COLOR_GREEN = "080";       // <c � > <c\x20\xFF\x20> Positive message to players.
const string COLOR_DARK_GREEN = "060";  // <c � > <c\x20\xAA\x20>
const string COLOR_BLUE = "009";        // <c  �> <c\x20\x20\xFF>
const string COLOR_DARK_BLUE = "006";   // <c  �> <c\x20\x20\xAA> In game descriptive text.
const string COLOR_CYAN = "099";        // <c ��> <c\x20\xFF\xFF>
const string COLOR_DARK_CYAN = "066";   // <c ��> <c\x20\xAA\xAA>
const string COLOR_MAGENTA = "909";     // <c� �> <c\xFF\x20\xFF>
const string COLOR_DARK_MAGENTA = "606";// <c� �> <c\xAA\x20\xAA>
const string COLOR_LIGHT_MAGENTA = "868"; // <�c�> <c\xAA\xE2\xAA> Combat text: Enemy name color.
const string COLOR_ORANGE = "950";      // <c�� > <c\xFF\x8E\x20>
const string COLOR_DARK_ORANGE = "940"; // <c�q > <c\xFF\x71\x20>  Combat text: base text color.
const string COLOR_GOLD = "860";        // <c� > <c\xE2\xAA\x20>
// Strips the color codes from sText
string ai_StripColorCodes(string sText);
// This function will make sString be the specified color
// as specified in sRGB.  RGB is the Red, Green, and Blue
// Each color can have a value from 0 to 9.
//   1 - 0(20)[ ] 142 - 5(8E)[?]
//  32 - 1(20)[ ] 170 - 6(AA)[�]
//  57 - 2(39)[9] 198 - 7(C6)[�]
//  85 - 3(55)[U] 226 - 8(E2)[�]
// 113 - 4(71)[q] 255 - 9(FE)[�]
string  ai_AddColorToText(string sText, string sRGB = COLOR_WHITE);

string ai_StripColorCodes(string sText)
{
    string sColorCode, sChar;
    int nStringLength = GetStringLength(sText);
    int i = FindSubString(sText, "<c", 0);
    while(i != -1)
    {
        sText = GetStringLeft(sText, i) + GetStringRight(sText, nStringLength -(i + 6));
        nStringLength = GetStringLength(sText);
        i = FindSubString(sText, "<c", i);
    }
    i = FindSubString(sText, "</", 0);
    while(i != -1)
    {
        sText = GetStringLeft(sText, i) + GetStringRight(sText, nStringLength -(i + 4));
        nStringLength = GetStringLength(sText);
        i = FindSubString(sText, "</", i);
    }
    return sText;
}
string  ai_AddColorToText(string sText, string sRGB = COLOR_WHITE)
{
    // Old info The magic characters(padded -- the last three characters are the same).
    string sColorCodes = "\x20\x20\x39\x55\x71\x8E\xAA\xC6\xE2\xFF";
    if(FindSubString(sText, "<c", 0) != -1) sText = ai_StripColorCodes(sText);
    return "<c" + // Begin the color token.
           GetSubString(sColorCodes, StringToInt(GetSubString(sRGB, 0, 1)), 1) + // red
           GetSubString(sColorCodes, StringToInt(GetSubString(sRGB, 1, 1)), 1) + // green
           GetSubString(sColorCodes, StringToInt(GetSubString(sRGB, 2, 1)), 1) + // blue
           ">"  + // End the color token
            sText + "</c>";
}
