-- Porgo, The Prince of Banishite
local s,id,o=GetID()
-- c210000084
function s.initial_effect(c)
	-- 2 Level 5 or higher “Banishite” monsters
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.e0mat,2)
	--[[
	[HOPT]
	When this card is Fusion Summoned:
	Banish this card, then Special Summon up to 3 monsters from either player's banishment(s), except this card.
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
function s.e0mat(c,fc,sumtype,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0xce3,fc,sumtype,tp)
end
function s.e1con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.e1fil(c,e,tp)
	return c:IsFaceup()
	and c:IsMonster()
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and c~=e:GetHandler()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToRemove()
	end

	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,1)
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

		Duel.BreakEffect()

		local max=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if max>0 and Duel.IsExistingMatchingCard(s.e1fil,0,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) then
			if max>3 then
				max=3
			end
			local tg=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_REMOVED,LOCATION_REMOVED,0,max,nil)
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
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