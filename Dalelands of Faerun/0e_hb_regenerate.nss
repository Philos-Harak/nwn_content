/*///////////////////////////////////////////////////
 Script: NW_C2_DEFAULT1
 Programmer: Naomi Novik
////////////////////////////////////////////////////
  OnHeartbeat script for Regenerating creatures.
  This script causes NPCs to perform default animations
  while not otherwise engaged.
/*///////////////////////////////////////////////////
#include "0i_effects"
void main()
{
    // Check to see if we should be playing default animations
    // make sure we don't have any current targets
    /*if (GetAttemptedAttackTarget () == OBJECT_INVALID &&
             GetAttemptedSpellTarget () == OBJECT_INVALID &&
             GetNearestEnemy (OBJECT_SELF, 1, 7, 7) == OBJECT_INVALID &&
             !GetIsInCombat () &&
             GetTag (GetArea (OBJECT_SELF)) != "cynosure")
    {
         // They are not talking to someone lets check for animations.
         if (!IsInConversation (OBJECT_SELF)) CheckCreatureAI ();
    } */
    // *********************************************************
    // ********** Regenerating creatures regenerating **********
    // *********************************************************
    object oCreature = OBJECT_SELF;
    int nTempDmg = GetLocalInt(oCreature, "0_TempDmg" );
    int nTotalDmg = nTempDmg + GetLocalInt(oCreature, "0_PermDmg");
    // If healed above 0 and is unconsious then get up!
    if(GetLocalInt (oCreature, "0_Unconscious"))
    {
        if(nTotalDmg < GetMaxHitPoints())
        {
            SetCommandable (TRUE);
            // Force the creature up off the ground won't unless it has an attack target.
            ActionForceMoveToLocation(GetLocation(oCreature));
            SetLocalInt(oCreature, "0_Unconscious", FALSE);
        }
        else return;
    }
    if(nTempDmg > 0) Regenerate();
    ExecuteScript("nw_c2_default1", oCreature);
}

