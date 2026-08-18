/*//////////////////////////////////////////////////////////////////////////////
 Krenshar Fear Stare
 NW_S1_KrenScare
////////////////////////////////////////////////////////////////////////////////
 Causes those in the gaze to be frightened (-4 penalty to attacks, saves, and
 skill checks.
//////////////////////////////////////////////////////////////////////////////*/
#include "0i_spells"
void main()
{
    effect eImpact = EffectVisualEffect(VFX_IMP_FEAR_S);
    int nSave, nHitDice = GetHitDice(OBJECT_SELF);
    float fDelay;
    location lLocation = GetSpellTargetLocation ();
    // Get first target in the spell cone.
    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 10.0, lLocation, TRUE);
    while(GetIsObjectValid (oTarget))
    {
        if(GetIsEnemy (oTarget))
        {
            fDelay = GetDistanceToObject(oTarget) / 20;
            // Fire cast spell at event for the specified target.
            SignalEvent(oTarget, EventSpellCastAt (OBJECT_SELF, SPELLABILITY_KRENSHAR_SCARE));
            nSave = WillSave(oTarget, 12, SAVING_THROW_TYPE_FEAR);
            if(!nSave)
            {
                // Apply the linked effects and the VFX impact.
                DelayCommand(fDelay, Frightened(oTarget, 18.0, nHitDice));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
            }
            else if(nSave != 2)
            {
                // Apply the linked effects and the VFX impact.
                DelayCommand(fDelay, Shaken(oTarget, 6.0, nHitDice));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
            }
        }
        // Get next target in the spell cone.
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 10.0, lLocation, TRUE);
    }
}
