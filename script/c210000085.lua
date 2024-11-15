-- Hemophilio, The Dark Crusader
local s,id,o=GetID()
-- c210000085
function s.initial_effect(c)
	-- 6 “Banishite” monsters in your banishment with different names.
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.e0mat,6)
	-- This card’s ATK/DEF become equal to the number of “Banishite” cards in the banishments x 1000.
	--[[
	[HOPT]
	When this card is Fusion Summoned:
	Banish this card, then banish the top 10 cards of your Deck.
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
function s.e0mat(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0xce3,fc,sumtype,tp)
	and c:IsLocation(LOCATION_REMOVED)
	and c:IsControler(tp)
	and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.e1con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.e1fil(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToRemove()
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,1)
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

		local g=Duel.GetDecktopGroup(tp,10)
		if g:GetCount()==10 and g:FilterCount(Card.IsAbleToRemove,nil,POS_FACEUP)==10 then
			local g=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
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