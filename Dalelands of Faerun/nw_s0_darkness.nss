/*////////////////////////////////////////////////
 Script: NW_S0_Darkness
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Darkness]
Level:  Brd 2, Clr 2, Sor/Wiz 2
Components: V, M/DF
Casting Time:   1 standard action
Range:  Touch
Target: Object touched
Duration: 2 min./level (D)
Saving Throw:   None
Spell Resistance:   No

This spell causes an object to radiate shadowy illumination out to a 20-foot
radius. All creatures in the area gain concealment (20% miss chance). Even
creatures that can normally see in such conditions (such as with darkvision or
low-light vision) have the miss chance in an area shrouded in magical darkness.

Material Component: A bit of bat fur and either a drop of pitch or a piece of coal.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // First check to see if they are using the Darkness Domain.
    if (GetLastSpell () == 965/*SPELL_DARKNESS_DOMAIN*/)
    {
        // Check to make sure they have the correct god to Cast this spell.
        int nDeity, bHasDomain;
        if(GetIsCharacter(Spell.oCaster))
        {
            nDeity = GetObjectDatabaseInt (Spell.oCaster, CHARACTER_TABLE, "deity");
            bHasDomain = StringToInt (Get2DAString ("deities", "Chaos_Domain", nDeity));
        }
        else bHasDomain = TRUE;
        if (!bHasDomain)
        {
            SendMessages ("Your god does not have Darkness as a domain. The spell fizzles out!", COLOR_RED, Spell.oCaster);
            return;
        }
    }
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_DARKNESS;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 2;
    Spell.iDurPerLvl = 2;
    Spell.iImpact = VFX_IMP_FLAME_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Check to make sure we don't overlap area of effect spells.
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_DARKNESS))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Darkness spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        effect eAOE = EffectAreaOfEffect (AOE_PER_DARKNESS);
        //Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}
