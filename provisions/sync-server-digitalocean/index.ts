/*
export BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master;
deno run \
  --allow-net \
  --allow-read \
  --allow-env \
  --unstable \
  --lock=<(curl -o- "$BURL/provisions/sync-server-digitalocean/lock.json") \
  --cached-only \
  "$BURL/provisions/sync-server-digitalocean/index.ts"
*/

import {
  Confirm,
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
} from "../digitalocean/mod.ts";

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
  tag: "sync",
  token: config?.digitalOceanToken,
  tld: config?.topLevelDomain,
  hostname: config?.hostname,
  volumeSizeGb: config?.volumeSizeGb,
  region: config?.region,
  dropletSize: config?.dropletSize,
  sshKeyNames: config?.sshKeyNames,
});

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

const scriptUrl = new URL(
  "../../install-sync-digitalocean.sh",
  import.meta.url,
);

// User Data Script:
const SCRIPT = await generateProvisionScript(
  scriptUrl,
  {
    TLD,
    COUCH_MODE,
    COUCH_PASSWORD,
    COUCH_COOKIE,
  },
);

console.log(`Provision script url: ${scriptUrl}`);
console.log(`Provision script:\n${SCRIPT.replace(/^(.)/gm, "  $1")}`);

const confirmation = skipConfirmation ||
  await Confirm.prompt("Continue with provision?");

// Provision:
if (confirmation) {
  await provisionServer(settings, SCRIPT);
}
