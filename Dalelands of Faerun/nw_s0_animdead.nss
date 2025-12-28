/*////////////////////////////////////////////////
 Script Name: NW_S0_AnimDead
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Cleric 3, Wizard / Sorcerer 5
Innate Level: 3
School: Necromancy
Descriptor(s): Evil
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Point
Duration: Instant
Save: None
Spell Resistance: No

Animate Dead summons forth an undead army of skeletons and zombies from the
ground where the caster desires.
These mindless undead will attack your nearby enemies, but will not follow the
caster around or goto any other areas.
The army will be created from a number of hit dice that is double the caster's
level. Any skeletons summoned will have 1 hit dice and zombies will have 2 hit dice.
Once a caster reaches 11th level they will summon stronger undead in the form
of skeletal veterans with 2 hit dice and zombie veterans with 4 hit dice.
They remain animated until they are destroyed.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "0i_master"
#include "0i_position"
void AddAnimateDeadToParty(object oCaster, object oCreature, int nTotalHD);
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_EVIL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    // Need to get caster level so we can calculate the gem amount.
    // Uses 25gp worth of onyx gems per Hit Dice. 2 HD per caster level.
    Spell.oCaster = OBJECT_SELF;
    // Pale Master Animate dead feat.
    if(GetSpellId() == 623) Spell.iClass = CLASS_TYPE_PALE_MASTER;
    else Spell.iClass = GetLastSpellCastClass();
    Spell = GetCasterTotalLevel(Spell);
    // We add +25 to the value so 1/2's are taken as well.
    int nComponentAmount = Spell.iCasterLevel * 25 + 25;
    Spell.sArcaneComponent = "onyx";
    Spell.sDivineComponent = "onyx";
    Spell.iCompAmount = nComponentAmount;
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if(Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    string sSkeleton, sZombie;
    float fDistance;
    effect eSummon = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
    effect eCenter = EffectVisualEffect(VFX_FNF_LOS_EVIL_20);
    object oCreature, oArea = GetArea(Spell.oCaster);
    object oMaster = GetPlayerMaster(Spell.oCaster);
    object oPoint = Spell.oTarget;
    int nCasterLevel = Spell.iCasterLevel * 2;
    int bFirstCreature, nTotalHD = Spell.iCasterLevel * 2;
    // Create evil effect in area.
    DelayCommand(0.5f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eCenter, Spell.lTarget));
    while(nCasterLevel > 0)
    {
        if(nCasterLevel > 4)
        {
            if(d100() > 50)
            {
                oCreature = CreateObject(OBJECT_TYPE_CREATURE, "a2_skeleton", Spell.lTarget);
                if(GetIsCharacter(Spell.oCaster)) AddAnimateDeadToParty(Spell.oCaster, oCreature, nTotalHD);
                nCasterLevel -= 2;
            }
            else
            {
                oCreature = CreateObject(OBJECT_TYPE_CREATURE, "a2_zombie", Spell.lTarget);
                if(GetIsCharacter(Spell.oCaster)) AddAnimateDeadToParty(Spell.oCaster, oCreature, nTotalHD);
                nCasterLevel -= 4;
            }
        }
        else
        {
            if(nCasterLevel == 1 || d100() > 50)
            {
                oCreature = CreateObject(OBJECT_TYPE_CREATURE, "a_skeleton", Spell.lTarget);
                if(GetIsCharacter(Spell.oCaster)) AddAnimateDeadToParty(Spell.oCaster, oCreature, nTotalHD);
                nCasterLevel -= 1;
            }
            else
            {
                oCreature = CreateObject(OBJECT_TYPE_CREATURE, "a_zombie", Spell.lTarget);
                if(GetIsCharacter(Spell.oCaster)) AddAnimateDeadToParty(Spell.oCaster, oCreature, nTotalHD);
                nCasterLevel -= 2;
            }
        }
        // If cast by an NPC make sure they are the correct faction.
        if(!GetIsCharacter(Spell.oCaster))
        {
            int nFaction = NWNX_Creature_GetFaction(Spell.oCaster) - 1;
            ChangeToStandardFaction(oCreature, nFaction);
        }
        // Apply the creatures summon effect.
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eSummon, GetLocation(oCreature));
        // Change the location of the next summoned undead.
        fDistance = IntToFloat(d4());
        if(!bFirstCreature && oPoint == OBJECT_INVALID)
        {
            bFirstCreature = TRUE;
            oPoint = oCreature;
        }
        Spell.lTarget = GetRandomLocation(oArea, oPoint, fDistance);
    }
    CleanUpSpell (Spell);
}
void AddAnimateDeadToParty(object oCaster, object oCreature, int nTotalHD)
{
    if(IncreaseUndeadControlledHitDice(oCaster, oCreature, "ANIMATE_DEAD", nTotalHD))
    {
        // Save to creature so we know the variable to adjust for controlled undead.
        SetLocalString(oCreature, "0_SUMMON_SPELL", "ANIMATE_DEAD");
        AddHenchman(oCaster, oCreature);
        MyrkulSetCheck(oCaster, oCreature);
    }
    else ChangeToStandardFaction(oCreature, STANDARD_FACTION_DEFENDER);
    // Must mark them as a summons.
    SetLocalInt (oCreature, "0_Summon_ID", Spell.iSpellID);
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
}

