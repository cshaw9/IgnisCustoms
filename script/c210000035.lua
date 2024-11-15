--The True Polygod
local s,id,o=GetID()
-- c210000035
function s.initial_effect(c)
	-- 1 “Polygod” Tuner + 1+ non-Tuner “Polygod” monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xce1),1,1,Synchro.NonTunerEx(Card.IsSetCard,0xce1),1,99)
	c:EnableReviveLimit()
	-- Cannot be Special Summoned, except from the Extra Deck.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- If this Attack Position card would be destroyed by card effect, you can change it to face-up Defense Position instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
	-- During your turn, when this card is Synchro Summoned: Destroy all other cards on the field, then skip to the End Phase.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	Once per Chain (Quick Effect):
	You can banish 1 card from your hand, then add 1 “Polygod” card from your banishment to your hand.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
function s.e2fil(c,tp)
	return not c:IsReason(REASON_REPLACE)
	and c:IsFaceup()
	and c:IsControler(tp)
	and c:IsReason(REASON_EFFECT)
end
function s.e2con(e)
	local c=e:GetHandler()

	return c:IsAttackPos()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsCanChangePosition()
	end
	
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.e2val(e,c)
	return s.e2fil(c,e:GetHandlerPlayer())
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		local repl=c:GetEquipGroup():Filter(Card.IsCode,nil,210000024)
		if repl:GetCount()>0 then
			if not Duel.SelectEffectYesNo(tp,repl:GetFirst()) then
				Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
			end
		else
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end
function s.e3con(e,tp)
	return tp==Duel.GetTurnPlayer() and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	end

	local tg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,tg:GetCount(),0,0)
end
function s.e3evt(e,tp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.BreakEffect()

		Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	end
end
function s.e4fil(c)
	return c:IsSetCard(0xce1)
	and c:IsAbleToHand()
end
function s.e4con(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
	and Duel.IsExistingMatchingCard(s.e4fil,0,LOCATION_REMOVED,0,1,e:GetHandler())
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		and Duel.IsExistingMatchingCard(s.e4fil,0,LOCATION_REMOVED,0,1,e:GetHandler())
	end
	
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.e4evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sel1=Group.Select(Duel.GetFieldGroup(tp,LOCATION_HAND,0),tp,1,1,nil)

	if Duel.Remove(sel1:GetFirst(),POS_FACEUP,REASON_EFFECT)>0 then
		local sel2=Duel.SelectMatchingCard(tp,s.e4fil,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc=sel2:GetFirst()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end