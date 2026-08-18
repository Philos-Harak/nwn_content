/*////////////////////////////////////////////////
 Script: NW_S0_CrUndead.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy [Evil]
Level:  Clr 6, Death 6, Evil 6, Sor/Wiz 6
Components: V, S, M
Casting Time:   1 hour
Range:  Close (25 ft. + 5 ft./2 levels)
Target: One corpse
Duration:   Instantaneous
Saving Throw:   None
Spell Resistance:   No
A much more potent spell than animate dead, this evil spell allows you to create
more powerful sorts of undead: ghouls, ghasts, mummies, and mohrgs. The type or
types of undead you can create is based on your caster level, as shown on the
table below.

You may create less powerful undead than your level would allow if you choose.

Material Component
A clay pot filled with grave dirt and another filled with brackish water.
You must place 50gp worth of black onyx gems per HD of the undead to be created
into the mouth or eye socket of the corpse.
The magic of the spell turns these gems into worthless shells.

11th or lower  Ghoul
12th-14th      Ghast
15th-17th      Mummy
18th or higher Mohrg
/*///////////////////////////////////////////////
#include "0i_items"
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_EVIL;
    Spell.sArcaneComponent = "onyx";
    Spell.sDivineComponent = "onyx";
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nEnhancedAC;
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nStack;
        int nMoonbarDust;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nMoonbarDust && GetTag(oItem) == "moonbar_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nMoonbarDust = TRUE;
                    nEnhancedAC += 2;    
                }
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nEnhancedAC)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase the natural AC by +" + IntToString(nEnhancedAC) + "!", COLOR_GREEN, oObject);
        }
    }
    // Get the casters summons selected summons or select a default.
    // Casters can select a summons via the Players Handbook.
    int iNumToSummon = 1, iCounter;
    int iCasterLevel = GetCasterLevel (OBJECT_SELF);
    int iSpellID = GetSpellId ();
    string sResRef, sSummonArray;
    if (GetIsCharacter (OBJECT_SELF)) sSummonArray = GetObjectDatabaseString (OBJECT_SELF, CHARACTER_TABLE, "summons");
    object oCreature;
    if (iSpellID == SPELL_CREATE_UNDEAD)
    {
        sResRef = GetStringArray (sSummonArray, 10);
        if (sResRef == "")
        {
            if (iCasterLevel < 12) sResRef = "ghoul";
            else if (iCasterLevel < 15) sResRef = "ghast";
            else if (iCasterLevel < 18) sResRef = "mummy";
            else sResRef = "mohrg";
        }
    }
    else if (iSpellID == SPELL_CREATE_GREATER_UNDEAD)
    {
        sResRef = GetStringArray (sSummonArray, 11);
        if (sResRef == "")
        {
            if (iCasterLevel < 16) sResRef = "m_vampire";
            else if (iCasterLevel < 18) sResRef = "NW_S_DOOMKGHT";
            else if (iCasterLevel < 20) sResRef = "NW_S_LICH";
            else sResRef = "NW_S_MUMCLERIC";
        }
    }
    // Select the varied component cost based on undead to summon.
    // 1 onyx gem is equal to 50gp value we need 1 or 50gp per HD of the undead.
    if (sResRef == "ghoul") Spell.iCompAmount = 2; // HD 2
    else if (sResRef == "ghast") Spell.iCompAmount = 4; // HD 4
    else if (sResRef == "mummy") Spell.iCompAmount = 8; // HD 8
    else if (sResRef == "mohrg") Spell.iCompAmount = 14; // HD 14
    else if (sResRef == "m_vampire") Spell.iCompAmount = 5; // HD 5
    else if (sResRef == "NW_S_DOOMKGHT") Spell.iCompAmount = 9; // HD 9
    else if (sResRef == "NW_S_LICH") Spell.iCompAmount = 12; // HD 12
    else if (sResRef == "NW_S_MUMCLERIC") Spell.iCompAmount = 16; // HD 16
    effect eImpact = EffectVisualEffect (VFX_FNF_SUMMON_UNDEAD);
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    int nTotalHD = GetTotalUndeadControlledHitDice(Spell.oCaster);
    // Check to see if we have multiple summons via feats, class abilities etc.
    // Should we be summoning anymore?
    if (iNumToSummon > 0)
    {
        // Loop through and summon them all.
        for (iCounter = iNumToSummon; iCounter > 0; iCounter --)
        {
            // Create the undead.
            oCreature = CreateObject (OBJECT_TYPE_CREATURE, sResRef, Spell.lTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCreature);
            if(nEnhancedAC) ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectACIncrease(nEnhancedAC, AC_NATURAL_BONUS), oCreature);
            if(IncreaseUndeadControlledHitDice(Spell.oCaster, oCreature, "TURNED_UNDEAD", nTotalHD))
            {
                AddHenchman (Spell.oCaster, oCreature);
                // Must mark them as a summons.
                SetLocalInt (oCreature, "0_Summon_ID", TRUE);
                SetLocalString(oCreature, "0_SUMMON_SPELL", "TURNED_UNDEAD");
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
                MyrkulSetCheck(Spell.oCaster, oCreature);
            }
            else ChangeToStandardFaction(oCreature, STANDARD_FACTION_DEFENDER);
        }
    }
    CleanUpSpell (Spell);
}


