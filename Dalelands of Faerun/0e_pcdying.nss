/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_pcdying
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a player drops below 1 hitpoint.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
#include "0i_character"
#include "0i_items"
void main ()
{
   string sResRef;
   object oPC = GetLastPlayerDying ();
   object oArea = GetArea (oPC);
   int iHP = GetCurrentHitPoints (oPC);
   SetLocalObject (oPC, "0_KILLER", GetLastHostileActor (oPC));
   // Check to see if they are actually dead -10 or more.
   // If so kill them.
   if (iHP < -9) ApplyEffectToObject (DURATION_TYPE_INSTANT, EffectDeath (FALSE, TRUE), oPC);
   // Make sure they have not been healed after this script has been fired.
   else if (iHP < 1)
   {
      // Check for Periapt of Wound Closure and items of regeneration.
      sResRef = GetResRef (GetItemInSlot (INVENTORY_SLOT_NECK, oPC));
      if (sResRef == "0_periapt_woundc" || GetHasRegeneration (oPC, TRUE)) SetLocalInt (oPC, "0_FirstAid", TRUE);
      // Remove any first aid they may have had if they don't have Periapt of wound closure.
      else DeleteLocalInt (oPC, "0_FirstAid");
      NWNX_Creature_OverrideDamageLevel (oPC, 6);
      // Post this to the logs and all DM's.
      SendMessages (GetName (oPC) + " has fallen in " + GetName (oArea) + " [ " + GetTag (oArea) + " ]!", COLOR_RED, OBJECT_INVALID, TRUE, FALSE);
      // Set player/character bleed counters.
      IncreaseServerDatabaseCounter (oPC, PLAYER_TABLE,"bleeds");
      IncreaseObjectDatabaseCounter (oPC, CHARACTER_TABLE,"bleeds");
      // Set the PC to dying mode so creatures stop attacking.
      SetLocalInt (oPC, "0_BLEEDING", TRUE);
      //DelayCommand (60.0, DeleteLocalInt (oPC, "0_BLEEDING"));
      //  Delay to the next round to check for bleeding again.
      DelayCommand (6.0, CharacterBleeding (TRUE, oPC));
   }
}

