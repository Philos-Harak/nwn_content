/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_cntrspell
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures using the combat mode counter spell.
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    // We are not in melee combat then we don't attack.
    int bAttack = nInMelee;
    if(!bAttack)
    {
        // If there are no casters, i.e. CLERIC or MAGES in the battle then attack.
        struct stClasses stClasses = ai_GetFactionsClasses(oCreature);
        if(!stClasses.CLERICS && !stClasses.MAGES) bAttack = TRUE;
    }
    // If we are not attacking and using magic then setup for counter spelling.
    if(!bAttack && !ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC))
    {
        //***************************  HEALING & CURES  ****************************
        if(ai_TryHealingTalent(oCreature, nInMelee)) return;
        if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
        int nDifficulty = ai_GetDifficulty(oCreature);
        if(AI_DEBUG) ai_Debug("ai_a_cntrspell", "32", " Counterspell Mode? " +
                 IntToString(GetActionMode(OBJECT_SELF, ACTION_MODE_COUNTERSPELL)));
        if(!GetActionMode(oCreature, ACTION_MODE_COUNTERSPELL))
        {
            object oTarget = ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER);
            // We can only counter spells from a hasted caster if we are hasted as well.
            if(ai_GetHasEffectType(oTarget, EFFECT_TYPE_HASTE) &&
              !ai_GetHasEffectType(oCreature, EFFECT_TYPE_HASTE))
            {
                // If we have haste then we should cast it.
                if(GetHasSpell(SPELL_HASTE, oCreature))
                {
                    if(AI_DEBUG) ai_Debug("ai_a_cntrspell", "45", "Opponent is hasted! Casting Haste.");
                    ActionCastSpellAtObject(SPELL_HASTE, oCreature);
                    ai_SetLastAction(oCreature, SPELL_HASTE);
                    return;
                }
                // If not then we need to go into normal combat.
                else
                {
                    if(AI_DEBUG) ai_Debug("ai_cntrspell", "53", "Opponent is hasted! Using ranged AI.");
                    ExecuteScript("ai_a_ranged");
                    return;
                }
            }
            if(oTarget != OBJECT_INVALID)
            {
                // First a good tactic for counter spelling is to be invisible.
                if(ai_TryToBecomeInvisible(oCreature)) return;
                // If we have attempted to become invisible or are invisible then
                // it is time to counter spell.
                if(AI_DEBUG) ai_Debug("ai_a_cntrspell", "64", "Setting Counterspell mode!");
                ActionCounterSpell(oTarget);
                return;
            }
        }
    }
    if(AI_DEBUG) ai_Debug("ai_a_cntrspell", "75", "Situation is not good for counterspelling! Using ranged AI.");
    ExecuteScript("ai_a_ranged");
}
