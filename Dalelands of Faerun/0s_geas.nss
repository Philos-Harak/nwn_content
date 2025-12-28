/*////////////////////////////////////////////////
 Script: 0s_geas
 Programmer: Philos
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:  Brd 6, Clr 6, Sor/Wiz 6
Components: V, S
Casting Time: 1 standard action
Range: Short
Target: One humanoid creature
Duration: 1 day/level or finished
Saving Throw: None
Spell Resistance: Yes

A geas places a magical quest upon a creature. The geased creature must follow
the given quest or until the spell expires. While on this quest the creature
takes 3d6 damage for every rest period as is sickened (-2 penalty to attack,
melee damage, saving throws and skill checks).
/*///////////////////////////////////////////////
#include "0i_spells"
#include "0i_quest"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_DOMINATE_S;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {

        }
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
