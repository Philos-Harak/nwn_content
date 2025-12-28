/*////////////////////////////////////////////////
 Script Name: NW_S0_Contagion
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy [Evil]
Level:	Clr 3, Destruction 3, Drd 3, Sor/Wiz 4
Components:	V, S
Casting Time:	1 standard action
Range:	Touch
Target:	Living creature touched
Duration:	Instantaneous
Saving Throw:	Fortitude negates
Spell Resistance:	Yes
The subject contracts a disease selected from Blidning Sickness, Cackle Fever,
Filth Fever, Mind Fire, Red Ache, the Shakes or Slimy Doom.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_EVIL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_DISEASE;
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
    // Roll for disease.
    int iRoll = Random (7) + 1;
    int iDisease;
    switch (iRoll)
    {
        case 1: iDisease = DISEASE_BLINDING_SICKNESS; break;
        case 2: iDisease = DISEASE_CACKLE_FEVER;      break;
        case 3: iDisease = DISEASE_FILTH_FEVER;       break;
        case 4: iDisease = DISEASE_MINDFIRE;          break;
        case 5: iDisease = DISEASE_RED_ACHE;          break;
        case 6: iDisease = DISEASE_SHAKES;            break;
        case 7: iDisease = DISEASE_SLIMY_DOOM;        break;
    }
    // Create effect.
    effect eDisease = EffectDisease (iDisease);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //The effect is permament because the disease subsystem has its own internal resolution
            //system in place.
            ApplyEffectToObject(Spell.iDurationType, eDisease, Spell.oAreaTarget);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

