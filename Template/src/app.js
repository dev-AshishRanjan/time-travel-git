// const yaml = require("js-yaml");
// const fs = require("fs");
// const path = require("path");

// // Read the contents of the YAML file
// const data = yaml.load(
//   fs.readFileSync(path.join(__dirname, "../database/data.yaml"), "utf8")
// );
// console.log(data);

// import { yaml } from "modulejs";
// import Yamldata from "../database/data.yaml";
var data;
const cards = document.querySelector(".cards");
fetch("./database/data.yaml")
  .then((response) => response.text())
  .then((Yamldata) => {
    data = jsyaml.load(Yamldata);
    console.log(data);
    data &&
      data.map((ele) => {
        const card = document.createElement("a");
        card.classList.add("card");
        card.setAttribute("href", ele.html_url);
        // const card = `<a href=${ele.html_url} class="card" key=${ele.id}>
        card.innerHTML = `<img src="${ele.avatar_url}" alt="${ele.login}"/>
        <h2>${ele.login}</h2>`;
        cards.appendChild(card);
      });
  });
