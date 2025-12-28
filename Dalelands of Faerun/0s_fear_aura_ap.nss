/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_fear_aura_ap
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Applies the fear aura on the creature.
 Aura: Save vs Fear effect. Save is 10 + 1/2 Sorcerer level + Charisma modifier.
 Lasts for 1 round per 1/2 Sorcerer level + Charisma modifier.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

void main()
{
    // Fear aura. 10' radius, Save DC 10 + 1/2 level + char mod.
    effect eAOE = EffectAreaOfEffect (47 /* AOE_SORCERER_FEAR_AURA */);
    eAOE = SupernaturalEffect (eAOE);
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eAOE, OBJECT_SELF);
}
