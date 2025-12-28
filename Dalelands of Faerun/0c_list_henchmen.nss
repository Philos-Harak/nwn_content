/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_list_henchmen
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text appears when script to list henchman for higher.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
#include "nwnx_player"
int StartingConditional ()
{
    int nClass, nLevel, nRace, nRoll, nCost, nPCLevel, nPackage;
    string sArray, sText, sName, sGender, sClass, sRace, sLevel, sIndex;
    object oPC = GetPCSpeaker ();
    object oArea = GetArea (oPC);
    string sInput = GetScriptParam ("sInput");
    string sPCName = RemoveIllegalCharacters (GetName (oPC));
    // Save the type to the player so we know which henchman type the pc selected.
    SetLocalString (oPC, "0_Henchman_Type", sInput);
    nLevel = GetCharacterLevels (oPC);
    // Cycle through and create 5 different henchman to choose from.
    int nCount = 0;
    while (nCount < 6)
    {
        sIndex = "0_H_" + sInput + sPCName + "_" + IntToString (nCount);
        // We only randomize a henchmen if they have not been randomized before (usually on server resets).
        sArray = GetLocalString (OBJECT_SELF, sIndex);
        if (sArray == "")
        {
            // Select the henchmens class, based upon the group selected.
            nRoll = d100();
            if (sInput == "Warrior")
            {
                if (nRoll < 6) { nClass = CLASS_TYPE_BARBARIAN; nPackage = 66; }
                else if (nRoll < 61) { nClass = CLASS_TYPE_FIGHTER;  nPackage = 86; }
                else if (nRoll < 66) { nClass = 43/*SWASHBUCKLER*/; nPackage = 0; }
                else if (nRoll < 71) { nClass = 45/*PALADIN*/; nPackage = 0; }
                else { nClass = 46/*RANGER*/; nPackage = 0; }
            }
            else if (sInput == "Healer")
            {
                if (nRoll < 71) { nClass = CLASS_TYPE_CLERIC; nPackage = 76; }
                else { nClass = 47/*FAVOREDSOUL*/; nPackage = 0; }
            }
            else if (sInput == "Rogue")
            {
                if (nRoll < 71) { nClass = CLASS_TYPE_ROGUE; nPackage = 106; }
                else { nClass = CLASS_TYPE_BARD; nPackage = 71; }
            }
            else if (sInput == "Mage")
            {
                if (nRoll < 71) { nClass = CLASS_TYPE_WIZARD; nPackage = 116; }
                else { nClass = CLASS_TYPE_SORCERER; nPackage = 111; }
            }
            // Randomize Package.
            if (nPackage > 0)
            {
                int nRoll = Random (6);
                if (nRoll == 5) nPackage = nClass;
                else nPackage = nPackage + nRoll;
            }
            else nPackage = nClass;
            // Randomize race.
            nRoll = d100();
            if (nRoll < 6) sRace = "36"; // Dwarf Shield
            else if (nRoll < 11) sRace = "37"; // Dwarf Gold
            else if (nRoll < 16) sRace = "39"; // Elf Moon
            else if (nRoll < 19) sRace = "40"; // Elf Sun
            else if (nRoll < 20) sRace = "41"; // Elf Wood
            else if (nRoll < 25) sRace = "44"; // Gnome Rock
            else if (nRoll < 26) sRace = "45"; // Gnome Forest
            else if (nRoll < 30) sRace = "48"; // Halfling Lightfoot
            else if (nRoll < 35) sRace = "49"; // Halfling Strongheart
            else if (nRoll < 36) sRace = "50"; // Halfling Ghostwise
            else if (nRoll < 37) sRace = "51"; // Half elf Moon
            else if (nRoll < 38) sRace = "52"; // Half elf Sun
            else if (nRoll < 39) sRace = "53"; // Half elf Wood
            else if (nRoll < 44) sRace = "56"; // Half orc
            else if (nRoll < 52) sRace = "30"; // Human Damaran
            else if (nRoll < 61) sRace = "31"; // Human Iluskan
            else if (nRoll < 69) sRace = "32"; // Human Rashemi
            else if (nRoll < 77) sRace = "33"; // Human Mulan
            else if (nRoll < 85) sRace = "34"; // Human Tethyrian
            else if (nRoll < 98) sRace = "35"; // Human Chondathan
            else if (nRoll < 99) // Rare races
            {
                nRoll = d100();
                if (nRoll < 15) sRace = "38"; // Dwarf Duergar
                else if (nRoll < 31) sRace = "46"; // Gnome Svirfneblin
                else if (nRoll < 47) sRace = "42"; // Elf Drow
                else if (nRoll < 48) sRace = "43"; // Elf Star
                else if (nRoll < 49) sRace = "55"; // Half elf Star
                else if (nRoll < 50) sRace = "54"; // Half elf Drow
                else if (nRoll < 66) sRace = "58"; // Orc Mountain
                else if (nRoll < 81) sRace = "59"; // Orc Gray
                else if (nRoll < 91) sRace = "57"; // Kobold
                else sRace = "47"; // Goblin
            }
            else // Outsiders
            {
                nRoll = d100();
                if (nRoll < 17) sRace = "60"; // Aasimar
                else if (nRoll < 34) sRace = "61"; // Tiefling
                else if (nRoll < 51) sRace = "62"; // Air Genasi
                else if (nRoll < 68) sRace = "63"; // Earth Genasi
                else if (nRoll < 85) sRace = "64"; // Fire Genasi
                else sRace = "65"; // Water Genasi
            }
            sArray = SetStringArray (sArray, 4, sRace, "-");
            sLevel = IntToString (nLevel);
            // Array -0Name-1ResRef-2Tag-3Gender-4Race-5Class-6Package-7level-8Align1
            // -9Align2-10Faction-11Waypointspawn-12Items-
            sArray = "-----" + sRace + "-" + IntToString (nClass) + "-" + IntToString (nPackage) + "-1---3--2--";
            sArray = CreateNPCArray (sArray);
            // Save the Henchman array to the PC.
            SetLocalString (OBJECT_SELF, sIndex, sArray);
        }
        // Create henchman cost: 50 * PC's Level ^2 in gold.
        nCost = 50 * (nLevel * nLevel);
        NWNX_Player_SetCustomToken (oPC, 806, IntToString(nCost));
        // Generate Custom token to display.
        sName = GetStringArray (sArray, 0, "-");
        // Lets just show the first name to save space.
        int nSpace = FindSubString (sName, " ");
        sName = GetStringLeft (sName, nSpace);
        if (GetStringArray (sArray, 3, "-") == "0") sGender = "(M)";
        else sGender = "(F)";
        nRace = StringToInt (GetStringArray (sArray, 4, "-"));
        sRace = GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", nRace)));
        nClass = StringToInt (GetStringArray (sArray, 5, "-"));
        sClass = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", nClass)));
        nPackage = StringToInt (GetStringArray (sArray, 6, "-"));
        string sPackage = GetStringByStrRef (StringToInt (Get2DAString ("packages", "Name", nPackage)));
        sLevel = GetStringArray (sArray, 7, "-");
        NWNX_Player_SetCustomToken (oPC, 800 + nCount, sName + " [" + sRace + " " + sGender + " " +
                                                       sClass + " - " + sPackage + "]");
        nCount ++;
    }
    return TRUE;
}
