/*
deno run \
  --allow-net \
  --allow-read \
  --unstable \
  --lock=<(curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/provisions/sync-server-digitalocean/lock.json) \
  --cached-only \
  https://raw.githubusercontent.com/EdgeApp/edge-devops/master/provisions/sync-server-digitalocean/index.ts
*/

import { Secret } from "https://deno.land/x/cliffy@v0.17.2/prompt/mod.ts";
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

// User Data Script:
const SCRIPT = await generateProvisionScript(
  "../../install-sync-digitalocean.sh",
  {
    TLD,
    COUCH_MODE,
    COUCH_PASSWORD,
    COUCH_COOKIE,
  },
);

// Provision:
await provisionServer(settings, SCRIPT);
