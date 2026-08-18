/*//////////////////////////////////////////////////////////////////////////////
 Howl: Fear
 NW_S1_HowlFear
////////////////////////////////////////////////////////////////////////////////
 A howl emanates from the creature which affects all within 10ft on a failed save.
 Creatures must make a Will save vs Fear DC 10 + Hit die / 4 or be
 Shakened (-2) if the creature is less than 6 hit dice.
 Frightened (-4) if the creature is 6 to 15 hit dice.
 Panicked (-6) if the creature is 16 to 20+ hit dice.
 This effect lasts for 1 round + Hit dice / 4 rounds.
 Updated By Philos
//////////////////////////////////////////////////////////////////////////////*/
#include "0i_spells"
void main()
{
    //Declare major variables
    effect eCenter = EffectVisualEffect(VFX_FNF_HOWL_MIND);
    effect eImpact = EffectVisualEffect(VFX_IMP_FEAR_S);
    int nFear;
    int nHitDice = GetHitDice(OBJECT_SELF);
    float fDelay;
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + (nHD / 4);
    float fDuration = RoundsToSeconds(1 + (nHD / 4));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eCenter, OBJECT_SELF);
    location lLocation = GetLocation (OBJECT_SELF);
    // Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    while(GetIsObjectValid (oTarget))
    {
        if(GetIsEnemy(oTarget) && oTarget != OBJECT_SELF)
        {
            fDelay = GetDistanceToObject(oTarget) / 10;
            // Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_HOWL_FEAR));
            // Make a saving throw check
            if(!WillSave (oTarget, nDC, SAVING_THROW_TYPE_FEAR))
            {
                //Apply the VFX impact and effects
                if(nHitDice < 6) DelayCommand(fDelay, Shaken(oTarget, fDuration, nHitDice));
                else if(nHitDice < 16) DelayCommand(fDelay, Frightened(oTarget, fDuration, nHitDice));
                else DelayCommand(fDelay, Panicked(oTarget, fDuration, nHitDice));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
            }
        }
        // Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    }
}

