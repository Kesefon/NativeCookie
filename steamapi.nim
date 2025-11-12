import os

when fileExists("greenworks/libsteam_api.so"):
    {.link: "greenworks/libsteam_api.so".}
    {.passl: "-Lgreenworks -lsteam_api -Wl,-rpath='$ORIGIN/greenworks/'".}
    {.passc: "-I./include ".}

    type
        ISteamUGC {.importcpp: "ISteamUGC", header: "steam/isteamugc.h".} = object

    proc initSteamAPI(): bool {.importcpp: "SteamAPI_Init", header: "steam/steam_api.h".}
    proc shutdownSteamAPI(): void {.importcpp: "SteamAPI_Shutdown", header: "steam/steam_api.h".}
    proc SteamUGC(): ptr ISteamUGC {.importcpp: "SteamUGC", header: "steam/isteamugc.h".}
    proc SubscribeItem(i: ptr ISteamUGC, id: int64): void {.importcpp: "#.SubscribeItem(@)", header: "steam/isteamugc.h".}

    proc subscribeWorkshopItem*(id: int64): void =
        if initSteamAPI():
            SteamUGC().SubscribeItem(id)
            shutdownSteamAPI()
else:
    proc subscribeWorkshopItem*(id: int64): void =
        return
