/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_altar_damage
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script on damage for altars in quests.

 Altar of the Darksun - undead awake and respawn in area.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_items"

void main()
{
    int iRow, iLevel, iNumber, iCounter, iDamage;
    string sResRef;
    object oPC, oPaper, oWaypoint, oCreature, oPlayerBook;
    location lLocation;
    oPC = GetLastDamager ();
    // Get the paper quest from the area.
    oPaper = GetLocalObject (oPC, "0_QP_AREA");
    // Get the level of the quest.
    string sQuestArray = GetLocalString (oPaper, "0_Q_QUEST");
    iLevel = StringToInt (GetStringArray (sQuestArray, 1, "-"));
    // Check which altar this is.
    // Altar of the Darksun (Cyric)
    // Spawn undead on altar when altar is hit for the first time.
    if (GetTag (OBJECT_SELF) == "0_altar_1" && !GetLocalInt (OBJECT_SELF, "0_HIT"))
    {
        // Mark it as hit so we don't keep spawning creatures.
        SetLocalInt (OBJECT_SELF, "0_HIT", TRUE);
        // Spawn undead in area!
        // Calculate row in the 2da (each level gets 5 entries thus ((ilevel - 1) * 5) + Random (5) + 1)
        iRow = ((iLevel - 1) * 5) + Random (5) + 1;
        // Get the resref of the creature to spawn.
        sResRef = Get2DAString ("e_undead", "ResRef", iRow);
        // Get number of creatures.
        iNumber = Random (StringToInt (Get2DAString ("e_undead", "Number", iRow))) + 1;
        // Spawn creatures on the altar.
        lLocation = GetLocation (OBJECT_SELF);
        // Create all of the creatures.
        for (iCounter = iNumber; iCounter > 0; iCounter --)
        {
            oCreature = CreateObject (OBJECT_TYPE_CREATURE, sResRef, lLocation);
        }
        if (!GetIsObjectValid (oCreature)) SetModuleError ("RESREF", "0i_quest", "224", "Quest error invalid RESREF: " + sResRef);
    }
    // Altar of Pain (Loviatar)
    // Take damage when hitting the altar.
    else if (GetTag (OBJECT_SELF) == "0_altar_2")
    {
        // Deal damage to the attacker.
        iDamage = 3 * iLevel;
        effect eDamage = EffectDamage (Random (iDamage) + 1);
        effect eVisual = EffectVisualEffect (VFX_FNF_LOS_EVIL_10);
        eDamage = EffectLinkEffects (eVisual, eDamage);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDamage, oPC);
    }
    // Altar of the Claw (Malar)
    // Mark the player - Doubles random encounters and increases spawns by +1.
    else if (GetTag (OBJECT_SELF) == "0_altar_3" && !GetLocalInt (OBJECT_SELF, "0_HIT"))
    {
        // Mark it as hit so we don't keep spawning creatures.
        SetLocalInt (OBJECT_SELF, "0_HIT", TRUE);
        SendMessages ("The mark of Malar has been placed on you. Beware of the Hunter!", COLOR_RED, oPC, FALSE, FALSE);
        // Save the mark on your players book.
        oPlayerBook = GetCreatureHasItem (oPC, "players_book");
        SetLocalInt (oPlayerBook, "0_MALAR_MARK", TRUE);
    }
    // Altar of the Night (Shar)
    // Cast darkness spell on defacer.
    else if (GetTag (OBJECT_SELF) == "0_altar_4")
    {
        ActionCastSpellAtObject (SPELL_DARKNESS, oPC, METAMAGIC_ANY, TRUE);
    }
    // Altar of Destruction (Talos)
    // Does ligtning damage to attacker.
    else if (GetTag (OBJECT_SELF) == "0_altar_5")
    {
        // Deal damage to the attacker.
        iDamage = 5 * iLevel;
        effect eDamage = EffectDamage (Random (iDamage) + 1, DAMAGE_TYPE_ELECTRICAL);
        effect eVisual = EffectVisualEffect (VFX_FNF_ELECTRIC_EXPLOSION);
        eDamage = EffectLinkEffects (eVisual, eDamage);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDamage, oPC);
    }
}

