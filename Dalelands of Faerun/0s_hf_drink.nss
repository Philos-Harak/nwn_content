/*////////////////////////////////////////////////
 Script Name: 0s_hf_drink
 Programmer : Philos
////////////////////////////////////////////////
Caster Level(s): Bard 6, Clr 6
Innate Level: 6
School: Conjuration (Creation)
Component(s): Verbal, Somatic, Divine Focus
Range: Short
Area of Effect / Target: Feast
Duration: 12 hours
Save: None
Spell Reisistance: No

You bring forth a great feast, including a magnificent table, chairs,
and food and drink. Every creature partaking of the feast is cured of all
diseases, sickness, and nausea; becomes immune to poison for 12 hours;
and gains 1d8 temporary hit points +1 point per two caster levels (maximum +10)
after imbibing the nectar-like beverage that is part of the feast.

The ambrosia food that is consumed grants each creature that partakes a
+1 morale bonus on attack rolls and Will saves and immunity to fear effects for
12 hours.

This is the drink script for Heroe's Feast.
/*///////////////////////////////////////////////
#include "0i_effects"

void main()
{
    object oCreature = GetLastUsedBy ();
    if (!HasEffectWithTag (oCreature, "0_Heroes_Feast_Drink"))
    {
        effect eImpact = EffectVisualEffect (VFX_IMP_HOLY_AID);
        int iHitPoints = d8() + GetLocalInt (OBJECT_SELF, "0_Heroes_Feast_HP");
        effect eTempHP = EffectTemporaryHitpoints (iHitPoints);
        effect eImmuneToPoison = EffectImmunity (IMMUNITY_TYPE_POISON);
        effect eLink = EffectLinkEffects (eTempHP, eImmuneToPoison);
        eLink = TagEffect (eLink, "0_Heroes_Feast_Drink");
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, oCreature, HoursToSeconds (12));
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oCreature);
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_DISEASE);
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_POISON);
        SendMessages ("You drink the nectar and fill quenched.", COLOR_GREEN, oCreature);
    }
    else SendMessages ("You drink the nectar, but gain no more benefits from it.", COLOR_RED, oCreature);
}
