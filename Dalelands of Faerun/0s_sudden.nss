/*////////////////////////////////////////////////
// Sudden feats (Empower, Widen, Maximize, & Extend
// Created By: Philos
////////////////////////////////////////////////
    Fires all Sudden feat scripts.

    Sets a variable that is checked in a spell to automatically use
    the sudden feat. Then it is removed.
/*///////////////////////////////////////////////
#include "0i_master"

void main()
{
    int nSpellID = GetSpellId();
    object oCaster = OBJECT_SELF;
    object oMaster = GetPlayerMaster(oCaster);
    switch(nSpellID)
    {
        // Sudden Empower.
        case 971:
        {
            if(GetLocalInt(oCaster, "0_SUDDEN_EMPOWER"))
            {
                if(oMaster == oCaster) SendMessages("You will no longer Empower your spells!", COLOR_RED, oCaster);
                else SendMessages(GetName(oCaster) + " will no longer Empower their spells!", COLOR_RED, oMaster);
                DeleteLocalInt(oCaster, "0_SUDDEN_EMPOWER");
            }
            else
            {
                if(oMaster == oCaster) SendMessages("You are prepaired to Empower your spells!", COLOR_GREEN, oCaster);
                else SendMessages(GetName(oCaster) + " is prepaired to Empower their spells!", COLOR_GREEN, oMaster);
                SetLocalInt(oCaster, "0_SUDDEN_EMPOWER", TRUE);
            }
            break;
        }
        // Sudden Widen.
        case 972:
        {
            if(GetLocalInt(oCaster, "0_SUDDEN_WIDEN"))
            {
                if(oMaster == oCaster) SendMessages("You will no longer Widen your spells!", COLOR_RED, oCaster);
                else SendMessages(GetName(oCaster) + " will no longer Widen their spells!", COLOR_RED, oMaster);
                DeleteLocalInt(oCaster, "0_SUDDEN_WIDEN");
            }
            else
            {
                if(oMaster == oCaster) SendMessages("You are prepaired to Widen your spells!", COLOR_GREEN, oCaster);
                else SendMessages(GetName(oCaster) + " is prepaired to Widen their spells!", COLOR_GREEN, oMaster);
                SetLocalInt (oCaster, "0_SUDDEN_WIDEN", TRUE);
            }
            break;
        }
        // Sudden Maximize.
        case 973:
        {
            if(GetLocalInt(oCaster, "0_SUDDEN_MAXIMIZE"))
            {
                if(oMaster == oCaster) SendMessages("You will no longer Maximize your spells!", COLOR_RED, oCaster);
                else SendMessages(GetName(oCaster) + " will no longer Maximize their spells!", COLOR_RED, oMaster);
                DeleteLocalInt(oCaster, "0_SUDDEN_MAXIMIZE");
            }
            else
            {
                if(oMaster == oCaster) SendMessages("You are prepaired to Maximize your spells!", COLOR_GREEN, oCaster);
                else SendMessages(GetName(oCaster) + " is prepaired to Maximize their spells!", COLOR_GREEN, oMaster);
                SetLocalInt (oCaster, "0_SUDDEN_MAXIMIZE", TRUE);
            }
            break;
        }
        // Sudden Extend.
        case 974:
        {
            if(GetLocalInt(oCaster, "0_SUDDEN_EXTEND"))
            {
                if(oMaster == oCaster) SendMessages("You will no longer Extend your spells!", COLOR_RED, oCaster);
                else SendMessages(GetName(oCaster) + " will no longer Extend their spells!", COLOR_RED, oMaster);
                DeleteLocalInt(oCaster, "0_SUDDEN_EXTEND");
            }
            else
            {
                if(oMaster == oCaster) SendMessages("You are prepaired to Extend your spells!", COLOR_GREEN, oCaster);
                else SendMessages(GetName(oCaster) + " is prepaired to Extend their spells!", COLOR_GREEN, oMaster);
                SetLocalInt (oCaster, "0_SUDDEN_EXTEND", TRUE);
            }
            break;
        }
    }
    int nFeat = StringToInt(Get2DAString("spells", "FeatID", nSpellID));
    IncrementRemainingFeatUses(oCaster, nFeat);
}

