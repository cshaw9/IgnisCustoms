-- Colorless Rainbow Realm
local s,id,o=GetID()
-- c210000055
function s.initial_effect(c)
	--[[
	[HOPT]
	Target 1 face-up card your opponent controls; negate that target’s effects,
	also, after that, you can send 1 “Rainbow Realm” card from your Deck to the GY, except “Colorless Rainbow Realm”.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,(id+0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During the Main Phase: You can banish this card from your GY;
	you take no effect damage for the rest of this turn.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,(id+1))
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1fil1(c,tp)
	return c:IsControler(1-tp)
	and c:IsNegatable()
	and c:IsCanBeEffectTarget()
end
function s.e1fil2(c)
	return c:IsSetCard(0xce2a)
	and not c:IsCode(id)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_ONFIELD)
		and chkc:IsControler(1-tp)
		and chkc:IsNegatable()
		and chkc:IsCanBeEffectTarget()
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1fil1,tp,0,LOCATION_ONFIELD,1,nil,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.e1fil1,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
end
function s.e1evt(e)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		tc:NegateEffects(c)

		Duel.BreakEffect()

		local g=Duel.GetMatchingGroup(s.e1fil2,tp,LOCATION_DECK,0,nil)
		if g:GetCount()>0 then
			if Duel.SelectEffectYesNo(tp,c) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local sg=g:Select(tp,1,1,nil)

				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local e2a=Effect.CreateEffect(e:GetHandler())
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CHANGE_DAMAGE)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetTargetRange(1,0)
	e2a:SetValue(s.e2val)
	e2a:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2a,tp)

	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2b:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2b,tp)
end
function s.e2val(e,re,val,r)
	if (r&REASON_EFFECT)~=0 then
		return 0
	else
		return val
	end
end