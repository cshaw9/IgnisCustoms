-- Banishite Castle
local s,id,o=GetID()
-- c210000078
function s.initial_effect(c)
	--[[
	[HOPT]
	Pay LP in multiples of 1000 (max. 3000);
	add 1 “Banishite” card from your Deck to your hand for every 1000 LP paid, except “Banishite Cavalry”.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.e1cst)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil(c)
	return c:IsSetCard(0xce3)
	and not c:IsCode(id)
	and c:IsAbleToHand()
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_DECK,0,nil)
	local mult=1000

	if chk==0 then
		return Duel.CheckLPCost(tp,mult)
		and g:GetCount()>=1
	end

	local max=3000
	if (g:GetCount()<3) then
		max=g:GetCount()*mult
	end

	local lp=Duel.GetLP(tp)
	local m=math.floor(math.min(lp,max)/mult)
	local t={}
	for i=1,m do
		t[i]=i*mult
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))

	Duel.PayLPCost(tp,ac)
	e:SetLabel(ac/mult)
end
function s.e1evt(e,tp)
	local ct=e:GetLabel()

	if not Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_DECK,0,ct,nil) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_DECK,0,ct,ct,nil)
	
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end