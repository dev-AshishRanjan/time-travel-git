const { exec } = require("child_process");
// const shellCommands = require("./run.sh");

exec(`./run.sh Sonal144 githubUser 50 false`, (error, stdout, stderr) => {
  if (error) {
    console.error(`exec error: ${error}`);
    console.error(`stderr: ${stderr}`); // Print stderr output
    return;
  }
  console.log(`stdout: ${stdout}`);
  console.error(`stderr: ${stderr}`);
});
