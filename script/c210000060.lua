-- Gray Area
local s,id,o=GetID()
-- c210000060
function s.initial_effect(c)
	--[[
	[HOPT]
	Target up to 3 “Rainbow Realm” Spell/Traps and/or “Area” Continuous Traps in your GY and/or banishment, except “Gray Area”;
	shuffle them into the Deck.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,(id+0))
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If an “Area” Continuous Trap(s) you control leaves your field because of an opponent’s card effect
	and is now in the GY or banishment (except during the Damage Step):
	You can banish this card from your GY;
	place 1 “Area” Continuous Trap from your GY or banishment face-up on your field.
	]]--
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetCode(EVENT_TO_GRAVE)
	e2a:SetRange(LOCATION_GRAVE)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCountLimit(1,(id+0))
	e2a:SetHintTiming(0,TIMING_BATTLE_START)
	e2a:SetCondition(s.e2con)
	e2a:SetCost(aux.bfgcost)
	e2a:SetOperation(s.e2evt)
	c:RegisterEffect(e2a)

	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2b)
end
function s.e1fil(c)
	return ((c:IsSetCard(0xce2a) and c:IsSpellTrap())
	or (c:IsSetCard(0xce2b) and c:IsContinuousTrap()))
	and not c:IsCode(id)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
	end
end
function s.e1evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local gc=g:GetCount()
	if gc>=1 then
		local max=3
		if gc<3 then
			max=gc
		end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sel=Group.Select(g,tp,1,max,nil)
		Duel.SendtoDeck(sel,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.e2fil1(c,tp)
	return c:IsSetCard(0xce2b)
	and c:IsContinuousTrap()
	and c:IsPreviousControler(tp)
	and c:IsPreviousLocation(LOCATION_ONFIELD)
	and c:IsReason(REASON_EFFECT)
	and c:GetReasonPlayer()==1-tp
end
function s.e2con(e,tp,eg)
	return eg:IsExists(s.e2fil1,1,nil,tp)
end
function s.e2fil2(c)
	return c:IsSetCard(0xce2b)
	and c:IsContinuousTrap()
	and not c:IsForbidden()
	and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.e2evt(e,tp)
	if Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)<1 then return end

	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e2fil2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g:Select(tp,1,1,nil)
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end