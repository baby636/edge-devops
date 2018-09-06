const f = require('/home/bitz/failedRepos.json')
if (f.length > 0) {
  console.log('CRITICAL: Failed repos: ' + f.length.toString())
  process.exit(2)
} else {
  console.log('SUCCESS')
  process.exit(0)
}
