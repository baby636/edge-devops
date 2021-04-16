/*
export BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master;
deno run \
  --allow-net \
  --allow-read \
  --allow-env \
  --unstable \
  --lock=<(curl -o- "$BURL/provisions/digitalocean/lock.json") \
  --cached-only \
  "$BURL/provisions/digitalocean/index.ts"
*/

import {
  Confirm,
  List,
  Secret,
} from "https://deno.land/x/cliffy@v0.17.2/prompt/mod.ts";
import { parseFlags } from "https://deno.land/x/cliffy@v0.17.2/flags/mod.ts";
import { asConfg, Config } from "./config.ts";
import {
  asEither,
  asString,
  asUndefined,
} from "https://deno.land/x/cleaners@v0.3.6/mod.ts";
import {
  generateProvisionScript,
  getProvisionSettings,
  provisionServer,
} from "./util.ts";

// Config:
let config: Config | undefined;

const { flags } = parseFlags(Deno.args);
const configFileName = asEither(asString, asUndefined)(flags.config);
const skipConfirmation = Boolean(flags.y);

if (configFileName != null) {
  const configFileContent = await Deno.readTextFile(configFileName);
  config = asConfg(JSON.parse(configFileContent));
}

// Provision Settings;
const settings = await getProvisionSettings({
  tag: config?.dropletTag,
  token: config?.digitalOceanToken,
  tld: config?.topLevelDomain,
  hostname: config?.hostname,
  volumeSizeGb: config?.volumeSizeGb,
  region: config?.region,
  dropletSize: config?.dropletSize,
  sshKeyNames: config?.sshKeyNames,
});

// Install Script
let scriptUrl: URL | undefined;
let SCRIPT: string | undefined;

if (config?.installScript != null) {
  // Env Var:
  const { TLD } = settings;
  const COUCH_MODE = "clustered";
  const COUCH_PASSWORD = config?.couchPassword ?? await Secret.prompt({
    message: "CouchDB password",
    validate: (v) => v.trim() !== "",
  });
  const COUCH_COOKIE = config?.couchMasterCookie ?? await Secret.prompt({
    message: "CouchDB master cookie",
    validate: (v) => v.trim() !== "",
  });
  const COUCH_SEEDLIST = config?.couchClusterSeedList ?? await List.prompt({
    message: "CouchDB cluster seedlist",
    validate: (v) => v.trim() !== "",
  });

  scriptUrl = new URL(
    `../../${config?.installScript}`,
    import.meta.url,
  );

  // User Data Script:
  SCRIPT = await generateProvisionScript(
    scriptUrl,
    {
      TLD,
      COUCH_MODE,
      COUCH_PASSWORD,
      COUCH_COOKIE,
      COUCH_SEEDLIST: COUCH_SEEDLIST.join(","),
    },
  );

  console.log(`Install script url: ${scriptUrl}`);
  console.log(`Install script:\n${SCRIPT.replace(/^(.)/gm, "  $1")}`);
} else {
  console.log(`No install script.`);
}

const confirmation = skipConfirmation ||
  await Confirm.prompt("Continue with provision?");

// Provision:
if (confirmation) {
  await provisionServer(settings, SCRIPT);
}
