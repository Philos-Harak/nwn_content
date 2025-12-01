/*//////////////////////////////////////////////////////////////////////////////
 Script: hench_ch_spell
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  This is a compatibility script for Aielund Saga module.
  Associates (Summons, Familiars, Companions) OnSpellCastAt event script;
  Fires when oCreature becomes the target of a spell via SignalEvent.
  Fires when a healing kit is used on a creature.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    object oCaster = GetLastSpellCaster();
    int nSpell = GetLastSpell();
    // **************************************
    // * CHAPTER 1
    // * Player brings back a dead henchmen
    // * for the first time
    // *
    // **************************************
    // This should only fire the first time they are raised - when they have
    // first been discovered in Undermountain
    if(!GetLocalInt(OBJECT_SELF, "X2_SavedInUndermountain") && GetTag(GetModule()) == "x0_module1")
    {
        if (nSpell == SPELL_RAISE_DEAD || nSpell == SPELL_RESURRECTION)
        {
            SetLocalInt(OBJECT_SELF, "X2_SavedInUndermountain", TRUE);
            string sTag = GetTag(oCreature);
            if(sTag == "x2_hen_sharwyn") AddJournalQuestEntry("q2sharwyn", 20, oCaster);
            else if(sTag == "x2_hen_tomi") AddJournalQuestEntry("q2tomi", 20, oCaster);
            else if(sTag == "x2_hen_daelan") AddJournalQuestEntry("q2daelan", 20, oCaster);
            if(GetHitDice(oCaster) < 15)
            {   //600 xp reward if PC is less than 15th level
                Reward_2daXP(oCaster, 12, TRUE);
            }
            else
            {   //200 xp reward if PC is 15th level or higher
                Reward_2daXP(oCaster, 11, TRUE);
            }
        }
    }
    ExecuteScript("nw_ch_acb", oCreature);
    if(nSpell == SPELL_RAISE_DEAD || nSpell == SPELL_RESURRECTION)
    {
       // * restore merchant faction to neutral
       SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 100, oCaster);
       SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 100, oCaster);
       SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 100, oCaster);
       ClearPersonalReputation(oCaster, oCreature);
       AssignCommand(oCreature, SurrenderToEnemies());
        object oHench = oCreature;
        AssignCommand(oHench, ClearAllActions(TRUE));
        string sFile = GetDialogFileToUse(oCaster);
        // * reset henchmen attack state - Oct 28 (BK)
        SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE, oHench);
        SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE, oHench);

        // * Oct 30 - If player previously hired this hench
        // * then just have them rejoin automatically
        if (GetPlayerHasHired(oCaster, oHench) == TRUE)
        {
            // Feb 11, 2004 - Jon: Don't fire the HireHenchman function if the
            // henchman is already oCaster's associate. Fixes a silly little problem
            // that occured when you try to raise a henchman who wasn't actually dead.
            if(GetMaster(oHench)!=oCaster) HireHenchman(oCaster, oHench, TRUE);
        }
        // * otherwise, they talk
        else
        {
            AssignCommand(oCaster, ActionStartConversation(oHench, sFile));
        }
    }
}
