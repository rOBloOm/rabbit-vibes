import { spawn } from 'node:child_process';

const serverPath = 'C:/dev/godot-mcp/build/index.js';
const godotPath = 'C:/Godot_v4.6.1-stable_mono_win64/Godot_v4.6.1-stable_mono_win64.exe';
const sandbox = 'C:/dev/jumpy/mcp_sandbox';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const child = spawn('node', [serverPath], {
  stdio: ['pipe', 'pipe', 'pipe'],
  env: { ...process.env, GODOT_PATH: godotPath }
});
child.stderr.on('data', (d) => process.stderr.write(d));
child.on('exit', (code) => console.log(`SERVER_EXIT=${code}`));

let buffer = Buffer.alloc(0), nextId = 1;
const pending = new Map();
child.stdout.on('data', (chunk) => { buffer = Buffer.concat([buffer, chunk]); parse(); });

function parse() {
  while (true) {
    const sep = buffer.indexOf('\n');
    if (sep === -1) return;
    const line = buffer.slice(0, sep).toString('utf8').trim();
    buffer = buffer.slice(sep + 1);
    if (!line) continue;
    const msg = JSON.parse(line);
    if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); }
    else console.log('NOTIFICATION', JSON.stringify(msg));
  }
}

function send(msg) { child.stdin.write(`${JSON.stringify(msg)}\n`); }
function request(method, params) {
  const id = nextId++;
  send({ jsonrpc: '2.0', id, method, params });
  return new Promise((resolve, reject) => {
    const t = setTimeout(() => { pending.delete(id); reject(new Error(`Timeout: ${method}`)); }, 30000);
    pending.set(id, (msg) => { clearTimeout(t); msg.error ? reject(new Error(JSON.stringify(msg.error))) : resolve(msg.result); });
  });
}
function notify(method, params) { send({ jsonrpc: '2.0', method, params }); }
function text(result) { return (result?.content || []).map((c) => c.text).join('\n'); }
async function tool(name, args = {}) { return request('tools/call', { name, arguments: args }); }

const results = [];
async function step(name, fn) {
  try {
    const result = await fn();
    results.push({ name, ok: true, result: typeof result === 'string' ? result : JSON.stringify(result) });
  } catch (err) {
    results.push({ name, ok: false, result: err.stack || String(err) });
  }
}

try {
  await request('initialize', { protocolVersion: '2024-11-05', capabilities: {}, clientInfo: { name: 'probe', version: '0.0.1' } });
  notify('notifications/initialized', {});

  await step('tools/list', async () => (await request('tools/list', {})).tools.map((t) => t.name).join(', '));
  await step('get_godot_version', async () => text(await tool('get_godot_version')));
  await step('list_projects', async () => text(await tool('list_projects', { directory: 'C:/dev/jumpy', recursive: true })));
  await step('get_project_info', async () => text(await tool('get_project_info', { projectPath: sandbox })));
  await step('create_scene', async () => text(await tool('create_scene', { projectPath: sandbox, scenePath: 'scenes/Main.tscn', rootNodeType: 'Node2D' })));
  await step('add_node Sprite2D', async () => text(await tool('add_node', { projectPath: sandbox, scenePath: 'scenes/Main.tscn', parentNodePath: 'root', nodeType: 'Sprite2D', nodeName: 'Sprite2D' })));
  await step('add_node Camera2D', async () => text(await tool('add_node', { projectPath: sandbox, scenePath: 'scenes/Main.tscn', parentNodePath: 'root', nodeType: 'Camera2D', nodeName: 'Camera2D' })));
  await step('load_sprite', async () => text(await tool('load_sprite', { projectPath: sandbox, scenePath: 'scenes/Main.tscn', nodePath: 'root/Sprite2D', texturePath: 'assets/test.png' })));
  await step('save_scene', async () => text(await tool('save_scene', { projectPath: sandbox, scenePath: 'scenes/Main.tscn' })));
  await step('get_uid scene', async () => text(await tool('get_uid', { projectPath: sandbox, filePath: 'scenes/Main.tscn' })));
  await step('update_project_uids', async () => text(await tool('update_project_uids', { projectPath: sandbox })));
  await step('run_project', async () => text(await tool('run_project', { projectPath: sandbox })));
  await sleep(4000);
  await step('get_debug_output', async () => text(await tool('get_debug_output')));
  await step('stop_project', async () => text(await tool('stop_project')));
} finally {
  console.log('RESULTS_START');
  for (const r of results) {
    console.log(`${r.ok ? 'OK' : 'FAIL'} :: ${r.name}`);
    console.log(r.result);
    console.log('---');
  }
  setTimeout(() => child.kill(), 500);
}

