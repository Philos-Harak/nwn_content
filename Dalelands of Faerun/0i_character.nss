/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_character
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for use on player characters.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_checks"
#include "0i_master"
#include "0i_effects"
#include "0i_datetime"
#include "0i_creature"
#include "nwnx_creature"
#include "nwnx_player"
#include "nwnx_object"

// Returns the number of languages a character can know.
// Note: This is not the number of skill points as it takes 2 skill points
// per language.
int GetLanguagesToLearn(object oPC);
// Returns the number of languages a character can know.
// Note: This is not the number of skill points as it takes 2 skill points
// per language.
int GetLanguagesKnown(object oPC);
// Runs the functions in order to get the character setup.
void SetNewCharacter(object oPC);
// Sets the character to the correct xp and gold.
// oPC the character to change the level of.
// iLevel the level to change to.
// bXP and bGold can be turned on and off (TRUE/FALSE).
void SetXpGold(object oPC, int iLevel, int bXP = TRUE, int bGold = TRUE);
void RestoreHitpointsFromDatabase(object oPC);
// Saves data for the character to the database.
// hitpoints, location, kills and exports the character.
// Checks the area the players in to make sure the data should be saved.
// iForceSave will save the character bypassing the time restriction.
void SaveCharacterData(object oPC, int iForceSave = FALSE);
// Saves data for the DMs to the database.
// location, languageusing
// iForceSave will save the DM bypassing the time restriction.
void SaveDMData(object oDM, int bForceSave = FALSE);
// Checks to see if a player can rest at the current location.
// oPC is the player to rest.
// If they can rest here based on waypoints in the areas.
// Returns TRUE or FALSE.
int CanPCRest(object oPC, int bPlaceableRest);
// Returns a characters reputation (Fame/Infamy) from Faerun.
// oPC is the character to get the reputation from.
// nFame if TRUE will get fame if false will get infamy.
int GetCharacterReputation(object oPC, int nFame = TRUE);
// Returns a characters reputation (Fame/Infamy) from Faerun.
// oPC is the character to get the reputation from.
// iFame if TRUE will get fame if false will get infamy.
// Will change reputation based on nAdjustement.
// oPC the player's reputation to change.
// sType either "fame" or "infamy".
void CheckForReputationAdjustment(object oPC, string sType);
string GetFameText(int iFame);
string GetInfamyText(int iInfamy);
void SetPrestigeClassesForLevelUp(object oPC);
void SetDeityInDatabase(object oPC);
// Does spot vs sleightofhand check for all within sight of oReceiver
// getting an item. Sends message to them if successful.
void DoSpotVsSleightOfHandCheck(object oReceiver, object oItem, object oGiver);
// Checks the dicerolltext to see if we are doing a special check.
// Returns "" if not.
string CheckDiceRollText(object oPlayer, string sText);
void SetRestingOption(object oPC, string sOption);
// This will make a character bleed as per the Dnd bleed rules.
// iBleedState should be either -1 or +1. -1 means they are bleeding. +1 means they are recovering.
void CharacterBleeding(int iBleedState, object oPC);
// Returns the number of creatures in a Party/faction.
// oPC is a member of the party/faction (Only use on players).
// iPCOnly will only count players if TRUE.
int GetPartySize(object oPC, int iPCOnly = TRUE);
// Save a characters pins on the map.
void SaveCharacterPins(object oPC);
// Get the experience need for the next level.
int GetXpForNextLevel(int nLevel);

// Returns the number of languages a character can learn.
int GetLanguagesToLearn (object oPC)
{
    int nSpeakLanguagePoints = GetSkillRank (27/*Speak_Languages*/, oPC, TRUE);
    // We do this since we don't want magic and item bonuses.
    int nIntelligenceModifier = (GetAbilityScore (oPC, ABILITY_INTELLIGENCE, TRUE) - 10) / 2;
    if (nIntelligenceModifier < 0) nIntelligenceModifier = 0;
    // Your first language is free thus the +1.
    return nSpeakLanguagePoints + nIntelligenceModifier + 1;
}

// Returns the number of lanuages a character knows.
int GetLanguagesKnown (object oPC)
{
    int i, nKnownLanguages;
    while (i < 27)
    {
        if (GetHasFeat(1171/*FEAT_LANGUAGES*/ + i, oPC)) nKnownLanguages ++;
        i ++;
    }
    // + 1 for the basic common language everyone knows.
    return nKnownLanguages;
}

// Runs the functions in order to get the character setup.
void SetNewCharacter (object oPC)
{
   object oModule = GetModule ();
   // Lets get the starting level based on a saved variable on the module. Can be altered by DM's.
   int iStartingLevel = GetServerDatabaseInt (oModule, SERVER_TABLE, "startlevel");
   if (iStartingLevel < 1) iStartingLevel = 1;
   // Setup the characters xp and gold.
   SetXpGold (oPC, iStartingLevel);
   // Check Diety field and set in database.
   SetDeityInDatabase (oPC);
}

// Sets the character to the correct xp and gold.
// oCreature to change the level of.
// iLevel the level to change to.
// bXP and bGold can be turned on and off (TRUE/FALSE).
void SetXpGold (object oPC, int iLevel, int bXP = TRUE, int bGold = TRUE)
{
   int iRace;
   float fRacialXP;
   // Make sure its within the limits of a character.
   if (iLevel < 0) iLevel = 1;
   if (iLevel > 40) iLevel = 40;
   int iXP = 0, iGP = 0;
   // Get the correct data to add to the character.
   switch (iLevel)
   {
      case 0:  iXP = 0;      iGP = 0;       break;
      case 1:  iXP = 0;      iGP = 150;     break;
      case 2:  iXP = 1000;   iGP = 900;     break;
      case 3:  iXP = 3000;   iGP = 2700;    break;
      case 4:  iXP = 6000;   iGP = 5400;    break;
      case 5:  iXP = 10000;  iGP = 9000;    break;
      case 6:  iXP = 15000;  iGP = 13000;   break;
      case 7:  iXP = 21000;  iGP = 19000;   break;
      case 8:  iXP = 28000;  iGP = 27000;   break;
      case 9:  iXP = 36000;  iGP = 36000;   break;
      case 10: iXP = 45000;  iGP = 49000;   break;
      case 11: iXP = 55000;  iGP = 66000;   break;
      case 12: iXP = 66000;  iGP = 88000;   break;
      case 13: iXP = 78000;  iGP = 110000;  break;
      case 14: iXP = 91000;  iGP = 150000;  break;
      case 15: iXP = 105000; iGP = 200000;  break;
      case 16: iXP = 120000; iGP = 260000;  break;
      case 17: iXP = 136000; iGP = 340000;  break;
      case 18: iXP = 153000; iGP = 440000;  break;
      case 19: iXP = 171000; iGP = 580000;  break;
      case 20: iXP = 190000; iGP = 760000;  break;
      case 21: iXP = 210000; iGP = 980000;  break;
      case 22: iXP = 231000; iGP = 1220000;  break;
      case 23: iXP = 253000; iGP = 1500000;  break;
      case 24: iXP = 276000; iGP = 1820000;  break;
      case 25: iXP = 300000; iGP = 2180000;  break;
      case 26: iXP = 325000; iGP = 2540000;  break;
      case 27: iXP = 351000; iGP = 2940000;  break;
      case 28: iXP = 378000; iGP = 3380000;  break;
      case 29: iXP = 406000; iGP = 3860000;  break;
      case 30: iXP = 435000; iGP = 4380000;  break;
      case 31: iXP = 465000; iGP = 4940000;  break;
      case 32: iXP = 496000; iGP = 5540000;  break;
      case 33: iXP = 528000; iGP = 6180000;  break;
      case 34: iXP = 561000; iGP = 6860000;  break;
      case 35: iXP = 595000; iGP = 7580000;  break;
      case 36: iXP = 630000; iGP = 8340000;  break;
      case 37: iXP = 666000; iGP = 9140000;  break;
      case 38: iXP = 703000; iGP = 9980000;  break;
      case 39: iXP = 741000; iGP = 10860000;  break;
      case 40: iXP = 780000; iGP = 11780000;  break;
   }
   if (bXP)
   {
       if (iLevel == 1)
       {
           // Check ECL and set PrepaidXP.
           iRace = GetRacialType (oPC);
           switch (iRace)
           {
                //Debug ("0i_character", "285", "iRace: " + IntToString (iRace));
                // ERL 1
                case 38: // Duergar
                case 60: // Aasimar
                case 61: // Tiefling
                case 62: // Air Genasi
                case 63: // Earth Genasi
                case 64: // Fire Genasi
                case 65: // Water Genasi
                    fRacialXP = 1000.0;
                    break;
                // ERL 2
                case 42: // Drow
                case 66: // Gloaming
                    fRacialXP = 3000.0;
                    break;
                // ERL 3
                case 46: // Svirfneblin
                    fRacialXP = 6000.0;
                    break;
           }
           SetObjectDatabaseFloat(oPC, CHARACTER_TABLE, "racialxp", fRacialXP);
       }
       else
       {
            if (GetObjectDatabaseFloat (oPC, CHARACTER_TABLE, "racialxp") > 0.0f)
            {
                SetObjectDatabaseFloat (oPC, CHARACTER_TABLE, "racialxp", 0.0f);
                SetLocalFloat (oPC, "0_RacialXP", 0.0f);
            }
       }
       // Give Xp after adjustments.
       SetXP (oPC, iXP);
       SendMessages (GetName (oPC) + " now has " + IntToString (iXP) + " experience.", COLOR_GRAY);
   }
   if (bGold)
   {
       // Set Gold to exact amount.
       GiveGoldToCreature (oPC, iGP);
       // Set back once we get NWNX working again.
       NWNX_Creature_SetGold (oPC, iGP);
       SendMessages (GetName (oPC) + " now has " + IntToString (iGP) + " gold pieces.", COLOR_GRAY);
   }
}

void RestoreHitpointsFromDatabase (object oPC)
{
    int iHP = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "hitpoints");
    if (iHP < 1)
    {
        IncreaseServerDatabaseCounter (oPC, PLAYER_TABLE, "respawns");
        IncreaseObjectDatabaseCounter (oPC, CHARACTER_TABLE, "respawns");
        NWNX_Object_SetCurrentHitPoints (oPC, 1);
        // Jump them to a respawn location.
        string sWaypoint = JsonGetString (JsonArrayGet (GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport"), 0));
        // Respawn to the default one if one is not set.
        if (sWaypoint == "") sWaypoint = WP_DEFAULT_RESPAWN;
        SendMessages (GetName (oPC) + " logged off at 0 or less hitpoints. You have been respawned!", COLOR_RED, oPC, TRUE, TRUE);
      // Set the PC to dying mode too off so creatures will attack.
      SetLocalInt (oPC, "0_BLEEDING", FALSE);
    }
    else if (iHP < GetMaxHitPoints (oPC)) NWNX_Object_SetCurrentHitPoints (oPC, iHP);
}

// Saves data for the character to the database.
// hitpoints, location, kills and exports the character.
// Checks the area the players in to make sure the data should be saved.
// iForceSave will save the character bypassing the time restriction.
void SaveCharacterData(object oPC, int bForceSave = FALSE)
{
    int nMinutesSinceLastSave, nKills, nPlayerKills, nSideQuests, nMainQuests;
    int nCurrentTime, nLastSave, bDMMode;
    string sLocation;
    float fFacing;
    object oWaypoint, oArea;
    vector vPosition;
    // Make sure to turn of the DM mode before we save.
    if(GetIsPlayerDM(oPC))
    {
        bDMMode = TRUE;
        NWNX_Player_ToggleDM (oPC, FALSE);
    }
    // Check if the area is a no save area then exit nothing can bypass this
    // except DM's always save.
    oWaypoint = GetNearestObjectByTag ("0_NoSave", oPC);
    if(GetIsObjectValid(oWaypoint)) return;
    // Check to see if enough time has passed to save the character.
    // Get the Current date.
    nCurrentTime = GetCurrentDateTimeInMinutes();
    // Get last save time.
    nLastSave = GetLocalInt(oPC, "0_LASTSAVE");
    // Get the number of hours difference sCurrentTime - sLastRest = iHours till last save.
    nMinutesSinceLastSave = DifferenceInCalendarDates (nCurrentTime, nLastSave, 1);
    if(bForceSave || nMinutesSinceLastSave > SAVE_CHARACTERS_DURATION)
    {
        // Save the last save time to current time.
        SetLocalInt(oPC, "0_LASTSAVE", nCurrentTime);
        string sLocation = LocationToStringArray(GetLocation (oPC));
        // Save information for players.
        SetObjectDatabaseInt(oPC, CHARACTER_TABLE, "hitpoints", GetCurrentHitPoints(oPC));
        SetObjectDatabaseInt(oPC, CHARACTER_TABLE, "luck", GetLocalInt(oPC, "0_Luck"));
        SetObjectDatabaseFloat(oPC, CHARACTER_TABLE, "racialxp", GetLocalFloat(oPC, "0_RacialXP"));
        nKills = GetLocalInt(oPC, "0_Kills");
        nPlayerKills = GetServerDatabaseInt(oPC, PLAYER_TABLE, "kills") + nKills;
        SetServerDatabaseInt(oPC, PLAYER_TABLE, "kills", nPlayerKills);
        nKills = GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "kills") + nKills;
        SetObjectDatabaseInt(oPC, CHARACTER_TABLE, "kills", nKills);
        SetLocalInt(oPC, "0_Kills", 0);
        SetObjectDatabaseInt(oPC, CHARACTER_TABLE, "languageusing", GetLocalInt(oPC, "0_Language"));
        SetObjectDatabaseString(oPC, CHARACTER_TABLE, "location", sLocation);
        SaveCharacterPins(oPC);
        ExportSingleCharacter(oPC);
        SetServerDatabaseTime(oPC, PLAYER_TABLE, "lastlogin");
        SendMessages("Saving " + StripColorCodes(GetName(oPC)) + " information to the database.", COLOR_GRAY, oPC, FALSE, TRUE);
        SaveServerCalendarToDatabase();
   }
   if(bDMMode) NWNX_Player_ToggleDM(oPC, TRUE);
}

// Saves data for the DMs to the database.
// location, languageusing
// iForceSave will save the DM bypassing the time restriction.
void SaveDMData (object oDM, int bForceSave = FALSE)
{
   int nMinutesSinceLastSave, nLastSave, nCurrentTime;
   string sLocation;
   float fFacing;
   object oWaypoint, oArea;
   vector vPosition;
   // Check to see if enough time has passed to save the character.
   // Get the Current date.
   nCurrentTime = GetCurrentDateTimeInMinutes ();
   // Get last save time.
   nLastSave = GetLocalInt (oDM, "0_LASTSAVE");
   // Get the number of hours difference sCurrentTime - sLastRest = iHours till last save.
   nMinutesSinceLastSave = DifferenceInCalendarDates (nCurrentTime, nLastSave, 1);
   if (bForceSave || nMinutesSinceLastSave > SAVE_CHARACTERS_DURATION)
   {
       // Save the last save time to current time.
       SetLocalInt (oDM, "0_LASTSAVE", nCurrentTime);
       string sLocation = LocationToStringArray (GetLocation (oDM));
       SetServerDatabaseInt (oDM, DM_TABLE, "languageusing", GetLocalInt (oDM, "0_Language"));
       SetServerDatabaseString (oDM, DM_TABLE, "location", sLocation);
       //SaveDMPins (oPC);
       SetServerDatabaseTime (oDM, PLAYER_TABLE, "lastlogin");
       SendMessages ("Saving DM's information to the database.", COLOR_GRAY, oDM);
       SaveServerCalendarToDatabase();
   }
}

// Checks to see if a player can rest at the current location.
// oPC is the player to rest.
// If they can rest here based on waypoints in the areas.
// Returns TRUE or FALSE.
int CanPCRest(object oPC, int bPlaceableRest)
{
    object oWaypoint, oModule = GetModule();
    // See if restrict rest is turned on.
    if(!GetServerDatabaseInt(oModule, SERVER_TABLE, "restrictrest") || GetTag(GetArea(oPC)) == "cynosure") return TRUE;
    // Check to see if the player can rest in this area.
    oWaypoint = GetNearestObjectByTag ("ip_no_rest", oPC);
    if(GetIsObjectValid (oWaypoint) && bPlaceableRest != 999)
    {
        // Player can't rest in this area.
        SendMessages ("You cannot rest in this area.", COLOR_RED, oPC, FALSE, FALSE);
        AssignCommand (oPC, ClearAllActions());
        return FALSE;
    }
    return TRUE;
}

// Returns a characters reputation (Fame/Infamy) from Faerun.
// oPC is the character to get the reputation from.
// nFame if TRUE will get fame if false will get infamy.
int GetCharacterReputation(object oPC, int nFame = TRUE)
{
    if(nFame) return GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "fame");
    else return GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "infamy");
}

// Will change reputation based on nAdjustement.
// oPC the player's reputation to change.
// sType either "fame" or "infamy".
void CheckForReputationAdjustment(object oPC, string sType)
{
    int nAdjustment;
    int nReputation = GetObjectDatabaseInt(oPC, CHARACTER_TABLE, sType);
    if (nReputation < 20)
    {
        // Make reputation check.
        int nCheck = GetSkillCheck(oPC, SKILL_PERSUADE, FALSE, 0, (nReputation * 2) + 5, TRUE, FALSE);
        // Make reputation check then give 1 reputation if over DC or 2 if beaten DC by over 10.
        if (nCheck >= 10) nAdjustment = 2;
        else if (nCheck >= 0) nAdjustment = 1;
        else nAdjustment = 0;
        if (nAdjustment > 0)
        {
            nReputation = nReputation + nAdjustment;
            SetObjectDatabaseInt(oPC, CHARACTER_TABLE, sType, nReputation);
            SendMessages("Your " + sType + " has increased by " + IntToString(nAdjustment) +
                         " to become " + IntToString(nReputation) + "!", COLOR_GREEN, oPC);

            // If we are at the maximum fame then adjust the alternate reputation down one.
            // A character can only every have 20 reputation points.
            string sAltType;
            if(sType == "fame") sAltType = "infamy";
            else sAltType = "fame";
            int nAltReputation = GetObjectDatabaseInt(oPC, CHARACTER_TABLE, sAltType);
            if(nReputation + nAltReputation > 20)
            {
                nAltReputation = nAltReputation - nAdjustment;
                SetObjectDatabaseInt(oPC, CHARACTER_TABLE, sType, nAltReputation);
                SendMessages("Your " + sAltType + " has decreased by " + IntToString(nAdjustment) +
                             " to become " + IntToString(nAltReputation) + "!", COLOR_YELLOW, oPC);
            }
        }
    }
    // oPC has the maximum reputation!
    else
    {
        SendMessages ("You have the highest " + sType + " you can have!", COLOR_RED, oPC);
        SetObjectDatabaseInt (oPC, CHARACTER_TABLE, sType, 20);
    }
}

// Get text for fame.
// iFame is the value to return the text for.
string GetFameText (int iFame)
{
    string sRep;
    switch (iFame)
    {
        case 1: sRep = "Accepted"; break;
        case 2: sRep = "Noted"; break;
        case 3: sRep = "Known"; break;
        case 4: sRep = "Good standing"; break;
        case 5: sRep = "Liked"; break;
        case 6: sRep = "Well-known"; break;
        case 7: sRep = "Admired"; break;
        case 8: sRep = "Prominant"; break;
        case 9: sRep = "Distinguished"; break;
        case 10: sRep = "Popular"; break;
        case 11: sRep = "Reputable"; break;
        case 12: sRep = "Honored"; break;
        case 13: sRep = "Celebrated"; break;
        case 14: sRep = "Illustrious"; break;
        case 15: sRep = "Eminent"; break;
        case 16: sRep = "Acclaimed"; break;
        case 17: sRep = "Prestigious"; break;
        case 18: sRep = "Famous"; break;
        case 19: sRep = "Renowned"; break;
        case 20: sRep = "Revered";
    }
    if (sRep == "" && iFame < 1) sRep = "Unknown";
    else if (iFame > 20) sRep = "Revered";
    return sRep;
}

// Get text for infamy.
// iInfamy is the value to return the text for.
string GetInfamyText (int iInfamy)
{
    string sRep;
    switch (iInfamy)
    {
        case 1: sRep = "Suspicious"; break;
        case 2: sRep = "Flagrant"; break;
        case 3: sRep = "Blatant"; break;
        case 4: sRep = "Scandalous";break;
        case 5: sRep = "Shady"; break;
        case 6: sRep = "Shameful"; break;
        case 7: sRep = "Nefarious"; break;
        case 8: sRep = "Notorious"; break;
        case 9: sRep = "Disreputable"; break;
        case 10: sRep = "Crooked"; break;
        case 11: sRep = "Degenerate"; break;
        case 12: sRep = "Inglorious"; break;
        case 13: sRep = "Contemptible"; break;
        case 14: sRep = "Dispicable"; break;
        case 15: sRep = "Wanted"; break;
        case 16: sRep = "Detestable"; break;
        case 17: sRep = "Heinous"; break;
        case 18: sRep = "Infamous";break;
        case 19: sRep = "Villainous"; break;
        case 20: sRep = "Dreaded";
    }
    if (sRep == "" && iInfamy < 1) sRep = "Unknown";
    else if (iInfamy > 20) sRep = "Dreaded";
    return sRep;
}

void SetPrestigeClassesForLevelUp (object oPC)
{
    // Check Mystic Theurge: Ability to cast 2nd level Arcane and Divine spells.
    // 0_Deny_Mystic_Theurge set to TRUE (1) will not let the player select Mystic Theurge.
    if(HasSpellLevel(oPC, 2, TRUE) && HasSpellLevel (oPC, 2, FALSE)) SetLocalInt(oPC, "0_Deny_Mystic_Theurge", FALSE);
    else SetLocalInt(oPC, "0_Deny_Mystic_Theurge", TRUE);
    // Check Pale master: Ability to cast 3rd level Arcane spells.
    // 0_Deny_Pale_Master set to TRUE (1) will not let the player select Pale master.
    if(HasSpellLevel(oPC, 3, TRUE)) SetLocalInt (oPC, "0_Deny_Pale_Master", FALSE);
    else SetLocalInt(oPC, "0_Deny_Pale_Master", TRUE);
}

void SetDeityInDatabase (object oPC)
{
    int nMatch;
    string sDeityName, sDeityField = GetDeity(oPC);
    int nPackage = GetCreatureStartingPackage(oPC);
    if(sDeityField == "" && nPackage != PACKAGE_INVALID)
    {
        sDeityField = Get2DAString("packages", "Deity", nPackage);
        SetDeity(oPC, sDeityField);
    }
    sDeityField = GetStringLowerCase(sDeityField);
    int nDeityMaxRows = StringToInt(Get2DAString("deities", "Deity", 0));
    int nRow = 1;
    while(nRow <= nDeityMaxRows && nMatch == 0)
    {
        sDeityName = GetStringLowerCase(Get2DAString("deities", "Deity", nRow));
        if(sDeityField == sDeityName) nMatch = nRow;
        nRow++;
    }
    if(nMatch > 0)
    {
        SendMessages("Deity name: " + sDeityField + " is valid!", COLOR_GREEN, oPC);
        SendMessages("Deity name: " + sDeityField + " is valid for " + GetName(oPC, TRUE) + "!", COLOR_GREEN, OBJECT_INVALID, FALSE, TRUE);
        // Save the Deity 2da line in the database.
        SetObjectDatabaseInt(oPC, CHARACTER_TABLE, "deity", nMatch);
    }
    else if(sDeityField != "")
    {
        SendMessages("Deity name: " + sDeityField + " is invalid!", COLOR_RED, oPC);
        SendMessages("Deity name: " + sDeityField + " is invalid for " + GetName (oPC, TRUE) + "!", COLOR_RED, OBJECT_INVALID, FALSE, TRUE);
    }
}

// Does spot vs sleightofhand check for all within sight of oReceiver
// getting an item. Sends message to them if successful.
void DoSpotVsSleightOfHandCheck (object oReceiver, object oItem, object oGiver)
{
    if(GetTag(oItem) == "0_quest_paper") return;
    int nCheck;
    string sBaseName;
    location lLocation = GetLocation (oReceiver);
    int nItemSize = GetItemSize (oItem) - 1;
    int nBaseItemType = GetBaseItemType (oItem);
    // Skip skins.
    if (nBaseItemType == 160 || nBaseItemType > 68 && nBaseItemType < 74) return;
    int nSleight = 10 + GetSkillRank (13, oReceiver) - nItemSize;
    object oPC = GetFirstObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    while (oPC != OBJECT_INVALID)
    {
         if (GetIsPC (oPC) && oPC != oReceiver)
         {
             nSleight = nSleight + FloatToInt (GetDistanceBetween (oPC, oReceiver) / 10.0f);
             nCheck = GetSkillCheck (oPC, 17, FALSE, 0, nSleight, 0, FALSE);
             // If spot made or the receiver is an associate of oPC.
             if (nCheck > 0 || oPC == GetMaster (oReceiver))
             {
                if (nBaseItemType == BASE_ITEM_INVALID) sBaseName = "gold";
                else sBaseName = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nBaseItemType)));
                SendMessages (GetName (oReceiver) + " takes " + sBaseName + " from " + GetName (oGiver) + ".", COLOR_GRAY, oPC);
             }
         }
         oPC = GetNextObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    }
}

// Checks the dicerolltext to see if we are doing a special check.
// Returns "" if not.
string CheckDiceRollText (object oRoller, string sInput)
{
    int nRoll, nRank, nResult, nDMDC, bArmorPenalty, nArmorPenalty;
    int nAbility = -1;
    int nSave = -1;
    int nSkill = -1;
    int nAttack = -1;
    string sString, sCheckName;
    int iDieAdjustment = GetLocalInt (oRoller, "0_DieBonus");
    sInput = GetStringLowerCase (sInput);
    if (sInput == "strength check")
    {
        nAbility = ABILITY_STRENGTH;
        sCheckName = "a Strength check";
    }
    else if (sInput == "dexterity check")
    {
        nAbility = ABILITY_DEXTERITY;
        sCheckName = "a Dexterity check";
    }
    else if (sInput == "constitution check")
    {
        nAbility = ABILITY_CONSTITUTION;
        sCheckName = "a Constitution check";
    }
    else if (sInput == "intelligence check")
    {
        nAbility = ABILITY_INTELLIGENCE;
        sCheckName = "an Intelligence check";
    }
    else if (sInput == "wisdom check")
    {
        nAbility = ABILITY_WISDOM;
        sCheckName = "a Wisdom check";
    }
    else if (sInput == "charisma check")
    {
        nAbility = ABILITY_CHARISMA;
        sCheckName = "a Charisma check";
    }
    // Base Attack Roll.
    else if (sInput == "base attack roll")
    {
        nAttack = 1;
        sCheckName = "a base attack roll";
    }
    // Saves.
    else if (sInput == "fortitude save")
    {
        nSave = SAVING_THROW_FORT;
        sCheckName = "a Fortitude save";
    }
    else if (sInput == "reflex save")
    {
        nSave = SAVING_THROW_REFLEX;
        sCheckName = "a Reflex save";
    }
    else if (sInput == "will save")
    {
        nSave = SAVING_THROW_WILL;
        sCheckName = "a Will save";
    }
    // Skills
    else if (sInput == "acrobatics check")
    {
        nSkill = 21;
        bArmorPenalty = TRUE;
        sCheckName = "an Acrobatics check";
    }
    else if (sInput == "animal empathy check")
    {
        nSkill = 0;
        sCheckName = "an Animal empathy check";
    }
    else if (sInput == "appraise check")
    {
        nSkill = 20;
        sCheckName = "an Appraise check";
    }
    else if (sInput == "athletics check")
    {
        nSkill = 3;
        bArmorPenalty = TRUE;
        sCheckName = "an Athletics check";
    }
    else if (sInput == "concentration check")
    {
        nSkill = 1;
        sCheckName = "a Concentration check";
    }
    else if (sInput == "crafting check")
    {
        nSkill = 23;
        sCheckName = "a Crafting check";
    }
    else if (sInput == "craft trap check")
    {
        nSkill = 22;
        sCheckName = "a Craft trap check";
    }
    else if (sInput == "decipher script check")
    {
        nSkill = 26;
        sCheckName = "a Decipher script check";
    }
    else if (sInput == "disable trap check")
    {
        nSkill = 2;
        sCheckName = "a Disable trap check";
    }
    else if (sInput == "heal check")
    {
        nSkill = 4;
        sCheckName = "a Heal check";
    }
    else if (sInput == "hide check")
    {
        nSkill = 5;
        bArmorPenalty = TRUE;
        sCheckName = "a Hide check";
    }
    else if (sInput == "intimidate check")
    {
        nSkill = 24;
        sCheckName = "an Intimidate check";
    }
    else if (sInput == "knowledge check")
    {
        nSkill = 7;
        sCheckName = "a Knowledge check";
    }
    else if (sInput == "listen check")
    {
        nSkill = 6;
        sCheckName = "a Listen check";
    }
    else if (sInput == "move silently check")
    {
        nSkill = 8;
        bArmorPenalty = TRUE;
        sCheckName = "a Move silently check";
    }
    else if (sInput == "open lock check")
    {
        nSkill = 9;
        sCheckName = "an Open lock check";
    }
    else if (sInput == "parry check")
    {
        nSkill = 10;
        bArmorPenalty = TRUE;
        sCheckName = "a Parry check";
    }
    else if (sInput == "perform check")
    {
        nSkill = 11;
        sCheckName = "a Perform check";
    }
    else if (sInput == "persuade check")
    {
        nSkill = 12;
        sCheckName = "a Persuade check";
    }
    else if (sInput == "sleight of hand check")
    {
        nSkill = 13;
        bArmorPenalty = TRUE;
        sCheckName = "a Sleight of hand check";
    }
    else if (sInput == "speak languages check")
    {
        nSkill = 27;
        sCheckName = "a Speak languages check";
    }
    else if (sInput == "search check")
    {
        nSkill = 14;
        sCheckName = "a Search check";
    }
    else if (sInput == "set trap check")
    {
        nSkill = 15;
        bArmorPenalty = TRUE;
        sCheckName = "a Set Trap check";
    }
    else if (sInput == "spellcraft check")
    {
        nSkill = 16;
        sCheckName = "a Spellcraft check";
    }
    else if (sInput == "spot check")
    {
        nSkill = 17;
        sCheckName = "a Spot check";
    }
    else if (sInput == "survival check")
    {
        nSkill = 25;
        sCheckName = "a Survival check";
    }
    else if (sInput == "taunt check")
    {
        nSkill = 18;
        sCheckName = "a Taunt check";
    }
    else if (sInput == "use magic device check")
    {
        nSkill = 19;
        sCheckName = "a Use magic device check";
    }
    // Check for target.
    object oTarget = GetLocalObject (oRoller, "0_Dice_Target");
    if (oTarget != OBJECT_INVALID) oRoller = oTarget;
    // Return results for an Ability check.
    if (nAbility > -1)
    {
        nRoll = d20();
        nRank = GetAbilityModifier (nAbility, oRoller);
        nResult = nRoll + nRank + iDieAdjustment;
    }
    // Return results for a Save.
    else if (nSave > -1)
    {
        nRoll = d20();
        if (nSave == SAVING_THROW_FORT) nRank = GetFortitudeSavingThrow (oRoller);
        else if (nSave == SAVING_THROW_REFLEX) nRank = GetReflexSavingThrow (oRoller);
        else if (nSave == SAVING_THROW_WILL) nRank = GetWillSavingThrow (oRoller);
        nResult = nRoll + nRank + iDieAdjustment;
    }
    // Return results for a Skill check.
    else if (nSkill > -1)
    {
        nRoll = d20();
        nRank = GetSkillRank (nSkill, oRoller);
        if (bArmorPenalty) nArmorPenalty = NWNX_Creature_GetArmorCheckPenalty (oRoller);
        else nArmorPenalty = 0;
        nResult = nRoll + nRank + nArmorPenalty + iDieAdjustment;
    }
    // Attack rolls.
    if (nAttack > -1)
    {
        nRoll = d20();
        nRank = GetBaseAttackBonus (oRoller);
        nResult = nRoll + nRank + iDieAdjustment;
    }
    // Setup string for Abilities, Saves, and Skills.
    if (nDMDC == 0 && nRoll > 0)
    {
        sString = GetName (oRoller) + " rolls " + sCheckName + " of " + IntToString (nRoll);
        if (nRank > -1) sString +=  " + " + IntToString (nRank);
        else sString += " - " + IntToString (abs (nRank));
        if (bArmorPenalty) sString += " - " + IntToString (abs (nArmorPenalty));
        if (iDieAdjustment != 0)
        {
            if (iDieAdjustment > 0) sString += " + " + IntToString (iDieAdjustment);
            else sString += " - " + IntToString (abs (iDieAdjustment));
        }
        sString +=  " = " + IntToString (nResult);
    }
    return sString;
}

void SetRestingOption (object oPC, string sOption)
{
    string sRestOption;
    if (sOption == "0" || sOption == "")
    {
        NWNX_Player_SetRestAnimation (oPC, 47);
        sRestOption = "sit";
        NWNX_Player_SetRestDuration (oPC, 3000);
    }
    else if (sOption == "1")
    {
        NWNX_Player_SetRestAnimation (oPC, 57);
        sRestOption = "stand";
        NWNX_Player_SetRestDuration (oPC, 3000);
    }
    else if (sOption == "2")
    {
        NWNX_Player_SetRestAnimation (oPC, 6);
        sRestOption = "lay facedown";
        NWNX_Player_SetRestDuration (oPC, 4000);
    }
    else if (sOption == "3")
    {
        NWNX_Player_SetRestAnimation (oPC, 8);
        sRestOption = "lay faceup";
        NWNX_Player_SetRestDuration (oPC, 4000);
    }
    else if (sOption == "4")
    {
        NWNX_Player_SetRestAnimation (oPC, 32);
        sRestOption = "meditate";
        NWNX_Player_SetRestDuration (oPC, 5000);

    }
    else if (sOption == "5")
    {
        NWNX_Player_SetRestAnimation (oPC, 33);
        sRestOption = "worship";
        NWNX_Player_SetRestDuration (oPC, 6000);
    }
    SendMessages ("You will now " + sRestOption + " while resting.", COLOR_GRAY, oPC);
}

// This will make a character bleed as per the DnD bleed rules.
// iBleedState should be either TRUE or FALSE. TRUE means they are bleeding. FALSE means they are recovering.
void CharacterBleeding (int iBleedState, object oPC)
{
    object oCreature;
    // Break the function if the PC is gone.
    if (!GetIsObjectValid (oPC)) return;
    // Get how many hitpoints they have.
    int iHp = GetCurrentHitPoints (oPC);
    // First check to see if they have been given First aid from the Heal skill and were bleeding.
    if (iBleedState == TRUE && GetLocalInt (oPC, "0_FirstAid"))
    {
        SendMessages ("You have been stablized!", COLOR_GREEN, oPC, FALSE, FALSE);
        // Reverse bleeding.
        iBleedState = FALSE;
    }
    // Check for the Sorcerer's Undeath blood line II feat - automatically stop bleeding.
    else if (iBleedState == TRUE && GetHasFeat (1351/*Undeath blood line II*/, oPC))
    {
        SendMessages ("Your life essence resists death!", COLOR_GREEN, oPC, FALSE, FALSE);
        // Reverse bleeding.
        iBleedState = FALSE;
    }
    // Check to see if we are dead!
    if (iHp < -9) return;
    // If less than one hitpoint then see if we are bleeding or stabilizing.
    else if (iHp < 1)
    {
        // If we are healing then lets keep going.
        if (iBleedState == FALSE)
        {
            // Check to see if any other players are around. If not then heal the player to 1 hitpoint.
            // We want to search for other PC's from the center of the dying player.
            int bOtherPC = FALSE, iHeal;
            object oOtherPC;
            location lLocation = GetLocation (oPC);
            oOtherPC = GetFirstObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, TRUE, OBJECT_TYPE_CREATURE);
            while (oOtherPC != OBJECT_INVALID && bOtherPC == FALSE)
            {
                if (GetIsCharacter (oOtherPC) && oOtherPC != oPC) bOtherPC = TRUE;
                else oOtherPC = GetNextObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, TRUE, OBJECT_TYPE_CREATURE);
            }
            // We have stabilized lets start the healing process since other players are around.
            if (bOtherPC) iHeal = 1;
            // There is no other PC's in the area so lets heal them up to 1 hitpoint and not make them wait.
            else
            {
                // Heal up to 1 hitpoint.
                if (iHp < 1) iHeal = abs (iHp) + 1;
                else iHeal = 0;
            }
            ApplyEffectToObject (DURATION_TYPE_INSTANT, EffectHeal (iHeal), oPC);
            iHp = GetCurrentHitPoints (oPC);
            SendMessages ("You are stable. Hitpoints: " + IntToString (iHp), COLOR_GREEN, oPC, FALSE, FALSE);
            NWNX_Creature_OverrideDamageLevel (oPC, 7);
         }
         // Make the Fortitude Save to see if we are stable for this round.
         else
         {
             // Set the DC to BLEED_DC + Current Hitpoints below Zero.
             if (FortitudeSave (oPC, BLEED_DC - iHp, SAVING_THROW_TYPE_DEATH))
             {
                iBleedState = FALSE;
                ApplyEffectToObject (DURATION_TYPE_INSTANT, EffectHeal (1), oPC);
                iHp = GetCurrentHitPoints (oPC);
                SendMessages ("You have stablized. Hitpoints: " + IntToString (iHp), COLOR_GREEN, oPC, FALSE, FALSE);
                NWNX_Creature_OverrideDamageLevel (oPC, 7);
             }
             else
             {
                 int iPain;
                 // We have failed so lets bleed the character for this round.
                 iBleedState = TRUE;
                 ApplyEffectToObject (DURATION_TYPE_INSTANT, EffectDamage (1), oPC);
                 iHp = GetCurrentHitPoints (oPC);
                 // Sometimes play voice pain.
                 if (d100() > 75)
                 {
                     iPain = d4();
                     if (iPain == 1) PlayVoiceChat (VOICE_CHAT_PAIN1, oPC);
                     else if (iPain == 2) PlayVoiceChat (VOICE_CHAT_PAIN2, oPC);
                     else if (iPain == 3) PlayVoiceChat (VOICE_CHAT_PAIN3, oPC);
                     else PlayVoiceChat (VOICE_CHAT_NEARDEATH, oPC);
                 }
                 SendMessages ("You are bleeding! Hitpoints: " + IntToString (iHp), COLOR_RED, oPC, FALSE, FALSE);
                 NWNX_Creature_OverrideDamageLevel (oPC, 6);
             }
         }
         // Lets check again the next round (6 seconds).
         if (iHp < 1 && iHp > -11) DelayCommand (6.0, CharacterBleeding (iBleedState, oPC));
     }
     // Tell player.
     if (iHp > 0)
     {
         // Remove the PC to dying mode so creatures can attack.
         SendMessages ("You have recovered!", COLOR_GREEN, oPC);
         SetLocalInt (oPC, "0_BLEEDING", FALSE);
         NWNX_Creature_OverrideDamageLevel (oPC, -1);
         // Make all creatures begin combat.
         object oCreature = GetFirstObjectInShape (SHAPE_SPHERE, 20.0f, GetLocation (oPC), TRUE, OBJECT_TYPE_CREATURE);
         while (oCreature != OBJECT_INVALID)
         {
             // Any non-PC creature not in combat needs to start combat.
             //if (!GetIsInCombat (oCreature) &&
             //    GetIsEnemy (oCreature, oPC) &&
             //    !GetIsDead (oCreature)) DelayCommand (3.0, AssignCommand (oCreature, DoMonsterCombatRound()));
             //SendMessages("Need to DoMonsterCombatRound!", COLOR_RED, oPC);
             oCreature = GetNextObjectInShape (SHAPE_SPHERE, 20.0f, GetLocation (oPC), TRUE, OBJECT_TYPE_CREATURE);
         }
     }
}

// Returns the number of creatures in a Party/faction.
// oPC is a member of the party/faction (Only use on players).
// iPCOnly will only count players if TRUE.
int GetPartySize (object oPC, int iPCOnly = TRUE)
{
    int iCounter = 0;
    object oPartyMember;
    if (GetIsCharacter (oPC))
    {
        // Get the first PC party member
        oPartyMember = GetFirstFactionMember(oPC, iPCOnly);
        // We stop when there are no more valid PC's in the party.
        while(GetIsObjectValid(oPartyMember) && iCounter < MAX_NUM_OF_PLAYERS)
        {
            // Count the number of party members.
            iCounter ++;
            // Get next party member.
            oPartyMember = GetNextFactionMember(oPC, iPCOnly);
        }
    }
    return iCounter;
}

// Save a characters pins on the map.
void SaveCharacterPins (object oPC)
{
    int inc = 1, i = GetLocalInt (oPC, "NW_TOTAL_MAP_PINS");
    string sEntry, sAreaTag, sPinID, sIncID;
    float fXpos, fYpos;
    // Clear all old map pins.
    DeleteObjectDatabase(oPC, PIN_TABLE);
    // Save all new map pins.
    while (i > 0)
    {
        sPinID = IntToString (i);
        sEntry = GetLocalString (oPC, "NW_MAP_PIN_NTRY_" + sPinID);
        if (sEntry != "")
        {
            sIncID = "PIN_" + IntToString (inc);
            fXpos = GetLocalFloat (oPC, "NW_MAP_PIN_XPOS_" + sPinID);
            fYpos = GetLocalFloat (oPC, "NW_MAP_PIN_YPOS_" + sPinID);
            sAreaTag = GetTag (GetLocalObject (oPC, "NW_MAP_PIN_AREA_" + sPinID));
            SavePinData (oPC, PIN_TABLE, sIncID, sAreaTag, fXpos, fYpos, sEntry);
            inc ++;
        }
        i --;
    }
}

int GetXpForNextLevel (int nLevel)
{
   int nXP;
   switch (nLevel)
   {
      case 0:  nXP = 0;      break;
      case 1:  nXP = 1000;   break;
      case 2:  nXP = 3000;   break;
      case 3:  nXP = 6000;   break;
      case 4:  nXP = 10000;  break;
      case 5:  nXP = 15000;  break;
      case 6:  nXP = 21000;  break;
      case 7:  nXP = 28000;  break;
      case 8:  nXP = 36000;  break;
      case 9:  nXP = 45000;   break;
      case 10: nXP = 55000;  break;
      case 11: nXP = 66000;  break;
      case 12: nXP = 78000;  break;
      case 13: nXP = 91000;  break;
      case 14: nXP = 105000; break;
      case 15: nXP = 120000; break;
      case 16: nXP = 136000; break;
      case 17: nXP = 153000; break;
      case 18: nXP = 171000; break;
      case 19: nXP = 190000; break;
      case 20: nXP = 210000; break;
      case 21: nXP = 231000; break;
      case 22: nXP = 253000; break;
      case 23: nXP = 276000; break;
      case 24: nXP = 300000; break;
      case 25: nXP = 325000; break;
      case 26: nXP = 351000; break;
      case 27: nXP = 378000; break;
      case 28: nXP = 406000; break;
      case 29: nXP = 435000; break;
      case 30: nXP = 465000; break;
      case 31: nXP = 496000; break;
      case 32: nXP = 528000; break;
      case 33: nXP = 561000; break;
      case 34: nXP = 595000; break;
      case 35: nXP = 630000; break;
      case 36: nXP = 666000; break;
      case 37: nXP = 703000; break;
      case 38: nXP = 741000; break;
      case 39: nXP = 780000; break;
   }
   return nXP;
}

int GetGoldForCurrentLevel (int nLevel)
{
   int nGP;
   switch (nLevel)
   {
      case 1:  nGP = 150;     break;
      case 2:  nGP = 900;     break;
      case 3:  nGP = 2700;    break;
      case 4:  nGP = 5400;    break;
      case 5:  nGP = 9000;    break;
      case 6:  nGP = 13000;   break;
      case 7:  nGP = 19000;   break;
      case 8:  nGP = 27000;   break;
      case 9:  nGP = 36000;   break;
      case 10: nGP = 49000;   break;
      case 11: nGP = 66000;   break;
      case 12: nGP = 88000;   break;
      case 13: nGP = 110000;  break;
      case 14: nGP = 150000;  break;
      case 15: nGP = 200000;  break;
      case 16: nGP = 260000;  break;
      case 17: nGP = 340000;  break;
      case 18: nGP = 440000;  break;
      case 19: nGP = 580000;  break;
      case 20: nGP = 760000;  break;
      case 21: nGP = 980000;  break;
      case 22: nGP = 1220000;  break;
      case 23: nGP = 1500000;  break;
      case 24: nGP = 1820000;  break;
      case 25: nGP = 2180000;  break;
      case 26: nGP = 2540000;  break;
      case 27: nGP = 2940000;  break;
      case 28: nGP = 3380000;  break;
      case 29: nGP = 3860000;  break;
      case 30: nGP = 4380000;  break;
      case 31: nGP = 4940000;  break;
      case 32: nGP = 5540000;  break;
      case 33: nGP = 6180000;  break;
      case 34: nGP = 6860000;  break;
      case 35: nGP = 7580000;  break;
      case 36: nGP = 8340000;  break;
      case 37: nGP = 9140000;  break;
      case 38: nGP = 9980000;  break;
      case 39: nGP = 10860000;  break;
      case 40: nGP = 11780000;  break;
   }
   return nGP;
}
