/*//////////////////////////////////////////////////////////////////////////////
// Script Name: x2_s1_shadow
////////////////////////////////////////////////////////////////////////////////
 The shadow gets special strength drain attack, once per round.
 The shifter's spectre form can use this but is not as effective as a real shadow
//////////////////////////////////////////////////////////////////////////////*/
#include "0i_spells"
void ApplyStrengthDrain (int nDamage, object oTarget)
{
    // Delaying the command to sever the connection between this effect and
    // the spell, so its effects stack.
    effect eDamage = EffectAbilityDecrease(ABILITY_STRENGTH, nDamage);
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDamage, oTarget);
}
void DoShadowHit (object oTarget)
{
    int nDamage = d6();
    int nTargetStrength = GetAbilityScore (oTarget, ABILITY_STRENGTH);
    effect eVisual;
    // Target is slain if Strength is reduced to 0.
    if (GetIsImmune (oTarget, IMMUNITY_TYPE_ABILITY_DECREASE) == FALSE)
    {
        // This does not work for PCs (shifter class) it would be too unbalancing
        if (nTargetStrength - nDamage <= 0 && !GetIsCharacter (OBJECT_SELF))
        {
            FloatingTextStrRefOnCreature (84482, oTarget,FALSE);
            int nHitPoints = GetCurrentHitPoints (oTarget);
            effect eHitDamage = EffectDamage (nHitPoints, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHitDamage, oTarget);
        }
        else
        {
            DelayCommand (0.1, ApplyStrengthDrain (nDamage, oTarget));
            FloatingTextStrRefOnCreature (84483, oTarget, FALSE);
        }
        eVisual = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY) ;
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget);
    }
    else
    {
        eVisual = EffectVisualEffect(VFX_COM_HIT_NEGATIVE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget);
    }
}
void main()
{
    object oTarget = GetSpellTargetObject ();
    if (TouchAttackMelee (oTarget, TRUE)) DoShadowHit (oTarget);
}
