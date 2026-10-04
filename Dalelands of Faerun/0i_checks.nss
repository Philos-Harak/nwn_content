/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_checks
//////////////////////////////////////////////////////////////////////////////////////////////////////
    Functions to do check on the server.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_s_message"

// Returns a creatures total character level as an int.
// oCreature is the creature to get the level for.
// bAddECL adds the characters effective race levels as well.
int GetCharacterLevels (object oCreature, int bAddECL = TRUE);
// Rolls a skill check for a creature.
// Returns the difference of the result. i.e Check - DC.
// oCreature is the creature that the skill will be rolled from.
// iSkill is the SKILL_* to use.
// iArmorPenalty makes it check for armor penalty.
// iBonus is any bonus the creature gets.
// iDC is the DC of the check.
// iDisplayFeedback sends the message to the player and log.
//    Can be 1 for full display or 2 for just the roll and no DC.
// iTake20 will replace the roll with a 20.
int GetSkillCheck (object oCreature, int iSkill, int iArmorPenalty = FALSE, int iBonus = 0, int iDC = 20, int iDisplayFeedback = 1, int iTake20 = FALSE);
// Rolls an ability check for a creature.
// Returns the difference of the result. i.e Check - DC.
// oCreature is the creature that the ability will be rolled from.
// iAbility is the ABILITY_* to use.
// iBonus is any bonus the creature gets.
// iDC is the DC of the check.
// iDisplayFeedback sends the message to the player and log.
int GetAbilityCheck (object oCreature, int iAbility, int iBonus = 0, int iDC = 20, int iDisplayFeedback = TRUE);
// Returns true or false depending on whether the creature is flying or not.
int IsFlying (object oCreature);
int GetCreatureSizeModifier (object oCreature);
// Returns a creatures total character level as an int.
// oCreature is the creature to get the level for.
// bAddERL adds the characters Effective Race Levels as well.
int GetCharacterLevels (object oCreature, int bAddERL = TRUE)
{
    int nLevel, nCount;
    for (nCount = 1; nCount < 6; nCount++)
    {
         nLevel += GetLevelByPosition(nCount, oCreature);
    }
    if(bAddERL) nLevel += FloatToInt(GetEffectiveCharacterLevel(oCreature));
    return nLevel;
}

// Rolls a skill check for a creature.
// Returns if it was successful or not.
// oCreature is the creature that the skill will be rolled from.
// iSkill is the SKILL_* to use.
// iArmorPenalty makes it check for armor penalty.
// iBonus is any bonus the creature gets.
// iDC is the DC of the check.
// iDisplayFeedback sends the message to the player and log.
//    Can be 1 for full display or 2 for just the roll and no DC.
// iTake20 will replace the roll with a 20.
int GetSkillCheck (object oCreature, int iSkill, int iArmorPenalty = FALSE, int iBonus = 0, int iDC = 20, int iDisplayFeedback = 1, int iTake20 = FALSE)
{
   int iRoll, iRanks, iResult;
   string sSkill, sRankSign, sBonusSign;
   iRanks = GetSkillRank (iSkill, oCreature);
   // If we are taking 20 then set to 20!
   if (iTake20) iRoll = 20;
   // otherwise roll.
   else iRoll = d20 ();
   // Check for armor penalty.
   if (iArmorPenalty)
   {
        // Get armor in armor slot.
        object oItem = GetItemInSlot (INVENTORY_SLOT_CHEST, oCreature);
        int iAC = GetItemACValue (oItem);
        iBonus - StringToInt (Get2DAString ("armor", "ACCHECK", iAC));
        // Get Shield in shield slot.
        oItem = GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oCreature);
        int iBaseItem = GetBaseItemType (oItem);
        iBonus - StringToInt (Get2DAString("baseitems", "ArmorCheckPen", iBaseItem));
   }
   // Get the result.
   iResult = iRoll + iRanks + iBonus;
   // Lets get the skill name.
   switch (iSkill)
   {
      case SKILL_ANIMAL_EMPATHY: sSkill = "Animal Empathy"; break;
      case SKILL_APPRAISE: sSkill = "Appraise"; break;
      case SKILL_BLUFF: sSkill = "Crafting"; break;
      case SKILL_CONCENTRATION: sSkill = "Concenration"; break;
      case SKILL_CRAFT_ARMOR: sSkill = "Survival"; break;
      case SKILL_CRAFT_TRAP: sSkill = "Craft Trap"; break;
      case SKILL_CRAFT_WEAPON: sSkill = "Decipher Script"; break;
      case SKILL_DISABLE_TRAP: sSkill = "Disable Trap"; break;
      case SKILL_DISCIPLINE: sSkill = "Athletics"; break;
      case SKILL_HEAL: sSkill = "Heal"; break;
      case SKILL_HIDE: sSkill = "Hide"; break;
      case SKILL_INTIMIDATE: sSkill = "Intimidate"; break;
      case SKILL_LISTEN: sSkill = "Listen"; break;
      case SKILL_LORE: sSkill = "Knowledge"; break;
      case SKILL_MOVE_SILENTLY: sSkill = "Move Silently"; break;
      case SKILL_OPEN_LOCK: sSkill = "Open Lock"; break;
      case SKILL_PARRY: sSkill = "Parry"; break;
      case SKILL_PERFORM: sSkill = "Perform"; break;
      case SKILL_PERSUADE: sSkill = "Persuade"; break;
      case SKILL_PICK_POCKET: sSkill = "Sleight of Hand"; break;
      case SKILL_RIDE: sSkill = "Speak Languages"; break;
      case SKILL_SEARCH: sSkill = "Search"; break;
      case SKILL_SET_TRAP: sSkill = "Set Trap"; break;
      case SKILL_SPELLCRAFT: sSkill = "Spellcraft"; break;
      case SKILL_SPOT: sSkill = "Spot"; break;
      case SKILL_TAUNT: sSkill = "Taunt"; break;
      case SKILL_TUMBLE: sSkill = "Acrobatics"; break;
      case SKILL_USE_MAGIC_DEVICE: sSkill = "Use Magic Device"; break;
   }
   // Full display.
   if (iRanks < 0)
   {
        iRanks = abs (iRanks);
        sRankSign = " - ";
   }
   else sRankSign = " + ";

   if (iBonus < 0)
   {
        iBonus = abs (iBonus);
        sBonusSign = " - ";
   }
   else sBonusSign = " + ";
   // Check for a master.
   string sAssociateName;
   object oMaster = GetMaster (oCreature);
   if (GetIsObjectValid (oMaster))
   {
        sAssociateName = "[" + GetName (oCreature) + "] ";
        oCreature = oMaster;
   }
   if (iDisplayFeedback == 1)
   {
        SendMessages (sAssociateName + "Roll: " + IntToString (iRoll) + sRankSign + IntToString (iRanks) + sBonusSign
                      + IntToString (iBonus) + " = " + IntToString (iResult) + " DC: "
                      + IntToString (iDC), COLOR_GRAY, oCreature, FALSE, FALSE);
        if (iDC > iResult) SendMessages (sSkill + " check failed!", COLOR_RED, oCreature, FALSE, FALSE);
        else SendMessages (sAssociateName + sSkill + " check Successful!", COLOR_GREEN, oCreature, FALSE, FALSE);
   }
   // Only give the roll.
   else if (iDisplayFeedback == 2)
   {
        SendMessages (sSkill + " skill check: " + IntToString (iRoll) + sRankSign + IntToString (iRanks) + sBonusSign
        + IntToString (iBonus) + " = " + IntToString (iResult), COLOR_GRAY, oCreature, FALSE, FALSE);
   }
   return iResult - iDC;
}

// Rolls an ability check for a creature.
// Returns the difference of the result. i.e Check - DC.
// oCreature is the creature that the ability will be rolled from.
// iAbility is the ABILITY_* to use.
// iBonus is any bonus the creature gets.
// iDC is the DC of the check.
// iDisplayFeedback sends the message to the player.
int GetAbilityCheck (object oCreature, int iAbility, int iBonus = 0, int iDC = 20, int iDisplayFeedback = TRUE)
{
   int iModifier = GetAbilityModifier (iAbility, oCreature);
   int iRoll = d20 ();
   int iResult = iRoll + iModifier + iBonus;
   string sAbility, sSign;
   // Lets get the ability name.
   switch (iAbility)
   {
      case ABILITY_STRENGTH: sAbility = "Strength"; break;
      case ABILITY_DEXTERITY: sAbility = "Dexterity"; break;
      case ABILITY_CONSTITUTION: sAbility = "Constitution"; break;
      case ABILITY_INTELLIGENCE: sAbility = "Intelligence"; break;
      case ABILITY_WISDOM: sAbility = "Wisdom"; break;
      case ABILITY_CHARISMA: sAbility = "Charisma"; break;
   }
   if (iDisplayFeedback)
   {
        if (iModifier > 0) sSign = " + ";
        else sSign = " - ";
        if (iDC > iResult)
        {
            SendMessages (sAbility + " check failed! DC:" + IntToString (iDC) + " Roll:"
            + IntToString (iRoll) + sSign + IntToString (abs (iModifier)) + " + "
            + IntToString (iBonus) + " = " + IntToString (iResult), COLOR_RED, oCreature, FALSE, FALSE);
        }
        else
        {
            SendMessages (sAbility + " check Successful! DC:" + IntToString (iDC) + " Roll:"
            + IntToString (iRoll) + sSign + IntToString (abs (iModifier)) + " + "
            + IntToString (iBonus) + " = " + IntToString (iResult), COLOR_GREEN, oCreature, FALSE, FALSE);
        }
   }
   return iResult - iDC;
}

// Returns true or false depending on whether the creature is flying or not.
int IsFlying (object oCreature)
{
    int nAppearance = GetAppearanceType(oCreature);
    int bFlying = FALSE;
    switch (nAppearance)
    {
        case APPEARANCE_TYPE_ALLIP:
        case APPEARANCE_TYPE_BAT:
        case APPEARANCE_TYPE_BAT_HORROR:
        case APPEARANCE_TYPE_ELEMENTAL_AIR:
        case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
        case APPEARANCE_TYPE_FAERIE_DRAGON:
        case APPEARANCE_TYPE_FALCON:
        case APPEARANCE_TYPE_FAIRY:
        case APPEARANCE_TYPE_HELMED_HORROR:
        case APPEARANCE_TYPE_IMP:
        case APPEARANCE_TYPE_LANTERN_ARCHON:
        case APPEARANCE_TYPE_MEPHIT_AIR:
        case APPEARANCE_TYPE_MEPHIT_DUST:
        case APPEARANCE_TYPE_MEPHIT_EARTH:
        case APPEARANCE_TYPE_MEPHIT_FIRE:
        case APPEARANCE_TYPE_MEPHIT_ICE:
        case APPEARANCE_TYPE_MEPHIT_MAGMA:
        case APPEARANCE_TYPE_MEPHIT_OOZE:
        case APPEARANCE_TYPE_MEPHIT_SALT:
        case APPEARANCE_TYPE_MEPHIT_STEAM:
        case APPEARANCE_TYPE_MEPHIT_WATER:
        case APPEARANCE_TYPE_QUASIT:
        case APPEARANCE_TYPE_RAVEN:
        case APPEARANCE_TYPE_SHADOW:
        case APPEARANCE_TYPE_SHADOW_FIEND:
        case APPEARANCE_TYPE_SPECTRE:
        case APPEARANCE_TYPE_WILL_O_WISP:
        case APPEARANCE_TYPE_WRAITH:
        case APPEARANCE_TYPE_WYRMLING_BLACK:
        case APPEARANCE_TYPE_WYRMLING_BLUE:
        case APPEARANCE_TYPE_WYRMLING_BRASS:
        case APPEARANCE_TYPE_WYRMLING_BRONZE:
        case APPEARANCE_TYPE_WYRMLING_COPPER:
        case APPEARANCE_TYPE_WYRMLING_GOLD:
        case APPEARANCE_TYPE_WYRMLING_GREEN:
        case APPEARANCE_TYPE_WYRMLING_RED:
        case APPEARANCE_TYPE_WYRMLING_SILVER:
        case APPEARANCE_TYPE_WYRMLING_WHITE:
        case APPEARANCE_TYPE_ELEMENTAL_WATER:
        case APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER:
        case 401: //beholder
        case 402: //beholder
        case 403: //beholder
        case 419: // harpy
        case 430: // Demi Lich
        case 472: // Hive mother
        return TRUE;
    }
    if (GetHasFeat (1368/*Wings*/) || GetHasFeat (1369/*Wings*/)) return TRUE;
    return FALSE;
}

// * Returns true if Target is a humanoid.
int IsAHumanoid(object oTarget)
{
   int nRacial = GetRacialType (oTarget);

   if((nRacial >= 30 && nRacial <= 66) ||
      (nRacial == RACIAL_TYPE_HUMAN) ||
      (nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
      (nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
      (nRacial == RACIAL_TYPE_HUMANOID_ORC) ||
      (nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN))
   {
       return TRUE;
   }
   return FALSE;
}

int GetCreatureSizeModifier (object oCreature)
{
    int nSize = GetCreatureSize (oCreature);
    int nModifier = 0;
    switch (nSize)
    {
        case CREATURE_SIZE_TINY: nModifier = -8;  break;
        case CREATURE_SIZE_SMALL: nModifier = -4; break;
        case CREATURE_SIZE_MEDIUM: nModifier = 0; break;
        case CREATURE_SIZE_LARGE: nModifier = 4;  break;
        case CREATURE_SIZE_HUGE: nModifier = 8;   break;
    }
    return nModifier;
}
