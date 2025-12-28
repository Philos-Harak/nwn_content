/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_transition
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Script that transitions a player to the target location based on skills using a placeable.
 Variables on OBJECT_SELF:
 0_TransitionTag: Will use this variable if Param is "".
 0_TransitionTag_Fail: Where to send someone if they fail.
     If not set then uses original transition.
 0_Skill Uses the skill number linked to the skill 2da to make a skill check.
 0_DC: If set will use this DC instead of 9 + Area Level.
 0_Tool: If set to an item it will give a bonus to the skill check based on that item.
 0_SuccessText: The text sent to the player if they succeed.
 0_FailText: The text sent to the player if they fail.
 0_DamageDie: Will give the damage die to use if the check failed then transition them. Default 6.
 0_DamageDieNum: Will give the number of dice to roll. Default iLevel / 2.
 0_Poison: Will make a check to see if they are poisoned by the # POISON_#. Used when swimming in poisoned water.
 0_Effect: Will use special effect on player.
    -1 is the portal effect.
    -2 is the Return to Prime Effect.
    -3 is the Rod of RecallEffect.
 Skills: 3 Athletics (Used for Climb, Swim, etc)
*///////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
#include "0i_creature"
#include "0i_area"
void SkillTransition (object oPC, object oPlaceable)
{
   int nLevel = GetLocalInt (GetArea(oPlaceable), "0_Area_Level");
   int nPoison = GetLocalInt (oPlaceable, "0_Poison");
   if (nPoison)
   {
       if (!FortitudeSave (oPC, nLevel + 10, SAVING_THROW_TYPE_POISON, oPlaceable))
       {
           effect ePoison = EffectPoison (nPoison);
           effect eImpact = EffectVisualEffect (VFX_IMP_POISON_L);
           DelayCommand (0.1, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPC));
           DelayCommand (0.1, ApplyEffectToObject (DURATION_TYPE_INSTANT, ePoison, oPC));
       }
   }
   // Is there a skill check associated with this transition?
   int nSkill = GetLocalInt (oPlaceable, "0_Skill");
   if (nSkill > 0)
   {
        // Get the Skill DC.
        int nDC = GetLocalInt (oPlaceable, "0_DC");
        if (nDC == 0) nDC = 9 + nLevel;
        // Check to see if they have and can use a tool.
        string sTool = GetLocalString (oPlaceable, "0_Tool");
        object oItem = GetCreatureHasItem (oPC, sTool);
        // Get the items skill bonus.
        int nBonus;
        if (GetIsObjectValid (oItem)) nBonus = GetItemCharges (oItem);
        // Make check.
        if (GetSkillCheck (oPC, nSkill, TRUE, nBonus, nDC) < 0)
        {
            // Send failure message.
            string sMessage = GetLocalString (oPlaceable, "0_FailText");
            SendMessages (sMessage, COLOR_RED, oPC, FALSE, FALSE);
            // Give damage.
            int nDamageDie = GetLocalInt (oPlaceable, "0_DamageDie");
            if (nDamageDie == 0) nDamageDie = 6;
            int nDamageDieNum = GetLocalInt (oPlaceable, "0_DamageDieNum");
            if (nDamageDieNum == 0) nDamageDieNum = nLevel / 2;
            int nDamage;
            while (nDamageDieNum > 0)
            {
                nDamage = nDamage + Random (nDamageDie) + 1;
                nDamageDieNum --;
            }
            effect eDamage = EffectDamage (nDamage, DAMAGE_TYPE_BLUDGEONING);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eDamage, oPC);
            // Get failed transition.
            string sTagFail = GetLocalString (oPlaceable, "0_TransitionTag_Fail");
            // Transition function uses Move_Tag to force move to the object with that tag.
            SetLocalString (oPC, "Move_Tag", sTagFail);
            Transition (oPC);
            return;
        }
        else
        {
            // Send success message.
            string sMessage = GetLocalString (oPlaceable, "0_SuccessText");
            SendMessages (sMessage, COLOR_GREEN, oPC, FALSE, FALSE);
        }
   }
   int nEffect = GetLocalInt(oPlaceable, "0_Effect");
   if(nEffect)
   {
        float fDelay;
        if(nEffect == -1) fDelay = PortalEffect(oPlaceable, oPC);
        else if(nEffect == -2) ReturnToPrimeEffect(OBJECT_INVALID, oPC);
        else if(nEffect == -3) fDelay = RodOfRecallEffect(oPC);
        else
        {
            effect eVisual = EffectVisualEffect(nEffect);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oPC);
        }
        DelayCommand(fDelay, Transition(oPC));
        return;
   }
   Transition (oPC);
}

// Delay transition until the creature is at the transition location.
// oCreature is the creature to wait to transition.
void WaitToSkillTransition (object oCreature, object oPlaceable)
{
    // if we have run this script more than 30 times then exit.
    int nCounter = GetLocalInt (oCreature, "Move_Count");
    //Debug ("0i_area", "937", "nCounter: " + IntToString (nCounter));
    if (nCounter < 30)
    {
        // Get the distance from the transition
        float fDistance = GetDistanceBetween (oCreature, oPlaceable);
        // if its more than 2.0 meters then wait.
        if (fDistance > 3.0f)
        {
            SetLocalInt (oCreature, "Move_Count", ++nCounter);
            DelayCommand (0.5f, WaitToSkillTransition (oCreature, oPlaceable));
        }
        // We are close enough so lets transition.
        else SkillTransition (oCreature, oPlaceable);
    }
    else
    {
        DeleteLocalInt (oCreature, "Move_Count");
        DeleteMoveVariables (oCreature);
    }
}

void main ()
{
    object oPC = GetPlaceableLastClickedBy ();
    string sTag = GetLocalString (OBJECT_SELF, "0_TransitionTag");
    //Debug("0e_transition", "117", "sTag: " + sTag);
    DeleteMoveVariables (oPC);
    // Transition function uses Move_Tran to get the transitioning object.
    SetLocalObject (oPC, "Move_Tran", OBJECT_SELF);
    // Check distance as we don't want to transition until they are close.
    float fDistance = GetDistanceToObject (oPC);
    if (fDistance > 2.0f)
    {
        // Check to see if we are already looking to move.
        int nCount = GetLocalInt (oPC, "Move_Count");
        // If the original count was 0 then we need to start a
        // wait for transition function for this PC Clear if the counter is 30+.
        if (nCount > 29)
        {
            SetLocalInt (oPC, "Move_Count", 0);
            nCount = 0;
        }
        if (nCount == 0)
        {
            //Debug ("0e_oi_walk_wp_b", "66", "Running WaitToTransition (oClicker)!");
            WaitToSkillTransition (oPC, OBJECT_SELF);
        }
        // If it is counting then we need to clear the count since we have
        // clicked a new location. The old wait for transition will still run.
        else
        {
            SetLocalInt (oPC, "Move_Count", 0);
        }
    }
    else SkillTransition (oPC, OBJECT_SELF);
}
