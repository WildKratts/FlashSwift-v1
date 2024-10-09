document.addEventListener("DOMContentLoaded", () => {
    console.log("DOM fully loaded and parsed");

    const ruffle = window.RufflePlayer.newest();
    if (!ruffle) {
        console.error("Ruffle is not available. Ensure ruffle.js is loaded correctly.");
        return;
    }

    const container = document.getElementById("player-container");
    if (!container) {
        console.error("Player container not found in the DOM.");
        return;
    }

    const player = ruffle.createPlayer();
    container.appendChild(player);

    // Ensure the player and container size fill the window
    container.style.width = "100%";
    container.style.height = "100%";
    player.style.width = "100%";
    player.style.height = "100%";

    // Load the SWF file from an external URL
    player.load("https://ruffle.rs/demo/swfs/wasted_sky.swf");
    console.log("SWF file loaded");
});

