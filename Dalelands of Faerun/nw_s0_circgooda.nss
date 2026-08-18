/*////////////////////////////////////////////////
 Script: nw_s0_circgooda
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
    Add basic protection from good effects to entering allies.
/*///////////////////////////////////////////////
#include "NW_I0_SPELLS"
void main()
{
    object oTarget = GetEnteringObject ();
    object oCreator = GetAreaOfEffectCreator ();
    if (GetIsFriend (oTarget, oCreator))
    {
        int nACBonus = GetLocalInt(oCreator, "0_PROT_AC_BONUS");
        int nSaveBonus = GetLocalInt(oCreator, "0_PROT_SAVE_BONUS");
        effect eAC = EffectACIncrease (nACBonus, AC_DEFLECTION_BONUS);
        eAC = VersusAlignmentEffect (eAC, ALIGNMENT_ALL, ALIGNMENT_GOOD);
        effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, nSaveBonus);
        eSave = VersusAlignmentEffect (eSave, ALIGNMENT_ALL, ALIGNMENT_GOOD);
        effect eImmune = EffectImmunity (IMMUNITY_TYPE_MIND_SPELLS);
        eImmune = VersusAlignmentEffect (eImmune,ALIGNMENT_ALL, ALIGNMENT_GOOD);
        effect eVisual = EffectVisualEffect (VFX_DUR_PROTECTION_GOOD_MINOR);
        effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
        effect eLink = EffectLinkEffects (eImmune, eSave);
        eLink = EffectLinkEffects (eLink, eAC);
        eLink = EffectLinkEffects (eLink, eDuration);
        eLink = EffectLinkEffects (eLink, eVisual);
        //Fire cast spell at event for the specified target
        SignalEvent (oTarget, EventSpellCastAt (OBJECT_SELF, SPELL_MAGIC_CIRCLE_AGAINST_GOOD, FALSE));
        //Apply the effects
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eLink, oTarget);
     }
}
