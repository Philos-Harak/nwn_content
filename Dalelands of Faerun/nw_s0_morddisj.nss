/*////////////////////////////////////////////////
 Script: NW_S0_MordDisj.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Magic 9, Sor/Wiz 9
Components: V
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Area:   All magical effects and magic items within a 40-ft.-radius burst
Duration:   Instantaneous
Saving Throw:   Will negates (object)
Spell Resistance:   No

All magical effects within the radius of the spell are disjoined, they are
dispelled as your caster level.
You may also target a permanent magic item that gets a saving throw.
The caster must make a check + the caster level + ability modifer to be able to
turn a magic item into a normal item.
Quality of the item defines the DC, MasterWork DC:30, Exquisite DC:35,
Relic DC:40, Legendary DC:45, Artifact DC:50.

Even artifacts are subject to disjunction, though there is only a 1% chance per
caster level of actually affecting such powerful items. Additionally, if an
artifact is destroyed, you must make a DC 25 Will save or permanently lose all
known spells.

NOTE: To make creatures immune to dispell set 0_IMMUNE_TO_DISPEL = true on the creature.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "0i_magicitems"

void ItemDisjunction (struct stSpell Spell);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sEnhancingComp = "nune_dust";
    Spell.iCompAmount = 4; // 100gp worth of Nune Dust.
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 40.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iImpact = VFX_IMP_HEAD_ODD;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eCenter = EffectVisualEffect (VFX_FNF_DISPEL_DISJUNCTION);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Did they target an item to destroy?
    if (GetObjectType (Spell.oTarget) == OBJECT_TYPE_ITEM)
    {
        ItemDisjunction (Spell);
    }
    else
    {
        int nCasterLevel = Spell.iCasterLevel;
        if(Spell.sEnhancingComp == "TRUE") nCasterLevel += 2;;
        // Apply visual effect at the center of the effect area.
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
        while (GetIsObjectValid(Spell.oAreaTarget))
        {
            // Check for area of effect spells.
            if (GetObjectType (Spell.oAreaTarget) == OBJECT_TYPE_AREA_OF_EFFECT)
            {
                DelayCommand (Spell.fDelay, DispelAoEEffect (Spell.oAreaTarget, Spell.oCaster, nCasterLevel));
            }
            // Check for placeables.
            else if (GetObjectType (Spell.oAreaTarget) == OBJECT_TYPE_PLACEABLE)
            {
                DelayCommand (Spell.fDelay, SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID)));
            }
            // Do creatures.
            else
            {
                DelayCommand (Spell.fDelay, DispelMagicEffect (Spell.oAreaTarget, nCasterLevel, eImpact, eCenter, TRUE, TRUE));
                DelayCommand (Spell.fDelay, CheckSpellEffectsForRemoval (Spell.oAreaTarget));
            }
            //Get the spells target(s).
            Spell = GetSpellTarget (Spell);
        }
    }
    CleanUpSpell (Spell);
}

void ItemDisjunction (struct stSpell Spell)
{
    int iRoll, iCasterBonus, iItemDC, iRemove, iQuality;
    string sMessage;
    itemproperty ipProperty;
    ipProperty = GetFirstItemProperty (Spell.oTarget);
    while (GetIsItemPropertyValid (ipProperty))
    {
        if (GetItemPropertyType (ipProperty) == 86/*Quality*/)
        {
            iQuality = GetItemPropertyCostTableValue (ipProperty);
            break;
        }
        else ipProperty = (GetNextItemProperty (Spell.oTarget));
    }
    // Give the magic item a save.
    iRoll = d20();
    iCasterBonus = Spell.iCasterLevel + GetCasterAbilityModifier (Spell.oCaster);
    if(Spell.sEnhancingComp == "TRUE") iCasterBonus += 2;;
    switch (iQuality)
    {
        case 1: iItemDC = 30; break; // Masterwork
        case 2: iItemDC = 35; break; // Exquisite
        case 3: iItemDC = 40; break; // Relic
        case 4: iItemDC = 45; break; // Legendary
        case 5: iItemDC = 50; break; // Artifact
    }
    if (iRoll + iCasterBonus >= iItemDC)
    {
        // Send save message *successful*.
        sMessage = AddColorToText ("Mordenkainen's Disjunction", COLOR_MAGENTA) +
                   AddColorToText (" dispel check vs " + GetName (Spell.oTarget) + " : *successful* : (" +
                                IntToString (iRoll) + " + " + IntToString (iCasterBonus) +
                                " = " + IntToString (iRoll + iCasterBonus) + " vs DC: " +
                                IntToString (iItemDC) + ")", COLOR_ORANGE);
        SendMessageToPC (Spell.oCaster, sMessage);
        // Check for an artifact Quality(86) and Artifact(5).
        if (iQuality == 5/*Artifact*/)
        {
            // Caster destroyed an artifact and failed the will save!
            if (!WillSave (Spell.oCaster, 25))
            {
                int iSpell, iSpellCount, iSpellLevel, iIndex;
                SendMessages ("You failed your Will save! Your magic has been taken with the magic items!", COLOR_RED, Spell.oCaster);
                for (iSpellLevel = 0; iSpellLevel > 9; iSpellLevel++)
                {
                    iSpellCount = GetKnownSpellCount (Spell.oCaster, Spell.iClass, iSpellLevel);
                    for (iIndex = iSpellCount; iIndex == 0; iIndex--)
                    {
                        iSpell = GetKnownSpellId (Spell.oCaster, Spell.iClass, iSpellLevel, iIndex);
                        NWNX_Creature_RemoveKnownSpell (Spell.oCaster, Spell.iClass, iSpellLevel, iSpell);
                    }
                }
            }
        }
        // Remove all magical properties, but not the quality.
        RemoveAllItemProperties (Spell.oTarget, DURATION_TYPE_PERMANENT);
        SendMessages ("You removed the magic from " + GetName (Spell.oTarget) + "!", COLOR_GREEN, Spell.oCaster);
        SetName (Spell.oTarget, "");
    }
    else
    {
        // Send save message *failure*
        sMessage = AddColorToText ("Mordenkainen's Disjunction", COLOR_MAGENTA) +
               AddColorToText (" dispel check vs " + GetName (Spell.oTarget) + " : *failure* : (" +
                                IntToString (iRoll) + " + " + IntToString (iCasterBonus) +
                                " = " + IntToString (iRoll + iCasterBonus) + " vs DC: " +
                                IntToString (iItemDC) + ")", COLOR_ORANGE);
        SendMessageToPC (Spell.oCaster, sMessage);
    }
}
