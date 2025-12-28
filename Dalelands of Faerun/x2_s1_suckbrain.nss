/*//////////////////////////////////////////////////////////////////////////////
// Script Name: x2_s1_suckbrain
////////////////////////////////////////////////////////////////////////////////
    The Mindflayer's Extract Brain ability

    Since we can not simulate the When All 4 tentacles hit condition reliably,
    we use this approach for extract brain

    If the player is helpless, the mindflayer will walk up and use this ability,
    which has the Suck Brain special creature animation tied to it through
    spells.2da

    They first perform a melee touch attack to grab the opponent.
    If they grab the victim then they take d3() + 2 points of intelligence
    damage. Once a victim's intelligence drops to 3 the brain has been extracted
    and kills them.

    As a little special condition, if the player is either diseased or poisoned,
    the creature will also become diseases or poisoned by sucking the brain.
*///////////////////////////////////////////////////////////////////////////////
// Alterations Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
// Created By: Georg Zoeller
////////////////////////////////////////////////////////////////////////////////
#include "0i_spells"

void DoSuckBrain (object oTarget, int nDamage, effect eBlood)
{
    effect eDrain = EffectAbilityDecrease (ABILITY_INTELLIGENCE, nDamage);
    eDrain = ExtraordinaryEffect (eDrain);
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDrain, oTarget);
    string sDamage = AddColorToText ("(-" + IntToString (nDamage) + ")", COLOR_RED);
    FloatingTextStringOnCreature (GetName (oTarget) + "'s brain is being sucked on! " + sDamage, oTarget);
    // If the victim is down to 3 Int then we have sucked out the brain!
    if (GetAbilityScore (oTarget, ABILITY_INTELLIGENCE) == 3)
    {
        effect eDeath = EffectDeath ();
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eBlood, oTarget);
        FloatingTextStringOnCreature (AddColorToText (GetName (oTarget) + "'s brain has been sucked out!", COLOR_RED), oTarget);
        DelayCommand (1.0f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, oTarget));
    }
    // If our target was poisoned or diseased, we inherit that
    if (GetHasEffect (EFFECT_TYPE_POISON, oTarget))
    {
        effect ePoison =  EffectPoison (POISON_PHASE_SPIDER_VENOM);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, ePoison, OBJECT_SELF);
    }
    if (GetHasEffect (EFFECT_TYPE_DISEASE, oTarget))
    {
        effect eDisease =  EffectDisease (DISEASE_SOLDIER_SHAKES);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDisease, OBJECT_SELF);
    }
}
void main()
{
    object oTarget = GetSpellTargetObject();
    effect eBlood = EffectVisualEffect (493);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eBlood, oTarget);
    SignalEvent (oTarget, EventSpellCastAt (OBJECT_SELF, GetSpellId()));
    // Do a melee touch attack.
    if (TouchAttackMelee (oTarget, TRUE))
    {
        int nDamage = d3() + 2;
        // Ok, since the engine prevents ability score damage from the same spell to stack,
        // we are using another "quirk" in the engine to  make it stack:
        // by Delay Commanding the spell the effect looses its SpellID information and stacks...
        DelayCommand (0.01f, DoSuckBrain (oTarget, nDamage, eBlood));
    }
}
