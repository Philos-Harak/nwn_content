/*//////////////////////////////////////////////////////////////////////////////
 Summon Undead
 X2_S2_SumUndead
 Created By: Andrew Nobbs updated by Philos
////////////////////////////////////////////////////////////////////////////////
 The level of the Pale Master determines the type of undead that is summoned.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_specialevents"
#include "0i_spells"
void main()
{
    object oCaster = OBJECT_SELF;
    // Get the Pale Master's highest level arcane class to add those levels.
    int nClass = GetHighestArcaneCasterClass(OBJECT_SELF, CLASS_TYPE_PALE_MASTER);
    int nCasterLevel = GetCasterLevelByClass(oCaster, nClass);
    nCasterLevel += GetLevelByClass(CLASS_TYPE_PALE_MASTER, OBJECT_SELF);
    string sResRef;
    object oCreature;
    location lLocation = GetSpellTargetLocation();
    effect eImpact, eTurnResistance;
    //Summon the appropriate creature based on the summoner level
    if(nCasterLevel <= 5) { sResRef = "NW_S_GHOUL"; eImpact = EffectVisualEffect(VFX_IMP_HARM); }
    else if(nCasterLevel == 6) { sResRef = "NW_S_SHADOW"; eImpact = EffectVisualEffect(VFX_IMP_HARM); }
    else if(nCasterLevel == 7) { sResRef = "NW_S_GHAST"; eImpact = EffectVisualEffect(VFX_IMP_HARM); }
    else if(nCasterLevel == 8) { sResRef = "NW_S_WIGHT"; eImpact = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD); }
    else if(nCasterLevel >= 9) { sResRef = "X2_S_WRAITH"; eImpact = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD); }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_EVIL_10), lLocation);
    // Loop through and summon two undead.
    int nCounter;
    for (nCounter = 1; nCounter < 3 ; nCounter++)
    {
        // Create the undead.
        oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCreature);
        // Increase the Turning Resistance.
        int nTurnResistance = GetTurnResistanceHD(oCreature);
        if(nTurnResistance > 0)
        {
            RemoveASpecificEffect(oCreature, EFFECT_TYPE_TURN_RESISTANCE_INCREASE);
        }
        eTurnResistance = EffectTurnResistanceIncrease(nTurnResistance + 4);
        eTurnResistance = UnyieldingEffect(eTurnResistance);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eTurnResistance, oCreature);
        AddHenchman(oCaster, oCreature);
        // Must mark them as a summons.
        SetLocalInt (oCreature, "0_Summon_ID", 624);
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_ch_ace");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_ch_ac3");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_ch_ac4");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_ch_ac5");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "nw_ch_ac7");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_ch_ac8");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_ch_ac2");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_ch_ac5");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_ch_ac9");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "nw_ch_acani9");
        SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_ch_acb");
        NWNX_Object_SetDialogResref(oCreature, "co_henchmen");
        MyrkulSetCheck(oCaster, oCreature);
    }
}
