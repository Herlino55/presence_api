const { Pool } = require('pg');

const pool = new Pool({
  user: "postgres", 
  host: "switchyard.proxy.rlwy.net",
  database: "railway", 
  password: "xSgcHYYgPHvGJmfzAQhiggkbwPbRtAAA", 
  port: 48564,
});

module.exports = pool;
