/*///////////////////////////////////////////////////////////////////////////////
 Script: 0c_henchmenspell
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Action script to cast a specific spell for a henchman.

 Script Param
 nTarget (INT) : 0 = ALL, 1-4 = Other Henchman, 5 = Caster, 6 = PC's Familiar
                 7 = PC's Animal Companion, 8 = PC.
 nBuffType = 1 short 2 long 3 all, 4 healing, 5 lay on hands.
 If nBuffType is 0 then it will cast a specific spell from
 Variable "0_SPELL_TO_CAST". Use script: 0c_h_spell_cast spell to set the spell.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
float ai_CastHealing(object oTarget, object oPC, float fDelay, object oCaster, int nCntr = 0);
float ai_UseLayOnHands(object oTarget, object oPC, float fDelay, object oCaster);
// Returns TRUE if nSpell is a cure spell and will not over heal for nHpLost.
int ai_ShouldWeCastThisCureSpell(int nSpell, int nHpLost);
// Keeps track if we are going to cast this spell already.
int ai_AreWeCastingThisSpell(object oCaster, int nClass, int nLevel, int nSlot, int nCntr);
void main()
{
    object oTarget, oPC = GetPCSpeaker();
    object oCaster = OBJECT_SELF;
    float fDelay;
    int nTarget = StringToInt(GetScriptParam("nTarget"));
    int nBuffType = StringToInt(GetScriptParam("nBuffType"));
    ai_SetupBuffTargets(oCaster, oPC);
    // Cast a group of buff spells based on nBuffType and nTarget or a single spell.
    if(nBuffType < 4)
    {
        // Cast a specific spell.
        if(nBuffType == 0)
        {
            int nSpell = GetLocalInt(oCaster, "0_SPELL_TO_CAST");
            // These are buff spells so Acid fog (index 0) is not a valid spell.
            if(nSpell > 0)
            {
                ai_ClearCreatureActions(oCaster);
                object oTarget = GetLocalObject(oCaster, "AI_BUFF_TARGET_" + IntToString(nTarget));
                if(oTarget != OBJECT_INVALID && ai_CheckAndCastSpell(oCaster, nSpell, 0, 0.0f, oTarget, oPC))
                {
                    DeleteLocalInt(oCaster, "0_SPELL_TO_CAST");
                }
                else
                {
                    if(!ai_GetAssociateMode(oCaster, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCaster);
                    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    ai_SendMessages("I cannot cast " + sSpellName + ".", COLOR_RED, oPC);
                }
            }
        }
        // Cast a creatures buff spells on nTarget.
        else ai_CastBuffs(oCaster, nBuffType, nTarget, oPC);
    }
    // Cast Healing spells.
    else if(nBuffType == 4)
    {
        // Target of 0 means cast it on all allies.
        if(nTarget == 0)
        {
            int nCntr, nIndex;
            while(nIndex < 9)
            {
                oTarget = GetLocalObject(oCaster, "AI_BUFF_TARGET_" + IntToString(++nIndex));
                //ai_Debug("0c_henchmanspell", "66", "oTarget: " + GetName(oTarget) +
                //         " nIndex: " + IntToString(nIndex));
                if(oTarget != OBJECT_INVALID && ai_GetPercHPLoss(oTarget) < 100)
                {
                    fDelay = ai_CastHealing(oTarget, oPC, fDelay, oCaster, ++nCntr);
                }
            }
            while (nCntr > 0)
            {
                DeleteLocalString(oCaster, "AI_CASTING_SPELL_" + IntToString(nCntr--));
            }
        }
        else
        {
            oTarget = GetLocalObject(oCaster, "AI_BUFF_TARGET_" + IntToString(nTarget));
            if(oTarget != OBJECT_INVALID) ai_CastHealing(oTarget, oPC, 0.0f, oCaster);
        }
    }
    // Use lay on hands.
    else if(nBuffType == 5)
    {
        oTarget = GetLocalObject(oCaster, "AI_BUFF_TARGET_" + IntToString(nTarget));
        ai_UseLayOnHands(oTarget, oPC, 0.0f, oCaster);
    }
    else if(!ai_GetAssociateMode(oCaster, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CUSS, oCaster);
    ai_ClearBuffTargets(oCaster);
}
float ai_CastHealing(object oTarget, object oPC, float fDelay, object oCaster, int nCntr = 0)
{
    int nHpLost = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    if(!nHpLost)
    {
        ai_SendMessages(GetName(oTarget) + " does not need healed.", COLOR_RED, oPC);
        return fDelay;
    }
    int nClassCnt = 1, nClass, nMaxSlot, nLevel, nSlot, nSpell, nDomain;
    int nCureSpell, nMetaMagic;
    while(nClassCnt <= AI_MAX_CLASSES_PER_CHARACTER && nClass != CLASS_TYPE_INVALID)
    {
        nClass = GetClassByPosition(nClassCnt, oCaster);
        // Search all memorized spells for a cure spell.
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            // Check each level, highest (Heal is 7th for druid) to lowest.
            nLevel = 7;
            while(nLevel >= 0)
            {
                // Check each slot within each level.
                nMaxSlot = GetMemorizedSpellCountByLevel(oCaster, nClass, nLevel);
                nSlot = 0;
                while(nSlot < nMaxSlot)
                {
                    if(GetMemorizedSpellReady(oCaster, nClass, nLevel, nSlot))
                    {
                        nSpell = GetMemorizedSpellId(oCaster, nClass, nLevel, nSlot);
                        if(ai_ShouldWeCastThisCureSpell(nSpell, nHpLost) &&
                           !ai_AreWeCastingThisSpell(oCaster, nClass, nLevel, nSlot, nCntr))
                        {
                            ai_CastMemorizedSpell(oCaster, nClass, nLevel, nSlot, oTarget, fDelay, oPC);
                            SetLocalString(oCaster, "AI_CASTING_SPELL_" + IntToString(nCntr), IntToString(nClass) + IntToString(nLevel) + IntToString(nSlot));
                            return fDelay + AI_HENCHMAN_BUFF_DELAY;
                        }
                    }
                    nSlot++;
                }
                nLevel --;
            }
            // We do not have any Cure spells memorized, can we cast them spontaneously?
            if(Get2DAString("classes", "CanCastSpontaneously", nClass) == "1")
            {
                // Check each level starting with the level 4.
                if(nHpLost > 32)
                { nCureSpell = SPELL_CURE_CRITICAL_WOUNDS; nLevel = 4; }
                else if(nHpLost > 24)
                { nCureSpell = SPELL_CURE_SERIOUS_WOUNDS; nLevel = 3; }
                else if(nHpLost > 16)
                { nCureSpell = SPELL_CURE_MODERATE_WOUNDS; nLevel = 2; }
                else if(nHpLost > 8)
                { nCureSpell = SPELL_CURE_LIGHT_WOUNDS; nLevel = 1; }
                else { nCureSpell = SPELL_CURE_MINOR_WOUNDS; nLevel = 0; }
                while(nLevel >= 0)
                {
                    // Check each slot within each level.
                    nMaxSlot = GetMemorizedSpellCountByLevel(oCaster, nClass, nLevel);
                    nSlot = 0;
                    while(nSlot < nMaxSlot)
                    {
                        // If memorized then use this spell to cast our spontaneous cure spell.
                        if(GetMemorizedSpellReady(oCaster, nClass, nLevel, nSlot) == 1)
                        {
                            nSpell = GetMemorizedSpellId(oCaster, nClass, nLevel, nSlot);
                            SetMemorizedSpellReady(oCaster, nClass, nLevel, nSlot, FALSE);
                            DelayCommand(fDelay, ActionCastSpellAtObject(nCureSpell, oTarget, 255, TRUE, 0, 0, TRUE));
                            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nCureSpell)));
                            DelayCommand(fDelay, ai_SendMessages(GetName(oCaster) + " has spontaneously cast " + sSpellName + " on " + GetName(oTarget) + ".", COLOR_GREEN, oPC));
                            return fDelay + AI_HENCHMAN_BUFF_DELAY;
                        }
                        nSlot ++;
                    }
                    nLevel --;
                }
            }
        }
        // Check non-memorized known lists for a cure spell.
        else
        {
            // Check each level, highest (Heal is 7th for druid) to lowest.
            nLevel = 7;
            while(nLevel >= 0)
            {
                // Check each slot within each level.
                nMaxSlot = GetKnownSpellCount(oCaster, nClass, nLevel);
                nSlot = 0;
                while(nSlot < nMaxSlot)
                {
                    nSpell = GetKnownSpellId(oCaster, nClass, nLevel, nSlot);
                    if(GetSpellUsesLeft(oCaster, nClass, nSpell))
                    {
                         if(ai_ShouldWeCastThisCureSpell(nSpell, nHpLost) &&
                            !ai_AreWeCastingThisSpell(oCaster, nClass, nLevel, nSlot, nCntr))
                        {
                            ai_CastKnownSpell(oCaster, nClass, nSpell, oTarget, fDelay, oPC);
                            SetLocalString(oCaster, "AI_CASTING_SPELL_" + IntToString(nCntr), IntToString(nClass) + IntToString(nLevel) + IntToString(nSlot));
                            return fDelay + AI_HENCHMAN_BUFF_DELAY;
                        }
                    }
                    nSlot++;
                }
                nLevel --;
            }
        }
        nClassCnt ++;
    }
    if(!ai_GetAssociateMode(oCaster, AI_MODE_DO_NOT_SPEAK)) VoiceCannotDo(TRUE);
    DelayCommand(fDelay, ai_SendMessages("I don't have any more healing spells. to cast on " + GetName(oTarget), COLOR_RED, oPC));
    return fDelay;
}
float ai_UseLayOnHands(object oTarget, object oPC, float fDelay, object oCaster)
{
    int nHpLost = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    if(!nHpLost)
    {
        if(!ai_GetAssociateMode(oCaster, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCaster);
        ai_SendMessages(GetName(oTarget) + " does not need healed.", COLOR_RED, oPC);
    }
    else
    {
        ai_SendMessages(GetName(oCaster) + " is laying hands on " + GetName(oTarget), COLOR_GREEN, oPC);
        ActionUseFeat(FEAT_LAY_ON_HANDS, oTarget);
        fDelay += 6.0f;
    }
    return fDelay;
}
int ai_ShouldWeCastThisCureSpell(int nSpell, int nHpLost)
{
    if(nSpell == SPELL_HEAL && nHpLost > 50) return TRUE;
    else if(nSpell == SPELL_CURE_CRITICAL_WOUNDS && nHpLost > 32) return TRUE;
    else if(nSpell == SPELL_CURE_SERIOUS_WOUNDS && nHpLost > 24) return TRUE;
    else if(nSpell == SPELL_CURE_MODERATE_WOUNDS && nHpLost > 16) return TRUE;
    else if(nSpell == SPELL_CURE_LIGHT_WOUNDS && nHpLost > 8) return TRUE;
    else if(nSpell == SPELL_CURE_MINOR_WOUNDS) return TRUE;
    return FALSE;
}
int ai_AreWeCastingThisSpell(object oCaster, int nClass, int nLevel, int nSlot, int nCntr)
{
    string sSpellToCast = IntToString(nClass) + IntToString(nLevel) + IntToString(nSlot);
    string sCastingSpell;
    nCntr--;
    while(nCntr > 0)
    {
        sCastingSpell = GetLocalString(oCaster, "AI_CASTING_SPELL_" + IntToString(nCntr));
        if(sCastingSpell == sSpellToCast) return TRUE;
        --nCntr;
    }
    return FALSE;
}
