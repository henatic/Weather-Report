const puppeteer = require("puppeteer");
// const {execSync} = require("child_process");
const fs = require("fs");
const date = new Date();
let currYear = date.getFullYear();
// process.chdir("U:Eureka\\SWPPP-INFO\\Rainfall_data-Eka\\");
let dir = currYear + '/';

/**
 * Loop meant to execute every hour, but report only generates every 72 hours.
 * Stores reports in a folder with the cooresponding year.
 */

function getReport() {

    // Redirect directory to a new yearly folder.

    if(currYear != new Date().getFullYear()) {
        currYear = new Date().getFullYear();
        dir = currYear + "/";
    }
    
    // If year directory doesn't exist, make a new one.

    if(!fs.existsSync(dir)) {
        fs.mkdir((dir), err => {
            if(err){
                throw err;
            }
        });
    }

    // Asynchronous function to access the browser and print the report of the specified URL.

    (async () => {
        let browser = await puppeteer.launch();
        let page = await browser.newPage();
        await page.goto("https://www.wrh.noaa.gov/eka/obs/getcgr.php?wfo=eka&sid=eka&obs=eka", {
          waitUntil: "networkidle2"
        });

        // Setting PDF options

        await page.setViewport({ width: 1680, height: 1050 });
        await page.pdf({
            path: dir + "/eka_"+ new Date().getMonth() + "-" + new Date().getDate() + "-" + new Date().getFullYear() +".pdf",
            format: "A4",
            printBackground: true,
            displayHeaderFooter: true,
            margin: {
                top: '38px',
                right: '38px',
                bottom: '38px',
                left: '38px'
            }
        });
            // Close browser.
            await browser.close();

            // Print to the console about the new weather report.
            console.log("New Weather Report available: " + new Date().getMonth() + "-" + new Date().getDate() + "-" + new Date().getFullYear());
    })();

}

// Send an initial report when the program starts.
getReport();
console.log("Began running Reporter.js. Press Ctrl+C to end process.");
setInterval(getReport, 259200000); // Runs getReport() every 72 hours (259200000 milliseconds).

