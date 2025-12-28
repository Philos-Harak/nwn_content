/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_pcrest
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a character rests.
 * For each player that rests there is a chance for a random encounter.
 * Gain +1 hitpoint per level when resting.
 May also increase hitpoints per level as follows.
 These are gained for using items or making a successful Survival check.
 1 hp the base bonus hitpoints gained per character level when resting.
 (DC: 10) +1 hp (+2/lvl) for using a bed roll
 (DC: 15) +1 hp (+3/lvl) for being near a campfire (Doubles encounter chances).
 (DC: 20) +1 hp (+4/lvl) for having rations and a water skin.
 (DC: Per 5 over 20) +1 hp when using Survival.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "0i_henchmen"
#include "0i_spawn"
#include "nwnx_player"

int GetNearestRestPlaceableValue(object oPC);
int IsThereAnEncounter (object oPC, int nForageBonus);
void SetupRandomEncounter (object oPC);
void SetupResting (object oPC);
void FinalizeResting(object oPC);

void main ()
{
   object oPC = GetLastPCRested();
   switch(GetLastRestEventType())
   {
      case REST_EVENTTYPE_REST_STARTED:
      {
         int nPlaceableRestValue;
         if(GetLocalInt(oPC, USING_PLACEABLE_TO_REST)) nPlaceableRestValue = GetNearestRestPlaceableValue(oPC);
         if(CanPCRest(oPC, nPlaceableRestValue))
         {
            // Has a forage bonus already been made in this area?
            int nForageBonus = GetForageBonus(oPC);
            if(!nPlaceableRestValue && !nForageBonus) nForageBonus = MakePartyForageCheck(oPC);
            if(IsThereAnEncounter(oPC, nForageBonus)) SetupRandomEncounter(oPC);
            else
            {
                if(!nPlaceableRestValue && nForageBonus)
                {
                    SendMessages("Your party has already foraged this area.", COLOR_GREEN, oPC);
                    // Rolled 20+ (Same as Bedroll, Campfire, Food & Rations).
                    if(nForageBonus >= 4) SendMessages("You successfully foraged for food, water and a great place to rest.", COLOR_GREEN, oPC);
                    // Rolled 15 - 19 (Same as Bedroll & Campfire).
                    else if(nForageBonus == 3) SendMessages("You successfully found a good place to rest.", COLOR_GREEN, oPC);
                    // Rolled 10 - 14 (Same as a bedroll).
                    else if(nForageBonus == 2) SendMessages("You successfully found a place to rest.", COLOR_GREEN, oPC);
                    else SendMessages("You failed to find a place to rest.", COLOR_RED, oPC);
                }
                SetupResting(oPC);
            }
         }
         else AssignCommand (oPC, ClearAllActions ());
         break;
      }
      case REST_EVENTTYPE_REST_FINISHED:
      {
          CheckSpellEffectsForRemoval(oPC, TRUE);
          DeleteLocalInt(oPC, USING_PLACEABLE_TO_REST);
          DelayCommand(0.5f, FinalizeResting(oPC));
          break;
      }
      case REST_EVENTTYPE_REST_CANCELLED:
      {
          // Lets save the player regardless of time laps.
          SaveCharacterData (oPC, TRUE);
          SaveAssociatesToDatabase(oPC, FALSE);
          DeleteLocalInt(oPC, USING_PLACEABLE_TO_REST);
          break;
      }
   }
}
int GetNearestRestPlaceableValue(object oPC)
{
    int nPlaceableValue, nIndex = 1;
    object oPlaceable = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nIndex);
    while(oPlaceable != OBJECT_INVALID && GetDistanceBetween(oPC, oPlaceable) <= 10.0)
    {
        nPlaceableValue = GetLocalInt(oPlaceable, "0_PlaceableRest");
        if(nPlaceableValue) return nPlaceableValue;
        oPlaceable = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, ++nIndex);
    }
    return FALSE;
}
int IsThereAnEncounter(object oPC, int nForageBonus)
{
    // Get the area random encounter waypoint if it is placed in the area.
    object oWaypoint = GetNearestObjectByTag("ip_randomencounter", oPC);
    if(GetIsObjectValid(oWaypoint))
    {
        int nChance = GetLocalInt(oWaypoint, "0_Enc_Chance");
        if(IsCampfireNearby(oPC)) nChance = nChance * 2;
        // Forage check must be 20 or higher to decrease encounter chances.
        nForageBonus -= 3;
        if(nForageBonus > 8) nForageBonus = 8;
        if(nForageBonus > 0) nChance = nChance - ((nChance * nForageBonus) / 10);
        //Debug ("0e_pcrest", "124", "nEncChance: " + IntToString (nChance) +
        //       " nForagebonus: " + IntToString (nForageBonus));
        int nRoll = d100LuckRoll(oPC);
        if(nRoll <= nChance)
        {
            SendMessages("Your rest has been interupted (Roll: " + IntToString(nRoll) + " Chance: " + IntToString(nChance) + ")!", COLOR_RED, oPC);
            return TRUE;
        }
        else SendMessages("Your rest was uninterupted (Roll: " + IntToString(nRoll) + " Chance: " + IntToString(nChance) + ").", COLOR_GREEN, oPC);
    }
    return FALSE;
}
object GetBestPartyListenSpot(object oPC)
{
    int nPerception, nBestPerception = -99;
    object oBestPMPerception;
    object oPartyMember = GetFirstFactionMember(oPC, FALSE);
    while(oPartyMember != OBJECT_INVALID)
    {
        nPerception = GetSkillRank(SKILL_LISTEN, oPartyMember) + GetSkillRank(SKILL_SPOT, oPartyMember);
        //Debug("0i_creature", "1060", " oPartyMember: " + GetName(oPartyMember) + " nPerception: " + IntToString (nPerception));
        if (nPerception > nBestPerception)
        {
            nBestPerception = nPerception;
            oBestPMPerception = oPartyMember;
        }
        oPartyMember = GetNextFactionMember(oPC, FALSE);
    }
    //Debug("0i_creature", "1067", "oBestPMPerception: " + GetName(oBestPMPerception));
    return oBestPMPerception;
}
void SetupRandomEncounter(object oPC)
{
    // PC notices random monsters based on spot and listen.
    object oSpotter = GetBestPartyListenSpot(oPC);
    int nPerception = (GetSkillRank(SKILL_LISTEN, oSpotter) + GetSkillRank(SKILL_SPOT, oSpotter)) / 2;
    int nRoll = d20();
    int nCheck = nRoll + nPerception;
    if(nPerception < 0) SendMessages(GetName(oSpotter) + " makes a perception check: " + IntToString(nRoll) +
                                     " - " + IntToString(abs(nPerception)) +
                                     " = " + IntToString(nCheck), COLOR_GRAY, oPC);
    else SendMessages(GetName(oSpotter) + " makes a perception check: " + IntToString(nRoll) +
                      " + " + IntToString(nPerception) +
                      " = " + IntToString(nCheck), COLOR_GRAY, oPC);
    if(nCheck < 0) nCheck = 0;
    location lLocation = GetRandomLocation(GetArea (oPC), oPC, IntToFloat(nCheck));
    object oWaypoint = CreateObject(OBJECT_TYPE_WAYPOINT, "ip_encounter", lLocation);
    CreateCreature(oWaypoint, oPC, GetLocalInt(GetArea(oPC), "0_Area_Level"));
    DestroyObject(oWaypoint);
    // Exit the rest script.
    DeleteLocalInt(oPC, "0_PlaceableRest");
    DeleteLocalInt(oPC, "0_Campfire");
    AssignCommand(oPC, ClearAllActions());
}
void SetupResting(object oPC)
{
    // Save the current hitpoints so we can adjust them once rested.
    int nHitpoints = GetCurrentHitPoints(oPC);
    SetLocalInt(oPC, "0_Current_HP", nHitpoints);
    // Save the current hitpoints of our henchmen and npc's.
    int nIndex = 1;
    int nAssociateType = 1;
    object oAssociate = GetAssociate(nAssociateType, oPC);
    while(nAssociateType < 5)
    {
        nIndex = 1;
        oAssociate = GetAssociate(nAssociateType, oPC, 1);
        while(oAssociate != OBJECT_INVALID)
        {
            SetLocalInt(oAssociate, "0_Current_HP", GetCurrentHitPoints(oAssociate));
            oAssociate = GetAssociate(nAssociateType, oPC, ++nIndex);
        }
        ++nAssociateType;
    }
}
int GetRestingBonus(object oPC, object oCreature)
{
    // Placeable rest gives a bonus to healing based on the placeable used.
    int nRestingBonusHP = GetNearestRestPlaceableValue(oPC);
    //Debug ("0e_pcrest", "166", "nRestingBonusHP: " + IntToString (nRestingBonusHP) +
    //       " nForageBonus: " + IntToString (nForageBonus));
    // 999 is a placeable that does not use supplies. i.e. Bed at an inn.
    if(nRestingBonusHP == 999) return nRestingBonusHP;
    if(nRestingBonusHP > 0)
    {
        // Check for supplies since we did use a camping placeable.
        // Base 1 + Placeable bonus + Rations/Water + Campfire.
        nRestingBonusHP = 1 + nRestingBonusHP + CheckForWaterAndRations(oCreature) + IsCampfireNearby(oCreature);
    }
    else
    {
        int nForageBonus = GetForageBonus(oPC);
        // ForageBonus is over 3 we just use the bonus.
        if(nForageBonus > 3) nRestingBonusHP = nForageBonus;
        // Better than a basic check so we don't need Campfire check.
        else if(nForageBonus == 3) nRestingBonusHP = nForageBonus + CheckForWaterAndRations (oCreature);
        else
        {
            // Check for supplies since we got a low forage check.
            // Placeable bonus + Rations/Water + Campfire + Standard bonus.
            nRestingBonusHP = nRestingBonusHP + nForageBonus + CheckForWaterAndRations(oCreature) + IsCampfireNearby(oCreature);
        }
    }
    // Check for Periapt of Wound Closure.
    // Periapt of wound closure doubles your resting bonus.
    string sResRef = GetResRef (GetItemInSlot (INVENTORY_SLOT_NECK, oCreature));
    if(sResRef == "0_periapt_woundc" && nRestingBonusHP < 999) nRestingBonusHP = nRestingBonusHP * 2;
    return nRestingBonusHP;
}
void SetCorrectHitpoints(object oPC, object oCreature)
{
    int nHitpoints, nRace = GetRacialType(oCreature);
    if(nRace == RACIAL_TYPE_UNDEAD || nRace == RACIAL_TYPE_CONSTRUCT)
    {
        nHitpoints = GetLocalInt(oCreature, "0_Current_HP");
        DeleteLocalInt(oCreature, "0_Current_HP");
        // Set the characters hitpoints after rest.
        NWNX_Object_SetCurrentHitPoints(oCreature, nHitpoints);
    }
    else
    {
        // Get the Hitpoints saved before oCreature fully rested.
        // Has to be saved since the game fully heals on rest.
        int nHeal;
        nHitpoints = GetLocalInt(oCreature, "0_Current_HP");
        DeleteLocalInt(oCreature, "0_Current_HP");
        int nMaxHp = GetMaxHitPoints(oCreature);
        // Check for items with regeneration we assume you would use any you have.
        if(GetHasRegeneration(oCreature)) nHitpoints = nMaxHp;
        else
        {
            int nRestingBonusHP = GetRestingBonus(oPC, oCreature);
            // Get the Hitpoints we want to heal based on constant in 0i_constants.
            nHeal = (GetCharacterLevels(oCreature) * HEAL_HP_PER_LEVEL) * nRestingBonusHP;
            // Add the original hitpoints to the amount we want to heal.
            nHitpoints += nHeal;
        }
        if(nHitpoints < nMaxHp)
        {
            // Set the characters hitpoints after rest.
            NWNX_Object_SetCurrentHitPoints(oCreature, nHitpoints);
            if(oPC == oCreature) SendMessages("You have healed " + IntToString(nHeal) + " hitpoints while resting.", COLOR_GREEN, oPC, FALSE, FALSE);
            else SendMessages(GetName(oCreature) + " has  healed " + IntToString(nHeal) + " hitpoints while resting.", COLOR_GREEN, oPC, FALSE, FALSE);
        }
        else
        {
           if(oPC == oCreature) SendMessages("You are fully healed after resting.", COLOR_GREEN, oPC, FALSE, FALSE);
            else SendMessages(GetName(oCreature) + " has fully healed after resting.", COLOR_GREEN, oPC, FALSE, FALSE);
        }
    }
}
void FinalizeResting(object oPC)
{
    SetCorrectHitpoints(oPC, oPC);
    int nIndex, nAssociateType = 1;
    effect eUnsummon;
    object oAssociate = GetAssociate(nAssociateType, oPC);
    while(nAssociateType < 7)
    {
        nIndex = 1;
        oAssociate = GetAssociate(nAssociateType, oPC, 1);
        while(oAssociate != OBJECT_INVALID)
        {
            // We check for Summons that are created as henchman.
            // If they are true summons then we must remove them on resting.
            int nSummon = GetLocalInt(oAssociate, "0_Summon_ID");
            if(nSummon)
            {
                // Animated dead are kept.
                if(nSummon == SPELL_ANIMATE_DEAD || nSummon == SPELLABILITY_PM_ANIMATE_DEAD)
                {
                    SetCorrectHitpoints(oPC, oAssociate);
                }
                else
                {
                    eUnsummon = EffectVisualEffect(VFX_IMP_UNSUMMON);
                    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eUnsummon, GetLocation(oAssociate));
                    SetIsDestroyable(TRUE, FALSE, FALSE, oAssociate);
                    DestroyObject(oAssociate);
                }
            }
            oAssociate = GetAssociate(nAssociateType, oPC, ++nIndex);
        }
        ++nAssociateType;
    }
    // Save the last time this character rested so we can restrict resting.
    int nCurrentTime = GetCurrentDateTimeInMinutes ();
    SetObjectDatabaseString(oPC, CHARACTER_TABLE, "lastrested", IntToString (nCurrentTime));
    // Save the player regardless of time laps.
    SaveCharacterData(oPC, TRUE);
    SaveAssociatesToDatabase(oPC, FALSE);
    IncreaseServerDatabaseCounter(oPC, PLAYER_TABLE, "rests");
    IncreaseObjectDatabaseCounter(oPC, CHARACTER_TABLE, "rests");
    // Clear resting variables.
    AdjustFeatUses(oPC);
    AdjustSummonUses(oPC, 1);
}
