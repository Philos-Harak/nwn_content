/*////////////////////////////////////////////////
 Script: NW_S0_Identify
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Divination
Level:  Brd 1, Magic 2, Sor/Wiz 1
Components: V, S, M/DF
Casting Time:   1 hour
Range:  Touch
Targets: Personal
Duration: Instantaneous
Saving Throw:   None
Spell Resistance:   No

The spell determines all magic properties of all magic items, including how
to activate those functions (if appropriate), and how many charges are left (if any) on the caster.

Identify does not function when used on any relics or artifacts.

Material Component: A pearl of at least 100 gp value, crushed into dust and
stirred into wine with an owl feather; the infusion must be drunk prior to spellcasting.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = "pearl_dust";
    Spell.iCompAmount = 4; // 100gp worth of Pearl Dust.
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iImpact = VFX_IMP_MAGICAL_VISION;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    object oItem;
    itemproperty ipQuality;
    int bIdentify;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Apply linked and VFX effects
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
        // Identify all items that are of legendary quality or less.
        oItem = GetFirstItemInInventory (Spell.oAreaTarget);
        while (GetIsObjectValid (oItem))
        {
            if (!GetIdentified (oItem))
            {
                bIdentify = FALSE;
                // Check items properties.
                // if Relic.
                if (GetIsItemPropertyValid (HasProperty (oItem, 86, 4))) bIdentify = FALSE;
                // if Artifact.
                else if (GetIsItemPropertyValid (HasProperty (oItem, 86, 5))) bIdentify = FALSE;
                else bIdentify = TRUE;
                SetIdentified (oItem, bIdentify);
            }
            oItem = GetNextItemInInventory (Spell.oAreaTarget);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
