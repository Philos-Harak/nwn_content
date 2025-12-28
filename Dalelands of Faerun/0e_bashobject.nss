/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Scruot Name: 0e_bashobject
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 On_damage event that fires when someone bashes an object like a sarcophagus,
 Checks to see if they can opening it.
 If so then it opens it and gives a small experience bonus for getting through.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
#include "0i_traps"
#include "0i_items"
#include "X0_i0_voice"

int CannotBashWithWeapon (object oWeapon)
{
   int nType = GetBaseItemType (oWeapon);
   switch (nType)
   {
      case 31: return TRUE; // Javelin
      case BASE_ITEM_SHURIKEN: return TRUE;
      case BASE_ITEM_HEAVYCROSSBOW: return TRUE;
      case BASE_ITEM_LIGHTCROSSBOW: return TRUE;
      case BASE_ITEM_LONGBOW: return TRUE;
      case BASE_ITEM_SHORTBOW: return TRUE;
   }
   return FALSE;
}

void BashOpen (object oObject, object oPC, int nDC, int nLevel)
{
     // Lets give the xp.
     GiveAreaXP (oPC, IntToFloat (nDC), IntToFloat (nLevel));
     effect eExplode = EffectVisualEffect (VFX_IMP_DUST_EXPLOSION);
     ApplyEffectToObject (DURATION_TYPE_INSTANT, eExplode, oObject);
     SetLocked (oObject, FALSE);
}

void main ()
{
   // Check to see if an NPC is bashing the door instead of a PC.
   object oMaster;
   object oPC = GetLastDamager (OBJECT_SELF);
   int bIsPC = GetIsPC (oPC);
   if (!bIsPC) oMaster = GetMaster (oPC);
   // Check to see if they are using a ranged weapon.
   object oWeapon = GetLastWeaponUsed (oPC);
   if (CannotBashWithWeapon (oWeapon))
   {
        if (bIsPC) SendMessages ("You cannot use a " + GetName (oWeapon) + " to bash this " + GetName (OBJECT_SELF) + " !", COLOR_RED, oPC, FALSE, FALSE);
        else SendMessages (GetName (oPC) + " cannot use a " + GetName (oWeapon) + " to bash this " + GetName (OBJECT_SELF) + " !", COLOR_RED, oMaster, FALSE, FALSE);
        return;
   }
   // Check to see if this door is trapped!
   if (GetIsTrapped (OBJECT_SELF))
   {
       // Get the type of trap.
       int nTrapType = GetTrapBaseType (OBJECT_SELF);
       // Generate the trap.
       TriggerTrap (oPC, OBJECT_SELF, nTrapType, GetLocalInt (OBJECT_SELF, "0_AOE_Trap"));
       // Set the no xp for disable variable to not give xp for triggering a trap.
       SetLocalInt (OBJECT_SELF, "0_NoDisableXP", TRUE);
       // Now turn of the trap!
       SetTrapDisabled (OBJECT_SELF);
   }
   // Check to make sure this door is locked.. no xp and automatically open if not locked.
   if (!GetLocked (OBJECT_SELF))
   {
      effect eExplode = EffectVisualEffect(VFX_IMP_DUST_EXPLOSION);
      ApplyEffectToObject(DURATION_TYPE_INSTANT, eExplode, OBJECT_SELF);
      AssignCommand (OBJECT_SELF, ActionOpenDoor (OBJECT_SELF));
      PlaySound ("as_cv_woodbreak2");
      AssignCommand (OBJECT_SELF, ClearAllActions (TRUE));
   }
   else
   {
      // Get the area level.
      int nLevel = GetLocalInt (GetArea (OBJECT_SELF), "0_Area_Level");
      // Limit the levels we use to the minimum area level.
      if (nLevel < MIN_AREA_LEVEL || nLevel > MAX_AREA_LEVEL) nLevel = MIN_AREA_LEVEL;
      int nDC = GetLocalInt (OBJECT_SELF, "0_BashDC");
      if (nDC == 0)
      {
         nDC = BASH_BASE_DC + Random(BASH_DIE) + 1 + nLevel;
         // Set the DC on the door so it doesn't change.
         SetLocalInt (OBJECT_SELF, "0_BashDC", nDC);
      }
      // Lets check against the PC's Strength + Athletics.
      int nAthletics = GetSkillRank (SKILL_ATHLETICS, oPC);
      int nRoll = d20();
      if (nAthletics + nRoll >= nDC)
      {
         if (bIsPC)
         {
            SendMessages ("You bash the " + GetName (OBJECT_SELF) + " ("
                         + IntToString (nRoll) + " + " + IntToString (nAthletics)
                         + " = " + IntToString (nAthletics + nRoll) + " DC: "
                         + IntToString (nDC) + "). It gives way.", COLOR_GREEN, oPC, FALSE, FALSE);
             AssignCommand (oPC, ClearAllActions (TRUE));
             BashOpen (OBJECT_SELF, oPC, nDC, nLevel);
         }
         else
         {
             SendMessages (GetName (oPC) + " bashes the " + GetName (OBJECT_SELF) + " ("
                         + IntToString (nRoll) + " + " + IntToString (nAthletics)
                         + " = " + IntToString (nAthletics + nRoll) + " DC: "
                         + IntToString (nDC) + "). It gives way.", COLOR_GREEN, oMaster, FALSE, FALSE);
             BashOpen (OBJECT_SELF, oPC, nDC, nLevel);
             AssignCommand (oPC, ClearAllActions (TRUE));
             AssignCommand (oPC, VoiceTaskComplete ());
         }
      }
      else
      {
          if (bIsPC) SendMessages ("You bash the " + GetName (OBJECT_SELF) + " ("
                                         + IntToString (nRoll) + " + " + IntToString (nAthletics)
                                         + " = " + IntToString (nAthletics + nRoll) + " DC: "
                                         + IntToString (nDC) + "). It holds fast.", COLOR_RED, oPC, FALSE, FALSE);
          else
          {
              SendMessages (GetName (oPC) + " bashes the " + GetName (OBJECT_SELF) + " ("
                                           + IntToString (nRoll) + " + " + IntToString (nAthletics)
                                           + " = " + IntToString (nAthletics + nRoll) + " DC: "
                                           + IntToString (nDC) + "). It holds fast.", COLOR_RED, oMaster, FALSE, FALSE);      }
          }
   }
   // Heal the door so it doesn't get destroyed.
   //effect eHeal = EffectHeal (1000);
   //ApplyEffectToObject (DURATION_TYPE_INSTANT, eHeal, OBJECT_SELF);
}

