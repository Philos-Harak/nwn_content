/*////////////////////////////////////////////////
// Bood feats (Blood Component, Blood Magic
// Created By: Philos
////////////////////////////////////////////////
    Fires all Bood feat scripts.

    Sets a variable that is checked in a spell to use the Blood feat.
/*///////////////////////////////////////////////
#include "0i_master"

void main()
{
    int nSpellID = GetSpellId ();
    object oCaster = OBJECT_SELF;
    object oMaster = GetPlayerMaster(oCaster);
    switch (nSpellID)
    {
        // Blood Component.
        case 981:
        {
            if(GetLocalInt(oCaster, "0_BLOOD_COMPONENT"))
            {
                if(oMaster == oCaster) SendMessages("You will no longer use your blood as a component in your spells!", COLOR_RED, oCaster);
                else SendMessages(GetName(oCaster) + " will no longer use their blood as a component in their spells!", COLOR_RED, oMaster);
                DeleteLocalInt(oCaster, "0_BLOOD_COMPONENT");
            }
            else
            {
                if(oMaster == oCaster) SendMessages("You will now use your blood as a component in your spells!", COLOR_GREEN, oCaster);
                else SendMessages(GetName(oCaster) + " will now use their blood as a component in their spells!", COLOR_GREEN, oMaster);
                SetLocalInt (oCaster, "0_BLOOD_COMPONENT", TRUE);
            }
            break;
        }
        // Blood Magic.
        case 982:
        {
            if(GetLocalInt(oCaster, "0_BLOOD_MAGIC"))
            {
                if(oMaster == oCaster) SendMessages("You will no longer use your blood to maintain your spells!", COLOR_RED, oCaster);
                else SendMessages(GetName(oCaster) + " will no longer use their blood to maintain their spells!", COLOR_RED, oMaster);
                DeleteLocalInt(oCaster, "0_BLOOD_MAGIC");
            }
            else
            {
                if(oMaster == oCaster) SendMessages("You will now use your blood to maintain your spells!", COLOR_GREEN, oCaster);
                else SendMessages(GetName(oCaster) + " will now use their blood to maintain their spells!", COLOR_GREEN, oMaster);
                SetLocalInt (oCaster, "0_BLOOD_MAGIC", TRUE);
            }
            break;
        }
    }
}

