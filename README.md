# «BattleBuilder» is a Voxel-gamemode concept for Garry's Mod, which was in development from 2022 to 2023. 
At the moment, its development is frozen, so I want to share my best practices here.

## Released
— Reading the voxel worlds format (.vxl 0.75) from the Ace Of Spades game directly into the gamemode.
— Creation of a game world (512x512x64) on the server side and its synchronization with the client.
— Blocks and Chunks which consume little RAM (lol).
— Editing blocks (destruction\creation) with a quick rebuild of the mesh.

## In-work
— A destruction system that cuts off geometry in the air (due to Lua limitations, this task cannot be implemented in real time).
— Basic player movement.

## Not Released
— Weapon system.
— Physical projectiles.

## My recommendations

— Due to technical limitations, many solutions will have to be improvised, so you probably won`t.

<html>
<body>
    <h1>GameMode Screens</h1>
    <div>
        <img src="https://steamuserimages-a.akamaihd.net/ugc/1911233378207744351/DA1D4635B0A9D2C40AE7666CFD9E26D3D1110D8A/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false" alt="Image 1">
        <img src="https://steamuserimages-a.akamaihd.net/ugc/1911233378207743646/7FFD4310ECEFF53EFBEA315AEB86F392A0D7FB3C/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false" alt="Image 2">
        <img src="https://steamuserimages-a.akamaihd.net/ugc/1899973303325325555/573AC19A817F6BBA5306CC6403A0845DE376CF15/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false" alt="Image 3">
        <img src="https://steamuserimages-a.akamaihd.net/ugc/1899973303325326183/36471834DA62D228A0671F8256F4281FA2EDBF67/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false" alt="Image 4">
    </div>
</body>
</html>
