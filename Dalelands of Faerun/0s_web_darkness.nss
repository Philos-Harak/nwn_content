/*////////////////////////////////////////////////
 Script: 0s_web_darkness
////////////////////////////////////////////////
Conjuration (Creation)
Level: Drow domain 1
Components: V, S
Casting Time: 1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Webs in a 20-ft.-radius spread
Duration: 1 round / level (D)
Saving Throw: Reflex negates; see text
Spell Resistance: Yes

Web creates a many-layered mass of strong, sticky strands made of negative energy.
These strands trap those caught in them. The strands are similar to spider webs
but far larger and tougher. Creatures caught within a web become entangled among
the gluey fibers. Attacking a creature in a web won’t cause you to become entangled.

Anyone in the effect’s area when the spell is cast must make a Reflex save.
If this save succeeds, the creature is entangled, but not prevented from moving,
though moving is more difficult than normal for being entangled (see below).
If the save fails, the creature is entangled and can’t move from its space,
but can break loose by spending 1 round and making a DC 20 Strength check or a
DC 25 Escape Artist check. Once loose (either by making the initial Reflex save
or a later Strength check or Escape Artist check), a creature remains entangled,
but may move through the web very slowly. Each round devoted to moving allows the
creature to make a new Strength check or Escape Artist check.
While within the webs a create takes d6 + 1 point of damage per caster level in
negative energy damage.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
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
    if (!AOESpellOverlaps (Spell.lTarget, 51/*AOE_PER_WEB_OF_DARKNESS*/))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Web of Darkness spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (51/*AOE_PER_WEB_OF_DARKNESS*/);
        //Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (DURATION_TYPE_TEMPORARY, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

