/*////////////////////////////////////////////////
 Script: 0s_unh_sacrifice
 Programmer: Philos
////////////////////////////////////////////////
You sacrifice the life of one of your comrades
to heal and remove all effects from yourself.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // Remove all bad effects and heal the caster.
    effect eVisual = EffectVisualEffect (VFX_FNF_MASS_HEAL);
    effect eHeal = EffectHeal(1000);
    object oCaster = OBJECT_SELF;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oCaster);
    RemoveCreatureEffects(oCaster, 1);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eHeal, oCaster);
    object oTarget = GetSpellTargetObject();
    // Only sacrifice allies in our party.
    if(GetFactionEqual(oCaster, oTarget))
    {
        // If they are not player characters we must do more to kill them!
        if(!GetIsCharacter(oTarget))
        {
            SetIsDestroyable(TRUE, TRUE, TRUE, oTarget);
            SetLocalInt(oTarget, "0_Hitpoints", -10);
        }
        // Players get a save vs death.
        else
        {
            int nDC = 20 + GetAbilityModifier(ABILITY_CHARISMA, oCaster);
            if(SavingThrowWithEffects(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_DEATH, oCaster))
            {
                SendMessages("You resisted the sacrifice by " + GetName(oCaster) + "!", COLOR_YELLOW, oTarget);
                if(GetIsCharacter(oCaster)) SendMessages(GetName(oTarget) + " resisted your sacrifice!", COLOR_YELLOW, oCaster);
                return;
            }
        }
        if(GetIsCharacter(oTarget)) SendMessages("You have been sacrificed by " + GetName(oCaster) + "!", COLOR_RED, oTarget);
        if(GetIsCharacter(oCaster)) SendMessages("You have sacrificed " + GetName(oTarget) + "!", COLOR_RED, oCaster);
        effect eDeath = EffectDeath();
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDeath, oTarget);
    }
}




