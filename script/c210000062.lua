-- Rainbow Realm Imp
local s,id,o=GetID()
-- c210000062
function s.initial_effect(c)
	-- If this card battles a monster, neither can be destroyed by that battle.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	You can discard this card and 1 “Area” Trap Card; draw 2 cards.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,(id+0))
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	(Quick Effect): You can banish this card from your GY, then target 1 “Rainbow Realm of Doom” in your Field Zone;
	that target is unaffected by other cards’ effects until the end of this turn.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,(id+0))
	e3:SetHintTiming(TIMING_STANDBY_PHASE+TIMING_END_PHASE)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1tgt(e,tc)
	local c=e:GetHandler()
	return tc==c or tc==c:GetBattleTarget()
end
function s.e2fil(c)
	return c:IsSetCard(0xce2b)
	and c:IsTrap()
	and c:IsDiscardable()
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_HAND,0,nil)

	if chk==0 then
		return c:IsDiscardable()
		and g:GetCount()>0
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local sg=g:Select(tp,1,1,nil)
	sg:AddCard(c)
	
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,2)
	end

	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.e2evt(e,tp)
	Duel.Draw(tp,2,REASON_EFFECT)
end
function s.e3fil(c)
	return c:IsCode(210000046)
	and c:IsFaceup()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc==0 then
		return chkc:IsLocation(LOCATION_FZONE)
		and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e3fil,tp,LOCATION_FZONE,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_FZONE,0,1,1,nil)
end
function s.e3evt(e)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e3b=Effect.CreateEffect(c)
		e3b:SetType(EFFECT_TYPE_SINGLE)
		e3b:SetCode(EFFECT_IMMUNE_EFFECT)
		e3b:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3b:SetValue(s.e3val)
		e3b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3b)
	end
end
function s.e3val(e,re)
	local c=e:GetHandler()
	return c~=re:GetOwner() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end