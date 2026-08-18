/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_npc_action
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Conversation script to have an NPC do something.

 Params string sInput:
 Pick_Target - Sets a variable to cast a spell on.
    int nTarget = 0)PC, #)Hench #, -1)Familiar, -2)Animal Companion
 Pick_Spell - Tells the NPC to cast nSpell upon Pick_Target for nGold.
    int nSpell is the spell to cast.
    int nGold is the cost if it has one.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_items"
void main()
{
    object oPC = GetPCSpeaker();
    string sInput = GetScriptParam("sInput");
    if(sInput == "Pick_Spell")
    {
        SetLocalInt(oPC, "NPC_Spell", StringToInt(GetScriptParam("nSpell")));
        SetLocalInt(oPC, "NPC_Gold", StringToInt(GetScriptParam("nGold")));
        // Set the characters to pick in the conversation.
        object oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
        if(oCreature != OBJECT_INVALID) SetCustomToken(8998, StripColorCodes(GetName(oCreature)));
        oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
        if(oCreature != OBJECT_INVALID) SetCustomToken(8999, StripColorCodes(GetName(oCreature)));
        SetCustomToken(9000, StripColorCodes(GetName(oPC)));
        oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 1);
        if(oCreature != OBJECT_INVALID) SetCustomToken(9001, StripColorCodes(GetName(oCreature)));
        oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 2);
        if(oCreature != OBJECT_INVALID) SetCustomToken(9002, StripColorCodes(GetName(oCreature)));
        oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 3);
        if(oCreature != OBJECT_INVALID) SetCustomToken(9003, StripColorCodes(GetName(oCreature)));
    }
    else if(sInput == "Pick_Target")
    {
        int nTarget = StringToInt(GetScriptParam("nTarget"));
        object oTarget;
        if(!nTarget) oTarget = oPC;
        else if(nTarget == -1) oTarget = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
        else if(nTarget == -2) oTarget = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
        else if(nTarget > 0) oTarget = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nTarget);
        int nSpell = GetLocalInt(oPC, "NPC_Spell");
        DeleteLocalInt(oPC, "NPC_Spell");
        int nGold = GetLocalInt(oPC, "NPC_Gold");
        DeleteLocalInt(oPC, "NPC_Gold");
        int nPCGold = GetGold(oPC);
        // Raise dead should be cast on a body in the inventory.
        if(nSpell == SPELL_RAISE_DEAD || nSpell == SPELL_RESURRECTION || nSpell == 970/*SPELL_TRUE_RESURRECTION*/)
        {
            if(nGold <= nPCGold)
            {
                object oCorpse = GetCreatureHasItem(oPC, "0_corpse");
                if(oCorpse != OBJECT_INVALID)
                {
                    int nRaise = 1;
                    if(nSpell == SPELL_RESURRECTION) nRaise = 2;
                    else if(nSpell == SPELL_TRUE_RESURRECTION) nRaise = 3;
                    if(GetLocalInt (oCorpse, "0_Raise") <= nRaise)
                    {
                        if(nGold) TakeGoldFromCreature(nGold, oPC);
                        ActionCastFakeSpellAtObject(nSpell, oCorpse);
                        // Pass to the Ressurect and Raise Dead script to know the spell is not being cast by the player.
                        SetLocalInt(oPC, "NPC_SPELL", TRUE);
                        AssignCommand(oPC, ActionCastSpellAtObject(nSpell, oCorpse, 255, TRUE, 0, 0, TRUE));
                    }
                    else SpeakString("This spell is not strong enought to resurrect this being!");
                }
                else SpeakString("You need to have a body for me to raise from the dead!");
            }
            else SpeakString("You do not have the " + IntToString (nGold) + "gold required for me to cast this spell for you!");
        }
        else
        {
            if (nGold <= nPCGold)
            {
                if(nGold) TakeGoldFromCreature (nGold, oPC);
                ActionCastSpellAtObject (nSpell, oTarget, 255, TRUE);
            }
            else SpeakString("You do not have the " + IntToString (nGold) + "gold required for me to cast this spell for you!");
        }
    }
}
