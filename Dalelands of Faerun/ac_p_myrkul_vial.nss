//////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: ac_p_myrkul_vial
/*////////////////////////////////////////////////////////////////////////////////////////////////////

 Activate item script for Myrkul's Vial of death.

 When a player drinks this it has random effects.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Made By: Philos
// Made On: 3/25/15
//////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_effects"

void main()
{
    int nRoll = d6();
    string sText;
    object oUser = OBJECT_SELF;
    effect eEffect;
    //Debug("ac_p_myrkul_vial", "23", "oUser: " + GetName(oUser) + " nRoll: " + IntToString(nRoll));
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    switch(nRoll)
    {
        // Immune to critical hits!
        case 1:
        {
            eEffect = EffectImmunity(IMMUNITY_TYPE_CRITICAL_HIT);
            effect eEffect2 = EffectImmunity(IMMUNITY_TYPE_SNEAK_ATTACK);
            eEffect = EffectLinkEffects(eEffect2, eEffect);
            eEffect = EffectLinkEffects (eDuration, eEffect);
            sText = "Your organs shut down and cease to function. Critical hits " +
                    "and Sneak attacks have no effect on them!";
            break;
        }
        case 2:
        {
            eEffect = EffectImmunity(IMMUNITY_TYPE_CONFUSED);
            effect eEffect2 = EffectImmunity(IMMUNITY_TYPE_CHARM);
            effect eEffect3 = EffectImmunity(IMMUNITY_TYPE_DAZED);
            effect eEffect4 = EffectImmunity(IMMUNITY_TYPE_DOMINATE);
            effect eEffect5 = EffectImmunity(IMMUNITY_TYPE_FEAR);
            effect eEffect6 = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
            effect eEffect7 = EffectImmunity(IMMUNITY_TYPE_PARALYSIS);
            eEffect = EffectLinkEffects(eEffect2, eEffect);
            eEffect = EffectLinkEffects(eEffect3, eEffect);
            eEffect = EffectLinkEffects(eEffect4, eEffect);
            eEffect = EffectLinkEffects(eEffect5, eEffect);
            eEffect = EffectLinkEffects(eEffect6, eEffect);
            eEffect = EffectLinkEffects(eEffect7, eEffect);
            eEffect = EffectLinkEffects (eDuration, eEffect);
            sText = "You feel numb as if your brain has a haze upon it. Mental " +
                    "attacks have no effect on you!";
            break;
        }
        case 3:
        {
            eEffect = EffectImmunity(IMMUNITY_TYPE_DISEASE);
            effect eEffect2 = EffectImmunity(IMMUNITY_TYPE_POISON);
            effect eEffect3 = EffectImmunity(IMMUNITY_TYPE_DEATH);
            eEffect = EffectLinkEffects(eEffect2, eEffect);
            eEffect = EffectLinkEffects(eEffect3, eEffect);
            eEffect = EffectLinkEffects (eDuration, eEffect);
            sText = "You feel stoic as a calmness flows through you, your vitals " +
                    "slow down and you can't feel them! Disease, poison, and death have no meaning to you!";
            break;
        }
        case 4:
        {
            eEffect = EffectImmunity(IMMUNITY_TYPE_ABILITY_DECREASE);
            effect eEffect2 = EffectImmunity(IMMUNITY_TYPE_BLINDNESS);
            effect eEffect3 = EffectImmunity(IMMUNITY_TYPE_SLOW);
            eEffect = EffectLinkEffects(eEffect2, eEffect);
            eEffect = EffectLinkEffects(eEffect3, eEffect);
            eEffect = EffectLinkEffects (eDuration, eEffect);
            sText = "You muscles stiffen as you feel distant to the world. " +
                    "your body hardens against outside effects to your senses!";
            break;
        }
        case 5:
        {
            eEffect = EffectAbilityIncrease(ABILITY_STRENGTH, 6);
            effect eEffect2 = EffectAbilityIncrease(ABILITY_DEXTERITY, 6);
            effect eEffect3 = EffectAbilityIncrease(ABILITY_CONSTITUTION, 6);
            eEffect = EffectLinkEffects(eEffect2, eEffect);
            eEffect = EffectLinkEffects(eEffect3, eEffect);
            eEffect = EffectLinkEffects (eDuration, eEffect);
            sText = "Your body rushes with power. You feel stronger, quicker, " +
                    "and heartier!";
            break;
        }
        case 6:
        {
            eEffect = EffectAbilityIncrease(ABILITY_INTELLIGENCE, 6);
            effect eEffect2 = EffectAbilityIncrease(ABILITY_WISDOM, 6);
            effect eEffect3 = EffectAbilityIncrease(ABILITY_CHARISMA, 6);
            eEffect = EffectLinkEffects(eEffect2, eEffect);
            eEffect = EffectLinkEffects(eEffect3, eEffect);
            eEffect = EffectLinkEffects (eDuration, eEffect);
            sText = "Your mind rushes with power. You feel smarter, wiser, " +
                    "and more forceful!";
            break;
        }
    }
    eEffect = TagEffect(eEffect, "Vial of Rot");
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oUser, HoursToSeconds(24));
    SendMessages(sText, COLOR_YELLOW, oUser);
    nRoll = d6();
    if(nRoll < 3) ActionPlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 3.0);
    else if(nRoll < 5) ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 3.0);
    else ActionPlayAnimation(ANIMATION_LOOPING_SPASM, 1.0, 6.0);
}
