-- Kiloton, The Purger
local s,id,o=GetID()
-- c210000086
function s.initial_effect(c)
	-- 2 “Banishite” monsters
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.e0mat,2)
	--[[
	[HOPT]
	When this card is Fusion Summoned:
	Banish this card.
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
	--[[
	[HOPT]
	During your Main Phase 1: You can banish 5 cards from either GY(s),
	also, skip your Battle Phase this turn. 
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,(id+2))
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e0mat(c,fc,sumtype,tp)
	return c:IsSetCard(0xce3,fc,sumtype,tp)
end
function s.e1con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.e1fil(c)
	return c:IsAbleToRemove()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToRemove()
	end

	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,1)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()

	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
		--[[
		[HOPT]
		During your next Standby Phase after this card was banished by this effect:
		You can Special Summon this card from your banishment.
		]]--
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
function s.e3con(e)
	return Duel.IsMainPhase()
end
function s.e3fil(c)
	return c:IsAbleToRemove()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.e3fil),0,LOCATION_GRAVE,LOCATION_GRAVE,5,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,5)
end
function s.e3evt(e,tp)
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.e3fil),0,LOCATION_GRAVE,LOCATION_GRAVE,5,nil)<5 then return end

	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e3fil),tp,LOCATION_GRAVE,LOCATION_GRAVE,5,5,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)

	Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
end