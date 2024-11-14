-- Gateway to the Rainbow Realm
local s,id,o=GetID()
-- c210000052
function s.initial_effect(c)
	--[[
	[HOPT]
	Activate 1 of the following effects.
	• Set 1 “Rainbow Realm” Spell/Trap from your Deck, except “Gateway to the Rainbow Realm”.
	• If “Rainbow Realm of Doom” is in your Field Zone: Draw 2 cards.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,(id+0)+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil(c,z)
	return c:IsSetCard(0xce2a)
	and c:IsSpellTrap()
	and not c:IsCode(id)
	and c:IsSSetable()
	and (z>0 or c:IsFieldSpell())
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_DECK,0,1,nil,Duel.GetLocationCount(tp,LOCATION_SZONE))
	local b2=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210000046),tp,LOCATION_FZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,2)

	if chk==0 then
		return b1 or b2
	end
	
	local sel=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(sel)

	if sel==2 then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
end
function s.e1evt(e,tp)
	local sel=e:GetLabel()
	if sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_DECK,0,1,1,nil,Duel.GetLocationCount(tp,LOCATION_SZONE))
		if g:GetCount()>0 then
			Duel.SSet(tp,g)
		end
	else
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end