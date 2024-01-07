getgenv().webhook = "" -- webhook link for successful snipes
getgenv().webhookFail = "" -- webhook link for successful snipes
getgenv().userid = "" -- pings your discord id if it snipes a huge or titanic 
getgenv().alts = {"bobofarm133","bobofarm134","bobofarm135","bobofarm136","bobofarm137","bobofarm138","bobofarm139","bobofarm140","bobofarm141","bobofarm142","bobofarm143"} -- put usernames to hop if more than two of them are in the same server
getgenv().normalwebhook = ""
getgenv().snipeNormalPets = false -- snipes other items that are priced at 1
repeat wait() until game:IsLoaded()
if game.PlaceId == 15502339080 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/bobitzaaa/sniper/main/proplaza2"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/bobitzaaa/sniper/main/pro%20plaza"))()
end
