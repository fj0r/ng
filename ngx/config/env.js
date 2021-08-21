const fs = require('fs').promises

function bin(r) {
    var f = METHODS[r.variables[1]]
    f ? f(r) : r.return(200, JSON.stringify({avaiables: Object.keys(METHODS)}))
}

const METHODS = {
    headers : r => r.return(200, JSON.stringify(r.headersIn)),
    ip      : r => r.return(200, r.headersIn['X-Real-IP']),
    rdr     : r => r.return(301, r.args.url),
    ua      : r => r.return(200, r.headersIn['User-Agent']),
    body    : r => r.return(200, r.requestBuffer),
    version : r => r.return(200, JSON.stringify({ngx: r.variables.nginx_version, njs: njs.version, tz: process.env.TIMEZONE})),
    dump    : r => r.return(200, JSON.stringify({env: process.env})),
    errorLog: r => fs.readFile('/opt/nginx/logs/error.log').then(data=>r.return(200, data)),
    r       : r => r.return(200, JSON.stringify(r)),
    v       : r => r.return(200, JSON.stringify(r.variables[r.args.v])),
}


function check_scheme(url) {
  if (url.startsWith('http')) {
    return url
  } else {
    return `http://${url}`
  }
}

function get_host(url) {
  if (url.startsWith('http')) {
    return url.split(':')[1].slice(2)
  } else {
    return url.split(':')[0]
  }
}

function _env(n) {
  return process.env[`UPSTREAM_${n.toUpperCase()}`]
}


function u_api(r) {
  return check_scheme(_env('api'))
}

function u_api_host(r) {
  return get_host(_env('api'))
}

function u_xmh(r) {
  return check_scheme(_env('xmh'))
}

function u_xmh_host(r) {
  return get_host(_env('xmh'))
}

function u_test(r) {
  return check_scheme(_env('test'))
}

export default { bin
               , u_test
               , u_api
               , u_api_host
               , u_xmh
               , u_xmh_host
               }
