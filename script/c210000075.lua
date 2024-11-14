-- Kingslands Realm of Banishite
local s,id,o=GetID()
-- c210000075
function s.initial_effect(c)
	c:EnableCounterPermit(0x34)
	c:SetCounterLimit(0x34,5)
	-- [Activation]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Any card sent to the GY is banished instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0xff,0xff)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTarget(s.e2tgt)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- Each time a card(s) is banished, place 1 Banishite Counter on this card (max. 5).
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.e3con)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	You can remove up to 3 Banishite Counters from this card, then target that many “Banishite” cards in your banishment;
	shuffle those targets into the Deck/Extra Deck.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,(id+0))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(s.e4cst)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	You can remove 1 Banishite Counter from this card; draw 1 card.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,(id+1))
	e5:SetCost(s.e5cst)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
function s.e2tgt(e,c)
	return Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
function s.e3con(e)
	return e:GetHandler():GetCounter(0x34)<5
end
function s.e3evt(e)
	e:GetHandler():AddCounter(0x34,1)
end
function s.e4cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanRemoveCounter(tp,0x34,3,REASON_COST)
	end
	
	c:RemoveCounter(tp,0x34,3,REASON_COST)
end
function s.e4fil(c)
	return c:IsSetCard(0xce3)
	and c:IsAbleToDeck()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_REMOVED)
		and chkc:IsControler(tp)
		and s.e4fil(chkc)
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_REMOVED,0,3,nil,e,tp)
	end

	if Duel.IsExistingTarget(s.e4fil,tp,LOCATION_REMOVED,0,3,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

		local g=Duel.SelectTarget(tp,s.e4fil,tp,LOCATION_REMOVED,0,3,3,nil)
		
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	end
end
function s.e4evt(e,tp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end

	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.e5cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanRemoveCounter(tp,0x34,1,REASON_COST)
	end
	
	c:RemoveCounter(tp,0x34,1,REASON_COST)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end

	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.e5evt(e,tp)
	Duel.Draw(tp,1,REASON_EFFECT)
end