/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_creature
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts that are used on PC's and Creatures.

Variable: SetCombatCondition (X0_COMBAT_FLAG_*)
Options : "X0_COMBAT_FLAG_AMBUSHER" - Set enemy to use stealth to attack.
          "X0_COMBAT_FLAG_DEFENSIVE" - Set enemy to use defensive tactics.
          "X0_COMBAT_FLAG_RANGED" - Set enemy to use ranged tactics.
          "X0_COMBAT_FLAG_COWARDLY" - Set enemy to stay out of combat.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
//#include "0i_server_colors"
#include "0i_treasure"
#include "0i_magicitems"
#include "nwnx_creature"
#include "nwnx_object"
#include "nwnx_feedback"
#include "0i_checks"
#include "0i_animate"
#include "0i_effects"
#include "nw_inc_gff"
// Gives NPC's equipment, used for the delay command.
// oCreature is the creature to give the equipment to.
// nEquipment gives different equipment based on value
// 1 - Clothing only.
// 2 - Normal equipment.
// 3 - Magical equipment.
// bDroppable set if they drop the items or not.
// iPackage is the package of the creature.
void GiveCreatureEquipment(object oCreature, int nEquipment, int bDroppable = TRUE, int iPackage = PACKAGE_INVALID);
// Gives creatures xp based onlECLevels and xp slider.
// oCreature is the creature to give xp.
// fXP is the base xp to adjust before giving xp to the creature.
void AdjustXPGiveToCreature(object oCreature, float fXP);
// Returns the average character level of the party based on oPC as an int.
// oPC is a member of the party (Only use on players).
// iPCOnly will only count players if TRUE.
int GetAvgPartyLevel(object oCreature, int iPCOnly = TRUE);
// Gives xp to the players in the current area.
void GiveXPForKill(object oDeadCreature, int bBonusXP = FALSE);
// Divide out a set amount of xp to the party adjusting for the XP slider and penalties.
void GiveAreaXP(object oPoint, float fXP, float fCR);
// Returns a random name for creatures based on Boss, Gender, Race, and alignment.
// iGender is the creatures gender.
// iRace is the creatures race.
// iAlign is the creatures alignment.
// iBoss defines if the creature is a boss or not, Put the CR of the Boss.
// sName is the name of the boss creature.
string GetRandomName(int iGender, int iRace, int iAlign = ALIGNMENT_NEUTRAL, int iBoss = FALSE, string sName = "");
// Create a creature array and return any randomized fields.
// sArray is the array we are building the creature from.
// Array -0Name-1ResRef-2Tag-3Gender-4Race-5Class-6Package-7level-8Align1
// -9Align2-10Faction-11Waypointspawn-12Items-
string CreateNPCArray(string sArray = "-----------0--0-");
// Create NPC
// lLocation is the location where the creature is created.
// sArray is an array of variables to fill in the PC variables uses "-" in array.
// The array is used by CreateNPC to build and create an NPC at lLocation.
object CreateNPC(location lLocation, string sArray = "");
// Levels up a creature to the specified level by using LevelUpHenchman script.
// oCreature is the creature to level up.
// iClass is the class to level up in.
// iLevel is the level to level up to.
// iReadyAllSpells will have the NPC fully ready to cast spells.
// iPackage is a specific package for the class to use to level up.
void LevelUpCreature(object oCreature, int nClass, int nLevel, int nReadyAllSpells = FALSE, int nPackage = PACKAGE_INVALID);
// Gets the correct race type for new races.
int GetNPCRaceType(object oCreature);
// Returns TRUE if the creature has the ability to cast Arcane or Divine spells of iSpellLevel.
// iSpellLevel is the level of the spells the character must be able to cast.
// iArcane defines if we check for Arcane spells(TRUE) or Divine spells(FALSE).
int HasSpellLevel(object oCreature, int iSpellLevel, int iArcane);
// Returns TRUE if the creature has a spell ability.
// nSpellAbility is the spell ability to check for SPELLABILITY_*.
int HasSpellAbility(object oCreature, int nSpellAbility);
// Return the tracking DC based on various conditions.
// oArea is the Area being checked.
// oUser is the tracker.
// oCreature the creature to be tracked.
// lLocation is the location selected.
// iSize the size of the creature.
// iRacialType is the race of the creature.
int TrackingDC(object oArea, object oUser, object oCreature, location lLocation, int iSize = CREATURE_SIZE_INVALID, int iRacialType = RACIAL_TYPE_INVALID);
string GetFactionName(int nFaction);
// returns TRUE or FALSE if they have waterskin and rations.
// rations will be deducted from the creatures inventory.
int CheckForWaterAndRations(object oCreature);
// returns TRUE or FALSE if there is a campfire near them.
int IsCampfireNearby(object oCreature);
// Sets the forage bonus of the area for this creatures party.
void SetForageBonus(object oCreature, int nBonus);
// Gets the forage bonus of the area for this creatures party.
int GetForageBonus(object oCreature);
// Gets the forage bonus of the area for this creatures party.
void DeleteForageBonus(object oCreature);
// Sets the parties resting bonus from a survival check on the area for 1 min.
int MakePartyForageCheck(object oCreature);
// Set a creatures hitpoints to a % of wounded.
// i.e. nWounded = 50 then a creature with 18 hitpoints will be at 9 hitpoints.
// nWounded the % of damage a creature will take.
void SetCreatureAsWounded(object oCreature, int nWounded);
void SetNPCHP(object oCreature);
// Buffs casters in the on spawn script.
void CheckCasterBuffs(object oCaster = OBJECT_SELF);
void SetCreatureAuras(object oCreature);
// Check to make sure if we need to do something before we choose an action.
void CheckForClaws(object oCreature, int nCharacterLevel);
void CheckForWings(object oCreature);
// Clears old skin and reapplies all effects to a new skin if not a monster.
// Should be done on Loading in, Leveling up, Change of Deity.
// bMonster should be used on monsters spawning in as this preserves their original skin.
void SetCharacterEffectsToSkin(object oCreature, int bMonster = FALSE);
void SetCharacterEffects(object oCreature);
// Selectes a Deity for the Favored Soul class based on oCreatures race.
// Saves the Deity int to "0_Deity" on oCreature base on deities.2da
void SelectDeityForFavoredSoul(object oCreature);
void CheckForFavoredSoulFeats(object oCreature);
void CheckForFamiliarFeats(object oCreature);
void CheckForDomainFeats(object oCreature);
void CheckForFeatsToAdd(object oCreature);
void AdjustFeatUses(object oCreature);
// Adjust all summons after resting/logging in.
// Remove use if resting (nState 1) and have the summons out.
// Add the use if they are logging in (nState 2).
void AdjustSummonUses(object oCreature, int nState);
// Gives a villian a special power.
// nLevel can be set to a specific number to change the number of powers given.
void GiveVillianSpecialPower(object oCreature, int nLevel = 0);
// Will randomize a portrait for the creature if they are set with "0_Random_Portrait" var.
void SetPortrait(object oCreature);
// Setup animations for a just spawned creature.
void CheckAnimations(object oCreature);
// Pass waypoint variables to the object.
// Get any variables from oWaypoint.
// Pass them to oObject.
void PassVariables(object oWaypoint, object oObject, int bVillain = FALSE);
// Does checks for all spawned creatures after the have been spawned.
// This fires after the spawn script, but uses variables from the waypoint that spawns them.
// oCreature - the creature spawned.
// oWaypoint - the waypoint that spawned them.
// oPC - the player that spawned them.
void SetupCreature(object oCreature, object oWaypoint = OBJECT_INVALID, object oPC = OBJECT_INVALID, int bVillain = FALSE);
// Returns if the target is a humanoid (person).
int GetIsHumanoid(object oTarget);
// Action version of SaveAssociateToDatabase so we can delay the save.
// sEffect saves any special effect for oAssociate: "dead" or "petrifed".
void ActionSaveAssociateToDatabase(object oPC, object oAssociate, string sEffect = "");
// Saves oAssociate to oPC's server database.
// returns the database tag for oAssociate.
// sEffect saves any special effect for oAssociate: "dead" or "petrifed".
string SaveAssociateToDatabase(object oPC, object oAssociate, string sEffect = "");
// Removes oAssociate from oPC's henchman database.
void RemoveHenchmanFromDatabase(object oPC, object oAssociate);
// Create the remains and puts any treasure on it as well as the corpse.
void CreateRemains(object oCreature);
// Gives creatures equipment, used for the delay command.
// oCreature is the creature to give the equipment to.
// nEquipment gives different equipment based on value
// 1 - Clothing only.
// 2 - Normal equipment.
// 3 - Magical equipment.
// bDroppable set if they drop the items or not.
// iPackage is the package of the creature.
void GiveCreatureEquipment(object oCreature, int nEquipment, int bDroppable = TRUE, int iPackage = PACKAGE_INVALID)
{
    if (nEquipment == 1) GiveClothing (oCreature, bDroppable);
    else if (nEquipment == 2) GiveEquipment  (oCreature, bDroppable, -1, iPackage);
    else if (nEquipment == 3) GiveMagicalEquipment (oCreature, GetCharacterLevels (oCreature), bDroppable, iPackage);
}

// Gives creatures xp based on ECL levels and xp slider.
// oCreature is the creature to give xp.
// fXP is the base xp to adjust before giving xp to the creature.
void AdjustXPGiveToCreature (object oCreature, float fXP)
{
    int iRace;
    int iRacialXP, iRacialXPNeeded;
    float fRacialXP, fERL, fECL;
    object oArea = GetArea (oCreature);
    // See if we can give xp based on area settings.
    if (GetLocalInt (oArea, "0_XPOFF")) return;
    // Adjust the xp based on the module slider.
    float fXPSlider = GetLocalFloat (GetModule (), "0_XP_SLIDER");
    if (fXPSlider != 0.0) fXP = fXP + fXP * (fXPSlider / 100);
    // Check for ECL level
    iRace = GetRacialType (oCreature);
    fERL = GetEffectiveCharacterLevel(oCreature);
    // Adjust any ERL characters.
    if(fERL > 0.0f)
    {
        // Get any racial xp left.
        fRacialXP = GetLocalFloat (oCreature, "0_RacialXP");
        // If they have racial xp then adjust.
        if (fRacialXP > 0.0f)
        {
            // Check to see if we have used all of the xp.
            if (fRacialXP > fXP)
            {
                // Get the amount of racial xp gained.
                iRacialXP = FloatToInt (fXP);
                // Subract the racial xp gained.
                fRacialXP = fRacialXP - fXP;
                // Remove any character XP.
                fXP = 0.0f;
            }
            else
            {
                 // Get the amount of racial xp gained which is the total racial xp left.
                 iRacialXP = FloatToInt (fRacialXP);
                 // Get the amount of XP left after subtracting racial xp to add to character xp.
                 fXP = fXP - fRacialXP;
                 // Set racial xp to 0.
                 fRacialXP = 0.0f;
            }
            // Send message that they have gained racial xp.
            // If they still need racial xp then send that message as well.
            if (fRacialXP > 0.0f)
            {
                // Get racial xp needed into an int for text message.
                iRacialXPNeeded = FloatToInt (fRacialXP);
                SendMessages ("You have gained " + IntToString (iRacialXP) + " racial experience and need " + IntToString (iRacialXPNeeded) + " more.", COLOR_GREEN, oCreature);
            }
            else SendMessages ("You have fulfilled all of your racial experience by gaining " + IntToString (iRacialXP) + " racial experience.", COLOR_GREEN, oCreature);
            // Save any racial xp left.
            SetLocalFloat (oCreature, "0_RacialXP", fRacialXP);
        }
        // If there is any xp left to adjust...
        if (fXP > 0.0f)
        {
            // Get Character Level.
            fECL = IntToFloat (GetCharacterLevels (oCreature));
            // Adjust the xp by ECL / Character Level.
            //Debug ("0i_creature", "158", "fERL: " + FloatToString (fERL) + " fECL: " + FloatToString (fECL));
            fXP = fXP * (1.0f - fERL / fECL);
            if (fXP < 1.0f) fXP = 1.0f;
        }
    }
    // Give adjusted xp.
    if (fXP > 0.0f) GiveXPToCreature (oCreature, FloatToInt (fXP));
}

// Returns the average character level of the party based on oPC as an int.
// oPC is a member of the party if an NPC is passed the script will fail.
// iPCOnly will only count players if TRUE.
int GetAvgPartyLevel (object oCreature, int iPCOnly = TRUE)
{
    int iLevels = 0, iCounter = 0;
    object oPartyMember;
    if (GetIsCharacter (oCreature))
    {
        // Get the first PC party member
        oPartyMember = GetFirstFactionMember(oCreature, iPCOnly);
        // We stop when there are no more valid PC's in the party.
        while(GetIsObjectValid(oPartyMember) && iCounter < MAX_NUM_OF_PLAYERS)
        {
            // Do something to party member
            iLevels = iLevels + GetCharacterLevels (oPartyMember);
            iCounter ++;
            // Get party members Levels
            oPartyMember = GetNextFactionMember(oCreature, iPCOnly);
        }
        iLevels = iLevels / iCounter;
    }
    // Cap the minimum and maximum levels of the party.
    if (iLevels < 1) iLevels = 1;
    else if (iLevels > 40) iLevels = 40;
    return iLevels;
}
void GiveXPForKill(object oDeadCreature, int bBonusXP = FALSE)
{
   // Get the creatures CR and cap at 20.
   float fCR = GetChallengeRating (oDeadCreature);
   if (fCR > 40.0f) fCR = 40.0f;
   // Let the all lower CR's through at this time.
   //else if (fCR < 0.5) fCR = 0.5f;
   // Get the highest level PC in xp area and use that level for calculation.
   // This limits higher level pc's from farming with lower level pc's.
   // int iNumOfPCs = 0; int iTotalLevels = 0;
   int iHighestLevel = 0; int iLevel = 0;
   // We want to search for other PC's from the center of the dead creature...
   location lLocation = GetLocation (oDeadCreature);
   // Get objects within the xp area.
   object oPC = GetFirstObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
   // If the object is valid then continue.
   while (oPC != OBJECT_INVALID)
   {
      // If they are a PC then get the level and compare.
      if (GetIsCharacter (oPC))
      {
         // Get the PC's levels.
         iLevel = GetCharacterLevels (oPC);
         // Record the highest level pc in the radius.
         if (iLevel > iHighestLevel) iHighestLevel = iLevel;
      }
      // Get next object.
      oPC = GetNextObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
   }
   // Get minimum level.
   if (iHighestLevel < 1) iHighestLevel = 1;
   // Change to float for xp calculation.
   float fHighestLevel = IntToFloat (iHighestLevel);
   // Now figure out how much xp the creature was worth based on Highest Level PC and CR of the creature.
   float fBaseXPToGive = ((fCR - fHighestLevel + ADJUSTMENT_XP) / ADJUSTMENT_XP) * (BASE_XP + fCR * BASE_XP_MULTIPLIER);
   //Debug ("0i_creature", "348", "(((CR - HighestLevel) + Adj XP) / Adj XP) * BaseXP: ((("
   //                   + FloatToString (fCR, 0, 0) + " - " + FloatToString (fHighestLevel, 0, 0) + ")" + " + "
   //                   + FloatToString (ADJUSTMENT_XP, 0, 0) + ") / " + FloatToString (ADJUSTMENT_XP, 0, 0) + ")"
   //                   + FloatToString (BASE_XP, 0, 0) + " = " + FloatToString (fBaseXPToGive, 0, 0));
   // Make sure experience is a minumum of 1.
   if (fBaseXPToGive < XP_MIN) fBaseXPToGive = XP_MIN;
   // Check if this is a boss and should double the xp.
   if (bBonusXP) fBaseXPToGive = fBaseXPToGive * IntToFloat(bBonusXP);
   // Now lets give out the xp to all PC's in the xp area!
   oPC = GetFirstObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
   while (oPC != OBJECT_INVALID)
   {
      if (GetIsCharacter (oPC)) AdjustXPGiveToCreature (oPC, fBaseXPToGive);
      oPC = GetNextObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
   }
}

// Divide out a set amount of xp to anyone within XP_PARTY_RADIUS adjusted based a various things.
void GiveAreaXP (object oPoint, float fXP, float fCR)
{
   float fXPPenalty, fBaseXP, fPBaseXP;
   location lLocation = GetLocation (oPoint);
   int iHighestLevel, iLevel;
    // We want to search for other PC's from the center of the location.
    object oPC = GetFirstObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
    while (oPC != OBJECT_INVALID)
    {
        if (GetIsCharacter (oPC))
        {
            // Get the pc level.
            iLevel = GetCharacterLevels (oPC);
            // Record the highest level pc in the radius.
            if (iLevel > iHighestLevel) iHighestLevel = iLevel;
        }
        oPC = GetNextObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
    }
   // Get minimum level so we don't divide by 0.
   if (iHighestLevel == 0) iHighestLevel = 1;
   float fHighestLevel = IntToFloat (iHighestLevel);
   // Now figure out how much xp the creature was worth based on Highest Level PC and CR of the creature.
   float fBaseXPToGive = (((fCR - fHighestLevel) + ADJUSTMENT_XP) / ADJUSTMENT_XP) * fXP;
   // Check for minimum xp threshhold.
   if (fBaseXPToGive < XP_MIN) fBaseXPToGive = XP_MIN;
   // Now lets give out the xp to all PC's in the xp area!
   oPC = GetFirstObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
   while (oPC != OBJECT_INVALID)
   {
      if (GetIsCharacter (oPC)) AdjustXPGiveToCreature (oPC, fBaseXPToGive);
      oPC = GetNextObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
   }
}

void SetXpByLevel (object oPC)
{
   int iXP = 0, iLevel = GetCharacterLevels (oPC);
   // Get the correct data to add to the character.
   switch(iLevel)
   {
      case 0:  iXP = 0;      break;
      case 1:  iXP = 0;      break;
      case 2:  iXP = 1000;   break;
      case 3:  iXP = 3000;   break;
      case 4:  iXP = 6000;   break;
      case 5:  iXP = 10000;  break;
      case 6:  iXP = 15000;  break;
      case 7:  iXP = 21000;  break;
      case 8:  iXP = 28000;  break;
      case 9:  iXP = 36000;  break;
      case 10: iXP = 45000;  break;
      case 11: iXP = 55000;  break;
      case 12: iXP = 66000;  break;
      case 13: iXP = 78000;  break;
      case 14: iXP = 91000;  break;
      case 15: iXP = 105000; break;
      case 16: iXP = 120000; break;
      case 17: iXP = 136000; break;
      case 18: iXP = 153000; break;
      case 19: iXP = 171000; break;
      case 20: iXP = 190000; break;
      case 21: iXP = 210000; break;
      case 22: iXP = 231000; break;
      case 23: iXP = 253000; break;
      case 24: iXP = 276000; break;
      case 25: iXP = 300000; break;
      case 26: iXP = 325000; break;
      case 27: iXP = 351000; break;
      case 28: iXP = 378000; break;
      case 29: iXP = 406000; break;
      case 30: iXP = 435000; break;
   }
   SetXP(oPC, iXP);
}

// Returns a random name for creatures based on Boss, Gender, Race, and alignment.
// iGender is the creatures gender.
// iRace is the creatures race.
// iAlign is the creatures alignment.
// iBoss defines if the creature is a boss or not, Put the CR of the Boss.
// sName is the name of the boss creature.
string GetRandomName(int iGender, int iRace, int nAlign = ALIGNMENT_NEUTRAL, int iBoss = FALSE, string sName = "")
{
    // If a boss add prefix or suffix.
    if(iBoss > 0)
    {
        int iPrefix, iSuffix, iMain, iCR;
        string sPrefix, sSuffix, sMain, sColor, sAlignName;
        if(nAlign == ALIGNMENT_GOOD) sAlignName = "holy_";
        else if(nAlign == ALIGNMENT_EVIL) sAlignName = "unholy_";
        // Get the prefix.
        if (d100() <= 50)
        {

            iPrefix = RollOn2daTable ("names_Boss");
            sPrefix = Get2DAString ("names_Boss", sAlignName + "prefix", iPrefix);
        }
        if(d100() <= 25)
        {
            iMain = RollOn2daTable ("names_Boss");
            sName = Get2DAString ("names_Boss", sAlignName + "main", iMain);
        }
        if(d100() <= 50 || !iPrefix)
        {
            // Get the suffix.
            iSuffix = RollOn2daTable ("names_Boss");
            sSuffix = Get2DAString ("names_Boss", sAlignName + "suffix", iSuffix);
            // Clear prefix, bosses only have a prefix or suffix.
        }
        if (iBoss < 6) sColor = COLOR_MAGIC;
        else if (iBoss < 12) sColor = COLOR_EXQUISITE;
        else if (iBoss < 18) sColor = COLOR_LEGENDARY;
        else if (iBoss < 20) sColor = COLOR_RELIC;
        else sColor = COLOR_ARTIFACT;
        return AddColorToText(sPrefix + " " + sName + " " + sSuffix, sColor);
    }
    // Generate an NPC based on race and sex.
    else
    {
        int iRace, iRaceStrRef, iPrefix, iSuffix;
        string sRaceNameA, sRaceNameB, sGender, sRaceName, sPrefix, sSuffix;
        // Get the name to generate from racialtype.2da column NameGenTableA and NameGenTableB.
        sRaceNameA = Get2DAString ("racialtypes", "NameGenTableA", iRace);
        sRaceNameB = Get2DAString ("racialtypes", "NameGenTableB", iRace);
        if (sRaceNameB != "")
        {
            if (d2() == 1) sRaceName = sRaceNameA;
            else sRaceName = sRaceNameB;
        }
        else sRaceName = sRaceNameA;
        // Roll on tables to get name.
        iPrefix = RollOn2daTable ("names_" + sRaceName);
        if (iGender = 0) sGender = "male";
        else sGender = "female";
        sPrefix = Get2DAString ("names_" + sRaceName, sGender, iPrefix) + " ";
        iSuffix = RollOn2daTable ("names_" + sRaceName);
        sSuffix = Get2DAString ("names_" + sRaceName, "surname", iSuffix);
        return sPrefix + sSuffix;
    }
}

// Changes are new NPC's ability score to match class, race, & Level.
// oTarget is the oTarget is the creature to adjust.
// iClass is the class of the target.
void AdjustAbiliyScores (object oTarget, int nClass, int nRace)
{
    int nStr, nDex, nCon, nInt, nWis, nCha;
    string sText;
    // Get the Class ability scores.
    nStr = StringToInt (Get2DAString ("classes", "Str", nClass));
    nDex = StringToInt (Get2DAString ("classes", "Dex", nClass));
    nCon = StringToInt (Get2DAString ("classes", "Con", nClass));
    nWis = StringToInt (Get2DAString ("classes", "Wis", nClass));
    nInt = StringToInt (Get2DAString ("classes", "Int", nClass));
    nCha = StringToInt (Get2DAString ("classes", "Cha", nClass));
    // Adjust them for the race.
    nStr += StringToInt (Get2DAString ("racialtypes", "StrAdjust", nRace));
    nDex += StringToInt (Get2DAString ("racialtypes", "DexAdjust", nRace));
    nCon += StringToInt (Get2DAString ("racialtypes", "ConAdjust", nRace));
    nWis += StringToInt (Get2DAString ("racialtypes", "WisAdjust", nRace));
    nInt += StringToInt (Get2DAString ("racialtypes", "IntAdjust", nRace));
    nCha += StringToInt (Get2DAString ("racialtypes", "ChaAdjust", nRace));
    // Adjust ability scores.
    NWNX_Creature_SetRawAbilityScore (oTarget, ABILITY_STRENGTH, nStr);
    NWNX_Creature_SetRawAbilityScore (oTarget, ABILITY_DEXTERITY, nDex);
    NWNX_Creature_SetRawAbilityScore (oTarget, ABILITY_CONSTITUTION, nCon);
    NWNX_Creature_SetRawAbilityScore (oTarget, ABILITY_INTELLIGENCE, nInt);
    NWNX_Creature_SetRawAbilityScore (oTarget, ABILITY_WISDOM, nWis);
    NWNX_Creature_SetRawAbilityScore (oTarget, ABILITY_CHARISMA, nCha);
}

// Create a creature array and return any randomized fields.
// sArray is the array we are building the creature from.
// Any field in the array that is set to "" will be randomized if possible.
// Array -0Name-1ResRef-2Tag-3Gender-4Race-5Class-6Package-7level-8Align1
// -9Align2-10Faction-11Waypointspawn-12Items-
string CreateNPCArray(string sArray = "-----------0--0-")
{
    int nSwitch, nClass, nLawChaos, nGoodEvil;
    string sRace, sClass, sLevel, sGender, sName, sAlign1, sAlign2, sPackage;
    // Check gender.
    sGender = GetStringArray (sArray, 3, "-");
    // If gender is blank then randomize.
    if(sGender == "") sArray = SetStringArray(sArray, 3, IntToString (Random (2)), "-");
    // Check race.
    sRace = GetStringArray(sArray, 4, "-");
    // If Race is blank then randomize.
    if(sRace == "")
    {
        nSwitch = d100();
        if(nSwitch < 6) sRace = "36"; // Dwarf Shield
        else if(nSwitch < 11) sRace = "37"; // Dwarf Gold
        else if(nSwitch < 16) sRace = "39"; // Elf Moon
        else if(nSwitch < 19) sRace = "40"; // Elf Sun
        else if(nSwitch < 20) sRace = "41"; // Elf Wood
        else if(nSwitch < 25) sRace = "44"; // Gnome Rock
        else if(nSwitch < 26) sRace = "45"; // Gnome Forest
        else if(nSwitch < 30) sRace = "48"; // Halfling Lightfoot
        else if(nSwitch < 35) sRace = "49"; // Halfling Strongheart
        else if(nSwitch < 36) sRace = "50"; // Halfling Ghostwise
        else if(nSwitch < 37) sRace = "51"; // Half elf Moon
        else if(nSwitch < 38) sRace = "52"; // Half elf Sun
        else if(nSwitch < 39) sRace = "53"; // Half elf Wood
        else if(nSwitch < 44) sRace = "56"; // Half orc
        else if(nSwitch < 52) sRace = "30"; // Human Damaran
        else if(nSwitch < 61) sRace = "31"; // Human Iluskan
        else if(nSwitch < 69) sRace = "32"; // Human Rashemi
        else if(nSwitch < 77) sRace = "33"; // Human Mulan
        else if(nSwitch < 85) sRace = "34"; // Human Tethyrian
        else if(nSwitch < 98) sRace = "35"; // Human Chondathan
        else if(nSwitch < 99) // Rare races
        {
            nSwitch = d100();
            if(nSwitch < 15) sRace = "38"; // Dwarf Duergar
            else if(nSwitch < 31) sRace = "46"; // Gnome Svirfneblin
            else if(nSwitch < 47) sRace = "42"; // Elf Drow
            else if(nSwitch < 48) sRace = "43"; // Elf Star
            else if(nSwitch < 49) sRace = "55"; // Half elf Star
            else if(nSwitch < 50) sRace = "54"; // Half elf Drow
            else if(nSwitch < 66) sRace = "58"; // Orc Mountain
            else if(nSwitch < 81) sRace = "59"; // Orc Gray
            else if(nSwitch < 91) sRace = "57"; // Kobold
            else sRace = "47"; // Goblin
        }
        else // Outsiders
        {
            nSwitch = d100();
            if(nSwitch < 17) sRace = "60"; // Aasimar
            else if(nSwitch < 34) sRace = "61"; // Tiefling
            else if(nSwitch < 51) sRace = "62"; // Air Genasi
            else if(nSwitch < 68) sRace = "63"; // Earth Genasi
            else if(nSwitch < 85) sRace = "64"; // Fire Genasi
            else sRace = "65"; // Water Genasi
        }
        sArray = SetStringArray(sArray, 4, sRace, "-");
    }
    // Check name.
    sName = GetStringArray (sArray, 0, "-");
    // If name is blank then set to randomize name.
    if(sName == "" || sName == "random")
    {
        sName = GetRandomName(StringToInt(sGender), StringToInt(sRace));
        sArray = SetStringArray(sArray, 0, sName, "-");
    }
    // Check class.
    sClass = GetStringArray(sArray, 5, "-");
    // If Class is blank then randomize.
    if(sClass == "")
    {
       nSwitch = d100();
       if(nSwitch <= 5) sClass = "0"; // Barbarian
       else if(nSwitch <= 10) sClass = "1"; // Bard
       else if(nSwitch <= 20) sClass = "2"; // Cleric
       else if(nSwitch <= 22) sClass = "3"; // Druid
       else if(nSwitch <= 52) sClass = "4"; // Fighter
       else if(nSwitch <= 54) sClass = "5"; // Monk
       else if(nSwitch <= 59) sClass = "46"; // Ranger
       else if(nSwitch <= 79) sClass = "8"; // Rogue
       else if(nSwitch <= 85) sClass = "9"; // Sorcerer
       else if(nSwitch <= 95) sClass = "10"; // Wizard
       else if(nSwitch <= 97) sClass = "47"; // Favored Soul
       else sClass = "9"; // must fix class. "48"; // Warmage
       nClass = StringToInt(sClass);
       sArray = SetStringArray(sArray, 5, sClass, "-");
    }
    // Check if package is set if not then randomize.
    sPackage = GetStringArray (sArray, 6, "-");
    if(sPackage == "")
    {
        nSwitch = StringToInt (sClass);
        if(d100() > 50)
        {
            // Packages.2da has 5 alternate packages for each class set at 150+.
            nSwitch = (nSwitch * 5) + 66 + Random(5);
            if(Get2DAString ("packages", "Name", nSwitch) == "") sPackage = sClass;
            else sPackage = IntToString(nSwitch);
        }
        else sPackage = sClass;
        sArray = SetStringArray (sArray, 6, sPackage, "-");
    }
    // Check Level.
    sLevel = GetStringArray (sArray, 7, "-");
    // If level is blank then randomize.
    if(sLevel == "") sArray = SetStringArray (sArray, 7, IntToString (d20()), "-");
    // Check Align1.
    sAlign1 = GetStringArray (sArray, 8, "-");
    // If Align1 is blank then randomize. 1-Neutral, 2-Lawful, 3-Chaotic
    if(sAlign1 == "")
    {
        // Adjust alignment for class restrictions law/chaos.
        if(nClass == CLASS_TYPE_BARD || nClass == CLASS_TYPE_BARBARIAN)
        {
            nLawChaos = Random(2) + 1;
        }
        if(nClass == CLASS_TYPE_MONK) nLawChaos = ALIGNMENT_LAWFUL;
        else nLawChaos = d3();
        sArray = SetStringArray(sArray, 8, IntToString(nLawChaos), "-");
    }
    // Check Align2.
    sAlign2 = GetStringArray(sArray, 9, "-");
    // If Align2 is blank then randomize. 4-Good 5-Evil
    if(sAlign2 == "")
    {
        // Adjust alignment for class restrictions good/evil.
        if(nClass == 45 /*Paladin*/) nGoodEvil = ALIGNMENT_GOOD;
        if(nClass == CLASS_TYPE_DRUID)
        {
            if(nLawChaos != ALIGNMENT_NEUTRAL || nGoodEvil != ALIGNMENT_NEUTRAL)
            {
                nSwitch = Random(2);
                if(nSwitch == 0) nLawChaos = ALIGNMENT_NEUTRAL;
                else nGoodEvil = ALIGNMENT_NEUTRAL;
            }
        }
        else
        {
            nSwitch = d6();
            if(nSwitch < 3) nGoodEvil = ALIGNMENT_GOOD;
            else if(nSwitch < 5) nGoodEvil = ALIGNMENT_NEUTRAL;
            else nGoodEvil = ALIGNMENT_EVIL;
        }
        sArray = SetStringArray(sArray, 9, IntToString (nGoodEvil), "-");
    }
    return sArray;
}

// Create NPC
// lLocation is the location where the creature is created.
// sArray is an array of variables to fill in the PC variables uses "-" in array.
// The array is used by CreateNPC to build and create an NPC at lLocation.
object CreateNPC(location lLocation, string sArray = "")
{
    int iClass, iSwitch, iPackage, iStat, iLevel, nRace, iAlignGE, iAlignLC;
    string sText, sResRef, sSkin, sPackage;
    object oCreature, oSkin;
    // Get the set information from the array and create the NPC.
    // Array -0Name-1ResRef-2Tag-3Gender-4Race-5Class-6Package-7level-8Align1
    //       -9Align2-10Faction-11Waypointspawn-12Items-
    // First see if they have a ResRef.
    //Debug ("0i_creature", "633", "sArray: " + sArray + " iQuestNPC: " + IntToString (iQuestNPC));
    sResRef = GetStringArray(sArray, 1, "-");
    if(sResRef != "")
    {
        oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
        if(!GetIsObjectValid (oCreature))
        {
              SetModuleError("RESREF", "0i_creature", "734", "Cannot create NPC! ResRef (" +  sResRef +
                              " Location: " + LocationToStringArray (lLocation) + ")");
        }
    }
    // Generate the creature based on variables in the array.
    else
    {
        // Get gender.
        iSwitch = StringToInt(GetStringArray (sArray, 3, "-"));
        if(iSwitch) sText = "f_";
        else sText = "m_";
        // Get race.
        string sRace = GetStringArray(sArray, 4, "-");
        nRace = StringToInt(sRace);
        sText = sText + sRace;
        // Create NPC.
        oCreature = CreateObject(OBJECT_TYPE_CREATURE, sText, lLocation);
        if(!GetIsObjectValid(oCreature))
        {
              SetModuleError("RESREF", "0i_creature", "728", "Invalid Creature: ResRef (" +  sText + ") " +
                              " lLocation: " + LocationToStringArray(lLocation) + " Generating a male, human (Chondathan) instead.");
              // Generate a generic NPC (Male, Human (Chondathan) on failure.
              oCreature = CreateObject(OBJECT_TYPE_CREATURE, "m_35", lLocation);
              sArray = "-Male-----4-4-3-1-1-4--1-";
        }
        // Set the faction.
        iSwitch = StringToInt (GetStringArray (sArray, 10, "-"));
        if (iSwitch < 4) ChangeToStandardFaction (oCreature, iSwitch);
        else
        {
            object oNeutralFaction = GetObjectByTag ("neutral_faction");
            ChangeFaction (oCreature, oNeutralFaction);
        }
        // Set faction values.
        SetLocalInt (oCreature, "0_PermanentFaction", iSwitch);
        SetLocalInt (oCreature, "0_CurrentFaction", iSwitch);
        // Get class.
        iClass = StringToInt (GetStringArray (sArray, 5, "-"));
        NWNX_Creature_SetClassByPosition (oCreature, 0, iClass);
        NWNX_Creature_SetLevelByPosition (oCreature, 0, 0);
        // Get package.
        sPackage = GetStringArray (sArray, 6, "-");
        if (sPackage == "") iPackage = iClass;
        else iPackage = StringToInt (sPackage);
        // Set Alignment.
        iAlignLC = StringToInt (GetStringArray (sArray, 8, "-"));
        if (iClass == CLASS_TYPE_MONK) iAlignLC = ALIGNMENT_LAWFUL;
        AdjustAlignment (oCreature, iAlignLC, 100);
        iAlignGE = StringToInt (GetStringArray (sArray, 9, "-"));
        if (iClass == 45/*CLASS_TYPE_PALADIN*/) iAlignGE = ALIGNMENT_GOOD;
        else if (iClass == CLASS_TYPE_DRUID) iAlignGE = ALIGNMENT_NEUTRAL;
        AdjustAlignment (oCreature, iAlignGE, 100);
        // Set ability scores.
        AdjustAbiliyScores (oCreature, iClass, nRace);
        // Level up NPC.
        iLevel = StringToInt (GetStringArray (sArray, 7, "-"));
        LevelUpCreature (oCreature, iClass, iLevel, TRUE, iPackage);
        // Set hitpoints based on server level vs Hitpoints for hostile npcs.
        if (iSwitch == 0) SetNPCHP (oCreature);
        // Check for Comanion or Familiar
        sText = Get2DAString ("packages", "Associate", iPackage);
        if (sText != "")
        {
            if (iClass == CLASS_TYPE_DRUID || iClass == 46 /*CLASS_TYPE_RANGER*/)
            {
                SetLocalString (oCreature, "0_COMPANION", sText);
            }
            else if (iClass == CLASS_TYPE_WIZARD || iClass == CLASS_TYPE_SORCERER)
            {
                SetLocalString (oCreature, "0_FAMILIAR", sText);
            }
        }
        // Mark the NPC as generated.
        SetLocalInt (oCreature, "0_Generated_NPC", TRUE);
    }
    // Set Name.
    sText = GetStringArray (sArray, 0, "-");
    if (sText != "") SetName (oCreature, sText);
    // Set creatures new Tag.
    string sName = GetName(oCreature);
    string sTag = GetStringLeft(sName, 5) + "_" +
                  GetStringRight(sName, 5) + "_" + IntToString(Random(1000));
    SetTag(oCreature, GetStringLowerCase(sTag));
    return oCreature;
}
// Levels up a creature to the specified level by using LevelUpHenchman script.
// oCreature is the creature to level up.
// iClass is the class to level up in.
// iLevel is the level to level up to.
// iReadyAllSpells will have the NPC fully ready to cast spells.
// iPackage is a specific package for the class to use to level up.
void LevelUpCreature (object oCreature, int nClass, int nLevel, int nReadyAllSpells = FALSE, int nPackage = PACKAGE_INVALID)
{
   int nLvlCounter = nLevel;
    // Minimum level is 1.
    if (nLvlCounter < 1) nLvlCounter = 1;
     while (nLvlCounter > 0)
    {
        if (!LevelUpHenchman (oCreature, CLASS_TYPE_INVALID, nReadyAllSpells, nPackage))
        {
           SetModuleError  ("LEVEL UP", "0i_creature", "801", "Did not level up NPC! Name: " + GetName (oCreature) +
                             " Level: " + IntToString (GetLevelByClass (nClass, oCreature)) +
                             " Class: " + IntToString (nClass) +
                             " Spells: " + IntToString (nReadyAllSpells) +
                             " Package: " + IntToString (nPackage));
           nLvlCounter = 0;
        }
        else nLvlCounter --;
    }
}

// Gets the correct base race type for NPC races.
// oCreature is the creature to get the race id for.
// nNPCRace will return the NPC race id number for random NPC's.
int GetNPCRaceType(object oCreature)
{
    return GetLocalInt(oCreature, "0_RacialType");
}

// Returns TRUE if the creature has the ability to cast Arcane or Divine spells of iSpellLevel.
// iSpellLevel is the level of the spells the character must be able to cast.
// iArcane defines if we check for Arcane spells TRUE(1) or Divine spells FALSE(0).
int HasSpellLevel (object oCreature, int iSpellLevel, int iArcane)
{
    int iClassSlot, iClass, iLevel, iAbility;
    string sSpellGainTable, sSpellsAtLevel, sSCA;
    // if classes.2da column "Arcane" is "1" for arcane or "0" for divine.
    for (iClassSlot = 1; iClassSlot < 4; iClassSlot++)
    {
        iClass = GetClassByPosition (iClassSlot, oCreature);
        if (iClass != CLASS_TYPE_INVALID)
        {
            // First check to make sure that thier SpellCastingAbil is high enought to cast the level of spells.
            sSCA = Get2DAString ("classes", "SpellcastingAbil", iClass);
            if (sSCA == "INT") iAbility = GetAbilityScore (oCreature, ABILITY_INTELLIGENCE, TRUE);
            else if (sSCA == "WIS") iAbility = GetAbilityScore (oCreature, ABILITY_WISDOM, TRUE);
            else if (sSCA == "CHA") iAbility = GetAbilityScore (oCreature, ABILITY_CHARISMA, TRUE);
            else if (sSCA == "STR") iAbility = GetAbilityScore (oCreature, ABILITY_STRENGTH, TRUE);
            else if (sSCA == "DEX") iAbility = GetAbilityScore (oCreature, ABILITY_DEXTERITY, TRUE);
            else if (sSCA == "CON") iAbility = GetAbilityScore (oCreature, ABILITY_CONSTITUTION, TRUE);
            else iAbility = 0;
            // Check if they have a SpellGainTable in the classes.2da this shows that they cast spells.
            sSpellGainTable = Get2DAString ("classes", "SpellGainTable", iClass);
            // Match up arcane vs divine if they do have a spell gain table.
            if (Get2DAString ("classes", "Arcane", iClass) == IntToString (iArcane) && sSpellGainTable != "")
            {
                // Table rows are off by one since they start at 0 instead of 1!
                iLevel = GetLevelByClass (iClass, oCreature) - 1;
                sSpellsAtLevel = Get2DAString (sSpellGainTable, "SpellLevel" + IntToString (iSpellLevel), iLevel);
                if (sSpellsAtLevel != "" && iAbility >= iSpellLevel + 10) return TRUE;
            }
        }
    }
    return FALSE;
}

// Returns TRUE if the creature has a spell ability.
// nSpellAbility is the spell ability to check for SPELLABILITY_*.
int HasSpellAbility (object oCreature, int nSpellAbility)
{
    int nIndex, nMaxIndex = NWNX_Creature_GetSpecialAbilityCount (oCreature);
    struct NWNX_Creature_SpecialAbility stSpellAbility;
    while (nIndex < nMaxIndex)
    {
        stSpellAbility = NWNX_Creature_GetSpecialAbility (oCreature, nIndex);
        if (stSpellAbility.id == nSpellAbility) return TRUE;
        nIndex ++;
    }
    return FALSE;
}

// Return the tracking DC based on various conditions.
// oArea is the Area being checked.
// oUser is the tracker.
// oCreature the creature to be tracked.
// lLocation is the location selected.
// iSize the size of the creature.
// iRacialType is the race of the creature.
int TrackingDC (object oArea, object oUser, object oCreature, location lLocation, int iSize = CREATURE_SIZE_INVALID, int iRacialType = RACIAL_TYPE_INVALID)
{
    int nAdjustment, iDC;
    // Get the surface.
    nAdjustment = GetSurfaceMaterial (lLocation);
    switch (nAdjustment)
    {
        // Very soft ground: puddles, swamp, mud, snow, sand.
        case 11: case 12: case 13: case 19: case 20:
            iDC = 5; break;
        // Soft ground: dirt, leaves.
        case 1: case 14:
            iDC = 10; break;
        // Firm ground: grass, carpet, barebones.
        case 3: case 9: case 21:
            iDC = 15; break;
        // Hard ground: stone, wood, water, metal, door, stonebridge.
        case 4: case 5: case 6: case 10: case 18: case 22:
            iDC = 20; break;
        default : iDC = 15; break;
    }
    // Check the weather.
    nAdjustment = GetWeather (oArea);
    // Book: Rain +1 per hour of rain (+ 1 to 6) and +3 if it is raining.
    if (nAdjustment == WEATHER_RAIN) iDC = iDC + d6() + 3;
    // Book: Snow +10 if fresh snow cover (+1 to +10).
    else if (nAdjustment == WEATHER_SNOW) iDC = iDC + d10() + 3;
    // Check the time of day.
    // Book: Moonless +6, moonlight +3.
    if (!GetIsDay())
    {
        int nDay = GetCalendarDay ();
        switch (nDay)
        {
            case 1: case 2: case 3: case 4: nAdjustment = 6;break; // New moon.
            case 5: case 6: case 7: nAdjustment = 5; break;
            case 8: case 9: case 10: nAdjustment =  4; break;
            case 11: case 12: case 13: nAdjustment = 3; break;
            case 14: case 15: case 16: nAdjustment = 3;break; // Full moon.
            case 17: case 18: case 19: nAdjustment = 3;break; // Full moon.
            case 20: case 21: case 22: nAdjustment = 3;break;
            case 23: case 24: case 25: nAdjustment = 4;break;
            case 26: case 27: case 28: nAdjustment = 5;break;
            default: nAdjustment = 3;
        }
        iDC = iDC + nAdjustment;
    }
    // Check for generated characters i.e. villains.
    // They are harder to track in an area.
    if (GetLocalInt (oCreature, "0_Generated_NPC")) iDC = iDC + 5;
    // Get the size of the creature if we have one.
    if (iSize == CREATURE_SIZE_INVALID) iSize = GetCreatureSize (oCreature);
    switch (iSize)
    {
        case CREATURE_SIZE_TINY: iDC = iDC + 8; break;
        case CREATURE_SIZE_SMALL: iDC = iDC + 4; break;
        case CREATURE_SIZE_LARGE: iDC = iDC - 4; break;
        case CREATURE_SIZE_HUGE: iDC = iDC - 8; break;
        default : break;
    }
    // Check for favored enemy.
    nAdjustment = GetLevelByClass (CLASS_TYPE_RANGER, oUser);
    if (nAdjustment > 0)
    {
        // The the Rangers Favored enemy bonus.
        if (iRacialType == RACIAL_TYPE_INVALID) iRacialType = GetRacialType (oCreature);
        nAdjustment = (nAdjustment / 5) + 1;
        if (nAdjustment < 1) nAdjustment = 1;
        if (iRacialType == RACIAL_TYPE_ABERRATION && GetHasFeat (FEAT_FAVORED_ENEMY_ABERRATION))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_ANIMAL && GetHasFeat (FEAT_FAVORED_ENEMY_ANIMAL))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_CONSTRUCT && GetHasFeat (FEAT_FAVORED_ENEMY_CONSTRUCT))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_DRAGON && GetHasFeat (FEAT_FAVORED_ENEMY_DRAGON))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_DWARF && GetHasFeat (FEAT_FAVORED_ENEMY_DWARF))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_ELEMENTAL && GetHasFeat (FEAT_FAVORED_ENEMY_ELEMENTAL))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_ELF && GetHasFeat (FEAT_FAVORED_ENEMY_ELF))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_FEY && GetHasFeat (FEAT_FAVORED_ENEMY_FEY))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_GIANT && GetHasFeat (FEAT_FAVORED_ENEMY_GIANT))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_GNOME && GetHasFeat (FEAT_FAVORED_ENEMY_GNOME))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_HUMANOID_GOBLINOID && GetHasFeat (FEAT_FAVORED_ENEMY_GOBLINOID))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_HALFELF && GetHasFeat (FEAT_FAVORED_ENEMY_HALFELF))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_HALFLING && GetHasFeat (FEAT_FAVORED_ENEMY_HALFLING))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_HALFORC && GetHasFeat (FEAT_FAVORED_ENEMY_HALFORC))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_HUMAN && GetHasFeat (FEAT_FAVORED_ENEMY_HUMAN))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_MAGICAL_BEAST && GetHasFeat (FEAT_FAVORED_ENEMY_MAGICAL_BEAST))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_HUMANOID_MONSTROUS && GetHasFeat (FEAT_FAVORED_ENEMY_MONSTROUS))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_HUMANOID_ORC && GetHasFeat (FEAT_FAVORED_ENEMY_ORC))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_OUTSIDER && GetHasFeat (FEAT_FAVORED_ENEMY_OUTSIDER))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN && GetHasFeat (FEAT_FAVORED_ENEMY_REPTILIAN))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_SHAPECHANGER && GetHasFeat (FEAT_FAVORED_ENEMY_SHAPECHANGER))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_UNDEAD && GetHasFeat (FEAT_FAVORED_ENEMY_UNDEAD))
            iDC = iDC + nAdjustment;
        else if (iRacialType == RACIAL_TYPE_VERMIN && GetHasFeat (FEAT_FAVORED_ENEMY_VERMIN))
            iDC = iDC + nAdjustment;
    }
    return iDC;
}

string GetFactionName (int nFaction)
{
    if (nFaction == 0) return "Hostile";
    else if (nFaction == 1) return "Commoner";
    else if (nFaction == 2) return "Merchant";
    else if (nFaction == 3) return "Defender";
    else if (nFaction == 4) return "Neutral";
    return "";
}

int CheckForWaterAndRations(object oCreature)
{
    int bRations, bWaterskin, nStack;
    string sTag;
    object oRations;
    float fDistance;
    object oArea = GetArea(oCreature);
    // Check inventory for Rations and Waterskin.
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        sTag = GetTag(oItem);
        if(sTag == "0_rations")
        {
            bRations = TRUE;
            oRations = oItem;
            if(bWaterskin) break;
        }
        else if(sTag == "0_waterskin")
        {
            bWaterskin = TRUE;
            if(bRations) break;
        }
        oItem = GetNextItemInInventory(oCreature);
    }
    // if true remove rations and increase the health bonus by +1.
    if (bRations && bWaterskin)
    {
        nStack = GetItemStackSize(oRations);
        if(nStack == 1)
        {
            DestroyObject(oRations);
            // Check and alert player if they are low on rations.
            bRations = FALSE;
            oItem = GetFirstItemInInventory(oCreature);
            while(GetIsObjectValid(oItem))
            {
                if(GetResRef(oItem) == "0_rations" && oItem != oRations) bRations = TRUE;
                oItem = GetNextItemInInventory(oCreature);
            }
            if(!bRations) SendMessages ("You are out of rations!", COLOR_RED, oCreature, FALSE, FALSE);
        }
        else SetItemStackSize(oRations, -- nStack);
        return TRUE;
    }
    return FALSE;
}

int IsCampfireNearby(object oCreature)
{
    object oCampfire = GetNearestObjectByTag("Campfire", oCreature);
    float fDistance = GetDistanceBetween (oCampfire, oCreature);
    if (fDistance <= 10.0f && fDistance != 0.0f) return TRUE;
    return FALSE;
}

object GetPartyMemberWithBestSurvival(object oCreature)
{
    int nSurvival, nBestSurvival = -99;
    object oBestPMSurvival;
    object oPartyMember = GetFirstFactionMember (oCreature, FALSE);
    while (oPartyMember != OBJECT_INVALID)
    {
        nSurvival = GetSkillRank (SKILL_SURVIVAL, oPartyMember);
        //Debug ("0i_creature", "1060", " oPartyMember: " + GetName (oPartyMember) + " nSuvival: " + IntToString (nSurvival));
        if (nSurvival > nBestSurvival)
        {
            nBestSurvival = nSurvival;
            oBestPMSurvival = oPartyMember;
        }
        oPartyMember = GetNextFactionMember (oCreature, FALSE);
    }
    //Debug ("0i_creature", "1067", "oBestPMSurvival: " + GetName (oBestPMSurvival));
    return oBestPMSurvival;
}

// Sets the forage bonus of the area for this creatures party.
void SetForageBonus(object oPC, int nBonus)
{
    object oArea = GetArea(oPC);
    SetLocalInt(oArea, "0_ForageBonus_" + RemoveIllegalCharacters(GetName (oPC)), nBonus);
    DelayCommand(300.0, DeleteLocalInt(oArea, "0_ForageBonus_" + RemoveIllegalCharacters(GetName (oPC))));
}

// Gets the forage bonus of the area for this creatures party.
int GetForageBonus (object oCreature)
{

    object oForager = GetPartyMemberWithBestSurvival (oCreature);
    return GetLocalInt (GetArea (oCreature), "0_ForageBonus_" + RemoveIllegalCharacters (GetName (oCreature)));
}

// Deletes the forage bonus of the area for this creatures party.
void DeleteForageBonus (object oCreature)
{

    object oForager = GetPartyMemberWithBestSurvival (oCreature);
    DeleteLocalInt (GetArea (oCreature), "0_ForageBonus_" + RemoveIllegalCharacters (GetName (oCreature)));
}
int MakePartyForageCheck(object oPC)
{
    int nRestingBonusHP;
    string sText;
    object oArea = GetArea(oPC);
    // Make a survival skill check to see if they forage for food, water and save place to rest.
    // Lets get the best survival check of the party.
    object oForager = GetPartyMemberWithBestSurvival(oPC);
    // We check against DC 10 as that is the lowest DC to be successful.
    int nDC = 10;
    // Harsh weather?
    int nWeather = GetWeather(oArea);
    if(nWeather == WEATHER_RAIN) nDC += 2;
    else if(nWeather == WEATHER_SNOW) nDC += 2;
    // Need to add +6 to the DC for storms!
    // How cold is it?
    if(!GetIsAreaInterior(oArea))
    {
        int nTemp = GetServerDatabaseInt(GetModule(), SERVER_TABLE, "temperature");
        if(nTemp < 51) nDC += ((100 - nTemp) / 10) - 3;
        //Debug ("0i_creature", "1124", "nTemp: " + IntToString (nTemp) + " nDC: " + IntToString (nDC));
    }
    int nCheck = GetSkillCheck(oForager, SKILL_CRAFT_ARMOR, FALSE, 0, nDC, TRUE, FALSE);
    if(oPC == oForager) sText = "You have ";
    else sText = "Your party has ";
    //Debug ("0i_creature", "1083", "nCheck: " + IntToString (nCheck));
    // Made survival check rolled 10+
    if(nCheck > 0)
    {
        // Rolled 20+ (Same as Bedroll, Campfire, Food & Rations).
        if (nCheck >= 10) SendMessages (sText + "successfully foraged for food, water and a great place to rest.", COLOR_GREEN, oPC, FALSE, FALSE);
        // Rolled 15 - 19 (Same as Bedroll & Campfire).
        // Forage successful bonus 3 also check for food & water.
        else if (nCheck >= 5)
        {
            SendMessages (sText + "successfully found a good place to rest.", COLOR_GREEN, oPC, FALSE, FALSE);
        }
        // Rolled 10 - 14 (Same as a bedroll).
        // Forage successful bonus 2 also check for food, water & campfire.
        else
        {
            SendMessages (sText + "successfully found a place to rest.", COLOR_GREEN, oPC, FALSE, FALSE);
        }
        // +1 Base bonus +1 Bedroll: +Bonus over a roll of 20. i.e. 25 +1, 30 + 2, 35 +3, etc.
        nRestingBonusHP = nRestingBonusHP + (nCheck / 5) + 2;
        SetForageBonus(oPC, nRestingBonusHP);
    }
    // Failed forage check gives the base bonus of 1.
    else
    {
        SetForageBonus(oPC, 1);
        return 1;
    }
    return nRestingBonusHP;
}

// Set a creatures hitpoints to a % of wounded.
// i.e. nWounded = 75 then a creature with 100 max hitpoints will be at 75 hitpoints.
// nWounded the % of damage a creature will take.
void SetCreatureAsWounded (object oCreature, int nWounded)
{
    if (nWounded > 99) nWounded = 99;
    else if (nWounded < 1) return;
    float fMaxHP = IntToFloat (GetMaxHitPoints (oCreature));
    float fWounded = IntToFloat (nWounded);
    float fHP = fMaxHP * (fWounded * 0.01);
    if (fHP < 1.0f) fHP = 1.0f;
    NWNX_Object_SetCurrentHitPoints (oCreature, FloatToInt (fHP));
}

void SetNPCHP (object oCreature)
{
    int nTotalHP;
    int nClass = GetClassByPosition (1, oCreature);
    int nLevel = GetCharacterLevels  (oCreature);
    int nPower = (nLevel / 5) + 1;
    float fHPPower = IntToFloat (nPower) / 2.0f;
    if (fHPPower < 1.0f) fHPPower = 1.0f;
    int nHP;
    switch (nClass)
    {
        case CLASS_TYPE_SORCERER:
        case CLASS_TYPE_WIZARD:
        case 48/*CLASS_TYPE_WARMAGE*/:
            nHP = 6;
            break;
        case CLASS_TYPE_BARD:
        case CLASS_TYPE_CLERIC:
        case CLASS_TYPE_DRUID:
        case CLASS_TYPE_ROGUE:
        case 47/*CLASS_TYPE_FAVOREDSOUL*/:
            nHP = 8;
            break;
        case CLASS_TYPE_FIGHTER:
        case CLASS_TYPE_MONK:
        case 45/*CLASS_TYPE_PALADIN*/:
        case 46/*CLASS_TYPE_RANGER*/:
        case 43/*CLASS_TYPE_SWASHBUCKLER*/:
            nHP = 10;
            break;
        case CLASS_TYPE_BARBARIAN:
            nHP = 12;
            break;
        default :
            nHP = 8;
            break;
    }
    nTotalHP = FloatToInt (IntToFloat (nHP * nLevel) * fHPPower);
    NWNX_Object_SetMaxHitPoints (oCreature, nTotalHP);
    SetCurrentHitPoints (oCreature, GetMaxHitPoints (oCreature));
}
// Caster buffs are set to Cheat due to Cleric domain spells of higher level.
void CheckCasterBuffs (object oCaster = OBJECT_SELF)
{
    int i = 1, nClass;
    // Check for casters so they can be prepaired.
    nClass = GetClassByPosition (i, oCaster);
    while (i < 6)
    {
        if (nClass == CLASS_TYPE_CLERIC || nClass == CLASS_TYPE_WIZARD ||
            nClass == CLASS_TYPE_SORCERER || nClass == CLASS_TYPE_BARD ||
            nClass == CLASS_TYPE_DRUID || nClass == 47/*CLASS_TYPE_FAVORED_SOUL*/) break;
        else nClass = GetClassByPosition (++i, oCaster);
    }
    //Debug ("0i_creature", "1225", GetName (oCaster) + " is using class: " + IntToString (nClass));
    if (nClass != CLASS_TYPE_INVALID)
    {
        //int nCounter;
        //for (nCounter = 0; nCounter < 10; nCounter++) { ReadySpellLevel (oCaster, nCounter);}
        int nLevel = GetLevelByClass (nClass, oCaster);
        //Debug ("0i_creature", "1231", GetName (oCaster) + " is level " + IntToString (nLevel));
        // 1st Level spells
        if (GetHasSpell (SPELL_ENERGY_BUFFER, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_ENERGY_BUFFER, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_PROTECTION_FROM_ELEMENTS, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_PROTECTION_FROM_ELEMENTS, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_RESIST_ELEMENTS, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_RESIST_ELEMENTS, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_ENDURE_ELEMENTS, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_ENDURE_ELEMENTS, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (962/*SPELL_GREATER_MAGE_ARMOR*/ , oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (962/*SPELL_GREATER_MAGE_ARMOR*/, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_MAGE_ARMOR, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_MAGE_ARMOR, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_MAGIC_VESTMENT, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_MAGIC_VESTMENT, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_GREATER_MAGIC_WEAPON, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_MAGIC_WEAPON, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_MAGIC_WEAPON, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_MAGIC_WEAPON, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_SUMMON_CREATURE_IX, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_IX, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_SUMMON_CREATURE_VIII, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_VIII, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_SUMMON_CREATURE_VII, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_VII, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_SUMMON_CREATURE_VI, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_VI, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_SUMMON_CREATURE_V, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_V, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_SUMMON_CREATURE_IV, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_IV, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_SUMMON_CREATURE_III, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_III, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_SUMMON_CREATURE_II, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_II, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_SUMMON_CREATURE_I, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SUMMON_CREATURE_I, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_BARKSKIN, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_BARKSKIN, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_SHIELD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SHIELD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_ENTROPIC_SHIELD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_ENTROPIC_SHIELD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_SHIELD_OF_FAITH, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SHIELD_OF_FAITH, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_REMOVE_FEAR, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_REMOVE_FEAR, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_IRONGUTS, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_IRONGUTS, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 2nd Level spells
        if (nLevel > 2)
        {
        if (GetHasSpell (SPELL_PREMONITION, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_PREMONITION, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_GREATER_STONESKIN, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_STONESKIN, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_GHOSTLY_VISAGE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GHOSTLY_VISAGE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_IMPROVED_INVISIBILITY, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_IMPROVED_INVISIBILITY, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_INVISIBILITY_SPHERE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_INVISIBILITY_SPHERE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_INVISIBILITY, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_INVISIBILITY, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_GREATER_BULLS_STRENGTH, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_BULLS_STRENGTH, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_BULLS_STRENGTH, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_BULLS_STRENGTH, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_GREATER_CATS_GRACE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_CATS_GRACE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_CATS_GRACE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_CATS_GRACE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_GREATER_EAGLE_SPLENDOR, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_EAGLE_SPLENDOR, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_EAGLE_SPLEDOR, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_EAGLE_SPLEDOR, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_GREATER_ENDURANCE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_ENDURANCE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_ENDURANCE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_ENDURANCE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_GREATER_FOXS_CUNNING, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_FOXS_CUNNING, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_FOXS_CUNNING, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_FOXS_CUNNING, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_GREATER_OWLS_WISDOM, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_OWLS_WISDOM, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_OWLS_WISDOM, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_OWLS_WISDOM, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 3rd Level spells
        if (nLevel > 4)
        {
        if (GetHasSpell (SPELL_KEEN_EDGE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_KEEN_EDGE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_ANIMATE_DEAD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_ANIMATE_DEAD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_INVISIBILITY_PURGE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_INVISIBILITY_PURGE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (952/*SPELL_SPIDER_SKIN*/, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (952/*SPELL_SPIDER_SKIN*/, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_DARKFIRE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_DARKFIRE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_NEGATIVE_ENERGY_PROTECTION, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_NEGATIVE_ENERGY_PROTECTION, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_MAGIC_CIRCLE_AGAINST_GOOD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_MAGIC_CIRCLE_AGAINST_GOOD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 1 Min/Lvl spell that is too low of level so it must be cast at 5th lvl or greater.
        if (GetHasSpell (SPELL_FLAME_WEAPON, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_FLAME_WEAPON, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_BLESS, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_BLESS, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_BLUR, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_BLUR, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_AID, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_AID, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_DEATH_WARD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_DEATH_WARD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_ENLARGE_PERSON, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_ENLARGE_PERSON, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 4th Level spells
        if (nLevel > 6)
        {
        if (GetHasSpell (SPELL_FREEDOM_OF_MOVEMENT, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_FREEDOM_OF_MOVEMENT, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_NEUTRALIZE_POISON, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_NEUTRALIZE_POISON, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 5th Level spells
        if (nLevel > 8)
        {
        if (GetHasSpell (SPELL_MIND_BLANK, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_MIND_BLANK, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (SPELL_LESSER_MIND_BLANK, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_LESSER_MIND_BLANK, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_SPELL_RESISTANCE, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SPELL_RESISTANCE, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_PROTECTION_FROM_GOOD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_PROTECTION_FROM_GOOD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 6th Level spells
        if (nLevel > 10)
        {
        if (GetHasSpell (SPELL_CREATE_UNDEAD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_CREATE_UNDEAD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_PLANAR_ALLY, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_PLANAR_ALLY, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_LESSER_PLANAR_BINDING, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_LESSER_PLANAR_BINDING, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_ETHEREALNESS, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_ETHEREALNESS, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (947/*SPELL_GREATER_FANTASTIC_MACHINE*/, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (947/*SPELL_GREATER_FANTASTIC_MACHINE*/, oCaster, 0, FALSE, 0, 0, TRUE)); }
        else if (GetHasSpell (946/*SPELL_FANTASTIC_MACHINE*/, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (946/*SPELL_FANTASTIC_MACHINE*/, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 7th Level spells
        if (nLevel > 12)
        {
        if (GetHasSpell (SPELL_PROTECTION_FROM_SPELLS, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_PROTECTION_FROM_SPELLS, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_SHADOW_SHIELD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_SHADOW_SHIELD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 8th Level spells
        if (nLevel > 14)
        {
        if (GetHasSpell (SPELL_CREATE_GREATER_UNDEAD, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_CREATE_GREATER_UNDEAD, oCaster, 0, FALSE, 0, 0, TRUE)); }
        if (GetHasSpell (SPELL_GREATER_PLANAR_BINDING, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (SPELL_GREATER_PLANAR_BINDING, oCaster, 0, FALSE, 0, 0, TRUE)); }
        // 9th Level spells
        if (nLevel > 16)
        {
        if (GetHasSpell (961/*SPELL_PRISMATIC_SPHERE*/, oCaster))
        { AssignCommand (oCaster, ActionCastSpellAtObject (961/*SPELL_PRISMATIC_SPHERE*/, oCaster, 0, FALSE, 0, 0, TRUE)); }
        }}}}}}}}
    }
}

void CheckCreatureSpecialAbilities (object oCreature = OBJECT_SELF)
{
    int nMaxSpecialAbilities = NWNX_Creature_GetSpecialAbilityCount (oCreature);
    if (nMaxSpecialAbilities)
    {
        int nIndex, bCanCast;
        // Struct is id, ready, level.
        struct NWNX_Creature_SpecialAbility stSA;
        while (nIndex < nMaxSpecialAbilities)
        {
            stSA = NWNX_Creature_GetSpecialAbility (oCreature, nIndex);
            if (stSA.ready)
            {
                bCanCast = FALSE;
                if (stSA.level > 4)
                {
                    // 1 Min/Lvl spell that is too low of level so it must be cast at 5th lvl or greater.
                    if (stSA.id == SPELL_FLAME_WEAPON) bCanCast = TRUE;
                    else if (stSA.id == SPELL_BLESS) bCanCast = TRUE;
                    else if (stSA.id == SPELL_BLUR) bCanCast = TRUE;
                    else if (stSA.id == SPELL_AID) bCanCast = TRUE;
                    else if (stSA.id == SPELL_DEATH_WARD) bCanCast = TRUE;
                    else if (stSA.id == SPELL_ENLARGE_PERSON) bCanCast = TRUE;
                }
                if (stSA.id == SPELL_ENERGY_BUFFER) bCanCast = TRUE;
                else if (stSA.id == SPELL_PROTECTION_FROM_ELEMENTS) bCanCast = TRUE;
                else if (stSA.id == SPELL_RESIST_ELEMENTS) bCanCast = TRUE;
                else if (stSA.id == SPELL_ENDURE_ELEMENTS) bCanCast = TRUE;
                else if (stSA.id == 962/*SPELL_GREATER_MAGE_ARMOR*/ ) bCanCast = TRUE;
                else if (stSA.id == SPELL_MAGE_ARMOR) bCanCast = TRUE;
                else if (stSA.id == SPELL_MAGIC_VESTMENT) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_MAGIC_WEAPON) bCanCast = TRUE;
                else if (stSA.id == SPELL_MAGIC_WEAPON) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_IX) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_VIII) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_VII) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_VI) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_V) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_IV) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_III) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_II) bCanCast = TRUE;
                else if (stSA.id == SPELL_SUMMON_CREATURE_I) bCanCast = TRUE;
                else if (stSA.id == SPELL_BARKSKIN) bCanCast = TRUE;
                else if (stSA.id == SPELL_SHIELD) bCanCast = TRUE;
                else if (stSA.id == SPELL_ENTROPIC_SHIELD) bCanCast = TRUE;
                else if (stSA.id == SPELL_SHIELD_OF_FAITH) bCanCast = TRUE;
                else if (stSA.id == SPELL_REMOVE_FEAR) bCanCast = TRUE;
                else if (stSA.id == SPELL_IRONGUTS) bCanCast = TRUE;
                else if (stSA.id == SPELL_PREMONITION) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_STONESKIN) bCanCast = TRUE;
                else if (stSA.id == SPELL_GHOSTLY_VISAGE) bCanCast = TRUE;
                else if (stSA.id == SPELL_IMPROVED_INVISIBILITY) bCanCast = TRUE;
                else if (stSA.id == SPELL_INVISIBILITY_SPHERE) bCanCast = TRUE;
                else if (stSA.id == SPELL_INVISIBILITY) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_BULLS_STRENGTH) bCanCast = TRUE;
                else if (stSA.id == SPELL_BULLS_STRENGTH) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_CATS_GRACE) bCanCast = TRUE;
                else if (stSA.id == SPELL_CATS_GRACE) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_EAGLE_SPLENDOR) bCanCast = TRUE;
                else if (stSA.id == SPELL_EAGLE_SPLEDOR) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_ENDURANCE) bCanCast = TRUE;
                else if (stSA.id == SPELL_ENDURANCE) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_FOXS_CUNNING) bCanCast = TRUE;
                else if (stSA.id == SPELL_FOXS_CUNNING) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_OWLS_WISDOM) bCanCast = TRUE;
                else if (stSA.id == SPELL_OWLS_WISDOM) bCanCast = TRUE;
                else if (stSA.id == SPELL_KEEN_EDGE) bCanCast = TRUE;
                else if (stSA.id == SPELL_ANIMATE_DEAD) bCanCast = TRUE;
                else if (stSA.id == SPELL_INVISIBILITY_PURGE) bCanCast = TRUE;
                else if (stSA.id == 952/*SPELL_SPIDER_SKIN*/) bCanCast = TRUE;
                else if (stSA.id == SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE) bCanCast = TRUE;
                else if (stSA.id == SPELL_DARKFIRE) bCanCast = TRUE;
                else if (stSA.id == SPELL_NEGATIVE_ENERGY_PROTECTION) bCanCast = TRUE;
                else if (stSA.id == SPELL_MAGIC_CIRCLE_AGAINST_GOOD) bCanCast = TRUE;
                else if (stSA.id == SPELL_FREEDOM_OF_MOVEMENT) bCanCast = TRUE;
                else if (stSA.id == SPELL_NEUTRALIZE_POISON) bCanCast = TRUE;
                else if (stSA.id == SPELL_MIND_BLANK) bCanCast = TRUE;
                else if (stSA.id == SPELL_LESSER_MIND_BLANK) bCanCast = TRUE;
                else if (stSA.id == SPELL_SPELL_RESISTANCE) bCanCast = TRUE;
                else if (stSA.id == SPELL_PROTECTION_FROM_GOOD) bCanCast = TRUE;
                else if (stSA.id == SPELL_CREATE_UNDEAD) bCanCast = TRUE;
                else if (stSA.id == SPELL_PLANAR_ALLY) bCanCast = TRUE;
                else if (stSA.id == SPELL_LESSER_PLANAR_BINDING) bCanCast = TRUE;
                else if (stSA.id == SPELL_ETHEREALNESS) bCanCast = TRUE;
                else if (stSA.id == 947/*SPELL_GREATER_FANTASTIC_MACHINE*/) bCanCast = TRUE;
                else if (stSA.id == 946/*SPELL_FANTASTIC_MACHINE*/) bCanCast = TRUE;
                else if (stSA.id == SPELL_PROTECTION_FROM_SPELLS) bCanCast = TRUE;
                else if (stSA.id == SPELL_SHADOW_SHIELD) bCanCast = TRUE;
                else if (stSA.id == SPELL_CREATE_GREATER_UNDEAD) bCanCast = TRUE;
                else if (stSA.id == SPELL_GREATER_PLANAR_BINDING) bCanCast = TRUE;
                else if (stSA.id == 961/*SPELL_PRISMATIC_SPHERE*/) bCanCast = TRUE;
                if (bCanCast) ActionCastSpellAtObject (stSA.id, oCreature, 255, 0, 0, 0, TRUE);
            }
            nIndex++;
        }
    }
}
int GetHasAura(object oCreature, string sTag)
{
    object oAura;
    int nCount = 0;
    oAura = GetObjectByTag(sTag, nCount);
    while(GetIsObjectValid(oAura))
    {
        if(GetAreaOfEffectCreator(oAura) == oCreature) return TRUE;
        oAura = GetObjectByTag(sTag, ++nCount);
    }
    return FALSE;
}
void SetCreatureAuras (object oCreature)
{
    // Check for aura of fear on dragon bloodline III.
    if(GetHasFeat (1332 /* Draconic bloodline III */, oCreature))
    {
        if(!GetHasAura(oCreature, "VFX_SORCERER_FEAR_AURA"))
        {
            ExecuteScript ("0s_fear_aura_ap", oCreature);
        }
    }
    // Check for aura of defense.
    if(GetHasFeat (1493 /* Aura of Defense */, oCreature))
    {
        if(!GetHasAura(oCreature, "VFX_AURA_OF_DEFENSE"))
        {
            ExecuteScript ("0s_auraofdefense", oCreature);
        }
    }
    // Check for aura of despair.
    if(GetHasFeat (1566 /* Aura of Despair */, oCreature))
    {
        if(!GetHasAura(oCreature, "VFX_AURA_OF_DESPAIR"))
        {
            ExecuteScript ("0s_auraofdespair", oCreature);
        }
    }
}
void CheckForClaws (object oCreature, int nCharacterLevel)
{
    // Has feat Draconic Bloodline II (gives d6x2 slashing damage for claws).
    if (GetHasFeat (1331, oCreature) && !GetIsObjectValid (GetItemInSlot (INVENTORY_SLOT_CWEAPON_L, oCreature)))
    {
        // Set the characters appearance for claws.
        // Kobolds cannot have claws so skip this race.
        if (GetRacialType (oCreature) != 57)
        {
            SetCreatureBodyPart (CREATURE_PART_LEFT_HAND, 203, oCreature);
            SetCreatureBodyPart (CREATURE_PART_RIGHT_HAND, 203, oCreature);
            // Get the appearance array.
            string sAppearanceArray = GetObjectDatabaseString (oCreature, CHARACTER_TABLE, "appearance");
            // Set the appearance value.
            sAppearanceArray = SetStringArray (sAppearanceArray, 2, "1");
            // Save the changes.
            SetObjectDatabaseString (oCreature, CHARACTER_TABLE, "appearance", sAppearanceArray);
        }
        // Need to create claws and equip!
        NWNX_Creature_AddFeatByLevel (oCreature, FEAT_WEAPON_PROFICIENCY_CREATURE, nCharacterLevel);
        NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_RECEIVED, TRUE, oCreature);
        object oClawLeft = CreateItemOnObject ("0_dragon_b_claw", oCreature);
        object oClawRight = CreateItemOnObject ("0_dragon_b_claw", oCreature);
        NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_RECEIVED, FALSE, oCreature);
        DelayCommand (0.2f, AssignCommand(oCreature, ActionEquipItem(oClawLeft, INVENTORY_SLOT_CWEAPON_L)));
        DelayCommand (0.2f, AssignCommand(oCreature, ActionEquipItem(oClawRight, INVENTORY_SLOT_CWEAPON_R)));
    }
}

void CheckForWings(object oCreature)
{
    if(!GetCreatureWingType(oCreature))
    {
        // Sorcerer: Abyssal Bloodline II.
        if(GetHasFeat (1316/*FEAT_ABYSSAL_BLOODLINE*/, oCreature)) SetCreatureWingType(203, oCreature);
        // Sorcerer: Celestial Bloodline II.
        else if(GetHasFeat(1326/*FEAT_CELESTIAL_BLOODLINE*/, oCreature)) SetCreatureWingType(217, oCreature);
        // Sorcerer: Infernal Bloodline II.
        else if(GetHasFeat(1346/*FEAT_INFERNAL_BLOODLINE*/, oCreature)) SetCreatureWingType(205, oCreature);
        // Check Dragon Disciple: FEAT_DRAGON_WINGS.
        else if(GetHasFeat(1367, oCreature))
        {
            if(GetHasFeat(FEAT_BLACK_DRAGON_BLOOD, oCreature)) SetCreatureWingType(65, oCreature);
            else if(GetHasFeat(FEAT_BLUE_DRAGON_BLOOD, oCreature)) SetCreatureWingType(67, oCreature);
            else if(GetHasFeat(FEAT_BRASS_DRAGON_BLOOD, oCreature)) SetCreatureWingType(59, oCreature);
            else if(GetHasFeat(FEAT_BRONZE_DRAGON_BLOOD, oCreature)) SetCreatureWingType(60, oCreature);
            else if(GetHasFeat(FEAT_COPPER_DRAGON_BLOOD, oCreature)) SetCreatureWingType(61, oCreature);
            else if(GetHasFeat(FEAT_GOLD_DRAGON_BLOOD, oCreature)) SetCreatureWingType(63, oCreature);
            else if(GetHasFeat(FEAT_GREEN_DRAGON_BLOOD, oCreature)) SetCreatureWingType(66, oCreature);
            else if(GetHasFeat(FEAT_RED_DRAGON_BLOOD, oCreature)) SetCreatureWingType(68, oCreature);
            else if(GetHasFeat(FEAT_SILVER_DRAGON_BLOOD, oCreature)) SetCreatureWingType(62, oCreature);
            else if(GetHasFeat(FEAT_WHITE_DRAGON_BLOOD, oCreature)) SetCreatureWingType(64, oCreature);
        }
        // Check for any racial wings.
        else if(GetHasFeat(1369/*FEAT_FLIGHT*/, oCreature))
        { 
            int nRaceType = GetRaceType(oCreature);
            if(nRaceType == 66) SetCreatureWingType(230, oCreature); // Butterfly Black.
            else if(nRaceType == 69) 
            {
                int nWingType;
                switch (d10())
                { // Avariel usually have white wings, but can have gray, brown, or black.
                    case 1: case 2: case 3: case 4: case 5: case 6: case 7: nWingType = 2; break; // White
                    case 8: nWingType = 6; break; // Brown
                    case 9: nWingType = 198; break; // Brown
                    case 10: nWingType = 199; break; // Black
                }
                SetCreatureWingType(nWingType, oCreature); // Random feather.
            }
        }
        // Check for the Wing feat.
        else if(GetHasFeat(1368/*FEAT_WINGS*/, oCreature))
        {
            // Check Favored Souls.
            if(GetLevelByClass(CLASS_TYPE_FAVORED_SOUL, oCreature) > 0)
            {
                int nAlignment = GetAlignmentGoodEvil(oCreature);
                if(nAlignment == ALIGNMENT_EVIL) SetCreatureWingType(201, oCreature); // Black wings.
                else if(nAlignment == ALIGNMENT_EVIL) SetCreatureWingType(198, oCreature); // Brown feathered wings.
                else SetCreatureWingType(217, oCreature); // White feathered wings.
            }
        }
        // Remove any wings since they don't have them now, mostly for level down.
        else SetCreatureWingType(0, oCreature);
    }
}
object SetCreatureSkin(object oCreature, int bMonster)
{
    object oNewSkin;
    object oOldSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCreature);
    if(oOldSkin == OBJECT_INVALID)
    {
        if(GetIsPC(oCreature))
        {
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, TRUE, oCreature);
            oNewSkin = CreateItemOnObject("0_skin_natural", oCreature);
            NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_RECEIVED, FALSE, oCreature);
        }
        else
        {
            oNewSkin = CreateItemOnObject("0_skin_natural", oCreature);
            SetName(oNewSkin, "New Skin");
        }
        ClearAllActions(FALSE, oCreature);
        AssignCommand(oCreature, ActionEquipItem(oNewSkin, INVENTORY_SLOT_CARMOUR));
    }
    else if(!bMonster)
    {
        RemoveAllItemProperties(oOldSkin, DURATION_TYPE_PERMANENT);
        oNewSkin = oOldSkin;
    }
    else oNewSkin = oOldSkin;
    return oNewSkin;
}
void SetCharacterEffectsToSkin(object oCreature, int bMonster = FALSE)
{
    int nCharacterLevel = GetCharacterLevels(oCreature);
    int nClassLevel, nStr, nDex, nCon, nInt, nWis, nCha, nFort, nWill, nRefl, nAll;
    int nElectricity, nAcid, nFire, nCold, nArmor;
    int nAppraise, nCraft, nMoveSilent, nHide, nAthletics, nPersuade, nUMD;
    int nDecipher, nKnowledge, nSearch, nSpellcraft, nTaunt, nDisableDevice;
    int nOpenLocks, nHeal, nSurvival, nAcrobatics, nListen, nSpot;
    itemproperty ipProperty;
    object oSkin = SetCreatureSkin(oCreature, bMonster);
    // Generate properties for the skin based on Feats, Race, and Class.
    // We will add up all Abilities, Skills, saves and put them on at the end.
    // Add FEAT properties.
    // *********************************
    // **** Add Other bonus feats ******
    // *********************************
    // Fix for darkvision, may test without it later to see if feats work correctly.
    //if(GetHasFeat(FEAT_DARKVISION, oCreature) || GetHasFeat(1330/*FEAT_DRACONIC_BLOODLINE_I*/, oCreature))
    if(GetHasFeat(1330/*FEAT_DRACONIC_BLOODLINE_I*/, oCreature))
    {
        ipProperty = ItemPropertyDarkvision();
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    // *****************************
    // **** Add Immunity feats *****
    // *****************************
    int bDmgAcid, bDmgElectrical, bDmgFire, bDmgCold, bParalysis, bPoison, bFear;
    int bDeath, bSneakAttacks, bCrits, bMind;
    if(GetHasFeat(FEAT_DRAGON_IMMUNE_ELEMENT, oCreature))
    {
        if(GetHasFeat(FEAT_BLACK_DRAGON_BLOOD, oCreature)) bDmgAcid = TRUE;
        else if(GetHasFeat(FEAT_BLUE_DRAGON_BLOOD, oCreature)) bDmgElectrical = TRUE;
        else if(GetHasFeat(FEAT_BRASS_DRAGON_BLOOD, oCreature)) bDmgFire = TRUE;
        else if(GetHasFeat(FEAT_BRONZE_DRAGON_BLOOD, oCreature)) bDmgElectrical = TRUE;
        else if(GetHasFeat(FEAT_COPPER_DRAGON_BLOOD, oCreature)) bDmgAcid = TRUE;
        else if(GetHasFeat(FEAT_GOLD_DRAGON_BLOOD, oCreature)) bDmgFire = TRUE;
        else if(GetHasFeat(FEAT_GREEN_DRAGON_BLOOD, oCreature)) bDmgAcid = TRUE;
        else if(GetHasFeat(FEAT_RED_DRAGON_BLOOD, oCreature)) bDmgFire = TRUE;
        else if(GetHasFeat(FEAT_SILVER_DRAGON_BLOOD, oCreature)) bDmgCold = TRUE;
        else if(GetHasFeat(FEAT_WHITE_DRAGON_BLOOD, oCreature)) bDmgCold = TRUE;
    }
    if(GetHasFeat(FEAT_COLD_IMMUNITY)) bDmgCold = TRUE;
    // Sorcerer: Abyssal blood line V, Infernal blood line V: Poison Immunity.
    if(GetHasFeat(1319, oCreature) || GetHasFeat (1349, oCreature)) bPoison = TRUE;
    // Sorcerer: Draconic blood line V: Immunity Sleep and Paralysis.
    if(GetHasFeat(1334, oCreature)) bParalysis = TRUE;
    // Sorcerer: Abberant blood line III: Immunity to Fear.
    if(GetHasFeat(1312, oCreature)) bFear = TRUE;
    // Sorcerer: Undeath blood line V: Immunity to Death effects.
    if(GetHasFeat(1354, oCreature)) bDeath = TRUE;
    // Sorcerer: Abberant blood line V, Elemental blood line V.
    // Immunity to Sneak Attacks and Crits.
    if(GetHasFeat(1314, oCreature) || GetHasFeat(1339, oCreature) || GetHasFeat(1393, oCreature) ||
       GetHasFeat(1398, oCreature) || GetHasFeat(1403, oCreature))
    {
        bSneakAttacks = TRUE;
        bCrits = TRUE;
    }
    // Sorcerer: Fey blood line V: Immunity to Enchantments and Charms.
    if(GetHasFeat(1344, oCreature)) bMind = TRUE;
    // Apply immunities.
    if(bSneakAttacks)
    {
        ipProperty = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_BACKSTAB);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bCrits)
    {
        ipProperty = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_CRITICAL_HITS);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bFear)
    {
        ipProperty = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_FEAR);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bParalysis)
    {
        ipProperty = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_PARALYSIS);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bMind)
    {
        ipProperty = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_MINDSPELLS);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bDeath)
    {
        ipProperty = ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_DEATH_MAGIC);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bPoison)
    {
        ipProperty = ItemPropertyImmunityMisc (IP_CONST_IMMUNITYMISC_POISON);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bDmgAcid)
    {
        ipProperty = ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_ACID, IP_CONST_DAMAGEIMMUNITY_100_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bDmgElectrical)
    {
        ipProperty = ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_ELECTRICAL, IP_CONST_DAMAGEIMMUNITY_100_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bDmgFire)
    {
        ipProperty = ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_FIRE, IP_CONST_DAMAGEIMMUNITY_100_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    if(bDmgCold)
    {
        ipProperty = ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_COLD, IP_CONST_DAMAGEIMMUNITY_100_PERCENT);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oSkin);
    }
    // **************************************
    // **** Add Damage Resistance feats *****
    // **************************************
    int nResistAcid, nResistCold, nResistElectrical, nResistFire, nResistSonic;
    int nResistBludgeoning, nResistPiercing, nResistSlashing, nResistPhysical;
    int nResistDivine, nResistMagical, nResistNegative, nResistPositive;
    int nResistValue;
    // Sorcerer: Abyssal blood line V, Air Elemental blood line V: Electrical Resistance 20.
    if(GetHasFeat(1319, oCreature) || GetHasFeat(1339, oCreature))
    {
        if(nResistElectrical < IP_CONST_DAMAGERESIST_20) nResistElectrical = IP_CONST_DAMAGERESIST_20;
    }
    // Sorcerer: Abyssal blood line III: Electrical Resistance 10.
    else if(GetHasFeat(1317, oCreature))
    {
        if(nResistElectrical < IP_CONST_DAMAGERESIST_10) nResistElectrical = IP_CONST_DAMAGERESIST_10;
    }
    // Sorcerer: Celestial blood line V, Earth Elemental blood line V: Acid Resistance 20.
    if(GetHasFeat(1329, oCreature) || GetHasFeat(1403, oCreature))
    {
        if(nResistAcid < IP_CONST_DAMAGERESIST_20) nResistAcid = IP_CONST_DAMAGERESIST_20;
    }
    // Sorcerer: Celestial blood line III: Acid Resistance 10.
    else if(GetHasFeat (1327, oCreature))
    {
        if(nResistAcid < IP_CONST_DAMAGERESIST_10) nResistAcid = IP_CONST_DAMAGERESIST_10;
    }
    // Sorcerer: Fire Elemental blood line V, Infernal blood line V: Fire Resistance 20.
    if(GetHasFeat(1393, oCreature) || GetHasFeat(1349, oCreature))
    {
        if(nResistFire < IP_CONST_DAMAGERESIST_20) nResistFire = IP_CONST_DAMAGERESIST_20;
    }
    // Sorcerer: Infernal blood line III: Fire Resistance 10.
    if(GetHasFeat(1347, oCreature))
    {
        if(nResistFire < IP_CONST_DAMAGERESIST_10) nResistFire = IP_CONST_DAMAGERESIST_10;
    }
    // Sorcerer: Water Elemental blood line V, Undeath blood line V: Cold Resistance 20.
    if(GetHasFeat(1398, oCreature) || GetHasFeat(1354, oCreature))
    {
        if(nResistCold < IP_CONST_DAMAGERESIST_20) nResistCold = IP_CONST_DAMAGERESIST_20;
    }
    // Sorcerer: Undeath blood line III: Cold Resistance 10.
    if(GetHasFeat(1352, oCreature))
    {
        if(nResistCold < IP_CONST_DAMAGERESIST_10) nResistCold = IP_CONST_DAMAGERESIST_10;
    }
    // All resistance feats.
    if(GetHasFeat(FEAT_LIGHTNING_RESISTANCE_10, oCreature) && nResistElectrical < IP_CONST_DAMAGERESIST_10) nResistElectrical = IP_CONST_DAMAGERESIST_10;
    if(GetHasFeat(FEAT_ACID_RESISTANCE_10, oCreature) && nResistAcid < IP_CONST_DAMAGERESIST_10) nResistAcid = IP_CONST_DAMAGERESIST_10;
    if(GetHasFeat(FEAT_FIRE_RESISTANCE_10, oCreature) && nResistFire < IP_CONST_DAMAGERESIST_10) nResistFire = IP_CONST_DAMAGERESIST_10;
    if(GetHasFeat(FEAT_COLD_RESISTANCE_10, oCreature) && nResistCold < IP_CONST_DAMAGERESIST_10) nResistCold = IP_CONST_DAMAGERESIST_10;
    // Set damage resistance property
    if(nResistAcid > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_ACID, nResistAcid);
    if(nResistCold > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_COLD, nResistCold);
    if(nResistElectrical > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_ELECTRICAL, nResistElectrical);
    if(nResistFire > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_FIRE, nResistFire);
    if(nResistSonic > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_SONIC, nResistSonic);
    if(nResistBludgeoning > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_BLUDGEONING, nResistBludgeoning);
    if(nResistPiercing > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_PIERCING, nResistPiercing);
    if(nResistSlashing > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_SLASHING, nResistSlashing);
    if(nResistPhysical > 0)
    {
        IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_BLUDGEONING, nResistPhysical);
        IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_PIERCING, nResistPhysical);
        IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_SLASHING, nResistPhysical);
    }
    if(nResistDivine > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_DIVINE, nResistDivine);
    if(nResistMagical > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_MAGICAL, nResistMagical);
    if(nResistNegative > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_NEGATIVE, nResistNegative);
    if(nResistPositive > 0) IP_DamageResistance(oSkin, IP_CONST_DAMAGETYPE_POSITIVE, nResistPositive);
    // ********************************
    // **** Add damage reduction ******
    // ********************************
    itemproperty ipDmgRed;
    // Sorcerer: Abberation blood line V: Physical Resistance 5.
    if(GetHasFeat(1314, oCreature))
    {
        ipDmgRed = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_20, IP_CONST_DAMAGESOAK_5_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDmgRed, oSkin);
    }
    // Sorcerer: Fey Blood line V - Damage Reduction 10/Magic
    if (GetHasFeat(1344, oCreature))
    {
        ipDmgRed = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_1, IP_CONST_DAMAGESOAK_10_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDmgRed, oSkin);
    }
    // Favored Soul: Damage Reduction 10/Magic
    if(GetHasFeat(1304, oCreature))
    {
        ipDmgRed = ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_1, IP_CONST_DAMAGESOAK_10_HP);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipDmgRed, oSkin);
    }
    // ********************************
    // **** Add Armor bonus feats *****
    // ********************************
    // Orog race gets +2 Natural armor.
    if(GetRaceType(oCreature) == 70) nArmor = 2;
    // Set Armor properties
    if(nArmor > 0) IP_ACBonus(oSkin, nArmor);
    // *********************************
    // **** Add Skill bonus feats *****
    // *********************************
    if(GetHasFeat(FEAT_TRACKLESS_STEP, oCreature) && GetHasFeat(FEAT_RACIAL_GNOME_FOREST, oCreature)) nHide = nHide + 4;
    if(GetHasFeat(FEAT_MASTER_CRAFTSMAN, oCreature))
    {
        // Get the Artificers level
        nClassLevel = GetLevelByClass (CLASS_TYPE_ARTIFICER, oCreature);
        if(nClassLevel < 5) nCraft = nCraft + 3;
        else if(nClassLevel < 9) nCraft = nCraft + 6;
        else nCraft = nCraft + 9;
    }
    if(GetHasFeat(FEAT_TUNE_DEVICES, oCreature))
    {
        // Get the Artificers level
        nClassLevel = GetLevelByClass(CLASS_TYPE_ARTIFICER, oCreature);
        if(nClassLevel < 8) nUMD = nUMD + 5;
        else nUMD = nUMD + 10;
    }
    // Sorcerer: Draconic blood line I: Gain Alertness.
    if(GetHasFeat(1330, oCreature))
    {
        nListen = nListen + 2;
        nSpot = nSpot + 2;
    }
    // Set up skill properties on the skin.
    if(nAcrobatics > 0) IP_SkillBonus(oSkin, SKILL_ACROBATICS, nAcrobatics);
    if(nAppraise > 0) IP_SkillBonus(oSkin, SKILL_APPRAISE, nAppraise);
    if(nAthletics > 0) IP_SkillBonus(oSkin, SKILL_ATHLETICS, nAthletics);
    if(nCraft > 0) IP_SkillBonus(oSkin, SKILL_CRAFTING, nCraft);
    if(nDecipher > 0) IP_SkillBonus(oSkin, SKILL_DECIPHER_SCRIPT, nDecipher);
    if(nDisableDevice > 0) IP_SkillBonus(oSkin, SKILL_DISABLE_TRAP, nDisableDevice);
    if(nHeal > 0) IP_SkillBonus(oSkin, SKILL_HEAL, nHeal);
    if(nHide > 0) IP_SkillBonus(oSkin, SKILL_HIDE, nHide);
    if(nKnowledge > 0) IP_SkillBonus(oSkin, SKILL_KNOWLEDGE, nKnowledge);
    if(nListen > 0) IP_SkillBonus(oSkin, SKILL_LISTEN, nListen);
    if(nPersuade > 0) IP_SkillBonus(oSkin, SKILL_PERSUADE, nPersuade);
    if(nMoveSilent > 0) IP_SkillBonus(oSkin, SKILL_MOVE_SILENTLY, nMoveSilent);
    if(nOpenLocks > 0) IP_SkillBonus(oSkin, SKILL_OPEN_LOCK, nOpenLocks);
    if(nSearch > 0) IP_SkillBonus(oSkin, SKILL_SEARCH, nSearch);
    if(nSpellcraft > 0) IP_SkillBonus(oSkin, SKILL_SPELLCRAFT, nSpellcraft);
    if(nSpot > 0) IP_SkillBonus(oSkin, SKILL_SPOT, nSpot);
    if(nSurvival > 0) IP_SkillBonus(oSkin, SKILL_SURVIVAL, nSurvival);
    if(nTaunt > 0) IP_SkillBonus(oSkin, SKILL_TAUNT, nTaunt);
    if(nUMD > 0) IP_SkillBonus(oSkin, SKILL_USE_MAGIC_DEVICE, nUMD);
    // *******************************
    // **** Add Save bonus feats *****
    // *******************************
    if(GetHasFeat(FEAT_DEFENSIVE_MASTERY, oCreature)) nAll = nAll + 2;
    if(GetHasFeat(FEAT_AIR_AFFINITY, oCreature)) nElectricity = nElectricity + (nCharacterLevel / 5) + 1;
    if(GetHasFeat(FEAT_EARTH_AFFINITY, oCreature)) nAcid = nAcid + (nCharacterLevel / 5) + 1;
    if(GetHasFeat(FEAT_FIRE_AFFINITY, oCreature)) nFire = nFire + (nCharacterLevel / 5) + 1;
    if(GetHasFeat(FEAT_WATER_AFFINITY, oCreature)) nCold = nCold + (nCharacterLevel / 5) + 1;
    // Set Save properties.
    if(nFort > 0) IP_BonusSavingThrow(oSkin, IP_CONST_SAVEBASETYPE_FORTITUDE, nFort);
    if(nRefl > 0) IP_BonusSavingThrow(oSkin, IP_CONST_SAVEBASETYPE_REFLEX, nRefl);
    if(nWill > 0) IP_BonusSavingThrow(oSkin, IP_CONST_SAVEBASETYPE_WILL, nWill);
    if(nAll > 0) IP_BonusSavingThrowVsX(oSkin, IP_CONST_SAVEVS_UNIVERSAL, nAll);
    if(nAcid > 0) IP_BonusSavingThrowVsX(oSkin, IP_CONST_SAVEVS_ACID, nAcid);
    if(nCold > 0) IP_BonusSavingThrowVsX(oSkin, IP_CONST_SAVEVS_COLD, nCold);
    if(nElectricity > 0) IP_BonusSavingThrowVsX(oSkin, IP_CONST_SAVEVS_ELECTRICAL, nElectricity);
    if(nFire > 0) IP_BonusSavingThrowVsX(oSkin, IP_CONST_SAVEVS_FIRE, nFire);
}

void SetCharacterEffects (object oCreature)
{
    int nCharacterLevel = GetCharacterLevels (oCreature);
    int nAttack, nMagic_Damage;
    effect eEffect;
    RemoveTagedEffects (oCreature, "Feat");
    // *********************************
    // **** Add Attack bonus feats *****
    // *********************************
    if (GetHasFeat (1556/*FEAT_LUCK_DOMAIN*/, oCreature)) nAttack = nAttack + 1;
    if (nAttack > 0)
    {
        CreateFeatEffect(oCreature, EffectAttackIncrease(nAttack), "ATTACK_BONUS_FEAT");
    }
    // *********************************
    // **** Add damage bonus feats *****
    // *********************************
    if (GetHasFeat (1556/*FEAT_LUCK_DOMAIN*/, oCreature)) nMagic_Damage = nMagic_Damage + 1;
    if (nMagic_Damage > 0)
    {
        CreateFeatEffect(oCreature, EffectDamageIncrease (nMagic_Damage, DAMAGE_TYPE_MAGICAL), "DAMAGE_BONUS_FEAT");
    }
}
void SelectDeityForFavoredSoul(object oCreature)
{
    int nDeity;
    // Lets randomize the Diety this favored soul is from.
    if(GetRacialType(oCreature) == 42) //RACIAL_TYPE_DROW
    {
        nDeity = Random(6) + 68;
    }
    else
    {
        int nRace = GetRaceType(oCreature, TRUE);
        if(nRace == RACIAL_TYPE_DWARF) nDeity = Random(14) + 74;
        else if(nRace == RACIAL_TYPE_ELF) nDeity = Random(12) + 88;
        else if(nRace == RACIAL_TYPE_GNOME) nDeity = Random(8) + 100;
        else if(nRace == RACIAL_TYPE_HALFLING) nDeity = Random(6) + 108;
        else if(nRace == RACIAL_TYPE_HALFORC) nDeity = Random(6) + 114;
        else if(nRace == RACIAL_TYPE_HUMAN) nDeity = Random(67) + 1;
    }
    SetLocalInt(oCreature, "0_Deity", nDeity);
    SetDeity(oCreature, Get2DAString("deities", "Deity", nDeity));
}
void CheckForFavoredSoulFeats (object oCreature)
{
    int nLevel = GetLevelByClass(47/*Favored Soul*/, oCreature);
    if(!nLevel) return;
    // Check to see if they have a set deity in the database.
    int nDeity;
    if(GetIsCharacter(oCreature)) nDeity = GetObjectDatabaseInt (oCreature, CHARACTER_TABLE, "deity");
    else
    {
        nDeity = GetLocalInt(oCreature, "0_Deity");
        if(nDeity == 0) SelectDeityForFavoredSoul(oCreature);
    }
    if(nDeity > 0)
    {
        int nWeaponProf, nWeaponFocus, nWeaponSpec;
        int nNonECLLevels = GetCharacterLevels(oCreature, FALSE);
        // Check for Weapon proficiency at level 1.
        if(nLevel >= 1)
        {
            nWeaponProf = StringToInt(Get2DAString("deities", "Weapon_Prof", nDeity));
            if(nWeaponProf > 0)
            {
                if(!GetHasFeat(nWeaponProf, oCreature)) NWNX_Creature_AddFeatByLevel(oCreature, nWeaponProf, nNonECLLevels);
            }
        }
        // Check for Weapon focus at level 3.
        if(nLevel >= 3)
        {
            nWeaponFocus = StringToInt(Get2DAString("deities", "Weapon_Focus", nDeity));
            if(nWeaponFocus > 0)
            {
                if(!GetHasFeat(nWeaponFocus, oCreature)) NWNX_Creature_AddFeatByLevel(oCreature, nWeaponFocus, nNonECLLevels);
            }
        }
        // Check for Weapon focus at level 12.
        else if(nLevel >= 12)
        {
            nWeaponSpec = StringToInt(Get2DAString("deities", "Weapon_Spec", nDeity));
            if(nWeaponSpec > 0)
            {
                if(!GetHasFeat(nWeaponSpec, oCreature)) NWNX_Creature_AddFeatByLevel(oCreature, nWeaponSpec, nNonECLLevels);
            }
        }
    }
}

void CheckForFamiliarFeats (object oCreature)
{
    int iFirstLevel;
    // Do they have the familiar feat?
    if (GetHasFeat (FEAT_SUMMON_FAMILIAR, oCreature))
    {
        // Is the character first level in sorcerer.
        if (GetLevelByClass (CLASS_TYPE_SORCERER, oCreature) == 1) iFirstLevel = TRUE;
        else iFirstLevel = FALSE;
        // Is the character first level in wizard and was not already a sorcerer.
        if (GetLevelByClass (CLASS_TYPE_WIZARD, oCreature) == 1 && iFirstLevel == FALSE) iFirstLevel = TRUE;
        else iFirstLevel = FALSE;
        // Check each familiar and give appropriate feet.
        if (GetFamiliarCreatureType (oCreature) != FAMILIAR_CREATURE_TYPE_NONE && iFirstLevel)
        {
            if (GetFamiliarCreatureType (oCreature) == 0/*Bat*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_SKILL_FOCUS_LISTEN, 1);
            else if (GetFamiliarCreatureType (oCreature) == 1/*Cat*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_SKILL_FOCUS_MOVE_SILENTLY, 1);
            else if (GetFamiliarCreatureType (oCreature) == 2/*Eagle*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_SKILL_FOCUS_SPOT, 1);
            else if (GetFamiliarCreatureType (oCreature) == 3/*Lizard*/) NWNX_Creature_AddFeatByLevel (oCreature, 175/*FEAT_SKILL_FOCUS_ATHLETICS*/, 1);
            else if (GetFamiliarCreatureType (oCreature) == 4/*Owl*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_SKILL_FOCUS_HIDE, 1);
            else if (GetFamiliarCreatureType (oCreature) == 5/*Rat*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_GREAT_FORTITUDE, 1);
            else if (GetFamiliarCreatureType (oCreature) == 6/*Raven*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_SKILLFOCUS_APPRAISE, 1);
            else if (GetFamiliarCreatureType (oCreature) == 7/*Viper*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_SKILL_FOCUS_PERSUADE, 1);
            else if (GetFamiliarCreatureType (oCreature) == 8/*Toad*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_IRON_WILL, 1);
            else if (GetFamiliarCreatureType (oCreature) == 9/*Weasel*/) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_LIGHTNING_REFLEXES, 1);
        }
    }
}

void CheckForDomainFeats (object oCreature)
{
    int nDomain1 = GetDomain (oCreature, 1);
    // If there is no domain then exit.
    if (nDomain1 == -1) return;
    int nDomain2 = GetDomain (oCreature, 2);
    int nClassLevel = GetLevelByClass (CLASS_TYPE_CLERIC, oCreature);
    int nDeity, bHasDomain;
    // Total level is required to add feat at the correct level.
    int nLevel = GetCharacterLevels (oCreature, FALSE);
    // Check to see if they have a set deity in the database.
    // We assume NPC's always have the correct Deity so set it to -1.
    if (GetIsCharacter (oCreature)) nDeity = GetObjectDatabaseInt (oCreature, CHARACTER_TABLE, "deity");
    else { nDeity = -1; bHasDomain = TRUE; }
    // *********************************
    // ******* Check luck bonus ********
    // *********************************
    // Check to make sure they have the correct god to Cast this spell.
    if (nDeity != -1) bHasDomain = StringToInt (Get2DAString ("deities", "Luck_Domain", nDeity));
    if (bHasDomain && GetHasFeat (1556/*FEAT_LUCK_DOMAIN*/, oCreature))
    {
        int nLuck = nClassLevel / 2;
        SetLocalInt (oCreature, "0_Luck", nLuck);
    }
    // ********** ANIMAL DOMAIN **********
    if ((nDomain1 == DOMAIN_ANIMAL || nDomain2 == DOMAIN_ANIMAL))
    {
        // Base ability: Skill focus Animal empathy.
        if (!GetHasFeat (FEAT_SKILL_FOCUS_ANIMAL_EMPATHY, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_SKILL_FOCUS_ANIMAL_EMPATHY, nLevel);
    }
    // ********** CAVERN DOMAIN **********
    if ((nDomain1 == 22/*CAVERN_DOMAIN*/ || nDomain2 == 22/*CAVERN_DOMAIN*/))
    {
        // Base ability: Gain stone cunning or Skill affinity Search.
        if (!GetHasFeat (FEAT_STONECUNNING, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_STONECUNNING, nLevel);
        else if (nClassLevel == 1 &&
                 !GetHasFeat (FEAT_SKILL_AFFINITY_SEARCH, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_SKILL_AFFINITY_SEARCH, nLevel);
        // Deity ability: Darkvision.
        if (nDeity != -1) bHasDomain = StringToInt (Get2DAString ("deities", "Cavern_Domain", nDeity));
        if (bHasDomain)
        {
            if (!GetHasFeat (FEAT_DARKVISION, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_DARKVISION, nLevel);
        }
    }
    // ********** CRAFT DOMAIN **********
    if ((nDomain1 == 24/*CRAFT_DOMAIN*/ || nDomain2 == 24/*CRAFT_DOMAIN*/))
    {
        // Base ability: Gain Skill focus (Craft).
        if (!GetHasFeat (915/*FEAT_SKILL_FOCUS_CRAFT*/, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, 915/*FEAT_SKILL_FOCUS_CRAFT*/, nLevel);
    }
    // ********** DARKNESS DOMAIN **********
    if ((nDomain1 == 25/*DARKNESS_DOMAIN*/ || nDomain2 == 25/*DARKNESS_DOMAIN*/))
    {
        // Base ability: Gain Blind-Fight feat.
        if (!GetHasFeat (FEAT_BLIND_FIGHT, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_BLIND_FIGHT, nLevel);
    }
    // ********** DROW DOMAIN **********
    if ((nDomain1 == 26/*DROW_DOMAIN*/ || nDomain2 == 26/*DROW_DOMAIN*/))
    {
        // Base ability: Gain Lightning reflexes feat.
        if (!GetHasFeat (FEAT_LIGHTNING_REFLEXES, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_LIGHTNING_REFLEXES, nLevel);
    }
    // ********** DWARF DOMAIN **********
    if ((nDomain1 == 27/*DWARF_DOMAIN*/ || nDomain2 == 27/*DWARF_DOMAIN*/))
    {
        // Base ability: Gain Great Fortitude feat.
        if (!GetHasFeat (FEAT_GREAT_FORTITUDE, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_GREAT_FORTITUDE, nLevel);
        // Deity ability: Weapon proficiency Martial at level 1 and Weapon focus at level 2.
        if (nDeity != -1) bHasDomain = StringToInt (Get2DAString ("deities", "War_Domain", nDeity));
        if (bHasDomain)
        {
            if (!GetHasFeat (FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_WEAPON_PROFICIENCY_MARTIAL, nLevel);
        }
    }
    // ********** ELF DOMAIN **********
    if ((nDomain1 == 28/*ELF_DOMAIN*/ || nDomain2 == 28/*ELF_DOMAIN*/))
    {
        // Base ability: Gain point blank shot feat.
        if (!GetHasFeat (FEAT_POINT_BLANK_SHOT, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_POINT_BLANK_SHOT, nLevel);
    }
    // ********** WAR DOMAIN **********
    if ((nDomain1 == DOMAIN_WAR || nDomain2 == DOMAIN_WAR) && nDeity > 0)
    {
        // Deity ability: Weapon proficiency Martial at level 1 and Weapon focus at level 2.
        if (nDeity != -1) bHasDomain = StringToInt (Get2DAString ("deities", "War_Domain", nDeity));
        if (bHasDomain)
        {
            if (nClassLevel > 2)
            {
                int nWeaponFocus = StringToInt (Get2DAString ("deities", "Weapon_Focus", nDeity));
                if (!GetHasFeat (nWeaponFocus, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, nWeaponFocus, nLevel);
            }
            if (!GetHasFeat (FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_WEAPON_PROFICIENCY_EXOTIC, nLevel);
        }
    }
}

void CheckForFeatsToAdd (object oCreature)
{
    // Get the characters level so we can set the feats to that level.
    // Use GetCharacterLevel(oCreature, FALSE) so we only get the class levels and none of the Racial levels.
    int iLevel = GetCharacterLevels (oCreature, FALSE);
    // *********************
    // **** Add feats  *****
    // *********************
    // Give the fly feat if they have Abyssal bloodline II or Celestial bloodline II, Infernal bloodline or Dragon Wings.
    if (GetHasFeat (1316/*Abyssal bloodline*/, oCreature) || GetHasFeat (1326/*Celestial bloodline*/, oCreature)
     || GetHasFeat (1346/*Infernal bloodline*/ , oCreature) || GetHasFeat (1367/*Dragon wings*/, oCreature))
     {
        if(!GetHasFeat(FEAT_FLY)) NWNX_Creature_AddFeatByLevel(oCreature, FEAT_FLY, iLevel);
     }
    else if(GetHasFeat(FEAT_FLY, oCreature)) NWNX_Creature_RemoveFeat(oCreature, FEAT_FLY);
    // Check for Dragon Disciple breath weapons.
    if (GetHasFeat (FEAT_DRAGON_DIS_BREATH, oCreature))
    {
        int iDragonBlood = 0;
        // Now check which type of dragon disciple they are.
        // Give the new breath weapon feat Line of Acid.
        if (GetHasFeat (FEAT_BLACK_DRAGON_BLOOD, oCreature) || GetHasFeat (FEAT_COPPER_DRAGON_BLOOD, oCreature)) iDragonBlood = 1383;
        // Give the new breath weapon feat Line of Lightning.
        else if (GetHasFeat (FEAT_BLUE_DRAGON_BLOOD, oCreature) || GetHasFeat (FEAT_BRONZE_DRAGON_BLOOD, oCreature)) iDragonBlood = 1384;
        // Give the new breath weapon feat Cone of Acid.
        else if (GetHasFeat (FEAT_GREEN_DRAGON_BLOOD, oCreature)) iDragonBlood = 1385;
        // Give the new breath weapon feat Cone of fire.
        else if (GetHasFeat (FEAT_GOLD_DRAGON_BLOOD, oCreature) || GetHasFeat (FEAT_RED_DRAGON_BLOOD, oCreature)) iDragonBlood = 1386;
        // Give the new breath weapon feat Cone of Cold.
        else if (GetHasFeat (FEAT_SILVER_DRAGON_BLOOD, oCreature) || GetHasFeat (FEAT_WHITE_DRAGON_BLOOD, oCreature)) iDragonBlood = 1387;
        // Give the new breath weapon feat Line of Fire.
        else if (GetHasFeat (FEAT_BRASS_DRAGON_BLOOD, oCreature)) iDragonBlood = 1388;
        if (iDragonBlood > 0)
        {
            // Give the new breath weapon feat.
            NWNX_Creature_AddFeatByLevel (oCreature, iDragonBlood, iLevel);
            // Remove the old breath weapon feat.
            NWNX_Creature_RemoveFeat (oCreature, FEAT_DRAGON_DIS_BREATH);
        }
        else
        {
            if (GetHasFeat (1383, oCreature)) NWNX_Creature_RemoveFeat (oCreature, 1383);
            if (GetHasFeat (1384, oCreature)) NWNX_Creature_RemoveFeat (oCreature, 1384);
            if (GetHasFeat (1385, oCreature)) NWNX_Creature_RemoveFeat (oCreature, 1385);
            if (GetHasFeat (1386, oCreature)) NWNX_Creature_RemoveFeat (oCreature, 1386);
            if (GetHasFeat (1387, oCreature)) NWNX_Creature_RemoveFeat (oCreature, 1387);
            if (GetHasFeat (1388, oCreature)) NWNX_Creature_RemoveFeat (oCreature, 1388);
        }
    }
    // Check for Fey blood line feats.
    // Fey Bloodline I gives Woodland stride feat.
    if (GetHasFeat (1340/*Fey Bloodline I*/, oCreature)) NWNX_Creature_AddFeatByLevel (oCreature, FEAT_WOODLAND_STRIDE, iLevel);
    // Fey Bloodline II gives +2 Charisma
    if (GetHasFeat (1341/*Fey Bloodline II*/, oCreature) && iLevel == 5)
    {
        int iCha = GetAbilityScore (oCreature, ABILITY_CHARISMA, TRUE) + 2;
        NWNX_Creature_SetRawAbilityScore (oCreature, ABILITY_CHARISMA, iCha);
    }
    CheckForFavoredSoulFeats (oCreature);
    CheckForDomainFeats (oCreature);
    CheckForFamiliarFeats (oCreature);
}

// Adjust feat uses.
void AdjustFeatUses(object oCreature)
{
    int nLevel, nUses;
    if(GetHasFeat(FEAT_EXTRA_SMITING, oCreature, TRUE)) nUses = 2;
    if(GetHasFeat(FEAT_SMITE_EVIL, oCreature, TRUE))
    {
        nLevel = GetLevelByClass(CLASS_TYPE_PALADIN2, oCreature);
        if(nLevel > 14) nUses += 3;
        else if(nLevel > 8) nUses += 2;
        else nUses += 1;
        NWNX_Creature_SetFeatRemainingUses(oCreature, FEAT_SMITE_EVIL, nUses);
    }
    if(GetHasFeat(FEAT_SMITE_GOOD, oCreature, TRUE))
    {
        nLevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD, oCreature);
        if(nLevel > 7) nUses += 3;
        else if(nLevel > 4) nUses += 2;
        else nUses += 1;
        NWNX_Creature_SetFeatRemainingUses(oCreature, FEAT_SMITE_GOOD, nUses);
    }
    if(GetHasFeat(1526/*FEAT_SUDDEN_EMPOWER*/, oCreature, TRUE))
    {
        nLevel = GetLevelByClass(CLASS_TYPE_WARMAGE, oCreature);

        if(nLevel > 18) nUses = 8;
        else if(nLevel > 16) nUses = 7;
        else if(nLevel > 14) nUses = 6;
        else if(nLevel > 12) nUses = 5;
        else if(nLevel > 10) nUses = 4;
        else if(nLevel > 8) nUses = 3;
        else if(nLevel > 6) nUses = 2;
        else nUses = 1;
        NWNX_Creature_SetFeatRemainingUses(oCreature, 1526/*FEAT_SUDDEN_EMPOWER*/, nUses);
    }
    if(GetHasFeat(1561/*FEAT_SUDDEN_EXTENDED*/, oCreature, TRUE))
    {
        nLevel = GetLevelByClass(CLASS_TYPE_WARMAGE, oCreature);

        if(nLevel > 18) nUses = 7;
        else if(nLevel > 16) nUses = 6;
        else if(nLevel > 14) nUses = 5;
        else if(nLevel > 12) nUses = 4;
        else if(nLevel > 10) nUses = 3;
        else if(nLevel > 8) nUses = 2;
        else nUses = 1;
        NWNX_Creature_SetFeatRemainingUses(oCreature, 1561/*FEAT_SUDDEN_EXTENDED*/, nUses);
    }
    if(GetHasFeat(1527/*FEAT_SUDDEN_WIDEN*/, oCreature, TRUE))
    {
        nLevel = GetLevelByClass(CLASS_TYPE_WARMAGE, oCreature);

        if(nLevel > 18) nUses = 6;
        else if(nLevel > 16) nUses = 5;
        else if(nLevel > 14) nUses = 4;
        else if(nLevel > 12) nUses = 3;
        else if(nLevel > 10) nUses = 2;
        else nUses = 1;
        NWNX_Creature_SetFeatRemainingUses(oCreature, 1527/*FEAT_SUDDEN_WIDEN*/, nUses);
    }
    if(GetHasFeat(1528/*FEAT_SUDDEN_MAXIMIZE*/, oCreature, TRUE))
    {
        nLevel = GetLevelByClass(CLASS_TYPE_WARMAGE, oCreature);

        if(nLevel > 18) nUses = 5;
        else if(nLevel > 16) nUses = 4;
        else if(nLevel > 14) nUses = 3;
        else if(nLevel > 12) nUses = 2;
        else nUses = 1;
        NWNX_Creature_SetFeatRemainingUses(oCreature, 1528/*FEAT_SUDDEN_MAXIMIZE*/, nUses);
    }
}

// Adjust all summons after resting/logging in.
// Remove use if resting (nState 1) and have the summons out.
// Add the use if they are logging in (nState 2).
void AdjustSummonUses (object oCreature, int nState)
{
    // Companions
    if (NWNX_Creature_GetFeatGrantLevel (oCreature, FEAT_ANIMAL_COMPANION) > 0)
    {
        if (nState == 1)
        {
            object oAssociate = GetAssociate (ASSOCIATE_TYPE_ANIMALCOMPANION, oCreature);
            if (oAssociate != OBJECT_INVALID) NWNX_Creature_SetFeatRemainingUses (oCreature, FEAT_ANIMAL_COMPANION, 0);
        }
        else if (nState == 2)
        {
            NWNX_Creature_SetFeatRemainingUses (oCreature, FEAT_ANIMAL_COMPANION, 1);
        }
    }
    // Familiars
    if (NWNX_Creature_GetFeatGrantLevel (oCreature, FEAT_SUMMON_FAMILIAR) > 0)
    {
        if (nState == 1)
        {
            object oAssociate = GetAssociate (ASSOCIATE_TYPE_ANIMALCOMPANION, oCreature);
            if (oAssociate != OBJECT_INVALID) NWNX_Creature_SetFeatRemainingUses (oCreature, FEAT_SUMMON_FAMILIAR, 0);
        }
        else if (nState == 2)
        {
            NWNX_Creature_SetFeatRemainingUses (oCreature, FEAT_SUMMON_FAMILIAR, 1);
        }
    }
}

// Gives a villians special powers based on level.
// 3st - 4th 1 power,  5th - 9th 2 powers, 10th - 14th 3 powers.
// 15th to 19th 4 powers, 20th 5 powers.
void GiveVillianSpecialPower(object oCreature, int nLevel = 0)
{
    // Villians of Level 1 or 2 don't get special powers.
    if(nLevel == 0) nLevel = FloatToInt(GetChallengeRating (oCreature));
    if (nLevel < 3) return;
    effect eEffect, eVisual, eHaste, eParalysis, eEntangle, eSlow, eMove, eHp;
    int nNumOfPowers, nAC = 2;
    int nToHit = 2;
    int nHp = 2;
    int nRoll, bHaste = FALSE, nConceal = 0, nRegen = 0, nSpellResist = 0;
    if (nLevel < 6) nNumOfPowers = 1;
    else if (nLevel < 12) nNumOfPowers = 2;
    else if (nLevel < 18) nNumOfPowers = 3;
    else if (nLevel < 22) nNumOfPowers = 4;
    else if (nLevel < 25) nNumOfPowers = 5;
    else if (nLevel < 28) nNumOfPowers = 6;
    else if (nLevel < 31) nNumOfPowers = 7;
    else if (nLevel < 34) nNumOfPowers = 8;
    else if (nLevel < 37) nNumOfPowers = 9;
    else nNumOfPowers = 10;
    SetLocalInt(oCreature, "0_NUM_OF_POWERS", nNumOfPowers);
    while(nNumOfPowers > 0)
    {
        nRoll = d100();
        // Haste
        if (nRoll < 6 && !bHaste)
        {
            eEffect = EffectVisualEffect (VFX_DUR_FREEDOM_OF_MOVEMENT);
            eHaste = EffectHaste ();
            eParalysis = EffectImmunity (IMMUNITY_TYPE_PARALYSIS);
            eEntangle = EffectImmunity (IMMUNITY_TYPE_ENTANGLE);
            eSlow = EffectImmunity (IMMUNITY_TYPE_SLOW);
            eMove = EffectImmunity (IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE);
            //Link effects
            eEffect = EffectLinkEffects(eEffect, eParalysis);
            eEffect = EffectLinkEffects(eEffect, eEntangle);
            eEffect = EffectLinkEffects(eEffect, eSlow);
            eEffect = EffectLinkEffects(eEffect, eMove);
            eEffect = EffectLinkEffects (eEffect, eHaste);
            ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
            bHaste = TRUE;
        }
        // Regeneratoin +1 per hit upto 5.
        else if (nRoll < 11 && nRegen < 5) nRegen ++;
        // Spell Resistance  10 + 2 per hit up to 20.
        else if (nRoll < 16 && nSpellResist < 20) nSpellResist = nSpellResist + 2;
        // Conceal 20% if hit twice then 50%
        else if (nRoll < 21 && nConceal < 49)
        {
            if (nConceal == 0) nConceal = 20;
            else nConceal = 50;
        }
        // x4 Hitpoints.
        else if (nRoll < 51 && nHp < 3) nHp = nHp + 2;
        // AC increase +1 per 2 levels.
        else if (nRoll < 61 && nAC < 3) nAC = nAC + (nLevel / 2);
        else if (nRoll < 85 && nToHit < 3) nToHit = nToHit + (nLevel / 2);
        // Extra damage
        else if (nRoll < 95)
        {
            int nEffect;
            int nDmgType, nDmgBonus = (nLevel / 4) + 7;
            if (nDmgBonus == 12) nDmgBonus = 13;
            nRoll = d100();
            if (nRoll < 10) { nDmgType = DAMAGE_TYPE_ACID; nEffect = VFX_DUR_AURA_GREEN_LIGHT; }
            else if (nRoll < 30) { nDmgType = DAMAGE_TYPE_COLD; nEffect = VFX_DUR_AURA_BLUE_LIGHT; }
            else if (nRoll < 50) { nDmgType = DAMAGE_TYPE_ELECTRICAL; nEffect = VFX_DUR_AURA_YELLOW_LIGHT; }
            else if (nRoll < 90) { nDmgType = DAMAGE_TYPE_FIRE; nEffect = VFX_DUR_AURA_RED_LIGHT; }
            else if (nRoll < 95) { nDmgType = DAMAGE_TYPE_SONIC; nEffect = VFX_DUR_GLOW_WHITE; }
            else { nDmgType = DAMAGE_TYPE_MAGICAL; nEffect = VFX_DUR_GLOW_PURPLE; }
            eVisual = EffectVisualEffect (nEffect);
            eEffect = EffectDamageIncrease (nDmgBonus, nDmgType);
            eEffect = EffectLinkEffects (eVisual, eEffect);
            ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
        }
        // Elemental shield.
        else
        {
            int nEffect;
            int nDmgType, nDmgBonus = (nLevel / 4) + 1;
            int nRndDamage = DAMAGE_BONUS_1d4;
            if(nDmgBonus < 3) nRndDamage = DAMAGE_BONUS_1d8;
            if(nDmgBonus < 4) nRndDamage = DAMAGE_BONUS_2d4;
            if(nDmgBonus < 5) nRndDamage = DAMAGE_BONUS_2d8;
            else nRndDamage = DAMAGE_BONUS_2d12;
            nRoll = d100();
            if (nRoll < 20) { nDmgType = DAMAGE_TYPE_ACID; nEffect = VFX_DUR_IOUNSTONE_GREEN; }
            else if (nRoll < 40) { nDmgType = DAMAGE_TYPE_COLD; nEffect = VFX_DUR_IOUNSTONE_BLUE; }
            else if (nRoll < 70) { nDmgType = DAMAGE_TYPE_ELECTRICAL; nEffect = VFX_DUR_IOUNSTONE_YELLOW; }
            else { nDmgType = DAMAGE_TYPE_FIRE; nEffect = VFX_DUR_IOUNSTONE_RED; }
            eEffect = EffectDamageShield (nDmgBonus, nRndDamage, nDmgType);
            eVisual = EffectVisualEffect (nEffect);
            eEffect = EffectLinkEffects (eVisual, eEffect);
            ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
        }
        nNumOfPowers --;
    }
    // Give bonus hitpoints.
    int nHitpoints = GetMaxHitPoints (oCreature) * nHp;
    NWNX_Object_SetMaxHitPoints (oCreature, nHitpoints);
    eEffect = EffectHeal(nHitpoints);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oCreature);
    //DelayCommand (0.1f, SetCurrentHitPoints (oCreature, nHitpoints));
    // Give bonus AC.
    eEffect = EffectACIncrease (nAC);
    if (nHp > 2)
    {
        eHp = EffectVisualEffect (VFX_DUR_GLOBE_MINOR);
        eEffect = EffectLinkEffects (eHp, eEffect);
    }
    if (nHp > 2)
    {
        eHp = EffectVisualEffect (VFX_DUR_GLOBE_MINOR);
        eEffect = EffectLinkEffects (eHp, eEffect);
    }
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    // Give To hit bonus.
    eEffect = EffectAttackIncrease (nToHit);
    if (nToHit > 2)
    {
        eVisual = EffectVisualEffect (VFX_DUR_PROT_PREMONITION);
        eEffect = EffectLinkEffects (eVisual, eEffect);
    }
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    // Give concealment.
    if (nConceal > 0)
    {
        eVisual = EffectVisualEffect (VFX_DUR_BLUR);
        eEffect = EffectConcealment (nConceal, MISS_CHANCE_TYPE_NORMAL);
        eEffect = EffectLinkEffects (eVisual, eEffect);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    }
    // Give regeneration.
    if (nRegen > 0)
    {
        eVisual = EffectVisualEffect (VFX_DUR_PROTECTION_EVIL_MAJOR);
        eEffect = EffectRegenerate (nRegen, 6.0f);
        eEffect = EffectLinkEffects (eVisual, eEffect);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    }
    // Give spell resistance.
    if (nSpellResist > 0)
    {
        eVisual = EffectVisualEffect (VFX_DUR_MAGIC_RESISTANCE);
        int nCurrentSpellResist = GetSpellResistance (oCreature);
        if (nCurrentSpellResist == 0) nSpellResist = nSpellResist + 10;
        eEffect = EffectSpellResistanceIncrease (nSpellResist);
        eEffect = EffectLinkEffects (eVisual, eEffect);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    }
}

// Will randomize a portrait for the creature if they are set with "0_Random_Portrait" var.
void SetPortrait (object oCreature)
{
    // Do we need to change the portrait?
    if (GetLocalInt (oCreature, "0_Random_Portrait"))
    {
        int nMaxMalePortrait, nMaxFemalePortrait;
        int nGender = GetGender (oCreature);
        int nRace = GetRaceType(oCreature, TRUE);
        string sRoll, sPortrait;
        if (nRace == 0)
        {
            sPortrait = "po_dw_";
            nMaxMalePortrait = 27;
            nMaxFemalePortrait = 26;
        }
        else if (nRace == 1)
        {
            if (GetRacialType (oCreature) == 42)
            {
                sPortrait = "po_dr_";
                nMaxMalePortrait = 2;
                nMaxFemalePortrait = 8;
            }
            else
            {
                sPortrait = "po_el_";
                nMaxMalePortrait = 29;
                nMaxFemalePortrait = 34;
            }
        }
        else if (nRace == 2)
        {
            sPortrait = "po_gn_";
            nMaxMalePortrait = 18;
            nMaxFemalePortrait = 13;
        }
        else if (nRace == 3)
        {
            sPortrait = "po_ha_";
            nMaxMalePortrait = 25;
            nMaxFemalePortrait = 23;
        }
        else if (nRace == 4)
        {
            if (d10() < 5)
            {
                sPortrait = "po_el_";
                nMaxMalePortrait = 29;
                nMaxFemalePortrait = 34;
            }
            else
            {
                sPortrait = "po_hu_";
                nMaxMalePortrait = 92;
                nMaxFemalePortrait = 71;
            }
        }
        else if (nRace == 5)
        {
            sPortrait = "po_or_";
            nMaxMalePortrait = 21;
            nMaxFemalePortrait = 17;
        }
        else if (nRace == 6)
        {
            sPortrait = "po_hu_";
            nMaxMalePortrait = 92;
            nMaxFemalePortrait = 71;
        }
        if (nGender)
        {
            sRoll = IntToString (Random (nMaxFemalePortrait) + 1);
            if (GetStringLength (sRoll) == 1) sRoll = "0" + sRoll + "_";
            sPortrait = sPortrait + "f_" + sRoll + "_";
        }
        else
        {
            sRoll = IntToString (Random (nMaxMalePortrait) + 1);
            if (GetStringLength (sRoll) == 1) sRoll = "0" + sRoll + "_";
            sPortrait = sPortrait + "m_" + sRoll + "_";
        }
        SetPortraitResRef (oCreature, sPortrait);
    }
}

// Setup animations for a just spawned creature.
void CheckAnimations (object oCreature)
{
    int nAnimation = GetLocalInt (oCreature, "0_Animation");
    // Default - 0_Animation = 0 This gives them mobile animations.
    if(nAnimation == 1) SetAICondition (AI_IS_MOBILE_CLOSE_RANGE, TRUE, oCreature);
    else if (nAnimation == 2) SetAICondition (AI_IS_IMMOBILE, TRUE, oCreature);
}

// Pass waypoint variables to the object.
// Checks to see if the object has the variable and if so will not transfer
// the variable data from the waypoint.
void PassVariables (object oWaypoint, object oObject, int bVillain = FALSE)
{
    // Check to see if we need to change the creatures name.
    string sName = GetLocalString (oWaypoint, "0_Name");
    if (sName != "") SetName (oObject, sName);
    // Transfer 0_LockChance variable.
    int iVar = GetLocalInt (oWaypoint, "0_LockChance");
    if (iVar != 0 && GetLocalInt (oObject, "0_LockChance") == 0) SetLocalInt (oObject, "0_LockChance", iVar);
    // Transfer 0_TrapChance variable.
    iVar = GetLocalInt (oWaypoint, "0_TrapChance");
    if (iVar != 0 && GetLocalInt (oObject, "0_TrapChance") == 0) SetLocalInt (oObject, "0_TrapChance", iVar);
    // Transfer 0_TreasureLevel variable: Sets the level of the chest.
    iVar = GetLocalInt (oWaypoint, "0_TreasureLevel");
    if (iVar != 0 && GetLocalInt (oObject, "0_TreasureLevel") == 0) SetLocalInt (oObject, "0_TreasureLevel", iVar);
    // Transfer 0_TreasureBonus variable.
    iVar = GetLocalInt (oWaypoint, "0_TreasureBonus");
    if (iVar != 0 && GetLocalInt (oObject, "0_TreasureBonus") == 0) SetLocalInt (oObject, "0_TreasureBonus", iVar);
    // Transfer 0_Multiplier variable.
    iVar = GetLocalInt (oWaypoint, "0_Multiplier");
    if (iVar != 0 && GetLocalInt (oObject, "0_Multiplier") == 0) SetLocalInt (oObject, "0_Multiplier", iVar);
    // Transfer 0_BonusGold variable.
    iVar = GetLocalInt (oWaypoint, "0_BonusGold");
    if (iVar != 0 && GetLocalInt (oObject, "0_BonusGold") == 0) SetLocalInt (oObject, "0_BonusGold", iVar);
    // Transfer 0_BonusMagicItems variable.
    iVar = GetLocalInt (oWaypoint, "0_BonusMagicItems");
    if (iVar != 0 && GetLocalInt (oObject, "0_BonusMagicItems") == 0) SetLocalInt (oObject, "0_BonusMagicItems", iVar);
    // Transfer 0_BaseItemType variable.
    iVar = GetLocalInt (oWaypoint, "0_BaseItemType");
    if (iVar != 0 && GetLocalInt (oObject, "0_BaseItemType") == 0) SetLocalInt (oObject, "0_BaseItemType", iVar);
    iVar = GetLocalInt (oWaypoint, "0_Animation");
    if (iVar != 0 && GetLocalInt (oObject, "0_Animation") == 0) SetLocalInt (oObject, "0_Animation", iVar);
    iVar = GetLocalInt (oWaypoint, "0_Journal");
    if (iVar != 0 && GetLocalInt (oObject, "0_Journal") == 0) SetLocalInt (oObject, "0_Journal", iVar);
    // Check to see if we need to add Villain magic bonus.
    if (bVillain)
    {
        // Make sure the villian drops at least one magic item.
        int iBonusMagicItems = GetLocalInt (oObject, "0_BonusMagicItems");
        if (iBonusMagicItems == 0) SetLocalInt (oObject, "0_BonusMagicItems", 1);
        // If they don't have a BaseItemType then make sure they roll a permanent item.
        int iBaseItemType = GetLocalInt (oObject, "0_BaseItemType");
        if (iBaseItemType == 0) SetLocalInt (oObject, "0_BaseItemType", 149);
    }
}

// Does checks for all spawned creatures after the have been spawned.
// This fires after the spawn script, but uses variables from the waypoint that spawns them.
// oCreature - the creature spawned.
// oWaypoint - the waypoint that spawned them.
// oPC - the player that spawned them.
void SetupCreature(object oCreature, object oWaypoint = OBJECT_INVALID, object oPC = OBJECT_INVALID, int bVillain = FALSE)
{
    int nCR = FloatToInt(GetChallengeRating(oCreature));
    if(oWaypoint != OBJECT_INVALID) PassVariables (oWaypoint, oCreature, bVillain);
    SetPortrait(oCreature);
    CheckAnimations(oCreature);
    // Check for Ranged weapons.
    if(GetLocalInt(oWaypoint, "0_Ranged") == 1)
    {
        if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature))
            GiveMartialRangedWeapons (oCreature);
        else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature))
                 GiveSimpleRangedWeapons (oCreature);
    }
    // Do we scale this creature with the area level?
    int nScale = GetLocalInt(oWaypoint, "0_Scale");
    if(nScale)
    {
        int nClass = GetClassByPosition (1, oCreature);
        int nLevel = GetLocalInt(GetArea (oCreature), "0_Area_Level");
        nLevel += GetLocalInt(oWaypoint, "0_CR_Increase");
        if(nScale > nLevel) nLevel = nScale;
        if(nLevel > 20) nLevel = 20;
        //Debug ("0i_spawn", "282", "nCR: " + IntToString (nCR) + " nLevel: " + IntToString (nLevel) +
        //       " nClass: " + IntToString (nClass));
        int nLevelAdjustment = nLevel - nCR;
        while(nCR < nLevel)
        {
            LevelUpHenchman (oCreature, nClass, TRUE);
            nCR++;
        }
        // Adjust hitpoints based on classtype and level.
        if(nLevelAdjustment > 0)
        {
            int nHp = 1;
            if(nLevel > 19) nHp = 5;
            else if(nLevel > 14) nHp = 4;
            else if(nLevel > 9) nHp = 3;
            else if(nLevel > 4) nHp = 2;
            int nHitpoints = GetMaxHitPoints(oCreature) * nHp;
            NWNX_Object_SetMaxHitPoints(oCreature, nHitpoints);
            //DelayCommand(0.1f, SetCurrentHitPoints(oCreature, nHitpoints));
            effect eHeal = EffectHeal(nHitpoints);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHeal, oCreature);
        }
    }
    // Roll treasure.
    // if they are not incorporeal, iMultiplier = -1 (i.e. no treasure)
    // or are a specific type of creature.
    object oArea = GetArea(oCreature);
    int nRacialType = GetRacialType(oCreature);
    int bEquipment = FALSE;
    if(nRacialType != RACIAL_TYPE_ANIMAL &&
        nRacialType != RACIAL_TYPE_VERMIN &&
        nRacialType != RACIAL_TYPE_CONSTRUCT &&
        nRacialType != RACIAL_TYPE_ELEMENTAL &&
        !GetCreatureFlag(oCreature, CREATURE_VAR_IS_INCORPOREAL)) bEquipment = TRUE;
    if((GetTag(oArea) != "cynosure2" &&
        GetLocalInt(oCreature, "0_Multiplier") != -1 && bEquipment) ||
        GetLocalInt(oCreature, "0_BonusMagicItems") > 0)
    {
        RollTreasure(oCreature, oPC);
        // Give base equipment and armor.
        if(bEquipment && nRacialType != RACIAL_TYPE_OOZE &&
            nRacialType != RACIAL_TYPE_MAGICAL_BEAST &&
            nRacialType != RACIAL_TYPE_DRAGON)
            {
                GiveEquipment(oCreature, FALSE);
                DelayCommand(0.5f, EquipItems(oCreature, FALSE));
            }
        if(GetLocalInt(oCreature, "0_No_Ranged")) SetAssociateMode(MODE_STOP_RANGED, TRUE);
    }
}

// Returns if the target is a humanoid (person).
int GetIsHumanoid (object oTarget)
{
    int nRacialType = GetRacialType (oTarget);
    // All player races are humanoid.
    if (StringToInt (Get2DAString ("racialtypes", "PlayerRace", nRacialType))) return TRUE;
    if (nRacialType == RACIAL_TYPE_HUMANOID_GOBLINOID ||
        nRacialType == RACIAL_TYPE_HUMANOID_MONSTROUS ||
        nRacialType == RACIAL_TYPE_HUMANOID_ORC ||
        nRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN) return TRUE;
    return FALSE;
}
void ActionSaveAssociateToDatabase(object oPC, object oAssociate, string sEffect = "")
{
    SaveAssociateToDatabase(oPC, oAssociate, sEffect);
}
string SaveAssociateToDatabase(object oPC, object oAssociate, string sEffect = "")
{
    int nIndex = 0;
    int nAssociateType = GetLocalInt(oAssociate, PC_ASSOCIATE_TYPE);
    string sObjectTag, sDatabaseTag, sEmptyDatabaseTag;
    string sAssociateType, sAssociateTag = GetTag(oAssociate);
    if(nAssociateType == ASSOCIATE_TYPE_NPC) sAssociateType = "npc";
    else if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN) sAssociateType = "henchmen";
    else return "";
    while(nIndex < 11)
    {
        sDatabaseTag = sAssociateType + IntToString(++nIndex);
        sObjectTag = GetServerDatabaseString(oPC, OBJECT_TABLE, "objecttag", sDatabaseTag);
        if(sObjectTag == sAssociateTag)
        {
            //SetServerDatabaseString(oPC, OBJECT_TABLE, "objecttag", GetTag(oAssociate), sDatabaseTag);
            if(sEffect != "") SetServerDatabaseString(oPC, OBJECT_TABLE, "location", sEffect, sDatabaseTag);
            else SetServerDatabaseString(oPC, OBJECT_TABLE, "location", "", sDatabaseTag);
            SetServerDatabaseObject(oPC, OBJECT_TABLE, oAssociate, sDatabaseTag);
            return sDatabaseTag;
        }
        if(sObjectTag == "" && sEmptyDatabaseTag == "") sEmptyDatabaseTag = sDatabaseTag;
    }
    if(sEmptyDatabaseTag != "")
    {
        CheckServerDataAndInitialize(oPC, OBJECT_TABLE, sEmptyDatabaseTag);
        SetServerDatabaseString(oPC, OBJECT_TABLE, "objecttag", GetTag(oAssociate), sEmptyDatabaseTag);
        if(sEffect != "") SetServerDatabaseString(oPC, OBJECT_TABLE, "location", sEffect, sEmptyDatabaseTag);
        SetServerDatabaseObject(oPC, OBJECT_TABLE, oAssociate, sEmptyDatabaseTag);
        return sEmptyDatabaseTag;
    }
    return "";
}
void RemoveHenchmanFromDatabase(object oPC, object oAssociate)
{
    int nIndex = 1;
    int nAssociateType = GetLocalInt(oAssociate, PC_ASSOCIATE_TYPE);
    string sAssociateType, sAssociateTag = GetTag(oAssociate);
    if(nAssociateType == ASSOCIATE_TYPE_NPC) sAssociateType = "npc";
    else if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN) sAssociateType = "henchmen";
    else return;
    string sDatabaseTag = sAssociateType + IntToString(nIndex);
    while(nIndex < 11)
    {
        if(GetServerDatabaseString(oPC, OBJECT_TABLE, "objecttag", sDatabaseTag) == sAssociateTag)
        {
            DeleteServerDatabaseObject(oPC, OBJECT_TABLE, sDatabaseTag);
            return;
        }
        sDatabaseTag = sAssociateType + IntToString(++nIndex);
    }
}
// Create the remains of a creature and puts any treasure on it as well as its corpse.
void CreateRemains(object oCreature)
{
    object oCopy, oCorpse, oRemains = CreateObject(OBJECT_TYPE_PLACEABLE, "0_inv_remains", GetLocation (oCreature));
    string sTag, sName = GetName(oCreature);
    location lDropLocation;
    SetName(oRemains, "Remains of " + sName);
    SetDescription(oRemains, sName + " lies here with all of their worldly possessions.");
    SetLocalObject(oRemains, "0_Remains_of_Creature", oCreature);
    // Move all items to the corpse.
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        if(GetTag(oItem) != "0_skin")
        {
            oCopy = CopyItem (oItem, oRemains, TRUE);
            SetDroppableFlag (oCopy, TRUE);
            DestroyObject (oItem);
        }
        oItem = GetNextItemInInventory (oCreature);
    }
    // Get all of the creatures equiped items as well.
    // Check all of the creatures slots (0 - 13, 14+ is creature items).
    int nSlot = 0;
    while (nSlot < 14)
    {
        // Lets not drop creature items.
        oItem = GetItemInSlot (nSlot, oCreature);
        if (oItem != OBJECT_INVALID)
        {
            if (nSlot == INVENTORY_SLOT_RIGHTHAND)
            {
                lDropLocation = GetStepRightLocation (oCreature, 0.5f);
                CopyObject (oItem, lDropLocation, OBJECT_INVALID, "", TRUE);
            }
            else if (nSlot == INVENTORY_SLOT_LEFTHAND)
            {
                lDropLocation = GetStepLeftLocation (oCreature, 0.5f);
                CopyObject (oItem, lDropLocation, OBJECT_INVALID, "", TRUE);
            }
            else CopyItem (oItem, oRemains, TRUE);
            if (nSlot != 0 && nSlot != 1 && nSlot != 6) DestroyObject (oItem);
        }
        nSlot ++;
    }
    // Add a dead body to be picked up.
    int nGender = GetGender (oCreature);
    if (nGender) oCorpse = CreateItemOnObject ("0_corpse_female", oRemains);
    else oCorpse = CreateItemOnObject ("0_corpse_male", oRemains);
    SetName (oCorpse, sName);
    SetDescription (oCorpse, "This is the body of " + sName);
    float fWeight;
    int nRace = GetRaceType(oCreature, TRUE);
    if (nRace == RACIAL_TYPE_DWARF) fWeight = 1550.0f;
    else if (nRace == RACIAL_TYPE_ELF) fWeight = 1050.0f;
    else if (nRace == RACIAL_TYPE_GNOME) fWeight = 450.0f;
    else if (nRace == RACIAL_TYPE_HALFLING) fWeight = 350.0f;
    else if (nRace == RACIAL_TYPE_HALFELF) fWeight = 1350.0f;
    else if (nRace == RACIAL_TYPE_HALFORC) fWeight = 2250.0f;
    else if (nRace == RACIAL_TYPE_HUMAN) fWeight = 1600.0f;
    if (nGender) fWeight = fWeight * 0.8f;
    if (GetPhenoType (oCreature) == 2) fWeight = fWeight * 1.5f;
    int nWeight = FloatToInt (fWeight);
    NWNX_Item_SetWeight (oCorpse, nWeight);
    SetLocalInt (oCorpse, "0_Weight", nWeight);
    // Define them as freshly dead.
    SetLocalInt (oCorpse, "0_Raise", 1);
    // Pass the associate type to the corpse.
    int nAssociateType = GetLocalInt (oCreature, PC_ASSOCIATE_TYPE);
    SetLocalInt (oCorpse, PC_ASSOCIATE_TYPE, nAssociateType);
    json jCreature = ObjectToJson (oCreature, TRUE);
    jCreature = GffRemoveList (jCreature, "Equip_ItemList");
    jCreature = GffRemoveList (jCreature, "ItemList");
    SetLocalJson (oCorpse, "0_Stats", jCreature);
    AssignCommand (oCreature, SetIsDestroyable (FALSE, FALSE, FALSE));
}
