/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_transition
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that transitions a player to the target location.
 Param:
 sTransitionTag - the tag of the object to transition to (Must be unique).
 Variables on OBJECT_SELF:
 0_TransitionTag: Will use this variable if Param is "".
 0_TransitionTag_Fail: Where to send someone if they fail.
     If not set then uses original transition.
 0_Skill Uses the skill number linked to the skill 2da to make a skill check.
 0_DC: If set will use this DC instead of 9 + Area Level.
 0_Tool: If set to an item it will give a bonus to the skill check based on that item.
 0_FailText: The text sent to the player if they fail.
 0_DamageDie: Will give the damage die to use if the check failed then transition them. Default 6.
 0_DamageDieNum: Will give the number of dice to roll. Default iLevel / 2.
 0_Poison: Will make a check to see if they are poisoned by the # POISON_#.
 Skills: 3 Athletics (Used for Climb, Swim, etc)
*///////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
#include "0i_creature"
#include "0i_area"
void main()
{
   int nDC, nBonus, nCheck, nDamage, nDamageDie, nDamageDieNum;
   string sTool, sMessage, sTagFail;
   object oWPTransition, oItem;
   effect eDamage;
   object oPC = GetPCSpeaker ();
   int nLevel = GetLocalInt (GetArea(OBJECT_SELF), "0_Area_Level");
   int nPoison = GetLocalInt (OBJECT_SELF, "0_Poison");
   if (nPoison)
   {
       if (!FortitudeSave (oPC, nLevel + 10, SAVING_THROW_TYPE_POISON, OBJECT_SELF))
       {
           effect ePoison = EffectPoison (nPoison);
           effect eImpact = EffectVisualEffect (VFX_IMP_POISON_L);
           DelayCommand (0.1, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPC));
           DelayCommand (0.1, ApplyEffectToObject (DURATION_TYPE_INSTANT, ePoison, oPC));
       }
   }
   string sTag = GetScriptParam ("sTransitionTag");
   // If the conversation didn't pass a transition tag then it must be on the object.
   if (sTag == "") sTag = GetLocalString (OBJECT_SELF, "0_TransitionTag");
   // If it did pass a transition tag lets put it on the object for the Transition function.
   else SetLocalString (OBJECT_SELF, "0_TransitionTag", sTag);
   // Is there a skill check associated with this transition?
   int nSkill = GetLocalInt (OBJECT_SELF, "0_Skill");
   DeleteMoveVariables (oPC);
   // Transition function uses Move_Tran to get the transitioning object.
   SetLocalObject (oPC, "Move_Tran", OBJECT_SELF);
   if (nSkill > 0)
   {
        // Get the Skill DC.
        nDC = GetLocalInt (OBJECT_SELF, "0_DC");
        if (nDC == 0) nDC = 9 + nLevel;
        // Check to see if they have and can use a tool.
        sTool = GetLocalString (OBJECT_SELF, "0_Tool");
        oItem = GetCreatureHasItem (oPC, sTool);
        // Get the items skill bonus.
        if (GetIsObjectValid (oItem)) nBonus = GetItemCharges (oItem);
        // Make check.
        if (GetSkillCheck (oPC, nSkill, TRUE, nBonus, nDC) < 0)
        {
            // Send failure message.
            sMessage = GetLocalString (OBJECT_SELF, "0_FailText");
            SendMessages (sMessage, COLOR_RED, oPC, FALSE, FALSE);
            // Give damage.
            nDamageDie = GetLocalInt (OBJECT_SELF, "0_DamageDie");
            if (nDamageDie == 0) nDamageDie = 6;
            nDamageDieNum = GetLocalInt (OBJECT_SELF, "0_DamageDieNum");
            if (nDamageDieNum == 0) nDamageDieNum = nLevel / 2;
            while (nDamageDieNum > 0)
            {
                nDamage = nDamage + Random (nDamageDie) + 1;
                nDamageDieNum --;
            }
            eDamage = EffectDamage (nDamage, DAMAGE_TYPE_BLUDGEONING);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eDamage, oPC);
            // Get failed transition.
            sTagFail = GetLocalString (OBJECT_SELF, "0_TransitionTag_Fail");
            // Transition function uses Move_Tag to force move to the object with that tag.
            SetLocalString (oPC, "Move_Tag", sTagFail);
            Transition (oPC);
            return;
        }
   }
   Transition (oPC);
}
