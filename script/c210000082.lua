-- Deragon, Dragon of Destruction
local s,id,o=GetID()
-- c210000082
function s.initial_effect(c)
	-- 1 "Banishite Dragon" + 1 Illusion monster
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,210000064,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ILLUSION))
	--[[
	[HOPT]
	When this card is Fusion Summoned:
	Banish all cards on the field and in both players hands, then each player draws 5 cards,
	also, you cannot Special Summon monsters for the rest of this turn.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,(id+0))
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then true end

	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_HAND+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,ct)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,5)
end
function s.e1fil(c)
	return c:IsAbleToRemove()
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_HAND+LOCATION_ONFIELD):Filter(s.e1fil, nil)

	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		--[[
		[HOPT]
		During your next Standby Phase after this card was banished by this effect:
		You can Special Summon this card from your banishment.
		]]--
		if g:IsContains(c) then
			local e2=Effect.CreateEffect(c)
			e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e2:SetRange(LOCATION_REMOVED)
			e2:SetHintTiming(0,TIMING_STANDBY_PHASE)
			e2:SetCountLimit(1,(id+1))
			e2:SetCondition(s.e2con)
			e2:SetTarget(s.e2tgt)
			e2:SetOperation(s.e2evt)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			c:RegisterEffect(e2)
		end

		Duel.BreakEffect()

		if Duel.IsPlayerCanDraw(tp,5) and Duel.IsPlayerCanDraw(1-tp,5) then
			Duel.Draw(tp,5,REASON_EFFECT)
			Duel.Draw(1-tp,5,REASON_EFFECT)
		end
	end

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1b:SetTargetRange(1,0)
	e1b:SetReset(RESET_PHASE+PHASE_END,1)
	Duel.RegisterEffect(e1b,tp)
end
function s.e2con(e,tp)
	local c=e:GetHandler()

	return c:GetTurnID()~=Duel.GetTurnCount()
	and tp==Duel.GetTurnPlayer()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end