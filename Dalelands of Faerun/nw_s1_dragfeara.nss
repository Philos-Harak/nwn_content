/*(/////////////////////////////////////////////////////////////////////////////
 Scipt Name: nw_s1_dragfeara
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Fear aura enter script used by dragons.

 Entering creature must make a Will save vs Fear DC 10 + Hit die / 2 or be
 Shakened (-2) if the creature is less than 6 hit dice.
 Frightened (-4) if the creature is 6 to 15 hit dice.
 Panicked (-6) if the creature is 16 to 20+ hit dice.
 This effect lasts for 4d6 rounds.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    object oCaster = GetAreaOfEffectCreator();
    string sCasterName = StripColorCodes (GetName (oCaster));
    // Exit if the target is not an enemy or has already been hit with this creatures aura.
    if (!GetIsEnemy (oTarget, oCaster) || GetLocalString (oTarget, "0_AURA_FEAR") == sCasterName) return;
    effect eImpact = EffectVisualEffect (VFX_IMP_FEAR_S);
    int nFear;
    int nHitDice = GetHitDice(oCaster);
    int nDC = (GetHitDice (oCaster) / 2) + GetAbilityModifier (ABILITY_CHARISMA, oCaster) + 10;
    float fDuration = RoundsToSeconds (d6(4));
    // Fire cast spell at event for the specified target
    SignalEvent (oTarget, EventSpellCastAt(oCaster, SPELLABILITY_AURA_FEAR));
    // Add a variable with the casters name to the monster so we know we did a check already.
    // Creatures only have to make one save no matter if the fail or not.
    SetLocalString (oTarget, "0_AURA_FEAR", sCasterName);
    //Make a saving throw check
    if(!WillSave(oTarget, nDC, SAVING_THROW_TYPE_FEAR))
    {
        //Apply the VFX impact and effects
        if(nHitDice < 6) Shaken(oTarget, fDuration, nHitDice);
        else if(nHitDice < 16) Frightened(oTarget, fDuration, nHitDice);
        else Panicked(oTarget, fDuration, nHitDice);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget);
    }
}
