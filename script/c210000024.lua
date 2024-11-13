--Polygod Pure DNA
local s,id,o=GetID()
-- c210000024
function s.initial_effect(c)
	-- [Activation]
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	-- Equip only to a “Polygod” monster.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.e2lim)
	c:RegisterEffect(e2)
	-- If the equipped monster would change its battle position by its own effect, it does not have to.
	--[[
	-- [aux Function]
	local e3=Effect.CreateEffect(c)
	c:RegisterEffect(e3)
	]]--
	-- Once per turn, if this card is in your GY: You can banish 1 card from your hand, then place this card on the top of your Deck.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
function s.e1fil(c)
	return c:IsFaceup()
	and c:IsSetCard(0xce1)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and s.e1fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.e1fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end
function s.e2lim(e,c)
	return c:IsSetCard(0xce1)
end
function s.e4con(e,tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	return g:GetCount()>=1
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToDeck()
	end
	
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.e4evt(e,tp,eg,ep,ev,re)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sel = Group.Select(g,tp,1,1,nil)
		if Duel.Remove(sel:GetFirst(),POS_FACEUP,REASON_EFFECT)>0 then
			Duel.BreakEffect()

			local c=e:GetHandler()
			if c:IsRelateToEffect(e) then
				Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
			end
		end
	end
end
