/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_set_racexp
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that sets CUSTOM500 to show racial xp in the
 players handbook.
*///////////////////////////////////////////////////////////////////////////////
int StartingConditional()
{
    int nRace, nRacialXPNeeded;
    object oPC = GetPCSpeaker ();
    // Get any racial xp left.
    int nRacialXP = FloatToInt (GetLocalFloat (oPC, "0_RacialXP"));
    if (nRacialXP > 0)
    {
        // Check for ECL level
        nRace = GetRacialType (oPC);
        switch (nRace)
        {
            // ERL 1
            case 60: // Aasimar
            case 61: // Tiefling
            case 62: // Air Genasi
            case 63: // Earth Genasi
            case 64: // Fire Genasi
            case 65: // Water Genasi
                nRacialXPNeeded = 1000;
                break;
            // ERL 2
            case 38: // Duergar
            case 42: // Drow
                nRacialXPNeeded = 3000;
                break;
            // ERL 3
            case 46: // Svirfneblin
                nRacialXPNeeded = 6000;
                break;
        }
        // We only save what racial xp is left to get.
        // Get the actual Racial xp by looking at what we have left and subtracting what is needed.
        nRacialXP = nRacialXPNeeded - nRacialXP;
        // To get what we need subtract xp needed by actual racial xp.
        nRacialXPNeeded = nRacialXPNeeded - nRacialXP;
        SetCustomToken (500, "Racial XP: " + IntToString (nRacialXP) + " Racial XP needed: " + IntToString (nRacialXPNeeded));
    }
    else SetCustomToken (500, "0");
    return TRUE;
}
