/*////////////////////////////////////////////////
 Script: NW_S0_BladeBarA.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Force]
Level:  Clr 6, Good 6, War 6
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Wall of whirling blades up to 20 ft
Duration:   1 min./level (D)
Saving Throw:   Reflex half or Reflex negates; see text
Spell Resistance:   Yes

An immobile, vertical curtain of whirling blades shaped of pure force springs
into existence. Any creature passing through the wall takes 1d6 points of damage
per caster level (maximum 15d6), with a Reflex save for half damage.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject ();
    object oCaster = GetAreaOfEffectCreator ();
    effect eDmg;
    effect eVisual = EffectVisualEffect (VFX_COM_BLOOD_LRG_RED);
    int iMetaMagic = GetMetaMagicFeat ();
    int iLevel = GetCasterLevel (oCaster);
    //Make level check
    if (iLevel > 15) iLevel = 15;
    if (IsSpellTargetValid (oTarget, TARGET_TYPE_ALL, oCaster))
    {
        //Fire spell cast at event
        SignalEvent (oTarget, EventSpellCastAt(oCaster, SPELL_BLADE_BARRIER));
        //Roll Damage
        int iDamage = d6 (iLevel);
        //Enter Metamagic conditions
        if (iMetaMagic == METAMAGIC_MAXIMIZE) iDamage = iLevel * 6;
        else if (iMetaMagic == METAMAGIC_EMPOWER) iDamage = iDamage + (iDamage / 2);
        //Make SR Check
        if (!ResistSpell (oCaster, oTarget))
        {
            //Adjust damage according to Reflex Save, Evasion or Improved Evasion
            iDamage = GetReflexAdjustedDamage (iDamage, oTarget, GetSpellSaveDC ());
            //Set damage effect
            eDmg = EffectDamage (iDamage, DAMAGE_TYPE_SLASHING);
            //Apply damage and VFX
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, oTarget);
        }
    }
}

